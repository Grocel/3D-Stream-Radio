local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

function CLASS:Create()
	BASE.Create(self)

	self.Browser = self:AddPanelByClassname("radio/gui_browser", true)
	self.Browser:SetName("browser")
	self.Browser:SetNWName("brw")
	self.Browser:SetZPos(50)
	self.Browser:Open()
	self.Browser:SetSkinIdentifyer("browser")

	self.Player = self:AddPanelByClassname("radio/gui_player", true)
	self.Player:SetName("player")
	self.Player:SetNWName("ply")
	self.Player:SetZPos(100)
	self.Player:Close()
	self.Player:SetSkinIdentifyer("player")

	self:SetShadowWidth(0)
	self.Browser:SetPadding(5)
	self.Player:SetPadding(5)

	self._showplaylist = true
	self._hasplaylist = false

	self.State = self:CreateListener({
		PlayerOpened = false,
	}, function(this, k, v)
		if not v then
			self.Player:Close()
			self.Browser:ActivateNetworkedMode()
			self.Browser:Open()
			self.Browser:CloseSingleItem()
		end

		if v then
			self.Browser:CloseSingleItem()
			self.Browser:Close()
			self.Player:ActivateNetworkedMode()
			self.Player:Open()

			self:EnablePlaylist(self._showplaylist)
			self:SetHasPlaylist(self._hasplaylist)

			if IsValid(self.StreamOBJ) then
				self.StreamOBJ:Play(true)
			end

			self:CallHook("OnPlayerShown")
		end

		self:SetNWBool(k, v)
		self:ApplyNetworkVars()
		self:InvalidateLayout()
	end)

	self.Browser.OnPlayItem = function(this, item)
		self:EnablePlaylist(true)
		self:Play(item)
	end

	self.Browser.OnPlaylistStartBuild = function(this, ...)
		return self:CallHook("OnPlaylistStartBuild", ...)
	end

	self.Browser.OnPlaylistEndBuild = function(this, ...)
		return self:CallHook("OnPlaylistEndBuild", ...)
	end

	self.Browser.OnPlaylistOpen = function(this, ...)
		return self:CallHook("OnPlaylistOpen", ...)
	end

	self.Browser.OnPlaylistClose = function(this, ...)
		return self:CallHook("OnPlaylistClose", ...)
	end

	self.Browser.OnToolButtonClick = function()
		self:CallHook("OnToolButtonClick")
	end

	self.Browser.OnWireButtonClick = function()
		self:CallHook("OnWireButtonClick")
	end

	self.Player.OnClose = function()
		self:Stop()
		self:CallHook("OnPlayerClosed")
	end

	self.Player.OnPlaylistBack = function()
		self:CallHook("OnPlaylistBack")
	end

	self.Player.OnPlaylistForward = function()
		self:CallHook("OnPlaylistForward")
	end

	self.Player.OnPlaybackLoopModeChange = function(this, newLoopMode)
		self:CallHook("OnPlaybackLoopModeChange", newLoopMode)
	end

	self:QueueCall("ActivateNetworkedMode")
	self:InvalidateLayout()
end

function CLASS:Stop()
	if not self.State.PlayerOpened then
		return
	end

	self:ClosePlayer()
	self:CallHook("OnStop")
end

function CLASS:Play(item)
	if not item then
		self:Stop()
		return
	end

	self:OpenPlayer()
	self:CallHook("OnPlayItem", item)
end

function CLASS:OpenPlayer()
	self.State.PlayerOpened = true
end

function CLASS:ClosePlayer()
	self.State.PlayerOpened = false
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	if not IsValid(self.Player) then return end
	if not IsValid(self.Browser) then return end

	local w, h = self:GetClientSize()

	self.Player:SetPos(0, 0)
	self.Player:SetSize(w, h)
	self.Browser:SetPos(0, 0)
	self.Browser:SetSize(w, h)
end

function CLASS:SetStream(stream)
	if self.StreamOBJ == stream then
		return
	end

	self.StreamOBJ = stream

	if IsValid(self.Player) then
		self.Player:SetStream(stream)
	end
end

function CLASS:GetStream()
	return self.StreamOBJ
end

function CLASS:EnablePlaylist(bool)
	self._showplaylist = bool
	self.Player:EnablePlaylist(bool and self._hasplaylist)
end

function CLASS:GetHasPlaylist()
	return self._hasplaylist or false
end

function CLASS:SetHasPlaylist(bool)
	self._hasplaylist = bool
	self.Player:EnablePlaylist(bool and self._showplaylist)

	self.Player:SetHasPlaylist(bool)
	self.Browser:SetHasPlaylist(bool)
end

function CLASS:IsPlaylistEnabled()
	return self.Player:IsPlaylistEnabled()
end

function CLASS:UpdatePlaybackLoopMode(...)
	self.Player:UpdatePlaybackLoopMode(...)
end

function CLASS:SetSyncMode(...)
	self.Player:SetSyncMode(...)
end

function CLASS:GetSyncMode()
	return self.Player:GetSyncMode()
end

function CLASS:IsPlayerOpen()
	return self.State.PlayerOpened or false
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)
	self.Browser:ActivateNetworkedMode()
	self.Player:ActivateNetworkedMode()

	if SERVER then
		self:SetNWBool("PlayerOpened", self.State.PlayerOpened)
		return
	end

	self:SetNWVarCallback("PlayerOpened", "Bool", function(this, nwkey, oldvar, newvar)
		self.State.PlayerOpened = newvar
	end)
end

function CLASS:ApplyNetworkVarsInternal()
	BASE.ApplyNetworkVarsInternal(self)

	self.State.PlayerOpened = self:GetNWBool("PlayerOpened", false)
end

function CLASS:PreDupe()
	local data = {}

	data.PlayerOpened = self.State.PlayerOpened

	return data
end

function CLASS:PostDupe(data)
	self.State.PlayerOpened = data.PlayerOpened
end

return true

