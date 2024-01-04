local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

local tune_nohdr = Vector( 0.80, 0, 0 )
local CursorMat = StreamRadioLib.GetCustomPNG("cursor")

local catchAndErrorNoHaltWithStack = StreamRadioLib.Util.CatchAndErrorNoHaltWithStack

local g_gui_controller_listengroup = 0
local g_loadedAtDelay = math.min(engine.TickInterval() * 16, 0.5)
local g_visuallyReadyAtDelay = 1

function CLASS:AssignToListenGroup()
	return self._gui_controller_listengroup
end

function CLASS:Create()
	self._gui_controller_listengroup = g_gui_controller_listengroup
	g_gui_controller_listengroup = (g_gui_controller_listengroup % 2 ^ 30) + 1

	self:SetGlobalVar("gui_controller_listengroup", self._gui_controller_listengroup)

	BASE.Create(self)

	self.loadedAt = 0
	self.visuallyReadyAt = 0
	self.isReady = false
	self.isLoading = false

	self.Layout.AllowCursor = true

	self.Cursor = self:CreateListener({
		Pos = Vector(0, 0, 0),
	}, function()
		self:CallHook("CursorChangedInternal")
		self:CallHook("OnCursorChanged")
	end)

	if CLIENT then
		self.Tooltip = self:AddPanelByClassname("tooltip")
		self.Tooltip:SetPos(0, 0)
		self.Tooltip:SetSize(1, 1)
		self.Tooltip:SetName("tooltip")
		self.Tooltip:SetNWName("tip")
		self.Tooltip:SetSkinIdentifyer("tooltip")
		self.Tooltip:SetText("")
		self.Tooltip:SetZPos(1000)
		self.Tooltip:Close()
	end

	self._Skin = StreamRadioLib.CreateOBJ("skin_controller")

	self._Skin.AssignToListenGroup = function()
		return self:AssignToListenGroup()
	end

	self._Skin.OnUpdateSkin = function(this, skindata)
		if not IsValid(self) then return end
		self:SetSkinInternal(skindata)
	end

	self.SkinMap["color"] = nil;

	self.SkinMap["color_cursor"] = {
		set = "SetCursorColor",
		get = "GetCursorColor",
	}

	self.SkinMap["color_border"] = {
		set = "SetColor",
		get = "GetColor",
	}

	self.SkinAble = true

	if SERVER then return end

	self.Colors.Cursor = Color(255, 255, 255)

	self.Layout.CornerSize = 16
	self.Layout.BorderWidth = 10

	self._RT = StreamRadioLib.CreateOBJ("rendertarget")
	if not IsValid(self._RT) then return end

	self._RT.AssignToListenGroup = function()
		return self:AssignToListenGroup()
	end

	local ResizeRT = function()
		local x = self:GetPos()
		local w, h = self:GetSize()

		self._RT:SetPos(x, x)
		self._RT:SetSize(w, h)

		self:InvalidateLayout()
	end

	local CalcSize = function()
		local w, h = self:GetSize()

		local sqmax, sqmin = math.max(w, h), math.min(w, h)
		local csq = math.min(sqmax * 0.06125, sqmin * 0.25)

		self:SetCursorSize(csq, csq)

		if IsValid(self.Tooltip) then
			self.Tooltip:SetMaxWidth(w / 3)
		end
	end

	self.Size = self.Size + ResizeRT + CalcSize
	self.Pos = self.Pos + ResizeRT

	self._RT.OnRender = function()
		render.PushFilterMin(TEXFILTER.NONE)
		render.PushFilterMag(TEXFILTER.NONE)

		catchAndErrorNoHaltWithStack(self._RenderInternal, self)

		render.PopFilterMag()
		render.PopFilterMin()
	end

	self._RT.OnRendertargetRemove = function()
		self:InvalidateLayout()
	end

	self._RT.OnRendertargetCreate = function()
		self:InvalidateLayout()
	end

	ResizeRT()
	CalcSize()

	self.CanListen = true
	self:StartListen()

	if CLIENT then
		self:StartFastThink()
	end
