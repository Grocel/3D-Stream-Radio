local LIBError = StreamRadioLib.Error

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
	HelpPanel:SetTitle( "Stream Radio Error Information" )
	HelpPanel:SetZPos(150)
	HelpPanel:GetParent():SetWorldClicker( true )

	HelpPanel.HelpTextPanel = vgui.Create( "Streamradio_VGUI_ReadOnlyTextEntry", HelpPanel )
	HelpPanel.HelpTextPanel:SetDrawBorder( true )
	HelpPanel.HelpTextPanel:SetPaintBackground( true )
	HelpPanel.HelpTextPanel:SetVerticalScrollbarEnabled( true )
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

	local OkButton = vgui.Create( "DButton", ControlPanel )
	OkButton:SetWide( 100 )
	OkButton:SetText( "OK" )
	OkButton:DockMargin( 5, 0, 0, 0 )
	OkButton:SetZPos(300)
	OkButton:Dock( RIGHT )

	OkButton.DoClick = function( self )
		StreamRadioLib.VR.CloseMenu(HelpPanel)
	end

	HelpPanel.CopyButton = vgui.Create( "DButton", ControlPanel )
	HelpPanel.CopyButton:SetWide( 100 )
	HelpPanel.CopyButton:SetText( "Copy to clipboard" )
	HelpPanel.CopyButton:DockMargin( 5, 0, 0, 0 )
	HelpPanel.CopyButton:SetZPos(400)
	HelpPanel.CopyButton:Dock( RIGHT )

	HelpPanel.OnlineHelpButton = StreamRadioLib.Menu.GetLinkButton("View online help")
	HelpPanel.OnlineHelpButton:SetParent(ControlPanel)
	HelpPanel.OnlineHelpButton:SetWide( 175 )
	HelpPanel.OnlineHelpButton:DockMargin( 5, 0, 20, 0 )
	HelpPanel.OnlineHelpButton:SetZPos(500)
	HelpPanel.OnlineHelpButton:Dock( RIGHT )

	HelpPanel.OptionToggleTick = vgui.Create( "DCheckBoxLabel", ControlPanel )
	HelpPanel.OptionToggleTick:SetWide( 125 )
	HelpPanel.OptionToggleTick:SetText( "" )
	HelpPanel.OptionToggleTick:DockMargin( 10, 0, 0, 0 )
	HelpPanel.OptionToggleTick:SetZPos(600)
	HelpPanel.OptionToggleTick:Dock( LEFT )

	g_helpPanel = HelpPanel
	return HelpPanel
end

local function OpenErrorHelpPanel( header, helptext, url, helpurl, userdata )
	header = header or ""
	helptext = helptext or ""
	url = url or ""
	helpurl = helpurl or ""
	userdata = userdata or {}

	local tickboxdata = userdata.userdata or {}
	tickboxdata = tickboxdata.tickbox

	local HelpPanel = CreateErrorHelpPanel()

	if not IsValid( HelpPanel ) then return end
	if not IsValid( HelpPanel.HelpTextPanel ) then return end
	if not IsValid( HelpPanel.CopyButton ) then return end
	if not IsValid( HelpPanel.OnlineHelpButton ) then return end
	if not IsValid( HelpPanel.OptionToggleTick ) then return end

	HelpPanel:SetTitle( "Stream Radio Error Information | " .. header )

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

	HelpPanel.OptionToggleTick:SetVisible(tickboxdata ~= nil)

	if tickboxdata then
		HelpPanel.OptionToggleTick:SetText(tickboxdata.text or "???")
		HelpPanel.OptionToggleTick:SetConVar(tickboxdata.cmd or "")
	end

	HelpPanel:InvalidateLayout( true )

	StreamRadioLib.g_HelpPanel = HelpPanel
	return HelpPanel
end

function StreamRadioLib.ShowErrorHelp( errorcode, url )
	local errorInfo = LIBError.GetStreamErrorInfo(errorcode)

	local hasHelpmenu = errorInfo.helpmenu
	if not hasHelpmenu then
		return
	end

	local code = errorInfo.id
	local name = errorInfo.name
	local description = errorInfo.description or ""
	local userdata = errorInfo.userdata

	local header = string.format("Error %i (%s): %s", code, name, description)

	local helptext = errorInfo.helptext or ""
	local helpurl = errorInfo.helpurl or ""

	OpenErrorHelpPanel( header, helptext, url, helpurl, userdata )
end

function StreamRadioLib.ShowPlaylistErrorHelp( )
	StreamRadioLib.ShowErrorHelp(LIBError.PLAYLIST_ERROR_INVALID_FILE)
end

return true

