local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

function CLASS:Create()
	BASE.Create(self)

	self.CanHaveLabel = false

	self.Layout.Align = TEXT_ALIGN_RIGHT

	self.ImagePanel = self:AddPanelByClassname("image", true)
	self.ImagePanel:SetPos(0, 0)
	self.ImagePanel:SetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	self.ImagePanel:SetName("image")
	self.ImagePanel:SetNWName("img")
	self.ImagePanel:SetSkinIdentifyer("image")

	self.ImagePanel.OnMaterialChange = function(pnl)
		if not IsValid(self) then return end
		self:InvalidateLayout()
		self:CallHook("OnMaterialChange")
	end

	self.ImagePanel.OnAlignChange = function(pnl)
		if not IsValid(self) then return end
		self:InvalidateLayout()
		self:CallHook("OnAlignChange")
	end

	self.LabelPanel = self:AddPanelByClassname("label", true)
	self.LabelPanel:SetPos(0, 0)
	self.LabelPanel:SetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	self.LabelPanel:SetName("label")
	self.LabelPanel:SetNWName("lbl")
	self.LabelPanel:SetSkinIdentifyer("label")

	self.LabelPanel.OnTextChange = function(pnl)
		if not IsValid(self) then return end
		self:InvalidateLayout()
		self:CallHook("OnTextChange")
	end

	self.LabelPanel.OnFontChange = function(pnl)
		if not IsValid(self) then return end
		self:InvalidateLayout()
		self:CallHook("OnFontChange")
	end

	self.LabelPanel.OnAlignChange = function(pnl)
		if not IsValid(self) then return end
		self:InvalidateLayout()
		self:CallHook("OnAlignChange")
	end

	self.SkinMap["color_hover"] = {
		set = "SetHoverColor",
		get = "GetHoverColor",
	}

	self.SkinMap["color_disabled"] = {
		set = "SetDisabledColor",
		get = "GetDisabledColor",
	}

	self.SkinMap["color_foreground_hover"] = {
		set = "SetTextHoverColor",
		get = "GetTextHoverColor",
	}

	self.SkinMap["color_foreground_disabled"] = {
		set = "SetTextDisabledColor",
		get = "GetTextDisabledColor",
	}

	self.SkinMap["color_icon_hover"] = {
		set = "SetIconHoverColor",
		get = "GetIconHoverColor",
	}

	self.SkinMap["color_icon_disabled"] = {
		set = "SetIconDisabledColor",
		get = "GetIconDisabledColor",
	}

	if not SERVER then
		self.Colors.Disabled = Color(128,128,128)
		self.Colors.DisabledText = Color(255,255,255)
		self.Colors.DisabledIcon = Color(255,255,255)

		self.Colors.Hover = Color(192,192,192)
		self.Colors.HoverText = Color(0,0,0)
		self.Colors.HoverIcon = Color(255,255,255)

		self.Colors.NoHover = Color(255,255,255)
		self.Colors.NoHoverText = Color(0,0,0)
		self.Colors.NoHoverIcon = Color(255,255,255)

		self.Colors = self.Colors + function(this, k, v)
			if k == "Main" then return end
			self:QueueCall("UpdateColor")
		end
	end

	self:IconFitToPanel()
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	self:QueueCall("UpdateColor")
	self:QueueCall(self._recallonlaylout)

	local mat_panel = self.ImagePanel
	local text_panel = self.LabelPanel

	if not IsValid(mat_panel) then
		return
	end

	if not IsValid(text_panel) then
		return
	end

	local has_mat = mat_panel:GetMaterial() ~= nil
	local has_text = text_panel:GetText() ~= ""

	if not has_text and not has_mat then
		return
	end

	local w, h = self:GetClientSize()
	local align = self.Layout.Align

	if has_mat and not has_text then
		text_panel:SetSize(0, 0)
		text_panel:SetVisible(false)
		mat_panel:SetSize(w, h)
		mat_panel:SetVisible(true)
		return
	end

	if has_text and not has_mat then
		text_panel:SetSize(w, h)
		text_panel:SetVisible(true)
		mat_panel:SetSize(0, 0)
		mat_panel:SetVisible(false)
		return
	end

	text_panel:SetVisible(true)
	mat_panel:SetVisible(true)

	local mat_size = self:GetSquareSize()
	local padding = self:GetPadding()

	if align == TEXT_ALIGN_RIGHT then
		mat_panel:SetPos(0, 0)
		mat_panel:SetSize(mat_size, mat_size)
		text_panel:SetPos(mat_size + padding, 0)
		text_panel:SetSize(w - mat_size - padding, h)
		return
	end

	if align == TEXT_ALIGN_LEFT then
		mat_panel:SetPos(w - mat_size, 0)
		mat_panel:SetSize(mat_size, mat_size)
		text_panel:SetPos(0, 0)
		text_panel:SetSize(w - mat_size - padding, h)
		return
	end

	local _, text_h = text_panel:GetTextSize()

	if align == TEXT_ALIGN_BOTTOM then
		mat_panel:SetPos(0, 0)
		mat_panel:SetSize(w, h - text_h - padding)
		text_panel:SetPos(0, h - text_h)
		text_panel:SetSize(w, text_h)
		return
	end

	if align == TEXT_ALIGN_TOP then
		mat_panel:SetPos(0, text_h + padding)
		mat_panel:SetSize(w, h - text_h - padding)
		text_panel:SetPos(0, 0)
		text_panel:SetSize(w, text_h)
		return
	end
