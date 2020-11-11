local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local EyePos = EyePos
local EyeAngles = EyeAngles

local trace = {mask = MASK_SHOT, mins = Vector(-2, -2, -2), maxs = Vector(2, 2, 2), filter = {}}
local entitylist = {}

local colTemp = Color(10, 255, 10)
function GM:DrawTargetID(ent, fade)
	fade = fade or 1
	local ts = ent:GetPos():ToScreen()
	local x, y = ts.x, math.Clamp(ts.y, 0, ScrH() * 0.95)

	colTemp.a = fade * 255

	draw.SimpleText(ent:Name(), "FRETTA_MEDIUM_SHADOW", x, y, colTemp, TEXT_ALIGN_CENTER)
end

function GM:HUDDrawTargetID()
	local MySelf = LocalPlayer()

	local start = EyePos()
	trace.start = start
	trace.endpos = start + EyeVector() * 2048
	trace.filter[1] = MySelf
	trace.filter[2] = MySelf:GetObserverTarget()

	local isspectator = MySelf:GetObserverMode() ~= OBS_MODE_NONE
	if isspectator then
		local t = MySelf:GetObserverTarget()
		if t and t:IsValid() and t:IsPlayer() then
			entitylist[t] = CurTime()
		end
	end

	local entity = util.TraceHull(trace).Entity
	if entity:IsValid() and entity:IsPlayer() then
		entitylist[entity] = CurTime()
	end

	for ent, time in pairs(entitylist) do
		if ent:IsValid() and ent:IsPlayer() and (isspectator or CurTime() < time + 2) then
			self:DrawTargetID(ent, 1 - math.Clamp((CurTime() - time) / 2, 0, 1))
		else
			entitylist[ent] = nil
		end
	end
end
