GM.Name = "Pedobear Escape 2"
GM.Author = "Douglas Huck"
GM.Email = "faceguydb@gmail.com"
GM.Website = "http://douglashuck.com"
GM.Skype = "faceguydb"

GM.RoundStartSounds = {
	Sound("vo/npc/male01/runforyourlife01.wav"),
	Sound("vo/npc/male01/runforyourlife02.wav"),
	Sound("vo/npc/male01/runforyourlife03.wav")
}

GM.RunSpeed = 320
GM.JumpPower = 0

GM.TeamBased = true
GM.CheckRate = 0.5 --How often we check for a round state change 0.1-1 Recommended

TEAM_RUNNER = 1

include("obj_entity_extend.lua")
include("sh_states.lua")
include("sh_gamecontroller.lua")
include("sh_entity_ext.lua")
include("obj_vector_extend.lua")
include("obj_player_extend.lua")
include("sh_animations.lua")

local bit_band = bit.band
local IN_DUCK = IN_DUCK
local IN_JUMP = IN_JUMP

function GM:CreateTeams()
	team.SetUp(TEAM_RUNNER, "Runners", Color(20, 255, 20))
	team.SetSpawnPoint(TEAM_RUNNER, "info_player_start")
	team.SetSpawnPoint(TEAM_SPECTATOR, "worldspawn")
end

function GM:PrecacheResources()
	util.PrecacheSound("physics/body/body_medium_break2.wav")
	util.PrecacheSound("physics/body/body_medium_break3.wav")
	util.PrecacheSound("physics/body/body_medium_break4.wav")
	for name, mdl in pairs(player_manager.AllValidModels()) do
		util.PrecacheModel(mdl)
	end
end

function GM:ShouldCollide(enta, entb)
	if enta.ShouldNotCollide and enta:ShouldNotCollide(entb) or entb.ShouldNotCollide and entb:ShouldNotCollide(enta) then
		return false
	end

	return true
end

function GM:GetFallDamage(pl, fallspeed)
	return ( fallspeed - 526.5 ) * ( 100 / 396 ) -- the Source SDK value
end

function GM:GetReadyPlayers()
	return team.GetPlayers(TEAM_RUNNER)
end

function GM:GetPlayingPlayers()
	local players = {}

	for _, pl in pairs(player.GetAll()) do
		if pl:IsActivePlayer() then
			table.insert(players, pl)
		end
	end

	return players
end

function GM:PlayerCanJoinTeam(pl, teamid)
	if pl:Team() == teamid then
		return false
	end

	--[[if self:GetRoundState() ~= ROUND_PLAY and self:GetRoundState() ~= ROUND_POST then
		pl:UnSpectate()
	end]]

	return true
end

function GM:AllowPlayerPickup(pl, ent)
	return false
end

function GM:PlayerNoClip(pl, on)
	if pl:IsAdmin() then
		if SERVER then
			PrintMessage(HUD_PRINTCONSOLE, pl:Name().." turned noclip "..(on and "on" or "off"))
		end

		return true
	end

	return false
end

function GM:SetupMove(pl, mv, cmd)
	if pl:Alive() then
		local buttons = mv:GetButtons()
		if bit_band(buttons, IN_DUCK) ~= 0 then
			mv:SetButtons(buttons - IN_DUCK)
		end
		if bit_band(buttons, IN_JUMP) ~= 0 then
			mv:SetButtons(mv:GetButtons() - IN_JUMP)
		end
	end
end

function GM:PlayerShouldTaunt(pl, actid)
	return pl:IsActive() and not pl:IsPlayingTaunt()
end

local KEY_RELOAD = KEY_RELOAD
function GM:KeyPress(pl, key)
	if key == IN_RELOAD then
		pl:SetDTBool(3, true)
	end
end

function GM:KeyRelease(pl, key)
	if key == IN_RELOAD and pl:GetDTBool(3) then
		pl:SetDTBool(3, false)
	end
end

GM.Rapists = {
	{
		Name = "Pedobear",
		Sprite = "pbe2/pedobearhdright",
		SpriteRaping = "pbe2/pedobearhdright",
		FlipSprite = true,
		FlipRapeSprite = true
	},
	{
		Name = "Piccolo",
		Sprite = "pbe2/dailydose",
		SpriteRaping = "pbe2/dailydoseraper",
		RapeMaterialOverride = "pbe2/dailydoseraper",
		FlipSprite = true,
		FlipRapeSprite = false
	},
	{
		Name = "Jared Fogle",
		Sprite = "pbe2/jaredfogle",
		SpriteRaping = "pbe2/jaredfogleraper",
		FlipSprite = true,
		FlipRapeSprite = true,
		SpriteRapingYScale = 1,
		SpriteYOffset = 64
	},
	{
		Name = "Ultros",
		Sprite = "pbe2/ultros",
		SpriteRaping = "pbe2/ultros",
		FlipSprite = true,
		FlipRapeSprite = true,
		SpriteYScale = 1,
		SpriteRapingYScale = 1
	}
}

GM.ItemsList = {
	{
		name="Beer Bottle",
		material="pbe2/bottleicon",
		swep="weapon_soda",
		desc="Gives you super speed because Alcohol."
	},{
		name="Banana Peel",
		material="pbe2/bananaicon",
		swep="weapon_banana",
		desc="Spins a players screen around."
	},{
		name="Smoke Grenade",
		material="pbe2/smokeicon",
		swep="weapon_smoke",
		desc="Make it hard to see."
	},{
		name="Trash Can",
		material="pbe2/trashicon",
		swep="weapon_trash",
		desc="Hide in a trash can that pedobear can't see in."
	},{
		name="Snow Ball",
		material="pbe2/snowicon",
		swep="weapon_snow",
		desc="Slow another player for a short time."
	},{
		name="Time Bomb",
		material="pbe2/bombicon",
		swep="weapon_bomb",
		desc="Blow everyone away."
	},{
		name="Baby Doll",
		material="pbe2/babyicon",
		swep="weapon_baby",
		desc="Pedobear is attracted to the mechanical doll."
	}
}

function GM:GetItemsList()
	return GAMEMODE.ItemsList
end

-- You need to run this on the client and server.
function GM:AddItem(item)
	table.insert(GAMEMODE.ItemsList, item)

	return item
end

function AccessorFuncDT(tab, membername, type, id)
	local emeta = FindMetaTable("Entity")
	local setter = emeta["SetDT"..type]
	local getter = emeta["GetDT"..type]

	tab["Set"..membername] = function(me, val)
		setter(me, id, val)
	end

	tab["Get"..membername] = function(me)
		return getter(me, id)
	end
end
