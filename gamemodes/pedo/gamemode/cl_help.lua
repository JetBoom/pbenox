local CENTER_HEIGHT = 300

local PANEL = {}
function PANEL:Init()
	self:SetText( "" )
	--self:SetSkin( GAMEMODE.HudSkin )

	self.pnlButtons = vgui.Create( "DIconLayout", self )
	self.pnlButtons:SetSpaceY( 10 )
	self.pnlButtons:SetSpaceX( 10 )

	self.lblMain = vgui.Create( "DLabel", self )
	self.lblMain:SetText( GAMEMODE.Name )
	self.lblMain:SetFont( "FRETTA_HUGE" )
	self.lblMain:SetColor( color_white )

	self.lblItems = vgui.Create( "DLabel", self )
	self.lblItems:SetText( GAMEMODE.Name )
	self.lblItems:SetFont( "FRETTA_LARGE" )
	self.lblItems:SetColor( color_white )

	self.lblBear = vgui.Create( "DLabel", self )
	self.lblBear:SetText( GAMEMODE.Name )
	self.lblBear:SetFont( "FRETTA_LARGE" )
	self.lblBear:SetColor( color_white )

	self.lblPlayers = vgui.Create( "DLabel", self )
	self.lblPlayers:SetText( GAMEMODE.Name )
	self.lblPlayers:SetFont( "FRETTA_LARGE" )
	self.lblPlayers:SetColor( color_white )

	self.lblLMS = vgui.Create( "DLabel", self )
	self.lblLMS:SetText( GAMEMODE.Name )
	self.lblLMS:SetFont( "FRETTA_LARGE" )
	self.lblLMS:SetColor( color_white )

	self.pnlItems = vgui.Create( "DIconLayout", self )
	self.pnlItems:SetSpaceX( 4 )

	self.pnlModels = vgui.Create( "DIconLayout", self )
	self.pnlModels:SetSpaceX( 4 )

	self.imgBear = vgui.Create( "DImage", self )

	self:InvalidateLayout()
	self.OpenTime = SysTime()
end

function PANEL:AddSelectButton(strName, fnFunction, txt)
	local btn = vgui.Create("DButton", self.pnlButtons)
	btn:SetText( strName )
	btn:SetSize( 800, 40 )
	btn.DoClick = function() fnFunction() surface.PlaySound( Sound("buttons/lightswitch2.wav") ) self:Remove() end

	Derma_Hook( btn, "Paint", 				"Paint", 		"SelectButton" )
	Derma_Hook( btn, "PaintOver",			"PaintOver", 	"SelectButton" )
	Derma_Hook( btn, "ApplySchemeSettings", "Scheme", 		"SelectButton" )
	Derma_Hook( btn, "PerformLayout", 		"Layout", 		"SelectButton" )

	local ListItem = self.pnlButtons:Add( btn )
	ListItem:SetSize( 800, 40 )

	return btn
end

function PANEL:AddItemImage( imgMat, desc )
	local img = vgui.Create( "DImageButton", self.pnlItems )
	img:SetImage( imgMat )
	img:SetSize( 96, 96 )
	img.DoClick = function()
		self.lblItems:SetText( desc )
	end

	local ListItem = self.pnlItems:Add( img )
	ListItem:SetSize( 96, 96 )

	return img
end

function PANEL:AddPlayerModel( mdl )
	local icon = vgui.Create( "SpawnIcon" , self.pnlModels )
	icon:SetModel( mdl )
	icon:SetSize( 64, 64 )
	icon.Model = mdl

	local ListModels = self.pnlModels:Add( icon )
	ListModels:SetSize( 64, 64 )

	return icon
end

