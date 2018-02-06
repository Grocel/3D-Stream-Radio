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
	self.HeaderPanel:SetSkinIdentifyer("header")

	self.HeaderPanelTextPre = self.HeaderPanel:AddPanelByClassname("label", true)
	self.HeaderPanelTextPre:SetText("Path: ")
	self.HeaderPanelTextPre:SetSize(1, 30)
	self.HeaderPanelTextPre:SetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self.HeaderPanelTextPre:SetName("pretext")

	self.HeaderPanelText = self.HeaderPanel:AddPanelByClassname("label", true)
	self.HeaderPanelText:SetShorterAtEnd(false)
	self.HeaderPanelText:SetAlign(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	self.HeaderPanelText:SetName("text")

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
	self.UpButton:SetSkinIdentifyer("sidebutton")
	self.UpButton:SetToolTip("Go to parent directory")

	self.RefreshButton = self:AddPanelByClassname("button", true)
	self.RefreshButton:SetIcon(g_mat_refresh)
	self.RefreshButton:SetSize(50, 50)
	self.RefreshButton:SetName("refreshbutton")
	self.RefreshButton:SetSkinIdentifyer("sidebutton")
	self.RefreshButton:SetToolTip("Refresh view")

	self.ToolButton = self:AddPanelByClassname("button", true)
	self.ToolButton:SetIcon(g_mat_toolbutton)
	self.ToolButton:SetSize(50, 50)
	self.ToolButton:SetName("toolbutton")
	self.ToolButton:SetSkinIdentifyer("sidebutton")
	self.ToolButton:SetToolTip("Play URL from Toolgun")

	self.WireButton = self:AddPanelByClassname("button", true)
	self.WireButton:SetIcon(g_mat_wirebutton)
	self.WireButton:SetSize(50, 50)
	self.WireButton:SetName("wirebutton")
	self.WireButton:SetSkinIdentifyer("sidebutton")
	self.WireButton:SetVisible(StreamRadioLib.HasWiremod())
	self.WireButton:SetToolTip("Play URL from Wiremod")

	self.ListFiles = self:AddPanelByClassname("radio/list_playlists", true)
	self.ListFiles:SetName("list-playlists")
	self.ListFiles:Open()
	self.ListFiles:SetSkinIdentifyer("list")

	self.ListPlaylist = self:AddPanelByClassname("radio/list_playlistview", true)
	self.ListPlaylist:SetName("list-playlistview")
	self.ListPlaylist:Close()
	self.ListPlaylist:SetSkinIdentifyer("list")

	self.Errorbox = self:AddPanelByClassname("radio/gui_errorbox", true)
	self.Errorbox:SetName("error")
	self.Errorbox:SetSkinIdentifyer("error")
	self.Errorbox.OnClose = function()
		if not self.State then return end

		self.State.PlaylistError = false
		self.State.PlaylistOpened = false
	end

	self.SideButtons = {
		self.UpButton,
		self.RefreshButton,
		self.ToolButton,
		self.WireButton,
	}

	self.Errorbox.OnRetry = function()
		if not self.State then return end

		self.State.PlaylistOpened = true
		self.ListPlaylist:Refresh()
	end

	self.Errorbox:SetZPos(100)
	self.Errorbox:Close()

	self.State = self:CreateListener({
		PlaylistOpened = false,
		PlaylistError = false,
	}, function(this, k, v)
		if k == "PlaylistOpened" then
			if not v then
				self.State.PlaylistError = false
				self.ListPlaylist:ClearData()
				self.ListPlaylist:Close()
				self.ListFiles:ActivateNetworkedMode()
				self.ListFiles:Open()
			end

			if v then
				self.ListFiles:ClearData()
				self.ListFiles:Close()
				self.ListPlaylist:ActivateNetworkedMode()
				self.ListPlaylist:Open()
			end

			self:Refresh()
			self:SetNWBool(k, v)
			self:UpdatePath()
		end

		if k == "PlaylistError" and not v then
			self.Errorbox:Close()
		end

		self:ApplyNetworkVars()
		self:InvalidateLayout()
	end)

	self.ListPlaylist.OnPlay = function(this, ...)
		self:UpdatePath()
		return self:CallHook("OnPlay", ...)
	end

	self.ListPlaylist.OnError = function(this, filename, filetype, ...)
		self.State.PlaylistError = true

		if IsValid(self.Errorbox) then
			self.Errorbox:SetPlaylistError(filename)
			self:InvalidateLayout()
		end

		return self:CallHook("OnError", filename, filetype, ...)
	end

	self.ListPlaylist.OnErrorClose = function(this, filename, filetype, ...)
		self.State.PlaylistError = false
	end

	self.ListPlaylist.OnInvalidDupeFilepath = function(this, filename, filetype, ...)
		self.InValidPlaylistDupe = true
		self.State.PlaylistOpened = false

		self:Refresh()
		self:QueueCall("Refresh")

		self:UpdatePath()
	end

	self.ListFiles.OnInvalidDupeFilepath = function(this)
		self.InValidPlaylistDupe = true
		self.State.PlaylistOpened = false

		self:Refresh()
		self:QueueCall("Refresh")

		self:UpdatePath()
	end

	self.ListPlaylist.OnDupePlaylistApply = function(this)
		self:CallHook("OnDupePlaylistApply")
	end

	self.ListFiles.OnFileClick = function(this, fullpath, path, filename, filetype, ...)
		if CLIENT then return end

		local r = self:CallHook("OnFileClick", fullpath, path, filename, filetype, ...)
		if r == false then return end

		self.State.PlaylistOpened = true
		self.ListPlaylist:SetFile(path, filetype)
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
		self.ListPlaylist:SaveScrollPos()
		self.ListFiles:SaveScrollPos()
	end)

	self:UpdatePath()
