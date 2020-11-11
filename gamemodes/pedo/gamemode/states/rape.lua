function STATE:Started(pl, oldstate)
	pl:Freeze(true)

	if SERVER then
		pl:SetAge(pl:GetAge(), true)
	end
end

function STATE:Ended(pl, newstate)
	pl:Freeze(false)

	if SERVER then
		pl:SetAge(pl:GetAge())
	end
end

function STATE:IsIdle(pl)
	return false
end

function STATE:Move(pl, move)
	move:SetSideSpeed(0)
	move:SetForwardSpeed(0)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)
end

function STATE:CalcMainActivity(pl, velocity)
	pl.CalcSeqOverride = pl:LookupSequence("zombie_slump_rise_01")
end

function STATE:GetCycle(pl)
	return 0.45 + math.sin(CurTime() * 20 + pl:EntIndex()) * 0.025
end

function STATE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:SetCycle(self:GetCycle(pl))
	pl:SetPlaybackRate(0)

	return true
end

function STATE:NoKnockDown(pl)
	return true
end

if not CLIENT then return end

local LerpVector = LerpVector
local Lerp = Lerp
local CurTime = CurTime
local math_Clamp = math.Clamp
local LocalPlayer = LocalPlayer

function STATE:Think(pl)
	GAMEMODE.RapeCameraTime = CurTime() + 2.5
end

function STATE:GetCameraPos(pl, camerapos, origin, angles, fov, znear, zfar)
	local delta = math_Clamp((CurTime() - pl:GetStateStart()) * 1.5, 0, 1) ^ 1.8

	angles.yaw = angles.yaw + delta * 110
	angles.pitch = Lerp(delta, angles.pitch, 45)
	origin:Set(LerpVector(delta, origin, pl:GetPos() % 4))
	camerapos:Set(origin - angles:Forward() * Lerp(delta, 82, 128))
end
