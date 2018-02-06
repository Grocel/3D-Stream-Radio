if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

function CLASS:PreAssignToListenGroup()
	local group = tonumber(self:GetGlobalVar("gui_controller_listengroup")) or self:GetID()
	return group
end

function CLASS:Create()
	BASE.Create(self)

	self.Pos = self:CreateListener({
		x = 0,
		y = 0,
	}, function()
		self:InvalidateLayout(true)
		self:CallHook("OnPositionChanged")
	end)

	self.Size = self:CreateListener({
		w = 0,
		h = 0,
	}, function()
		self:InvalidateLayout(true)
		self:CallHook("OnResize")
	end)

	local updateothers = function(this, panel)
		if panel == self then return end
		panel:InvalidateLayout(false, true)
	end

	local recache = function(this)
		this._ChildrenPanelsSorted = nil
		this:DelCacheValue("IsVisible")
		this:DelCacheValue("GetClickPanel")
		this:DelCacheValue("GetPanelsAtCursor")
		this:DelCacheValue("GetTopmostPanelAtCursor")
	end

	self.SkinMap = {}

	self.Layout = self:CreateListener({
		Disabled = false,
		Padding = 0,
		Margin = 5,
		ZIndex = 0,
		Visible = true,
		Tooltip = "",
	}, function(this, k, v)
		self:InvalidateLayout()

		if k == "Disabled" then
			if v then
				self:ReleaseClick()
			end
		end

		if k == "ZIndex" or k == "Visible" then
			recache(self)

			local parent = self:GetParent()
			if not IsValid(parent) then return end

			recache(parent)
			parent:ForEachChild(updateothers)
		end

		if k == "Visible" then
			if v then
				self:ApplyNetworkedMode()

				self:CallHook("OnOpen")
				self:StartListenRecursive()
			else
				self:CallHook("OnClose")
				self:ReleaseClick()
				self:StopListenRecursive()
			end
		end
	end)

	self._ChildrenPanels = {}
	self._ChildrenPanelsSorted = nil

	self.Parent = nil
	self.SuperParent = self

	self.Clickable = true
	self.IsPressed = false
	self.SkinAble = false

	self.SkinMap["color"] = {
		set = "SetColor",
		get = "GetColor",
	}

	if CLIENT then
		self.Colors = self:CreateListener({
			Main = Color(255,255,255)
		}, function(...)
			self:_PerformRerenderInternal()
		end)
	end

	self:Clear()
	self:InvalidateLayout()
end

function CLASS:Initialize()
	self:DelCacheValue("GetAbsolutePos")
	self:DelCacheValue("GetRenderPos")
	self:DelCacheValue("IsVisible")
	self:DelCacheValue("GetClickPanel")
	self:DelCacheValue("GetPanelsAtCursor")
	self:DelCacheValue("GetTopmostPanelAtCursor")

	self:ApplyHierarchy()
	self:RegisterForDupe()
end

function CLASS:Remove(childmode)
	self:ForEachChild(function(this, panel)
		panel:Remove(true)
	end)

	self._ChildrenPanels = {}
	self._ChildrenPanelsSorted = nil

	if childmode then
		BASE.Remove(self)
		return
	end

	self:SetParent(nil)
	BASE.Remove(self)
end

function CLASS:InvalidateLayout(layoutnow, nochildren)
	if layoutnow then
		self:PerformLayout(nochildren)
		return
	end

	self:QueueCall("PerformLayout", nochildren)
end

function CLASS:_PerformRerenderInternal()
	self:QueueCall("PerformRerender")
end

function CLASS:PerformRerender(force)
	if not force and not self._rendered then return end
	self._rendered = false

	self:GetSuperParent():CallHook("OnContentChanged")
end

local function CursorChangedInternalFunc(this, panel)
	if not panel.Clickable then return end
	if not panel:IsVisible() then return end
	panel:CursorChangedInternal()
end

