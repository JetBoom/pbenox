if SERVER then
	AddCSLuaFile( "shared.lua" )
end
if CLIENT then
   SWEP.PrintName			= "Snow Ball"
   SWEP.Instructions		= ""
end
SWEP.Author				= "Douglas Huck"
SWEP.Contact				= "faceguydb@gmail.com"
SWEP.Base				= "weapon_banana"
SWEP.ViewModel			= "models/weapons/pbecustom/v_snowmanhead.mdl"
SWEP.WorldModel			= "models/weapons/pbecustom/w_snowmanhead_fix.mdl"
function SWEP:GetObjectToMake()
	return "pbe2_snow"
end