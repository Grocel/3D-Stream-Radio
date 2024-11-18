
local StreamRadioLib = StreamRadioLib

StreamRadioLib.properties = StreamRadioLib.properties or {}

local LIB = StreamRadioLib.properties
table.Empty(LIB)

local LIBNet = StreamRadioLib.Net
local LIBError = StreamRadioLib.Error
local LIBUtil = StreamRadioLib.Util
local LIBUrl = StreamRadioLib.Url

local g_mainOptionAdded = false
local g_subOptions = {}
local g_nameprefix = "3dstreamradio_properties_"

local g_mode_play = 0
local g_mode_pause = 1
local g_mode_stop = 2
local g_mode_previous_track = 3
local g_mode_next_track = 4
local g_mode_rewind = 5
local g_mode_fastforward = 6

local g_mode_mute = 0
local g_mode_unmute = 1
local g_mode_volume_up = 2
local g_mode_volume_down = 3

if SERVER then
	LIBNet.Receive("properties", function(len, client)
		if not IsValid(client) then return end

		local name = net.ReadString()
		if not name then return end

		local subOption = g_subOptions[name]
		if not subOption then return end
		if not subOption.Receive then return end

		subOption:Receive(len, client)
	end)
end

function LIB.GetName(identifier)
	identifier = g_nameprefix .. tostring(identifier or "")
	identifier = string.lower(identifier)

	return identifier
end

function LIB.Get(identifier)
	identifier = LIB.GetName(identifier)

	return properties.List[identifier] or g_subOptions[identifier]
end

function LIB.Add(identifier, propertyData)
	identifier = LIB.GetName(identifier)

	return properties.Add(identifier, propertyData)
end

function LIB.CanProperty(identifier, ent, ply )
	if not IsValid( ent ) then return false end
	if not ent.__IsRadio then return false end

	identifier = LIB.GetName(identifier)
	if not gamemode.Call( "CanProperty", ply, identifier, ent ) then return false end

	return true
end

function LIB.CanBeTargeted(ent, ply)
	if not IsValid( ent ) then return false end
	if not ent.__IsRadio then return false end
	if not properties.CanBeTargeted( ent, ply ) then return false end

	return true
end

function LIB.CheckFilter(identifier, ent, ply)
	local propertyData = LIB.Get(identifier)

	if not propertyData then
		return true
	end

	if not propertyData.Filter then
		return true
	end

	return propertyData:Filter(ent, ply)
end

function LIB.CheckFilters(identifiers, ent, ply)
	for i, identifier in ipairs(identifiers) do
		if LIB.CheckFilter(identifier, ent, ply) then
			return true
		end
	end

	return false
end

local g_meta = {
	MsgStart = function(self)
		LIBNet.Start("properties")
		net.WriteString(self.InternalName)
	end,

	MsgEnd = function(self)
		net.SendToServer()
	end
}

g_meta.__index = g_meta

local function addMainOption()
	if g_mainOptionAdded then
		return
	end

	LIB.Add("radio_options", {
		MenuLabel = "Radio Options",
		Order = 10000,
		MenuIcon = "3dstreamradio/icon16/format_radio.png",

		Filter = function( self, ent, ply )
			if not LIB.CanBeTargeted( ent, ply ) then return false end
			return true
		end,

		MenuOpen = function( self, option, ent, tr )
			local ply = LocalPlayer()
			if not self:Filter(ent, ply) then return end

			local submenuPanel = option:AddSubMenu()

			submenuPanel:SetMinimumWidth(215)

			for k, subOption in SortedPairsByMemberValue( g_subOptions, "Order" ) do
				if not subOption.Filter then continue end
				if not subOption:Filter(ent, ply) then continue end

				if subOption.PrependSpacer then
					submenuPanel:AddSpacer()
				end

				local label = subOption.MenuLabel or subOption.InternalName

				local optionPanel = submenuPanel:AddOption(
					label,
					function(panel)
						if not subOption:Filter(ent, ply) then
							return
						end

						subOption:Action(ent, tr)

						panel:Think()
					end
				)

				if subOption.OnCreate then
					subOption:OnCreate(submenuPanel, optionPanel)
				end

				if subOption.MenuIcon then
					optionPanel:SetImage(subOption.MenuIcon)
				end

				if subOption.MenuOpen then
					subOption:MenuOpen(optionPanel, ent, tr)
				end

				optionPanel._oldThink = optionPanel.Think
				optionPanel.Think = function(panel, ...)
					if not subOption.Think then
						return
					end

					if not subOption:Filter(ent, ply) then
						return
					end

					subOption:Think(panel, ent)

					if panel._oldThink then
						return panel:_oldThink(...)
					end
				end
			end
		end,

		Action = function( self, ent )
		end,

		Receive = function( self, length, ply )
		end
	})

	g_mainOptionAdded = true
