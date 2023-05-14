if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

local g_mat_help = StreamRadioLib.GetPNGIcon("help")
local g_mat_cross = StreamRadioLib.GetPNGIcon("cross")
local g_mat_arrow_refresh = StreamRadioLib.GetPNGIcon("arrow_refresh")

function CLASS:Create()
	BASE.Create(self)

	self.Error = 0
	self.URL = ""

	self.BodyPanelText = self:AddPanelByClassname("textview", true)
	self.BodyPanelText:SetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	self.BodyPanelText:SetName("textbox")
	self.BodyPanelText:SetSkinIdentifyer("textbox")

	self.HelpButton = self:AddPanelByClassname("button", true)
	self.HelpButton:SetSize(1, 40)
	self.HelpButton:SetIcon(g_mat_help)
	self.HelpButton:SetText("Help")
	self.HelpButton:SetName("help")
	self.HelpButton:SetSkinIdentifyer("button")
	self.HelpButton.DoClick = function()
		self:CallHook("OnHelp")
		if SERVER then return end

		if self.Error == "playlist" then
			StreamRadioLib.ShowPlaylistErrorHelp()
			return
		end

		StreamRadioLib.ShowErrorHelp( self.Error, self.URL )
	end

	self.CloseButton = self:AddPanelByClassname("button", true)
	self.CloseButton:SetSize(1, 40)
	self.CloseButton:SetIcon(g_mat_cross)
	self.CloseButton:SetText("Close")
	self.CloseButton:SetName("close")
	self.CloseButton:SetSkinIdentifyer("button")
	self.CloseButton.DoClick = function()
		self:Close()
	end

	self.RetryButton = self:AddPanelByClassname("button", true)
	self.RetryButton:SetSize(1, 40)
	self.RetryButton:SetIcon(g_mat_arrow_refresh)
	self.RetryButton:SetText("Retry")
	self.RetryButton:SetName("retry")
	self.RetryButton:SetSkinIdentifyer("button")
	self.RetryButton.DoClick = function()
		self:Close()
		self:CallHook("OnRetry")
	end
end

function CLASS:SetPlaylistError(url)
	url = tostring(url or "")

	if StreamRadioLib.IsBlockedURLCode(url) then
		url = ""
	end

	self.Error = "playlist"
	self.URL = url

	local text

	if url ~= "" then
		text = string.format("Error: Could not open playlist:\n%s\n\nMake sure the file is valid and not Empty\n\nClick help for more details.", url)
	else
		text = "Error: Could not open playlist!\n\nMake sure the file is valid and not Empty\n\nClick help for more details."
	end

	if IsValid(self.BodyPanelText) then
		self.BodyPanelText:SetText(text)
	end

	self:Open()
end

function CLASS:SetErrorCode(err, url)
	err = tonumber(err or 0) or 0
	url = tostring(url or "")

	if StreamRadioLib.IsBlockedURLCode(url) then
		url = ""
	end

	self.Error = err
	self.URL = url

	local errordesc = StreamRadioLib.DecodeErrorCode(err)
	local text

	if url ~= "" then
		text = string.format("Error: %i\n\nCould not play stream:\n%s\n\n%s\n\nClick help for more details.", err, url, errordesc)
	else
		text = string.format("Error: %i\n\nCould not play stream!\n\n%s\n\nClick help for more details.", err, errordesc)
	end

	if IsValid(self.BodyPanelText) then
		self.BodyPanelText:SetText(text)
	end

	self:Open()
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	local w, h = self:GetClientSize()
	local margin = self:GetMargin()

	local bodyheight = h

	local buttonh = 0
	local buttonw = w - 100
	local buttonc = 0

	if IsValid(self.CloseButton) and self.CloseButton.Layout.Visible then
		buttonc = buttonc + 1
		buttonh = self.CloseButton:GetHeight()
	end

	if IsValid(self.RetryButton) and self.RetryButton.Layout.Visible then
		buttonc = buttonc + 1
		buttonh = self.RetryButton:GetHeight()
	end

	if IsValid(self.HelpButton) and self.RetryButton.Layout.Visible then
		buttonc = buttonc + 1
		buttonh = self.HelpButton:GetHeight()
	end

	if buttonc > 0 then
		buttonw = math.max(buttonw / buttonc, buttonh * 2.5)
	else
		buttonw = 0
	end

	local buttonbarw = buttonw * buttonc
	if buttonbarw > 0 then
		buttonbarw = buttonbarw + (buttonc - 1) * margin
	end

	if buttonh > 0 then
		bodyheight = bodyheight - buttonh - margin
	end

	local buttonx = (w - buttonbarw) / 2
	local buttony = h - buttonh

	if IsValid(self.CloseButton) then
		self.CloseButton:SetSize(buttonw, buttonh)
		self.CloseButton:SetPos(buttonx, buttony)
		buttonx = buttonx + (buttonw + margin)
	end

	if IsValid(self.RetryButton) then
		self.RetryButton:SetSize(buttonw, buttonh)
		self.RetryButton:SetPos(buttonx, buttony)
		buttonx = buttonx + (buttonw + margin)
	end

	if IsValid(self.HelpButton) then
		self.HelpButton:SetSize(buttonw, buttonh)
		self.HelpButton:SetPos(buttonx, buttony)
	end

	if IsValid(self.BodyPanelText) then
		self.BodyPanelText:SetPos(0, 0)
		self.BodyPanelText:SetSize(w, bodyheight)
	end
end
