AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01.mdl")
	self:PhysicsInitSphere(8)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetTrigger(true)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end

	self:Fire("kill", "", 30)
end

function ENT:StartTouch(ent)
	if self.Removing or not ent:IsPlayer() or not ent:IsActivePlayer() then return end

	ent:StripWeapons() --if not ent:GetCurrentItem() then
		ent:Give(table.Random(GAMEMODE:GetItemsList())["swep"])
	--end

	self:RemoveNextFrame()
end

function ENT:OnRemove()
	local pos = self:GetPos()

	local effectdata = EffectData()
		effectdata:SetStart(pos)
		effectdata:SetOrigin(pos)
	util.Effect("AntlionGib", effectdata)

	self:EmitSound("physics/flesh/flesh_squishy_impact_hard2.wav", 80, 120)
end