function CLASS:CursorChangedInternal(nochildren)
	self:DelCacheValue("IsVisible")
	self:DelCacheValue("GetClickPanel")
	self:DelCacheValue("GetPanelsAtCursor")
	self:DelCacheValue("GetTopmostPanelAtCursor")

	self:_OpenToolTipPanel()

	if nochildren then return end

	if not self:IsCursorInBounds() or not self.Clickable or not self:IsVisible() then
		self._CursorChangedInternalOutCount = (self._CursorChangedInternalOutCount or 0) - 1

		if self._CursorChangedInternalOutCount <= 0 then
			return
		end
	else
		self._CursorChangedInternalOutCount = 2
	end

	self:ForEachChild(CursorChangedInternalFunc)
end

local function PerformLayoutFunc(this, panel)
	panel:InvalidateLayout(true)
end

function CLASS:PerformLayout(nochildren)
	self:DelCacheValue("GetAbsolutePos")
	self:DelCacheValue("GetRenderPos")
	self:DelCacheValue("IsVisible")
	self:DelCacheValue("GetClickPanel")
	self:DelCacheValue("GetPanelsAtCursor")
	self:DelCacheValue("GetTopmostPanelAtCursor")

	self:ForEachChild(PerformLayoutFunc)
	self:CursorChangedInternal(true)
	self:PerformRerender(true)

	self:DelCacheValue("GetAbsolutePos")
	self:DelCacheValue("GetRenderPos")
	self:DelCacheValue("IsVisible")
	self:DelCacheValue("GetClickPanel")
	self:DelCacheValue("GetPanelsAtCursor")
	self:DelCacheValue("GetTopmostPanelAtCursor")

	self:CallHook("OnPerformLayout")
end

local function RenderInternalPanel(this, panel)
	if not panel._RenderInternal then return end
	panel:_RenderInternal()
end

function CLASS:_RenderInternal()
	if SERVER then return end
	if not self.Valid then return end

	if not self:IsVisible() then
		self._rendered = true
		return
	end

	self:Render()
	self:ForEachChild(RenderInternalPanel, true)

	self._rendered = true
end

local coldebug = Color(0,0,0,200)

function CLASS:Render()
	if not self.debugborders then return end

	local x, y = self:GetRenderPos()
	local w, h = self:GetSize()

	surface.SetDrawColor( coldebug )
	surface.DrawOutlinedRect(x, y, w, h)
	surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2)
end

local function StartListenRecursiveFunc(this, panel)
	panel:StartListenRecursive()
end

local function StopListenRecursiveFunc(this, panel)
	panel:StopListenRecursive()
end

function CLASS:StartListenRecursive()
	self.CanListen = true
	self:ForEachChild(StartListenRecursiveFunc)
	self:StartListen()
end

function CLASS:StopListenRecursive()
	self.CanListen = false
	self:ForEachChild(StopListenRecursiveFunc)
	self:StopListen()
end

function CLASS:_SortPanels()
	if not self.Valid then return end
	if self._ChildrenPanelsSorted then return end

	local tmp = {}
	for _, panel in pairs(self._ChildrenPanels) do
		if not IsValid(panel) then continue end
		if panel == self then continue end
		if panel:GetParent() ~= self then continue end

		table.insert(tmp, panel)
	end

	table.sort(tmp, function(a, b)
		local a_strong_composition = a._strong_composition and 1 or -1
		local b_strong_composition = b._strong_composition and 1 or -1

		if a_strong_composition ~= b_strong_composition then
			return a_strong_composition < b_strong_composition
		end

		local a_zindex = a:GetZPos()
		local b_zindex = b:GetZPos()

		if a_zindex ~= b_zindex then
			return a_zindex > b_zindex
		end

		return a:GetID() > b:GetID()
	end)

	self._ChildrenPanelsSorted = {}
	for _, panel in pairs(tmp) do
		table.insert(self._ChildrenPanelsSorted, panel)
	end
end

