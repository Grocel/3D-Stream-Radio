local LIBError = StreamRadioLib.Error
local LIBLocale = StreamRadioLib.Locale
local LIBHook = StreamRadioLib.Hook
local LIBTimer = StreamRadioLib.Timer

local T = LIBLocale.Translate
local F = LIBLocale.Format

local g_helpPanel = StreamRadioLib.g_HelpPanel

if IsValid(g_helpPanel) then
	StreamRadioLib.VR.CloseMenu(g_helpPanel)
	g_helpPanel:Remove()

	g_helpPanel = nil
	StreamRadioLib.g_HelpPanel = nil
end

local function CreateErrorHelpPanel()
	if IsValid( g_helpPanel ) then
		return g_helpPanel
	end

	local ErrorHelpFont = StreamRadioLib.Surface.AddFont(14, 1000, "Lucida Console")
	local HelpPanel = vgui.Create( "DFrame" ) -- The main frame.

	HelpPanel:SetPos( 25, 25 )
	HelpPanel:SetSize( 900, 600 )

	HelpPanel:SetMinWidth( 575 )
	HelpPanel:SetMinHeight( 200 )
	HelpPanel:SetSizable( true )
	HelpPanel:SetDeleteOnClose( false )
	HelpPanel:SetVisible( false )
	HelpPanel:SetTitle( "" )
	HelpPanel:SetZPos(150)
	HelpPanel:GetParent():SetWorldClicker( true )

	HelpPanel.HelpTextPanel = vgui.Create( "Streamradio_VGUI_ReadOnlyTextEntry", HelpPanel )
	HelpPanel.HelpTextPanel:SetDrawBorder( true )
	HelpPanel.HelpTextPanel:SetPaintBackground( true )
	HelpPanel.HelpTextPanel:SetVerticalScrollbarEnabled( true )
	HelpPanel.HelpTextPanel:SetHistoryEnabled( false )
	HelpPanel.HelpTextPanel:SetFont( ErrorHelpFont )
	HelpPanel.HelpTextPanel:SetZPos(100)
	HelpPanel.HelpTextPanel:SetCursor( "beam" )
	HelpPanel.HelpTextPanel:Dock( FILL )

	local ControlPanel = vgui.Create( "DPanel", HelpPanel )
	ControlPanel:SetPaintBackground( false )
	ControlPanel:SetTall( 30 )
	ControlPanel:DockMargin( 0, 5, 0, 0 )
	ControlPanel:SetZPos(200)
	ControlPanel:Dock( BOTTOM )

	local CloseButton = vgui.Create( "DButton", ControlPanel )
	CloseButton:SetWide( 100 )
	CloseButton:SetText( T("?vgui.error_help_panel.close", "Close") )
	CloseButton:DockMargin( 5, 0, 0, 0 )
	CloseButton:SetZPos(300)
	CloseButton:Dock( RIGHT )

	CloseButton.DoClick = function( self )
		StreamRadioLib.VR.CloseMenu(HelpPanel)
	end

	HelpPanel.CopyButton = vgui.Create( "DButton", ControlPanel )
	HelpPanel.CopyButton:SetWide( 150 )
	HelpPanel.CopyButton:SetText( T("?vgui.error_help_panel.clipboard", "Copy to clipboard") )
	HelpPanel.CopyButton:DockMargin( 5, 0, 0, 0 )
	HelpPanel.CopyButton:SetZPos(400)
	HelpPanel.CopyButton:Dock( RIGHT )

	local viewOnline = T("?vgui.error_help_panel.view_online", "View online help")

	HelpPanel.OnlineHelpButton = StreamRadioLib.Menu.GetLinkButton(viewOnline)
	HelpPanel.OnlineHelpButton:SetParent(ControlPanel)
	HelpPanel.OnlineHelpButton:SetWide( 200 )
	HelpPanel.OnlineHelpButton:DockMargin( 5, 0, 20, 0 )
	HelpPanel.OnlineHelpButton:SetZPos(500)
	HelpPanel.OnlineHelpButton:Dock( RIGHT )

	g_helpPanel = HelpPanel
	return HelpPanel
end

