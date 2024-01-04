local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local LIBNetwork = StreamRadioLib.Network
local LIBError = StreamRadioLib.Error
local LIBUtil = StreamRadioLib.Util
local LIBError = StreamRadioLib.Error

local emptyTableSafe = LIBUtil.EmptyTableSafe

local BASE = CLASS:GetBaseClass()

local g_mat_closebutton = StreamRadioLib.GetPNGIcon("door_in")

function CLASS:Create()
	BASE.Create(self)

	self.HeaderPanel = self:AddPanelByClassname("shadow_panel", true)
	self.HeaderPanel:SetSize(1, 40)
	self.HeaderPanel:SetName("header")
	self.HeaderPanel:SetNWName("hdr")
	self.HeaderPanel:SetSkinIdentifyer("header")

	self.HeaderText = self.HeaderPanel:CreateText("label_fade")
	self.HeaderPanel:SetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	self.SpectrumPanel = self:AddPanelByClassname("radio/gui_player_spectrum", true)
	self.SpectrumPanel:SetSize(1, 1)
	self.SpectrumPanel:SetName("spectrum")
	self.SpectrumPanel:SetNWName("spc")
	self.SpectrumPanel:SetSkinIdentifyer("spectrum")

	self.VolumePanel = self.SpectrumPanel:AddPanelByClassname("shadow_panel")
	self.VolumePanel:SetSize(1, 60)
	self.VolumePanel:SetName("volume")
	self.VolumePanel:SetNWName("vol")
	self.VolumePanel:SetSkinIdentifyer("volume")
	self.VolumePanel:SetShadowWidth(0)
	self.VolumePanel:SetColor(Color(128, 128, 128, 160))
	self.VolumePanel.SkinAble = false
	self.VolumePanel:SetZPos(200)
	self.VolumePanel:Close()

	self.VolumeBar = self.VolumePanel:AddPanelByClassname("progressbar", true)
	self.VolumeBar:SetName("progressbar")
	self.VolumeBar:SetNWName("bar")
	self.VolumeBar:SetSkinIdentifyer("bar")
	self.VolumeBar:SetAllowFractionEdit(true)
	self.VolumeBar:SetShadowWidth(0)
	self.VolumeBar:SetColor(Color(0, 0, 0, 200))
	self.VolumeBar:SetTextColor(Color(255, 255, 255, 255))
	self.VolumeBar.SkinAble = false

	self.VolumeBar.FractionChangeText = function(this, v)
		return string.format("Volume: %3i%%", math.Round(v * 100))
	end

	self.VolumeBar.OnFractionChangeEdit = function(this, v)
		if CLIENT then return end
		if not IsValid(self.StreamOBJ) then return end
		self.StreamOBJ:SetVolume(v)
	end

	self.VolumeBar:SetSize(1, 1)

	self.ControlPanel = self:AddPanelByClassname("radio/gui_player_controls", true)
	self.ControlPanel:SetSize(1, 1)
	self.ControlPanel:SetName("controls")
	self.ControlPanel:SetNWName("ctrl")
	self.ControlPanel:SetSkinIdentifyer("controls")

	self.ControlPanel.OnPlaylistBack = function()
		self:CallHook("OnPlaylistBack")
	end

	self.ControlPanel.OnPlaylistForward = function()
		self:CallHook("OnPlaylistForward")
	end

	self.ControlPanel.OnPlaybackLoopModeChange = function(this, newLoopMode)
		self:CallHook("OnPlaybackLoopModeChange", newLoopMode)
	end

	if CLIENT then
		self.Errorbox = self.SpectrumPanel:AddPanelByClassname("radio/gui_errorbox")
		self.Errorbox:SetName("error")
		self.Errorbox:SetNWName("err")
		self.Errorbox:SetSkinIdentifyer("error")

		self.Errorbox.OnRetry = function()
			if not IsValid(self.Errorbox) then
				return
			end

			self.Errorbox:Close()
		end

		self.Errorbox.OnClose = function()
			if not IsValid(self.StreamOBJ) then return end
			if not self.State then return end

			if not self.State.Error then return end
			if self.State.Error == 0 then return end

			self.State.Error = 0
			self:ResetStream()
		end

		self.Errorbox.OnWhitelist = function()
			if not IsValid(self.StreamOBJ) then return end

			StreamRadioLib.Whitelist.QuickWhitelistAdd(self.StreamOBJ:GetURL())
		end

		self.Errorbox:SetZPos(100)
		self.Errorbox:Close()

		if self.Errorbox.CloseButton then
			self.Errorbox.CloseButton:Remove()
			self.Errorbox.CloseButton = nil
		end
	end

	self.CloseButton = self:AddPanelByClassname("button", true)
	self.CloseButton:SetName("backbutton")
	self.CloseButton:SetNWName("bk")
	self.CloseButton:SetSkinIdentifyer("button")
	self.CloseButton:SetIcon(g_mat_closebutton)
	self.CloseButton:SetAlign(TEXT_ALIGN_RIGHT)
	self.CloseButton:SetTextAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	self.CloseButton:SetSize(200, 60)
	self.CloseButton:SetText("Back")
	self.CloseButton.DoClick = function()
		if CLIENT then
			return
		end

		if self.State then
			self.State.Error = 0
		end

		if IsValid(self.StreamOBJ) then
			self.StreamOBJ:Stop()
		end

		self:Close()
	end

	if CLIENT then
		self._textlistBuffer = {}

		self.State = self:CreateListener({
			Error = 0,
		}, function(this, k, v)
			if not IsValid(self.Errorbox) then
				return
			end

			local err = tonumber(v or 0) or 0
			local url = nil

			if IsValid(self.StreamOBJ) then
				url = self.StreamOBJ:GetURL()
			end

			self.Errorbox:SetErrorCode(err, url)
		end)
	end

	if SERVER then
		LIBNetwork.AddNetworkString("streamreset_on_sv")
		LIBNetwork.AddNetworkString("streamreset_on_cl")

		self:NetReceive("streamreset_on_sv", function(this, id, len, ply)
			self:ResetStream()
		end)
	else
		self:NetReceive("streamreset_on_cl", function(this, id, len, ply)
			self:ResetStream(true)
		end)
	end
