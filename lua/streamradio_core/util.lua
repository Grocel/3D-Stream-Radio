local StreamRadioLib = StreamRadioLib

StreamRadioLib.Util = StreamRadioLib.Util or {}
local LIB = StreamRadioLib.Util

local LIBNetURL = StreamRadioLib.NetURL

function LIB.IsDebug()
	local devconvar = GetConVar("developer")
	if not devconvar then
		return false
	end

	if devconvar:GetInt() <= 0 then
		return false
	end

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

function LIB.NormalizeNewlines(text, nl)
	nl = tostring(nl or "")
	text = tostring(text or "")

	local replacemap = {
		["\r\n"] = true,
		["\r"] = true,
		["\n"] = true,
	}

	if not replacemap[nl] then
		nl = "\n"
	end

	replacemap[nl] = nil

	for k, v in pairs(replacemap) do
		replacemap[k] = nl
	end

	text = string.gsub(text, "([\r]?[\n]?)", replacemap)

	return text
end

local g_createCacheArrayMeta = {
	Set = function(self, cacheid, data)
		if cacheid == nil then
			return
		end

		if data == nil then
			self:Remove(cacheid)
			return
		end

		local hadCache = false
		local cache = self.cache

		if cache[cacheid] then
			hadCache = true
		end

		if self.limit > 0 and self.count > self.limit then
			self:Empty()
		end

		cache[cacheid] = data

		if not hadCache then
			self.count = self.count + 1
		end
	end,

	Get = function(self, cacheid)
		if cacheid == nil then
			return nil
		end

		return self.cache[cacheid]
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

	Has = function(self, cacheid)
		if cacheid == nil then
			return false
		end

		return self.cache[cacheid] ~= nil
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

function LIB.IsBlockedURLCode(url)
	url = url or ""

	local blockedURLCode = StreamRadioLib.BlockedURLCode or ""
	local blockedURLCodeSequence = StreamRadioLib.BlockedURLCodeSequence or ""

	if blockedURLCode == "" then
		return false
	end

	if blockedURLCodeSequence == "" then
		return false
	end

	if url == blockedURLCode then
		return true
	end

	if string.find(url, blockedURLCodeSequence, 1, true) then
		return true
	end

	return false
end

function LIB.IsBlockedCustomURL(url, ply)
	url = url or ""

	if url == "" then
		return false
	end

	if LIB.IsBlockedURLCode(url) then
		return true
	end

	if LIB.IsOfflineURL(url) then
		return false
	end

	if not StreamRadioLib.IsCustomURLsAllowed(ply) then
		return true
	end

	return false
end

function LIB.FilterCustomURL(url, ply, treatBlockedURLCodeAsEmpty)
	if treatBlockedURLCodeAsEmpty and LIB.IsBlockedURLCode(url) then
		return ""
	end

	if LIB.IsBlockedCustomURL(url, ply) then
		return StreamRadioLib.BlockedURLCode
	end

	return url
end

function LIB.IsValidURL(url)
	url = url or ""

	if url == "" then
		return false
	end

	if LIB.IsBlockedURLCode(url) then
		return false
	end

	return true
end

function LIB.SanitizeUrl(url)
	url = tostring(url or "")

	url = string.Trim(url)

	url = string.Replace(url, "\n", "")
	url = string.Replace(url, "\r", "")
	url = string.Replace(url, "\t", "")
	url = string.Replace(url, "\b", "")
	url = string.Replace(url, "\v", "")

	url = string.Trim(url)

	url = string.sub(url, 0, StreamRadioLib.STREAM_URL_MAX_LEN_ONLINE)

	url = string.Trim(url)

	return url
end

local function NormalizeOfflineFilename( path )
	path = LIB.SanitizeUrl(path)

	path = string.Replace( path, "\\", "/" )
	path = string.Replace( path, "../", "" )
	path = string.Replace( path, "//", "/" )

	path = string.Trim(path)

	path = string.sub(path, 0, StreamRadioLib.STREAM_URL_MAX_LEN_OFFLINE)

	path = string.Trim(path)

	return path
end

function LIB.URIAddParameter(url, parameter)
	if not istable(parameter) then
		parameter = {parameter}
	end

	url = tostring(url or "")
	url = LIBNetURL.normalize(url)

	for k, v in pairs(parameter) do
		url.query[k] = v
	end

	url = tostring(url)
	return url
end

function LIB.NormalizeURL(url)
	url = LIB.SanitizeUrl(url)

	if not LIB.IsOfflineURL(url) then
		url = LIBNetURL.normalize(url)
		url = tostring(url)
	end

	url = string.Trim(url)

	return url
end

function LIB.IsOfflineURL( url )
	url = string.Trim( url or "" )
	local protocol = string.Trim( string.match( url, ( "^([ -~]+):[//\\][//\\]" ) ) or "" )

	if protocol == "" then
		return true
	end

	if protocol == "file" then
		return true
	end

	return false
end

function LIB.IsDriveLetterOfflineURL( url )
	if not LIB.IsOfflineURL(url) then
		return false
	end

	url = string.Trim( url or "" )

	local driveLetter = string.Trim( string.match( url, ( "([a-zA-Z]+):[//\\]" ) ) or "" )

	if driveLetter == "" then
		return false
	end

	return true
end

function LIB.ConvertURL( url )
	url = LIB.SanitizeUrl(url)

	if LIB.IsOfflineURL( url ) then
		local fileurl = LIB.SanitizeUrl( string.match( url, ( ":[//\\][//\\]([ -~]+)$" ) ) or "" )

		if fileurl ~= "" then
			url = fileurl
		end

		url = "sound/" .. url
		url = NormalizeOfflineFilename(url)
		return url, StreamRadioLib.STREAM_URLTYPE_FILE
	end

	local Cachefile = StreamRadioLib.Cache.GetFile( url )
	if Cachefile then
		url = "data/" .. Cachefile
		url = NormalizeOfflineFilename(url)

		return url, StreamRadioLib.STREAM_URLTYPE_CACHE
	end

	local URLType = StreamRadioLib.STREAM_URLTYPE_ONLINE

	url = LIB.NormalizeURL(url)

	return url, URLType
end

function LIB.EmptyTableSafe(tab)
	if not tab then
		return
	end

	table.Empty(tab)
end

function LIB.DeleteFolder(path)
	if not StreamRadioLib.DataDirectory then
		return false
	end

	if StreamRadioLib.DataDirectory == "" then
		return false
	end

	if path == "" then
		return false
	end

	if not string.StartWith(path, StreamRadioLib.DataDirectory) then
		return false
	end

	local files, folders = file.Find(path .. "/*", "DATA")

	for k, v in pairs(folders or {}) do
		LIB.DeleteFolder(path .. "/" .. v)
	end

	for k, v in pairs(files or {}) do
		file.Delete(path .. "/" .. v)
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