end

function LIB.AddSubOption(identifier, propertyData)
	addMainOption()

	identifier = LIB.GetName(identifier)

	propertyData = table.Copy(propertyData)
	propertyData.InternalName = identifier

	setmetatable(propertyData, g_meta)

	g_subOptions[identifier] = propertyData
end

local function g_emptyFunction()
end

local g_titleOnCreate = function( self, submenuPanel, optionPanel )
	optionPanel.OnMousePressed = g_emptyFunction
	optionPanel.OnMouseReleased = g_emptyFunction
	optionPanel.DoClickInternal = g_emptyFunction

	optionPanel:SetEnabled(false)
	optionPanel:SetTextInset(2, 0)
	optionPanel:SetContentAlignment(5)
end

local g_VolumeMenuOpen = function( self, optionPanel, ent )
	optionPanel.OnMousePressed = g_emptyFunction
	optionPanel.OnMouseReleased = g_emptyFunction
	optionPanel.DoClickInternal = g_emptyFunction

	optionPanel:SetTextInset(10, 0)
	optionPanel:DockPadding(5, 5, 5, 5)

	local ply = LocalPlayer()

	local upButton = vgui.Create( "DButton", optionPanel )
	optionPanel._upButton = upButton

	upButton:Dock(RIGHT)
	upButton:SetImage(StreamRadioLib.GetPNGIconPath("sound_add"))
	upButton:SetText("")
	upButton:DockMargin(5, 0, 0, 0)
	upButton:SetTooltip("Increase volume")

	upButton.DoClick = function(panel)
		if not self.VolumeUp then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:VolumeUp(ent)
		panel:Think()
	end

	local downButton = vgui.Create( "DButton", optionPanel )
	optionPanel._downButton = downButton

	downButton:Dock(RIGHT)
	downButton:SetImage(StreamRadioLib.GetPNGIconPath("sound_delete"))
	downButton:SetText("")
	downButton:DockMargin(5, 0, 0, 0)
	downButton:SetTooltip("Decrease volume")

	downButton.DoClick = function(panel)
		if not self.VolumeDown then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:VolumeDown(ent)
		panel:Think()
	end

	local muteButton = vgui.Create( "DButton", optionPanel )
	optionPanel._muteButton = muteButton

	muteButton:Dock(RIGHT)
	muteButton:SetImage(StreamRadioLib.GetPNGIconPath("sound_mute"))
	muteButton:SetText("")
	muteButton:DockMargin(0, 0, 0, 0)
	muteButton:SetTooltip("Mute")

	muteButton.DoClick = function(panel)
		if not self.Mute then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:Mute(ent)
		panel:Think()
	end

	local unmuteButton = vgui.Create( "DButton", optionPanel )
	optionPanel._unmuteButton = unmuteButton

	unmuteButton:Dock(RIGHT)
	unmuteButton:SetImage(StreamRadioLib.GetPNGIconPath("sound"))
	unmuteButton:SetText("")
	unmuteButton:DockMargin(0, 0, 0, 0)
	unmuteButton:SetTooltip("Unmute")

	unmuteButton.DoClick = function(panel)
		if not self.Unmute then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:Unmute(ent)
		panel:Think()
	end

	-- bypass hardcoded size in internal PerformLayout
	optionPanel._SetSize = optionPanel.SetSize

	optionPanel.SetSize = function(panel, x, y)
		y = 40
		local buttonSize = y - 10

		upButton:SetSize(buttonSize, buttonSize)
		downButton:SetSize(buttonSize, buttonSize)
		muteButton:SetSize(buttonSize, buttonSize)
		unmuteButton:SetSize(buttonSize, buttonSize)

		return panel:_SetSize(x, y)
	end
