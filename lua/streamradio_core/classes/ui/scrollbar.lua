local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

local g_mat_up = StreamRadioLib.GetPNGIcon("scroll_up", true)
local g_mat_down = StreamRadioLib.GetPNGIcon("scroll_down", true)
local g_mat_left = StreamRadioLib.GetPNGIcon("scroll_left", true)
local g_mat_right = StreamRadioLib.GetPNGIcon("scroll_right", true)

function CLASS:Create()
	BASE.Create(self)

	self.Layout.IsHorizontal = true

	self.Scroll = self:CreateListener({
		Pos = 0,
		Max = 0,
	}, function(this, k, v)
		self:InvalidateLayout()

		if k == "Max" then
			if v < 0 then
				v = 0
				self.Scroll.Max = v
				return
			end

			self:SetNWInt("ScrollMax", v)
			self:CallHook("OnScroll", self:GetScroll())
		end

		if k == "Pos" then
			if v < 0 then
				v = 0
				self.Scroll.Pos = v
				return
			end

			self:SetNWInt("ScrollPos", v)
			self:CallHook("OnScroll", v)
		end
	end)

	self.BarButton = self:AddPanelByClassname("button", true)
	self.BarButton:SetName("bar")
	self.BarButton:SetNWName("bar")
	self.BarButton:SetSkinIdentifyer("bar")
	self:_TreatIconAsText(self.BarButton)

	self.BarButton.DoClick = function()
		if self:IsInputDisabled() then return end
		self:DoClick()

		self.BarButton.IsPressed = false
		self.IsPressed = true

		local sp = self:GetSuperParent()
		sp.LastClickedPanel = self
	end

	self.BarButton.OnMouseReleased = function()
		if self:IsInputDisabled() then return end
		self:OnMouseReleased()
	end

	self.LeftUpButton = self:AddPanelByClassname("button", true)
	self.LeftUpButton:SetName("left-up")
	self.LeftUpButton:SetNWName("lup")
	self.LeftUpButton:SetSkinIdentifyer("button")
	self:_TreatIconAsText(self.LeftUpButton)

	self.LeftUpButton.DoClick = function()
		if self:IsInputDisabled() then return end
		self:SetScroll(self:GetScroll() - 1)
	end

	self.RightDownButton = self:AddPanelByClassname("button", true)
	self.RightDownButton:SetName("right-down")
	self.RightDownButton:SetNWName("rdn")
	self.RightDownButton:SetSkinIdentifyer("button")
	self:_TreatIconAsText(self.RightDownButton)

	self.RightDownButton.DoClick = function()
		if self:IsInputDisabled() then return end
		self:SetScroll(self:GetScroll() + 1)
	end

	self:QueueCall("ClearInvisible")
end

function CLASS:_TreatIconAsText(button)
	if not IsValid(button) then return end

	button.SkinMap = button.SkinMap or {}

	button.SkinMap["color_foreground"] = {
		set = "SetIconColor",
		get = "GetIconColor",
	}

	button.SkinMap["color_foreground_hover"] = {
		set = "SetIconHoverColor",
		get = "GetIconHoverColor",
	}

	button.SkinMap["color_foreground_disabled"] = {
		set = "SetIconDisabledColor",
		get = "GetIconDisabledColor",
	}

	button.SkinMap["color_icon"] = nil
	button.SkinMap["color_icon_hover"] = nil
	button.SkinMap["color_icon_disabled"] = nil

	button:SetText("")
	button.SetText = (function() end)
end


