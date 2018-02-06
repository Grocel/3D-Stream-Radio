StreamRadioLib.Playlist = StreamRadioLib.Playlist or {}
local LIB = StreamRadioLib.Playlist

local pairs = pairs
local type = type
local IsValid = IsValid
local file = file
local table = table
local string = string
local util = util
local player = player
local ents = ents
local MainDir = ( StreamRadioLib.DataDirectory or "" ) .. "/playlists"
local MX_RadioFile = "mxradio.txt"
local SCar_RadioFile = "scarradiochannels.txt"
local WebRadio_RadioFile = "webradiobookmarks.txt"


local function IsValidFile( File )
	return ( not file.IsDir( File, "DATA" ) and file.Exists( File, "DATA" ) )
end

local function SetupPath( folder1, folder2 )
	folder1 = folder1 or ""
	folder2 = folder2 or ""

	if ( folder1 == "" ) then return end
	if ( folder2 == "" ) then return end

	return ( folder1 .. "/" .. folder2 )
end

local function ConvertVirtualFilename(filename)
	filename = filename or ""

	local ext = string.GetExtensionFromFilename(filename) or ""
	if ext == "txt" then return filename end

	local validext = StreamRadioLib.TYPE_TABLE_VALUE[ext]
	if not validext then return filename end


	local noext = string.sub( filename, 0, -( 2 + #ext ) )

	filename = noext .. "_" .. ext .. ".txt"

	return filename
end

local function VirtualPathToGlobal(path)
	path = path or ""
	path = SetupPath( MainDir, path ) or MainDir
	path = ConvertVirtualFilename(path)

	return path
end

function LIB.IsValidFolder(folderpath)
	if not StreamRadioLib.DataDirectory then return false end

	local path = SetupPath(MainDir, folderpath) or MainDir
	if not file.IsDir(path, "DATA") then return false end

	return true
end

function LIB.IsValidFile(filepath)
	if not StreamRadioLib.DataDirectory then return false end

	local Path = SetupPath(MainDir, filepath) or MainDir
	if not IsValidFile(Path) then return false end

	return true
end

function LIB.Find( name, callback, folder, endcallback, not_async, ... )
	if not isfunction(callback) then return end
	if not StreamRadioLib.DataDirectory then return end

	name = "radio_files_[" .. tostring(name) .. "]"

	local Path = SetupPath( MainDir, folder ) or MainDir

	local CallbackFiles = {}
	local args = {...}

	local _, Folders = file.Find( Path .. "/*", "DATA", "nameasc" )

	if not isfunction(endcallback) then
		endcallback = function() end
	end

	for k, v in pairs( Folders ) do
		CallbackFiles[#CallbackFiles + 1] = {
			type = StreamRadioLib.TYPE_FOLDER,
			file = v
		}
	end

	for t, ext in pairs( StreamRadioLib.TYPE_TABLE_KEY ) do
		if ( t == StreamRadioLib.TYPE_MXRADIO ) then continue end
		if ( t == StreamRadioLib.TYPE_FOLDER ) then continue end
		local Files = file.Find( Path .. "/*_" .. ext .. ".txt", "DATA", "nameasc" )

		for k, v in pairs( Files ) do
			CallbackFiles[#CallbackFiles + 1] = {
				type = t,
				file = v
			}
		end
	end

	if Path == MainDir then
		CallbackFiles[#CallbackFiles + 1] = {
			type = StreamRadioLib.TYPE_MXRADIO,
			file = "MX-Radio"
		}

		CallbackFiles[#CallbackFiles + 1] = {
			type = StreamRadioLib.TYPE_WEBRADIO,
			file = "Web-Radio"
		}

		CallbackFiles[#CallbackFiles + 1] = {
			type = StreamRadioLib.TYPE_PPLAY,
			file = "PPlay-List"
		}

		CallbackFiles[#CallbackFiles + 1] = {
			type = StreamRadioLib.TYPE_SCARSRADIO,
			file = "SCar-Radio"
		}
	end

	local len = #CallbackFiles

	StreamRadioLib.TimedpairsStop( name )

	local func = function( k, v, ... )
		if not isfunction( callback ) then return false end

		local filename = v.file or ""
		local filetype = v.type or StreamRadioLib.TYPE_FOLDER
		local filepath = SetupPath( folder, filename ) or filename
		local Fullpath = Path .. "/" .. filename

		if ( filetype == StreamRadioLib.TYPE_FOLDER ) then
			if ( file.IsDir( Fullpath, "DATA" ) ) then
				return callback( Fullpath, filepath, filename, StreamRadioLib.TYPE_FOLDER, k, len )
			end

			return
		end

		if filetype == StreamRadioLib.TYPE_MXRADIO and IsValidFile( MX_RadioFile ) then
			local mxpath = string.GetFileFromFilename( MX_RadioFile ) or ""

			if ( mxpath == "" ) then
				mxpath = MX_RadioFile
			end

			return callback( "MX-Radio", "MX-Radio", "MX-Radio", StreamRadioLib.TYPE_MXRADIO, k, len )
		end

		if filetype == StreamRadioLib.TYPE_WEBRADIO and IsValidFile( WebRadio_RadioFile ) and game.SinglePlayer( ) then
			local mxpath = string.GetFileFromFilename( WebRadio_RadioFile ) or ""

			if ( mxpath == "" ) then
				mxpath = WebRadio_RadioFile
			end

			return callback( "Web-Radio", "Web-Radio", "Web-Radio", StreamRadioLib.TYPE_WEBRADIO, k, len )
		end

		if filetype == StreamRadioLib.TYPE_PPLAY and istable( sh_PPlay ) then
			return callback( "PPlay-List", "PPlay-List", "PPlay-List", StreamRadioLib.TYPE_PPLAY, k, len )
		end

		-- Not compatible, as SCar doesn't use sound.PlayURL(), yet...
		--[[
		if ( filetype == StreamRadioLib.TYPE_SCARSRADIO and IsValidFile( SCar_RadioFile ) and game.SinglePlayer( ) ) then
			local scpath = string.GetFileFromFilename( SCar_RadioFile ) or ""
			if ( scpath == "" ) then
				scpath = SCar_RadioFile
			end

			return callback( SCar_RadioFile, scpath, "SCar-Radio", StreamRadioLib.TYPE_SCARSRADIO, k, len )
		end
		]]--

		if ( IsValidFile( Fullpath ) ) then
			local ext = StreamRadioLib.TYPE_TABLE_KEY[filetype]
			local noext = string.sub( filename, 0, -( 6 + #ext ) )

			filename = noext .. "." .. ext
			filepath = SetupPath( folder, filename ) or filename

			return callback( Fullpath, filepath, noext .. "." .. ext, filetype, k, len )
		end
	end

	if not_async then
		local lastv = nil
		local lastk = nil

		for k, v in pairs(CallbackFiles) do
			lastv = v
			lastk = k

			local r = func(k, v, unpack( args ))
			if r == false then
				break
			end
		end

		endcallback(lastk, lastv, unpack( args ))

		return
	end

	StreamRadioLib.Timedpairs( name, CallbackFiles, 1, func, endcallback, unpack( args ) )
end


local g_ReadPlaylistFuncs = {}
local g_WritePlaylistFuncs = {}

local function sanitizedata(data)

	local tmp = {}
	for k, v in pairs(data) do
		local url = string.Trim(tostring(v.url or v.uri or v.link or v.source or v.path or ""))
		local name = string.Trim(tostring(v.name or v.title or ""))

		if url == "" then
			continue
		end

		if name == "" then
			name = url
		end

		tmp[#tmp + 1] = {
			order = tonumber(k or 0) or 0,
			name = name,
			url = url,
		}
	end

	table.SortByMember(tmp, "order", true)

	for i, v in ipairs(tmp) do
		tmp[i].order = nil
	end

	return tmp
end

function LIB.Read(plpath, pltype)
	plpath = plpath or ""
	pltype = pltype or 0

	local func = g_ReadPlaylistFuncs[pltype]
	if not func then return nil end

	local data = func(plpath, pltype)
	if not data then return nil end

	data = sanitizedata(data)
	return data
end

function LIB.Write(plpath, pltype, data)
	plpath = plpath or ""
	pltype = pltype or 0

	local func = g_WritePlaylistFuncs[pltype]
	if not func then return false end

	data = sanitizedata(data or {})

	local saved = func(plpath, data, pltype)
	if not saved then return false end

	return true
end

function LIB.CanReadFormat(pltype)
	pltype = pltype or 0

	local func = g_ReadPlaylistFuncs[pltype]
	if not func then return false end

	return true
end

function LIB.CanWriteFormat(pltype)
	pltype = pltype or 0

	local func = g_WritePlaylistFuncs[pltype]
	if not func then return false end

	return true
end

local function SavePCall(func, ...)
	if ( not isfunction( func ) ) then
		return nil
	end

	return pcall(func, ...)
end

local function Getfilestring(f)
	if ( not f ) then return "" end
	return string.Trim( f:Read( f:Size( ) ) or "" )
end

g_ReadPlaylistFuncs[StreamRadioLib.TYPE_PLS] = function( File )
	local Path = VirtualPathToGlobal(File)

	if ( not IsValidFile( Path ) ) then return false end
	local f = file.Open( Path, "r", "DATA" )
	if ( not f ) then return false end

	local RawPlaylist = Getfilestring(f)
	f:Close( )
	if ( RawPlaylist == "" ) then return {} end

	local RawPlaylistLowered = string.lower( RawPlaylist )
	local Count = tonumber( string.match( RawPlaylistLowered, '%s*numberofentries%s*=%s*([0-9]+)' ) ) or 0
	local Playlist = {}

	if ( Count > 0 ) then
		local Index = 1

		for i = 1, Count do
			local url = string.Trim( string.match( RawPlaylist, ( "%s*File" .. i .. "%s*=%s*([%w%p%_]+)" ) ) or "" )
			local name = string.Trim( string.match( RawPlaylist, ( "%s*Title" .. i .. "%s*=%s*([%w%p% %_]+)" ) ) or "" )

			if ( name == "" ) then
				name = url
			end

			if( url == "" ) then
				continue
			end

			Playlist[Index] = {
				name = name,
				url = url
			}

			Index = Index + 1
		end
	end

	return Playlist
end

g_ReadPlaylistFuncs[StreamRadioLib.TYPE_M3U] = function( File )
	local Path = VirtualPathToGlobal(File)

	if ( not IsValidFile( Path ) ) then return false end
	local f = file.Open( Path, "r", "DATA" )
	if ( not f ) then return false end

	local RawPlaylist = Getfilestring(f)
	f:Close( )
	if ( RawPlaylist == "" ) then return {} end

	local RawPlaylistTab = string.Split( RawPlaylist, "\n" )
	local AdvancedM3U = string.lower( string.Trim( RawPlaylistTab[1] ) ) == '#extm3u'
	local Playlist = {}
	local Index = 1

	if ( not AdvancedM3U ) then
		for i = 1, #RawPlaylistTab do
			local url = string.Trim( RawPlaylistTab[i] or "" )
			local name = url

			if( url == "" ) then
				continue
			end

			if( url[1] == "#" ) then
				continue
			end

			Playlist[Index] = {
				name = name,
				url = url
			}

			Index = Index + 1
		end

		return Playlist
	end

	for i = 2, #RawPlaylistTab, 2 do
		local name = string.Trim( string.match( RawPlaylistTab[i], ( "%s*#EXTINF:%s*%d%s*,%s*([%w%p% %_]+)" ) ) or "" )
		local url = string.Trim( RawPlaylistTab[i + 1] or "" )

		if ( name == "" ) then
			name = url
		end

		if( url == "" ) then
			continue
		end

		Playlist[Index] = {
			name = name,
			url = url
		}

		Index = Index + 1
	end

	return Playlist
end

g_ReadPlaylistFuncs[StreamRadioLib.TYPE_JSON] = function( File )
	local Path = VirtualPathToGlobal(File)

	if ( not IsValidFile( Path ) ) then return false end
	local f = file.Open( Path, "r", "DATA" )
	if ( not f ) then return false end

	local RawPlaylist = Getfilestring(f)
	f:Close( )
	if ( RawPlaylist == "" ) then return {} end

	local Playlist = util.JSONToTable( RawPlaylist ) or {}

	return Playlist
end

g_ReadPlaylistFuncs[StreamRadioLib.TYPE_VDF] = function( File )
	local Path = VirtualPathToGlobal(File)
	if ( not IsValidFile( Path ) ) then return false end
	local f = file.Open( Path, "r", "DATA" )
	if ( not f ) then return false end

	local RawPlaylist = Getfilestring(f)
	f:Close( )
	if ( RawPlaylist == "" ) then return {} end

	local Playlist = util.KeyValuesToTable( RawPlaylist, false, true ) or {}

	return Playlist
end

g_ReadPlaylistFuncs[StreamRadioLib.TYPE_MXRADIO] = function( )
	if ( not game.SinglePlayer( ) ) then return false end
	if ( not IsValidFile( MX_RadioFile ) ) then return false end
	local f = file.Open( MX_RadioFile, "r", "DATA" )
	if ( not f ) then return false end

	local RawPlaylist = Getfilestring(f)
	f:Close( )
	if ( RawPlaylist == "" ) then return {} end

	local RawPlaylistTab = string.Split( RawPlaylist, "\n" )
	local Playlist = {}
	local Index = 1

	for i = 1, #RawPlaylistTab, 2 do
		local url = string.Trim( RawPlaylistTab[i] or "" )
		local name = string.Trim( RawPlaylistTab[i + 1] or "" )

		if ( name == "" ) then
			name = url
		end

		if( url == "" ) then
			continue
		end

		Playlist[Index] = {
			name = name,
			url = url
		}

		Index = Index + 1
	end

	return Playlist
end

g_ReadPlaylistFuncs[StreamRadioLib.TYPE_SCARSRADIO] = function( )
	if ( not game.SinglePlayer( ) ) then return false end
	if ( not IsValidFile( SCar_RadioFile ) ) then return false end
	local f = file.Open( SCar_RadioFile, "rb", "DATA" )
	if ( not f ) then return false end

	local RawPlaylist = Getfilestring(f)
	f:Close( )
	if ( RawPlaylist == "" ) then return {} end

	local RawPlaylistTab = string.Split( RawPlaylist, "\n" )
	local Playlist = {}
	local Index = 1

	for i = 1, #RawPlaylistTab do
		local line = string.Split( RawPlaylistTab[i], string.char( 0xA4 ) )
		local name = string.Trim( line[1] or "" )
		local url = string.Trim( line[2] or "" )

		if ( name == "" ) then
			name = url
		end

		if( url == "" ) then
			continue
		end

		Playlist[Index] = {
			name = name,
			url = url
		}

		Index = Index + 1
	end

	return Playlist
end

g_ReadPlaylistFuncs[StreamRadioLib.TYPE_WEBRADIO] = function( )
	if ( not game.SinglePlayer( ) ) then return false end
	if ( not IsValidFile( WebRadio_RadioFile ) ) then return false end
	local f = file.Open( WebRadio_RadioFile, "r", "DATA" )
	if ( not f ) then return false end

	local RawPlaylist = Getfilestring(f)
	f:Close( )
	if ( RawPlaylist == "" ) then return {} end

	local RawPlaylistTab = string.Split( RawPlaylist, "\n" )
	local Playlist = {}
	local Index = 1

	for i = 1, #RawPlaylistTab do
		local line = string.Split( RawPlaylistTab[i], "#:#" )
		local name = string.Trim( line[1] or "" )
		local url = string.Trim( line[2] or "" )

		if ( name == "" ) then
			name = url
		end

		if( url == "" ) then
			continue
		end

		Playlist[Index] = {
			name = name,
			url = url
		}

		Index = Index + 1
	end

	return Playlist
end

g_ReadPlaylistFuncs[StreamRadioLib.TYPE_PPLAY] = function( )
	if ( not istable( sh_PPlay ) ) then return false end
	local tempPlaylist = {}

	local run = SavePCall( sh_PPlay.getSQLTable, "pplay_streamlist", function( result )
		tempPlaylist = result
	end, false, nil )

	if ( not run ) then return false end
	local Playlist = {}
	local Index = 1

	for k, v in pairs( tempPlaylist ) do
		local entry = v["info"] or {}
		local name = string.Trim( entry["title"] or "" )
		local url = string.Trim( entry["streamurl"] or "" )

		if ( name == "" ) then
			name = url
		end

		if( url == "" ) then
			continue
		end

		Playlist[Index] = {
			name = name,
			url = url
		}

		Index = Index + 1
	end

	return Playlist
end

local function CreateDirForFile( filename )
	local Folder = string.GetPathFromFilename( filename ) or ""
	if ( Folder == "" ) then return true end

	if ( not file.IsDir( Folder, "DATA" ) ) then
		file.CreateDir( Folder )
	end

	return file.IsDir( Folder, "DATA" )
end

g_WritePlaylistFuncs[StreamRadioLib.TYPE_PLS] = function( File, Data )
	if ( not Data ) then return false end
	local Path = VirtualPathToGlobal(File)

	if ( not CreateDirForFile( Path ) ) then return false end
	local f = file.Open( Path, "w", "DATA" )
	if ( not f ) then return false end
	local Count = #Data
	local DataString = string.format( "[playlist]\nNumberOfEntries=%i\n", Count )
	local Seperator = "\n"
	local Seperator2 = "="

	for k, v in pairs( Data ) do
		local name = string.Replace( v.name, Seperator, "" )
		local url = string.Replace( v.url, Seperator, "" )
		name = string.Trim( string.Replace( name, Seperator2, "" ) )
		url = string.Trim( string.Replace( url, Seperator2, "" ) )

		DataString = DataString .. string.format( "File%i" .. Seperator2 .. "%s" .. Seperator .. "Title%i" .. Seperator2 .. "%s" .. Seperator .. "Length%i" .. Seperator2 .. "-1\n", k, url, k, name, k )
	end

	DataString = DataString .. "Version=2"
	DataString = string.Trim( DataString )
	DataString = DataString .. "\n\n"

	f:Write( DataString )
	f:Close( )

	return true
end

g_WritePlaylistFuncs[StreamRadioLib.TYPE_M3U] = function( File, Data )
	if ( not Data ) then return false end
	local Path = VirtualPathToGlobal(File)

	if ( not CreateDirForFile( Path ) ) then return false end
	local f = file.Open( Path, "w", "DATA" )
	if ( not f ) then return false end
	local DataString = "#EXTM3U\n"
	local Seperator = "\n"

	for k, v in pairs( Data ) do
		local name = string.Trim( string.Replace( v.name, Seperator, "" ) )
		local url = string.Trim( string.Replace( v.url, Seperator, "" ) )

		DataString = DataString .. string.format( "#EXTINF:0,%s" .. Seperator .. "%s\n", name, url )
	end

	DataString = string.Trim( DataString )
	DataString = DataString .. "\n\n"

	f:Write( DataString )
	f:Close( )

	return true
end

g_WritePlaylistFuncs[StreamRadioLib.TYPE_JSON] = function( File, Data )
	if ( not Data ) then return false end
	local Path = VirtualPathToGlobal(File)

	if ( not CreateDirForFile( Path ) ) then return false end
	local f = file.Open( Path, "w", "DATA" )
	if ( not f ) then return false end

	local DataString = util.TableToJSON( Data )
	DataString = string.Trim( DataString )
	DataString = DataString .. "\n\n"

	f:Write( DataString )
	f:Close( )

	return true
end

g_WritePlaylistFuncs[StreamRadioLib.TYPE_VDF] = function( File, Data )
	if ( not Data ) then return false end
	local Path = VirtualPathToGlobal(File)

	if ( not CreateDirForFile( Path ) ) then return false end
	local f = file.Open( Path, "w", "DATA" )
	if ( not f ) then return false end

	local DataString = util.TableToKeyValues( Data )
	DataString = string.Trim( DataString )
	DataString = DataString .. "\n\n"

	f:Write( DataString )
	f:Close( )

	return true
end

g_WritePlaylistFuncs[StreamRadioLib.TYPE_MXRADIO] = function( _, Data )
	if ( not Data ) then return false end
	if ( not CreateDirForFile( MX_RadioFile ) ) then return false end
	local f = file.Open( MX_RadioFile, "w", "DATA" )
	if ( not f ) then return false end
	local DataString = ""
	local Seperator = "\n"

	for k, v in pairs( Data ) do
		local name = string.Trim( string.Replace( v.name, Seperator, "" ) )
		local url = string.Trim( string.Replace( v.url, Seperator, "" ) )

		DataString = DataString .. string.format( "%s" .. Seperator .. "%s\n", url, name )
	end

	DataString = string.Trim( DataString )
	f:Write( DataString )
	f:Close( )

	-- Telling the MX-Radio addon to update it's playlist.
	SavePCall( SetUpStationTable )

	return true
end

g_WritePlaylistFuncs[StreamRadioLib.TYPE_SCARSRADIO] = function( _, Data )
	if ( not game.SinglePlayer( ) ) then return false end
	if ( not Data ) then return false end
	if ( not CreateDirForFile( SCar_RadioFile ) ) then return false end
	local f = file.Open( SCar_RadioFile, "wb", "DATA" )
	if ( not f ) then return false end
	local DataString = ""
	local Seperator = string.char( 0xA4 )

	for k, v in pairs( Data ) do
		local name = string.Trim( string.Replace( v.name, Seperator, "" ) )
		local url = string.Trim( string.Replace( v.url, Seperator, "" ) )

		DataString = DataString .. string.format( "%s" .. Seperator .. "%s\n", name, url )
	end

	DataString = string.Trim( DataString )
	f:Write( DataString )
	f:Close( )

	return true
end

g_WritePlaylistFuncs[StreamRadioLib.TYPE_WEBRADIO] = function( _, Data )
	if ( not game.SinglePlayer( ) ) then return false end
	if ( not Data ) then return false end
	if ( not CreateDirForFile( WebRadio_RadioFile ) ) then return false end
	local f = file.Open( WebRadio_RadioFile, "w", "DATA" )
	if ( not f ) then return false end
	local DataString = ""
	local Seperator = "#:#"

	for k, v in pairs( Data ) do
		local name = string.Trim( string.Replace( v.name, Seperator, "" ) )
		local url = string.Trim( string.Replace( v.url, Seperator, "" ) )

		DataString = DataString .. string.format( "%s" .. Seperator .. "%s" .. Seperator .. "Radio Stream\n", name, url )
	end

	DataString = string.Trim( DataString )
	f:Write( DataString )
	f:Close( )

	return true
end

g_WritePlaylistFuncs[StreamRadioLib.TYPE_PPLAY] = function( _, Data )
	if ( not istable( sh_PPlay ) ) then return false end
	local tempPlaylist = {}
	local Seperator = "|"
	sql.Query( "DELETE FROM pplay_streamlist;" )

	for k, v in pairs( Data ) do
		local name = string.Replace( v.name, Seperator, "" )
		local url = string.Replace( v.url, Seperator, "" )
		name = sql.SQLStr( name, true )
		url = sql.SQLStr( url, true )
		name = string.Trim( name )
		url = string.Trim( url )

		local item = {}
		item.title = name
		item.streamurl = url
		local run = SavePCall( sh_PPlay.insertRow, nil, "pplay_streamlist", item, "station" )
		if ( not run ) then return false end
	end

	return true
end