end

local g_PlaylistControlsMenuOpen = function( self, optionPanel, ent )
	optionPanel.OnMousePressed = g_emptyFunction
	optionPanel.OnMouseReleased = g_emptyFunction
	optionPanel.DoClickInternal = g_emptyFunction

	optionPanel:SetTextInset(5, 0)
	optionPanel:DockPadding(5, 5, 5, 5)

	local ply = LocalPlayer()

	local playButton = vgui.Create( "DButton", optionPanel )
	optionPanel._playButton = playButton

	playButton:Dock(LEFT)
	playButton:SetImage(StreamRadioLib.GetPNGIconPath("control_play"))
	playButton:SetText("")
	playButton:DockMargin(0, 0, 0, 0)
	playButton:SetTooltip("Play")

	playButton.DoClick = function(panel)
		if not self.Play then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:Play(ent)
		panel:Think()
	end

	local pauseButton = vgui.Create( "DButton", optionPanel )
	optionPanel._pauseButton = pauseButton

	pauseButton:Dock(LEFT)
	pauseButton:SetImage(StreamRadioLib.GetPNGIconPath("control_pause"))
	pauseButton:SetText("")
	pauseButton:DockMargin(0, 0, 0, 0)
	pauseButton:SetTooltip("Pause")

	pauseButton.DoClick = function(panel)
		if not self.Pause then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:Pause(ent)
		panel:Think()
	end

	local stopButton = vgui.Create( "DButton", optionPanel )
	optionPanel._stopButton = stopButton

	stopButton:Dock(LEFT)
	stopButton:SetImage(StreamRadioLib.GetPNGIconPath("control_stop"))
	stopButton:SetText("")
	stopButton:DockMargin(5, 0, 0, 0)
	stopButton:SetTooltip("Stop")

	stopButton.DoClick = function(panel)
		if not self.Stop then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:Stop(ent)
		panel:Think()
	end

	local previousTrackButton = vgui.Create( "DButton", optionPanel )
	optionPanel._previousTrackButton = previousTrackButton

	previousTrackButton:Dock(LEFT)
	previousTrackButton:SetImage(StreamRadioLib.GetPNGIconPath("control_start"))
	previousTrackButton:SetText("")
	previousTrackButton:DockMargin(5, 0, 0, 0)
	previousTrackButton:SetTooltip("Previous track")

	previousTrackButton.DoClick = function(panel)
		if not self.PreviousTrack then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:PreviousTrack(ent)
		panel:Think()
	end

	local nextTrackButton = vgui.Create( "DButton", optionPanel )
	optionPanel._nextTrackButton = nextTrackButton

	nextTrackButton:Dock(LEFT)
	nextTrackButton:SetImage(StreamRadioLib.GetPNGIconPath("control_end"))
	nextTrackButton:SetText("")
	nextTrackButton:DockMargin(5, 0, 0, 0)
	nextTrackButton:SetTooltip("Next track")

	nextTrackButton.DoClick = function(panel)
		if not self.NextTrack then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:NextTrack(ent)
		panel:Think()
	end

	local rewindButton = vgui.Create( "DButton", optionPanel )
	optionPanel._rewindButton = rewindButton

	rewindButton:Dock(LEFT)
	rewindButton:SetImage(StreamRadioLib.GetPNGIconPath("control_rewind"))
	rewindButton:SetText("")
	rewindButton:DockMargin(5, 0, 0, 0)
	rewindButton:SetTooltip("Rewind 10 seconds")

	rewindButton.DoClick = function(panel)
		if not self.Rewind then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:Rewind(ent)
		panel:Think()
	end

	local fastForwardButton = vgui.Create( "DButton", optionPanel )
	optionPanel._fastForwardButton = fastForwardButton

	fastForwardButton:Dock(LEFT)
	fastForwardButton:SetImage(StreamRadioLib.GetPNGIconPath("control_fastforward"))
	fastForwardButton:SetText("")
	fastForwardButton:DockMargin(5, 0, 0, 0)
	fastForwardButton:SetTooltip("Fast forward 10 seconds")

	fastForwardButton.DoClick = function(panel)
		if not self.FastForward then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:FastForward(ent)
		panel:Think()
	end

	-- bypass hardcoded size in internal PerformLayout
	optionPanel._SetSize = optionPanel.SetSize

	optionPanel.SetSize = function(panel, x, y)
		y = 40
		local buttonSize = y - 10

		playButton:SetSize(buttonSize, buttonSize)
		pauseButton:SetSize(buttonSize, buttonSize)
		stopButton:SetSize(buttonSize, buttonSize)
		previousTrackButton:SetSize(buttonSize, buttonSize)
		nextTrackButton:SetSize(buttonSize, buttonSize)
		rewindButton:SetSize(buttonSize, buttonSize)
		fastForwardButton:SetSize(buttonSize, buttonSize)

		return panel:_SetSize(x, y)
	end
