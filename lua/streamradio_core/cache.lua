local StreamRadioLib = StreamRadioLib
local LIB = StreamRadioLib:NewLib("Cache")

local LIBUtil = StreamRadioLib.Util
local LIBBass = StreamRadioLib.Bass
local LIBTimer = StreamRadioLib.Timer
local LIBPrint = StreamRadioLib.Print

local g_emptyFunction = function() end
local g_forbidden = LIBUtil.CreateCacheArray(256)

local g_nextCacheCleanup = 0

local g_mainDir = nil
local g_mainDirLegacy = nil

local g_minFileSize = 65535 -- 64 KB
local g_minCacheCleanupInterval = 60

local g_maxFileSize = nil
local g_maxFileAge = nil
local g_maxFileLength = nil
local g_maxCacheSize = nil
local g_maxCacheCount = nil

local g_cacheRealm = SERVER and "sv" or "cl"
local g_cacheRealmFlag = SERVER and FCVAR_GAMEDLL or FCVAR_CLIENTDLL

local g_cvCacheMaxFileSize = CreateConVar(
	g_cacheRealm .. "_streamradio_cache_max_file_size",
	"256",
	bit.bor(FCVAR_ARCHIVE, g_cacheRealmFlag ),
	"Maximum size of cached files in MB. Default: 256, Min: 0 (no cache), Max: 256",
	0,
	256
)

local g_cvCacheMaxFileAge = CreateConVar(
	g_cacheRealm .. "_streamradio_cache_max_file_age",
	"10080",
	bit.bor( FCVAR_ARCHIVE, g_cacheRealmFlag ),
	"Maximum age of cached files in minutes. Default: 10080 (1 week), Min: 0 (no cache), Max: 40320 (4 weeks)",
	0,
	40320
)

local g_cvCacheMaxFileLength = CreateConVar(
	g_cacheRealm .. "_streamradio_cache_max_file_length",
	"90",
	bit.bor( FCVAR_ARCHIVE, g_cacheRealmFlag ),
	"Maximum length of cached files in minutes. Default: 90, Min: 0 (no cache), Max: 120",
	0,
	120
)

local g_cvCacheMaxSize = CreateConVar(
	g_cacheRealm .. "_streamradio_cache_max_size",
	"16384",
	bit.bor( FCVAR_ARCHIVE, g_cacheRealmFlag ),
	"Maximum total size of all cached files in MB. Default: 16384, Min: 0 (no cache), Max: 16384",
	0,
	16384
)

local g_cvCacheMaxCount = CreateConVar(
	g_cacheRealm .. "_streamradio_cache_max_count",
	"1024",
	bit.bor( FCVAR_ARCHIVE, g_cacheRealmFlag ),
	"Maximum total count of all cached files. Default: 1024, Min: 0 (no cache), Max: 8192 (4 weeks)",
	0,
	8192
)

local MB = 1024 ^ 2
local MINUTES = 60


local function UpdateLimitsInternal()
	g_maxFileSize = math.Clamp(g_cvCacheMaxFileSize:GetInt(), 0, 256) * MB
	g_maxFileAge = math.Clamp(g_cvCacheMaxFileAge:GetFloat(), 0, 40320) * MINUTES
	g_maxFileLength = math.Clamp(g_cvCacheMaxFileLength:GetFloat(), 0, 120) * MINUTES
	g_maxCacheSize = math.Clamp(g_cvCacheMaxSize:GetInt(), 0, 65536) * MB
	g_maxCacheCount = math.Clamp(g_cvCacheMaxCount:GetInt(), 0, 8192)

	g_maxFileSize = math.min(g_maxCacheSize, g_maxFileSize)

	g_forbidden:Empty()
	g_nextCacheCleanup = 0
end

local function UpdateLimits()
	LIBTimer.NextFrame("Cache_UpdateLimits", UpdateLimitsInternal)
end