end

function CLASS:IsSingleItem()
	return self.ListPlaylist:IsSingleItem()
end

function CLASS:CloseSingleItem()
	if not self:IsSingleItem() then return end

	self.State.PlaylistError = false
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

function CLASS:IsPlaylistOpend()
	return self.State.PlaylistOpened or self.State.PlaylistError or false
end

function CLASS:GetPath()
	if self:IsPlaylistOpend() then
		return self.ListPlaylist:GetFile()
	end

	return self.ListFiles:GetPath()
end

function CLASS:GoUpPath()
	if not self.State then return end

	if self.State.PlaylistOpened or self.State.PlaylistError then
		self.State.PlaylistOpened = false
		self.State.PlaylistError = false
		return
	end

	if CLIENT then return end
	self.ListFiles:GoUpPath()
end

function CLASS:Refresh()
	if not self.State then return end

	if self.State.PlaylistError then
		self.State.PlaylistError = false
		self.State.PlaylistOpened = false
		self.State.PlaylistOpened = true
	end

	self.ListPlaylist:Refresh()
	self.ListFiles:Refresh()
end

function CLASS:PlayNext()
	if not IsValid(self.ListPlaylist) then return end
	self.ListPlaylist:PlayNext()
end

function CLASS:PlayPrevious()
	if not IsValid(self.ListPlaylist) then return end
	self.ListPlaylist:PlayPrevious()
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

	local w, h = self:GetClientSize()
	local bw = 0

	for k, v in pairs(self.SideButtons) do
		if not IsValid(v) then continue end
		if not v.Layout.Visible then continue end

		if bw <= 0 then
			bw = v:GetWidth()
		end
	end

	local headerw, headerh = self.HeaderPanel:GetSize()

	local margin = self:GetMargin()
	local listx = 0

	if bw > 0 then
		listx = bw + margin
	end

	local listy = headerh + margin

	local listw = w - listx
	local listh = h - listy

	headerw = listw

	local buttony = listy

	for k, v in pairs(self.SideButtons) do
		if not IsValid(v) then continue end
		if not v.Layout.Visible then continue end

		local newbutteny = buttony + (bw + margin)
		if newbutteny >= h then
			v:SetPos(0, 0)
			v:SetHeight(0)
			continue
		end

		v:SetPos(0, buttony)
		v:SetSize(bw, bw)
		buttony = newbutteny
	end

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

	self:SetNWVarProxy("PlaylistOpened", function(this, nwkey, oldvar, newvar)
		self.State.PlaylistOpened = newvar
	end)
end

function CLASS:ApplyNetworkVarsInternal()
	BASE.ApplyNetworkVarsInternal(self)

	self.State.PlaylistOpened = self:GetNWBool("PlaylistOpened", false)
end

function CLASS:PreDupe(ent)
	local data = {}

	data.PlaylistOpened = self.State.PlaylistOpened

	return data
end

function CLASS:PostDupe(ent, data)
	self.State.PlaylistOpened = data.PlaylistOpened and not self.InValidPlaylistDupe
end
