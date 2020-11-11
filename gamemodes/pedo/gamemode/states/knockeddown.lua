STATE.Time = 0.9

function STATE:Started(pl, oldstate)
	pl:Freeze(true)

	if SERVER then
		pl:EmitSound("npc/zombie/zombie_hit.wav", 75, math.random(125, 135))
	end
end

function STATE:Ended(pl, newstate)
	pl:Freeze(false)
end

function STATE:IsIdle(pl)
	return false
end

function STATE:Move(pl, move)
	move:SetSideSpeed(0)
	move:SetForwardSpeed(0)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)
end

function STATE:CalcMainActivity(pl, velocity)
	pl.CalcSeqOverride = pl:LookupSequence("zombie_slump_rise_02_fast")
end

function STATE:GetCycle(pl)
	return math.Clamp(1 - (pl:GetStateEnd() - CurTime()) / self.Time, 0, 1)
end

function STATE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:SetCycle(self:GetCycle(pl))
	pl:SetPlaybackRate(0)

	return true
end