AddCSLuaFile()

ENT.Type = "anim"

function ENT:Initialize()
	self:DrawShadow(false)
	if CLIENT then
		self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 64))
	end
end

if not CLIENT then return end

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local colDraw = Color(255, 255, 255, 180)
local CurTime = CurTime

function ENT:DrawTranslucent()
	local mod = (CurTime() * 3) % 1
	local scale = 1 + mod * 0.45

	render_SetMaterial(mod < 0.5 and GAMEMODE.Rapists[1].MaterialRight or GAMEMODE.Rapists[1].MaterialLeft)
	render_DrawSprite(self:GetPos() % 16, 16 * scale, 32 * scale, colDraw)
end
