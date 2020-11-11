AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInitBox(Vector(-10240, -10240, 0), Vector(10240, 10240, 16))
	self:DrawShadow(false)
	self:SetNoDraw(true)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end
end
