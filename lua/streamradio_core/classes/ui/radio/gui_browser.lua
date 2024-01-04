local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

local g_mat_upbutton = StreamRadioLib.GetPNGIcon("door_in")
local g_mat_refresh = StreamRadioLib.GetPNGIcon("arrow_refresh")
local g_mat_toolbutton = StreamRadioLib.GetPNGIcon("wrench")
local g_mat_wirebutton = StreamRadioLib.GetPNGIcon("wiremod", true)

function CLASS:Create()
	BASE.Create(self)

	self.HeaderPanel = self:AddPanelByClassname("shadow_panel", true)
	self.HeaderPanel:SetSize(1, 30)
	self.HeaderPanel:SetName("header")
	self.HeaderPanel:SetNWName("hdr")
	self.HeaderPanel:SetSkinIdentifyer("header")

	self.HeaderPanelTextPre = self.HeaderPanel:AddPanelByClassname("label", true)
	self.HeaderPanelTextPre:SetText("Path: ")
	self.HeaderPanelTextPre:SetSize(1, 30)
	self.HeaderPanelTextPre:SetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self.HeaderPanelTextPre:SetName("pretext")
	self.HeaderPanelTextPre:SetNWName("ptxt")

	self.HeaderPanelText = self.HeaderPanel:AddPanelByClassname("label", true)
	self.HeaderPanelText:SetShorterAtEnd(false)
	self.HeaderPanelText:SetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self.HeaderPanelText:SetName("text")
	self.HeaderPanelText:SetNWName("txt")

	self.HeaderPanel.SetTextColor = function(this, color)
		if IsValid(self.HeaderPanelText) then
			self.HeaderPanelText:SetTextColor(color)
		end

		if IsValid(self.HeaderPanelTextPre) then
			self.HeaderPanelTextPre:SetTextColor(color)
		end
	end

	self.HeaderPanel.GetTextColor = function(this)
		if IsValid(self.HeaderPanelText) then
			return self.HeaderPanelText:GetTextColor()
		end

		if IsValid(self.HeaderPanelTextPre) then
			return self.HeaderPanelTextPre:GetTextColor()
		end

		return nil
	end

	self.UpButton = self:AddPanelByClassname("button", true)
	self.UpButton:SetIcon(g_mat_upbutton)
	self.UpButton:SetSize(50, 50)
	self.UpButton:SetName("backbutton")
	self.UpButton:SetNWName("bk")
	self.UpButton:SetSkinIdentifyer("sidebutton")
	self.UpButton:SetTooltip("Go to parent directory")

	self.RefreshButton = self:AddPanelByClassname("button", true)
	self.RefreshButton:SetIcon(g_mat_refresh)
	self.RefreshButton:SetSize(50, 50)
	self.RefreshButton:SetName("refreshbutton")
	self.RefreshButton:SetNWName("rfsh")
	self.RefreshButton:SetSkinIdentifyer("sidebutton")
	self.RefreshButton:SetTooltip("Refresh view")

	self.ToolButton = self:AddPanelByClassname("button", true)
	self.ToolButton:SetIcon(g_mat_toolbutton)
	self.ToolButton:SetSize(50, 50)
	self.ToolButton:SetName("toolbutton")
	self.ToolButton:SetNWName("tool")
	self.ToolButton:SetSkinIdentifyer("sidebutton")
	self.ToolButton:SetTooltip("Play URL from Toolgun")

	self.WireButton = self:AddPanelByClassname("button", true)
	self.WireButton:SetIcon(g_mat_wirebutton)
	self.WireButton:SetSize(50, 50)
	self.WireButton:SetName("wirebutton")
	self.WireButton:SetNWName("wire")
	self.WireButton:SetSkinIdentifyer("sidebutton")
	self.WireButton:SetVisible(StreamRadioLib.Wire.HasWiremod())
	self.WireButton:SetTooltip("Play URL from Wiremod")

	self.ListFiles = self:AddPanelByClassname("radio/list_playlists", true)
	self.ListFiles:SetName("list-playlists")
	self.ListFiles:SetNWName("lstp")
	self.ListFiles:Open()
	self.ListFiles:SetSkinIdentifyer("list")

	self.ListPlaylist = self:AddPanelByClassname("radio/list_playlistview", true)
	self.ListPlaylist:SetName("list-playlistview")
	self.ListPlaylist:SetNWName("lstpv")
	self.ListPlaylist:Close()
	self.ListPlaylist:SetSkinIdentifyer("list")

	self.Errorbox = self:AddPanelByClassname("radio/gui_errorbox", true)
	self.Errorbox:SetName("error")
	self.Errorbox:SetNWName("err")
	self.Errorbox:SetSkinIdentifyer("error")

	if self.Errorbox.RetryButton then
		self.Errorbox.RetryButton:Remove()
		self.Errorbox.RetryButton = nil
	end

	if self.Errorbox.AdminWhitelistButton then
		self.Errorbox.AdminWhitelistButton:Remove()
		self.Errorbox.AdminWhitelistButton = nil
	end

	if IsValid(self.Errorbox.CloseButton) and CLIENT then
		-- The error box is handled on the server, so the client shouldn't touch it.
		self.Errorbox.CloseButton.DoClick = nil
	end

	self.Errorbox.OnCloseClick = function()
		self:GoUpPath()
	end

	self.Errorbox:SetZPos(100)
	self.Errorbox:Close()

	self.SideButtons = {
		self.UpButton,
		self.RefreshButton,
		self.ToolButton,
		self.WireButton,
	}

	self.State = self:CreateListener({
		PlaylistOpened = false,
	}, function(this, k, v)
		if IsValid(self.Errorbox) then
			self.Errorbox:Close()
			self:InvalidateLayout()
		end

		if not v then
			self:CallHook("OnPlaylistClose")

			if IsValid(self.ListPlaylist) then
				self.ListPlaylist:ClearData()
				self.ListPlaylist:Close()
			end

			if IsValid(self.ListFiles) then
				self.ListFiles:ActivateNetworkedMode()
				self.ListFiles:Open()
			end
		else
			self:CallHook("OnPlaylistOpen")

			if IsValid(self.ListFiles) then
				self.ListFiles:ClearData()
				self.ListFiles:Close()
			end

			if IsValid(self.ListPlaylist) then
				self.ListPlaylist:ActivateNetworkedMode()
				self.ListPlaylist:Open()
			end
		end

		self:Refresh()
		self:SetNWBool(k, v)
		self:UpdatePath()

		self:ApplyNetworkVars()
		self:InvalidateLayout()
	end)

	self.ListPlaylist.OnPlayItem = function(this, ...)
		self:UpdatePath()
		return self:CallHook("OnPlayItem", ...)
	end

	self.ListPlaylist.OnPlaylistStartBuild = function(this, ...)
		return self:CallHook("OnPlaylistStartBuild", ...)
	end

	self.ListPlaylist.OnPlaylistEndBuild = function(this, ...)
		return self:CallHook("OnPlaylistEndBuild", ...)
	end

	self.ListPlaylist.OnError = function(this, filename, filetype, ...)
		if IsValid(self.Errorbox) then
			self.Errorbox:SetPlaylistError(filename)
			self:InvalidateLayout()
		end

		return self:CallHook("OnError", filename, filetype, ...)
	end

	self.ListPlaylist.OnErrorRelease = function(this, filename, filetype, ...)
		if IsValid(self.Errorbox) then
			self.Errorbox:Close()
			self:InvalidateLayout()
		end

		return self:CallHook("OnErrorRelease", filename, filetype, ...)
	end

	self.ListPlaylist.OnInvalidDupeFilepath = function(this, filename, filetype, ...)
		self:QueueCall("OnInvalidDupeFilepath")
	end

	self.ListFiles.OnInvalidDupeFilepath = function(this)
		self:QueueCall("OnInvalidDupeFilepath")
	end

	self.ListFiles.OnFileClick = function(this, value, ...)
		if CLIENT then return end

		local r = self:CallHook("OnFileClick", value, ...)
		if r == false then return end

		self.State.PlaylistOpened = true

		if IsValid(self.ListPlaylist) then
			self.ListPlaylist:SetFile(value.path, value.type)
		end
	end

	self.ListFiles.OnPathChange = function(this, ...)
		self:UpdatePath()
		return self:CallHook("OnPathChange", ...)
	end

	self.ListPlaylist.OnPathChange = function(this, ...)
		self:UpdatePath()
		return self:CallHook("OnPathChange", ...)
	end

	self.UpButton.DoClick = function()
		self:GoUpPath()
	end

	self.RefreshButton.DoClick = function()
		self:Refresh()
	end

	self.ToolButton.DoClick = function()
		self:CallHook("OnToolButtonClick")
	end

	self.WireButton.DoClick = function()
		self:CallHook("OnWireButtonClick")
	end

	self:SetEvent("OnClose", "SaveScrollPos", function()
		if IsValid(self.ListPlaylist) then
			self.ListPlaylist:SaveScrollPos()
		end

		if IsValid(self.ListFiles) then
			self.ListFiles:SaveScrollPos()
		end
	end)

	self:UpdatePath()