end

function CLASS:Remove()
	if IsValid(self.StreamOBJ) then
		self.StreamOBJ:RemoveEvent("OnVolumeChange", self:GetID())

		if CLIENT then
			self.StreamOBJ:RemoveEvent("OnConnect", self:GetID())
			self.StreamOBJ:RemoveEvent("OnError", self:GetID())
			self.StreamOBJ:RemoveEvent("OnSearch", self:GetID())
			self.StreamOBJ:RemoveEvent("OnMute", self:GetID())
		end
	end

	BASE.Remove(self)
end

function CLASS:ResetStream(nosend)
	if not nosend then
		if SERVER then
			self:NetSend("streamreset_on_cl")
		else
			self:NetSend("streamreset_on_sv")
			return
		end
	end

	if not IsValid(self.StreamOBJ) then return end
	self.StreamOBJ:Reconnect()
end

function CLASS:SetStream(stream)
	if self.StreamOBJ == stream then
		return
	end

	self.StreamOBJ = stream

	self:SetFastThinkRate(0)

	if IsValid(self.ControlPanel) then
		self.ControlPanel:SetStream(stream)
	end

	if IsValid(self.SpectrumPanel) then
		self.SpectrumPanel:SetStream(stream)
	end

	if not IsValid(stream) then return end

	stream:SetEvent("OnVolumeChange", self:GetID(), function(this, vol)
		if not IsValid(self) then return end

		if IsValid(self.VolumeBar) then
			self.VolumeBar:SetFraction(vol)
		end

		if IsValid(self.VolumePanel) then
			local volumetimeout = 5

			self.VolumePanel:Show()

			self:TimerOnce("volumebar", volumetimeout, function()
				if not IsValid(self.VolumePanel) then return end
				self.VolumePanel:Hide()
			end)
		end

		self:CallHook("OnVolumeChange", v)
	end)

	if IsValid(self.VolumeBar) then
		self.VolumeBar:SetFraction(stream:GetVolume())
	end

	if CLIENT then
		local updateErrorState = function()
			if not IsValid(self) then return end
			if not self.State then return end

			local err = stream:GetError()

			if err == LIBError.STREAM_OK then
				self.State.Error = LIBError.STREAM_OK
			else
				if IsValid(self.Errorbox) then
					self.Errorbox:SetErrorCode(err, stream:GetURL())
				end

				self.State.Error = err
			end
		end

		stream:SetEvent("OnClose", self:GetID(), updateErrorState)
		stream:SetEvent("OnSearch", self:GetID(), updateErrorState)
		stream:SetEvent("OnConnect", self:GetID(), updateErrorState)
		stream:SetEvent("OnError", self:GetID(), updateErrorState)
		stream:SetEvent("OnMute", self:GetID(), updateErrorState)

		updateErrorState()
	end

	self:UpdateFromStream()