function CLASS:AddPanel(panel, strong_composition)
	if not IsValid(panel) then return end
	if panel == self then return end

	local id = tostring(panel)
	if IsValid(self._ChildrenPanels[id]) then return self._ChildrenPanels[id] end

	self._ChildrenPanels[id] = panel
	self._ChildrenPanelsSorted = nil

	panel:SetParent(self)
	panel:ApplyHierarchy()
	panel._strong_composition = strong_composition or false

	panel:InvalidateLayout()
	self:InvalidateLayout()

	self:QueueCall("_SetSkinAfterAddedPanel")
	self:QueueCall("_SetModelSetupAfterAddedPanel")
	return panel
end

function CLASS:AddPanelByClassname(name, ...)
	local panel = StreamRadioLib.CreateOBJ("ui/" .. name)
	return self:AddPanel(panel, ...)
end

function CLASS:RemovePanel(panel)
	if not IsValid(panel) then return end
	if panel == self then return end

	local id = tostring(panel)
	if not self._ChildrenPanels[id] then return panel end

	panel:SetParent(nil)
	panel:ApplyHierarchy()

	self._ChildrenPanels[id] = nil
	self._ChildrenPanelsSorted = nil

	if panel._strong_composition then
		panel:Remove()

		self:InvalidateLayout()
		return nil
	end

	self:InvalidateLayout()
	panel:InvalidateLayout()

	return panel
end

function CLASS:Clear()
	self:ForEachChild("RemovePanel")
	self._ChildrenPanels = {}
	self._ChildrenPanelsSorted = nil

	self:InvalidateLayout(true)
end

function CLASS:ClearInvisible()
	self:ForEachChild(function(this, panel)
		if not IsValid(panel) then return end
		if panel:IsVisible() then return end

		self:RemovePanel(panel)
	end)

	self._ChildrenPanelsSorted = nil
	self:InvalidateLayout(true)
end

function CLASS:ForEachParent(func)
	func = self:GetFunction(func)
	if not func then
		return nil
	end

	local once = {}
	local curparent = self:GetParent()

	while true do
		if not IsValid(curparent) then break end
		if once[curparent] then break end
		once[curparent] = true

		local rv = func(self, curparent)
		if rv ~= nil then
			return rv
		end

		curparent = curparent:GetParent()
	end

	return nil
end

function CLASS:ForEachChild(func, reverse)
	self:_SortPanels()
	local children = self._ChildrenPanelsSorted

	func = self:GetFunction(func)
	if not func then
		return nil
	end

	if not children then
		return nil
	end

	local invalid = false
	local len = #children

	if len <= 0 then
		return nil
	end

	if reverse then
		for i = len, 1, -1 do
			local panel = children[i]
			if not IsValid(panel) then
				invalid = true
				continue
			end

			local rv = func(self, panel)
			if rv ~= nil then
				return rv
			end
		end
	else
		for i = 1, len do
			local panel = children[i]
			if not IsValid(panel) then
				invalid = true
				continue
			end

			local rv = func(self, panel)
			if rv ~= nil then
				return rv
			end
		end
	end

	if invalid then
		self._ChildrenPanelsSorted = nil
		self:_SortPanels(true)
	end

	return nil
end

function CLASS:ForEachChildRecursive(func, reverse)
	func = self:GetFunction(func)
	if not func then
		return
	end

	local nodouble = {}

	local function recursive(this, child)
		if nodouble[child] then
			return
		end

		local rv = func(self, child)
		nodouble[child] = true

		if rv ~= nil then
			return rv
		end

		return child:ForEachChild(recursive, reverse)
	end

	return self:ForEachChild(recursive, reverse)
end

function CLASS:GetPanelByName(name)
	name = StreamRadioLib.GetHierarchy(name)
	local maxlevel = #name

	local panel = self

	for level, v in ipairs(name) do
		if not IsValid(panel) then break end

		if not panel._panelmap then break end
		if not panel._panelmap.names then break end

		panel = panel._panelmap.names[v]

		if level >= maxlevel then
			return panel
		end
	end

	return nil
end

