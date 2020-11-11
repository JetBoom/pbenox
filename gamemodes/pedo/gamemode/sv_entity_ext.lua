local meta = FindMetaTable("Entity")
if not meta then return end

function meta:RemoveNextFrame()
	self.Removing = true
	self:Fire("kill", "", 0.01)
end

function meta:ThrowFromPosition(pos, force, knockdownthreshold)
	if force == 0 or self:IsProjectile() or self.NoThrowFromPosition then return false end

	if self:IsPlayer() then
		force = force * (self.KnockbackScale or 1)
	end

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			phys:ApplyForceOffset(force * 50 * (nearest - pos):NormalizeRef(), nearest)
		end

		return true
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		if SERVER and self:IsPlayer() then
			if math.abs(absforce) >= (knockdownthreshold or 32) then
				self:KnockDown()
			end
		end
		self:SetVelocity(force * (self:LocalToWorld(self:OBBCenter()) - pos):NormalizeRef())

		return true
	end
end

function meta:ThrowFromPositionSetZ(pos, force, zmul, knockdownthreshold)
	if force == 0 or self:IsProjectile() or self.NoThrowFromPosition then return false end
	zmul = zmul or 0.7

	if self:IsPlayer() then
		force = force * (self.KnockbackScale or 1)
	end

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			local dir = nearest - pos
			dir.z = 0
			dir:Normalize()
			dir.z = zmul
			phys:ApplyForceOffset(force * 50 * dir, nearest)
		end

		return true
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		if SERVER and self:IsPlayer() then
			if math.abs(absforce) >= (knockdownthreshold or 32) then
				self:KnockDown()
			end
		end

		local dir = self:LocalToWorld(self:OBBCenter()) - pos
		dir.z = 0
		dir:Normalize()
		dir.z = zmul
		self:SetVelocity(force * dir)

		return true
	end
end

local function bonescale(e, b, s)
	local bone = e:LookupBone(b)
	if bone then
		e:ManipulateBoneScale(bone, s)
	end
end

local function bonetranslate(e, b, s)
	local bone = e:LookupBone(b)
	if bone then
		e:ManipulateBonePosition(bone, s)
	end
end

local headBone = "ValveBiped.Bip01_Head1"
local pelvisBone = "ValveBiped.Bip01_Pelvis"
local spineBones = {"ValveBiped.Bio01_Spine1", "ValveBiped.Bio01_Spine2", "ValveBiped.Bip01_Spine4"}
local legBones = {"ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_L_Calf"}
local armBones = {"ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_L_Forearm"}
function meta:SetAge(age, nopelvis)
	self.Age = age

	local effectiveAge = age
	if effectiveAge < 1 then
		effectiveAge = 1
	elseif effectiveAge > 18 then
		effectiveAge = 18
	end

	local ageFloat = (effectiveAge - 1) / 17
	local rageFloat = 1 - ageFloat

	--[[local speed = defaultSpeed * (0.65 + 0.35 * ageFloat)
	local jump = defaultJump * (0.8 + 0.2 * ageFloat)

	local heightScale = 0.4 + ageFloat * 0.6
	local lateralScale = 0.6 + ageFloat * 0.4]]
	local headScale = 2.2 - ageFloat * 1.2
	local legScale = 1.3 - ageFloat * 0.3
	local armScale = legScale
	local armmove = rageFloat * 4
	local spinemove = rageFloat * -3
	local heightchange = rageFloat * 24

	--[[local hullMins = defaultHullMins * lateralScale
	local hullMaxs = defaultHullMaxs * lateralScale
	hullMaxs.z = defaultHullMaxs.z * heightScale
	local hullMaxsDucked = hullMaxs * 1 -- For whatever reason this isn't copying without * 1
	hullMaxsDucked.z = hullMaxs.z * 0.5]]

	bonescale(self, headBone, Vector(headScale, headScale, headScale))

	--[[for _, bone in pairs(legBones) do
		bonescale(self, bone, Vector(legScale, legScale, legScale))
	end]]

	for _, bone in pairs(spineBones) do
		bonetranslate(self, bone, Vector(spinemove, 0, 0))
	end

	bonetranslate(self, pelvisBone, nopelvis and vector_origin or Vector(0, 0, heightchange * -0.8))

	bonetranslate(self, "ValveBiped.Bip01_L_Upperarm", Vector(0, armmove, 0))
	bonetranslate(self, "ValveBiped.Bip01_L_Forearm", Vector(-armmove, 0, 0))
	bonetranslate(self, "ValveBiped.Bip01_R_Upperarm", Vector(0, armmove, 0))
	bonetranslate(self, "ValveBiped.Bip01_R_Forearm", Vector(-armmove, 0, 0))

	for _, bone in pairs(legBones) do
		bonetranslate(self, bone, Vector(0, heightchange / 2, 0))
	end

	for _, bone in pairs(armBones) do
		bonescale(self, bone, Vector(armScale, armScale, armScale))
	end
end

function meta:GetAge()
	return self.Age or 18
end
