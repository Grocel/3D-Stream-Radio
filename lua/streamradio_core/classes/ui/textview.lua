local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

function CLASS:Create()
	BASE.Create(self)

	self.CanHaveLabel = false

	self.TextPanel = self:AddPanelByClassname("text", true)
	self.TextPanel:SetPos(0, 0)
	self.TextPanel:SetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	self.TextPanel:SetName("text")
	self.TextPanel:SetNWName("txt")

	self.ScrollBar = self:AddPanelByClassname("scrollbar", true)
	self.ScrollBar:SetName("scrollbar")
	self.ScrollBar:SetNWName("sbar")
	self.ScrollBar:SetSkinIdentifyer("scrollbar")
	self.ScrollBar:Hide()

	self.SkinMap["color_foreground"] = {
		set = "SetTextColor",
		get = "GetTextColor",
	}

	self.TextPanel.OnTextChange = function(pnl)
		if not IsValid(self) then return end
		self:InvalidateLayout()
		self:CallHook("OnTextChange")
	end

	self.TextPanel.OnFontChange = function(pnl)
		if not IsValid(self) then return end
		self:InvalidateLayout()
		self:CallHook("OnFontChange")
	end

	self.TextPanel.OnAlignChange = function(pnl)
		if not IsValid(self) then return end
		self:InvalidateLayout()
		self:CallHook("OnAlignChange")
	end

	self.TextPanel.OnBuildLines = function(pnl)
		if SERVER then return end
		if not IsValid(self.ScrollBar) then return end

		local lines = self.TextPanel:GetVisibleLines()
		local count = self.TextPanel:GetLineCount() - #lines
		local scroll = self.TextPanel:GetStartLine()

		self.ScrollBar:SetMaxScroll(count)
		self.ScrollBar:SetScroll(scroll - 1)

		self:InvalidateLayout()
	end

	self.ScrollBar.OnScroll = function(pnl, value)
		if SERVER then return end
		if not IsValid(self.TextPanel) then return end
		self.TextPanel:SetStartLine(value + 1)
	end
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	local text_panel = self.TextPanel
	local scrollbar = self.ScrollBar

	if not IsValid(text_panel) then
		return
	end

	local w, h = self:GetClientSize()
	local hasscrollbar = IsValid(scrollbar) and scrollbar:IsScrollAble()

	if not hasscrollbar then
		text_panel:SetSize(w, h)

		if IsValid(scrollbar) then
			scrollbar:Hide()
		end

		return
	end

	local barwidth = scrollbar:GetWidth()
	local margin = self:GetMargin()

	text_panel:SetSize(w - margin - barwidth, h)

	scrollbar:SetHeight(h)
	scrollbar:SetPos(w - barwidth, 0)

	scrollbar:SetHorizontal(false)
	scrollbar:Show()
end

function CLASS:GetTextAlign(...)
	return self:GetAlign(...)
end

function CLASS:SetTextAlign(...)
	return self:SetAlign(...)
end

function CLASS:GetAlign(...)
	return self.TextPanel:GetAlign(...)
end

function CLASS:SetAlign(...)
	return self.TextPanel:SetAlign(...)
end

function CLASS:SetText(...)
	return self.TextPanel:SetText(...)
end

function CLASS:GetText(...)
	return self.TextPanel:GetText(...)
end

function CLASS:SetFont(...)
	return self.TextPanel:SetFont(...)
end

function CLASS:GetFont(...)
	return self.TextPanel:GetFont(...)
end

function CLASS:SetTextColor(...)
	return self.TextPanel:SetColor(...)
end

function CLASS:GetTextColor(...)
	return self.TextPanel:GetColor(...)
end

function CLASS:OnModelSetup(setup)
	BASE.OnModelSetup(self, setup)

	if setup.font then
		self:SetFont(setup.font)
	end
end

return true

