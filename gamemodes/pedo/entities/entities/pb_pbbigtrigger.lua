ENT.Type = "anim"

function ENT:Initialize()
	--self:SetModel("models/props_junk/PopCan01a.mdl")
	self:PhysicsInitBox(Vector(-20, -20, 0), Vector(20, 20, 144))
	self:SetCollisionBounds(Vector(-20, -20, 0), Vector(20, 20, 144))
	self:SetTrigger(true)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

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
