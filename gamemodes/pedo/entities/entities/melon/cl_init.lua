include("shared.lua")

function ENT:Draw()
	self:SetRenderAngles(Angle(0, (CurTime() * 360) % 360, 0))

	self:DrawModel()
end