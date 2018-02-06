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

local function Timeformat(f, u)
	f = f or {}
	u = u or 0

	local ms = f.ms or 0
	local s = f.s or 0
	local m = f.m or 0
	local rh = f.h or 0
	local h = rh % 24
	local d = math.floor(rh / 24)

	if u <= 0 then
		return nil
	end

	if u <= 3 then
		return m, s, ms
	end

	if u == 4 then
		return h, m, s, ms
	end

	return d, h, m, s, ms
end


local function GetTimeformat(timef, lenf)
	lenf = lenf or timef or {}

	local m = lenf.m or 0
	local rh = lenf.h or 0
	local h = rh % 24
	local d = math.floor(rh / 24)

	if d <= 0 then
		if h <= 0 then
			if m >= 10 then
				return "%02i:%02i.%02i", 3
			end

			return "%01i:%02i.%02i", 3
		end

		if h >= 10 then
			return "%02i:%02i:%02i.%02i", 4
		end

		return "%01i:%02i:%02i.%02i", 4
	end

	if d >= 100 then
		return "%03i:%02i:%02i:%02i.%02i", 5
	end

	if d >= 10 then
		return "%02i:%02i:%02i:%02i.%02i", 5
	end

	return "%01i:%02i:%02i:%02i.%02i", 5
end

local function FormatTimeleft(time, len)
	time = time or 0
	len = len or 0

	local timef = string.FormattedTime(time)
	local lenf = nil

	if len > 0 then
		lenf = string.FormattedTime(len)
	end

	local format, units = GetTimeformat(timef, lenf)
	timef = string.format(format, Timeformat(timef, units))

	if lenf then
		lenf = string.format(format, Timeformat(lenf, units))
		return timef .. " / " .. lenf
	end

	return timef
end

function CLASS:Create()
	BASE.Create(self)

	self.StreamOBJ = nil

	self.PlayPauseButton = self:AddPanelByClassname("button", true)
	self.PlayPauseButton:SetIcon(g_mat_play)
	self.PlayPauseButton:SetName("play")
	self.PlayPauseButton:SetSkinIdentifyer("button")
	self.PlayPauseButton.DoClick = function()
		if not IsValid(self.StreamOBJ) then return end
		local isPlayMode = self.StreamOBJ:IsPlayMode()

		if isPlayMode then
			self:CallHook("OnPause")
			self.StreamOBJ:Pause()
			return
		end

		self:CallHook("OnPlay")
		self.StreamOBJ:Play(self.StreamOBJ:HasEnded())
	end

	self.BackButton = self:AddPanelByClassname("button", true)
	self.BackButton:SetIcon(g_mat_back)
	self.BackButton:SetName("back")
	self.BackButton:SetSkinIdentifyer("button")
	self.BackButton:SetToolTip("Go to previous playlist track")
	self.BackButton.DoClick = function()
		self:CallHook("OnPlaylistBack")
	end

	self.ForwardButton = self:AddPanelByClassname("button", true)
	self.ForwardButton:SetIcon(g_mat_forward)
	self.ForwardButton:SetName("forward")
	self.ForwardButton:SetSkinIdentifyer("button")
	self.ForwardButton:SetToolTip("Go to next playlist track")
	self.ForwardButton.DoClick = function()
		self:CallHook("OnPlaylistForward")
	end

	self.StopButton = self:AddPanelByClassname("button", true)
	self.StopButton:SetIcon(g_mat_stop)
	self.StopButton:SetName("stop")
	self.StopButton:SetSkinIdentifyer("button")
	self.StopButton:SetToolTip("Stop playback")
	self.StopButton.DoClick = function()
		if not IsValid(self.StreamOBJ) then return end
		self:CallHook("OnStop")
		self.StreamOBJ:Stop()
	end

	self.VolumeDownButton = self:AddPanelByClassname("button", true)
	self.VolumeDownButton:SetIcon(g_mat_volumedown)
	self.VolumeDownButton:SetName("volumedown")
	self.VolumeDownButton:SetSkinIdentifyer("button")
	self.VolumeDownButton:SetToolTip("Decrease volume")
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

	self.Buttons = {}
	table.insert(self.Buttons, self.PlayPauseButton)
	table.insert(self.Buttons, self.BackButton)
	table.insert(self.Buttons, self.ForwardButton)
	table.insert(self.Buttons, self.StopButton)
	table.insert(self.Buttons, self.VolumeDownButton)
	table.insert(self.Buttons, self.VolumeUpButton)

	self.PlayBar = self:AddPanelByClassname("progressbar", true)
	self.PlayBar:SetName("progressbar")
	self.PlayBar:SetSkinIdentifyer("progressbar")
	self.PlayBar.FractionChangeText = function(this, v)
		if not IsValid(self.StreamOBJ) then return end

		if self.StreamOBJ:GetMuted() then
			return "Muted..."
		end

		if self.StreamOBJ:IsBuffering() then
			return "Buffering..."
		end

		if self.StreamOBJ:IsSeeking() then
			return "Seeking..."
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

		local len = self.StreamOBJ:GetMasterLength()
		self.StreamOBJ:SetTime(len * v, true)
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

		self:SetNWBool(k, v)
		self:ApplyNetworkVars()
		self:InvalidateLayout()
	end)


	self.PlayBar:SetSize(1,1)
	self:QueueCall("ActivateNetworkedMode")
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
	end

	BASE.Remove(self)