function CLASS:GetPanelsBySkinIdentifyer(name)
	name = StreamRadioLib.GetHierarchy(name)
	local maxlevel = #name
	local panels = {}

	local function recusive(thispanel, level)
		if not IsValid(thispanel) then return end

		local thisname = name[level] or ""

		if level > maxlevel then
			table.insert(panels, thispanel)
			return
		end

		if not thispanel._panelmap then return end
		if not thispanel._panelmap.skin then return end

		for k, panel in pairs(thispanel._panelmap.skin[thisname] or {}) do
			recusive(panel, level + 1)
		end
	end

	recusive(self, 1)

	return panels
end

function CLASS:ReleaseClick()
	if not self.IsPressed then
		return
	end

	self.IsPressed = false
	self:CallHook("OnMouseReleased")
end

function CLASS:Click(pressed)
	if not pressed then
		local sp = self:GetSuperParent()
		local LastClickedPanel = sp.LastClickedPanel

		if IsValid(LastClickedPanel) then
			LastClickedPanel:ReleaseClick()
			sp.LastClickedPanel = nil
		end

		self:ReleaseClick()
		return
	end

	local panel = self:GetClickPanel()
	if not IsValid(panel) then return end

	if panel ~= self then
		panel:Click(pressed)
		return
	end

	if self:IsInputDisabled() then return end
	if self:IsDisabled() then return end

	local sp = self:GetSuperParent()
	local LastClickedPanel = sp.LastClickedPanel

	if IsValid(LastClickedPanel) and LastClickedPanel ~= self then
		LastClickedPanel:ReleaseClick()
	end

	self.IsPressed = pressed

	if pressed then
		sp.LastClickedPanel = self

		local lastclicktime = self.LastClickTime or 0
		self.LastClickTime = RealTime()

		local clickdistance = self.LastClickTime - lastclicktime

		if clickdistance < 0.5 and isfunction(self.DoDoubleClick) then
			self:DoDoubleClick()
		end

		self:CallHook("DoClick")
	else
		sp.LastClickedPanel = nil
		self:CallHook("OnMouseReleased")
	end
end

local function GetFirstClickableChildPanel(this, panel)
	if not panel.Clickable then return end
	if not panel:IsVisible() then return end
	if not panel:IsCursorInBounds() then return end

	return panel
end

function CLASS:GetClickPanel()
	if not self:IsVisible() then return end
	if not self:IsCursorInBounds() then return end

	local chpanel = self:GetCacheValue("GetClickPanel")
	if IsValid(chpanel) then
		return chpanel
	end

	local panel = self:ForEachChild(GetFirstClickableChildPanel)

	if not IsValid(panel) then
		panel = GetFirstClickableChildPanel(self, self) or self
	end

	return self:SetCacheValue("GetClickPanel", panel)
end

function CLASS:IsCursorInBounds()
	local cxr, cyr = self:GetCursorRelative()
	return self:IsInBounds(cxr, cyr)
end

function CLASS:IsCursorOnPanel()
	local parent = self:GetParent()

	local self_onself = self:GetClickPanel() == self
	if not IsValid(parent) then
		return self_onself
	end

	return self_onself and parent:GetClickPanel() == self
end

function CLASS:IsInBounds(x, y)
	local w, h = self:GetSize()

	if x < 0 then return false end
	if x > w then return false end
	if y < 0 then return false end
	if y > h then return false end

	return true
end

function CLASS:GetPanelsAtCursor()
	local chpanels = self:GetCacheValue("GetPanelsAtCursor")
	if IsValid(chpanels) then
		return chpanels
	end

	local cx, cy = self:GetCursor()
	local panels = self:GetPanelsAtPos(cx, cy)

	return self:SetCacheValue("GetPanelsAtCursor", panels)
end

function CLASS:GetPanelsAtPos(x, y)
	local panels = {}

	local function func(this, panel)
		if not panel:IsVisible() then return end

		local px, py = panel:GetAbsolutePos()
		if not panel:IsInBounds(x - px, y - py) then return end

		table.insert(panels, panel)
	end

	func(self, self)
	self:ForEachChildRecursive(func)

	return panels
end

