ENT.Type = "nextbot"
ENT.Base = "base_nextbot"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.IsRapist = true

AccessorFuncDT(ENT, "RapistType", "Int", 0)
AccessorFuncDT(ENT, "RapeVictim", "Entity", 0)

function ENT:GetRaping()
	return self:GetRapeVictim():IsValid()
end
ENT.IsRaping = ENT.GetRaping

function ENT:GetRapist()
	local id = self:GetRapistType()
	return GAMEMODE.Rapists[id] or GAMEMODE.Rapists[1]
end

function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() or ent == self.Trigger
end