end

function CLASS:OnInvalidDupeFilepath()
	self.State.PlaylistOpened = false

	if IsValid(self.Errorbox) then
		self.Errorbox:Close()
	end

	self:Refresh()

	self:UpdatePath()
	self:InvalidateLayout()
end

function CLASS:GetHasPlaylist()
	return self._hasplaylist or false
end

function CLASS:SetHasPlaylist(bool)
	self._hasplaylist = bool
end

function CLASS:CloseSingleItem()
	if self:GetHasPlaylist() then return end

	self.State.PlaylistOpened = false
end

function CLASS:UpdatePath()
	if not IsValid(self.UpButton) then return end
	if not IsValid(self.HeaderPanelText) then return end

	local path = self:GetPath()

	self.HeaderPanelText:SetText("/" .. path)
	self.UpButton:SetDisabled(path == "")
end

function CLASS:GetUpButton()
	return self.UpButton
end

function CLASS:GetRefreshButton()
	return self.RefreshButton
end

function CLASS:GetToolButton()
	return self.ToolButton
end

function CLASS:GetWireButton()
	return self.WireButton
end

function CLASS:GetFilesPanel()
	return self.ListFiles
end

function CLASS:GetPlaylistPanel()
	return self.ListPlaylist
end

function CLASS:GetHeaderPanel()
	return self.HeaderPanel
