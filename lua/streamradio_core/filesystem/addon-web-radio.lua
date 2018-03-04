local RADIOFS = RADIOFS
if not istable( RADIOFS ) then
	StreamRadioLib.Filesystem.Load()
	return
end

local g_addonname = "Web-Radio"
local g_addonid = ""

RADIOFS.name = "Addon " .. g_addonname
RADIOFS.type = g_addonname
RADIOFS.icon = StreamRadioLib.GetPNGIcon("format_radio", true)

RADIOFS.addonname = g_addonname
RADIOFS.addonid = g_addonid

RADIOFS.priority = 90
RADIOFS.nocreate = true

RADIOFS._filepath = "webradiobookmarks.txt"
RADIOFS._filename = g_addonname
RADIOFS._filenamelower = string.lower(RADIOFS._filename)

function RADIOFS:IsInFolder(vfolder)
	local levels = self:GetPathLevels(vfolder)
	local firstlevel = levels[1] or ""

	if firstlevel ~= ":addons" then
		return false
	end

	return true
end

function RADIOFS:IsFileInFolder(vpath)
	vpath = string.GetPathFromFilename(vpath)
	return self:IsInFolder(vpath)
end

function RADIOFS:IsAddonFile(vpath)
	if not self:IsFileInFolder(vpath) then
		return false
	end

	vpath = string.GetFileFromFilename(vpath)

	if vpath ~= self._filenamelower then
		return false
	end

	return true
end

function RADIOFS:IsInstalled()
	if not file.Exists(self._filepath, "DATA") then
		return false
	end

	return true
end

function RADIOFS:IsType(globalpath, vpath)
	if not self:IsInstalled() then
		return false
	end

	return self:IsAddonFile(vpath)
end

function RADIOFS:Find(globalpath, vfolder)
	if not self:IsInstalled() then
		return nil
	end

	if vfolder == "" then
		return nil, {":addons"}
	end

	if not self:IsInFolder(vfolder) then
		return nil
	end

	return {self._filename}
end

function RADIOFS:Exists(globalpath, vpath)
	if not self:IsInstalled() then
		return false
	end

	if not self:IsAddonFile(vpath) then
		return false
	end

	return true
end

RADIOFS.Delete = nil

function RADIOFS:Read(globalpath, vpath, callback)
	globalpath = self._filepath
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
	local Playlist = {}
	local Index = 1

	for i = 1, #RawPlaylistTab do
		local line = string.Split( RawPlaylistTab[i], "#:#" )
		local name = string.Trim( line[1] or "" )
		local url = string.Trim( line[2] or "" )

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
	globalpath = self._filepath
	if not self:CreateDirForFile(globalpath) then
		callback(false)
		return false
	end

	local f = file.Open(globalpath, "w", "DATA")
	if not f then
		callback(false)
		return false
	end

	local DataString = ""
	local Seperator = "#:#"

	for k, v in pairs( data ) do
		local name = string.Trim( string.Replace( v.name, Seperator, "" ) )
		local url = string.Trim( string.Replace( v.url, Seperator, "" ) )

		DataString = DataString .. string.format( "%s" .. Seperator .. "%s" .. Seperator .. "Radio Stream\n", name, url )
	end

	DataString = string.Trim( DataString )
	f:Write( DataString )
	f:Close( )

	callback(true)
	return true
end
