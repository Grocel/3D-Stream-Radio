StreamRadioLib.Cache = StreamRadioLib.Cache or {}
local LIB = StreamRadioLib.Cache

LIB.queue = LIB.queue or {}
LIB.loading = LIB.loading or {}
LIB.forbidden = LIB.forbidden or {}
LIB.lastloaded = LIB.lastloaded or {}

local g_isDedicatedServer = (SERVER and game.IsDedicated())
local MainDir = (StreamRadioLib.DataDirectory or "") .. "/cache"

local MinFileSize = 2 ^ 16 // 64 KB
local MaxFileSize = 2 ^ 26 // 64 MB
local MaxCacheSize = 2 ^ 30 // 1 GB
local MaxCacheCount = 128
local MaxCacheAge = 3600 * 24 * 7 // 1 Week

local function CreateBaseFolder( dir )
	if not file.IsDir( dir, "DATA" ) then
		file.CreateDir( dir )
	end
end

local function DeleteFolder( path )
	path = path or ""
	if ( path == "" ) then return end

	local files, folders = file.Find( path .. "/*", "DATA" )

	for k, v in pairs( files or {} ) do
		file.Delete( path .. "/" .. v )
	end

	for k, v in pairs( folders or {} ) do
		DeleteFolder( path .. "/" .. v )
	end

	file.Delete( path )

	if not file.Exists( path, "DATA" ) then
		return true
	end

	if not file.IsDir( path, "DATA" ) then
		return true
	end

	return false
end

local function Cache_Clear( ply, cmd, args )
	if game.SinglePlayer() then
		StreamRadioLib.Msg( ply, "A server stream cache does not exist in single player!" )
		return
	end

	if not g_isDedicatedServer then
		StreamRadioLib.Msg( ply, "A server stream cache does not exist on listen servers!" )
		return
	end

	if ( not ply or ( IsValid( ply ) and ply:IsAdmin( ) ) ) then
		if not DeleteFolder( MainDir ) then
			StreamRadioLib.Msg( ply, "Server stream cache could not be cleared!" )
			return
		end

		StreamRadioLib.Msg( ply, "Server stream cache cleared!" )
	else
		StreamRadioLib.Msg( ply, "You need to be an admin clear the server stream cache." )
	end
end

concommand.Add( "sv_streamradio_cacheclear", Cache_Clear )

if ( CLIENT ) then
	local function Cache_Clear( ply, cmd, args )
		if not DeleteFolder( MainDir ) then
			StreamRadioLib.Msg( ply, "Client stream cache could not be cleared!" )
			return
		end

		StreamRadioLib.Msg( ply, "Client stream cache cleared!" )
	end

	concommand.Add( "cl_streamradio_cacheclear", Cache_Clear )
end

local function IsValidFile( File )
	return ( not file.IsDir( File, "DATA" ) and file.Exists( File, "DATA" ) )
end