if SERVER then
	cvars.AddChangeCallback("sv_streamradio_cache_max_file_size", UpdateLimits, "streamradio_cache_update_limits_callback")
	cvars.AddChangeCallback("sv_streamradio_cache_max_file_age", UpdateLimits, "streamradio_cache_update_limits_callback")
	cvars.AddChangeCallback("sv_streamradio_cache_max_file_length", UpdateLimits, "streamradio_cache_update_limits_callback")
	cvars.AddChangeCallback("sv_streamradio_cache_max_size", UpdateLimits, "streamradio_cache_update_limits_callback")
	cvars.AddChangeCallback("sv_streamradio_cache_max_count", UpdateLimits, "streamradio_cache_update_limits_callback")
end

if CLIENT then
	cvars.AddChangeCallback("cl_streamradio_cache_max_file_size", UpdateLimits, "streamradio_cache_update_limits_callback")
	cvars.AddChangeCallback("cl_streamradio_cache_max_file_age", UpdateLimits, "streamradio_cache_update_limits_callback")
	cvars.AddChangeCallback("cl_streamradio_cache_max_file_length", UpdateLimits, "streamradio_cache_update_limits_callback")
	cvars.AddChangeCallback("cl_streamradio_cache_max_size", UpdateLimits, "streamradio_cache_update_limits_callback")
	cvars.AddChangeCallback("cl_streamradio_cache_max_count", UpdateLimits, "streamradio_cache_update_limits_callback")
end

StreamRadioLib.Hook.Add("PostCleanupMap", "reset_cache_update_limits", function()
	g_oldIsActive = nil
	UpdateLimits()
end)

function LIB.IsActive()
	if SERVER and not LIBBass.CanLoadDLL() then
		-- Server side cache is only active/needed if GM_BASS3 is installed.
		-- Otherwise the server will never download or stream content.
		return false
	end

	if not g_mainDir then
		return false
	end

	if not g_maxCacheSize or g_maxCacheSize <= 0 then
		return false
	end

	if not g_maxCacheCount or g_maxCacheCount <= 0 then
		return false
	end

	if not g_maxFileAge or g_maxFileAge <= 0 then
		return false
	end

	if not g_maxFileLength or g_maxFileLength <= 0 then
		return false
	end

	if not g_minFileSize or g_minFileSize <= 0 then
		return false
	end

	if not g_maxFileSize or g_maxFileSize <= 0 then
		return false
	end

	return true
end

local function CreateBaseFolder(dir)
	if file.IsDir(dir, "DATA") then
		return
	end

	file.CreateDir(dir)
end

local function IsValidFile(path)
	if not file.Exists(path, "DATA") then
		return false
	end

	if file.IsDir(path, "DATA") then
		return false
	end

	return true
end

local function Hash(var)
	var = tostring(var or "")

	local hash = util.SHA1("StreamRadioLib: '" .. var .. "'")
	return hash
end

local function GetFilenameFromURL(url)
	if not g_mainDir then
		return nil
	end

	url = tostring(url or "")
	url = StreamRadioLib.Url.SanitizeUrl(url)

	if filename == "" then
		return nil
	end

	local hash = Hash(url)
	local path = string.format("%s/cache_%s.dat", g_mainDir, hash)

	return path
end

local function Cache_GetCacheMap()
	if not g_mainDir then
		return nil
	end

	if not file.IsDir(g_mainDir, "DATA") then
		return nil
	end

	local map = {}
	map.files = {}
	map.totalsize = 0

	local now = os.time()
	local files = file.Find(g_mainDir .. "/*", "DATA") or {}

	for k, v in ipairs(files) do
		local path = g_mainDir .. "/" .. v

		if not IsValidFile(path) then
			continue
		end

		local size = file.Size(path, "DATA") or 0
		size = math.max(size, 0)

		local time = file.Time(path, "DATA") or 0
		time = math.max(time, 0)

		local age = now - time
		age = math.max(age, 0)

		local filestats = {
			path = path,
			name = v,
			size = size,
			time = time,
			age = age,
		}

		map.totalsize = map.totalsize + size
		table.insert(map.files, filestats)
	end

	return map
