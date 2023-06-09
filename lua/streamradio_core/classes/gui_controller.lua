if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

local ColR = Color(255,0,0, 255)
local ColY = Color(255,255,0, 60)
local tune_nohdr = Vector( 0.80, 0, 0 )
local CursorMat = StreamRadioLib.GetCustomPNG("cursor")

local catchAndErrorNoHaltWithStack = StreamRadioLib.CatchAndErrorNoHaltWithStack

local g_listengroup = 0

function CLASS:PreAssignToListenGroup()
	return self._listengroup
end

function CLASS:Create()
	self._listengroup = g_listengroup
	g_listengroup = g_listengroup + 1

	self:SetGlobalVar("gui_controller_listengroup", self._listengroup)

	BASE.Create(self)
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

	self._Skin.PreAssignToListenGroup = function()
		return self:PreAssignToListenGroup()
	end

	self._Skin.OnUpdateSkin = function(this, skin)
		if not IsValid(self) then return end
		self:SetSkinInternal(skin)
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

	self.Colors.DrawAlpha = 1
	self.Colors.Cursor = Color(255, 255, 255)

	self.Layout.CornerSize = 16
	self.Layout.BorderWidth = 10

	self._RT = StreamRadioLib.CreateOBJ("rendertarget")
	if not IsValid(self._RT) then return end

	self._RT.PreAssignToListenGroup = function()
		return self:PreAssignToListenGroup()
	end

	local ResizeRT = function()
		local x, y = self:GetPos()
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

	if CLIENT then
		self:StartSuperThink()
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
	if not self.Tooltip:IsVisible() then return end

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
	if not force and not self.Tooltip:IsVisible() then return end

	local x, y = self:GetPos()

	local cx, cy = self:GetCursor()
	local cw, ch = self:GetCursorSize()
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

local function RenderStop(this)
	this._isseen = false
end

function CLASS:RenderSystem()
	if SERVER then return end
	if not self.Valid then return end

	self:ProfilerStart("Render")
	self._isseen = true

	render.PushFilterMin(TEXFILTER.NONE)
	render.PushFilterMag(TEXFILTER.NONE)

	local alpha = self:GetDrawAlpha()
	local oldtune = render.GetToneMappingScaleLinear( )
	render.SetToneMappingScaleLinear(tune_nohdr) -- Turns off hdr

	surface.SetAlphaMultiplier(alpha)
	catchAndErrorNoHaltWithStack(self.DrawBorder, self)
	surface.SetAlphaMultiplier(1)

	if self:HasRendertarget() then
		surface.SetDrawColor(255, 255, 255, alpha * 255)

		catchAndErrorNoHaltWithStack(self._RT.Render, self._RT)

		surface.SetDrawColor(255, 255, 255, 255)
		self.FrameTime = self._RT:ProfilerTime("Render")
	else
		self:ProfilerStart("Render_rtfallback")
		surface.SetAlphaMultiplier(alpha)

		catchAndErrorNoHaltWithStack(self._RenderInternal, self)

		surface.SetAlphaMultiplier(1)
		self.FrameTime = self:ProfilerEnd("Render_rtfallback")
	end

	surface.SetAlphaMultiplier(alpha)
	catchAndErrorNoHaltWithStack(self.DrawCursor, self)
	surface.SetAlphaMultiplier(1)

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

	local ax1, ay1, ax2, ay2 = self:GetArea()

	local cx, cy = self:GetCursor()
	local cw, ch = self:GetCursorSize()

	local cu = ((cx + cw) - ax2) / cw
	local cv = ((cy + ch) - ay2) / ch

	cu = math.Clamp(1 - cu, 0, 1)
	cv = math.Clamp(1 - cv, 0, 1)

	surface.SetMaterial(CursorMat)
	surface.SetDrawColor(self.Colors.Cursor)
	surface.DrawTexturedRectUV(cx, cy, cw * cu, ch * cv, 0, 0, cu, cv)
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

function CLASS:Think()
	if SERVER then return end
	if not IsValid(self._RT) then return end
	if not self.isseen then return end

	self._RT:SetFramerate(StreamRadioLib.RenderTargetFPS())
	self._RT:SetEnabled(StreamRadioLib.IsRenderTarget())
	self:PosTooltipToCursor()
end

function CLASS:SuperThink()
	if SERVER then return end

	local change = self.isseen ~= self._isseen

	self.isseen = self._isseen
	self._isseen = false

	if change then
		if self.isseen then
			self:StartListenRecursive()
		else
			self:StopListenRecursive()
		end
	end

	if not IsValid(self._RT) then return end
	if not self.isseen then return end
	if not self._renderupdate then return end
	if not self._RT:Update() then return end

	self._renderupdate = false
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
	return SERVER or self.isseen
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

	self.Colors.Cursor = color
end

function CLASS:GetCursorColor()
	if SERVER then return end
	local col = self.Colors.Cursor

	return Color(col.r or 0, col.g or 0, col.b or 0, col.a or 0)
end

function CLASS:SetDrawAlpha(alpha)
	if SERVER then return end

	alpha = math.Clamp(alpha, 0, 1)
	self.Colors.DrawAlpha = alpha
end

function CLASS:GetDrawAlpha()
	if SERVER then return end
	local alpha = self.Colors.DrawAlpha

	return alpha or 0
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

	if not IsValid(self._Skin) then return end
	self._Skin:SetEntity(...)
end

function CLASS:LoadFromDupe()
	self:LoadFromDupeInternal()

	self:ForEachChildRecursive(function(this, child)
		child:LoadFromDupeInternal()
	end)

	if IsValid(self._Skin) then
		self._Skin:LoadFromDupeInternal()
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