end

function CLASS:Remove()
	if IsValid(self._RT) then
		self._RT:Remove()
	end

	if IsValid(self._Skin) then
		self._Skin:Remove()
	end

	if IsValid(self._Debug) then
		self._Debug:Remove()
	end

	BASE.Remove(self)
end

function CLASS:HasRendertarget()
	if not IsValid(self._RT) then
		return false
	end

	return self._RT:HasRendertarget()
end

function CLASS:GetRendertargetSize()
	if not self:HasRendertarget() then
		return -1, -1
	end

	return self._RT:GetSize()
end

function CLASS:GetRenderPos()
	if self:HasRendertarget() then
		return 0, 0
	end

	local getpos = self.GetClientPos or self.GetPos
	local x, y = getpos(self)

	return x, y
end

function CLASS:GetTooltipPanel()
	return self.Tooltip
end

function CLASS:UpdateTooltip(text)
	if SERVER then return end
	if not IsValid(self.Tooltip) then return end
	if not self.Tooltip:IsVisibleSimple() then return end

	text = tostring(text or "")
	self.Tooltip:SetText(text)

	if text == "" then
		self.Tooltip:Close()
	end

	return self.Tooltip
end

function CLASS:OpenTooltip(text)
	if SERVER then return end
	if not IsValid(self.Tooltip) then return end

	text = tostring(text or "")
	self.Tooltip:SetText(text)

	if text ~= "" then
		self.Tooltip:Open()
		self:PosTooltipToCursor(true)
	else
		self.Tooltip:Close()
	end

	return self.Tooltip
end

function CLASS:CloseTooltip(text)
	if SERVER then return end
	if not IsValid(self.Tooltip) then return end

	self.Tooltip:Close()
end

function CLASS:PosTooltipToCursor(force)
	if SERVER then return end
	if not IsValid(self.Tooltip) then return end
	if not force and not self.Tooltip:IsVisibleSimple() then return end

	local x, y = self:GetPos()

	local cx, cy = self:GetCursor()
	local _, ch = self:GetCursorSize()
	local pw, ph = self:GetClientSize()
	local tw, th = self.Tooltip:GetSize()

	cx = cx - x
	cy = cy - y

	local tx, ty = 0, 0

	tx = cx - tw / 2
	ty = cy - th * 1.5

	if ty < 0 then
		ty = cy + ch * 1.5
	end

	tx = math.Clamp(tx, 0, pw - tw)
	ty = math.Clamp(ty, 0, ph - th)

	self.Tooltip:SetPos(tx, ty)
end

function CLASS:OpenTooltipDelay(text, delay, callback)
	if SERVER then return end
	if not IsValid(self.Tooltip) then return end

	self:TimerOnce("tooltip", delay or 3, function()
		callback = self:GetFunction(callback)
		if not callback then return end
		if not callback(self) then return end

		self:OpenTooltip(text)
	end)
end

function CLASS:GetPanelByName(name)
	name = StreamRadioLib.GetHierarchy(name)

	local firstname = name[1] or ""

	if firstname ~= self:GetName() then
		return nil
	end

	if #name <= 1 then
		return self
	end

	table.remove(name, 1)
	return BASE.GetPanelByName(self, name)
end

function CLASS:IsSkinAble()
	if not self.SkinAble then return false end
	return true
end

