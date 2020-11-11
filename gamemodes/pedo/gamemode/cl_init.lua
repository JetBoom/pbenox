include("shared.lua")
--include("sh_player_ext.lua")

include("vgui/dexnotificationslist.lua")

include("obj_player_extend_cl.lua")
include("cl_audio.lua")
include("cl_round.lua")
include("cl_skin.lua")
include("cl_help.lua")
include("cl_options.lua")
include("cl_items.lua")
include("cl_targetid.lua")
include("cl_hud.lua")

CreateClientConVar("pbe2_playermodel", "models/player/kleiner.mdl", true, true)
CreateConVar( "cl_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO }, "The value is a Vector - so between 0-1 - not between 0-255" )
CreateConVar( "cl_weaponcolor", "0.30 1.80 2.10", { FCVAR_ARCHIVE, FCVAR_USERINFO }, "The value is a Vector - so between 0-1 - not between 0-255" )
local math_min = math.min
local math_max = math.max

-- Scales the screen based around 1080p but doesn't make things TOO tiny on low resolutions.
function BetterScreenScale()
	return math.Clamp(ScrH() / 1080, 0.6, 1)
end

function GM:Initialize()
	self:CreateFonts()
	self:CreateRapistMaterials()
	self:CreateVGUI()
	self:PrecacheResources()
end

function GM:InitPostEntity()
	--GAMEMODE:PlayMusic()
	self:ShowTeam()

	self.CreateMove = self._CreateMove
end

function GM:CreateVGUI()
	self.TopNotificationHUD = vgui.Create("DEXNotificationsList")
	self.TopNotificationHUD:SetAlign(RIGHT)
	self.TopNotificationHUD.PerformLayout = function(pan)
		local ss = BetterScreenScale()
		pan:SetSize(ScrW() * 0.4, ScrH() * 0.6)
		pan:AlignTop(16 * ss)
		pan:AlignRight()
	end
	self.TopNotificationHUD:InvalidateLayout()
	self.TopNotificationHUD:ParentToHUD()
end

function GM:CreateFonts()
	surface.CreateFont("FRETTA_MEDIUM", {font = "Trebuchet MS", size = 19, weight = 700, antialias = true, additive = false})
	surface.CreateFont("FRETTA_MEDIUM_SHADOW", {font = "Trebuchet MS", size = 19, weight = 700, antialias = true, additive = false, shadow = true})
	surface.CreateFont("FRETTA_HUGE", {font = "Trebuchet MS", size = 69, weight = 700, antialias = true, additive = false})
	surface.CreateFont("FRETTA_HUGE_SHADOW", {font = "Trebuchet MS", size = 69, weight = 700, antialias = true, additive = false, shadow = true})
	surface.CreateFont("FRETTA_LARGE", {font = "Trebuchet MS", size = 40, weight = 700, antialias = true, additive = false})
	surface.CreateFont("FRETTA_LARGE_SHADOW", {font = "Trebuchet MS", size = 40, weight = 700, antialias = true, additive = false, shadow = true})
	surface.CreateFont("FRETTA_SMALL", {font = "Trebuchet MS", size = 16, weight = 700, antialias = true, additive = false})
	surface.CreateFont("FRETTA_SMALL_SHADOW", {font = "Trebuchet MS", size = 16, weight = 700, antialias = true, additive = false, shadow = true})
end

function GM:CreateRapistMaterials()
	for _, rapist in pairs(self.Rapists) do
		local sprite = rapist.Sprite
		local rapesprite = rapist.SpriteRaping

		local matright = CreateMaterial(rapist.Name.."right", "UnlitGeneric", {["$basetexture"] = sprite, ["$translucent"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1, ["$nolod"] = 1, ["$nomip"] = 1, ["$basetexturetransform"] = "center .5 .5 scale 1 1 rotate 0 translate 0 0"})
		local matleft, matraperight, matrapeleft

		if rapist.FlipSprite then
			matleft = CreateMaterial(rapist.Name.."left", "UnlitGeneric", {["$basetexture"] = sprite, ["$translucent"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1, ["$nolod"] = 1, ["$nomip"] = 1, ["$basetexturetransform"] = "center .5 .5 scale -1 1 rotate 0 translate 0 0"})
		end

		if rapesprite then
			matraperight = CreateMaterial(rapist.Name.."raperight", "UnlitGeneric", {["$basetexture"] = rapesprite, ["$translucent"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1, ["$nolod"] = 1, ["$nomip"] = 1, ["$basetexturetransform"] = "center .5 .5 scale 1 1 rotate 0 translate 0 0"})

			if rapist.FlipRapeSprite then
				matrapeleft = CreateMaterial(rapist.Name.."rapeleft", "UnlitGeneric", {["$basetexture"] = rapesprite, ["$translucent"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1, ["$nolod"] = 1, ["$nomip"] = 1, ["$basetexturetransform"] = "center .5 .5 scale -1 1 rotate 0 translate 0 0"})
			end
		end

		if rapist.RapeMaterialOverride then
			matraperight = Material(rapist.RapeMaterialOverride)
			matrapeleft = matraperight
		end

		matleft = matleft or matright
		matraperight = matraperight or matright
		matrapeleft = matrapeleft or matleft

		rapist.MaterialRight = matright
		rapist.MaterialRightRape = matraperight
		rapist.MaterialLeft = matleft
		rapist.MaterialLeftRape = matrapeleft
	end
end

local LookBehindAngles = {
	[3] = Angle(0, -30, -30),
	[4] = Angle(0, 0, -30),
	[6] = Angle(0, 0, -80)
}
function GM:Think()
	self:MusicThink()

	local lbt = FrameTime() * 4
	local lp = LocalPlayer()
	for _, pl in pairs(player.GetAll()) do
		pl:SetIK(false)

		if pl:Alive() and pl:GetObserverMode() == OBS_MODE_NONE then
			if pl == lp then
				pl:ThinkSelf()
			else
				pl:CallStateFunction("ThinkOther")
			end

			local lookbehind = pl:GetDTBool(3)
			pl.LookBehind = math.Approach(pl.LookBehind or 0, lookbehind and 1 or 0, lbt)
			if pl.LookBehind == 0 then
				if pl.LookBehindScaled then
					pl.LookBehindScaled = false
					for boneid, scale in pairs(LookBehindAngles) do
						pl:ManipulateBoneAngles(boneid, angle_zero)
					end
				end
			else
				pl.LookBehindScaled = true
				for boneid, scale in pairs(LookBehindAngles) do
					pl:ManipulateBoneAngles(boneid, scale * pl.LookBehind)
				end
			end
		end
	end
end

function GM:ShouldDrawLocalPlayer(pl)
	return true
end

local EyeHullMins = Vector(-8, -8, -8)
local EyeHullMaxs = Vector(8, 8, 8)
--local lerpfov
local roll = 0
function GM:CalcView(pl, origin, angles, fov, znear, zfar)
	local targetroll = 0

	if pl:Alive() and pl:GetObserverMode() == OBS_MODE_NONE then
		if pl.LookBehind then
			angles:RotateAroundAxis(Vector(0, 0, 1), pl.LookBehind * -180)
		end

		-- 3rd person camera pos
		local camerapos = origin - angles:Forward() * 82

		--pl:CallCarryFunction("GetCameraPos", camerapos, origin, angles, fov, znear, zfar)
		pl:CallStateFunction("GetCameraPos", camerapos, origin, angles, fov, znear, zfar)

		local tr = util.TraceHull({start = origin, endpos = camerapos, mask = MASK_SOLID_BRUSHONLY, mins = EyeHullMins, maxs = EyeHullMaxs})
		origin = tr.Hit and tr.HitPos + (tr.HitPos - origin):GetNormalized() * 4 or tr.HitPos

		-- FOV scaling
		local vel = pl:GetVelocity()
		local speed = vel:Length()
		--fov = fov + fov * math.Clamp(math.abs(angles:Forward():Dot(vel:GetNormalized())) * ((speed - 100) / 250), 0, 1) * 0.15

		-- View rolling
		targetroll = targetroll + vel:GetNormalized():Dot(angles:Right()) * math_min(30, speed / 100)
	end

	roll = math.Approach(roll, targetroll, math_max(0.25, math.sqrt(math.abs(roll))) * 30 * FrameTime())
	angles.roll = angles.roll + roll
	--lerpfov = math.Approach(lerpfov or fov, fov, FrameTime() * 60)

	return self.BaseClass.CalcView(self, pl, origin, angles, fov --[[lerpfov]], znear, zfar)
end

function GM:TopNotify(...)
	if self.TopNotificationHUD and self.TopNotificationHUD:IsValid() then
		return self.TopNotificationHUD:AddNotification(...)
	end
end

function GM:_CreateMove(cmd)
	if LocalPlayer():IsPlayingTaunt() then
		cmd:ClearButtons(0)
		cmd:ClearMovement()
	end

	if GAMEMODE.RapeCameraTime and CurTime() < GAMEMODE.RapeCameraTime and LocalPlayer():GetObserverMode() == OBS_MODE_ROAMING then
		local ragdoll = LocalPlayer():GetRagdollEntity()
		if ragdoll and ragdoll:IsValid() then
			local pos = ragdoll:GetPos()
			local ang = (pos - EyePos()):Angle()
			ang.roll = 0

			cmd:ClearButtons(0)
			cmd:ClearMovement(0)
			cmd:SetViewAngles(ang)
			cmd:SetUpMove(48)
		end
	end
end

net.Receive("pb_pl_raped", function(length)
	local victim = net.ReadEntity()

	if victim:IsValid() then
		local victimname = victim:Name()

		if victim == LocalPlayer() then
			if victimteam == TEAM_HUMAN then
				gamemode.Call("LocalPlayerRaped")
			end
		end

		MsgC(team.GetColor(victim), victimname, color_white, " was caught!", "\n")

		GAMEMODE:TopNotify(victim, " was caught!")
	end
end)

net.Receive("pb_pl_died", function(length)
	local victim = net.ReadEntity()

	if victim:IsValid() then
		local victimname = victim:Name()

		if victim == LocalPlayer() then
			if victimteam == TEAM_HUMAN then
				gamemode.Call("LocalPlayerRaped")
			end
		end

		MsgC(team.GetColor(victim), victimname, color_white, " died!", "\n")

		GAMEMODE:TopNotify(victim, " died!")
	end
end)

net.Receive("pb_topnotify", function(length)
	local contents = net.ReadTable()

	GAMEMODE:TopNotify(unpack(contents))
end)
