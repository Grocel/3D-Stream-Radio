local StreamRadioLib = StreamRadioLib

StreamRadioLib.Cache = StreamRadioLib.Cache or {}
local LIB = StreamRadioLib.Cache

local g_forbidden = StreamRadioLib.Util.CreateCacheArray(256)
local g_lastloaded = StreamRadioLib.Util.CreateCacheArray(16)

StreamRadioLib.Hook.Add("PostCleanupMap", "reset_cache_download_cache", function()
	g_forbidden:Empty()
	g_lastloaded:Empty()
end)

local g_isDedicatedServer = (SERVER and game.IsDedicated())
local g_mainDir = (StreamRadioLib.DataDirectory or "") .. "/cache"

local g_minFileSize = 2 ^ 16 -- 64 KB
local g_maxFileSize = 2 ^ 28 -- 256 MB
local g_maxFileSizeFast = 2 ^ 24 -- 16 MB
local g_maxCacheSize = 2 ^ 34 -- 16 GB
local g_maxCacheCount = 1024

local function CreateBaseFolder( dir )
	if not file.IsDir( dir, "DATA" ) then
		file.CreateDir( dir )
	end
end

do
	local function Cache_Clear( ply, cmd, args )
		if game.SinglePlayer() then
			StreamRadioLib.Print.Msg( ply, "A server stream cache does not exist in single player!" )
			return
		end

		if not g_isDedicatedServer then
			StreamRadioLib.Print.Msg( ply, "A server stream cache does not exist on listen servers!" )
			return
		end

		if ( not ply or ( IsValid( ply ) and ply:IsAdmin( ) ) ) then
			if not StreamRadioLib.DataDirectory then
				return
			end

			if not StreamRadioLib.Util.DeleteFolder( g_mainDir ) then
				StreamRadioLib.Print.Msg( ply, "Server stream cache could not be cleared!" )
				return
			end

			g_forbidden:Empty()
			g_lastloaded:Empty()

			StreamRadioLib.Print.Msg( ply, "Server stream cache cleared!" )
		else
			StreamRadioLib.Print.Msg( ply, "You need to be an admin clear the server stream cache." )
		end
	end

	concommand.Add( "sv_streamradio_cacheclear", Cache_Clear )

	if ( CLIENT ) then
		local function Cache_Clear( ply, cmd, args )
			if not StreamRadioLib.DataDirectory then
				return
			end

			if not StreamRadioLib.Util.DeleteFolder( g_mainDir ) then
				StreamRadioLib.Print.Msg( ply, "Client stream cache could not be cleared!" )
				return
			end

			g_forbidden:Empty()
			g_lastloaded:Empty()

			StreamRadioLib.Print.Msg( ply, "Client stream cache cleared!" )
		end

		concommand.Add( "cl_streamradio_cacheclear", Cache_Clear )
	end
end

local function IsValidFile( File )
	return not file.IsDir( File, "DATA" ) and file.Exists( File, "DATA" )
end

local function Hash( var )
	var = tostring( var or "" )

	local hash = util.SHA1( "StreamRadioLib: '" .. var .. "'" )

	return hash
end

local function GetFilenameFromURL( url )
	url = tostring( url or "" )
	url = StreamRadioLib.Util.NormalizeURL(url)

	local filename = Hash( url ) or ""
	if ( filename == "" ) then return end

	local path = g_mainDir .. "/cache_" .. filename .. ".dat"
	return path
end

local function Cache_GetCacheMap()
	local map = {}
	map.files = {}
	map.totalsize = 0

	if ( not file.IsDir( g_mainDir, "DATA" ) ) then
		return map
	end

	local files = file.Find( g_mainDir .. "/*", "DATA" ) or {}
	local index = 0

	for k, v in pairs( files ) do
		local path = g_mainDir .. "/" .. v
		if ( not IsValidFile( path ) ) then continue end

		local size = file.Size(path, "DATA") or 0
		local time = file.Time(path, "DATA") or 0

		if (size < 0) then
			size = 0
		end

		local filestats = {
			path = path,
			name = v,
			size = size,
			time = time,
		}

		map.totalsize = map.totalsize + size

		index = index + 1
		map.files[index] = filestats
	end

	return map
end

local function Cache_Cleanup()
	local map = Cache_GetCacheMap()
	if ( not map ) then return end

	local files = map.files
	local filesleft = {}

	local sizeleft = map.totalsize - g_maxCacheSize
	if ( sizeleft < 0 ) then
		sizeleft = 0
	end

	-- new -> old
	table.SortByMember( files, "time", false )

	local index = 1
	for k, v in pairs( files ) do
		local path = v.path
		local size = v.size

		if ( index >= g_maxCacheCount ) then
			file.Delete( path )

			if ( sizeleft > 0 ) then
				sizeleft = sizeleft - size
			end

			continue
		end

		if ( size < g_minFileSize or size > g_maxFileSize or size > g_maxCacheSize ) then
			file.Delete( path )

			if ( sizeleft > 0 ) then
				sizeleft = sizeleft - size
			end

			continue
		end

		filesleft[index] = v
		index = index + 1
	end
	files = nil

	if ( sizeleft <= 0 ) then
		return
	end

	-- old -> new
	table.SortByMember( filesleft, "time", true )

	for k, v in pairs( filesleft ) do
		local path = v.path
		local size = v.size

		if ( sizeleft <= 0 ) then continue end

		file.Delete( path )
		sizeleft = sizeleft - size
	end
