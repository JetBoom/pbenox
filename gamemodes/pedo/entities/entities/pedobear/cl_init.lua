include("shared.lua")

--local color_white = color_white
local CurTime = CurTime
local EyePos = EyePos
local render_DrawQuadEasy = render.DrawQuadEasy
local render_SetMaterial = render.SetMaterial

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))
end

function ENT:DrawTranslucent()
	local rapist = self:GetRapist()
	if not rapist or not rapist.MaterialRight then return end

	local raping = self:GetRaping()
	local center = self:GetPos() % (rapist.SpriteYOffset or 48)

	if (CurTime() + self:EntIndex() * 0.1) * 2.5 % 1 < 0.5 then
		render_SetMaterial(raping and rapist.MaterialRightRape or rapist.MaterialRight)
	else
		render_SetMaterial(raping and rapist.MaterialLeftRape or rapist.MaterialLeft)
	end

	render_DrawQuadEasy(center, (EyePos() - center) ^ 1, (raping and rapist.SpriteRapingXScale or rapist.SpriteXScale or 1) * 64, (raping and rapist.SpriteRapingXScale or rapist.SpriteXScale or 2) * 64, self:GetColor(), 180)
end