end

LIB.AddSubOption("clientside_title", {
	MenuLabel = "Clientside Options",
	Order = 100,
	PrependSpacer = true,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end

		local allowed = LIB.CheckFilters(
			{
				"copy_url",
				"error_info",
				"clientside_mute",
				"clientside_unmute",
				"clientside_volume",
			},
			ent,
			ply
		)

		return allowed
	end,

	Action = function( self, ent )
	end,

	OnCreate = g_titleOnCreate,
})

LIB.AddSubOption("copy_url", {
	MenuLabel = "Copy Stream URL to clipboard",
	Order = 110,
	MenuIcon = StreamRadioLib.GetPNGIconPath("page_copy"),
	PrependSpacer = true,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end

		local url = ent:GetStreamURL()
		if url == "" then return false end

		return true
	end,

	Action = function( self, ent )
		local url = ent:GetStreamURL()
		SetClipboardText(url)
	end,
})

LIB.AddSubOption("error_info", {
	MenuLabel = "Error",
	Order = 111,
	MenuIcon = StreamRadioLib.GetPNGIconPath("error"),

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end

		local stream = ent:GetStreamObject()
		if not stream then return false end
		if not stream:HasError() then return false end

		return true
	end,

	Action = function( self, ent )
		local stream = ent:GetStreamObject()

		if stream:IsKilled() then
			stream:ReviveStream()
			return
		end

		local err = stream:GetError()
		local url = stream:GetURL()

		StreamRadioLib.ShowErrorHelp(err, url)
	end,

	Think = function( self, optionPanel, ent )
		local stream = ent:GetStreamObject()

		if stream:IsKilled() then
			local label = string.format("%s: %s", self.MenuLabel, "Sound stopped!")
			local tooltip = "The sound has been stopped. Click here to restart."

			optionPanel:SetText(label)
			optionPanel:SetTooltip(tooltip)
			return
		end

		local err = stream:GetError()
		local url = stream:GetURL()

		local errorInfo = LIBError.GetStreamErrorInfo(err)
		local errorName = errorInfo.name
		local errorDescription = errorInfo.description
		local hasHelpmenu = errorInfo.helpmenu

		local label = string.format("%s: %i (%s)", self.MenuLabel, err, errorName)

		local tooltip = ""

		if hasHelpmenu then
			tooltip = string.format("Error %i (%s): %s\n\nCan not play this URL:\n%s\n\nClick for more details.", err, errorName, errorDescription, url)
		else
			tooltip = string.format("Error %i (%s): %s\n\nCan not play this URL:\n%s", err, errorName, errorDescription, url)
		end

		optionPanel:SetText(label)
		optionPanel:SetTooltip(tooltip)
	end,
})

LIB.AddSubOption("reset_gui", {
	MenuLabel = "Reset GUI",
	Order = 112,
	MenuIcon = StreamRadioLib.GetPNGIconPath("lightning"),

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		if ent.DisplayLess then return false end

		return true
	end,

	Action = function( self, ent )
		ent:RemoveGui()
	end,
})

