if SERVER then
	AddCSLuaFile( "shared.lua" )
end
if CLIENT then
   SWEP.PrintName			= "Time Warp"
   SWEP.Instructions		= ""
end
SWEP.Author				= "Douglas Huck"
SWEP.Contact				= "faceguydb@gmail.com"
SWEP.Base				= "weapon_banana"
SWEP.ViewModel			= "models/weapons/pbecustom/v_clockhand.mdl"
SWEP.WorldModel			= "models/weapons/pbecustom/w_clockhand.mdl"

function SWEP:Throw()
	if SERVER then
		ply = self.Owner
		if(ply:IsPlayer())then
			if(IsValid(ply:GetUncanEnt()))then
				ply:GetUncanEnt():Remove()
			end
			//GAMEMODE:SetTimeScale(3,0.2)
			self:Remove()
		end
	end
end