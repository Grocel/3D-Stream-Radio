if SERVER then
	CLASS = nil
	return true
end

local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()
local g_classname = CLASS:GetClassname()

local catchAndErrorNoHaltWithStack = StreamRadioLib.Util.CatchAndErrorNoHaltWithStack

local g_RenderTargetsCache = {}

local function next2power(value)
	value = value or 0
	if value <= 0 then return 0 end

	return math.ceil(2 ^ math.ceil(math.log(value) / math.log(2)))
end

local function GetRenderTargetMaterial(tex)
	if not tex then
		return nil
	end

	if tex:IsError() then
		return nil
	end

	local name = tex:GetName()

	local materialParameters = {
		["$basetexture"] = name,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$nocull"] = 1,
		["$nolod"] = 1,
		["$selfillum"] = 1,
		["$translucent"] = 1,
	}

	local mat = CreateMaterial( name, "UnlitGeneric", materialParameters )

	if not mat then
		return nil
	end

	mat:Recompute()
	return mat
end

local function GetCacheForSize(w, h)
	w = w or 0
	h = h or 0

	if w <= 0 then
		return nil
	end

	if h <= 0 then
		return nil
	end

	g_RenderTargetsCache[w] = g_RenderTargetsCache[w] or {}
	g_RenderTargetsCache[w][h] = g_RenderTargetsCache[w][h] or {}

	return g_RenderTargetsCache[w][h]
end

local function GetCacheCountForSize(w, h)
	local cache = GetCacheForSize(w, h)

	if not cache then
		return 0
	end

	return #cache
end

local function FreeCache(w, h, index)
	local cache = GetCacheForSize(w, h)
	if not cache then return end
	if not cache[index] then return end

	cache[index].free = true
end

local function UnfreeCache(w, h, index)
	local cache = GetCacheForSize(w, h)
	if not cache then return end
	if not cache[index] then return end

	cache[index].free = false
end

local function GetRendertargetName(w, h, index)
	w = w or 0
	h = h or 0

	if w <= 0 then
		return nil
	end

	if h <= 0 then
		return nil
	end

	index = index or GetCacheCountForSize(w, h)

	local name = string.format("3dstreamradio-rt_cls-%s_%ix%i_id-%i", g_classname, w, h, index)
	name = string.lower(name or "")
	name = string.Trim(name)
	name = string.gsub(name, "[%s\\.]", "_" )

	return name
end

function CLASS:Create()
	BASE.Create(self)

	local CreateRendertarget = function(this, key, value)
		if key == "Framerate" then return end

		if key == "Disabled" and value then
			self:Free()
			self._RT = nil

			self:CallHook("OnRendertargetRemove")
			return
		end

		self._RT = self:CreateRendertarget()

		if self._RT then
			self:CallHook("OnRendertargetCreate")
		else
			self:CallHook("OnRendertargetRemove")
		end
	end

	self.Size = self:CreateListener({
		w = 0,
		h = 0,
	}, CreateRendertarget)

	self.Pos = self:CreateListener({
		x = 0,
		y = 0,
	}, function()
		self:CallHook("OnPosChange")
	end)

	self.Settings = self:CreateListener({
		Framerate = 0,
		Disabled = false,
	}, CreateRendertarget)
end

function CLASS:Initialize()
	BASE.Initialize(self)

	self._RT = self:CreateRendertarget()

	if self._RT then
		self:CallHook("OnRendertargetCreate")
	else
		self:CallHook("OnRendertargetRemove")
	end

	self:Update()
end

function CLASS:GetCache()
	local w, h = self:GetSize()
	local cache = GetCacheForSize(w, h)

	if not cache then
		return nil
	end

	for i, v in ipairs(cache) do
		if not v.free then continue end
		if not v.tex then continue end
		if not v.mat then continue end

		local out = {
			mat = v.mat,
			tex = v.tex,
			index = i
		}

		return out
	end

	return nil
end

function CLASS:SetCache(mat, tex)
	if not mat then return nil end
	if not tex then return nil end

	local w, h = self:GetSize()
	local cache = GetCacheForSize(w, h)

	if not cache then
		return nil
	end

	local rt = {}

	rt.mat = mat
	rt.tex = tex
	rt.free = true

	table.insert(cache, rt)

	local out = {
		mat = mat,
		tex = tex,
		index = #cache
	}

	return out
end

function CLASS:GetCacheCount()
	local w, h = self:GetSize()
	return GetCacheCountForSize(w, h)
end

function CLASS:Free()
	local w, h = self:GetSize()
	self:Clear()

	local rt = self._RT
	if not rt then return end

	FreeCache(w, h, rt.index)
end

function CLASS:GetMaxCacheCount()
	return self:GetGlobalVar("rendertarget_MaxCacheCount", 0)
end

function CLASS:SetMaxCacheCount(value)
	value = value or 0

	if value <= 0 then
		value = 0
	end

	return self:SetGlobalVar("rendertarget_MaxCacheCount", value)
end