end

function CLASS:GetHeaderTextPanel()
	return self.HeaderPanelText
end

function CLASS:IsPlaylistOpen()
	if self.State.PlaylistOpened then
		return true
	end

	if IsValid(self.ListPlaylist) and self.ListPlaylist:HasError() then
		return true
	end

	return false
end

function CLASS:GetPath()
	if self:IsPlaylistOpen() then
		return self.ListPlaylist:GetFile()
	end

	return self.ListFiles:GetPath()
end

function CLASS:GoUpPath()
	if CLIENT then return end
	if not self.State then return end

	if self:IsPlaylistOpen() then
		self.State.PlaylistOpened = false
		return
	end

	if IsValid(self.ListFiles) then
		self.ListFiles:GoUpPath()
	end
end

function CLASS:Refresh()
	local antiSpamTime = 1

	if IsValid(self.RefreshButton) then
		self.RefreshButton:SetDisabled(true)

		self:TimerOnce("RefreshButtonAntiSpam", antiSpamTime, function()
			if not IsValid(self.RefreshButton) then
				return
			end

			self.RefreshButton:SetDisabled(false)
		end)
	end

	if IsValid(self.Errorbox) and IsValid(self.Errorbox.RetryButton) then
		self.Errorbox.RetryButton:SetDisabled(true)

		self:TimerOnce("RetryButtonAntiSpam", antiSpamTime, function()
			if not IsValid(self.Errorbox) then
				return
			end

			if not IsValid(self.Errorbox.RetryButton) then
				return
			end

			self.Errorbox.RetryButton:SetDisabled(false)
		end)
	end

	if CLIENT then return end

	if IsValid(self.ListPlaylist) and self.ListPlaylist:IsVisible() then
		self.ListPlaylist:Refresh()
	end

	if IsValid(self.ListFiles) and self.ListFiles:IsVisible() then
		self.ListFiles:Refresh()
	end