end

function CLASS:SetStream(stream)
	self.StreamOBJ = stream
	self:UpdateFromStream()

	if IsValid(self.PlayBar) and self.PlayBar:IsVisible() then
		self.PlayBar:UpdateText()
	end

	if not IsValid(self.StreamOBJ) then return end

	self.StreamOBJ:SetEvent("OnTrackEnd", self:GetID(), function()
		if not IsValid(self) then return end
		if not IsValid(self.StreamOBJ) then return end

		if not self.State.PlaylistEnabled then return end

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

		local isPlayMode = self.StreamOBJ:IsPlayMode()
		local isStopMode = self.StreamOBJ:IsStopMode()

		if IsValid(self.PlayPauseButton) then
			self.PlayPauseButton:SetIcon(isPlayMode and g_mat_pause or g_mat_play)
			self.PlayPauseButton:SetToolTip(isPlayMode and "Pause playback" or "Start playback")
		end

		if IsValid(self.StopButton) then
			self.StopButton:SetDisabled(isStopMode or self._syncmode)
		end
	end

	self.StreamOBJ:SetEvent("OnVolumeChange", self:GetID(), OnVolumeChange)
	self.StreamOBJ:SetEvent("OnPlayModeChange", self:GetID(), OnPlayModeChange)

	OnVolumeChange(self.StreamOBJ, self.StreamOBJ:GetVolume())
	OnPlayModeChange(self.StreamOBJ)
end

function CLASS:GetStream()
	return self.StreamOBJ
end

function CLASS:UpdateFromStream()
	if not IsValid(self.StreamOBJ) then return end

	local len = self.StreamOBJ:GetLength()
	local time = self.StreamOBJ:GetTime()

	if IsValid(self.PlayBar) and self.PlayBar:IsVisible() then
		if
			self.StreamOBJ:IsEndless() or self.StreamOBJ:IsLoading() or
			self.StreamOBJ:GetError() ~= 0 or self.StreamOBJ:GetMuted()
		then
			self.PlayBar:SetFraction(0)
			self.PlayBar:SetAllowFractionEdit(false)
		else
			self.PlayBar:SetFraction(time / len)
			self.PlayBar:SetAllowFractionEdit(not self.StreamOBJ:IsBlockStreamed())
		end

		self.PlayBar:UpdateText()
	end
end

function CLASS:EnablePlaylist(bool)
	if CLIENT then return end
	self.State.PlaylistEnabled = bool
end

function CLASS:IsPlaylistEnabled(bool)
	if CLIENT then return end
	return self.State.PlaylistEnabled or false
end

function CLASS:SetSyncMode(bool)
	self._syncmode = bool or false

	if not IsValid(self.StreamOBJ) then return end

	if IsValid(self.PlayPauseButton) then
		self.PlayPauseButton:SetDisabled(bool)
	end

	if IsValid(self.StopButton) then
		self.StopButton:SetDisabled(self.StreamOBJ:IsStopMode() and bool)
	end

	if IsValid(self.BackButton) then
		self.BackButton:SetDisabled(bool)
	end

	if IsValid(self.ForwardButton) then
		self.ForwardButton:SetDisabled(bool)
	end

	if IsValid(self.PlayBar) then
		self.PlayBar:SetDisabled(bool)
	end
end

function CLASS:GetSyncMode()
	return self._syncmode or  false
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)

	if SERVER then
		self:SetNWBool("PlaylistEnabled", self.State.PlaylistEnabled)
		return
	end

	self:SetNWVarProxy("PlaylistEnabled", function(this, nwkey, oldvar, newvar)
		self.State.PlaylistEnabled = newvar
	end)
end

function CLASS:ApplyNetworkVarsInternal()
	BASE.ApplyNetworkVarsInternal(self)

	self.State.PlaylistEnabled = self:GetNWBool("PlaylistEnabled", false)
end
