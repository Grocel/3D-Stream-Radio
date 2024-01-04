local RADIOFS = RADIOFS
if not istable( RADIOFS ) then
	StreamRadioLib.Filesystem.Load()
	return
end

local g_addonname = "MX-Radio"
local g_addonid = ""

RADIOFS.name = g_addonname
RADIOFS.type = g_addonname
RADIOFS.icon = StreamRadioLib.GetPNGIcon("format_radio", true)

RADIOFS.addonname = g_addonname
RADIOFS.addonid = g_addonid

RADIOFS.priority = 100
RADIOFS.nocreate = true
RADIOFS.loadToWhitelist = true

RADIOFS._filepath = "mxradio.txt"
RADIOFS._filename = g_addonname
RADIOFS._filenamelower = string.lower(RADIOFS._filename)

function RADIOFS:IsInFolder(vpath)
	local levels = self:GetPathLevels(vpath)
	local firstlevel = levels[1] or ""

	if firstlevel ~= ":addons" then
		return false
	end

	return true
end

function RADIOFS:IsAddonFile(vpath)
	if not self:IsInFolder(vpath) then
		return false
	end

	vpath = string.lower(string.GetFileFromFilename(vpath))

	if vpath ~= self._filenamelower then
		return false
	end

	return true
end

function RADIOFS:IsInstalled()
	if CLIENT then
		return true
	end

	if self._isInstalled ~= nil then
		return self._isInstalled
	end

	if not isfunction(SetUpStationTable) then
		self._isInstalled = false
		return self._isInstalled
	end

	if not file.Exists(self._filepath, "DATA") then
		self._isInstalled = false
		return self._isInstalled
	end

	self._isInstalled = true
	return self._isInstalled
end

function RADIOFS:IsType(globalpath, vpath)
	return self:IsAddonFile(vpath)
end

function RADIOFS:Find(globalpath, vfolder, callback)
	if not self:IsInstalled() then
		callback(false, nil, nil)
		return false
	end

	if vfolder == "" then
		callback(true, nil, {":addons"})
		return true
	end

	if not self:IsInFolder(vfolder) then
		callback(false, nil, nil)
		return false
	end

	callback(true, {self._filename}, nil)
	return true
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

local function decodeAddonfile(RawPlaylist)
	local RawPlaylistTab = string.Split( RawPlaylist, "\n" )
	local Playlist = {}

	for i = 1, #RawPlaylistTab, 2 do
		local url = string.Trim( RawPlaylistTab[i] or "" )
		local name = string.Trim( RawPlaylistTab[i + 1] or "" )

		if name == "" then
			name = url
		end

		if url == "" then
			continue
		end

		Playlist[#Playlist + 1] = {
			name = name,
			url = url
		}
	end

	return Playlist
end

function RADIOFS:Read(globalpath, vpath, callback)
	globalpath = self._filepath

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

		local Playlist = decodeAddonfile(RawPlaylist)
		if not Playlist then
			callback(false, nil)
			return
		end

		callback(true, Playlist)
	end)

	return true
end

function RADIOFS:Write(globalpath, vpath, data, callback)
	globalpath = self._filepath
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

	for i, v in ipairs(data) do
		local name = string.Trim( string.Replace( v.name, Seperator, "" ) )
		local url = string.Trim( string.Replace( v.url, Seperator, "" ) )

		dataOut[#dataOut + 1] = string.format( "%s" .. Seperator .. "%s\n", url, name )
	end

	local DataString = table.concat(dataOut, "")

	DataString = string.Trim(DataString)
	DataString = DataString .. "\n\n"

	f:Write(DataString)
	f:Close()

	-- Telling the MX-Radio addon to update its playlist.
	self:SavePCall(SetUpStationTable)

	callback(true)
	return true
end

return true

