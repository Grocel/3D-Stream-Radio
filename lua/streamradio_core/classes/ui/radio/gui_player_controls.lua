if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

local g_mat_play = StreamRadioLib.GetPNGIcon("control_play")
local g_mat_pause = StreamRadioLib.GetPNGIcon("control_pause")
local g_mat_stop = StreamRadioLib.GetPNGIcon("control_stop")
local g_mat_back = StreamRadioLib.GetPNGIcon("control_start")
local g_mat_forward = StreamRadioLib.GetPNGIcon("control_end")
local g_mat_volumedown = StreamRadioLib.GetPNGIcon("sound_delete")
local g_mat_volumeup = StreamRadioLib.GetPNGIcon("sound_add")

local g_mat_playback_modes = {
	[StreamRadioLib.PLAYBACK_LOOP_MODE_NONE] = StreamRadioLib.GetPNGIcon("arrow_not_refresh", true),
	[StreamRadioLib.PLAYBACK_LOOP_MODE_SONG] = StreamRadioLib.GetPNGIcon("arrow_refresh"),
	[StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST] = StreamRadioLib.GetPNGIcon("table_refresh"),
}

local g_tooltip_playback_modes = {
	[StreamRadioLib.PLAYBACK_LOOP_MODE_NONE] = "Change loop mode\n(currently: No loop)",
	[StreamRadioLib.PLAYBACK_LOOP_MODE_SONG] = "Change loop mode\n(currently: Song loop)",
	[StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST] = "Change loop mode\n(currently: Playlist loop)",
}

local g_next_playback_modes = {
	[StreamRadioLib.PLAYBACK_LOOP_MODE_NONE] = StreamRadioLib.PLAYBACK_LOOP_MODE_SONG,
	[StreamRadioLib.PLAYBACK_LOOP_MODE_SONG] = StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST,
	[StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST] = StreamRadioLib.PLAYBACK_LOOP_MODE_NONE,
}

local function FormatTime(seconds)
	seconds = tonumber(seconds or 0) or 0

	local rs, ms = math.modf(seconds)
	ms = math.floor(ms * 100)

	local s = rs % 60
	local m = math.floor((rs / 60) % 60)

	local rh = math.floor(rs / 3600)
	local h = rh % 24
	local d = math.floor(rh / 24)

	return d, h, m, s, ms
end

local function GetTimeFormated(seconds, timeScale)
	seconds = tonumber(seconds or 0) or 0
	timeScale = tonumber(timeScale or 0) or 0

	if timeScale <= 0 then
		timeScale = seconds
	end

	local d, h, m, s, ms = FormatTime(seconds)

	local scale_1m = 60
	local scale_10m = scale_1m * 10
	local scale_1h = scale_1m * 60
	local scale_10h = scale_1h * 10
	local scale_1d = scale_1h * 24

	if timeScale < scale_1h then
		return string.format("%01i:%02i.%02i", m, s, ms)
	end

	if timeScale < scale_1d then
		return string.format("%01i:%02i:%02i", h, m, s)
	end

	return string.format("%01i:%02i:%02i:%02i", d, h, m, s)
end

local function FormatTimeleft(time, len)
	time = time or 0
	len = len or 0

	local timef = GetTimeFormated(time, len)
	local lenf = nil

	if len > 0 then
		lenf = GetTimeFormated(len)
	end

	if lenf then
		return string.format("%s / %s" , timef, lenf)
	end

	return timef
end

