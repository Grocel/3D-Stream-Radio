local StreamRadioLib = StreamRadioLib

StreamRadioLib.Util = StreamRadioLib.Util or {}

local LIB = StreamRadioLib.Util
table.Empty(LIB)

local LIBString = StreamRadioLib.String

local g_debug = false
local g_debug_nextcheck = 0

function LIB.IsDebug()
	local now = RealTime()

	if g_debug_nextcheck > now then
		return g_debug
	end

	g_debug_nextcheck = now + 1
	g_debug = false

	local devconvar = GetConVar("developer")
	if not devconvar then
		return false
	end

	if devconvar:GetInt() <= 0 then
		return false
	end

	g_debug = true
	return true
end

function LIB.GameIsPaused()
	local frametime = FrameTime()

	if frametime > 0 then
		return false
	end

	return true
end

function LIB.ErrorNoHaltWithStack(err)
	err = tostring(err or "")
	ErrorNoHaltWithStack(err)
end

local catchAndNohalt = function(err)
	local msgstring = tostring(err or "")
	msgstring = string.Trim(StreamRadioLib.AddonPrefix .. msgstring) .. "\n"

	LIB.ErrorNoHaltWithStack(err)

	return err
end

function LIB.CatchAndErrorNoHaltWithStack(func, ...)
	return xpcall(func, catchAndNohalt, ...)
end

function LIB.Hash(str)
	str = tostring(str or "")

	local salt = "StreamRadioLib_Hash20230810"

	local data = string.format(
		"[%s][%s]",
		salt,
		str
	)

	local hash = util.SHA256(data)
	return hash
end

local g_uid = 0
function LIB.Uid()
	g_uid = (g_uid + 1) % (2 ^ 30)
	return g_uid
end

local g_createCacheArrayMeta = {
	Set = function(self, cacheid, data, expires)
		if cacheid == nil then
			return
		end

		if data == nil then
			self:Remove(cacheid)
			return
		end

		if self.limit > 0 and self.count > self.limit then
			self:Empty()
		end

		local cache = self.cache
		local cacheItem = cache[cacheid]

		if not cacheItem then
			cacheItem = {}
			cache[cacheid] = cacheItem

			self.count = self.count + 1
		end

		cacheItem.data = data
		cacheItem.expires = expires
	end,

	Get = function(self, cacheid, now)
		if cacheid == nil then
			return nil
		end

		local cache = self.cache
		local cacheItem = cache[cacheid]

		if not cacheItem then
			return nil
		end

		local data = cacheItem.data
		if data == nil then
			self:Remove(cacheid)
			return nil
		end

		now = now or 0
		local expires = cacheItem.expires or 0

		if now > 0 and expires > 0 and expires < now then
			self:Remove(cacheid)
			return nil
		end

		return data
	end,

	Remove = function(self, cacheid)
		if cacheid == nil then
			return
		end

		local cache = self.cache
		if cache[cacheid] == nil then
			return
		end

		cache[cacheid] = nil
		self.count = math.max(self.count - 1, 0)
	end,

	Has = function(self, cacheid, now)
		return self:Get(cacheid, now) ~= nil
	end,

	Empty = function(self)
		LIB.EmptyTableSafe(self.cache)
		self.count = 0
	end,

	Count = function(self)
		return self.count
	end,
}

g_createCacheArrayMeta.__index = g_createCacheArrayMeta

function LIB.CreateCacheArray(limit)
	local cache = {}

	cache.cache = {}
	cache.limit = math.max(limit or 0, 0)
	cache.count = 0

	setmetatable(cache, g_createCacheArrayMeta)

	return cache
end

function LIB.EmptyTableSafe(tab)
	if not tab then
		return
	end

	table.Empty(tab)
end

function LIB.GetMainDirectory(directory)
	local baseDirectory = StreamRadioLib.DataDirectory or ""

	if baseDirectory == "" then
		error("StreamRadioLib.DataDirectory is empty")
		return
	end

	directory = tostring(directory or "")

	local mainPath = baseDirectory .. "/" .. directory
	mainPath = LIBString.NormalizeSlashes(mainPath)

	return mainPath