local function GetBarSpaceSize(len, margin, buttonsize)
	return len - (buttonsize + margin) * 2
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	local lu_button = self.LeftUpButton
	local rd_button = self.RightDownButton
	local bar_button = self.BarButton

	if not IsValid(lu_button) then
		return
	end

	if not IsValid(rd_button) then
		return
	end

	if not IsValid(bar_button) then
		return
	end

	local ishorizontal = self:GetHorizontal()
	local buttonsize = self:GetSquareSize()

	lu_button:SetSize(buttonsize, buttonsize)
	rd_button:SetSize(buttonsize, buttonsize)

	-- Force position change trigger
	lu_button:SetPos(0, 1)
	lu_button:SetPos(0, 0)

	local w, h = self:GetClientSize()
	local margin = self:GetMargin()
	local scoll = self:GetScroll()
	local maxscoll = self:GetMaxScroll() + 1
	local minbarsize = buttonsize / 2

	local noscroll = maxscoll <= 1

	lu_button:SetDisabled(noscroll or scoll <= 0)
	rd_button:SetDisabled(noscroll or scoll >= (maxscoll - 1))
	bar_button:SetDisabled(noscroll)
	self:SetDisabled(noscroll)

	if ishorizontal then
		local len = GetBarSpaceSize(w, margin, buttonsize)
		self.ScrollLen = len

		local barsize = len / maxscoll
		local barpos = buttonsize + margin + barsize * scoll

		if barsize < minbarsize then
			barsize = minbarsize
		end

		local maxbarpos = len - barsize + buttonsize + margin
		if barpos > maxbarpos then
			barpos = maxbarpos
		end

		bar_button:SetPos(barpos, 0)
		bar_button:SetSize(barsize, buttonsize)
		rd_button:SetPos(w - buttonsize, 0)

		lu_button:SetIcon(g_mat_left)
		rd_button:SetIcon(g_mat_right)
	else
		local len = GetBarSpaceSize(h, margin, buttonsize)
		self.ScrollLen = len

		local barsize = len / maxscoll
		local barpos = buttonsize + margin + barsize * scoll

		if barsize < minbarsize then
			barsize = minbarsize
		end

		local maxbarpos = len - barsize + buttonsize + margin
		if barpos > maxbarpos then
			barpos = maxbarpos
		end

		bar_button:SetPos(0, barpos)
		bar_button:SetSize(buttonsize, barsize)
		rd_button:SetPos(0, h - buttonsize)

		lu_button:SetIcon(g_mat_up)
		rd_button:SetIcon(g_mat_down)
	end

	lu_button:QueueCall("ClearInvisible")
	rd_button:QueueCall("ClearInvisible")
	bar_button:QueueCall("ClearInvisible")
end

function CLASS:DoScroll()
	BASE.CursorChangedInternal(self)

	local lu_button = self.LeftUpButton
	local rd_button = self.RightDownButton
	local bar_button = self.BarButton
	local scrolllen = self.ScrollLen

	if not IsValid(lu_button) then
		return
	end

	if not IsValid(rd_button) then
		return
	end

	if not IsValid(bar_button) then
		return
	end

	if not scrolllen then
		return
	end

	local cx, cy = self:GetCursorRelative()

	local ishorizontal = self:GetHorizontal()
	local buttonsize = self:GetSquareSize()

	local margin = self:GetMargin()
	local shadow = bar_button:GetShadowWidth()
	local maxscoll = self:GetMaxScroll() + 1
	local scroll = 0

	cx = cx - buttonsize
	cy = cy - buttonsize

	local maxcx = buttonsize - shadow
	local maxcy = maxcx

	if ishorizontal then
		local barsize = scrolllen / maxscoll
		if barsize <= 0 then return end

		scroll = cx / barsize
	else
		local barsize = scrolllen / maxscoll
		if barsize <= 0 then return end

		scroll = cy / barsize
	end

	if scroll < 0 then return end
	if scroll > maxscoll then return end

	self:SetScroll(scroll)
end

function CLASS:Think()
	self.thinkRate = 0.1

	local lu_button = self.LeftUpButton
	local rd_button = self.RightDownButton
	local scrolllen = self.ScrollLen

	if not IsValid(lu_button) then
		self.tmpscroll = nil
		return
	end

	if not IsValid(rd_button) then
		self.tmpscroll = nil
		return
	end

	if not scrolllen then
		self.tmpscroll = nil
		return
	end

	if not lu_button.IsPressed and not rd_button.IsPressed then
		self.tmpscroll = nil
		return
	end

	if lu_button.IsPressed and rd_button.IsPressed then
		self.tmpscroll = nil
		return
	end

	local acive_button = lu_button
	local scolldir = -1

	if rd_button.IsPressed then
		acive_button = rd_button
		scolldir = 1
	end

	local scoll = self.tmpscroll or self:GetScroll()
	local maxscoll = self:GetMaxScroll()
	local scollrate = 10

	local lastclicktime = acive_button.LastClickTime or 0
	local clickdistance = RealTime() - lastclicktime

	local lastthink = self.lastthink or RealTime()
	self.lastthink = RealTime()

	local thinkdistance = RealTime() - lastthink

	if clickdistance > 0.5 then
		self.tmpscroll = scoll + scolldir * thinkdistance * scollrate
		self:SetScroll(self.tmpscroll)
	end
end

