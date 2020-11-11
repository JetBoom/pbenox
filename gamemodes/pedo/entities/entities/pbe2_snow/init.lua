AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModelScale(1.5, 0)
	self:SetModel("models/weapons/pbecustom/snowmanface.mdl")
	self:PhysicsInitSphere(20)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetTrigger(true)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetMass(5)
	end

	self.Created = CurTime()

	self:Fire("kill", "", 9)
end

function ENT:StartTouch(ent)
	if self.Removing or not ent:IsActivePlayer() or ent == self:GetOwner() and CurTime() < self.Created + 0.5 then return end

	ent:SetRunSpeed(GAMEMODE.RunSpeed * 0.60)
	ent:SetWalkSpeed(GAMEMODE.RunSpeed * 0.60)
	ent:SetNormalSpeedTime(CurTime() + 5)

	self:RemoveNextFrame()
end

function ENT:OnRemove()
	local pos = self:GetPos()

	local effectdata = EffectData()
		effectdata:SetStart(pos)
		effectdata:SetOrigin(pos)
		effectdata:SetScale(3)
	util.Effect("GlassImpact", effectdata)

	self:EmitSound("physics/glass/glass_impact_bullet4.wav", 80, 120)
end