end

function LIB.CreateDirectoryForFile(path)
	local baseDirectory = StreamRadioLib.DataDirectory or ""

	if baseDirectory == "" then
		return false
	end

	path = tostring(path or "")

	if path == "" then
		return false
	end

	if not string.StartsWith(path, baseDirectory) then
		return false
	end

	local directory = string.GetPathFromFilename(path) or ""
	if directory == "" then return true end

	if not file.IsDir(directory, "DATA") then
		file.CreateDir(directory)
	end

	return file.IsDir(directory, "DATA")
end

function LIB.DeleteFolder(path)
	local baseDirectory = StreamRadioLib.DataDirectory or ""

	if baseDirectory == "" then
		return false
	end

	path = tostring(path or "")

	if path == "" then
		return false
	end

	if not string.StartsWith(path, baseDirectory) then
		return false
	end

	local files, folders = file.Find(path .. "/*", "DATA")

	for k, v in ipairs(files or {}) do
		file.Delete(path .. "/" .. v)
	end

	for k, v in ipairs(folders or {}) do
		LIB.DeleteFolder(path .. "/" .. v)
	end

	file.Delete(path)

	if file.Exists(path, "DATA") then
		return false
	end

	if file.IsDir(path, "DATA") then
		return false
	end

	return true
end

local g_cache_IsValidModel = {}
local g_cache_IsValidModelFile = {}

function LIB.GetDefaultModel()
	local defaultModel = Model("models/sligwolf/grocel/radio/radio.mdl")
	return defaultModel
end

function LIB.IsValidModel(model)
	model = tostring(model or "")

	if g_cache_IsValidModel[model] then
		return true
	end

	g_cache_IsValidModel[model] = nil

	if not LIB.IsValidModelFile(model) then
		return false
	end

	util.PrecacheModel(model)

	if not util.IsValidModel(model) then
		return false
	end

	if not util.IsValidProp(model) then
		return false
	end

	g_cache_IsValidModel[model] = true
	return true
end

function LIB.IsValidModelFile(model)
	model = tostring(model or "")

	if g_cache_IsValidModelFile[model] then
		return true
	end

	g_cache_IsValidModelFile[model] = nil

	if model == "" then
		return false
	end

	if IsUselessModel(model) then
		return false
	end

	if not file.Exists(model, "GAME") then
		return false
	end

	g_cache_IsValidModelFile[model] = true
	return true
end

function LIB.FrameNumber()
	local frame = nil

	if CLIENT then
		frame = FrameNumber()
	else
		frame = engine.TickCount()
	end

	return frame
end

function LIB.RealFrameTime()
	local frameTime = nil

	if CLIENT then
		frameTime = RealFrameTime()
	else
		frameTime = FrameTime()
	end

	return frameTime
end

function LIB.RealTimeFps()
	local fps = LIB.RealFrameTime()

	if fps <= 0 then
		return 0
	end

	fps = 1 / fps

	return fps
end

local g_LastFrameRegister = {}
local g_LastFrameRegisterCount = 0

function LIB.IsSameFrame(id)
	local id = tostring(id or "")
	local lastFrame = g_LastFrameRegister[id]

	local frame = LIB.FrameNumber()

	if not lastFrame or frame ~= lastFrame then

		-- prevent the cache from overflowing
		if g_LastFrameRegisterCount > 1024 then
			LIB.EmptyTableSafe(g_LastFrameRegister)
			g_LastFrameRegisterCount = 0
		end

		g_LastFrameRegister[id] = frame

		if not lastFrame then
			g_LastFrameRegisterCount = g_LastFrameRegisterCount + 1
		end

		return false
	end

	return true
end

function LIB.IsAdmin(ply)
	if CLIENT and not IsValid(ply) then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then
		return false
	end

	if not ply:IsAdmin() then
		return false
	end

	return true
end

function LIB.IsAdminForCMD(ply)
	if not IsValid(ply) then
		return true
	end

	if not LIB.IsAdmin(ply) then
		return false
	end

	return true
end

return true

