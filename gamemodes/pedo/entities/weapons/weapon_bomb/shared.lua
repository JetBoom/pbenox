if SERVER then
	AddCSLuaFile( "shared.lua" )
end
if CLIENT then
   SWEP.PrintName			= "Time Bomb"
   SWEP.Instructions		= ""
end
SWEP.Author				= "Douglas Huck"
SWEP.Contact				= "faceguydb@gmail.com"
SWEP.Base				= "weapon_banana"
SWEP.ViewModel			= "models/weapons/pbecustom/v_helibomb.mdl"
SWEP.WorldModel			= "models/weapons/pbecustom/w_helibomb_fix.mdl"
SWEP.HoldReady = "grenade"
SWEP.HoldNormal = "grenade"

function SWEP:GetObjectToMake()
	return "pbe2_bomb"
end