local function Hash( var )
	var = tostring( var or "" )

	local hash = string.format(
		"%08x%08x%08x",
		tonumber( util.CRC( var ) ),
		tonumber( util.CRC( "StreamRadioLib: '" .. var .. "'" )),
		tonumber( util.CRC( #var ) )
	)

	return hash
end

local function GetFilenameFromURL( url )
	local filename = Hash( url ) or ""
	if ( filename == "" ) then return end

	local path = MainDir .. "/cache_" .. filename .. ".dat"
	return path
end

local function Cache_GetCacheMap()
	local map = {}
	map.files = {}
	map.totalsize = 0

	if ( not file.IsDir( MainDir, "DATA" ) ) then
		return map
	end

	local files = file.Find( MainDir .. "/*", "DATA" ) or {}
	local index = 0

	for k, v in pairs( files ) do
		local path = MainDir .. "/" .. v
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

	local sizeleft = map.totalsize - MaxCacheSize
	if ( sizeleft < 0 ) then
		sizeleft = 0
	end

	local now = os.time()

	-- new -> old
	table.SortByMember( files, "time", false )

	local index = 1
	for k, v in pairs( files ) do
		local path = v.path
		local name = v.name
		local size = v.size
		local time = v.time

		if ( index >= MaxCacheCount ) then
			file.Delete( path )

			if ( sizeleft > 0 ) then
				sizeleft = sizeleft - size
			end

			continue
		end

		if ( size < MinFileSize or size > MaxFileSize or size > MaxCacheSize ) then
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
		local name = v.name
		local size = v.size
		local time = v.time

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

	CreateBaseFolder( MainDir )
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

function LIB.CanDownload( len )
	if SERVER and not g_isDedicatedServer then
		return false
	end

	len = tonumber(len or 0) or 0

	if len <= 0 then
		return false
	end

	if len > MaxCacheSize then
		return false
	end

	if len > MaxFileSize then
		return false
	end

	if len < MinFileSize then
		return false
	end

	return true
end

local function CallCallbacks(queueurl, ...)
	if not queueurl then return end

	local queue = LIB.queue
	if not queue then return end

	queue = LIB.queue[queueurl]
	if not queue then return end

	for i, v in ipairs(queue) do
		if not v then continue end
		v(...)
	end

	LIB.queue[queueurl] = nil
end

local function InternalDownload(url, saveas_url)
	local queueurl = saveas_url or url or ""
	if queueurl == "" then return false end

	if SERVER and not g_isDedicatedServer then
		CallCallbacks(queueurl, 0, {}, -1, false)
		return true
	end

	if LIB.forbidden[queueurl] then
		CallCallbacks(queueurl, 0, {}, -1, false)
		return true
	end

	if LIB.loading[queueurl] then
		return true
	end

	LIB.loading[queueurl] = true

	local onLoad = function( data, len, headers, code )
		LIB.loading[queueurl] = nil

		data = data or ""
		len = len or 0
		headers = headers or {}
		code = code or -1

		if LIB.forbidden[queueurl] then
			CallCallbacks(queueurl, len, headers, -1, false)
			return
		end

		local contenttype, maintype, subtype = GetContentType( headers )

		if contenttype_blacklist[contenttype] then
			CallCallbacks(queueurl, len, headers, -1, false)
			return
		end

		if maintype and contenttype_blacklist[maintype .. "/*"] then
			CallCallbacks(queueurl, len, headers, -1, false)
			return
		end

		if subtype and contenttype_blacklist["*/" .. subtype] then
			CallCallbacks(queueurl, len, headers, -1, false)
			return
		end

		if not LIB.CanDownload( len ) then
			LIB.forbidden[queueurl] = true
			CallCallbacks(queueurl, len, headers, -1, false)
		end

		local saved = Cache_Save(queueurl, data)

		LIB.lastloaded = {}
		LIB.lastloaded[queueurl] = {
			data = data,
			len = len,
			headers = headers,
			code = code,
		}

		CallCallbacks(queueurl, len, headers, code, saved)
	end

	local cache = LIB.lastloaded[queueurl]
	if cache then
		StreamRadioLib.Timedcall(onLoad, cache.data, cache.len, cache.headers, cache.code)
		return true
	end

	http.Fetch(url or "", onLoad, function( err )
		LIB.loading[queueurl] = nil
		CallCallbacks(queueurl, 0, {}, err, false)
	end)

	return true
end

function LIB.Download(url, callback, saveas_url)
	local queueurl = saveas_url or url or ""
	if queueurl == "" then return false end

	if not isfunction( callback ) then
		callback = function( len, headers, code, saved )
			-- dummy function
		end
	end

	LIB.queue = LIB.queue or {}
	LIB.queue[queueurl] = LIB.queue[queueurl] or {}
	LIB.queue[queueurl][#LIB.queue[queueurl] + 1] = callback

	return InternalDownload(url, saveas_url)
end