end

function CLASS:GetStream()
	return self.StreamOBJ
end

if CLIENT then
	function CLASS:Think()
		self.thinkRate = 0.5

		if not self:IsSeen() then return end
		if not self:IsVisible() then return end

		self.thinkRate = 0
		self:UpdateFromStream()
	end
end

local function formatInterfaceName(interfaceName, text)
	interfaceName = interfaceName or ""
	text = text or ""

	if text == "" then
		return ""
	end

	if interfaceName == "" then
		return text
	end

	text = string.format("[%s] %s", interfaceName, text)
	return text
end

function CLASS:UpdateHeaderTextFromStream()
	if SERVER then return end

	local stream = self.StreamOBJ
	if not IsValid(stream) then return end

	local headerText = self.HeaderText
	if not IsValid(headerText) then return end

	local textlist = self._textlistBuffer
	if not textlist then return end

	emptyTableSafe(textlist)

	local interfaceName = stream:GetActiveInterfaceName()
	local name = stream:GetStreamName()
	local url = stream:GetURL()

	name = string.Trim(name)
	url = string.Trim(url)

	if url == "" then
		url = "(Unknown URL)"
	end

	if name == url then
		-- Avoid showing the name if it is the URL
		name = ""
	end

	if name ~= "" then
		table.insert(textlist, name)
	end

	if name == "" or not string.find(name, url, 1, true) then
		-- Avoid showing the URL twice

		local urlText = formatInterfaceName(interfaceName, url)
		table.insert(textlist, urlText)
	end

	local metatags = stream:GetMetaTags() or {}

	local remotename = metatags["streamtitle"] or ""
	remotename = string.Trim(remotename)

	remotename = formatInterfaceName(interfaceName, remotename)

	if remotename ~= "" then
		table.insert(textlist, remotename)
	end

	headerText:SetList(textlist)
end

function CLASS:UpdateWhitelistButtonFromStream()
	if SERVER then return end

	local stream = self.StreamOBJ
	if not IsValid(stream) then return end

	local errorbox = self.Errorbox
	if not IsValid(errorbox) then return end

	local isAdmin = LIBUtil.IsAdmin()
	local isOnlineUrl = stream:IsOnlineUrl()
	local isWhitelistError = stream:GetError() == LIBError.STREAM_ERROR_URL_NOT_WHITELISTED
	local showButton = isAdmin and isWhitelistError and isOnlineUrl

	errorbox:SetAdminWhitelistButtonVisible(showButton)
end

