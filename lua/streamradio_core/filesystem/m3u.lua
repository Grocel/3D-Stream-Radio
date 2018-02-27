local RADIOFS = RADIOFS
if not istable( RADIOFS ) then
	StreamRadioLib.Filesystem.Load()
	return
end

RADIOFS.name = "M3U"
RADIOFS.type = "m3u"
RADIOFS.icon = StreamRadioLib.GetPNGIcon("page")

RADIOFS.priority = 10000
RADIOFS.default = true

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

	local RawPlaylistTab = string.Split( RawPlaylist, "\n" )
	local AdvancedM3U = string.lower( string.Trim( RawPlaylistTab[1] ) ) == '#extm3u'
	local Playlist = {}
	local Index = 1

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

			Playlist[Index] = {
				name = name,
				url = url
			}

			Index = Index + 1
		end

		callback(true, Playlist)
		return true
	end

	for i = 2, #RawPlaylistTab, 2 do
		local name = string.Trim( string.match( RawPlaylistTab[i], ( "%s*#EXTINF:%s*%d%s*,%s*([%w%p% %_]+)" ) ) or "" )
		local url = string.Trim( RawPlaylistTab[i + 1] or "" )

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

	local DataString = "#EXTM3U\n"
	local Seperator = "\n"

	for k, v in pairs(data) do
		local name = string.Trim(string.Replace(v.name, Seperator, ""))
		local url = string.Trim(string.Replace(v.url, Seperator, ""))

		DataString = DataString .. string.format("#EXTINF:0,%s" .. Seperator .. "%s\n", name, url)
	end

	DataString = string.Trim(DataString)
	DataString = DataString .. "\n\n"

	f:Write(DataString)
	f:Close()

	callback(true)
	return true
end
