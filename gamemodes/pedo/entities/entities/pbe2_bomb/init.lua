AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(5)
		phys:Wake()
	end

	for i=0.5, 2.5, 0.5 do
		self:Fire("flash", "", i)
	end
	self:Fire("explode", "", 3)
end

function ENT:Explode()
	if self.Removing then return end
	self:RemoveNextFrame()

	local epicenter = self:GetPos()

	local effectdata = EffectData()
		effectdata:SetStart(epicenter)
		effectdata:SetOrigin(epicenter)
		effectdata:SetScale(3)
	util.Effect("HelicopterMegaBomb", effectdata)

	self:EmitSound("weapons/explode"..math.random(3, 5)..".wav", 90, 120)

	for k, ent in pairs(ents.FindInSphere(epicenter, 1024)) do
		if ent and ent:IsValid() then
			if ent:IsPlayer() then
				local vel = ent:GetVelocity() + (ent:WorldSpaceCenter() - epicenter) ^ 350
				vel.z = vel.z + 350
				ent:SetGroundEntity(NULL)
				ent:SetLocalVelocity(vel)
			elseif ent.IsRapist then
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:AddVelocity((ent:WorldSpaceCenter() - epicenter) ^ 1600)
				end
			end
		end
	end
end

function ENT:AcceptInput(name)
	if name == "flash" then
		self:SetColor(Color(0, 0, 0, 255))
		self:EmitSound("weapons/grenade/tick1.wav", 80, 120)

		self:Fire("unflash", "", 0.2)

		return true
	elseif name == "unflash" then
		self:SetColor(color_white)

		return true
	elseif name == "explode" then
		self:Explode()

		return true
	end
end
