local meta = FindMetaTable("Player")
if not meta then return end

local TEAM_RUNNER = TEAM_RUNNER
function meta:IsActive()
	return self:Team() == TEAM_RUNNER and self:Alive()
end

function meta:IsIdle()
	return self:CallStateFunction("IsIdle")
end

function meta:SetState(state, duration, ent, nocallended, force)
	local oldstate = self:GetState()
	if oldstate ~= state then
		if not force and self:CallForcedStateFunction(oldstate, "CantSwitchTo", state) then return end

		if not nocallended then
			self:CallForcedStateFunction(oldstate, "Ended", state)
		end
	end
	self:SetDTInt(0, state)
	self:SetStateStart(CurTime())
	if duration then
		self:SetStateEnd(CurTime() + duration)
	else
		self:SetStateEnd(0)
	end
	if ent then
		self:SetStateEntity(ent)
	else
		self:SetStateEntity(NULL)
	end

	if oldstate == state then
		self:CallForcedStateFunction(state, "Restarted")
	else
		self:CallForcedStateFunction(state, "Started", oldstate)
	end
end

function meta:SetStateForced(state, duration, ent, nocallended)
	self:SetState(state, duration, ent, nocallended, true)
end

function meta:GetState() return self:GetDTInt(0) end
function meta:GetStateTable() return STATES[self:GetState()] end
function meta:GetStateStart() return self:GetDTFloat(0) end
function meta:GetStateEnd() return self:GetDTFloat(1) end
function meta:GetStateNumber() return self:GetDTFloat(2) end
function meta:GetStateInteger() return self:GetDTInt(2) end
function meta:GetStateEntity() return self:GetDTEntity(0) end
function meta:GetStateVector() return self:GetDTVector(0) end
function meta:GetStateAngles() return self:GetDTAngle(0) end
function meta:GetStateBool() return self:GetDTBool(0) end
function meta:SetStateStart(time) self:SetDTFloat(0, time) end
function meta:SetStateEnd(time) self:SetDTFloat(1, time) end
function meta:SetStateNumber(num) self:SetDTFloat(2, num) end
function meta:SetStateInteger(int) self:SetDTInt(2, int) end
function meta:SetStateEntity(ent) self:SetDTEntity(0, ent) end
function meta:SetStateVector(vec) self:SetDTVector(0, vec) end
function meta:SetStateAngles(ang) self:SetDTAngle(0, ang) end
function meta:SetStateBool(bool) self:SetDTBool(0, bool) end

local STATES = STATES
function meta:CallStateFunction(name, ...)
	local statetab = STATES[self:GetState()]
	local func = statetab[name]
	if func then
		return func(statetab, self, ...)
	end
end

function meta:CallForcedStateFunction(state, name, ...)
	local statetab = STATES[state]
	local func = statetab[name]
	if func then
		return func(statetab, self, ...)
	end
end

function meta:ThinkSelf()
	if self:GetState() ~= STATE_NONE and self:GetStateEnd() > 0 and CurTime() >= self:GetStateEnd() and not self:CallStateFunction("GoToNextState") then
		self:EndState()
	end

	self:CallStateFunction("Think")
end

meta = FindMetaTable("NextBot")
if not meta then return end

function meta:IsActive()
	return false
end
meta.IsActivePlayer = meta.IsActive
meta.IsPlayer = meta.IsActive
