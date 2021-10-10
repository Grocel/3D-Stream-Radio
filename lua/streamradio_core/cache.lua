StreamRadioLib.Cache = StreamRadioLib.Cache or {}
local LIB = StreamRadioLib.Cache

LIB.forbidden = {}
LIB.lastloaded = {}

local g_isDedicatedServer = (SERVER and game.IsDedicated())
local MainDir = (StreamRadioLib.DataDirectory or "") .. "/cache"

local MinFileSize = 2 ^ 16 -- 64 KB
local MaxFileSize = 2 ^ 28 -- 256 MB
local MaxCacheSize = 2 ^ 34 -- 16 GB
local MaxCacheCount = 1024

local function CreateBaseFolder( dir )
	if not file.IsDir( dir, "DATA" ) then
		file.CreateDir( dir )
	end
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
		if not StreamRadioLib.DataDirectory then
			return
		end

		if not StreamRadioLib.DeleteFolder( MainDir ) then
			StreamRadioLib.Msg( ply, "Server stream cache could not be cleared!" )
			return
		end

		LIB.lastloaded = {}
		LIB.forbidden = {}

		StreamRadioLib.Msg( ply, "Server stream cache cleared!" )
	else
		StreamRadioLib.Msg( ply, "You need to be an admin clear the server stream cache." )
	end
end

concommand.Add( "sv_streamradio_cacheclear", Cache_Clear )

if ( CLIENT ) then
	local function Cache_Clear( ply, cmd, args )
		if not StreamRadioLib.DataDirectory then
			return
		end

		if not StreamRadioLib.DeleteFolder( MainDir ) then
			StreamRadioLib.Msg( ply, "Client stream cache could not be cleared!" )
			return
		end

		LIB.lastloaded = {}
		LIB.forbidden = {}

		StreamRadioLib.Msg( ply, "Client stream cache cleared!" )
	end

	concommand.Add( "cl_streamradio_cacheclear", Cache_Clear )
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
	url = StreamRadioLib.NormalizeURL(url)

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

	-- new -> old
	table.SortByMember( files, "time", false )

	local index = 1
	for k, v in pairs( files ) do
		local path = v.path
		local size = v.size

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

	if len == -1 then
		-- allow trying to download the file if the size is unknown
		return true
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

function LIB.Download(url, callback, saveas_url)
	local queueurl = saveas_url or url or ""
	if queueurl == "" then return false end

	if not isfunction( callback ) then
		callback = function( len, headers, code, saved )
			-- dummy function
		end
	end

	if SERVER and not g_isDedicatedServer then
		LIB.lastloaded[queueurl] = nil
		callback(queueurl, 0, {}, -1, false)
		return true
	end

	if LIB.forbidden[queueurl] then
		LIB.lastloaded[queueurl] = nil
		callback(queueurl, 0, {}, -1, false)
		return true
	end

	local onLoad = function(success, data)
		local err = data.err or data.code
		local len = data.len
		local headers = data.headers
		local code = data.code

		if not success then
			LIB.lastloaded[queueurl] = nil
			callback(queueurl, 0, {}, err, false)
			return
		end

		if LIB.forbidden[queueurl] then
			LIB.lastloaded[queueurl] = nil
			callback(queueurl, len, headers, -1, false)
			return
		end

		local contenttype, maintype, subtype = GetContentType( headers )

		if contenttype_blacklist[contenttype] then
			LIB.lastloaded[queueurl] = nil
			callback(queueurl, len, headers, -1, false)
			return
		end

		if maintype and contenttype_blacklist[maintype .. "/*"] then
			LIB.lastloaded[queueurl] = nil
			callback(queueurl, len, headers, -1, false)
			return
		end

		if subtype and contenttype_blacklist["*/" .. subtype] then
			LIB.lastloaded[queueurl] = nil
			callback(queueurl, len, headers, -1, false)
			return
		end

		if not LIB.CanDownload(len) then
			LIB.lastloaded[queueurl] = nil
			LIB.forbidden[queueurl] = true
			callback(queueurl, len, headers, -1, false)
		end

		local saved = Cache_Save(queueurl, data.body)

		LIB.lastloaded = {}
		LIB.lastloaded[queueurl] = data

		callback(queueurl, len, headers, code, saved)
	end

	local cache = LIB.lastloaded[queueurl]
	if cache then
		StreamRadioLib.Timedcall(onLoad, true, cache)
		return true
	end

	local status = StreamRadioLib.Http.Request(url, onLoad)
	return status
end