function CLASS:CreateRendertarget()
	if not self.Valid then
		return nil
	end

	if not self.Created then
		return nil
	end

	if self:IsDisabled() then
		return nil
	end

	local w, h = self:GetSize()

	if w <= 0 then
		return nil
	end

	if h <= 0 then
		return nil
	end

	local rt = self:GetCache()
	if rt then
		UnfreeCache(w, h, rt.index)
		return rt
	end

	local name = GetRendertargetName(w, h)
	if not name then return nil end

	local maxcount = self:GetMaxCacheCount()
	if maxcount > 0 and self:GetCacheCount() > maxcount then
		return nil
	end

	-- No ENUMS for thise values are available in the game.
	-- https://wiki.facepunch.com/gmod/Enums/TEXTUREFLAGS
	local textureFlags = bit.bor(
		4,    -- TEXTUREFLAGS_CLAMPS
		8,    -- TEXTUREFLAGS_CLAMPT
		16,   -- TEXTUREFLAGS_ANISOTROPIC
		32,   -- TEXTUREFLAGS_HINT_DXT5
		512,  -- TEXTUREFLAGS_NOLOD
		8192, -- TEXTUREFLAGS_EIGHTBITALPHA
		32768 -- TEXTUREFLAGS_RENDERTARGET
	)

	local tex = GetRenderTargetEx(
		name, w, h,
		RT_SIZE_NO_CHANGE,
		MATERIAL_RT_DEPTH_SEPARATE,
		textureFlags,
		0,
		IMAGE_FORMAT_RGBA8888
	)

	local mat = GetRenderTargetMaterial(tex)

	rt = self:SetCache(mat, tex)
	if not rt then
		return nil
	end

	render.PushRenderTarget( tex )
		render.Clear( 0, 0, 0, 0, true )
	render.PopRenderTarget( )

	UnfreeCache(w, h, rt.index)
	return rt
end

function CLASS:Update()
	if not self._RT then return false end
	if self:IsDisabled() then return false end

	local now = SysTime()
	local framerate = self.Settings.Framerate or 0
	local min_rtframetime = 1 / math.max(framerate, 2)
	local renderNextTime = self._renderNextTime or 0

	if renderNextTime > now then
		return false
	end

	local w, h = self:GetSize()

	self:ProfilerStart("Render")
	render.PushRenderTarget(self._RT.tex, 0, 0, w, h)
		render.Clear(0, 0, 0, 0, true)
		cam.Start2D()
			catchAndErrorNoHaltWithStack(self.CallHook, self, "OnRender")
		cam.End2D()
	render.PopRenderTarget()
	self:ProfilerEnd("Render")

	self._renderNextTime = now + min_rtframetime
	return true
end

function CLASS:Remove()
	self:Free()
	self._RT = nil
	self:CallHook("OnRendertargetRemove")

	BASE.Remove(self)
end

function CLASS:Clear()
	if not self._RT then return end
	if self:IsDisabled() then return end

	local rt = self._RT
	local tex = rt.tex

	render.PushRenderTarget( tex )
		render.Clear( 0, 0, 0, 0, true )
	render.PopRenderTarget( )
end

function CLASS:Render()
	if not self._RT then return end
	if self:IsDisabled() then return end

	local rt = self._RT
	local mat = rt.mat

	local x, y = self:GetPos()
	local w, h = self:GetSize()

	surface.SetMaterial(mat)
	surface.DrawTexturedRectUV(x, y, w, h, 0, 0, 1, 1)
end

function CLASS:SetSize(w, h)
	self.Size.w = next2power(w)
	self.Size.h = next2power(h)
end

function CLASS:GetSize()
	if not self.Size then return 0, 0 end
	return self.Size.w or 0, self.Size.h or 0
end

function CLASS:GetWidth()
	return self.Size.w or 0
end

function CLASS:GetHeight()
	return self.Size.h or 0
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

function CLASS:GetRendertargetName()
	local rt = self._RT

	if not rt then
		return nil
	end

	local w, h = self:GetSize()

	return GetRendertargetName(w, h, rt.index)
end

function CLASS:HasRendertarget()
	if not self.Valid then return false end
	if self:IsDisabled() then return false end
	if self._RT then return true end
	return false
end

function CLASS:GetRendertarget()
	if not self.Valid then return nil end
	if self:IsDisabled() then return nil end
	return self._RT
end

function CLASS:GetTexture()
	if not self.Valid then return nil end
	if self:IsDisabled() then return nil end
	if not self._RT then return nil end
	return self._RT.tex
end

function CLASS:GetMaterial()
	if not self.Valid then return nil end
	if self:IsDisabled() then return nil end
	if not self._RT then return nil end
	return self._RT.mat
end

function CLASS:IsDisabled()
	if not self.Settings then return true end
	return self.Settings.Disabled or false
end

function CLASS:IsEnabled()
	if not self.Settings then return false end
	return not self.Settings.Disabled
end

function CLASS:SetEnabled(bool)
	if not self.Settings then return end
	self.Settings.Disabled = not bool
end

function CLASS:SetDisabled(bool)
	if not self.Settings then return end
	self.Settings.Disabled = bool or false
end

function CLASS:GetFramerate()
	if not self.Settings then return 0 end
	return self.Settings.Framerate or 0
end

function CLASS:SetFramerate(rate)
	if not self.Settings then return end
	self.Settings.Framerate = rate or 0
end

function CLASS:__tostring()
	local name = self:GetRendertargetName() or "no rendertarget"
	if not self:HasRendertarget() then
		name = "no rendertarget"
	end

	return string.format("[%s][%s]", self.classname, name)
end

function CLASS:__eg(other)
	if self:GetRendertargetName() ~= other:GetRendertargetName() then
		return false
	end

	return true
end

return true

