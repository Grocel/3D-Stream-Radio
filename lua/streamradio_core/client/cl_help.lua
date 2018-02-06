local IsValid = IsValid
local type = type
local Vector = Vector
local GetViewEntity = GetViewEntity
local unpack = unpack
local tonumber = tonumber
local tostring = tostring
local Color = Color
local LocalPlayer = LocalPlayer
local concommand = concommand
local hook = hook
local math = math
local debug = debug
local string = string
local vgui = vgui
local net = net

local NoHelpText = [[
There is no help text for this error.

Please report this! Include the URL and the Errorcode in the report please.
]]

NoHelpText = string.gsub(NoHelpText, "\r", "")
NoHelpText = string.Trim(NoHelpText)

local ErrorHelpPlaylistText = [[
The Playlist file you are trying to load is invalid.

This could be the problem:
  - The playlist could not be found or read.
  - Its format is not supported.
  - It is broken.
  - It is empty.

Supported playlist formats:
  M3U, PLS, VDF, JSON

Playlists are located at "<path to game>/garrysmod/data/streamradio/playlists/".

Hint: Use the playlist editor to make playlists.
]]

ErrorHelpPlaylistText = string.gsub(ErrorHelpPlaylistText, "\r", "")
ErrorHelpPlaylistText = string.Trim(ErrorHelpPlaylistText)

local ErrorHelps = {}

ErrorHelps[-1] = {
	text = [[
The exact cause of this error is unknown.

This error is usually caused by:
  - Invalid file pathes or URLs without the protocol prefix such as 'http://'.
  - Attempting to play self-looping *.WAV files.

]],
	helpurl = ""
}

ErrorHelps[0] = {
	text = [[
Everything should be fine. You should not see this.
]],
	helpurl = ""
}

ErrorHelps[1] = {
	text = [[
A memory error is always bad.
You proably ran out of it.
]],
	helpurl = ""
}

ErrorHelps[2] = {
	text = [[
There was no file or content found at the given path.

If you try to play an online file:
  - Do not forget the protocol prefix such as 'http://'.
  - Make sure the file exist at the given URL. It should be downloadable.
  - Make sure the format is supported and the file is not broken. (See below.)

If you try to play a local file:
  - Make sure the file exist at the given path.
  - Make sure the file is readable for Garry's Mod.
  - The path must be relative your "<path to game>/garrysmod/sound/" folder. (See below.)
  - The file must be in "<path to game>/garrysmod/sound/" folder. (See below.)
  - You can play mounted stuff in "<path to game>/garrysmod/sound/".
  - You can not play sound scripts or sound properties.
  - Make sure the format is supported and the file is not broken. (See below.)

Supported formats:
  MP3, OGG, AAC, WAV, WMA, FLAC
  *.WAV files must be not self-looping in game as the API does not support these.

How local or mounted file paths work:
  - If you have a file located "<path to game>/garrysmod/sound/mymusic/song.mp3" you access it with these urls:
    * file://mymusic/song.mp3
    * mymusic/song.mp3"

  - For files in "<path to game>/garrysmod/sound/filename.mp3" you get them like this:
    * file://filename.mp3
    * filename.mp3

  - Files outside the game folder are forbidden to be accessed by the game.
  - Do not enter absolute paths.
  - Only people who also have the same file localed there, will be able to hear the music too.
  - Create folders if they are missing.

YouTube note:
  YouTube support is done via third party services, which are NOT under my control. So please do not blame me about problems with this.
]],
	helpurl = "http://steamcommunity.com/workshop/filedetails/discussion/246756300/523897277918001392/"
}

ErrorHelps[3] = {
	text = [[
Something is wrong with your sound hardware or your sound drivers.
]],
	helpurl = ""
}

ErrorHelps[4] = {
	text = [[
Your sound driver/interface was lost.

To fix it you need to do this:
- Plugin your speakers or head phones.
- Enable the sound device.
- Restart the game. Do not just disconnect!
- Restart your PC, if it still not works.
]],
	helpurl = ""
}

ErrorHelps[18] = {
	text = [[
A memory error is always bad.
You proably ran out of it.
]],
	helpurl = ""
}

ErrorHelps[21] = {
	text = [[
Something is wrong with your sound hardware or your sound drivers.
It does not support 3D world sound.
]],
	helpurl = ""
}

ErrorHelps[22] = {
	text = [[
Something is wrong with your sound hardware or your sound drivers.
It does not support EAX-effects.
]],
	helpurl = ""
}

ErrorHelps[29] = {
	text = [[
Something is wrong with your sound hardware. Out of memory?
]],
	helpurl = ""
}

ErrorHelps[32] = {
	text = [[
You internet connection is not working.
Check your network devices and your firewall.
]],
	helpurl = ""
}

ErrorHelps[34] = {
	text = [[
Something is wrong with your sound hardware or your sound drivers.
It does not support EAX-effects.
]],
	helpurl = ""
}

ErrorHelps[37] = {
	text = [[4]],
}

