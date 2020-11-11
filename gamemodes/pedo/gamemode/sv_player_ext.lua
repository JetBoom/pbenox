local meta = FindMetaTable("Player")
if not meta then return end

function meta:EndState(nocallended)
	self:SetState(STATE_NONE, nil, nil, nocallended)
end

function meta:KnockDown(time, knocker)
	if not self:Alive() or self:InVehicle() or self:CallStateFunction("NoKnockDown") then return end

	time = time or 2
	self:SetState(STATE_KNOCKEDDOWN, time)

	if knocker and knocker:IsValid() and knocker:IsPlayer() then
		gamemode.Call("OnPlayerKnockedDownBy", self, knocker)
	end

	--[[local carry = self:GetCarrying()
	if carry:IsValid() and carry.Drop then
		carry:Drop()
	end]]
end

function meta:SetNormalSpeedTime(time)
	self.NormalTime = time
end

function meta:GetNormalSpeedTime()
	return self.NormalTime or CurTime() + 1
end

function meta:SetUncanTime(ent, time)
	self.CanEnt = ent
	self.UncanTime = time
end

function meta:GetUncanTime()
	return self.UncanTime or CurTime() + 1
end

function meta:GetUncanEnt()
	return self.CanEnt
end

function meta:GetCurrentItem()
	local wep = self:GetActiveWeapon()
	if wep and wep:IsValid() then
		local wepclass = wep:GetClass()

		for _, itemInfo in ipairs(GAMEMODE.ItemsList) do
			if itemInfo["swep"] == wepclass then
				return itemInfo
			end
		end
	end

	return false
end