end

function LIB.Cleanup(force)
	if not LIB.IsActive() then
		return
	end

	local now = RealTime()

	if not force and g_nextCacheCleanup > now then
		return
	end

	g_nextCacheCleanup = now + g_minCacheCleanupInterval

	local map = Cache_GetCacheMap()

	if not map then
		return
	end

	local files = map.files
	local filesleft = {}

	local sizeleft = map.totalsize - g_maxCacheSize
	sizeleft = math.max(sizeleft, 0)

	local delete = function(item)
		local path = item.path
		local size = item.size

		file.Delete(path)
		sizeleft = math.max(sizeleft - size, 0)
	end

	-- new -> old
	table.SortByMember(files, "time", false)

	local count = 0

	for k, item in ipairs(files) do
		local size = item.size
		local age = item.age

		if count >= g_maxCacheCount then
			-- max file count reached, deleting oldest files
			delete(item)
			continue
		end

		if age > g_maxFileAge then
			-- too old
			delete(item)
			continue
		end

		if size < g_minFileSize then
			-- too small, likly broken or not a real sound file
			delete(item)
			continue
		end

		if size > g_maxFileSize then
			-- too large
			delete(item)
			continue
		end

		table.insert(filesleft, v)
		count = count + 1
	end

	files = nil

	-- old -> new
	table.SortByMember(filesleft, "time", true)

	for k, item in ipairs(filesleft) do
		if sizeleft <= 0 then
			break
		end

		-- delete all files that exceed the total size limit
		-- oldest are deleted first
		delete(item)
	end
end

local function Cache_Save(url, data)
	if not LIB.IsActive() then
		return false
	end

	if not url then
		return false
	end

	if not data then
		return false
	end

	local path = GetFilenameFromURL(url)
	if not path then
		return false
	end

	CreateBaseFolder(g_mainDir)

	LIB.DeleteFileRaw(path)

	local f = file.Open(path, "wb", "DATA")
	if not f then
		return false
	end

	f:Write(data)
	f:Close()

	LIB.Cleanup(false)

	return true
end

function LIB.DeleteFileForUrl(url)
	local path = GetFilenameFromURL(url)

	if not LIB.DeleteFileRaw(path) then
		return false
	end

	return true
end

function LIB.DeleteFileRaw(path)
	if not path then return false end

	if not IsValidFile(path) then
		return true
	end

	file.Delete(path)

	if IsValidFile(path) then
		return false
	end

	return true
end

function LIB.GetFile(url)
	local path = GetFilenameFromURL(url)

	if not path then return nil end
	if not IsValidFile(path) then return nil end

	return path
end

local contenttype_blacklist = {
	["text/*"] = true,
	["image/*"] = true,
}

local function GetContentType( headers )
	if not istable(headers) then return "" end

	local contenttype = headers["Content-Type"] or headers["content-type"] or ""
	contenttype = (string.Explode(";", contenttype) or {})[1] or contenttype
	contenttype = string.Trim(contenttype)
	contenttype = string.lower(contenttype)

	local maintypes = string.Explode("/", contenttype) or {}
	local maintype = string.Trim(maintypes[1] or "")
	local subtype = string.Trim(maintypes[2] or "")

	if maintype == "" then
		maintype = nil
	end

	if subtype == "" then
		subtype = nil
	end

	return contenttype, maintype, subtype
end

function LIB.CanDownloadBySize(filesize)
	if not LIB.IsActive() then
		return false
	end

	filesize = tonumber(filesize or 0) or 0

	if filesize == -1 then
		-- we don't know the file size yet
		return true
	end

	if filesize > g_maxFileSize then
		-- too large
		return false
	end

	if filesize < g_minFileSize then
		-- too small, likely broken or not a real sound file
		return false
	end

	return true
end