function CLASS:Create()
	BASE.Create(self)

	self.StreamOBJ = nil

	self.PlayPauseButton = self:AddPanelByClassname("button", true)
	self.PlayPauseButton:SetIcon(g_mat_play)
	self.PlayPauseButton:SetName("play")
	self.PlayPauseButton:SetNWName("pl")
	self.PlayPauseButton:SetSkinIdentifyer("button")
	self.PlayPauseButton.DoClick = function()
		if not IsValid(self.StreamOBJ) then return end
		local isPlayMode = self.StreamOBJ:IsPlayMode()

		if isPlayMode then
			self:CallHook("OnPause")
			self.StreamOBJ:Pause()
			return
		end

		self:TriggerPlay()
	end

	self.BackButton = self:AddPanelByClassname("button", true)
	self.BackButton:SetIcon(g_mat_back)
	self.BackButton:SetName("back")
	self.BackButton:SetNWName("bk")
	self.BackButton:SetSkinIdentifyer("button")
	self.BackButton:SetTooltip("Go to previous playlist track")
	self.BackButton.DoClick = function()
		self:CallHook("OnPlaylistBack")
	end

	self.ForwardButton = self:AddPanelByClassname("button", true)
	self.ForwardButton:SetIcon(g_mat_forward)
	self.ForwardButton:SetName("forward")
	self.ForwardButton:SetNWName("fw")
	self.ForwardButton:SetSkinIdentifyer("button")
	self.ForwardButton:SetTooltip("Go to next playlist track")
	self.ForwardButton.DoClick = function()
		self:CallHook("OnPlaylistForward")
	end

	self.StopButton = self:AddPanelByClassname("button", true)
	self.StopButton:SetIcon(g_mat_stop)
	self.StopButton:SetName("stop")
	self.StopButton:SetNWName("sp")
	self.StopButton:SetSkinIdentifyer("button")
	self.StopButton:SetTooltip("Stop playback")
	self.StopButton.DoClick = function()
		if not IsValid(self.StreamOBJ) then return end
		self:CallHook("OnStop")
		self.StreamOBJ:Stop()
	end

	self.VolumeDownButton = self:AddPanelByClassname("button", true)
	self.VolumeDownButton:SetIcon(g_mat_volumedown)
	self.VolumeDownButton:SetName("volumedown")
	self.VolumeDownButton:SetNWName("vdn")
	self.VolumeDownButton:SetSkinIdentifyer("button")
	self.VolumeDownButton:SetTooltip("Decrease volume")
	self.VolumeDownButton.OnMousePressed = function()
		if not IsValid(self.StreamOBJ) then return end

		local newvol = self.StreamOBJ:GetVolume()
		newvol = newvol - 0.1
		newvol = math.Clamp(newvol, 0, 1)

		self.StreamOBJ:SetVolume(newvol)
		self:CallHook("OnVolumeDown", newvol)
	end

	self.VolumeUpButton = self:AddPanelByClassname("button", true)
	self.VolumeUpButton:SetIcon(g_mat_volumeup)
	self.VolumeUpButton:SetName("volumeup")
	self.VolumeUpButton:SetNWName("vup")
	self.VolumeUpButton:SetSkinIdentifyer("button")
	self.VolumeUpButton:SetTooltip("Increase volume")
	self.VolumeUpButton.OnMousePressed = function()
		if not IsValid(self.StreamOBJ) then return end

		local newvol = self.StreamOBJ:GetVolume()
		newvol = newvol + 0.1
		newvol = math.Clamp(newvol, 0, 1)

		self.StreamOBJ:SetVolume(newvol)
		self:CallHook("OnVolumeUp", newvol)
	end

	self.VolumeUpButton.DoClick = function(this)
		this.IsPressed = true
		this.LastClickTime = RealTime()
		this:OnMousePressed()
	end

	self.VolumeUpButton.OnMouseReleased = function(this)
		this.IsPressed = nil
		this.LastClickTime = nil
	end

	self.VolumeUpButton.Think = function(this)
		if not this.IsPressed then
			return
		end

		local lastclicktime = this.LastClickTime or 0
		local clickdistance = RealTime() - lastclicktime

		if clickdistance <= 0.5 then
			return
		end

		this.LastClickTime = RealTime() - 0.45
		this:CallHook("OnMousePressed")
	end

	self.VolumeDownButton.DoClick = self.VolumeUpButton.DoClick
	self.VolumeDownButton.OnMouseReleased = self.VolumeUpButton.OnMouseReleased
	self.VolumeDownButton.Think = self.VolumeUpButton.Think

	self.PlaybackLoopModeButton = self:AddPanelByClassname("button", true)
	self.PlaybackLoopModeButton:SetName("playback-mode")
	self.PlaybackLoopModeButton:SetNWName("pm")
	self.PlaybackLoopModeButton:SetSkinIdentifyer("button")

	self.PlaybackLoopModeButton.DoClick = function()
		local loopMode = self._currentLoopMode or StreamRadioLib.PLAYBACK_LOOP_MODE_NONE
		local newLoopMode = g_next_playback_modes[loopMode] or StreamRadioLib.PLAYBACK_LOOP_MODE_NONE

		self:CallHook("OnPlaybackLoopModeChange", newLoopMode)
	end

	self.Buttons = {}
	table.insert(self.Buttons, self.PlayPauseButton)
	table.insert(self.Buttons, self.BackButton)
	table.insert(self.Buttons, self.ForwardButton)
	table.insert(self.Buttons, self.StopButton)
	table.insert(self.Buttons, self.VolumeDownButton)
	table.insert(self.Buttons, self.VolumeUpButton)
	table.insert(self.Buttons, self.PlaybackLoopModeButton)

	self.PlayBar = self:AddPanelByClassname("progressbar", true)
	self.PlayBar:SetName("progressbar")
	self.PlayBar:SetNWName("pbar")
	self.PlayBar:SetSkinIdentifyer("progressbar")
	self.PlayBar.FractionChangeText = function(this, v)
		if not IsValid(self.StreamOBJ) then return end

		if self.StreamOBJ:GetMuted() then
			return "Muted..."
		end

		if self.StreamOBJ:IsBuffering() then
			return "Buffering..."
		end

		if self.StreamOBJ:IsStopMode() then
			return "Stopped..."
		end

		if self.StreamOBJ:GetError() ~= 0 then
			return "Error!"
		end

		if self.StreamOBJ:IsDownloading() then
			return "Downloading..."
		end

		if self.StreamOBJ:IsLoading() then
			return "Loading..."
		end

		local len = self.StreamOBJ:GetLength()
		local time = self.StreamOBJ:GetTime()

		return FormatTimeleft(time, len)
	end

	self.PlayBar.OnFractionChangeEdit = function(this, v)
		if not IsValid(self.StreamOBJ) then return end

		local noise = math.random() * 0.00001
		local len = self.StreamOBJ:GetMasterLength()

		-- Set a fake value that is minimal off target to force a change detection when the right one is set
		self.StreamOBJ:SetTime(len * v - noise, true)
	end

	self.State = self:CreateListener({
		PlaylistEnabled = true,
	}, function(this, k, v)
		if IsValid(self.BackButton) then
			self.BackButton:SetVisible(v)
		end

		if IsValid(self.ForwardButton) then
			self.ForwardButton:SetVisible(v)
		end

		self:UpdatePlaybackLoopMode(self._currentLoopMode)

		self:SetNWBool(k, v)
		self:ApplyNetworkVars()
		self:InvalidateLayout()
	end)

	self:UpdatePlaybackLoopMode()
	self:UpdatePlayBar()

	self.PlayBar:SetSize(1,1)
	self:QueueCall("ActivateNetworkedMode")

	if CLIENT then
		self:StartSuperThink()
	end

	self:InvalidateLayout()
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	local w, h = self:GetClientSize()

	local margin = self:GetMargin()
	local minbarw = (h + margin) * 1.618 * 2
	local buttoncount = 0
	local buttonw = h
	local buttonh = h
	local wpos = 0
	local hpos = 0
	local hasplaybar = IsValid(self.PlayBar) and self.PlayBar.Layout.Visible
	local buttons = self.Buttons or {}

	for k, v in pairs(buttons) do
		if not IsValid(v) then continue end
		if not v.Layout.Visible then continue end

		wpos = wpos + buttonw + margin
		buttoncount = buttoncount + 1
	end

	local barw = w - wpos
	local oneline = hasplaybar and (barw > minbarw or w > ((h + margin) * buttoncount))
	local hasbuttons = buttoncount > 0

	wpos = 0
	if oneline then
		if barw < minbarw and hasbuttons then
			barw = 0
			hasplaybar = false
			buttonw = (w - margin * (buttoncount - 1)) / buttoncount
		end

		for k, v in pairs(buttons) do
			if not IsValid(v) then continue end
			if not v.Layout.Visible then continue end

			v:SetSize(buttonw, buttonh)
			v:SetPos(wpos, hpos)

			wpos = wpos + buttonw + margin
		end
	else
		buttonw = 0
		barw = w

		if hasbuttons then
			buttonw = (w - margin * (buttoncount - 1)) / buttoncount
			if hasplaybar then
				buttonh = (h - margin) / 2
			end
		end

		hpos = hasplaybar and buttonh + margin or 0

		for k, v in pairs(buttons) do
			if not IsValid(v) then continue end
			if not v.Layout.Visible then continue end

			v:SetSize(buttonw, buttonh)
			v:SetPos(wpos, hpos)

			wpos = wpos + buttonw + margin
		end

		wpos = 0
	end

	local barh = h
	if hasbuttons and not oneline then
		barh = buttonh
	end

	if IsValid(self.PlayBar) then
		self.PlayBar:SetSize(barw, barh)
		self.PlayBar:SetPos(wpos, 0)
	end
