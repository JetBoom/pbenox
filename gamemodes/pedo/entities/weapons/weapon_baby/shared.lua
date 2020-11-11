if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
   SWEP.PrintName			= "Baby Doll"
   SWEP.Instructions		= ""
end

SWEP.Author				= "Douglas Huck"
SWEP.Contact				= "faceguydb@gmail.com"
SWEP.Base				= "weapon_banana"
SWEP.ViewModel			= "models/weapons/pbecustom/v_babydoll.mdl"
SWEP.WorldModel			= "models/weapons/pbecustom/w_babydoll.mdl"

function SWEP:GetObjectToMake()
	return "pbe2_baby"
end