LIB.AddSubOption("clientside_volume", {
	MenuLabel = "Volume",
	Order = 120,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		return true
	end,

	Action = function( self, ent )
	end,

	Mute = function( self, ent )
		ent:SetCLMute(true)
	end,

	Unmute = function( self, ent )
		ent:SetCLMute(false)
	end,

	VolumeUp = function( self, ent )
		local volume = ent:GetCLVolume()

		volume = math.Clamp(volume + 0.2, 0, 1)
		volume = math.Round(volume, 2)

		ent:SetCLVolume(volume)
	end,

	VolumeDown = function( self, ent )
		local volume = ent:GetCLVolume()

		volume = math.Clamp(volume - 0.2, 0, 1)
		volume = math.Round(volume, 2)

		ent:SetCLVolume(volume)
	end,

	Think = function( self, optionPanel, ent )
		local volume = ent:GetCLVolume()
		local isMuted = ent:GetCLMute()

		local label = string.format("%s: %3i%%", self.MenuLabel, volume * 100)

		optionPanel:SetText(label)

		local upButton = optionPanel._upButton
		local downButton = optionPanel._downButton
		local muteButton = optionPanel._muteButton
		local unmuteButton = optionPanel._unmuteButton

		if IsValid(upButton) then
			upButton:SetEnabled(volume < 1)
		end

		if IsValid(downButton) then
			downButton:SetEnabled(volume > 0)
		end

		if IsValid(muteButton) then
			muteButton:SetVisible(not isMuted)
		end

		if IsValid(unmuteButton) then
			unmuteButton:SetVisible(isMuted)
		end
	end,

	MenuOpen = g_VolumeMenuOpen,
})

LIB.AddSubOption("serverside_title", {
	MenuLabel = "Entity Options",
	Order = 200,
	PrependSpacer = true,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end

		local allowed = LIB.CheckFilters(
			{
				"serverside_volume",
			},
			ent,
			ply
		)

		return allowed
	end,

	Action = function( self, ent )
	end,

	OnCreate = g_titleOnCreate,
})