end

function CLASS:_PerformButtonLayout(buttonx, buttony)
	if not self.SideButtons then return end

	local _, h = self:GetClientSize()
	local buttonw = 0

	for k, v in ipairs(self.SideButtons) do
		if not IsValid(v) then continue end
		if not v.Layout.Visible then continue end

		if buttonw <= 0 then
			buttonw = v:GetWidth()
			break
		end
	end

	local margin = self:GetMargin()

	for k, v in ipairs(self.SideButtons) do
		if not IsValid(v) then continue end
		if not v.Layout.Visible then continue end

		local newbutteny = buttony + (buttonw + margin)
		if newbutteny >= h then
			v:SetPos(0, 0)
			v:SetHeight(0)
			continue
		end

		v:SetPos(buttonx, buttony)
		v:SetSize(buttonw, buttonw)
		buttony = newbutteny
	end

	return buttonw, buttony
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	if not IsValid(self.HeaderPanel) then return end
	if not IsValid(self.HeaderPanelText) then return end
	if not IsValid(self.UpButton) then return end
	if not IsValid(self.ToolButton) then return end
	if not IsValid(self.WireButton) then return end
	if not IsValid(self.ListFiles) then return end
	if not IsValid(self.ListPlaylist) then return end
	if not self.SideButtons then return end

	local w, h = self:GetClientSize()
	local headerw, headerh = self.HeaderPanel:GetSize()

	local buttonw = self:_PerformButtonLayout(0, headerh)

	local margin = self:GetMargin()
	local listx = 0

	if buttonw > 0 then
		listx = buttonw + margin
	end

	local listy = headerh + margin

	local listw = w - listx
	local listh = h - listy

	headerw = listw

	self.ListFiles:SetSize(listw, listh)
	self.ListPlaylist:SetSize(listw, listh)

	self.ListFiles:SetPos(listx, listy)
	self.ListPlaylist:SetPos(listx, listy)

	self.HeaderPanel:SetSize(headerw, headerh)
	self.HeaderPanel:SetPos(listx, 0)

	local headeriw, headerih = self.HeaderPanel:GetClientSize()

	self.HeaderPanelTextPre:AutoWidth(headeriw)
	self.HeaderPanelTextPre:SetHeight(headerih)

	local headerprew = self.HeaderPanelTextPre:GetWidth()

	self.HeaderPanelTextPre:SetPos(0, 0)

	self.HeaderPanelText:SetSize(headeriw - headerprew, headerih)
	self.HeaderPanelText:SetPos(headerprew, 0)

	if IsValid(self.Errorbox) then
		self.Errorbox:SetSize(listw, listh)
		self.Errorbox:SetPos(listx, listy)
	end
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)
	self.ListFiles:ActivateNetworkedMode()
	self.ListPlaylist:ActivateNetworkedMode()

	if SERVER then
		self:SetNWBool("PlaylistOpened", self.State.PlaylistOpened)
		return
	end

	self:SetNWVarCallback("PlaylistOpened", "Bool", function(this, nwkey, oldvar, newvar)
		self.State.PlaylistOpened = newvar
	end)
end

function CLASS:ApplyNetworkVarsInternal()
	BASE.ApplyNetworkVarsInternal(self)

	self.State.PlaylistOpened = self:GetNWBool("PlaylistOpened", false)
end

function CLASS:PreDupe()
	local data = {}

	data.PlaylistOpened = self.State.PlaylistOpened

	return data
end

function CLASS:PostDupe(data)
	self.State.PlaylistOpened = data.PlaylistOpened
end

return true

