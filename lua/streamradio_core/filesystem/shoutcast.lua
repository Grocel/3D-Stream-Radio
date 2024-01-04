local RADIOFS = RADIOFS
if not istable( RADIOFS ) then
	StreamRadioLib.Filesystem.Load()
	return
end

local LIBShoutcast = StreamRadioLib.Shoutcast
local LIBWhitelist = StreamRadioLib.Whitelist
local LIBFilesystem = StreamRadioLib.Filesystem

RADIOFS.name = "SHOUTcast"
RADIOFS.type = "shoutcast"
RADIOFS.icon = StreamRadioLib.GetPNGIcon("sound")

RADIOFS.priority = 50000
RADIOFS.nocreate = true
RADIOFS.loadToWhitelist = false

local g_playlistfile = "> Browse Stations <"

function RADIOFS:GetGenreHierarchy(vpath)
	if not self:IsInFolder(vpath) then
		return nil
	end

	local levels = self:GetPathLevels(vpath)
	local mainGenre = levels[2] or ""
	local subGenre = levels[3] or ""

	if mainGenre == "" or self:LevelIsPlaylistFile(mainGenre) then
		return {}
	end

	if subGenre == "" or self:LevelIsPlaylistFile(subGenre) then
		return {mainGenre}
	end

	return {mainGenre, subGenre}
end

function RADIOFS:LevelIsPlaylistFile(level)
	level = tostring(level or "")

	if level == string.lower(g_playlistfile) then
		return true
	end

	return false
end

function RADIOFS:IsPlaylistFile(vpath)
	if not self:IsInFolder(vpath) then
		return false
	end

	local levels = self:GetPathLevels(vpath)
	local level2 = levels[2] or ""
	local level3 = levels[3] or ""
	local level4 = levels[4] or ""

	if self:LevelIsPlaylistFile(level2) then
		return true
	end

	if self:LevelIsPlaylistFile(level3) then
		return true
	end

	if self:LevelIsPlaylistFile(level4) then
		return true
	end

	return false
end

function RADIOFS:IsInFolder(vpath)
	local levels = self:GetPathLevels(vpath)
	local firstlevel = levels[1] or ""

	if firstlevel ~= ":shoutcast" then
		return false
	end

	return true
end

function RADIOFS:IsType(globalpath, vpath)
	return self:IsInFolder(vpath)
end

function RADIOFS:Find(globalpath, vfolder, callback)
	if vfolder == "" then
		callback(true, nil, {":shoutcast"})
		return true
	end

	if not self:IsInFolder(vfolder) then
		callback(false, nil, nil)
		return false
	end

	if self:IsPlaylistFile(vfolder) then
		callback(false, nil, nil)
		return false
	end

	local hierarchy = self:GetGenreHierarchy(vfolder)
	if not hierarchy then
		callback(false, nil, nil)
		return false
	end

	local genre = LIBShoutcast.GetGenre(hierarchy)
	if not genre then
		callback(false, nil, nil)
		return false
	end

	local subGenres = genre.childrenTitles

	if genre.isRoot then
		callback(true, nil, subGenres)
		return true
	end

	callback(true, {g_playlistfile}, subGenres)
	return true
end

function RADIOFS:Exists(globalpath, vpath)
	if self:IsPlaylistFile(vpath) then
		return true
	end

	local hierarchy = self:GetGenreHierarchy(vpath)
	if not hierarchy then
		return false
	end

	if not LIBShoutcast.GenreExists(hierarchy) then
		return false
	end

	return true
end

RADIOFS.Delete = nil

function RADIOFS:Read(globalpath, vpath, callback)
	if not self:IsPlaylistFile(vpath) then
		callback(false, nil)
		return false
	end

	local hierarchy = self:GetGenreHierarchy(vpath)
	if not hierarchy then
		callback(false, nil)
		return false
	end

	LIBShoutcast.GetListOfGenre(hierarchy, function(success, items)
		if not success then
			callback(false, nil)
			return
		end

		local playlist = {}

		for i, v in ipairs(items) do
			local item = {
				name = v.name,
				url = v.streamUrl,
			}

			table.insert(playlist, item)
		end

		callback(true, playlist)
		return
	end)

	return true
end

LIBWhitelist.AddCheckFunction("shoutcast", function(url)
	if not LIBFilesystem.IsEnabledFilesystem("shoutcast") then
		return nil
	end

	if not LIBShoutcast.IsShoutcastUrl(url) then
		return nil
	end

	--[[
		Shoutcast gets a spacial treatment to avoid its auto/dynamic playlist needing to be iterated.
		This would cause like 100+ HTTP calls on every server start up otherwise.
	]]

	return true
end)

return true

