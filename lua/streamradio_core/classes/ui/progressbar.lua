local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

function CLASS:Create()
	BASE.Create(self)

	self.Progress = self:CreateListener({
		Fraction = 0,
		AllowEdit = false,
	}, function(this, k, v)
		if k == "Fraction" then
			if v > 1 then
				self.Progress.Fraction = 1
				return
			end

			if v < 0 then
				self.Progress.Fraction = 0
				return
			end

			self:CallHook("OnFractionChange", v)
			self:UpdateText()

			self:SetNWFloat("Fraction", v)
			self:InvalidateLayout(true)
		end

		if k == "AllowEdit" then
			self:SetNWBool(k, v)
			self:InvalidateLayout()
		end
	end)

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
			if k == "Main" then
				self.Colors.Secondary = Color(
					v.r * 0.65,
					v.g * 0.65,
					v.b * 0.65,
					v.a * 0.75
				)

				return
			end

			if k == "Secondary" then
				return
			end
	
			self:QueueCall("UpdateColor")
		end
	end

	self.CanHaveLabel = true
	self.SkinAble = true
	self:SetAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	self:QueueCall("UpdateText")
	self:InvalidateLayout()
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	self:QueueCall("UpdateColor")
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

		if IsValid(self.TextPanel) then
			self.TextPanel:SetColor(self.Colors.DisabledText)
		end

		return
	end

	if self.Progress.AllowEdit and self:IsCursorOnPanel() then
		self.Colors.Main = self.Colors.Hover

		if IsValid(self.TextPanel) then
			self.TextPanel:SetColor(self.Colors.HoverText)
		end

		return
	end

	self.Colors.Main = self.Colors.NoHover

	if IsValid(self.TextPanel) then
		self.TextPanel:SetColor(self.Colors.NoHoverText)
	end
end

function CLASS:Render()
	local x, y = self:GetRenderPos()
	local w, h = self:GetSize()
	local shadowWidth = self:GetShadowWidth()

	local col1 = self.Colors.Main or color_white
	local col2 = self.Colors.Secondary or color_white

	local fraction1 = self.Progress.Fraction

	if shadowWidth <= 0 then
		surface.SetDrawColor(col1:Unpack())
		surface.DrawRect(x, y, w, h)

		surface.SetDrawColor(col2:Unpack())
		surface.DrawRect(x, y, w * fraction1, h)

		return
	end

	local colShadow = self.Colors.Shadow or color_black

	local sx, sy = x + shadowWidth, y + shadowWidth
	local sw, sh = w - shadowWidth, h - shadowWidth

	surface.SetDrawColor(colShadow:Unpack())
	surface.DrawRect(sx, sy, sw, sh)
	surface.SetDrawColor(col1:Unpack())
	surface.DrawRect(x, y, sw, sh)
	surface.SetDrawColor(col2:Unpack())
	surface.DrawRect(x, y, sw * fraction1, sh)
end

function CLASS:DoEditProgress(force)
	if self:IsDisabled() then
		return
	end

	if not self.Progress.AllowEdit then
		return
	end

	if CLIENT and self.Network.Active then
		return
	end

	BASE.CursorChangedInternal(self)

	local cx = self:GetCursorRelative()
	local w = self:GetClientSize()

	local fraction = 0
	if w > 0 then
		fraction = math.Clamp(cx / w, 0, 1)
	end

	fraction = self:CallHook("OnFractionChangeEdit", fraction) or fraction

	self:SetFraction(fraction)
end

function CLASS:CursorChangedInternal()
	BASE.CursorChangedInternal(self)

	if not self.IsPressed then return end
	self:DoEditProgress()
end

function CLASS:DoClick()
	self:DoEditProgress()
end

function CLASS:OnMouseReleased()
	self:DoEditProgress()
end

function CLASS:UpdateText()
	local text = tostring(self:CallHook("FractionChangeText", self.Progress.Fraction) or "")
	self:SetText(text)
end

function CLASS:FractionChangeText(fraction)
	return math.Round(fraction * 100) .. "%"
end

function CLASS:SetFraction(fraction)
	self.Progress.Fraction = fraction or 0
end

function CLASS:GetFraction()
	return self.Progress.Fraction or 0
end

function CLASS:SetAllowFractionEdit(bool)
	self.Progress.AllowEdit = bool or false
end

function CLASS:GetAllowFractionEdit()
	return self.Progress.AllowEdit or false
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


function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)

	if SERVER then
		self:SetNWFloat("Fraction", self:GetFraction())
		self:SetNWBool("AllowEdit", self:GetAllowFractionEdit())
		return
	end

	self:SetNWVarCallback("Fraction", "Float", function(this, nwkey, oldvar, newvar)
		self:SetFraction(newvar)
	end)

	self:SetNWVarCallback("AllowEdit", "Bool", function(this, nwkey, oldvar, newvar)
		self:SetAllowFractionEdit(newvar)
	end)

	self:SetFraction(self:GetNWFloat("Fraction", 0))
	self:SetAllowFractionEdit(self:GetNWBool("AllowEdit", false))
end

function CLASS:PreDupe()
	local data = {}

	data.Fraction = self:GetFraction()
	data.AllowEdit = self:GetAllowFractionEdit()

	return data
end

function CLASS:PostDupe(data)
	self:SetFraction(data.Fraction)
	self:SetAllowFractionEdit(data.AllowEdit)
end

return true