LIB.AddSubOption("playlist_controls", {
	MenuLabel = "",
	Order = 210,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		if not LIB.CanProperty("playlist_controls", ent, ply ) then return false end

		local stream = ent:GetStreamObject()
		if not IsValid(stream) then
			return false
		end

		local hasPlaylist = ent:GetHasPlaylist()
		local url = ent:GetStreamURL()

		if not hasPlaylist and url == "" then
			return false
		end

		return true
	end,

	Action = function( self, ent )
	end,

	DoControl = function( self, ent, mode )
		self:MsgStart()
			net.WriteEntity( ent )
			net.WriteUInt( mode, 4 )
		self:MsgEnd()
	end,

	Play = function( self, ent )
		local stream = ent:GetStreamObject()

		if stream:IsKilled() then
			stream:ReviveStream()
		end

		self:DoControl(ent, g_mode_play)
	end,

	Pause = function( self, ent )
		self:DoControl(ent, g_mode_pause)
	end,

	Stop = function( self, ent )
		self:DoControl(ent, g_mode_stop)
	end,

	PreviousTrack = function( self, ent )
		self:DoControl(ent, g_mode_previous_track)
	end,

	NextTrack = function( self, ent )
		self:DoControl(ent, g_mode_next_track)
	end,

	Rewind = function( self, ent )
		self:DoControl(ent, g_mode_rewind)
	end,

	FastForward = function( self, ent )
		self:DoControl(ent, g_mode_fastforward)
	end,

	Think = function( self, optionPanel, ent )
		local stream = ent:GetStreamObject()
		if not IsValid(stream) then return end

		local isPlayMode = stream:IsPlayMode()
		local isStopMode = stream:IsStopMode()

		if stream:IsKilled() then
			isPlayMode = false
			isStopMode = true
		end

		local isEndless = stream:IsEndless()

		local hasPlaylist = ent:GetHasPlaylist()

		local playButton = optionPanel._playButton
		local pauseButton = optionPanel._pauseButton
		local stopButton = optionPanel._stopButton
		local previousTrackButton = optionPanel._previousTrackButton
		local nextTrackButton = optionPanel._nextTrackButton
		local rewindButton = optionPanel._rewindButton
		local fastForwardButton = optionPanel._fastForwardButton

		if IsValid(stopButton) then
			stopButton:SetEnabled(not isStopMode)
		end

		if IsValid(playButton) then
			playButton:SetVisible(not isPlayMode)
		end

		if IsValid(pauseButton) then
			pauseButton:SetVisible(isPlayMode)
		end

		if IsValid(previousTrackButton) then
			previousTrackButton:SetEnabled(hasPlaylist)
		end

		if IsValid(nextTrackButton) then
			nextTrackButton:SetEnabled(hasPlaylist)
		end

		if IsValid(rewindButton) then
			rewindButton:SetEnabled(not isEndless)
		end

		if IsValid(fastForwardButton) then
			fastForwardButton:SetEnabled(not isEndless)
		end
	end,

	MenuOpen = g_PlaylistControlsMenuOpen,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()
		local mode = net.ReadUInt(4)

		if not self:Filter( ent, ply ) then return end

		local stream = ent:GetStreamObject()

		if mode == g_mode_play then
			local hasEnded = stream:HasEnded()
			local isPauseMode = stream:IsPauseMode()

			if isPauseMode and not hasEnded then
				stream:Play(hasEnded)
			else
				ent:PlayFromCurrentPlaylistItem()
			end
		elseif mode == g_mode_pause then
			stream:Pause()
		elseif mode == g_mode_stop then
			stream:Stop()
		elseif mode == g_mode_previous_track then
			ent:PlayPreviousPlaylistItem()
		elseif mode == g_mode_next_track then
			ent:PlayNextPlaylistItem()
		elseif mode == g_mode_rewind then
			local length = stream:GetMasterLength()

			if length > 0 then
				local time = stream:GetMasterTime()
				local newtime = math.Clamp(time - 10, 0, length - 0.1)

				stream:SetTime(newtime, true)
			end
		elseif mode == g_mode_fastforward then
			local length = stream:GetMasterLength()

			if length > 0 then
				local time = stream:GetMasterTime()
				local newtime = math.Clamp(time + 10, 0, length - 0.1)

				stream:SetTime(newtime, true)
			end
		end
	end
})

LIB.AddSubOption("serverside_volume", {
	MenuLabel = "Volume",
	Order = 220,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		if not LIB.CanProperty("serverside_volume", ent, ply ) then return false end

		return true
	end,

	Action = function( self, ent )
	end,

	DoControl = function( self, ent, mode )
		self:MsgStart()
			net.WriteEntity( ent )
			net.WriteUInt( mode, 4 )
		self:MsgEnd()
	end,

	Mute = function( self, ent )
		self:DoControl(ent, g_mode_mute)
	end,

	Unmute = function( self, ent )
		self:DoControl(ent, g_mode_unmute)
	end,

	VolumeUp = function( self, ent )
		self:DoControl(ent, g_mode_volume_up)
	end,

	VolumeDown = function( self, ent )
		self:DoControl(ent, g_mode_volume_down)
	end,

	Think = function( self, optionPanel, ent )
		local volume = ent:GetVolume()
		local isMuted = ent:GetSVMute()

		local label = string.format("%s: %3i%%", self.MenuLabel, volume * 100)

		optionPanel:SetText(label)

		local upButton = optionPanel._upButton
		local downButton = optionPanel._downButton
		local muteButton = optionPanel._muteButton
		local unmuteButton = optionPanel._unmuteButton

		if IsValid(upButton) then
			upButton:SetEnabled(volume < 1)
		end

		if IsValid(downButton) then
			downButton:SetEnabled(volume > 0)
		end

		if IsValid(muteButton) then
			muteButton:SetVisible(not isMuted)
		end

		if IsValid(unmuteButton) then
			unmuteButton:SetVisible(isMuted)
		end
	end,

	MenuOpen = g_VolumeMenuOpen,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()
		local mode = net.ReadUInt(4)

		if not self:Filter( ent, ply ) then return end

		if mode == g_mode_mute then
			ent:SetSVMute(true)
		elseif mode == g_mode_unmute then
			ent:SetSVMute(false)
		elseif mode == g_mode_volume_up then
			local volume = ent:GetVolume()

			volume = math.Clamp(volume + 0.2, 0, 1)
			volume = math.Round(volume, 2)

			ent:SetVolume(volume)
		elseif mode == g_mode_volume_down then
			local volume = ent:GetVolume()

			volume = math.Clamp(volume - 0.2, 0, 1)
			volume = math.Round(volume, 2)

			ent:SetVolume(volume)
		end
	end
})