ErrorHelps[39] = {
	text = [[
Something is wrong with your sound hardware or your sound drivers.
DirectX seems to be outdated or not installed.
]],
	helpurl = ""
}

ErrorHelps[40] = {
	text = [[
The connection seems being slow. Just try again in a few minutes.
If it does not work, the server you are trying to stream from is down.

YouTube note:
  YouTube support is done via third party services, which are NOT under my control. So please do not blame me about problems with this.
]],
	helpurl = ""
}

ErrorHelps[41] = {
	text = [[
You are trying to play something that the streaming API of GMod (and so the radio) does not support.

These things will NOT work:
  - HTML pages that play sound.
  - Flash players/games/applications that are playing sound.
  - Videos exept those on YouTube in limited cases. (See below.)
  - Anything that requires any kind of login to access.
  - Anything that is not public.
  - Sound scripts or sound properties.
  - Broken files or unsupported formats. (See below.)

These things will work:
  - URLs to sound files (aka. DIRECT download).
  - URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
  - URLs inside these playlists files.
  - Local sound files inside your "<path to game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
  - You may have to install addional codices to your OS.
  - Formats that are listed below.

Supported formats:
  MP3, OGG, AAC, WAV, WMA, FLAC
  *.WAV files must be not self-looping ingame as the API does not support these.

YouTube note:
  YouTube support is done via third party services, which are NOT under my control. So please do not blame me about problems with this.
]],
	helpurl = "http://steamcommunity.com/workshop/filedetails/discussion/246756300/523897277918028290/"
}

ErrorHelps[42] = {
	text = [[
Something is wrong with your sound hardware or your sound drivers.
Do you even have speakers?
]],
	helpurl = ""
}

ErrorHelps[44] = {
	text = [[41]]
}

ErrorHelps[1000] = {
	text = [[
The server does not allow playback of custom URLs.
You can ask an admin to enable it, but there is probably a reason why it is forbidden.

All online URLs from these sources are blocked:
  - Toolgun input
  - Wiremod input
  - From duplications and saves

The Convar is: sv_streamradio_allow_customurls 0/1
]],
	helpurl = ""
}

ErrorHelps[37] = ErrorHelps[4]
ErrorHelps[44] = ErrorHelps[41]

local HelpPanel = nil
local HelpPanelYoutube = nil

