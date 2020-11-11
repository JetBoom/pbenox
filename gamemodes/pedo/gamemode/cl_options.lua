local TeamPanel

local PANEL = {}

PANEL.OpenTime = 0

function PANEL:Init()
	local label

	--[[label = vgui.Create("DLabel", self)
	label:SetContentAlignment(8)
	label:SetFont("FRETTA_HUGE")
	label:SetTextColor(color_white)
	label:SetText("Customize")
	label:SizeToContents()
	label:Dock(TOP)
	label:DockMargin(0, 16, 0, 32)]]

	label = vgui.Create("DLabel", self)
	label:SetContentAlignment(8)
	label:SetFont("FRETTA_LARGE")
	label:SetTextColor(color_white)
	label:SetText("Pump up (or down) the volume")
	label:SizeToContents()
	label:Dock(TOP)
	label:DockMargin(0, 16, 0, 0)

	local slidebox = vgui.Create("Panel", self)
	--slidebox:SetBackgroundColor(Color(255, 255, 255, 120))
	slidebox:Dock(TOP)
	slidebox:SetTall(48)
	slidebox:DockMargin(0, 8, 0, 0)
	slidebox.PerformLayout = function(me)
		me.Slider:SetTall(me:GetTall())
		me.Slider:Center()
	end

	local slidevolume = vgui.Create("Slider", slidebox)
	slidevolume:SetDecimals(0)
	slidevolume:SetMinMax(0, 100)
	slidevolume:SetConVar("pbe2_volume")
	slidevolume:SetValue(GetConVar("pbe2_volume"):GetInt()) --???
	slidevolume:SizeToContents()
	slidevolume:SetWide(600)
	slidebox.Slider = slidevolume
	slidebox:InvalidateLayout()

	local strip = vgui.Create("PBEPanelStrip", self)
	strip:SetTall(40)
	strip:Dock(BOTTOM)
	strip:DockMargin(0, 0, 0, 12)
	strip:AddButton( "Spectate", function() RunConsoleCommand( "changeteam", TEAM_SPECTATOR ) TeamPanel:Remove() end, team.GetColor(TEAM_SPECTATOR) ):SetWide(250)
	strip:AddButton( "Start The Game!", function() RunConsoleCommand( "changeteam", TEAM_RUNNER ) TeamPanel:Remove() end, team.GetColor(TEAM_RUNNER) ):SetWide(250)

	self:InvalidateLayout()

	self.OpenTime = SysTime()
end

function PANEL:PerformLayout()
	self:SetSize(ScrW(), math.min(ScrH(), 300))
	self:CenterVertical()
end

function PANEL:Paint(w, h)
	Derma_DrawBackgroundBlur(self, self.OpenTime)

	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(0, 0, w, 2)
	surface.DrawRect(0, 4, w, h - 8)
	surface.DrawRect(0, h - 2, w, 2)
end

vgui.Register("PBEOptions", PANEL, "DPanel")

PANEL = {}

--[[function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 0, 0, 255)
	surface.DrawRect(0, 0, w, h)
end]]

function PANEL:PerformLayout()
	local padding = self:GetWide()
	for _, child in pairs(self:GetChildren()) do
		padding = padding - (child:GetWide() + 8)
	end
	padding = padding / 2

	self:DockPadding(padding, 0, padding, 0)
end

function PANEL:AddButton(strName, fnFunction, col)
	local btn = vgui.Create("DButton", self)
	btn:SetText(strName)
	btn:Dock(LEFT)
	btn:DockMargin(4, 0, 4, 0)
	btn.DoClick = function()
		surface.PlaySound("buttons/lightswitch2.wav")
		fnFunction()
	end

	Derma_Hook(btn, "Paint", 				"Paint", 		"SelectButton")
	Derma_Hook(btn, "PaintOver",			"PaintOver", 	"SelectButton")
	Derma_Hook(btn, "ApplySchemeSettings", "Scheme", 		"SelectButton")
	Derma_Hook(btn, "PerformLayout", 		"Layout", 		"SelectButton")

	btn.m_colBackground = col or btn.m_colBackground

	self:InvalidateLayout()

	return btn
end

vgui.Register("PBEPanelStrip", PANEL, "Panel")

local FirstTime = true
function GM:ShowTeam()
	if FirstTime then
		FirstTime = false
		GAMEMODE:ShowHelp()
		return
	end

	if not IsValid(TeamPanel) then
		TeamPanel = vgui.Create("PBEOptions")
	end

	TeamPanel:MakePopup()
end