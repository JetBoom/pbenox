if SERVER then
	AddCSLuaFile( "shared.lua" )
end
if CLIENT then
   SWEP.PrintName			= "Trash Can"
   SWEP.Instructions		= ""
end
SWEP.Author				= "Douglas Huck"
SWEP.Contact				= "faceguydb@gmail.com"
SWEP.Base				= "weapon_banana"
SWEP.ViewModel			= "models/weapons/pbecustom/v_trashcan.mdl"
SWEP.WorldModel			= "models/weapons/pbecustom/w_trashcan.mdl"

function SWEP:Throw()
	if SERVER then
		ply = self.Owner
		if(ply:IsPlayer())then
			if(IsValid(ply:GetUncanEnt()))then
				ply:GetUncanEnt():Remove()
			end
			local ent = ents.Create("pbe2_trash")
			ent:SetPos(ply:GetPos()+Vector(0,0,20))
			ent:Spawn()
			constraint.NoCollide( ent, ply, 0, 0 );
			ply:Freeze()
			ply:SetUncanTime(ent, CurTime()+6)
			ply:Spectate( OBS_MODE_CHASE )
			ply.SpectatedEntity = ent
			ply:SpectateEntity(ent)
			sound.Play("vo/Citadel/br_laugh01.wav", ply:GetPos(), 100)
			ply:StripWeapons()
			self:Remove()
		end
	end
end