end

local function Cache_Save( url, data )
	if ( not url ) then return false end
	if ( not data ) then return false end

	local path = GetFilenameFromURL( url )
	if ( not path ) then return false end

	CreateBaseFolder( g_mainDir )
	Cache_Cleanup()

	local f = file.Open( path, "wb", "DATA" )
	if ( not f ) then return false end

	f:Write( data )
	f:Close( )

	return true
end

function LIB.DeleteFile( url )
	local path = GetFilenameFromURL( url )
	if ( not path ) then return false end
	if ( not IsValidFile( path ) ) then return false end

	file.Delete( path )
	if ( IsValidFile( path ) ) then return false end

	return true
end

function LIB.DeleteFileRaw( path )
	if ( not path ) then return false end
	if ( not IsValidFile( path ) ) then return false end

	file.Delete( path )
	if ( IsValidFile( path ) ) then return false end

	return true
end

function LIB.GetFile( url )
	local path = GetFilenameFromURL( url )

	if ( not path ) then return end
	if ( not IsValidFile( path ) ) then return end

	return path
end

local contenttype_blacklist = {
	["text/*"] = true,
	["image/*"] = true,
}

local function GetContentType( headers )
	if ( not istable( headers ) ) then return "" end

	local contenttype = headers["Content-Type"] or headers["content-type"] or ""
	contenttype = ( ( string.Explode( ";", contenttype ) or {} )[1] ) or contenttype
	contenttype = string.Trim(contenttype)
	contenttype = string.lower(contenttype)

	local maintypes = string.Explode( "/", contenttype ) or {}
	local maintype = string.Trim(maintypes[1] or "")
	local subtype = string.Trim(maintypes[2] or "")

	if ( maintype == "" ) then maintype = nil end
	if ( subtype == "" ) then subtype = nil end

	return contenttype, maintype, subtype
end

function LIB.CanDownload( filesize )
	if SERVER and not g_isDedicatedServer then
		return false
	end

	filesize = tonumber(filesize or 0) or 0

	if filesize == -1 then
		-- we don't know the file size yet
		return true
	end

	if filesize > g_maxCacheSize then
		return false
	end

	if filesize > g_maxFileSize then
		return false
	end

	if filesize < g_minFileSize then
		-- small files are likly not real sound files
		return false
	end

	return true
end

function LIB.Download(url, callback, saveas_url)
	local queueurl = saveas_url or url or ""
	if queueurl == "" then return false end

	local cacheid = util.SHA256(queueurl)

	if not isfunction( callback ) then
		callback = function( len, headers, code, saved )
			-- dummy function
		end
	end

	if SERVER and not g_isDedicatedServer then
		g_lastloaded:Remove(cacheid)
		callback(queueurl, 0, {}, -1, false)
		return true
	end

	if g_forbidden:Has(cacheid) then
		g_lastloaded:Remove(cacheid)
		callback(queueurl, 0, {}, -1, false)
		return true
	end

	local onLoad = function(success, data)
		local err = data.err or data.code
		local len = data.len
		local headers = data.headers
		local code = data.code

		if not success then
			g_lastloaded:Remove(cacheid)
			callback(queueurl, 0, {}, err, false)
			return
		end

		if g_forbidden:Has(cacheid) then
			g_lastloaded:Remove(cacheid)
			callback(queueurl, len, headers, -1, false)
			return
		end

		local contenttype, maintype, subtype = GetContentType( headers )

		if contenttype_blacklist[contenttype] then
			g_lastloaded:Remove(cacheid)
			callback(queueurl, len, headers, -1, false)
			return
		end

		if maintype and contenttype_blacklist[maintype .. "/*"] then
			g_lastloaded:Remove(cacheid)
			callback(queueurl, len, headers, -1, false)
			return
		end

		if subtype and contenttype_blacklist["*/" .. subtype] then
			g_lastloaded:Remove(cacheid)
			callback(queueurl, len, headers, -1, false)
			return
		end

		if len == -1 then
			-- still unknown sizes can't be cached
			g_lastloaded:Remove(cacheid)
			g_forbidden:Set(cacheid, true)

			callback(queueurl, len, headers, -1, false)
			return
		end

		if not LIB.CanDownload(len) then
			g_lastloaded:Remove(cacheid)
			g_forbidden:Set(cacheid, true)

			callback(queueurl, len, headers, -1, false)
			return
		end

		local saved = Cache_Save(queueurl, data.body)

		g_forbidden:Remove(cacheid)

		if len <= g_maxFileSizeFast then
			g_lastloaded:Set(cacheid, data)
		end

		callback(queueurl, len, headers, code, saved)
	end

	local cache = g_lastloaded:Get(cacheid)
	if cache then
		StreamRadioLib.Timedcall(onLoad, true, cache)
		return true
	end

	local status = StreamRadioLib.Http.Request(url, onLoad)
	return status
end
