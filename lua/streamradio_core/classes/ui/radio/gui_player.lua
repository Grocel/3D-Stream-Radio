if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

local g_mat_closebutton = StreamRadioLib.GetPNGIcon("door_in")

function CLASS:Create()
	BASE.Create(self)

	self.HeaderPanel = self:AddPanelByClassname("shadow_panel", true)
	self.HeaderPanel:SetSize(1, 40)
	self.HeaderPanel:SetName("header")
	self.HeaderPanel:SetSkinIdentifyer("header")

	self.HeaderText = self.HeaderPanel:CreateText("label_fade")
	self.HeaderPanel:SetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	self.SpectrumPanel = self:AddPanelByClassname("radio/gui_player_spectrum", true)
	self.SpectrumPanel:SetSize(1, 1)
	self.SpectrumPanel:SetName("spectrum")
	self.SpectrumPanel:SetSkinIdentifyer("spectrum")

	self.VolumePanel = self.SpectrumPanel:AddPanelByClassname("shadow_panel")
	self.VolumePanel:SetSize(1, 60)
	self.VolumePanel:SetName("volume")
	self.VolumePanel:SetSkinIdentifyer("volume")
	self.VolumePanel:SetShadowWidth(0)
	self.VolumePanel:SetColor(Color(128, 128, 128, 160))
	self.VolumePanel.SkinAble = false
	self.VolumePanel:SetZPos(200)
	self.VolumePanel:Close()

	self.VolumeBar = self.VolumePanel:AddPanelByClassname("progressbar", true)
	self.VolumeBar:SetName("progressbar")
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
		if not IsValid(self.StreamOBJ) then return end
		self.StreamOBJ:SetVolume(v)
	end

	self.VolumeBar:SetSize(1,1)

	self.ControlPanel = self:AddPanelByClassname("radio/gui_player_controls", true)
	self.ControlPanel:SetSize(1, 1)
	self.ControlPanel:SetName("controls")
	self.ControlPanel:SetSkinIdentifyer("controls")

	self.ControlPanel.OnPlaylistBack = function()
		self:CallHook("OnPlaylistBack")
	end

	self.ControlPanel.OnPlaylistForward = function()
		self:CallHook("OnPlaylistForward")
	end

	self.Errorbox = self.SpectrumPanel:AddPanelByClassname("radio/gui_errorbox")
	self.Errorbox:SetName("error")
	self.Errorbox:SetSkinIdentifyer("error")
	self.Errorbox.OnClose = function()
		if not IsValid(self.StreamOBJ) then return end
		if not self.State then return end

		if not self.State.Error then return end
		if self.State.Error == 0 then return end

		self.State.Error = 0
		self:ResetStream()
	end

	self.Errorbox:SetZPos(100)
	self.Errorbox:Close()

	if self.Errorbox.CloseButton then
		self.Errorbox.CloseButton:Remove()
		self.Errorbox.CloseButton = nil
	end

	self.CloseButton = self:AddPanelByClassname("button", true)
	self.CloseButton:SetName("backbutton")
	self.CloseButton:SetSkinIdentifyer("button")
	self.CloseButton:SetIcon(g_mat_closebutton)
	self.CloseButton:SetAlign(TEXT_ALIGN_RIGHT)
	self.CloseButton:SetTextAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	self.CloseButton:SetSize(200, 60)
	self.CloseButton:SetText("Back")
	self.CloseButton.DoClick = function()
		if self.State then
			self.State.Error = 0
		end

		if IsValid(self.StreamOBJ) then
			self.StreamOBJ:Stop()
		end

		self:Close()
	end

	if CLIENT then
		self.State = self:CreateListener({
			Error = 0,
		}, function(this, k, v)
			if not IsValid(self.StreamOBJ) then return end
			local err = tonumber(v or 0) or 0
			local haserror = err ~= 0

			self.State.Error = err

			if haserror then
				self.Errorbox:SetErrorCode(err, self.StreamOBJ:GetURL())
				self.Errorbox:Open()
			else
				self.Errorbox:Close()
			end

			self:InvalidateLayout()
		end)
	end

	if SERVER then
		self:NetReceive("streamreset_sv", function(this, id, len, ply)
			self:ResetStream()
		end)
	else
		self:StartSuperThink()

		self:NetReceive("streamreset_cl", function(this, id, len, ply)
			self:ResetStream(true)
		end)
	end
end

