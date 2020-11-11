if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName			= "Speed Boost"
SWEP.Base				= "weapon_banana"

SWEP.ViewModel			= "models/weapons/pbecustom/v_glassbottle.mdl"
SWEP.WorldModel			= "models/weapons/pbecustom/w_glassbottle.mdl"

function SWEP:Throw()
	if SERVER then
		owner = self.Owner
		owner:SetRunSpeed(GAMEMODE.RunSpeed * 2)
		owner:SetWalkSpeed(GAMEMODE.RunSpeed * 2)
		owner:SetNormalSpeedTime(CurTime() + 4)
		sound.Play("npc/vort/claw_swing2.wav", owner:GetPos(), 100)

		owner:StripWeapons()
	end
end