function CLASS:GetTopmostPanelAtCursor()
	local chpanel = self:GetCacheValue("GetTopmostPanelAtCursor")
	if IsValid(chpanel) then
		return chpanel
	end

	local panels = self:GetPanelsAtCursor()

	local area = nil
	local panel = nil

	for i, v in ipairs(panels) do
		local w, h = v:GetSize()
		local a = w * h

		if not area or area >= a then
			area = a
			panel = v
		end
	end

	return self:SetCacheValue("GetTopmostPanelAtCursor", panel)
end

function CLASS:GetAbsolutePos()
	local chx, chy = self:GetCacheValues("GetAbsolutePos")
	if chx then
		return chx, chy
	end

	local getpos = self.GetClientPos or self.GetPos
	local x, y = getpos(self)

	local parent = self:GetParent()
	if not IsValid(parent) then
		return self:SetCacheValues("GetAbsolutePos", x, y)
	end

	local px, py = parent:GetAbsolutePos()

	return self:SetCacheValues("GetAbsolutePos", px + x, py + y)
end

function CLASS:GetRenderPos()
	local chx, chy = self:GetCacheValues("GetRenderPos")
	if chx then
		return chx, chy
	end

	local getpos = self.GetClientPos or self.GetPos
	local x, y = getpos(self)

	local parent = self:GetParent()
	if not IsValid(parent) then
		return self:SetCacheValues("GetRenderPos", x, y)
	end

	local px, py = parent:GetRenderPos()

	return self:SetCacheValues("GetRenderPos", px + x, py + y)
end

function CLASS:GetArea()
	local x, y = self:GetPos()
	local w, h = self:GetSize()

	return x, y, x + w, y + h
end

function CLASS:SetPos(x, y)
	self.Pos.x = x or 0
	self.Pos.y = y or 0
end

function CLASS:GetPos()
	return self.Pos.x or 0, self.Pos.y or 0
end

function CLASS:SetPosX(x)
	self.Pos.x = x or 0
end

function CLASS:GetPosX()
	return self.Pos.x or 0
end

function CLASS:SetPosY(y)
	self.Pos.y = y or 0
end

function CLASS:GetPosY()
	return self.Pos.y or 0
end

function CLASS:GetClientPos()
	local x, y = self:GetPos()
	local parent = self:GetParent()

	if not IsValid(parent) then return x, y end
	local p = parent:GetPadding()

	return x + p, y + p
end

function CLASS:SetSize(w, h)
	w = w or 0
	h = h or 0

	if w < 0 then
		w = 0
	end

	if h < 0 then
		h = 0
	end

	self.Size.w = w
	self.Size.h = h
end

function CLASS:SetWidth(w)
	w = w or 0

	if w < 0 then
		w = 0
	end

	self.Size.w = w
end

function CLASS:SetHeight(h)
	h = h or 0

	if h < 0 then
		h = 0
	end

	self.Size.h = h
end

function CLASS:GetSize()
	return self.Size.w or 0, self.Size.h or 0
end

function CLASS:GetWidth()
	return self.Size.w or 0
end

function CLASS:GetHeight()
	return self.Size.h or 0
end

function CLASS:GetClientSize()
	local w, h = self:GetSize()
	local p = 2 * self:GetPadding()

	w = w - p
	h = h - p

	if w < 0 then
		w = 0
	end

	if h < 0 then
		h = 0
	end

	return w, h
end

function CLASS:GetClientWidth()
	local w = self:GetWidth()
	local p = 2 * self:GetPadding()

	w = w - p

	if w < 0 then
		w = 0
	end

	return w
end

function CLASS:GetClientHeight()
	local h = self:GetHeight()
	local p = 2 * self:GetPadding()

	h = h - p

	if h < 0 then
		h = 0
	end

	return h
end

function CLASS:GetSquareSize()
	local w, h = self:GetClientSize()

	local square = w

	if square > h then
		square = h
	end

	return square
end

function CLASS:SetColor(color)
	if SERVER then return end
	self.Colors.Main = color
end