LIB.AddSubOption("admin_title", {
	MenuLabel = "Admin Options",
	Order = 300,
	PrependSpacer = true,

	Filter = function( self, ent, ply )
		if not LIBUtil.IsAdmin( ply ) then return false end
		if not LIB.CanBeTargeted( ent, ply ) then return false end

		local url = ent:GetStreamURL()
		if url ~= "" then
			local context = StreamRadioLib.Whitelist.BuildContext(ent, ply)

			-- Trigger updating the cache in the background if needed
			StreamRadioLib.Whitelist.IsAllowedAsync(url, context)
		end

		local allowed = LIB.CheckFilters(
			{
				"admin_whitelist_add",
				"admin_whitelist_remove",
			},
			ent,
			ply
		)

		return allowed
	end,

	Action = function( self, ent )
	end,

	OnCreate = g_titleOnCreate,
})

LIB.AddSubOption("admin_whitelist_add", {
	MenuLabel = "Add to quick whitelist",
	Order = 310,
	MenuIcon = StreamRadioLib.GetPNGIconPath("shield_add"),
	PrependSpacer = true,

	Filter = function( self, ent, ply )
		if not LIBUtil.IsAdmin( ply ) then return false end
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		if not StreamRadioLib.IsUrlWhitelistEnabled() then return false end

		local url = ent:GetStreamURL()
		if url == "" then return false end

		if LIBUrl.IsOfflineURL(url) then
			return false
		end

		local context = StreamRadioLib.Whitelist.BuildContext(ent, ply)
		local result, blockedByHook = StreamRadioLib.Whitelist.IsAllowedSync(url, context)

		if blockedByHook then return false end
		if result then return false end

		return true
	end,

	Action = function( self, ent )
		local url = ent:GetStreamURL()
		StreamRadioLib.Whitelist.QuickWhitelistAdd(url)

		-- Trigger updating the cache in the background if needed
		local context = StreamRadioLib.Whitelist.BuildContext(ent)
		StreamRadioLib.Whitelist.IsAllowedAsync(url, context)
	end,
})

LIB.AddSubOption("admin_whitelist_remove", {
	MenuLabel = "Remove from quick whitelist",
	Order = 320,
	MenuIcon = StreamRadioLib.GetPNGIconPath("shield_delete"),
	PrependSpacer = true,

	Filter = function( self, ent, ply )
		if not LIBUtil.IsAdmin( ply ) then return false end
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		if not StreamRadioLib.IsUrlWhitelistEnabled() then return false end

		local url = ent:GetStreamURL()
		if url == "" then return false end

		if LIBUrl.IsOfflineURL(url) then
			return false
		end

		local context = StreamRadioLib.Whitelist.BuildContext(ent, ply)
		local result, blockedByHook = StreamRadioLib.Whitelist.IsAllowedSync(url, context)

		if blockedByHook then return false end
		if not result then return false end

		return true
	end,

	Action = function( self, ent )
		local url = ent:GetStreamURL()
		StreamRadioLib.Whitelist.QuickWhitelistRemove(url)

		-- Trigger updating the cache in the background if needed
		local context = StreamRadioLib.Whitelist.BuildContext(ent)
		StreamRadioLib.Whitelist.IsAllowedAsync(url, context)
	end,
})

return true

