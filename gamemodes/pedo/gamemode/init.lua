AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_states.lua")
AddCSLuaFile("sh_gamecontroller.lua")
AddCSLuaFile("sh_entity_ext.lua")
AddCSLuaFile("obj_vector_extend.lua")
AddCSLuaFile("obj_entity_extend.lua")
AddCSLuaFile("obj_player_extend.lua")
AddCSLuaFile("obj_player_extend_cl.lua")
AddCSLuaFile("sh_animations.lua")

AddCSLuaFile("vgui/dexnotificationslist.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_audio.lua")
AddCSLuaFile("cl_round.lua")
AddCSLuaFile("cl_skin.lua")
AddCSLuaFile("cl_help.lua")
AddCSLuaFile("cl_options.lua")
AddCSLuaFile("cl_items.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_targetid.lua")

include("shared.lua")
include("sv_player_ext.lua")
include("sv_entity_ext.lua")
include("sv_rounds.lua")
include("mapeditor.lua")

CreateConVar("pbe2_bearsspawnrate", "16", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("pbe2_melonspawnrate", "5", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("pbe2_melonsmax", "8", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("pbe2_preptime", "10", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("pbe2_posttime", "10", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("pbe2_playerstostart", "2", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("pbe2_playerstowin", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("pbe2_rounds", "15", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("pbe2_timelimit", "240", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("pbe2_megarapetime", "180", FCVAR_ARCHIVE + FCVAR_NOTIFY)

cvars.AddChangeCallback("pbe2_timelimit", function(cvar, oldvalue, newvalue)
	if GAMEMODE:GetRoundState() == ROUND_PLAY then
		local num = tonumber(newvalue)
		if num then
			GAMEMODE:SetNextRoundStateTime(GAMEMODE:GetRoundStateChangedTime() + num)
		end
	end
end)

cvars.AddChangeCallback("pbe2_megarapetime", function(cvar, oldvalue, newvalue)
	if GAMEMODE:GetRoundState() == ROUND_PLAY then
		local num = tonumber(newvalue)
		if num then
			GAMEMODE.MegaRapeTime = GAMEMODE:GetRoundStateChangedTime() + num
		end
	end
end)

if file.Exists(GM.FolderName.."/gamemode/maps/"..game.GetMap()..".lua", "LUA") then
	include("maps/"..game.GetMap()..".lua")
end

local OBS_MODE_ROAMING = OBS_MODE_ROAMING
local OBS_MODE_NONE = OBS_MODE_NONE
local OBS_MODE_CHASE = OBS_MODE_CHASE

function GM:Initialize()
	self:AddResources()
	self:AddNetworkStrings()
	self:PrecacheResources()
end

function GM:PlayerInitialSpawn(pl)
	pl:Spectate(OBS_MODE_ROAMING)

	if pl:IsBot() then
		pl:SetTeam(TEAM_RUNNER)
	else
		pl:SetTeam(TEAM_UNASSIGNED)
	end
end

function GM:CanPlayerSuicide(pl)
	if self:GetRoundState() ~= ROUND_PLAY then
		return false
	end

	return self.BaseClass.CanPlayerSuicide(self, pl)
end

function GM:InitPostEntity()
	gamemode.Call("InitPostEntityMap")

	timer.Create("pbe2RoundStateCheck", self.CheckRate, 0, function() GAMEMODE:RoundCheck() end)
end

function GM:InitPostEntityMap()
	gamemode.Call("RemoveUnusedEntities")
	pcall(gamemode.Call, "LoadMapEditorFile")

	gamemode.Call("SetupSpawnPoints")
end

function GM:SetupSpawnPoints()
	team.SetSpawnPoint(TEAM_UNASSIGNED, "info_player_start")
	team.SetSpawnPoint(TEAM_SPECTATOR, "info_player_start")
	team.SetSpawnPoint(TEAM_RUNNER, "info_player_start")
end

function GM:AddResources()
	for _, itemInfo in ipairs(self.ItemsList) do
		resource.AddFile("materials/"..itemInfo["material"]..".vmt")
	end

	resource.AddFile("materials/pbe2/pedobearhdright.vmt")
	resource.AddFile("materials/pbe2/dailydose.vmt")
	resource.AddFile("materials/pbe2/dailydoseraper.vmt")
	resource.AddFile("materials/pbe2/jaredfogle.vtf")
	resource.AddFile("materials/pbe2/jaredfogleraper.vtf")
	resource.AddFile("materials/pbe2/ultros.vtf")

	resource.AddFile("models/weapons/pbecustom/v_babydoll.mdl")
	resource.AddFile("models/weapons/pbecustom/w_babydoll.mdl")

	resource.AddFile("models/weapons/pbecustom/v_glassbottle.mdl")
	resource.AddFile("models/weapons/pbecustom/w_glassbottle.mdl")

	resource.AddFile("models/weapons/v_banana.mdl")
	resource.AddFile("models/weapons/w_banana.mdl")
	resource.AddFile("materials/models/cs_italy/bananna.vmt")

	resource.AddFile("models/weapons/pbecustom/v_helibomb.mdl")
	resource.AddFile("models/weapons/pbecustom/w_helibomb_fix.mdl")

	resource.AddFile("models/weapons/pbecustom/snowmanface.mdl")
	resource.AddFile("models/weapons/pbecustom/v_snowmanhead.mdl")
	resource.AddFile("models/weapons/pbecustom/w_snowmanhead_fix.mdl")
	resource.AddFile("materials/models/pbecustom/snowmanb.vmt")
	resource.AddFile("materials/models/pbecustom/snowmanc.vmt")

	resource.AddFile("models/weapons/pbecustom/v_clockhand.mdl")
	resource.AddFile("models/weapons/pbecustom/w_clockhand.mdl")

	resource.AddFile("models/weapons/pbecustom/v_trashcan.mdl")
	resource.AddFile("models/weapons/pbecustom/w_trashcan.mdl")

	resource.AddFile("sound/pbe2/pedobear_amb1.ogg")
	resource.AddFile("sound/pbe2/pedobear_amb2.ogg")
	resource.AddFile("sound/pbe2/pedobear_amb3.ogg")
	resource.AddFile("sound/pbe2/pedobear_amb4.ogg")
end

function GM:AddNetworkStrings()
	util.AddNetworkString("pbe2_roundstatechange")
	util.AddNetworkString("pb_pl_raped")
	util.AddNetworkString("pb_pl_died")
	util.AddNetworkString("pb_topnotify")
end

function GM:TopNotify(...)
	net.Start("pb_topnotify")
		net.WriteTable({...})
	net.Broadcast()
end

function GM:Think()
	for _, pl in pairs(player.GetAll()) do
		if pl:Team() == TEAM_RUNNER then
			if CurTime() >= pl:GetNormalSpeedTime() then
				pl:SetWalkSpeed(self.RunSpeed)
				pl:SetRunSpeed(self.RunSpeed)

				pl:SetNormalSpeedTime(CurTime() + 99999)
			end

			if CurTime() >= pl:GetUncanTime() then
				pl:UnSpectate()

				if IsValid(pl:GetUncanEnt()) then
					local pos = pl:GetUncanEnt():GetPos()
					pl:GetUncanEnt():Remove()
					pl:Spawn()
					pl:SetPos(pos)
				else
					pl:Spawn()
				end

				pl:SetUncanTime(nil, CurTime() + 99999)
			end

			if pl:Alive() then
				if pl:WaterLevel() >= 2 and pl:GetObserverMode() == OBS_MODE_NONE then
					pl:Kill()
				else
					pl:ThinkSelf()
				end
			elseif pl:GetObserverMode() == OBS_MODE_NONE then
				pl:Spectate(OBS_MODE_ROAMING)
			end
		else
			if pl:Alive() then
				pl:KillSilent()
			end
			if pl:GetObserverMode() == OBS_MODE_NONE then
				pl:Spectate(OBS_MODE_ROAMING)
			end
		end
	end
end

function GM:PlayerDeathThink(pl)
	if self:GetRoundState() == ROUND_PREP and pl:Team() == TEAM_RUNNER then
		pl:UnSpectate()
		pl:Spawn()
	elseif pl.PreSpectateTarget then
		if pl.PreSpectateTarget:IsValid() then
			pl:Spectate(OBS_MODE_CHASE)
			pl:SpectateEntity(pl.PreSpectateTarget)
		end
		pl.PreSpectateTarget = nil
	elseif pl:KeyPressed(IN_ATTACK) then
		local targets = GAMEMODE:GetPlayingPlayers()
		if #targets > 0 then
			local target = table.Random(targets)
			if target:IsValid() then
				pl:Spectate(OBS_MODE_CHASE)
				pl:SpectateEntity(target)
			end
		end
	elseif pl:KeyPressed(IN_ATTACK2) then
		pl:Spectate(OBS_MODE_ROAMING)
	elseif pl:GetObserverMode() == OBS_MODE_CHASE then -- This block is to fix PVS issues on spectators
		local target = pl:GetObserverTarget()
		if target and target:IsValid() then
			pl:SetPos(target:GetPos() % 16)
		end
	end
end

function GM:DoPlayerDeath(pl, attacker, dmginfo)
	pl:Extinguish()
	pl:Freeze(false)
	pl:EndState()

	self.BaseClass.DoPlayerDeath(self, pl, attacker, dmginfo)
end

function GM:IsSpawnpointSuitable(pl, spawnpointent, bMakeSuitable)
	if pl:Team() == TEAM_UNASSIGNED or pl:Team() == TEAM_SPECTATOR or bMakeSuitable then return true end

	local Pos = spawnpointent:GetPos()

	local Ents = ents.FindInBox( Pos + Vector( -16, -16, 0 ), Pos + Vector( 16, 16, 64 ) )

	for k, v in pairs( Ents ) do
		if IsValid(v) and v ~= pl and v:GetClass() == "player" and v:Alive() then
			return false
		end
	end

	return true
end

function GM:PlayerSpawn(pl)
	pl:StripWeapons()
	pl:Freeze(false)
	pl:EndState()

	if pl:GetMaterial() ~= "" then
		pl:SetMaterial("")
	end

	pl.SpawnNoSuicide = CurTime() + 1
	pl.SpawnedTime = CurTime()

	pl:ShouldDropWeapon(false)

	local desiredname = pl:GetInfo("cl_playermodel")
	local modelname = player_manager.TranslatePlayerModel(#desiredname == 0 and "kleiner" or desiredname)
	pl:SetModel(modelname)

	if pl:Team() == TEAM_RUNNER then
		pl:UnSpectate()

		pl:SetAge(12)
		pl:SetJumpPower(self.JumpPower)
		pl:SetWalkSpeed(self.RunSpeed)
		pl:SetRunSpeed(self.RunSpeed)
		pl:SetCrouchedWalkSpeed(0.65)
		pl:SetNoCollideWithTeammates(true)
		pl:SetAvoidPlayers(true)

		local pcol = Vector(pl:GetInfo("cl_playercolor"))
		pcol.x = math.Clamp(pcol.x, 0, 2.5)
		pcol.y = math.Clamp(pcol.y, 0, 2.5)
		pcol.z = math.Clamp(pcol.z, 0, 2.5)
		pl:SetPlayerColor(pcol)

		local wcol = Vector(pl:GetInfo("cl_weaponcolor"))
		wcol.x = math.Clamp(wcol.x, 0, 2.5)
		wcol.y = math.Clamp(wcol.y, 0, 2.5)
		wcol.z = math.Clamp(wcol.z, 0, 2.5)
		pl:SetWeaponColor(wcol)

		pl:SetNormalSpeedTime(CurTime() + 99999)
		pl:SetUncanTime(nil, CurTime() + 99999)
	else
		if pl:Alive() then
			pl:KillSilent()
		end
		self:PlayerSpawnAsSpectator(pl)
		pl:Spectate(OBS_MODE_ROAMING)
	end
end

function GM:OnPlayerChangedTeam(pl, oldteam, newteam)
	if newteam == TEAM_SPECTATOR then
		local pos = pl:EyePos()
		pl:Spawn()
		pl:SetPos(pos)
	elseif oldteam == TEAM_SPECTATOR then
		if self:GetRoundState() == ROUND_PREP then
			pl:Spawn()
		end
	end

	PrintMessage(HUD_PRINTTALK, Format("%s joined '%s'", pl:Name(), team.GetName(newteam)))
end

function GM:ShowTeam(pl)
	pl:SendLua("GAMEMODE:ShowTeam()")
end

function GM:ShowHelp(pl)
	pl:SendLua("GAMEMODE:ShowHelp()")
end

function GM:CheckBears()
	if #ents.FindByClass("pedobear") < math.min(28, (CurTime() - self:GetRoundStateChangedTime()) / GetConVar("pbe2_bearsspawnrate"):GetFloat()) then
		self:SpawnBear()
	end
end

function GM:SpawnBear()
	local pos = GAMEMODE:GetBearSpawnPoint()
	local ent = ents.Create("pedobear")
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:Spawn()
		if self.MegaRape then
			ent:SetColor(Color(255, 0, 0))
		end
	end
end

function GM:LoadNextMap()
	game.LoadNextMap()
end

function GM:GetBearSpawnPoint()
	local spawns = ents.FindByClass("pb_spawn")
	if #spawns == 0 then
		spawns = ents.FindByClass("info_player_start")
	end

	if #spawns > 0 then
		local spawn = table.Random(spawns)
		if spawn and spawn:IsValid() then
			local pos = spawn:GetPos()
			pos.z = pos.z + 12

			return pos
		end
	end

	return vector_origin
end

function util.RemoveAll(class)
	for _, ent in pairs(ents.FindByClass(class)) do
		if ent:IsValid() then
			ent:Remove()
		end
	end
end

function GM:RemoveUnusedEntities()
	util.RemoveAll("prop_ragdoll")
	util.RemoveAll("npc_*")
	util.RemoveAll("item_*")
	util.RemoveAll("weapon_*")
end

local lastMelonSpawned = 0
function GM:CheckMelons()
	if CurTime() > lastMelonSpawned + GetConVar("pbe2_melonspawnrate"):GetFloat() and #ents.FindByClass("melon") < GetConVar("pbe2_melonsmax"):GetInt() then
		lastMelonSpawned = CurTime()
		GAMEMODE:SpawnMelon()
	end
end

function GM:SpawnMelon(pos)
	pos = pos or self:GetMelonSpawnPoint()
	if pos then
		local ent = ents.Create("melon")
		if ent:IsValid() then
			ent:SetPos(pos)
			ent:Spawn()
		end
	end
end

function GM:GetMelonSpawnPoint()
	local spawns = ents.FindByClass("pb_powerup")
	if #spawns == 0 then
		spawns = ents.FindByClass("info_player_*")
	end
	if #spawns > 0 then
		local spawn = table.Random(spawns)
		if spawn and spawn:IsValid() then
			local pos = spawn:GetPos()
			pos.z = pos.z + 12

			return pos
		end
	end
end

concommand.Add("createnavmesh", function(sender, command, arguments)
	if sender:IsSuperAdmin() and not game.IsDedicated() then
		if sender:GetObserverMode() == OBS_MODE_NONE and sender:IsOnGround() and sender:OnGround() then
			for _, ent in pairs(ents.FindByClass("func_door*")) do
				ent:Fire("open", "", 0)
			end
			for _, ent in pairs(ents.FindByClass("prop_door*")) do
				ent:Fire("open", "", 0)
			end
			local ent = ents.Create("info_player_start")
			if ent:IsValid() then
				ent:SetPos(sender:GetPos())
				ent:Spawn()
				timer.Simple(2, function() navmesh.BeginGeneration() end)
			end
		else
			print("You must be firmly planted on the ground.")
		end
	end
end)