end

function CLASS:Remove()
	if IsValid(self.StreamOBJ) then
		self.StreamOBJ:RemoveEvent("OnTrackEnd", self:GetID())
		self.StreamOBJ:RemoveEvent("OnVolumeChange", self:GetID())
		self.StreamOBJ:RemoveEvent("OnPlayModeChange", self:GetID())

		if CLIENT then
			self.StreamOBJ:RemoveEvent("OnSeekingStart", self:GetID())
			self.StreamOBJ:RemoveEvent("OnSeekingEnd", self:GetID())
			self.StreamOBJ:RemoveEvent("OnMute", self:GetID())
			self.StreamOBJ:RemoveEvent("OnClose", self:GetID())

			self.StreamOBJ:RemoveEvent("OnSearch", self:GetID())
			self.StreamOBJ:RemoveEvent("OnConnect", self:GetID())
			self.StreamOBJ:RemoveEvent("OnError", self:GetID())
		end
	end

	BASE.Remove(self)
end

function CLASS:UpdateButtons()
	local StreamOBJ = self.StreamOBJ
	if not IsValid(StreamOBJ) then return end

	local isPlayMode = StreamOBJ:IsPlayMode()
	local isStopMode = StreamOBJ:IsStopMode()
	local syncMode = self:GetSyncMode()

	if IsValid(self.PlayPauseButton) then
		self.PlayPauseButton:SetIcon(isPlayMode and g_mat_pause or g_mat_play)
		self.PlayPauseButton:SetTooltip(isPlayMode and "Pause playback" or "Start playback")
		self.PlayPauseButton:SetDisabled(syncMode)
	end

	if IsValid(self.StopButton) then
		self.StopButton:SetDisabled(isStopMode or syncMode)
	end
