ROUND_WAIT = 1
ROUND_PREP = 2
ROUND_PLAY = 3
ROUND_POST = 4

ROUNDS = {
	[ROUND_WAIT] = "Waiting for players...",
	[ROUND_PREP] = "Prepare to run!",
	[ROUND_PLAY] = "Run!!",
	[ROUND_POST] = "Round Over..."
}

function GM:SetRound(round)
	SetGlobalInt("round", round)
end

function GM:GetRound()
	return GetGlobalInt("round", 0)
end

function GM:SetRoundState(state)
	if state ~= self:GetRoundState() then
		SetGlobalInt("roundstate", state)

		if SERVER then
			self:SetRoundStateChangedTime(CurTime())

			net.Start("pbe2_roundstatechange")
				net.WriteUInt(state, 4)
			net.Broadcast()
		end
	end
end

function GM:GetRoundState()
	return GetGlobalInt("roundstate", ROUND_WAIT)
end

function GM:SetNextRoundStateTime(time)
	SetGlobalFloat("roundtime", time)
end

function GM:GetNextRoundStateTime()
	return GetGlobalFloat("roundtime", -1)
end

function GM:SetRoundStateChangedTime(time)
	SetGlobalFloat("roundchangedtime", time)
end

function GM:GetRoundStateChangedTime()
	return GetGlobalFloat("roundchangedtime", 0)
end

function GM:SetEndMessage(msg)
	SetGlobalString("endmessage", msg)
end

function GM:GetEndMessage()
	return GetGlobalFloat("endmessage", "")
end