end

function CLASS:CursorChangedInternal()
	BASE.CursorChangedInternal(self)

	if SERVER then return end
	self:UpdateColor()
end

function CLASS:UpdateColor()
	if SERVER then return end

	if self:IsDisabled() then
		self.Colors.Main = self.Colors.Disabled
		if IsValid(self.LabelPanel) then
			self.LabelPanel:SetColor(self.Colors.DisabledText)
		end

		if IsValid(self.ImagePanel) then
			self.ImagePanel:SetColor(self.Colors.DisabledIcon)
		end

		return
	end

	if self:IsCursorOnPanel() then
		self.Colors.Main = self.Colors.Hover

		if IsValid(self.LabelPanel) then
			self.LabelPanel:SetColor(self.Colors.HoverText)
		end

		if IsValid(self.ImagePanel) then
			self.ImagePanel:SetColor(self.Colors.HoverIcon)
		end

		return
	end

	self.Colors.Main = self.Colors.NoHover
	if IsValid(self.LabelPanel) then
		self.LabelPanel:SetColor(self.Colors.NoHoverText)
	end

	if IsValid(self.ImagePanel) then
		self.ImagePanel:SetColor(self.Colors.NoHoverIcon)
	end
end

function CLASS:GetAlign()
	return self.Layout.Align or TEXT_ALIGN_RIGHT
end

function CLASS:SetAlign(align)
	self.Layout.Align = align or TEXT_ALIGN_RIGHT
end

function CLASS:GetIconAlign(...)
	return self.ImagePanel:GetAlign(...)
end

function CLASS:SetIconAlign(...)
	return self.ImagePanel:SetAlign(...)
end

function CLASS:GetTextAlign(...)
	return self.LabelPanel:GetAlign(...)
end

function CLASS:SetTextAlign(...)
	return self.LabelPanel:SetAlign(...)
end

function CLASS:SetText(...)
	return self.LabelPanel:SetText(...)
end

function CLASS:GetText(...)
	return self.LabelPanel:GetText(...)
end

function CLASS:SetFont(...)
	return self.LabelPanel:SetFont(...)
end

function CLASS:GetFont(...)
	return self.LabelPanel:GetFont(...)
end

function CLASS:GetMaterial(...)
	return self.ImagePanel:GetMaterial(...)
end

function CLASS:SetMaterial(...)
	return self.ImagePanel:SetMaterial(...)
end

function CLASS:GetMaterialName(...)
	return self.ImagePanel:GetMaterialName(...)
end

function CLASS:SetTexture(...)
	return self.ImagePanel:SetTexture(...)
end

function CLASS:SetIcon(...)
	return self.ImagePanel:SetMaterial(...)
end

function CLASS:GetIcon(...)
	return self.ImagePanel:GetMaterial(...)
end

function CLASS:IconSizeToPanel(...)
	self._recallonlaylout = "IconSizeToPanel"
	return self.ImagePanel:TextureSizeToPanel(...)
end

function CLASS:IconFitToPanel(...)
	self._recallonlaylout = "IconFitToPanel"
	return self.ImagePanel:TextureFitToPanel(...)
end

function CLASS:IconSizeToTexture(...)
	self._recallonlaylout = "IconSizeToTexture"
	return self.ImagePanel:TextureSizeToTexture(...)
end

function CLASS:SetColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.NoHover = color
end

function CLASS:GetColor()
	if SERVER then return end

	local col = self.Colors.NoHover
	return col
end

function CLASS:SetHoverColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.Hover = color
end

function CLASS:GetHoverColor()
	if SERVER then return end

	local col = self.Colors.Hover
	return col
end

function CLASS:SetDisabledColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.Disabled = color
end

function CLASS:GetDisabledColor()
	if SERVER then return end

	local col = self.Colors.Disabled
	return col
end

function CLASS:SetTextColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.NoHoverText = color
end

function CLASS:GetTextColor()
	if SERVER then return end

	local col = self.Colors.NoHoverText
	return col
end

function CLASS:SetTextHoverColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.HoverText = color
end

function CLASS:GetTextHoverColor()
	if SERVER then return end

	local col = self.Colors.HoverText
	return col
end

function CLASS:SetTextDisabledColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.DisabledText = color
end

function CLASS:GetTextDisabledColor()
	if SERVER then return end

	local col = self.Colors.DisabledText
	return col
end

function CLASS:SetIconColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.NoHoverIcon = color
end

function CLASS:GetIconColor()
	if SERVER then return end

	local col = self.Colors.NoHoverIcon
	return col
end

function CLASS:SetIconHoverColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.HoverIcon = color
end

function CLASS:GetIconHoverColor()
	if SERVER then return end

	local col = self.Colors.HoverIcon
	return col
end

function CLASS:SetIconDisabledColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.DisabledIcon = color
end

function CLASS:GetIconDisabledColor()
	if SERVER then return end

	local col = self.Colors.DisabledIcon
	return col
end

function CLASS:DoClick()
	-- Override me
end

function CLASS:OnMouseReleased()
	-- Override me
end

function CLASS:OnModelSetup(setup)
	BASE.OnModelSetup(self, setup)

	if setup.font then
		self:SetFont(setup.font)
	end
end

return true

