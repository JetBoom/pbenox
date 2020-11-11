function GM:RoundCheck()
	local roundstate = self:GetRoundState()

	if roundstate == ROUND_WAIT then
		if --[[CurTime() >= self:GetNextRoundStateTime() and]] table.Count(self:GetReadyPlayers()) >= GetConVar("pbe2_playerstostart"):GetInt() then
			game.CleanUpMap(true)
			gamemode.Call("InitPostEntityMap")

			for k, pl in pairs(team.GetPlayers(TEAM_RUNNER)) do
				pl:EndState()
				pl:Freeze(false)
				pl:KillSilent()
				--print(pl:Nick())
			end

			self:SetRoundState(ROUND_PREP)
			self:SetNextRoundStateTime(CurTime() + GetConVar("pbe2_preptime"):GetFloat())
			self:SetRound(self:GetRound() + 1)

			self:TopNotify("Starting round "..self:GetRound().." / "..GetConVar("pbe2_rounds"):GetInt())
		end
	elseif roundstate == ROUND_PREP then
		if CurTime() >= self:GetNextRoundStateTime() then
			self:SetRoundState(ROUND_PLAY)
			self:SetNextRoundStateTime(CurTime() + GetConVar("pbe2_timelimit"):GetFloat())
			self.MegaRapeTime = CurTime() + GetConVar("pbe2_megarapetime"):GetFloat()
		end
	elseif roundstate == ROUND_PLAY then
		self:CheckBears()
		self:CheckMelons()

		local playing = self:GetPlayingPlayers()
		local numplaying = #playing

		if not self.MegaRape and CurTime() >= self.MegaRapeTime then
			self.MegaRape = true
			local colred = Color(255, 0, 0)
			for _, ent in pairs(ents.FindByClass("pedobear")) do
				ent:SetColor(colred)
			end
		elseif CurTime() >= self:GetNextRoundStateTime() or numplaying <= GetConVar("pbe2_playerstowin"):GetInt() then
			if numplaying > 1 then
				for _, pl in pairs(playing) do
					pl:AddFrags(1)
				end
				self:SetEndMessage("Survivors: "..numplaying)
			elseif numplaying == 1 then
				local pl = playing[1]
				pl:AddFrags(1)
				self:SetEndMessage(pl:Name().." survived!")
				self:TopNotify(pl, " survived!")
			else
				self:SetEndMessage("No one managed to survive!")
			end

			self:SetRoundState(ROUND_POST)
			self:SetNextRoundStateTime(CurTime() + GetConVar("pbe2_posttime"):GetFloat())
			self.MegaRape = false
			for _, ent in pairs(ents.FindByClass("pedobear")) do
				ent:SetColor(color_white)
			end

			gamemode.Call("RoundEnded")
		end
	elseif roundstate == ROUND_POST then
		if CurTime() >= self:GetNextRoundStateTime() then
			if self:GetRound() >= GetConVar("pbe2_rounds"):GetInt() then
				gamemode.Call("LoadNextMap")
			else
				self:SetRoundState(ROUND_WAIT)
			end
		end
	end
end
