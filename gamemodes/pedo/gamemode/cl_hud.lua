color_black_alpha180 = Color(0, 0, 0, 180)

local DontDraw = {["CHudHealth"] = true, ["CHudBattery"] = true, ["CHudAmmo"] = true, ["CHudSecondaryAmmo"] = true, ["CHudCrosshair"] = true, ["CHudWeaponSelection"] = true}
function GM:HUDShouldDraw(name)
	return not DontDraw[name]
end

local RoundsMovement = 0
local RoundLast = ROUND_WAIT
local RoundBarWidth = 0
local RoundSendingBack = false
function GM:DrawRounds()
	if self:GetRoundState() ~= RoundLast then
		RoundSendingBack = true
	end

	if RoundSendingBack then
		RoundsMovement = RoundsMovement + 2
		if RoundsMovement > math.max( surface.GetTextSize(ROUNDS[RoundLast]), surface.GetTextSize(ROUNDS[self:GetRoundState()]) ) then
			RoundLast = self:GetRoundState()
			RoundSendingBack = false
		end
	elseif RoundsMovement > 0 then
		RoundsMovement = RoundsMovement - 2
	end

	RoundBarWidth = surface.GetTextSize(ROUNDS[RoundLast])
	draw.RoundedBox(8, -8 - RoundsMovement, 280, RoundBarWidth + 16, 38, color_black_alpha180)
	surface.SetTextPos(4 - RoundsMovement, 276)
	surface.DrawText(ROUNDS[RoundLast])
end

local ItemsMovement = 0
local LastItem = ""
local LastItemMaterial = Material("pbe2/bananaicon")
local LastItemWidth = 0
function GM:DrawItems()
	local lp = LocalPlayer()
	if not lp:Alive() then return end

	local item = lp:GetCurrentItem()
	if item then
		if LastItem ~= item then
			LastItem = item["name"]
			LastItemMaterial = Material(item["material"])
			LastItemWidth = surface.GetTextSize(LastItem)
		end

		if ItemsMovement > 0 then
			ItemsMovement = ItemsMovement - 3
		end
	elseif ItemsMovement < 160 then
		ItemsMovement = ItemsMovement + 3
	end

	if ItemsMovement < 160 then
		draw.RoundedBox(8, -8, -8 - ItemsMovement, 144, 144, color_black_alpha180)
		draw.RoundedBoxEx(8, 136, 0 - ItemsMovement, LastItemWidth + 16, 38, color_black_alpha180, false, false, false, true)

		surface.SetTextPos( 140, -4 - ItemsMovement)
		surface.DrawText(LastItem)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(LastItemMaterial)
		surface.DrawTexturedRect(0, -ItemsMovement, 128, 128)
	end
end

function MakeTime(time)
	local seconds = math.floor(time % 60)
	if seconds < 10 then
		seconds = "0"..seconds
	end

	return math.floor(time / 60)..":"..seconds
end

function GM:DrawTimer(w, h)
	local nextroundtime = self:GetNextRoundStateTime()
	if nextroundtime > 0 then
		local TimeStr = MakeTime(math.max(0, nextroundtime - CurTime()))

		surface.SetFont("FRETTA_HUGE")
		local TimerWidth = surface.GetTextSize(TimeStr)

		draw.RoundedBox(8, w / 2 - TimerWidth / 2 - 4, -8, TimerWidth + 8, 64, color_black_alpha180)
		surface.SetTextPos(w / 2 - TimerWidth / 2, -6)
		surface.DrawText(TimeStr)
	end
end

function GM:DrawWinner(w, h)
	local str = self:GetEndMessage()
	if #str > 0 then
		surface.SetFont("FRETTA_LARGE_SHADOW")
		surface.SetTextPos(w / 2 - surface.GetTextSize(str) / 2, h / 2 - 45)
		surface.DrawText(str)
	end
end

function GM:HUDPaint()
	local w, h = ScrW(), ScrH()

	--self:DrawPlayerNames()
	self:HUDDrawTargetID()

	surface.SetFont("FRETTA_LARGE")
	surface.SetTextColor(255, 255, 255, 255)
	self:DrawRounds()
	self:DrawItems()
	self:DrawTimer(w, h)
	if self:GetRoundState() == ROUND_POST then
		self:DrawWinner(w, h)
	end
end

--[[function GM:DrawPlayerNames()
	surface.SetTextColor(0, 255, 0, 255)
	surface.SetFont("FRETTA_SMALL_SHADOW")

	local lp = LocalPlayer()
	local name
	local targetPos
	local targetScreenpos
	local w

	for _, target in pairs(player.GetAll()) do
		if target ~= lp and target:IsActivePlayer() then
			name = target:Name()
			targetPos = target:GetPos()
			targetScreenpos = targetPos:ToScreen()
			w = surface.GetTextSize(name)

			surface.SetTextPos(targetScreenpos.x - w / 2, targetScreenpos.y)
			surface.DrawText(target:Nick())
		end
	end
end]]
