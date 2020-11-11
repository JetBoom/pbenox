AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/doll01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	self.NextScreamTime = CurTime()

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetMass(5)
	end

	self:Fire("scream", "", 0)
	self:Fire("kill", "", 8)
end

function ENT:AcceptInput(name)
	if name == "scream" then
		self:EmitSound("ambient/creatures/town_muffled_cry1.wav", 100, 100)
		self:Fire("scream", "", 1)

		return true
	end
end