end

function CLASS:UpdatePlayBar()
	if SERVER then return end

	if not IsValid(self.PlayBar) then
		return
	end

	if not self.PlayBar:IsVisible() then
		return
	end

	self.PlayBar:UpdateText()
end

function CLASS:SetStream(stream)
	self.StreamOBJ = stream

	self:UpdateFromStream()
	self:UpdateButtons()
	self:UpdatePlayBar()

	if not IsValid(self.StreamOBJ) then return end

	self.StreamOBJ:SetEvent("OnTrackEnd", self:GetID(), function()
		if not IsValid(self) then return end
		if not IsValid(self.StreamOBJ) then return end

		self:QueueCall("UpdatePlayBar")
		self:QueueCall("UpdateButtons")

		if self:GetSyncMode() then return end
		if not self.State.PlaylistEnabled then return end
		if self._currentLoopMode ~= StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST then return end

		self:CallHook("OnPlaylistForward")
		self.StreamOBJ:Play()
	end)

	local function OnVolumeChange(this, vol)
		if not IsValid(self) then return end

		if IsValid(self.VolumeUpButton) then
			self.VolumeUpButton:SetDisabled(vol >= 1)
		end

		if IsValid(self.VolumeDownButton) then
			self.VolumeDownButton:SetDisabled(vol <= 0)
		end
	end

	local function OnPlayModeChange(this, mode)
		if not IsValid(self) then return end

		local StreamOBJ = self.StreamOBJ
		if not IsValid(StreamOBJ) then return end

		local isPlayMode = StreamOBJ:IsPlayMode()
		local isStopMode = StreamOBJ:IsStopMode()

		if IsValid(self.PlayPauseButton) then
			self.PlayPauseButton:SetIcon(isPlayMode and g_mat_pause or g_mat_play)
			self.PlayPauseButton:SetTooltip(isPlayMode and "Pause playback" or "Start playback")
		end

		if IsValid(self.StopButton) then
			self.StopButton:SetDisabled(isStopMode or self:GetSyncMode())
		end

		self:QueueCall("UpdatePlayBar")
		self:QueueCall("UpdateButtons")
	end

	self.StreamOBJ:SetEvent("OnVolumeChange", self:GetID(), OnVolumeChange)
	self.StreamOBJ:SetEvent("OnPlayModeChange", self:GetID(), OnPlayModeChange)

	if CLIENT then
		local function UpdatePlayBar()
			if not IsValid(self) then
				return false
			end

			self:QueueCall("UpdateButtons")
			self:QueueCall("UpdatePlayBar")

			return true
		end

		self.StreamOBJ:SetEvent("OnSeekingStart", self:GetID(), UpdatePlayBar)
		self.StreamOBJ:SetEvent("OnSeekingEnd", self:GetID(), UpdatePlayBar)
		self.StreamOBJ:SetEvent("OnMute", self:GetID(), UpdatePlayBar)
		self.StreamOBJ:SetEvent("OnClose", self:GetID(), UpdatePlayBar)

		self.StreamOBJ:SetEvent("OnDownload", self:GetID(), UpdatePlayBar)
		self.StreamOBJ:SetEvent("OnRetry", self:GetID(), UpdatePlayBar)
		self.StreamOBJ:SetEvent("OnSearch", self:GetID(), UpdatePlayBar)
		self.StreamOBJ:SetEvent("OnConnect", self:GetID(), UpdatePlayBar)
		self.StreamOBJ:SetEvent("OnError", self:GetID(), UpdatePlayBar)
	end

	OnVolumeChange(self.StreamOBJ, self.StreamOBJ:GetVolume())
	OnPlayModeChange(self.StreamOBJ)
