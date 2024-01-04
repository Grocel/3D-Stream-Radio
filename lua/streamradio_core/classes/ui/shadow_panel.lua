local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

function CLASS:Create()
	BASE.Create(self)

	self.CanHaveLabel = true

	self.Layout.Padding = 5
	self.Layout.ShadowWidth = 5
	self.Layout.Background = true

	self.SkinMap["color_foreground"] = {
		set = "SetTextColor",
		get = "GetTextColor",
	}

	self.SkinMap["color_icon"] = {
		set = "SetIconColor",
		get = "GetIconColor",
	}

	self.SkinMap["color_shadow"] = {
		set = "SetShadowColor",
		get = "GetShadowColor",
	}

	if not SERVER then
		self.Colors.Shadow = Color(64,64,64)
	end

	self.SkinAble = true
end

function CLASS:CreateText(class)
	if not self.CanHaveLabel then return nil end

	if IsValid(self.TextPanel) then
		return self.TextPanel
	end

	self.TextPanel = self:AddPanelByClassname(class or "label", true)
	self.TextPanel:SetPos(0, 0)
	self.TextPanel:SetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	self.TextPanel:SetName("label")
	self.TextPanel:SetNWName("lbl")
	self.TextPanel:SetSkinIdentifyer("label")

	self.TextPanel.OnTextChange = function(pnl)
		if not IsValid(self) then return end
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

	self:InvalidateLayout()
	return self.TextPanel
end

function CLASS:Render()
	if not self.Layout.Background then
		BASE.Render(self)
		return
	end

	local x, y = self:GetRenderPos()
	local w, h = self:GetSize()
	local shadowWidth = self:GetShadowWidth()

	local colMain = self.Colors.Main or color_white

	if shadowWidth <= 0 then
		surface.SetDrawColor(colMain:Unpack())
		surface.DrawRect(x, y, w, h)

		BASE.Render(self)
		return
	end

	local sx, sy = x + shadowWidth, y + shadowWidth
	local sw, sh = w - shadowWidth, h - shadowWidth

	local colShadow = self.Colors.Shadow or color_black

	surface.SetDrawColor(colShadow:Unpack())
	surface.DrawRect(sx, sy, sw, sh)
	surface.SetDrawColor(colMain:Unpack())
	surface.DrawRect(x, y, sw, sh)

	BASE.Render(self)
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	if not self.CanHaveLabel then
		return
	end

	local text_panel = self.TextPanel
	if not IsValid(text_panel) then
		return
	end

	local w, h = self:GetClientSize()
	text_panel:SetSize(w, h)
end

function CLASS:SetShadowColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.Shadow = color
end

function CLASS:GetShadowColor()
	if SERVER then return end

	local col = self.Colors.Shadow
	return col
end

function CLASS:GetShadowWidth()
	if not self.Layout.Background then
		return 0
	end

	return self.Layout.ShadowWidth or 0
end

function CLASS:SetShadowWidth(width)
	self.Layout.ShadowWidth = width or 0
end

function CLASS:GetClientSize()
	local w, h = BASE.GetClientSize(self)
	local s = self:GetShadowWidth()

	w = w - s
	h = h - s

	if w < 0 then
		w = 0
	end

	if h < 0 then
		h = 0
	end

	return w, h
end

function CLASS:GetClientWidth()
	local w = BASE.GetClientWidth(self)
	local s = self:GetShadowWidth()

	w = w - s

	if w < 0 then
		w = 0
	end

	return w
end

function CLASS:GetClientHeight()
	local h = BASE.GetClientHeight(self)
	local s = self:GetShadowWidth()

	h = h - s

	if h < 0 then
		h = 0
	end

	return h
end

function CLASS:SetSizeWithoutShadow(w, h)
	w = w or 0
	h = h or 0
	local s = self:GetShadowWidth()

	w = w + s
	h = h + s
	return self:SetSize(w, h)
end

function CLASS:SetWidthWithoutShadow(w)
	w = w or 0
	local s = self:GetShadowWidth()

	w = w + s
	return self:SetWidth(w)
end

function CLASS:SetHeightWithoutShadow(h)
	h = h or 0
	local s = self:GetShadowWidth()

	h = h + s
	return self:SetTall(h)
end

function CLASS:IsInBounds(x, y)
	if not BASE.IsInBounds(self, x, y) then return false end

	local w, h = self:GetSize()
	local s = self:GetShadowWidth()

	if x > (w - s) then return false end
	if y > (h - s) then return false end

	return true
end

function CLASS:SetPaintBackground(bool)
	self.Layout.Background = bool or false
end

function CLASS:GetPaintBackground(bool)
	return self.Layout.Background or false
end

function CLASS:GetTextAlign(...)
	return self:GetAlign(...)
end

function CLASS:SetTextAlign(...)
	return self:SetAlign(...)
end

function CLASS:GetAlign(...)
	if not IsValid(self.TextPanel) then
		return TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
	end

	return self.TextPanel:GetAlign(...)
end

function CLASS:SetAlign(...)
	return self:CreateText():SetAlign(...)
end

function CLASS:SetText(...)
	return self:CreateText():SetText(...)
end

function CLASS:GetText(...)
	if not IsValid(self.TextPanel) then
		return ""
	end

	return self.TextPanel:GetText(...)
end

function CLASS:SetFont(...)
	return self:CreateText():SetFont(...)
end

function CLASS:GetFont(...)
	if not IsValid(self.TextPanel) then
		return ""
	end

	return self.TextPanel:GetFont(...)
end

function CLASS:SetTextColor(...)
	return self:CreateText():SetColor(...)
end

function CLASS:GetTextColor(...)
	if not IsValid(self.TextPanel) then
		return self:GetColor(...)
	end

	return self.TextPanel:GetColor(...)
end

function CLASS:OnModelSetup(setup)
	BASE.OnModelSetup(self, setup)

	if setup.shadowwidth then
		self:SetShadowWidth(setup.shadowwidth)
	end

	if setup.font then
		self:SetFont(setup.font)
	end
end

return true

