local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

function CLASS:Create()
	BASE.Create(self)

	self.TextPanel = self:AddPanelByClassname("text", true)
	self.TextPanel:SetPos(0, 0)
	self.TextPanel:SetSize(350, 1)
	self.TextPanel:SetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	self.TextPanel:SetName("text")
	self.TextPanel:SetNWName("txt")
	self.TextPanel:SetSkinIdentifyer("text")
	self.TextPanel:SetStartLine(0)

	self:SetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	self.SkinMap["color_foreground"] = {
		set = "SetTextColor",
		get = "GetTextColor",
	}

	self.TextPanel.OnTextChange = function(pnl)
		if not IsValid(self) then return end
		self.TextPanel:FitToText(75, self:GetMaxWidth())
		self:InvalidateLayout()
		self:CallHook("OnTextChange")
	end

	self.TextPanel.OnFontChange = function(pnl)
		if not IsValid(self) then return end
		self.TextPanel:FitToText(75, self:GetMaxWidth())
		self:InvalidateLayout()
		self:CallHook("OnFontChange")
	end

	self.TextPanel.OnAlignChange = function(pnl)
		if not IsValid(self) then return end
		self:InvalidateLayout()
		self:CallHook("OnAlignChange")
	end

	if CLIENT then
		self.Colors.Main = Color(0, 0, 0, 192)
		self:SetTextColor(Color(255, 255, 255, 255))
	end

	local CalcSize = function(this, k, v)
		if k ~= "MaxWidth" then return end

		if not IsValid(self.TextPanel) then
			return
		end

		self.TextPanel:FitToText(75, v)
		self:InvalidateLayout()
	end

	self.Size = self.Size + CalcSize

	self.Clickable = false
	self.SkinAble = false

	self:SetPadding(10)
	self:SetMaxWidth(350)
	self:InvalidateLayout()
end

function CLASS:SetMaxWidth(maxw)
	self.Size.MaxWidth = math.max(maxw or 0, 75)
end

function CLASS:GetMaxWidth()
	return self.Size.MaxWidth or 0
end

function CLASS:Render()
	local text_panel = self.TextPanel
	if not IsValid(text_panel) then
		return
	end

	local x, y = self:GetRenderPos()
	local w, h = self:GetSize()

	local colText = self:GetTextColor()
	colText = colText or color_white

	local colMain = self.Colors.Main or color_black

	local thickness = 2
	local padding = 2

	surface.SetDrawColor(colText:Unpack())

	for i = 0, thickness - 1 do
		local t = i + padding
		local tt = t * 2

		surface.DrawOutlinedRect(x + t, y + t, w - tt, h - tt)
	end

	surface.SetDrawColor(colMain:Unpack())
	surface.DrawRect(x, y, w, h)

	BASE.Render(self)
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	local text_panel = self.TextPanel
	if not IsValid(text_panel) then
		return
	end

	local padding = self:GetPadding()
	local w, h = text_panel:GetSize()
	local nw, nh = w + padding * 2, h + padding * 2

	self:SetSize(nw, nh)
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

function CLASS:IsInBounds(x, y)
	return false
end

function CLASS:OnModelSetup(setup)
	BASE.OnModelSetup(self, setup)

	if setup.font then
		self:SetFont(setup.font)
	end
end

return true

