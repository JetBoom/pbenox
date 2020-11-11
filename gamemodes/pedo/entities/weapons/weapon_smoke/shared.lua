if SERVER then
	AddCSLuaFile( "shared.lua" )
end
if CLIENT then
   SWEP.PrintName			= "Smoke Grenade"
   SWEP.Instructions		= ""
end
SWEP.Author				= "Douglas Huck"
SWEP.Contact				= "faceguydb@gmail.com"
SWEP.Base				= "weapon_banana"
SWEP.ViewModel			= "models/weapons/v_grenade.mdl"
SWEP.WorldModel			= "models/weapons/w_grenade.mdl"
function SWEP:GetObjectToMake()
	return "pbe2_smoke"
end