function PANEL:PerformLayout()
	self:SetSize( ScrW(), ScrH() )

	local CenterY = ScrH() / 2.0
	local InnerWidth = 800
	local currentY = 0
	self.lblMain:SizeToContents()
	self.lblMain:SetPos( ScrW() * 0.5 - self.lblMain:GetWide() * 0.5, CenterY - CENTER_HEIGHT - self.lblMain:GetTall() * 1.2 )

	currentY = CenterY - CENTER_HEIGHT
	self.lblItems:SizeToContents()
	self.lblItems:SetPos( ScrW() * 0.5 - self.lblItems:GetWide() * 0.5, currentY )

	currentY = currentY + self.lblItems:GetTall()
	self.pnlItems:SetSize( 100*table.Count(GAMEMODE:GetItemsList()), 96 )
	self.pnlItems:SetPos( ScrW() * 0.5 - self.pnlItems:GetWide() * 0.5, currentY )

	currentY = currentY + self.pnlItems:GetTall()
	self.lblBear:SizeToContents()
	self.lblBear:SetPos( ScrW() * 0.5 - self.lblBear:GetWide() * 0.5, currentY )

	currentY = currentY + self.lblBear:GetTall()
	self.imgBear:SetSize( 96, 192 )
	self.imgBear:SetPos( ScrW() * 0.5 - self.imgBear:GetWide() * 0.5, currentY )

	currentY = currentY + self.imgBear:GetTall()
	self.lblPlayers:SizeToContents()
	self.lblPlayers:SetPos( ScrW() * 0.5 - self.lblPlayers:GetWide() * 0.5, currentY )

	currentY = currentY + self.lblPlayers:GetTall()
	self.pnlModels:SetSize( 544, 64 )
	self.pnlModels:SetPos( ScrW() * 0.5 - self.pnlModels:GetWide() * 0.5, currentY )

	currentY = currentY + self.pnlModels:GetTall()
	self.lblLMS:SizeToContents()
	self.lblLMS:SetPos( ScrW() * 0.5 - self.lblLMS:GetWide() * 0.5, currentY )

	self.pnlButtons:SetPos( ScrW() * 0.5 - InnerWidth * 0.5, (CenterY + CENTER_HEIGHT) - 60 )
	self.pnlButtons:SetSize( InnerWidth, (CENTER_HEIGHT * 2) - 20 - 20 - 20 )
end

function PANEL:Paint()
	Derma_DrawBackgroundBlur( self, self.OpenTime )

	local CenterY = ScrH() / 2

	surface.SetDrawColor( 0, 0, 0, 200 );
	surface.DrawRect( 0, CenterY - CENTER_HEIGHT, ScrW(), CENTER_HEIGHT * 2 )
	surface.DrawRect( 0, CenterY - CENTER_HEIGHT - 4, ScrW(), 2 )
	surface.DrawRect( 0, CenterY + CENTER_HEIGHT + 2, ScrW(), 2 )
end

vgui_help = vgui.RegisterTable( PANEL, "DPanel" )

local HelpPanel
function GM:ShowHelp()
	if IsValid(HelpPanel) then return end

	HelpPanel = vgui.CreateFromTable( vgui_help )

	local func = function() GAMEMODE:ShowTeam() end
	local btn = HelpPanel:AddSelectButton( "Next (Hit F1 to see this again)", func )
	btn.m_colBackground = team.GetColor(TEAM_RUNNER)

	for k,itemInfo in ipairs(GAMEMODE:GetItemsList()) do
		HelpPanel:AddItemImage(itemInfo["material"], itemInfo["desc"])
	end
	local modelOptions = player_manager.AllValidModels()
	for i=1, 8 do
		HelpPanel:AddPlayerModel(table.Random(modelOptions))
	end

	HelpPanel.imgBear:SetImage("pbe2/pedobearhdright")
	HelpPanel.lblItems:SetText("Collect melons for items")
	HelpPanel.lblBear:SetText("Escape from Pedobear")
	HelpPanel.lblPlayers:SetText("Beat the other players...")
	HelpPanel.lblLMS:SetText("...by being the last one left.")
	HelpPanel.lblMain:SetText("WTF do I do?")

	HelpPanel:MakePopup()
end