function CLASS:RenderSystem()
	if SERVER then return end
	if not self.Valid then return end

	self:ProfilerStart("Render")
	self._isseen = true

	render.PushFilterMin(TEXFILTER.NONE)
	render.PushFilterMag(TEXFILTER.NONE)

	local now = RealTime()
	local currentRenderAlpha = surface.GetAlphaMultiplier()
	local drawAlpha = self:GetDrawAlpha()
	local alpha = drawAlpha * currentRenderAlpha
	local isTransparent = drawAlpha < 1
	local ready = self.isReady and self.visuallyReadyAt < now

	local oldtune = render.GetToneMappingScaleLinear( )
	render.SetToneMappingScaleLinear(tune_nohdr) -- Turns off hdr

	if isTransparent then
		surface.SetAlphaMultiplier(alpha)
	end

	catchAndErrorNoHaltWithStack(self.DrawBorder, self)

	if isTransparent then
		surface.SetAlphaMultiplier(currentRenderAlpha)
	end

	if ready then
		if self:HasRendertarget() then
			surface.SetDrawColor(255, 255, 255, alpha * 255)

			catchAndErrorNoHaltWithStack(self._RT.Render, self._RT)

			surface.SetDrawColor(255, 255, 255, 255)
			self.FrameTime = self._RT:ProfilerTime("Render")
		else
			self:ProfilerStart("Render_rtfallback")

			if isTransparent then
				surface.SetAlphaMultiplier(alpha)
			end

			catchAndErrorNoHaltWithStack(self._RenderInternal, self)

			if isTransparent then
				surface.SetAlphaMultiplier(currentRenderAlpha)
			end

			self.FrameTime = self:ProfilerEnd("Render_rtfallback")
		end

		if isTransparent then
			surface.SetAlphaMultiplier(alpha)
		end
	end

	if ready then
		catchAndErrorNoHaltWithStack(self.DrawCursor, self)
	else
		catchAndErrorNoHaltWithStack(self.RenderLoader, self)
	end

	if isTransparent then
		surface.SetAlphaMultiplier(currentRenderAlpha)
	end

	render.SetToneMappingScaleLinear(oldtune) -- Resets hdr

	render.PopFilterMag()
	render.PopFilterMin()

	self:ProfilerEnd("Render")
end

function CLASS:SetCursorSize(w, h)
	self.Cursor_w = w or 0
	self.Cursor_h = h or 0
end

function CLASS:GetCursorSize()
	return self.Cursor_w, self.Cursor_h
end

function CLASS:DrawCursor()
	if not self:GetAllowCursor() then return end
	if not self:IsCursorInBounds() then return end

	local _, _, ax2, ay2 = self:GetArea()

	local cx, cy = self:GetCursor()
	local cw, ch = self:GetCursorSize()
	local colCursor = self.Colors.Cursor or color_white

	local cu = ((cx + cw) - ax2) / cw
	local cv = ((cy + ch) - ay2) / ch

	cu = math.Clamp(1 - cu, 0, 1)
	cv = math.Clamp(1 - cv, 0, 1)

	surface.SetMaterial(CursorMat)
	surface.SetDrawColor(colCursor:Unpack())
	surface.DrawTexturedRectUV(cx, cy, cw * cu, ch * cv, 0, 0, cu, cv)
end

function CLASS:RenderLoader()
	local color = self.Colors.Cursor

	local x, y = self:GetRenderPos()
	local p = self:GetPadding()
	x = x + p
	y = y + p

	local w, h = self:GetClientSize()

	local sqmax, sqmin = math.max(w, h), math.min(w, h)
	local isq = math.min(sqmax * 0.5, sqmin * 0.5)

	StreamRadioLib.Surface.Loading( x + (w - isq) / 2, y + (h - isq) / 2, isq, isq, color, 8)
end

function CLASS:DrawBorder()
	local borderw = self.Layout.BorderWidth or 0
	if borderw <= 0 then return end

	local x, y = self:GetPos()
	local w, h = self:GetSize()

	x = x - borderw
	y = y - borderw
	w = w + borderw * 2
	h = h + borderw * 2

	draw.RoundedBox(self.Layout.CornerSize, x, y, w, h, self.Colors.Main)
end

function CLASS:OnContentChanged()
	self._renderupdate = true
end