function CLASS:GetColor()
	if SERVER then return end
	local col = self.Colors.Main

	return Color(col.r or 0, col.g or 0, col.b or 0, col.a or 0)
end

function CLASS:SetParent(panel)
	local oldpanel = self:GetParent()

	if oldpanel == panel then return end
	if panel == self then
		error("Do not set the parent to self!", 2)
	end

	self.Parent = panel

	if IsValid(oldpanel) then
		oldpanel:RemovePanel(self)
	end

	if IsValid(panel) then
		panel:AddPanel(self)
	end
end

function CLASS:GetParent()
	return self.Parent
end

function CLASS:GetSuperParent()
	return self.SuperParent
end

function CLASS:CalcSuperParent()
	local superparent = self

	self:ForEachParent(function(this, parent)
		superparent = parent
	end)

	self.SuperParent = superparent
	return self.SuperParent
end

function CLASS:SetToolTip(text)
	if SERVER then return end
	self.Layout.ToolTip = tostring(text or "")
end

function CLASS:GetToolTip()
	if SERVER then return "" end
	return self.Layout.ToolTip or ""
end

-- Alias
CLASS.SetTooltip = CLASS.SetToolTip
CLASS.GetTooltip = CLASS.GetToolTip

function CLASS:GetToolTipPanel()
	if SERVER then return nil end

	local sp = self:GetSuperParent()
	return sp.ToolTip
end

function CLASS:_OpenToolTipPanel()
	if SERVER then return end

	local text = self:GetToolTip()
	if text == "" then return end

	local sp = self:GetSuperParent()
	if not IsValid(sp) then return end
	if not IsValid(sp.ToolTip) then return end
	if not sp.OpenToolTipDelay then return end

	local onpanel = self:IsCursorOnPanel()

	local oldonpanel = self._oldonpanel
	self._oldonpanel = onpanel

	if onpanel == oldonpanel then return end

	if not onpanel then
		sp:CloseToolTip()
		return
	end


	sp:CloseToolTip()
	sp:OpenToolTipDelay(text, 0.75, function()
		local text = self:GetToolTip()
		if text == "" then return false end

		local onpanel = self:IsCursorOnPanel()

		if not onpanel then
			sp:CloseToolTip()
		end

		return onpanel
	end)
end

function CLASS:IsDisabled()
	return self.Layout.Disabled or false
end

function CLASS:IsEnabled()
	return not self.Layout.Disabled
end

function CLASS:SetEnabled(bool)
	self.Layout.Disabled = not bool
end

function CLASS:SetDisabled(bool)
	self.Layout.Disabled = bool or false
end

function CLASS:IsInputDisabled()
	return CLIENT and self.Network.Active
end

function CLASS:SetPadding(padding)
	padding = padding or 0

	if padding < 0 then
		padding = 0
	end

	self.Layout.Padding = padding or 0
end

function CLASS:GetPadding()
	return self.Layout.Padding or 0
end

function CLASS:SetMargin(margin)
	margin = margin or 0

	if margin < 0 then
		margin = 0
	end

	self.Layout.Margin = margin or 0
end

function CLASS:GetMargin()
	return self.Layout.Margin or 0
end

function CLASS:HasChildren()
	self:_SortPanels()
	if not self._ChildrenPanelsSorted then return false end

	return #self._ChildrenPanelsSorted > 0
end


function CLASS:IsSeen()
	local superparent = self:GetSuperParent()

	if superparent == self then
		return true
	end

	return superparent:IsSeen()
end

function CLASS:IsVisible()
	local isvisible = self:GetCacheValue("IsVisible")
	if isvisible ~= nil then
		return isvisible
	end

	local w, h = self:GetSize()
	if w <= 0 then
		return self:SetCacheValue("IsVisible", false)
	end

	if h <= 0 then
		return self:SetCacheValue("IsVisible", false)
	end

	if not self.Layout.Visible then
		return self:SetCacheValue("IsVisible", false)
	end

	local parent = self:GetParent()
	if IsValid(parent) then
		return self:SetCacheValue("IsVisible", parent:IsVisible())
	end

	return true