function CLASS:UpdateFromStream()
	if SERVER then return end
	if not IsValid(self.StreamOBJ) then return end

	self:UpdateWhitelistButtonFromStream()
	self:UpdateHeaderTextFromStream()
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	if not IsValid(self.HeaderPanel) then return end
	if not IsValid(self.CloseButton) then return end
	if not IsValid(self.SpectrumPanel) then return end

	local w, h = self:GetClientSize()
	local margin = self:GetMargin()

	local headerh = self.HeaderPanel:GetHeight()
	local closew, closeh = self.CloseButton:GetSize()

	closew = closeh * 4
	self.CloseButton:SetWidth(closew)

	local closex = w - closew
	local closey = h - closeh

	local spectrumy = headerh + margin

	local spectrumbgw = w
	local spectrumbgh = h - headerh - closeh - margin * 2

	local controlx = 0
	local controly = closey

	local controlw = w - closew - margin
	local controlh = closeh

	local ultrawideminh = closeh * 2 + margin

	if spectrumbgh <= ultrawideminh then
		if IsValid(self.ControlPanel) then
			closew = closeh * (self.ControlPanel.State.PlaylistEnabled and 6 or 4)
			self.CloseButton:SetWidth(closew)
		end

		spectrumbgw = w - closew - margin
		spectrumbgh = h - headerh - margin

		controlx = closex
		controly = spectrumy

		controlw = closew
		controlh = spectrumbgh - closeh - margin
	end

	self.HeaderPanel:SetPos(0, 0)
	self.HeaderPanel:SetWidth(w)

	self.SpectrumPanel:SetPos(0, spectrumy)
	self.SpectrumPanel:SetSize(spectrumbgw, spectrumbgh)

	local spectrumw, spectrumh = self.SpectrumPanel:GetClientSize()

	if IsValid(self.Errorbox) then
		self.Errorbox:SetPos(0, 0)
		self.Errorbox:SetSize(spectrumw, spectrumh)
	end

	if IsValid(self.ControlPanel) then
		self.ControlPanel:SetPos(controlx, controly)
		self.ControlPanel:SetSize(controlw, controlh)
	end

	if IsValid(self.VolumePanel) and IsValid(self.VolumeBar) then
		local headerheight = self.HeaderPanel:GetHeight()
		local volumew = spectrumw * 0.618
		local volumeh = math.Clamp(spectrumh * 0.1, headerheight, headerheight * 2)

		local volumex = (spectrumw - volumew) / 2
		local volumey = spectrumh * 0.95 - volumeh

		self.VolumePanel:SetPos(volumex, volumey)
		self.VolumePanel:SetSize(volumew, volumeh)

		self.VolumeBar:SetPos(0, 0)
		self.VolumeBar:SetSize(self.VolumePanel:GetClientSize())
	end

	self.CloseButton:SetPos(closex, closey)
end

function CLASS:GetHasPlaylist()
	return self._hasplaylist or false
end

function CLASS:SetHasPlaylist(bool)
	self._hasplaylist = bool
end

function CLASS:EnablePlaylist(...)
	if not IsValid(self.ControlPanel) then
		return
	end

	self.ControlPanel:EnablePlaylist(...)
end

function CLASS:IsPlaylistEnabled()
	if not IsValid(self.ControlPanel) then
		return
	end

	return self.ControlPanel:IsPlaylistEnabled()
end

function CLASS:UpdatePlaybackLoopMode(...)
	if not IsValid(self.ControlPanel) then
		return
	end

	self.ControlPanel:UpdatePlaybackLoopMode(...)
end

function CLASS:SetSyncMode(bool)
	self._syncmode = bool or false

	if IsValid(self.CloseButton) then
		self.CloseButton:SetDisabled(bool)
	end

	if IsValid(self.ControlPanel) then
		self.ControlPanel:SetSyncMode(bool)
	end
end

function CLASS:GetSyncMode()
	return self._syncmode or  false
end

return true

