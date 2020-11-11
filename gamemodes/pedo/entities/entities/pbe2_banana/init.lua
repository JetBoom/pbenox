AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModelScale(2, 0)
	self:SetModel("models/weapons/w_banana.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetTrigger(true)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(5)
		phys:Wake()
	end

	self.CreatedTime = CurTime()
end

function ENT:StartTouch(ent)
	if self.Removing or CurTime() < self.CreatedTime + 1 or not ent:IsActivePlayer() then return end

	local ang = ent:EyeAngles()
	local oldyaw = ang.yaw
	ang.yaw = math.Rand(0, 360)
	if math.abs(oldyaw, ang.yaw) < 90 then
		ang.yaw = -ang.yaw
	end
	ent:SetEyeAngles(ang)

	ent:SetGroundEntity(NULL)
	ent:SetLocalVelocity(ent:GetVelocity() * 0.2 + Vector(0, 0, 520))
	ent:KnockDown(2)

	local pos = self:WorldSpaceCenter()

	local effectdata = EffectData()
		effectdata:SetStart(pos)
		effectdata:SetOrigin(pos)
	util.Effect("AntlionGib", effectdata)

	sound.Play("physics/flesh/flesh_squishy_impact_hard2.wav", pos, 120)

	self:RemoveNextFrame()
end
