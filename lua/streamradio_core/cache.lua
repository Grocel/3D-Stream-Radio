local StreamRadioLib = StreamRadioLib

StreamRadioLib.Cache = StreamRadioLib.Cache or {}

local LIB = StreamRadioLib.Cache
table.Empty(LIB)

local LIBUtil = StreamRadioLib.Util

local g_emptyFunction = function() end
local g_forbidden = LIBUtil.CreateCacheArray(256)

local g_nextCacheCleanup = 0

StreamRadioLib.Hook.Add("PostCleanupMap", "reset_cache_download_cache", function()
	g_forbidden:Empty()
	g_nextCacheCleanup = 0
end)

local g_mainDir = nil
local g_mainDirLegacy = nil

local g_minFileSize = 2 ^ 16 -- 64 KB
local g_maxFileSize = 2 ^ 29 -- 28 -- 256 MB
local g_maxFileAge = 7 * 24 * 3600 -- 7 days
local g_maxCacheSize = 2 ^ 34 -- 16 GB
local g_maxCacheCount = 1024

local g_minCacheCleanupInterval = 60 -- 1 Minute

g_maxFileSize = math.min(g_maxCacheSize, g_maxFileSize)

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

local function Cache_Cleanup(force)
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
	if not g_mainDir then
		return nil
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

	Cache_Cleanup(false)

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

function LIB.CanDownload(filesize)
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
		-- too small, likly broken or not a real sound file
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

		if not LIB.CanDownload(len) then
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
	local cacheRealm = SERVER and "sv" or "cl"

	g_mainDir = LIBUtil.GetMainDirectory(string.format("cache-%s", cacheRealm))
	g_mainDirLegacy = LIBUtil.GetMainDirectory("cache")

	LIBUtil.DeleteFolder(g_mainDirLegacy)
	Cache_Cleanup(true)
end

do
	local function Cache_Clear(ply, cmd, args)
		if not LIBUtil.IsAdminForCMD(ply) then
			StreamRadioLib.Print.Msg(ply, "You need to be an admin clear the server stream cache.")
			return
		end

		LIBUtil.DeleteFolder(g_mainDirLegacy)

		if not LIBUtil.DeleteFolder(g_mainDir) then
			StreamRadioLib.Print.Msg(ply, "Server stream cache could not be cleared!")
			return
		end

		g_forbidden:Empty()
		StreamRadioLib.Print.Msg(ply, "Server stream cache cleared!")
	end

	concommand.Add( "sv_streamradio_cacheclear", Cache_Clear )

	if CLIENT then
		local function Cache_Clear(ply, cmd, args)
			LIBUtil.DeleteFolder(g_mainDirLegacy)

			if not LIBUtil.DeleteFolder(g_mainDir) then
				StreamRadioLib.Print.Msg(ply, "Client stream cache could not be cleared!")
				return
			end

			g_forbidden:Empty()
			StreamRadioLib.Print.Msg(ply, "Client stream cache cleared!")
		end

		concommand.Add("cl_streamradio_cacheclear", Cache_Clear)
	end
end

return true