end

function CLASS:GetStream()
	return self.StreamOBJ
end

function CLASS:UpdateFromStream()
	local StreamOBJ = self.StreamOBJ
	if not IsValid(StreamOBJ) then return end

	local len = StreamOBJ:GetLength()
	local time = StreamOBJ:GetTime()

	local isEndlessOrNoStream = StreamOBJ:IsEndless() or StreamOBJ:IsLoading() or StreamOBJ:GetError() ~= 0 or StreamOBJ:GetMuted()

	if IsValid(self.PlayBar) and self.PlayBar:IsVisible() then
		if isEndlessOrNoStream then
			self.PlayBar:SetFraction(0)
			self.PlayBar:SetAllowFractionEdit(false)
			self.PlayBar:SetDisabled(self:GetSyncMode())
		else
			self.PlayBar:SetFraction(time / len)
			self.PlayBar:SetAllowFractionEdit(StreamOBJ:CanSeek())
			self.PlayBar:SetDisabled(self:GetSyncMode() or not StreamOBJ:CanSeek())
		end
	end
end

function CLASS:ShouldPerformRerender()
	if SERVER then return false end
	if not IsValid(self.StreamOBJ) then return false end

	if not self.StreamOBJ:IsPlaying() then
		return false
	end

	return true
end

function CLASS:SuperThink()
	if SERVER then return end
	if not IsValid(self.StreamOBJ) then return end

	if not self:IsSeen() then return end
	if not self:IsVisible() then return end

	self:UpdateFromStream()

	if not self:ShouldPerformRerender() then return end

	self:UpdatePlayBar()
	self:PerformRerender(true)
