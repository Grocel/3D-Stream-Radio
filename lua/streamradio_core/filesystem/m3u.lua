local RADIOFS = RADIOFS
if not istable( RADIOFS ) then
	StreamRadioLib.Filesystem.Load()
	return
end

RADIOFS.name = "M3U"
RADIOFS.type = "m3u"
RADIOFS.extension = "m3u"
RADIOFS.icon = StreamRadioLib.GetPNGIcon("table_sound", true)

RADIOFS.priority = 10000
RADIOFS.default = true
RADIOFS.loadToWhitelist = true

local function decodeM3U(RawPlaylist)
	local RawPlaylistTab = string.Split( RawPlaylist, "\n" )
	local AdvancedM3U = string.lower( string.Trim( RawPlaylistTab[1] or "" ) ) == "#extm3u"
	local Playlist = {}

	if not AdvancedM3U then
		for i = 1, #RawPlaylistTab do
			local url = string.Trim( RawPlaylistTab[i] or "" )
			local name = url

			if url == "" then
				continue
			end

			if url[1] == "#" then
				continue
			end

			local item = {
				name = name,
				url = url
			}

			table.insert(Playlist, item)
		end

		callback(true, Playlist)
		return true
	end

	for i = 2, #RawPlaylistTab, 2 do
		local name = string.Trim( string.match( RawPlaylistTab[i], "%s*#EXTINF:%s*%d%s*,%s*([^\n]+)" ) or "" )
		local url = string.Trim( RawPlaylistTab[i + 1] or "" )

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

		local Playlist = decodeM3U(RawPlaylist)
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
	local Seperator = "\n"

	dataOut[#dataOut + 1] = "#EXTM3U\n"

	for i, v in ipairs(data) do
		local name = string.Trim(string.Replace(v.name, Seperator, ""))
		local url = string.Trim(string.Replace(v.url, Seperator, ""))

		dataOut[#dataOut + 1] = string.format("#EXTINF:0,%s" .. Seperator .. "%s\n", name, url)
	end

	local DataString = table.concat(dataOut, "")

	DataString = string.Trim(DataString)
	DataString = DataString .. "\n\n"

	f:Write(DataString)
	f:Close()

	callback(true)
	return true
end

return true

