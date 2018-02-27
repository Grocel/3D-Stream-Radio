local RADIOFS = RADIOFS
if not istable( RADIOFS ) then
	StreamRadioLib.Filesystem.Load()
	return
end

RADIOFS.name = "PLS"
RADIOFS.type = "pls"
RADIOFS.icon = StreamRadioLib.GetPNGIcon("format_pls", true)

RADIOFS.priority = 9000

function RADIOFS:Read(globalpath, vpath, callback)
	local f = file.Open(globalpath, "r", "DATA")

	if not f then
		callback(false, nil)
		return false
	end

	local RawPlaylist = string.Trim(f:Read(f:Size()) or "")
	f:Close()


	if RawPlaylist == "" then
		callback(true, {})
		return true
	end

	local RawPlaylistLowered = string.lower(RawPlaylist)
	local Count = tonumber(string.match(RawPlaylistLowered, '%s*numberofentries%s*=%s*([0-9]+)')) or 0
	local Playlist = {}

	if Count > 0 then
		local Index = 1

		for i = 1, Count do
			local url = string.Trim(string.match(RawPlaylist, "%s*File" .. i .. "%s*=%s*([%w%p%_]+)") or "")
			local name = string.Trim(string.match(RawPlaylist, "%s*Title" .. i .. "%s*=%s*([%w%p% %_]+)") or "")

			if name == "" then
				name = url
			end

			if url == "" then
				continue
			end

			Playlist[Index] = {
				name = name,
				url = url
			}

			Index = Index + 1
		end
	end

	callback(true, Playlist)
	return true
end

function RADIOFS:Write(globalpath, vpath, data, callback)
	if not self:CreateDirForFile(globalpath) then
		callback(false)
		return false
	end

	local f = file.Open(globalpath, "w", "DATA")
	if not f then
		callback(false)
		return false
	end

	local Count = #data
	local DataString = string.format( "[playlist]\nNumberOfEntries=%i\n", Count )
	local Seperator = "\n"
	local Seperator2 = "="

	for k, v in pairs( data ) do
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

	callback(true)
	return true
end
