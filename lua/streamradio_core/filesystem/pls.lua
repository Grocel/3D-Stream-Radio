local RADIOFS = RADIOFS
if not istable( RADIOFS ) then
	StreamRadioLib.Filesystem.Load()
	return
end

RADIOFS.name = "PLS"
RADIOFS.type = "pls"
RADIOFS.extension = "pls"
RADIOFS.icon = StreamRadioLib.GetPNGIcon("table_sound", true)

RADIOFS.priority = 9000
RADIOFS.loadToWhitelist = true

local function decodePLS(RawPlaylist)
	local RawPlaylistTab = string.Split( RawPlaylist, "\n" )

	local Header = string.lower( string.Trim( RawPlaylistTab[1] or "" ) )
	local Version = string.lower( string.Trim( RawPlaylistTab[#RawPlaylistTab] or "" ) )

	if Header ~= "[playlist]" then
		return nil
	end

	if Version ~= "version=2" then
		return nil
	end

	local CountHeader = string.lower( string.Trim( RawPlaylistTab[2] or "" ) )
	local Count = tonumber(string.match(CountHeader, "%s*numberofentries%s*=%s*([0-9]+)")) or 0

	local Playlist = {}

	if Count <= 0 then
		return Playlist
	end

	for i = 1, Count do
		local line = i * 3

		local UrlLine = RawPlaylistTab[line] or ""
		local NameLine = RawPlaylistTab[line + 1] or ""

		local url = string.Trim(string.match(UrlLine, "%s*File" .. i .. "%s*=%s*([^\n]+)") or "")
		local name = string.Trim(string.match(NameLine, "%s*Title" .. i .. "%s*=%s*([^\n]+)") or "")

		if name == "" then
			name = url
		end

		if url == "" then
			continue
		end

		local item = {
			name = name,
			url = url
		}

		table.insert(Playlist, item)
	end

	return Playlist
end

function RADIOFS:Read(globalpath, vpath, callback)
	file.AsyncRead(globalpath, "DATA", function(fileName, gamePath, status, data)
		if status ~= FSASYNC_OK then
			callback(false, nil)
			return
		end

		local RawPlaylist = string.Trim(data or "")
		if RawPlaylist == "" then
			callback(true, {})
			return
		end

		local Playlist = decodePLS(RawPlaylist)
		if not Playlist then
			callback(false, nil)
			return
		end

		callback(true, Playlist)
	end)

	return true
end

function RADIOFS:Write(globalpath, vpath, data, callback)
	if not self:CreateDirectoryForFile(globalpath) then
		callback(false)
		return false
	end

	local f = file.Open(globalpath, "w", "DATA")
	if not f then
		callback(false)
		return false
	end

	local dataOut = {}
	local Count = #data
	local Seperator = "\n"
	local Seperator2 = "="

	dataOut[#dataOut + 1] = string.format( "[playlist]\nNumberOfEntries=%i\n", Count )

	for i, v in ipairs( data ) do
		local name = string.Replace( v.name, Seperator, "" )
		local url = string.Replace( v.url, Seperator, "" )
		name = string.Trim( string.Replace( name, Seperator2, "" ) )
		url = string.Trim( string.Replace( url, Seperator2, "" ) )

		dataOut[#dataOut + 1] = string.format( "File%i" .. Seperator2 .. "%s" .. Seperator .. "Title%i" .. Seperator2 .. "%s" .. Seperator .. "Length%i" .. Seperator2 .. "-1\n", k, url, k, name, k )
	end

	dataOut[#dataOut + 1] = "Version=2"
	local DataString = table.concat(dataOut, "")

	DataString = string.Trim(DataString)
	DataString = DataString .. "\n\n"

	f:Write( DataString )
	f:Close( )

	callback(true)
	return true
end

return true