function LIB.CanDownloadByLength(filelength)
	if not LIB.IsActive() then
		return false
	end

	filelength = tonumber(filelength or 0) or 0

	if filelength <= 0 then
		-- endless stream
		return false
	end

	if filelength > g_maxFileLength then
		-- too long, likely to big to download
		return false
	end

	return true
end


function LIB.Download(url, callback, saveAsUrl)
	url = tostring(url or "")
	saveAsUrl = tostring(saveAsUrl or "")
	callback = callback or g_emptyFunction

	if saveAsUrl == "" then
		saveAsUrl = url
	end

	if url == "" then
		callback(false, false, saveAsUrl)
		return
	end

	if saveAsUrl == "" then
		callback(false, false, saveAsUrl)
		return
	end

	if not LIB.IsActive() then
		callback(false, false, saveAsUrl)
		return
	end

	local cacheid = util.SHA256(saveAsUrl)

	if g_forbidden:Has(cacheid) then
		callback(false, false, saveAsUrl)
		return
	end

	local onLoad = function(success, data)
		local len = data.len
		local headers = data.headers

		if not success then
			callback(false, false, saveAsUrl)
			return
		end

		if g_forbidden:Has(cacheid) then
			callback(false, false, saveAsUrl)
			return
		end

		local contenttype, maintype, subtype = GetContentType( headers )

		if contenttype_blacklist[contenttype] then
			g_forbidden:Set(cacheid, true)
			callback(false, false, saveAsUrl)
			return
		end

		if maintype and contenttype_blacklist[maintype .. "/*"] then
			g_forbidden:Set(cacheid, true)
			callback(false, false, saveAsUrl)
			return
		end

		if subtype and contenttype_blacklist["*/" .. subtype] then
			g_forbidden:Set(cacheid, true)
			callback(false, false, saveAsUrl)
			return
		end

		if len == -1 then
			-- still unknown sizes can't be cached
			g_forbidden:Set(cacheid, true)

			callback(false, false, saveAsUrl)
			return
		end

		if not LIB.CanDownloadBySize(len) then
			g_forbidden:Set(cacheid, true)

			callback(false, false, saveAsUrl)
			return
		end

		g_forbidden:Remove(cacheid)

		local saved = Cache_Save(saveAsUrl, data.body)
		callback(true, saved, saveAsUrl)
	end

	StreamRadioLib.Http.Request(url, onLoad)
end

function LIB.Load()
	LIBUtil = StreamRadioLib.Util
	LIBBass = StreamRadioLib.Bass
	LIBTimer = StreamRadioLib.Timer
	LIBPrint = StreamRadioLib.Print

	g_mainDir = LIBUtil.GetMainDirectory(string.format("cache-%s", g_cacheRealm))
	g_mainDirLegacy = LIBUtil.GetMainDirectory("cache")

	LIBUtil.DeleteFolder(g_mainDirLegacy)
	UpdateLimitsInternal()

	LIB.Cleanup(true)
end

function LIB.Clear()
	LIBUtil.DeleteFolder(g_mainDirLegacy)

	if not LIBUtil.DeleteFolder(g_mainDir) then
		return false
	end

	UpdateLimitsInternal()

	return true
end

do
	local function Cache_Clear(ply, cmd, args)
		if not SERVER then
			return
		end

		if not LIBUtil.IsAdminForCMD(ply) then
			LIBPrint.Msg(ply, "You need to be an admin clear the server stream cache.")
			return
		end

		if not LIB.Clear() then
			LIBPrint.Msg(ply, "Server stream cache could not be cleared!")
			return
		end

		LIBPrint.Msg(ply, "Server stream cache cleared!")
	end

	concommand.Add( "sv_streamradio_cache_clear", Cache_Clear)

	if CLIENT then
		local function Cache_Clear(ply, cmd, args)
			if not LIB.Clear() then
				LIBPrint.Msg(ply, "Client stream cache could not be cleared!")
				return
			end

			LIBPrint.Msg(ply, "Client stream cache cleared!")
		end

		concommand.Add("cl_streamradio_cache_clear", Cache_Clear)
	end
end

return true

