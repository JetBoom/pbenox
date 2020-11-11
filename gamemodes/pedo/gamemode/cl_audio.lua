local basedir = "http://heavy.noxiousnet.com/music/"
local function ms(m, s) return m * 60 + s end

GM.BackgroundMusic = {
	{
		"Foozogz",
		"Party Rabbit",
		"foozogz-party_rabbit.ogg",
		288
	},
	{
		"Foozogz",
		"Enveloped",
		"foozogz-enveloped.ogg",
		205
	},
	{
		"Foozogz",
		"Pinkie Loves Sugar VIP",
		"foozogz-pinkie_loves_sugar_vip.ogg",
		217
	},
	{
		"Foozogz",
		"A Sunny Day",
		"foozogz-a_sunny_day.ogg",
		208
	},
	{
		"Foozogz",
		"Dream Chaser",
		"foozogz-dream_chaser.ogg",
		222
	},
	{
		"Foozogz",
		"Pinkie's Videogame BGM",
		"foozogz-pinkies_video_game_bgm.ogg",
		240
	},
	{
		"Foozogz",
		"Fluttershy Likes Being Nice",
		"foozogz-fluttershy_likes_being_nice.ogg",
		ms(3, 56)
	},
	{
		"Foozogz",
		"Feeling Whimsical",
		"foozogz-feeling_whimsical.ogg",
		ms(2, 54)
	},
	{
		"Foozogz",
		"Stratacoaster",
		"foozogz-stratacoaster.ogg",
		ms(3, 54)
	},
	{
		"Starship Amazing",
		"A Full-Length Docudrama Based On The Making Of The Movie Space Jam",
		"starship_amazing-a_full-length_docudrama_based_on_the_making_of_the_movie_space_jam.ogg",
		ms(5, 16)
	},
	{
		"Level 99",
		"Ecco: The Tides of Time 'Waves of Stone'",
		"level99-waves_of_stone.ogg",
		ms(3, 54)
	},
	{
		"GARticuno",
		"Ore no Barklimouto",
		"garticuno-ore_no_barklimouto.ogg",
		ms(4, 13)
	},
	{
		"_ensnare_",
		"Excerpt from Live Mix Jan 2012",
		"_ensnare_-excerpt_from_live_mix_jan_2012.ogg",
		ms(2, 53)
	},
	{
		"Foozogz",
		"Of Fond Memories",
		"foozogz-of_fond_memories.ogg",
		ms(3, 23)
	},
	{
		"Foozogz",
		"Sweetheart",
		"foozogz-sweetheart.ogg",
		ms(3, 48)
	},
	{
		"Foozogz",
		"Space Invaders",
		"foozogz-space_invaders.ogg",
		ms(4, 07)
	},
	{
		"Planetboom",
		"SuperSonic",
		"planetboom-supersonic.ogg",
		ms(3, 15)
	},
	{
		"Warrior's Orochi",
		"Theme of Lu Bu",
		"warriors_orochi-theme_of_lu_bu.ogg",
		ms(2, 15)
	},
	{
		"Nutritious",
		"Trial by Fire",
		"nutritious-trial_by_fire.ogg",
		ms(4, 00)
	}
}

AccessorFunc(GM, "CurrentTrack", "CurrentTrack", FORCE_STRING)

local Music
local MusicChannel

local CVarVolume = CreateClientConVar("pbe2_volume", "25", true, false)
cvars.AddChangeCallback("pbe2_volume", function(cvar, oldvalue, newvalue)
	oldvalue = tonumber(oldvalue) or 0
	newvalue = tonumber(newvalue) or 0

	GAMEMODE.MusicVolume = math.Clamp(math.ceil(newvalue) / 100, 0, 1)
	GAMEMODE:MusicVolumeChanged(oldvalue)
end)

function GM:MusicVolumeChanged(oldvalue)
	if self.MusicVolume == 0 then
		self:StopMusic()
	else
		if self.MusicVolume > 0 and oldvalue <= 0 then
			self:PlayMusic()
		end
		if MusicChannel then
			MusicChannel:SetVolume(self.MusicVolume)
		end
	end
end

local NextMusic
function GM:MusicThink()
	if self.MusicVolume == nil then
		self.MusicVolume = math.Clamp(math.ceil(CVarVolume:GetInt()) / 100, 0, 1)
		self:MusicVolumeChanged(0)
	elseif NextMusic and RealTime() >= NextMusic then
		self:PlayMusic()
	end
end

function GM:PlayMusic(trackid)
	if self.MusicVolume <= 0 then return end

	local track = self.BackgroundMusic[trackid]

	if not track then
		local currenttrack = self:GetCurrentTrack()
		local notplaying = {}
		for k, v in pairs(self.BackgroundMusic) do
			if v[1] ~= currenttrack then
				table.insert(notplaying, v)
			end
		end

		math.randomseed(CurTime())
		track = table.Random(notplaying)
	end

	self:StopMusic()

	self:PlayMusicUrl(basedir..track[3])
	self:SetCurrentTrack(track[1])

	NextMusic = RealTime() + track[4]
end

function GM:PlayMusicUrl(url)
	Music = sound.PlayURL(url, "noblock", function(channel)
		if channel then
			MusicChannel = channel
			channel:SetVolume(self.MusicVolume)
		end
	end)
end

function GM:StopMusic()
	if MusicChannel then
		MusicChannel:Stop()
		MusicChannel = nil
	end

	NextMusic = 0
end