local function OpenErrorHelpPanel( header, helptext, url, helpurl, userdata )
	header = header or ""
	helptext = helptext or ""
	url = url or ""
	helpurl = helpurl or ""
	userdata = userdata or {}

	local HelpPanel = CreateErrorHelpPanel()

	if not IsValid( HelpPanel ) then return end
	if not IsValid( HelpPanel.HelpTextPanel ) then return end
	if not IsValid( HelpPanel.CopyButton ) then return end
	if not IsValid( HelpPanel.OnlineHelpButton ) then return end

	local title = F(
		"?vgui.error_help_panel.header",
		"Stream Radio Error Information | %s",
		header
	)

	HelpPanel:SetTitle(title)

	if not StreamRadioLib.VR.IsActive() then
		local X, Y = HelpPanel:GetPos()
		local W, H = HelpPanel:GetSize()

		if X <= 0 then
			X = 25
		end

		if Y <= 0 then
			Y = 25
		end

		W = math.min(ScrW() - 50, W)
		H = math.min(ScrH() - 50, H)

		HelpPanel:SetPos(X, Y)
		HelpPanel:SetSize(W, H)
		HelpPanel:SetSizable(true)
		HelpPanel:SetDraggable(true)
		HelpPanel:GetParent():SetWorldClicker(true)
	else
		HelpPanel:SetPos(0, 0)
		HelpPanel:SetSize(900, 600)
		HelpPanel:SetSizable(false)
		HelpPanel:SetDraggable(false)
		HelpPanel:GetParent():SetWorldClicker(false)
	end

	StreamRadioLib.VR.MenuOpen(
		"StreamRadioErrorInformation",
		HelpPanel,
		true
	)

	if url ~= "" then
		helptext = string.format("%s\n\n%s\n\n%s", header, url, helptext)
	else
		helptext = string.format("%s\n\n%s", header, helptext)
	end

	helptext = string.Replace(helptext, "\t", "    ")

	HelpPanel.HelpTextPanel:SetText( helptext )

	local CopyText = string.gsub( helptext or "", "\n", "\r\n" )
	CopyText = string.Trim( CopyText )
	HelpPanel.CopyButton:SetVisible(CopyText ~= "")

	HelpPanel.CopyButton.DoClick = function( self )
		if ( not IsValid( HelpPanel ) ) then return end
		if ( CopyText == "" ) then return end

		SetClipboardText( CopyText )
	end

	HelpPanel.OnlineHelpButton:SetVisible( helpurl ~= "" )
	HelpPanel.OnlineHelpButton:SetURL( helpurl )

	HelpPanel:InvalidateLayout( true )

	StreamRadioLib.g_HelpPanel = HelpPanel
	return HelpPanel
end

function StreamRadioLib.ShowErrorHelp( errorcode, url )
	local errorInfo = LIBError.GetStreamErrorInfo(errorcode)

	local hashelp = errorInfo.hashelp
	if not hashelp then
		return
	end

	local id = errorInfo.id
	local name = errorInfo.name
	local description = errorInfo.translation.description or ""
	local userdata = errorInfo.userdata

	local header = F(
		"?vgui.error_help_panel.header_error_info",
		"Error %i (%s): %s",
		id, name, description
	)

	local helptext = errorInfo.translation.helptext or ""
	local helpurl = errorInfo.helpurl or ""

	OpenErrorHelpPanel( header, helptext, url, helpurl, userdata )
end

LIBTimer.Simple(0.5, function()
	local function recreatePanel()
		if IsValid(g_helpPanel) then
			StreamRadioLib.VR.CloseMenu(g_helpPanel)
			g_helpPanel:Remove()

			g_helpPanel = nil
			StreamRadioLib.g_HelpPanel = nil
		end

		StreamRadioLib.ShowErrorHelp(-1, "")

		if IsValid(g_helpPanel) then
			StreamRadioLib.VR.CloseMenu(g_helpPanel)
		end
	end

	LIBHook.AddCustom("OnLocaleChanged", "ErrorHelp.recreatePanel", recreatePanel)
	LIBHook.AddCustom("OnLocaleGenerate", "ErrorHelp.recreatePanel", recreatePanel)
end)

return true