end

function CLASS:EnablePlaylist(bool)
	self.State.PlaylistEnabled = bool
end

function CLASS:IsPlaylistEnabled()
	return self.State.PlaylistEnabled or false
end

function CLASS:TriggerPlay()
	if not IsValid(self.StreamOBJ) then return end
	local isPlayMode = self.StreamOBJ:IsPlayMode()

	if isPlayMode then
		return
	end

	self:CallHook("OnPlay")
	self.StreamOBJ:Play(self.StreamOBJ:HasEnded())
end

function CLASS:UpdatePlaybackLoopMode(loopMode)
	loopMode = loopMode or StreamRadioLib.PLAYBACK_LOOP_MODE_NONE
	self._currentLoopMode = loopMode

	if IsValid(self.PlaybackLoopModeButton) then
		self.PlaybackLoopModeButton:SetIcon(g_mat_playback_modes[loopMode])
		self.PlaybackLoopModeButton:SetTooltip(g_tooltip_playback_modes[loopMode])

		local antiSpamTime = 1

		self.PlaybackLoopModeButton:SetDisabled(true)

		self:TimerOnce("PlaybackLoopModeButtonAntiSpam", antiSpamTime, function()
			if not IsValid(self.PlaybackLoopModeButton) then
				return
			end

			self.PlaybackLoopModeButton:SetDisabled(false)
		end)
	end

	local StreamOBJ = self.StreamOBJ

	if not IsValid(StreamOBJ) then
		return
	end

	if not StreamOBJ:HasEnded() then
		local time = StreamOBJ:GetMasterTime()

		-- make sure we reapply the time between mode changes, so it prevents jumping
		StreamOBJ:SetTime(time, true)
	else
		if loopMode ~= StreamRadioLib.PLAYBACK_LOOP_MODE_NONE then
			self:TriggerPlay()
		end
	end
end

function CLASS:SetSyncMode(bool)
	self._syncmode = bool or false

	if not IsValid(self.StreamOBJ) then return end

	if IsValid(self.BackButton) then
		self.BackButton:SetDisabled(bool)
	end

	if IsValid(self.ForwardButton) then
		self.ForwardButton:SetDisabled(bool)
	end

	if IsValid(self.PlaybackLoopModeButton) then
		self.PlaybackLoopModeButton:SetDisabled(bool)
	end

	if IsValid(self.PlayBar) then
		self.PlayBar:SetDisabled(bool)
	end

	self:UpdateButtons()
	self:UpdatePlayBar()
end

function CLASS:GetSyncMode()
	return self._syncmode or false
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)

	if SERVER then
		self:SetNWBool("PlaylistEnabled", self.State.PlaylistEnabled)
		return
	end

	self:SetNWVarCallback("PlaylistEnabled", "Bool", function(this, nwkey, oldvar, newvar)
		self.State.PlaylistEnabled = newvar
	end)
end

function CLASS:ApplyNetworkVarsInternal()
	BASE.ApplyNetworkVarsInternal(self)

	self.State.PlaylistEnabled = self:GetNWBool("PlaylistEnabled", false)
end