end

function CLASS:SetVisible(bool)
	self.Layout.Visible = bool or false
end

function CLASS:GetZPos()
	return self.Layout.ZIndex or 0
end

function CLASS:SetZPos(zindex)
	self.Layout.ZIndex = zindex or 0
end

function CLASS:Close()
	self:SetVisible(false)
end

function CLASS:Open()
	self:SetVisible(true)
end

function CLASS:Hide()
	self:SetVisible(false)
end

function CLASS:Show()
	self:SetVisible(true)
end

function CLASS:_GetCursorInternal()
	return -1, -1
end

function CLASS:GetCursor()
	local sp = self:GetSuperParent()
	return sp:_GetCursorInternal()
end

function CLASS:GetCursorRelative()
	local cx, cy = self:GetCursor()
	local posx, posy = self:GetAbsolutePos()

	return cx - posx, cy - posy
end

function CLASS:GetEntity()
	local superparent = self:GetSuperParent()
	return superparent.Entity
end

function CLASS:SetEntity(ent)
	self:ApplyHierarchy()

	local superparent = self:GetSuperParent()
	local oldent = self:GetEntity()
	local name = self:GetName()

	if IsValid(oldent) and oldent._3dstreamradio_classobjs then
		oldent._3dstreamradio_classobjs[name] = nil
	end

	superparent.Entity = ent
	self:RegisterForDupe()
	self:ApplyNetworkedMode()
end

function CLASS:GetNameWithoutHierarchy()
	return self.Name or ""
end

function CLASS:SetName(name)
	self:ApplyHierarchy()

	name = tostring(name or "")
	name = string.gsub(name, "[%/%\\%s]", "_")

	local ent = self:GetEntity()
	local oldname = self:GetName()

	if IsValid(ent) and ent._3dstreamradio_classobjs then
		ent._3dstreamradio_classobjs[oldname] = nil
	end

	self.Name = name
	self:CalcName()

	local parent = self:GetParent()
	if IsValid(parent) then
		parent._panelmap = parent._panelmap or {}
		parent._panelmap.names = parent._panelmap.names or {}
		parent._panelmap.names[oldname] = nil
		parent._panelmap.names[name] = self
	end

	self:RegisterForDupe()
	self:ApplyNetworkedMode()
end

function CLASS:GetName()
	return self.HierarchyName or ""
end

function CLASS:ApplyHierarchy()
	self:CalcSuperParent()
	self:CalcName()
	self:CalcSkinIdentifyer()
end

function CLASS:CalcName()
	local hierarchy = self:CalcHierarchy("GetNameWithoutHierarchy")
	local name = table.concat(hierarchy, "/")

	self.HierarchyName = name
	return self.HierarchyName
end

function CLASS:CalcHierarchy(func)
	local thisfunc = self:GetFunction(func)
	if not thisfunc then return end

	local hierarchy = {}
	table.insert(hierarchy, thisfunc(self))

	self:ForEachParent(function(this, parent)
		local thisfunc = parent:GetFunction(func)
		if not thisfunc then return end

		table.insert(hierarchy, thisfunc(parent))
	end)

	hierarchy = table.Reverse(hierarchy)
	return hierarchy
end

function CLASS:CalcSkinIdentifyer()
	local hierarchy = self:CalcHierarchy("GetSkinIdentifyer")
	table.remove(hierarchy, 1)

	local name = table.concat(hierarchy, "/")

	self.HierarchySkinIdentifyer = name
	return self.HierarchySkinIdentifyer
end

function CLASS:SetSkinIdentifyer(name)
	name = tostring(name or "")
	name = string.gsub(name, "[%/%\\%s]", "_")

	local parent = self:GetParent()
	if IsValid(parent) then
		parent._panelmap = parent._panelmap or {}
		parent._panelmap.skin = parent._panelmap.skin or {}
		parent._panelmap.skin[name] = parent._panelmap.skin[name] or {}

		table.insert(parent._panelmap.skin[name], self)
	end

	self.SkinName = name
	self:CalcSkinIdentifyer()
