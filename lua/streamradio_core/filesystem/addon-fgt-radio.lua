local RADIOFS = RADIOFS
if not istable( RADIOFS ) then
	StreamRadioLib.Filesystem.Load()
	return
end

local g_addonname = "F.G.T. Radio"
local g_addonid = "177192540"

RADIOFS.name = "Addon " .. g_addonname
RADIOFS.type = "FGT-Radio"
RADIOFS.icon = StreamRadioLib.GetPNGIcon("format_radio", true)

RADIOFS.addonname = g_addonname
RADIOFS.addonid = g_addonid

RADIOFS.priority = 80
RADIOFS.nocreate = true

RADIOFS._filename = g_addonname
RADIOFS._filenamelower = string.lower(RADIOFS._filename)
RADIOFS._cachetimeout = 300

function RADIOFS:IsInFolder(vfolder)
	vfolder = string.Trim(vfolder, "/")
	vfolder = string.Trim(vfolder, "\\")
	vfolder = string.Trim(vfolder, "/")
	vfolder = string.Trim(vfolder, "\\")

	if vfolder ~= ":addons" then
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
	if self._addoninstalled ~= nil then
		return self._addoninstalled
	end

	// Only use the addon's playlist, if the addon is installed!
	local addons = engine.GetAddons()

	for i, v in ipairs(addons) do
		if not v.mounted then continue end
		if not v.downloaded then continue end

		local id = tostring(v.wsid or "")
		if id ~= self.addonid then continue end

		self._addoninstalled = true
		return true
	end

	self._addoninstalled = false
	return false
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

function RADIOFS:ProccessQueue()
	if self._request_started then return true end

	local function callcallbacks(...)
		if not self._quene then return end
		if not self._request_started then return end

		local tmp = self._quene

		self._quene = nil
		self._request_started = nil

		for func, v in pairs(tmp) do
			if not isfunction(func) then continue end

			func(...)
		end
	end

	local status = self:Request("http://fgtradio.fgthou.se/list.php", function(suggess, result)
		if not suggess then
			callcallbacks(false, nil)
			return
		end

		local body = result.body

		if body == "" then
			callcallbacks(false, nil)
			return
		end

		local playlist = {}
		local lines = string.Explode("\n", body)

		for i, line in ipairs(lines) do
			local cols = string.Explode("\t", line)
			if #cols < 5 then continue end

			local id = cols[1]
			local title = string.Trim( cols[2] or "" )
			local artist = string.Trim( cols[3] or "" )
			local genre = string.Trim( cols[4] or "" )
			local url = string.Trim( cols[5] or "" )
			local name = title

			if artist == "" then
				artist = "Unknown"
			end

			if genre == "" then
				genre = "Unknown"
			end

			if name == "" then
				name = url
			else
				name = artist .. " - " .. title

				if genre ~= "Unknown" then
					name = name .. " [" .. genre .. "]"
				end
			end

			if url == "" then
				continue
			end

			playlist[#playlist + 1] = {
				order = id,
				name = name,
				url = url
			}
		end

		self._cache_playlist = {
			time = RealTime(),
			data = playlist,
		}

		callcallbacks(true, playlist)
	end)

	self._request_started = status
	return status
end


function RADIOFS:Read(globalpath, vpath, callback)
	if self._cache_playlist and self._cache_playlist.time and self._cache_playlist.data then
		local time = self._cache_playlist.time
		local data = self._cache_playlist.data

		if #data > 0 and (RealTime() - time) <= self._cachetimeout then
			self._quene = nil
			self._request_started = nil

			callback(true, data)
			return true
		end

		self._cache_playlist = nil
	end

	self._quene = self._quene or {}
	self._quene[callback] = true

	local status = self:ProccessQueue()
	return status
end