function CLASS:PollLoading()
	if not self.isLoading then
		return
	end

	local now = RealTime()
	local loadedAt = self.loadedAt or 0

	if loadedAt > now then
		return
	end

	self.loadedAt = now
	self.isLoading = false

	self:CallHook("OnLoadDone")

	if not self.isReady then
		self.isReady = true
		self.visuallyReadyAt = now + g_visuallyReadyAtDelay

		self:CallHook("OnReady")
	end
end

function CLASS:Think()
	self.thinkRate = 0.5

	self:PollLoading()

	if SERVER then
		return
	end

	if not IsValid(self._RT) then return end
	if not self:IsSeen() then return end

	self.thinkRate = 0.1

	self._RT:SetFramerate(StreamRadioLib.GetRenderTargetFPS())
	self._RT:SetEnabled(StreamRadioLib.IsRenderTarget())

	self:PosTooltipToCursor()
end

if CLIENT then
	function CLASS:FastThink()
		local isReady = self.isReady

		self.fastThinkRate = isReady and 0.1 or 0.5

		local isSeen = self:IsSeen()
		local change = isSeen ~= self._isseen

		isSeen = self._isseen
		self._isseen = false

		self.isseen = isSeen

		if change then
			if isSeen then
				self:StartListenRecursive()
			else
				if not self.isReady then
					-- make sure the gui controller never stops thinking if not maked as ready yet.
					self.CanListen = true
					self:StartListen()
				else
					self:StopListenRecursive()
				end
			end
		end

		if not IsValid(self._RT) then return end
		if not isSeen then return end

		self.fastThinkRate = 0

		if not self._renderupdate then return end
		if not self._RT:Update() then return end

		self._renderupdate = false
	end
end

function CLASS:GetAllowCursor()
	return self.Layout.AllowCursor or false
end

function CLASS:SetAllowCursor( bool )
	self.Layout.AllowCursor = bool or false
end

function CLASS:GetFrametime()
	return self.FrameTime or 0
end

function CLASS:SetCursorGlobal(x, y)
	self:SetCursor(x, y)
end

function CLASS:SetCursor(x, y)
	x = math.floor(x or -1)
	y = math.floor(y or -1)

	local x1, y1, x2, y2 = self:GetArea()

	if x < x1 then
		x = -1
		y = -1
	end

	if y < y1 then
		x = -1
		y = -1
	end

	if x > x2 then
		x = -1
		y = -1
	end

	if y > y2 then
		x = -1
		y = -1
	end

	self.Cursor.Pos = Vector(x, y, 0)
end

function CLASS:_GetCursorInternal()
	return math.floor(self.Cursor.Pos.x or -1), math.floor(self.Cursor.Pos.y or -1)
end

function CLASS:GetCursor()
	return self:_GetCursorInternal()
end

function CLASS:GetCornerSize()
	return self.Layout.CornerSize or 0
end

function CLASS:SetCornerSize(size)
	self.Layout.CornerSize = size or 0
end

function CLASS:GetBorderWidth()
	return self.Layout.BorderWidth or 0
end

function CLASS:SetBorderWidth(size)
	self.Layout.BorderWidth = size or 0
end

function CLASS:IsSeen()
	return SERVER or (self.isseen and self.isReady)
end

function CLASS:SetDebug(allowdebug)
	if SERVER then return end
	allowdebug = allowdebug and true or false

	if self:GetDebug() == allowdebug then
		return
	end

	if not allowdebug then
		self._Debug:Remove()
		self._Debug = nil
		self:InvalidateLayout()
		return
	end

	self._Debug = self:AddPanelByClassname("debug")
	self._Debug:SetName("debug")
	self._Debug:SetNWName("debug")
	self:InvalidateLayout()
end

function CLASS:GetDebug()
	if not IsValid(self._Debug) then
		return false
	end

	return true
end

function CLASS:SetSkin(...)
	if not IsValid(self._Skin) then
		return
	end

	return self._Skin:SetSkin(...)