end

function CLASS:GetSkinIdentifyer(name)
	return self.SkinName or ""
end

function CLASS:IsSkinAble()
	if self:GetSkinIdentifyer() == "" then return false end
	if not self.SkinAble then return false end
	if not self.SkinMap then return false end

	return true
end

function CLASS:SetSkinAble(bool)
	self.SkinAble = bool or false
end

function CLASS:GetSkinIdentifyerHierarchy()
	if not self.HierarchySkinIdentifyer then
		return self:CalcSkinIdentifyer()
	end

	return self.HierarchySkinIdentifyer
end

function CLASS:_SetSkinAfterAddedPanel()
	if not self._skindata then return end
	self:SetSkin(self._skindata)
end

function CLASS:_SetModelSetupAfterAddedPanel()
	if not self._modelsetupdata then return end
	self:SetModelSetup(self._modelsetupdata)
end

function CLASS:SetSkin(skindata)
	if SERVER then return end

	skindata = skindata or {}
	self._skindata = skindata

	local thisdata = skindata.data
	local childrendata = skindata.children

	if thisdata and self:IsSkinAble() then
		if self.SkinMap then
			for k, v in pairs(thisdata) do
				if not self.SkinMap[k] then continue end

				local setter = self:GetFunction(self.SkinMap[k].set)
				if not setter then continue end

				setter(self, v)
			end
		end

		self:CallHook("OnSkin", thisdata)
	end

	if childrendata then
		self:ForEachChild(function(this, panel)
			local name = panel:GetSkinIdentifyer()

			local childdata = childrendata[name]
			if not childdata then return end

			panel:SetSkin(childdata)
		end)
	end
end

function CLASS:GetSkinValue(key, ...)
	key = tostring(key or "")

	if not self.SkinMap then return nil end
	if not self.SkinMap[key] then return nil end

	local getter = self:GetFunction(self.SkinMap[key].get)
	if not getter then return nil end

	return getter(self, ...)
end

function CLASS:GetSkinValues(...)
	local tmp = {}

	for k, v in pairs(self.SkinMap or {}) do
		local getter = self:GetFunction(v.get)
		if not getter then continue end

		tmp[k] = getter(self, ...)
	end

	return tmp
end

function CLASS:SetModelSetup(setupdata)
	setupdata = setupdata or {}
	local thisdata = setupdata.data
	local childrendata = setupdata.children

	if thisdata then
		self:CallHook("OnModelSetup", thisdata)
	end

	if childrendata then
		self:ForEachChild(function(this, panel)
			local name_id = panel:GetNameWithoutHierarchy()
			local name_skin = panel:GetSkinIdentifyer()


			local childdata = childrendata[name_id or ""] or childrendata[name_skin or ""]
			if not childdata then return end

			panel:SetModelSetup(childdata)
		end)
	end

	self._modelsetupdata = setupdata
	self:InvalidateLayout(false, true)
end

function CLASS:OnModelSetup(setup)
	if setup.margin then
		self:SetMargin(setup.margin)
	end

	if setup.padding then
		self:SetPadding(setup.padding)
	end

	if setup.visible ~= nil then
		self:SetVisible(setup.visible or false)
	end

	if setup.size then
		local s = setup.size
		local w = s.width or s.w or s.x or s[1] or 0
		local h = s.height or s.y or s[2] or 0

		self:SetSize(w, h)
	end

	if setup.pos then
		local p = setup.pos
		local x = p.x or p[1] or 0
		local y = p.y or p[2] or 0

		self:SetPos(x, y)
	end


	if setup.sizex or setup.sizew then
		local w = setup.sizex or setup.sizew
		self:SetWidth(w)
	end

	if setup.sizey or setup.sizeh then
		local h = setup.sizex or setup.sizeh
		self:SetHeight(h)
	end

	if setup.posx then
		local x = setup.posx
		self:SetPosX(x)
	end

	if setup.posy then
		local x = setup.posy
		self:SetPosY(x)
	end
end