function CLASS:CursorChangedInternal()
	BASE.CursorChangedInternal(self)

	if not self.IsPressed then return end
	self:DoScroll()
end

function CLASS:DoClick()
	self:DoScroll()
end

function CLASS:OnMouseReleased()
	self:DoScroll()
end

function CLASS:SetScroll(scroll)
	self.Scroll.Pos = math.Clamp(math.floor(scroll or 0), 0, self.Scroll.Max)
end

function CLASS:GetScroll()
	return math.Clamp(self.Scroll.Pos, 0, self.Scroll.Max)
end

function CLASS:SetMaxScroll(max)
	max = max or 0

	if max <= 0 then
		max = 0
	end

	self.Scroll.Max = math.floor(max)
end

function CLASS:GetMaxScroll()
	return self.Scroll.Max or 0
end

function CLASS:IsScrollAble()
	return self:GetMaxScroll() > 0
end

function CLASS:SetHorizontal(horizontal)
	self.Layout.IsHorizontal = horizontal or false
end

function CLASS:GetHorizontal()
	return self.Layout.IsHorizontal or false
end

function CLASS:AutoSetHorizontal()
	local w, h = self:GetClientSize()
	self:SetHorizontal(w >= h)
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)
	if SERVER then
		self:SetNWInt("ScrollPos", self.Scroll.Pos or 0)
		self:SetNWInt("ScrollMax", self:GetMaxScroll())

		return
	end

	self:SetNWVarCallback("ScrollPos", "Int", function(this, nwkey, oldvar, newvar)
		self.Scroll.Pos = newvar
	end)

	self:SetNWVarCallback("ScrollMax", "Int", function(this, nwkey, oldvar, newvar)
		self:SetMaxScroll(newvar)
	end)

	self.Scroll.Pos = self:GetNWInt("ScrollPos", 0)
	self:SetMaxScroll(self:GetNWInt("ScrollMax", 0))
end

function CLASS:PreDupe()
	local data = {}

	data.Scroll = self:GetScroll()

	return data
end

function CLASS:PostDupe(data)
	self:SetScroll(data.Scroll)
	self.DupeData = data
end

function CLASS:SetColor(...)
	if SERVER then return end

	self.LeftUpButton:SetColor(...)
	self.RightDownButton:SetColor(...)
	self.BarButton:SetColor(...)
end

function CLASS:GetColor(...)
	if SERVER then return end
	return self.BarButton:GetColor(...)
end

function CLASS:SetHoverColor(...)
	if SERVER then return end

	self.LeftUpButton:SetHoverColor(...)
	self.RightDownButton:SetHoverColor(...)
	self.BarButton:SetHoverColor(...)
end

function CLASS:GetHoverColor(...)
	if SERVER then return end
	return self.BarButton:GetHoverColor(...)
end

function CLASS:SetDisabledColor(...)
	if SERVER then return end

	self.LeftUpButton:SetDisabledColor(...)
	self.RightDownButton:SetDisabledColor(...)
	self.BarButton:SetDisabledColor(...)
end

function CLASS:GetDisabledColor(...)
	if SERVER then return end
	return self.BarButton:GetDisabledColor(...)
end

function CLASS:SetTextColor(...)
	if SERVER then return end

	self.LeftUpButton:SetTextColor(...)
	self.RightDownButton:SetTextColor(...)
	self.BarButton:SetTextColor(...)
end

function CLASS:GetTextColor(...)
	if SERVER then return end
	return self.BarButton:GetTextColor(...)
end

function CLASS:SetTextHoverColor(...)
	if SERVER then return end

	self.LeftUpButton:SetTextHoverColor(...)
	self.RightDownButton:SetTextHoverColor(...)
	self.BarButton:SetTextHoverColor(...)
end

function CLASS:GetTextHoverColor(...)
	if SERVER then return end
	return self.BarButton:GetTextHoverColor(...)
end

function CLASS:SetTextDisabledColor(...)
	if SERVER then return end

	self.LeftUpButton:SetTextDisabledColor(...)
	self.RightDownButton:SetTextDisabledColor(...)
	self.BarButton:SetTextDisabledColor(...)
end

function CLASS:GetTextDisabledColor(...)
	if SERVER then return end
	return self.BarButton:GetTextDisabledColor(...)
end

function CLASS:OnModelSetup(setup)
	BASE.OnModelSetup(self, setup)

	if setup.font then
		self:SetFont(setup.font)
	end
end

return true