local function CreateErrorHelpPanel( ErrorHeader, ErrorText, url, ErrorOnlineHelp, ErrorData )
	ErrorHeader = ErrorHeader or ""
	ErrorText = ErrorText or ""
	url = url or ""
	ErrorOnlineHelp = ErrorOnlineHelp or ""
	ErrorData = ErrorData or {}

	local tickboxdata = ErrorData.userdata or {}
	tickboxdata = tickboxdata.tickbox

	if not IsValid( HelpPanel ) then
		local ErrorHelpFont = StreamRadioLib.Surface.AddFont(14, 1000, "Lucida Console")
		HelpPanel = vgui.Create( "DFrame" ) -- The main frame.
		HelpPanel:SetPos( 25, 25 )

		local W = math.min( ScrW( ) - 50, 700 )
		local H = math.min( ScrH( ) - 50, 400 )
		HelpPanel:SetSize( W, H )

		HelpPanel:SetMinWidth( 550 )
		HelpPanel:SetMinHeight( 200 )
		HelpPanel:SetSizable( true )
		HelpPanel:SetDeleteOnClose( false )
		HelpPanel:SetVisible( false )
		HelpPanel:SetTitle( "Stream Radio Error Information" )
		HelpPanel:GetParent( ):SetWorldClicker( true )

		HelpPanel.HelpTextPanel = vgui.Create( "DTextEntry", HelpPanel )
		HelpPanel.HelpTextPanel:SetEditable( true )
		HelpPanel.HelpTextPanel:SetMultiline( true )
		HelpPanel.HelpTextPanel:SetDrawLanguageID( false )
		HelpPanel.HelpTextPanel:AllowInput( false )
		HelpPanel.HelpTextPanel:SetTabbingDisabled( false )
		HelpPanel.HelpTextPanel:SetHistoryEnabled( false )
		HelpPanel.HelpTextPanel:SetEnterAllowed( false )
		HelpPanel.HelpTextPanel:SetDrawBorder( true )
		HelpPanel.HelpTextPanel:SetVerticalScrollbarEnabled( true )
		HelpPanel.HelpTextPanel:SetFont( ErrorHelpFont )
		HelpPanel.HelpTextPanel:Dock( FILL )

		local ControlPanel = vgui.Create( "DPanel", HelpPanel )
		ControlPanel:SetPaintBackground( false )
		ControlPanel:SetTall( 30 )
		ControlPanel:DockMargin( 0, 5, 0, 0 )
		ControlPanel:Dock( BOTTOM )

		local OkButton = vgui.Create( "DButton", ControlPanel )
		OkButton:SetWide( 100 )
		OkButton:SetText( "OK" )
		OkButton:DockMargin( 5, 0, 0, 0 )
		OkButton:Dock( RIGHT )

		OkButton.DoClick = function( self )
			if ( not IsValid( HelpPanel ) ) then return end
			HelpPanel:Close( )
		end

		HelpPanel.CopyButton = vgui.Create( "DButton", ControlPanel )
		HelpPanel.CopyButton:SetWide( 100 )
		HelpPanel.CopyButton:SetText( "Copy to clipboard" )
		HelpPanel.CopyButton:DockMargin( 5, 0, 0, 0 )
		HelpPanel.CopyButton:Dock( RIGHT )

		HelpPanel.OnlineHelpButton = vgui.Create( "DButton", ControlPanel )
		HelpPanel.OnlineHelpButton:SetWide( 125 )
		HelpPanel.OnlineHelpButton:SetText( "View online help" )
		HelpPanel.OnlineHelpButton:DockMargin( 5, 0, 20, 0 )
		HelpPanel.OnlineHelpButton:Dock( RIGHT )

		HelpPanel.OptionToggleTick = vgui.Create( "DCheckBoxLabel", ControlPanel )
		HelpPanel.OptionToggleTick:SetWide( 125 )
		HelpPanel.OptionToggleTick:SetText( "" )
		HelpPanel.OptionToggleTick:DockMargin( 10, 0, 0, 0 )
		HelpPanel.OptionToggleTick:Dock( LEFT )
	end

	if ( not IsValid( HelpPanel ) ) then return end
	if ( not IsValid( HelpPanel.HelpTextPanel ) ) then return end
	if ( not IsValid( HelpPanel.CopyButton ) ) then return end
	if ( not IsValid( HelpPanel.OnlineHelpButton ) ) then return end
	if ( not IsValid( HelpPanel.OptionToggleTick ) ) then return end

	HelpPanel:Close( )
	HelpPanel:SetTitle( "Stream Radio Error Information | " .. ErrorHeader )
	HelpPanel:SetVisible( true )
	HelpPanel:MakePopup( )

	if url ~= "" then
		ErrorText = ErrorHeader .. "\nURL: " .. url .. "\n\n" .. ErrorText
	else
		ErrorText = ErrorHeader .. "\n\n" .. ErrorText
	end

	HelpPanel.HelpTextPanel:SetText( ErrorText )

	HelpPanel.HelpTextPanel.OnChange = function( self )
		if ( not IsValid( HelpPanel ) ) then return end
		self:SetText( ErrorText )
	end

	local CopyText = string.gsub( ErrorText or "", "\n", "\r\n" )
	CopyText = string.Trim( CopyText )
	HelpPanel.CopyButton:SetVisible(CopyText ~= "")

	HelpPanel.CopyButton.DoClick = function( self )
		if ( not IsValid( HelpPanel ) ) then return end
		if ( CopyText == "" ) then return end

		SetClipboardText( CopyText )
	end

	HelpPanel.OnlineHelpButton:SetVisible( ErrorOnlineHelp ~= "" )

	HelpPanel.OnlineHelpButton.DoClick = function( self )
		if ( not IsValid( HelpPanel ) ) then return end
		if ( ErrorOnlineHelp == "" ) then return end
		gui.OpenURL( ErrorOnlineHelp )
	end

	HelpPanel:InvalidateLayout( true )

	HelpPanel.OptionToggleTick:SetVisible(tickboxdata ~= nil)

	if tickboxdata then
		HelpPanel.OptionToggleTick:SetText(tickboxdata.text or "???")
		HelpPanel.OptionToggleTick:SetConVar(tickboxdata.cmd or "")
	end

	return HelpPanel
end

function StreamRadioLib.ShowErrorHelp( errorcode, url )
	errorcode = tonumber(errorcode or -1) or -1
	if errorcode == 0 then return end

	local errorheader = "Error " .. errorcode .. ": " .. StreamRadioLib.DecodeErrorCode( errorcode )

	local errordata = ErrorHelps[errorcode] or {}
	local errortext = errordata.text or ""
	errortext = string.gsub( errortext, "\r", "" )
	errortext = string.Trim( errortext )

	if errortext == "" then
		errordata = StreamRadioLib.Interface.GetErrorData(errorcode) or {}
		errortext = errordata.text or ""
		errortext = string.gsub( errortext, "\r", "" )
		errortext = string.Trim( errortext )
	end

	if errortext == "" then
		errortext = NoHelpText
	end

	local erroronlinehelp = errordata.helpurl or errordata.url or ""

	url = url or ""
	if StreamRadioLib.IsBlockedURLCode(url) then
		url = ""
	end

	CreateErrorHelpPanel( errorheader, errortext, url, erroronlinehelp, errordata )
end

function StreamRadioLib.ShowPlaylistErrorHelp( )
	CreateErrorHelpPanel( "Error: Invalid Playlist", ErrorHelpPlaylistText, nil, "http://steamcommunity.com/workshop/filedetails/discussion/246756300/523897277917951293/" )
end
