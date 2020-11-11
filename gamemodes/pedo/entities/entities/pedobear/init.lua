AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local rapeSounds = {
	"vo/npc/barney/ba_pain01.wav",
	"vo/npc/barney/ba_pain02.wav",
	"vo/npc/barney/ba_pain03.wav",
	"vo/npc/barney/ba_pain04.wav",
	"vo/npc/barney/ba_pain05.wav",
	"vo/npc/barney/ba_pain06.wav",
	"vo/npc/barney/ba_pain07.wav",
	"vo/npc/barney/ba_pain08.wav",
	"vo/npc/barney/ba_pain09.wav",
	"vo/npc/barney/ba_pain10.wav",
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav"
}

ENT.NextAssPound = 0
ENT.StuckFrames = 0
ENT.TrickyTrackTimeRequired = 1
ENT.TrickyAccuracy = 1
ENT.TargetAcquireTime = 0
ENT.CurrentTarget = NULL

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self.TargetPos = self:GetPos()

	self:DrawShadow(false)
	--self:SetModel("models/props_junk/PopCan01a.mdl") -- This makes the locomotion have very small bounds so it doesn't get stuck.
	self:SetModel("models/headcrabclassic.mdl")
	--self:SetModel("models/player.mdl")
	--self:PhysicsInitBox(Vector(-20, -20, 0), Vector(20, 20, 144))
	--self:SetCollisionBounds(Vector(-20, -20, 0), Vector(20, 20, 144))
	self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
	self:SetCustomCollisionCheck(true)
	--self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetSolidMask(MASK_NPCSOLID)

	self.nextFree = CurTime()

	self:Fire("taunt", "", 1)

	self:SetRapistType(math.random(#GAMEMODE.Rapists))

	self.loco:SetStepHeight(24)
	self.loco:SetJumpHeight(240)
	self.loco:SetAcceleration(750)
	self.loco:SetDeceleration(750)
	self.loco:SetDeathDropHeight(99999)
	self.loco:SetDesiredSpeed(380)

	local trigger = ents.Create("pb_pbtrigger")
	if trigger:IsValid() then
		trigger:SetPos(self:GetPos())
		trigger:SetOwner(self)
		trigger:SetParent(self)
		trigger:Spawn()
		self.Trigger = trigger
	end

	self:CollisionRulesChanged()

	self.TrickyTrackTimeRequired = math.Rand(8, 12)
	self.TrickyAccuracy = math.Rand(0.8, 1.1)
end

function ENT:AcceptInput(name)
	if name == "taunt" then
		if not self:IsRaping() then
			self:Fire("taunt", "", math.Rand(3, 7))
			self:EmitSound("pbe2/pedobear_amb"..math.random(4)..".ogg", 90, math.random(97, 103))
		end

		return true
	end
end

--[[local tempent
local function Compute( area, fromArea, ladder, elevator, length )
	if not IsValid( fromArea ) then
		-- first area in path, no cost
		return 0
	else

		if not tempent.loco:IsAreaTraversable( area ) then
			-- our locomotor says we can't move here
			return -1
		end

		-- compute distance traveled along path so far
		local dist = 0
		if IsValid(ladder) then
			-- ladders don't work
			dist = 9999 --ladder:GetLength()
		elseif length > 0 then
			-- optimization to avoid recomputing length
			dist = length
		else
			dist = (area:GetCenter() - fromArea:GetCenter()):GetLength()
		end

		local cost = dist + fromArea:GetCostSoFar()

		-- check height change
		local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange( area )
		if ( deltaZ >= tempent.loco:GetStepHeight() ) then
			if ( deltaZ >= tempent.loco:GetMaxJumpHeight() ) then
				-- too high to reach
				return -1
			end

			-- jumping is MUCH slower than flat ground so only do it if can't find anything else
			cost = cost + 8 * dist + 256
		-- Who cares?
		--[[elseif deltaZ < -tempent.loco:GetDeathDropHeight() then
			-- too far to drop
			return -1]]
		--[[end

		return cost
	end
end]]

-- Not every pedobear on the map needs to compute all this shit
local TargetPositions = {}
local MaxEnemiesPerPlayer = 3
hook.Add("Think", "FindPBTargets", function()
	local active = 0
	local targets = {}

	for _, ply in ipairs(team.GetPlayers(TEAM_RUNNER)) do
		if ply:IsActive() and ply:GetState() ~= STATE_RAPE and ply:GetObserverMode() == OBS_MODE_NONE then
			targets[#targets + 1] = ply
			ply.TargetedBy = 0
			active = active + 1
		end
	end

	for _, baby in pairs(ents.FindByClass("pbe2_baby")) do
		if baby:IsValid() then
			targets[#targets + 1] = baby
			baby.TargetedBy = -1000
			active = active + 1
		end
	end

	if active > 0 then
		MaxEnemiesPerPlayer = math.max(#ents.FindByClass("pedobear") / active * 0.7, 3)
		--print(MaxEnemiesPerPlayer)
	end

	TargetPositions = targets
end)

function ENT:RunBehaviour()
	while true do
		if not self:IsRaping() then
			self:SetTargetPosToClosestTarget()
			self:ChasePos()
		end

		coroutine.wait(0.1)
	end
end

function ENT:SetTargetPosToClosestTarget()
	local length = 999999
	local pathlength

	if #TargetPositions == 0 then
		self.TargetPos = nil
		return
	end

	local tpath = Path("Follow")
	tpath:SetMinLookAheadDistance(128)
	tpath:SetGoalTolerance(8)

	local target
	local pos

	for _, ent in pairs(TargetPositions) do
		pos = ent:GetPos()
		if ent.TargetedBy < MaxEnemiesPerPlayer then
			--[[tempent = self
			tpath:Compute(self, pos, Compute)]]
			tpath:Compute(self, pos)

			pathlength = tpath:GetLength()
			if ent.TargetPriority then
				pathlength = pathlength / ent.TargetPriority
			end
			if ent.TargetExtraPriority then
				pathlength = pathlength - ent.TargetExtraPriority
			end
			if ent == self.CurrentTarget then
				pathlength = pathlength * 0.9
			end
			if tpath:IsValid() and pathlength < length then
				length = pathlength
				target = ent
			end
		--[[else
			print("Ignoring ", ent, " because they're targeted by ", ent.TargetedBy, " and max is ", MaxEnemiesPerPlayer)]]
		end
	end

	if not target then
		if self.CurrentTarget ~= NULL then
			self.CurrentTarget = NULL
			self:TargetChanged(NULL)
		end

		return
	end

	pos = target:GetPos()

	if self.UseTrickyMovement then
		pos = pos + target:GetVelocity() * self.TrickyAccuracy + self.TrickDirection * 48 * (pos - self:GetPos()):Angle():Right()
		if CurTime() > self.UseTrickyMovement then
			self.UseTrickyMovement = nil
		end
	end

	self.TargetPos = pos
	tpath:Compute(self, pos)

	if target == self.CurrentTarget then
		if self.TrickTime then
			if CurTime() >= self.TrickTime then
				self.TrickTime = nil
				self.UseTrickyMovement = CurTime() + math.Rand(0.66, 1.66)
				self.TrickDirection = math.random(2) == 1 and -1 or 1
				--print("Starting to use tricky movement")
			end
		elseif self:HasBeenTrackingTargetFor(self.TrickyTrackTimeRequired) then
			if pos:DistToSqr(self:GetPos()) <= 16384 then -- 128^2
				self.TrickTime = CurTime() + math.Rand(0, 2)
			end
		end
	else
		self.CurrentTarget = target
		self:TargetChanged(target)
	end

	target.TargetedBy = target.TargetedBy + 1
end

function ENT:TargetChanged(target)
	self.TargetAcquireTime = CurTime()
	self.TrickTime = nil
	if not target:IsValid() then
		self:TargetLost()
	end
end

function ENT:HasBeenTrackingTargetFor(time)
	return self.CurrentTarget:IsValid() and CurTime() >= self.TargetAcquireTime + time
end

function ENT:ChasePos()
	if not self.TargetPos then return end

	local path = Path("Follow")
	path:SetMinLookAheadDistance(400)
	path:SetGoalTolerance(8)
	path:Compute(self, self.TargetPos)

	if not path:IsValid() then return "failed" end

	while path:IsValid() and self.TargetPos do
		if path:GetAge() >= 0.05 then
			self:SetTargetPosToClosestTarget()
			if self.TargetPos then
				path:Compute(self, self.TargetPos)
			end
		end
		path:Update(self)

		if self:IsRaping() then
			self.loco:SetDesiredSpeed(0)
		elseif path:GetLength() >= 2000 or GAMEMODE.MegaRape then
			self.loco:SetDesiredSpeed(800)
		else
			self.loco:SetDesiredSpeed(385)
		end

		if self.loco:IsStuck() or self:EntityStuck() then
			self:HandleStuck()
			return "stuck"
		end

		if not self:EntityStuck() then
			self.StuckFrames = 0
		end

		coroutine.yield()
	end

	return "ok"
end

function ENT:HandleStuck()
	self.StuckFrames = self.StuckFrames + 1
	if self.StuckFrames >= 40 then
		self.StuckFrames = 0
		self.QueueUnstuck = true
		self.QueueJump = nil
	elseif self.StuckFrames >= 3 then
		self.QueueJump = true
	end
end

function ENT:EntityStuck()
	return self:WaterLevel() >= 3
end

local ShouldBreak = {
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true,
	["func_physbox"] = true,
	["func_physbox_multiplayer"] = true,
	["func_breakable"] = true,
	["func_breakable_surf"] = true,
	["prop_door_rotating"] = true,
	["func_door_rotating"] = true
}

local ShouldOpen = {
	--[[ ["prop_door_rotating"] = true,
	["func_door_rotating"] = true]]
}

function ENT:Think()
	if self.QueueUnstuck then
		self.QueueUnstuck = nil
		self.StuckFrames = 0
		self:SetPos(GAMEMODE:GetBearSpawnPoint())
	end

	if self.QueueJump then
		self.QueueJump = nil

		self.loco:Jump()

		if self.TargetPos and not self.JumpTowardsTime then
			self.JumpTowardsTime = CurTime() + 0.5
			self.JumpTowards = self.TargetPos - self:GetPos()
			self.JumpTowards.z = 0
			self.JumpTowards:Normalize()
			self.JumpTowards = self.JumpTowards * 200
		end
	end

	if GAMEMODE:GetRoundState() == ROUND_PLAY then
		local victim = self:GetRapeVictim()
		if victim:IsValid() then
			if CurTime() >= self.NextAssPound then
				self:EmitSound(table.Random(rapeSounds), 95, math.random(95, 105))
				self.NextAssPound = CurTime() + 0.3
			end

			if CurTime() >= self.nextFree then
				victim:TakeSpecialDamage(1000, DMG_CRUSH, self, self, self:GetPos(), victim:GetForward() * 30000 + Vector(0, 0, 30000))

				self:SetRapeVictim(NULL)

				self:SetPos(victim:GetPos())
			else
				local pos = victim:GetPos() - victim:GetForward() * 30
				pos.z = pos.z + 20
				self:SetPos(pos)
			end
		else
			if self.JumpTowardsTime and CurTime() >= self.JumpTowardsTime then
				self.JumpTowardsTime = nil
				self.loco:SetVelocity(self.JumpTowards)
				self.JumpTowards = nil
			end

			for _, ent in pairs(ents.FindInSphere(self:GetPos(), 32)) do
				if ent:IsValid() then
					if ShouldBreak[ent:GetClass()] then
						self:BreakProp(ent)
					end
				end
			end
		end
	else
		local victim = self:GetRapeVictim()
		if IsValid(victim) then
			victim:SetStateForced(STATE_NONE)

			self:SetRapeVictim(NULL)

			self:SetPos(victim:GetPos())
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	local victim = self:GetRapeVictim()
	if IsValid(victim) then
		victim:SetStateForced(STATE_NONE)

		self:SetRapeVictim(NULL)
	end
end

function ENT:BreakProp(ent)
	ent:Fire("open", "", 0)
	ent:Fire("break", "", 0.25)
	ent:Fire("kill", "", 0.3)
	ent:TakeDamage(2000, self, self)
end

function ENT:OpenProp(ent)
	ent:Fire("open", "", 0)
end

function ENT:DoTouch(ent)
	if GAMEMODE:GetRoundState() ~= ROUND_PLAY or self:IsRaping() then return end

	if not ent:IsPlayer() then
		local entclass = ent:GetClass()
		if ShouldBreak[entclass] then
			self:BreakProp(ent)
		elseif ShouldOpen[entclass] then
			self:OpenProp(ent)
		end

		return
	end

	if not ent:IsActive() or ent:GetState() == STATE_RAPE then return end

	self:SetRapeVictim(ent)
	self:EmitSound("physics/flesh/flesh_bloody_break.wav", 90, math.random(95, 105))

	self.nextFree = CurTime() + 5

	self.loco:SetDesiredSpeed(0)
	self.loco:SetVelocity(vector_origin)

	ent:StripWeapons()
	ent:SetStateForced(STATE_RAPE)

	net.Start("pb_pl_raped")
		net.WriteEntity(ent)
	net.Broadcast()
end
