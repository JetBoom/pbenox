AddCSLuaFile()

ENT.Type = "anim"

ENT.PBTRIGGER = true

if SERVER then
	function ENT:Initialize()
		self:DrawShadow(false)
		self:SetNoDraw(true)

		self:PhysicsInitBox(Vector(-17, -17, 0), Vector(17, 17, 144))
		self:SetCollisionBounds(Vector(-17, -17, 0), Vector(17, 17, 144))
		self:SetTrigger(true)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetMoveType(MOVETYPE_NONE)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
	end

	function ENT:StartTouch(ent)
		self:GetParent():DoTouch(ent)
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_NEVER
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_NONE

	function ENT:Initialize()
		self:DrawShadow(false)
		self:SetNoDraw(true)
	end

	function ENT:Draw()
	end
end
