if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local LIBError = StreamRadioLib.Error

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
	self.BodyPanelText:SetNWName("txt")
	self.BodyPanelText:SetSkinIdentifyer("textbox")

	self.HelpButton = self:AddPanelByClassname("button", true)
	self.HelpButton:SetSize(40, 40)
	self.HelpButton:SetIcon(g_mat_help)
	self.HelpButton:SetDrawAlpha(0.5)
	self.HelpButton:SetTooltip("Help")
	self.HelpButton:SetName("help")
	self.HelpButton:SetNWName("hlp")
	self.HelpButton:SetSkinIdentifyer("button")
	self.HelpButton.DoClick = function()
		self:CallHook("OnHelp")
		if SERVER then return end

		StreamRadioLib.ShowErrorHelp( self.Error, self.URL )
	end

	self.CloseButton = self:AddPanelByClassname("button", true)
	self.CloseButton:SetSize(40, 40)
	self.CloseButton:SetIcon(g_mat_cross)
	self.CloseButton:SetDrawAlpha(0.5)
	self.CloseButton:SetTooltip("Close")
	self.CloseButton:SetName("close")
	self.CloseButton:SetNWName("cls")
	self.CloseButton:SetSkinIdentifyer("button")
	self.CloseButton.DoClick = function()
		self:Close()
		self:CallHook("OnCloseClick")
	end

	self.RetryButton = self:AddPanelByClassname("button", true)
	self.RetryButton:SetSize(40, 40)
	self.RetryButton:SetIcon(g_mat_arrow_refresh)
	self.RetryButton:SetDrawAlpha(0.5)
	self.RetryButton:SetTooltip("Retry")
	self.RetryButton:SetName("retry")
	self.RetryButton:SetNWName("rty")
	self.RetryButton:SetSkinIdentifyer("button")
	self.RetryButton.DoClick = function()
		self:CallHook("OnRetry")
	end

	self.SideButtons = {
		self.CloseButton,
		self.RetryButton,
		self.HelpButton,
	}
end

function CLASS:SetPlaylistError(url)
	url = tostring(url or "")

	if StreamRadioLib.IsBlockedURLCode(url) then
		url = ""
	end

	self.Error = LIBError.PLAYLIST_ERROR_INVALID_FILE
	self.URL = url

	local errorInfo = LIBError.GetStreamErrorInfo(self.Error)

	local code = errorInfo.id
	local name = errorInfo.name

	local text

	if url ~= "" then
		text = string.format("Error: %i (%s)\n\nCould not open playlist:\n%s\n\nMake sure the file is valid and not Empty\n\nClick the '?' button for more details.", code, name, url)
	else
		text = string.format("Error: %i (%s)\n\nCould not open playlist!\n\nMake sure the file is valid and not Empty\n\nClick the '?' button for more details.", code, name)
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

	local errorInfo = LIBError.GetStreamErrorInfo(err)

	local code = errorInfo.id
	local name = errorInfo.name
	local description = errorInfo.description or ""

	local text

	if url ~= "" then
		text = string.format("Error: %i (%s)\n\nCould not play stream:\n%s\n\n%s\n\nClick the '?' button for more details.", code, name, url, description)
	else
		text = string.format("Error: %i (%s)\n\nCould not play stream!\n\n%s\n\nClick the '?' button for more details.", code, name, description)
	end

	if IsValid(self.BodyPanelText) then
		self.BodyPanelText:SetText(text)
	end

	if err ~= 0 then
		self:Open()
	else
		self:Close()
	end
end

function CLASS:_PerformButtonLayout(buttonx, buttony)
	if not self.SideButtons then return end

	local w, h = self:GetClientSize()
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

	local w, h = self:GetClientSize()

	local margin = self:GetMargin()

	self:_PerformButtonLayout(margin, margin)

	if IsValid(self.BodyPanelText) and self.BodyPanelText.Layout.Visible then
		self.BodyPanelText:SetPos(0, 0)
		self.BodyPanelText:SetSize(w, h)
	end
end