function CLASS:Remove()
	if IsValid(self.StreamOBJ) then
		self.StreamOBJ:RemoveEvent("OnVolumeChange", self:GetID())
		self.StreamOBJ:RemoveEvent("OnConnect", self:GetID())
		self.StreamOBJ:RemoveEvent("OnError", self:GetID())
		self.StreamOBJ:RemoveEvent("OnSearch", self:GetID())
	end

	BASE.Remove(self)
end

function CLASS:ResetStream(nosend)
	if not nosend then
		if SERVER then
			self:NetSend("streamreset_cl")
		else
			self:NetSend("streamreset_sv")
			return
		end
	end

	if not IsValid(self.StreamOBJ) then return end
	self.StreamOBJ:Retry()
end

function CLASS:SetStream(stream)
	self.StreamOBJ = stream

	if IsValid(self.ControlPanel) then
		self.ControlPanel:SetStream(stream)
	end

	if IsValid(self.ControlPanel) then
		self.SpectrumPanel:SetStream(stream)
	end

	if not IsValid(self.StreamOBJ) then return end

	self.StreamOBJ:SetEvent("OnVolumeChange", self:GetID(), function(this, vol)
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
		self.VolumeBar:SetFraction(self.StreamOBJ:GetVolume())
	end

	if CLIENT then
		self.StreamOBJ:SetEvent("OnSearch", self:GetID(), function()
			if not IsValid(self) then return end
			if not self.State then return end
			if not IsValid(self.Errorbox) then return end

			-- self.State.Error = 0
		end)

		self.StreamOBJ:SetEvent("OnConnect", self:GetID(), function()
			if not IsValid(self) then return end
			if not self.State then return end
			if not IsValid(self.Errorbox) then return end

			self.State.Error = 0
		end)

		self.StreamOBJ:SetEvent("OnError", self:GetID(), function(this, err)
			if not IsValid(self) then return end
			if not self.State then return end
			if not IsValid(self.Errorbox) then return end

			self.Errorbox:SetErrorCode(err, self.StreamOBJ:GetURL())
			self.State.Error = err
		end)
	end

	self:UpdateFromStream()
end

function CLASS:GetStream()
	return self.StreamOBJ
end

function CLASS:Think()
	if not self:IsSeen() then return end
	if not self:IsVisible() then return end

	self:UpdateFromStream()
end

function CLASS:SuperThink()
	if SERVER then return end
	if not IsValid(self.StreamOBJ) then return end

	if not self:IsSeen() then return end
	if not self:IsVisible() then return end

	if IsValid(self.ControlPanel) then
		self.ControlPanel:UpdateFromStream()
	end

	self:PerformRerender(true)
end

function CLASS:UpdateFromStream()
	if not IsValid(self.StreamOBJ) then return end
	if SERVER then return end

	local textlist = {}

	local name = self.StreamOBJ:GetStreamName()
	local isOnline = self.StreamOBJ:IsOnline()
	local isCached = self.StreamOBJ:IsCached()
	local url = self.StreamOBJ:GetURL()

	if StreamRadioLib.IsBlockedURLCode(url) then
		url = "(Blocked URL)"
		isCached = false
		isOnline = true
	end

	local urlprefix = "URL: "
	local urlpostfix = ""

	if not isOnline and not isCached then
		urlprefix = "File: "
	end

	if isCached then
		urlpostfix = " (Cached)"
	end

	if name ~= "" then
		textlist[#textlist + 1] = name
	end

	textlist[#textlist + 1] = urlprefix .. url .. urlpostfix

	local metaname = ""
	local meta = self.StreamOBJ:GetMetadata()

	local prefix = meta.converter_name or ""
	if prefix ~= "" then
		prefix = "[" .. prefix .. "] "
	end

	local title = meta.title or ""

	if title ~= "" then
		metaname = prefix .. title
	end

	if self.StreamOBJ:IsBASSEngineEnabled() then
		local remotename = self.StreamOBJ:GetTag(BASS3.ENUM.TAG_META) or {}
		remotename = remotename["streamtitle"] or ""

		if remotename ~= "" then
			metaname = prefix .. remotename
		end
	end

	if metaname ~= "" then
		textlist[#textlist + 1] = metaname
	end

	self.HeaderText:SetList(textlist)
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

function CLASS:EnablePlaylist(...)
	self.ControlPanel:EnablePlaylist(...)
end

function CLASS:IsPlaylistEnabled()
	return self.ControlPanel:IsPlaylistEnabled()
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