end

function CLASS:SetSkinInternal(...)
	return BASE.SetSkin(self, ...)
end

function CLASS:GetSkin(...)
	if not IsValid(self._Skin) then
		return {}
	end

	return self._Skin:GetSkin(...)
end

function CLASS:SetSkinProperty(...)
	if not IsValid(self._Skin) then
		return
	end

	return self._Skin:SetProperty(...)
end

function CLASS:SetSkinOnServer(...)
	if not IsValid(self._Skin) then
		return
	end

	return self._Skin:SetSkinOnServer(...)
end

function CLASS:SetSkinPropertyOnServer(...)
	if not IsValid(self._Skin) then
		return
	end

	return self._Skin:SetPropertyOnServer(...)
end

function CLASS:SetCursorColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.Cursor = color
end

function CLASS:GetCursorColor()
	if SERVER then return end

	local col = self.Colors.Cursor
	return col
end

function CLASS:SetName(...)
	BASE.SetName(self, ...)

	local name = self:GetName()
	local nwname = self:GetName()

	if IsValid(self._Skin) then
		self._Skin:SetName(name .. "/skin")
		self._Skin:SetNWName(nwname .. "/sk")
	end

	if IsValid(self._RT) then
		self._RT:SetName(name .. "/rendertarget")
		self._RT:SetNWName(nwname .. "/rt")
	end
end

function CLASS:SetEntity(...)
	BASE.SetEntity(self, ...)

	if IsValid(self._Skin) then
		self._Skin:SetEntity(...)
	end
end

function CLASS:LoadToDupe(dupeTable)
	if not SERVER then return end
	if not istable(dupeTable) then return end

	self:LoadToDupeInternal(dupeTable)

	self:ForEachChildRecursive(function(this, child)
		child:LoadToDupeInternal(dupeTable)
	end)

	if IsValid(self._Skin) then
		self._Skin:LoadToDupeInternal(dupeTable)
	end
end

function CLASS:LoadFromDupe(dupeTable)
	if not SERVER then return end
	if not istable(dupeTable) then return end

	self:LoadFromDupeInternal(dupeTable)

	self:ForEachChildRecursive(function(this, child)
		child:LoadFromDupeInternal(dupeTable)
	end)

	if IsValid(self._Skin) then
		self._Skin:LoadFromDupeInternal(dupeTable)
	end
end

function CLASS:AddToNwRegister(nwRegister)
	if not istable(nwRegister) then return end

	self:AddToNwRegisterInternal(nwRegister)

	self:ForEachChildRecursive(function(this, child)
		child:AddToNwRegisterInternal(nwRegister)
	end)

	if IsValid(self._Skin) then
		self._Skin:AddToNwRegisterInternal(nwRegister)
	end
end

function CLASS:RemoveFromNwRegister(nwRegister)
	if not istable(nwRegister) then return end

	self:RemoveFromNwRegisterInternal(nwRegister)

	self:ForEachChildRecursive(function(this, child)
		child:RemoveFromNwRegisterInternal(nwRegister)
	end)

	if IsValid(self._Skin) then
		self._Skin:RemoveFromNwRegisterInternal(nwRegister)
	end
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)

	if not IsValid(self._Skin) then return end
	self._Skin:ActivateNetworkedMode(self)
end

function CLASS:OnModelSetup(setup)
	BASE.OnModelSetup(self, setup)

	if setup.cornersize then
		self:SetCornerSize(setup.cornersize)
	end

	if setup.borderwidth then
		self:SetBorderWidth(setup.borderwidth)
	end
end

function CLASS:OnPanelElementLoaded()
	self.loadedAt = RealTime() + g_loadedAtDelay
	self.isLoading = true
end

function CLASS:IsLoading()
	return self.isLoading or false
end

function CLASS:IsReady()
	return self.isReady or false
end

return true

