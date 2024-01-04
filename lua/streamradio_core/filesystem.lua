local StreamRadioLib = StreamRadioLib

StreamRadioLib.Filesystem = StreamRadioLib.Filesystem or {}

local LIB = StreamRadioLib.Filesystem
table.Empty(LIB)

local LIBString = StreamRadioLib.String
local LIBUtil = StreamRadioLib.Util

local g_playlistdir = LIBUtil.GetMainDirectory("playlists")
local g_luaFilesystemDirectory = "streamradio_core/filesystem"
local g_Filesystem = {}
local g_FilesystemBlacklist = {}

local g_emptyFunction = function() end

local g_FolderID = 1
local g_VirtualFolderID = 250
local g_GenericID = ":generic"

local g_VirtualFolderIcon = StreamRadioLib.GetPNGIcon("folder_link")

StreamRadioLib.TYPE_FOLDER = g_FolderID
StreamRadioLib.TYPE_DEFAULT = nil
StreamRadioLib.VALID_FORMATS_EXTENSIONS_LIST = ""

local function getFS(id)
	if not g_Filesystem then return nil end
	if not g_Filesystem.id then return nil end
	if not g_Filesystem.type then return nil end
	if not g_Filesystem.name then return nil end

	if not id then return nil end

	local fs = g_Filesystem.id[id] or g_Filesystem.type[id] or g_Filesystem.name[id]
	if not fs then return nil end

	if fs.type ~= g_GenericID then
		if g_FilesystemBlacklist[fs.id] then return nil end
		if g_FilesystemBlacklist[fs.type] then return nil end
		if g_FilesystemBlacklist[fs.name] then return nil end
	end

	if isfunction(fs.IsInstalled) and not fs:IsInstalled() then
		return nil
	end

	return fs
end

local g_pathLevelsCache = {}

local function AddCommonFunctions(fs)
	if not fs then return end

	function fs:Find(globalpath, vfolder, callback)
		local files = file.Find(globalpath .. "/*_" .. self.type .. ".txt", "DATA", "nameasc")

		files = LIB.FilterInvalidFilesnames(files)

		callback(true, files, nil)
		return true
	end

	function fs:Delete(globalpath, vpath, callback)
		file.Delete(globalpath)
		local deleted = not file.Exists(globalpath, "DATA")
		callback(deleted)

		return deleted
	end

	function fs:Exists(globalpath, vpath)
		if not file.Exists(globalpath, "DATA") then
			return false
		end

		return true
	end

	function fs:CreateDirectoryForFile(globalpath)
		return LIBUtil.CreateDirectoryForFile(globalpath)
	end

	function fs:IsType(globalpath, vpath)
		local ext = string.lower(string.GetExtensionFromFilename(vpath) or "")
		if ext == self.type then
			return true
		end

		return false
	end

	function fs:SavePCall(func, ...)
		if not isfunction(func) then
			return nil
		end

		return pcall(func, ...)
	end

	function fs:GetPathLevels(vpath)
		vpath = string.Trim(vpath or "")

		g_pathLevelsCache = g_pathLevelsCache or {}

		if g_pathLevelsCache[vpath] then
			return g_pathLevelsCache[vpath]
		end

		g_pathLevelsCache[vpath] = nil

		local levels = string.Explode("/", vpath, false) or {}
		local out = {}

		for i, v in ipairs(levels) do
			v = string.Trim(v, "/")
			if v == "" then continue end

			table.insert(out, v)
		end

		if table.IsEmpty(out) then
			return out
		end

		g_pathLevelsCache[vpath] = out
		return out
	end
end

local function loadFilesystem(script)
	script = script or ""
	if script == "" then return nil end

	local scriptpath = g_luaFilesystemDirectory .. "/"
	local scriptfile = scriptpath .. script

	RADIOFS = nil
	RADIOFS = {}

	RADIOFS.scriptpath = scriptpath
	RADIOFS.scriptfile = scriptfile

	AddCommonFunctions(RADIOFS)

	StreamRadioLib.LoadSH(scriptfile, true)

	local name = string.Trim(RADIOFS.name or "")
	local type = string.Trim(RADIOFS.type or "")

	RADIOFS.priority = tonumber(RADIOFS.priority or 0) or 0

	if name == "" then
		RADIOFS = nil
		return nil
	end

	if type == "" then
		RADIOFS = nil
		return nil
	end

	if RADIOFS.disabled then
		RADIOFS = nil
		return nil
	end

	local fs = RADIOFS
	RADIOFS = nil

	return fs
end

local function SetupPath(folder1, folder2)
	folder1 = folder1 or ""
	folder2 = folder2 or ""

	if folder1 == "" then return end
	if folder2 == "" then return end

	return folder1 .. "/" .. folder2
end


local function ConvertVirtualFilename(filename)
	filename = filename or ""

	local ext = string.GetExtensionFromFilename(filename) or ""
	if ext == "txt" then
		return filename
	end

	local validext = getFS(ext)
	if not validext then
		return filename
	end

	local noext = string.sub(filename, 0, -(2 + #ext))
	filename = noext .. "_" .. ext .. ".txt"

	return filename
end

local function ConvertGlobalFilename(filename)
	local ext = string.GetExtensionFromFilename(filename) or ""
	if ext ~= "txt" then
		return filename
	end

	local noext = string.StripExtension(filename)

	local vext_tbl = string.Explode("_", noext, false)
	if not vext_tbl then
		return filename
	end

	local vext = vext_tbl[#vext_tbl]
	vext_tbl[#vext_tbl] = nil

	noext = table.concat(vext_tbl, "_")

	local validext = getFS(vext)
	if not validext then
		return filename
	end

	return noext .. "." .. vext
end

local function VirtualPathToGlobal(path, asfolder)
	path = path or ""
	path = SetupPath(g_playlistdir, path) or g_playlistdir

	if not asfolder then
		path = ConvertVirtualFilename(path)
	end

	return path
end

local function SanitizeData(data)
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

		table.insert(tmp, {
			order = tonumber(k or 0) or 0,
			name = name,
			url = url,
		})
	end

	table.SortByMember(tmp, "order", true)

	for i, v in ipairs(tmp) do
		tmp[i].order = nil
	end

	return tmp
end

function LIB.Load()
	local files = file.Find(g_luaFilesystemDirectory .. "/*", "LUA")

	local filesystems = {};

	for _, f in ipairs(files or {}) do
		local fs = loadFilesystem(f)
		if not fs then
			continue
		end

		table.insert(filesystems, fs)
	end

	g_Filesystem = {}
	g_Filesystem.id = {}
	g_Filesystem.type = {}
	g_Filesystem.name = {}

	table.SortByMember(filesystems, "priority", false)

	local index = g_FolderID -- first is folder
	local formats = {}

	for _, fs in ipairs(filesystems) do
		fs.id = index

		local id = fs.id
		local type = fs.type
		local name = fs.name
		local extension = fs.extension or ""

		g_Filesystem.id[id] = fs
		g_Filesystem.type[type] = fs
		g_Filesystem.name[name] = fs

		index = index + 1

		local isDefault = false

		if fs.default and not StreamRadioLib.TYPE_DEFAULT then
			isDefault = true
			StreamRadioLib.TYPE_DEFAULT = id
		end

		if extension ~= "" then
			extension = "*." .. extension

			if isDefault then
				extension = extension .. " (default)"
			end

			table.insert(formats, extension)
		end
	end

	StreamRadioLib.VALID_FORMATS_EXTENSIONS_LIST = table.concat(formats, ", ")
end

function LIB.FilterInvalidFilesnames(filenames)
	if not istable(filenames) then
		filenames = {filenames}
	end

	local results = {}

	for i, filename in ipairs(filenames) do
		if not LIBString.IsValidFilename(filename) then
			continue
		end

		table.insert(results, filename)
	end

	return results
end

function LIB.FilterInvalidFilepaths(filepaths)
	if not istable(filepaths) then
		filepaths = {filepaths}
	end

	local results = {}

	for i, filepath in ipairs(filepaths) do
		if not LIBString.IsValidFilepath(filepath) then
			continue
		end

		table.insert(results, filepath)
	end

	return results
end

function LIB.IsFolder(filetype)
	if not filetype then
		return false
	end

	if filetype == g_FolderID then
		return true
	end

	if filetype == g_VirtualFolderID then
		return true
	end

	filetype = LIB.GetTypeID(filetype)

	if filetype == g_FolderID then
		return true
	end

	if filetype == g_VirtualFolderID then
		return true
	end

	return false
end

function LIB.GetIcon(filetype)
	if not filetype then
		return LIB.GetIcon(g_GenericID)
	end

	if filetype == g_VirtualFolderID then
		return g_VirtualFolderIcon
	end

	local fs = getFS(filetype)

	if not fs then
		if filetype == g_GenericID then
			return nil
		end

		return LIB.GetIcon(g_GenericID)
	end

	if not fs.icon then
		if filetype == g_GenericID then
			return nil
		end

		return LIB.GetIcon(g_GenericID)
	end

	return fs.icon
end

function LIB.GetTypeID(filetype)
	if not filetype then
		return LIB.GetTypeID(g_GenericID)
	end

	if filetype == g_VirtualFolderID then
		return g_VirtualFolderID
	end

	local fs = getFS(filetype)

	if not fs then
		if filetype == g_GenericID then
			return nil
		end

		return LIB.GetTypeID(g_GenericID)
	end

	return fs.id
end

function LIB.GetTypeName(filetype)
	if not filetype then
		return LIB.GetTypeName(g_GenericID)
	end

	if filetype == g_VirtualFolderID then
		return "Virtual Folder"
	end

	local fs = getFS(filetype)

	if not fs then
		if filetype == g_GenericID then
			return nil
		end

		return LIB.GetTypeName(g_GenericID)
	end

	return fs.name
end

function LIB.GetTypeExt(filetype)
	if not filetype then
		return LIB.GetTypeExt(g_GenericID)
	end

	if filetype == g_VirtualFolderID then
		return "Virtual Folder"
	end

	local fs = getFS(filetype)

	if not fs then
		if filetype == g_GenericID then
			return nil
		end

		return LIB.GetTypeExt(g_GenericID)
	end

	return fs.type
end

function LIB.CanLoadToWhitelist(filetype)
	if not filetype then
		return LIB.CanLoadToWhitelist(g_GenericID)
	end

	local fs = getFS(filetype)

	if not fs then
		if filetype == g_GenericID then
			return true
		end

		return LIB.CanLoadToWhitelist(g_GenericID)
	end

	return fs.loadToWhitelist or false
end

function LIB.IsEnabledFilesystem(fsid)
	local fs = getFS(fsid)

	if not fs then
		return false
	end

	return true
end

function LIB.CreateFolder(vpath, callback)
	callback = callback or g_emptyFunction

	if not StreamRadioLib.DataDirectory then
		callback(false)
		return false
	end

	vpath = string.lower(vpath or "")

	if vpath == "" then
		callback(false)
		return false
	end

	if LIBString.IsVirtualPath(vpath) then
		callback(false)
		return false
	end

	if not LIBString.IsValidFilepath(vpath) then
		callback(false)
		return false
	end

	local globalpath = VirtualPathToGlobal(vpath, true)

	if LIB.Exists(vpath, g_FolderID) then
		callback(true)
		return true
	end

	file.CreateDir(globalpath)

	if not LIB.Exists(vpath, g_FolderID) then
		callback(false)
		return false
	end

	callback(true)
	return true
end

function LIB.CanReadFormat(filetype)
	if LIB.IsFolder(filetype) then
		return false
	end

	local fs = getFS(filetype)

	if not fs then
		return false
	end

	if not fs.Read then
		return false
	end

	return true
end

function LIB.CanWriteFormat(filetype)
	if LIB.IsFolder(filetype) then
		return false
	end

	local fs = getFS(filetype)

	if not fs then
		return false
	end

	if not fs.Write then
		return false
	end

	return true
end

function LIB.CanCreateFormat(filetype)
	if LIB.IsFolder(filetype) then
		return false
	end

	if not LIB.CanWriteFormat(filetype) then
		return false
	end

	local fs = getFS(filetype)

	if fs.nocreate then
		return false
	end

	return true
end

function LIB.CanDeleteFormat(filetype)
	if LIB.IsFolder(filetype) then
		if LIBString.IsVirtualPath(vpath) then
			return false
		end

		return true
	end

	local fs = getFS(filetype)

	if not fs then
		return false
	end

	if not fs.Delete then
		return false
	end

	return true
end

function LIB.Read(vpath, filetype, callback)
	callback = callback or g_emptyFunction

	if not StreamRadioLib.DataDirectory then
		callback(false, nil)
		return false
	end

	vpath = string.lower(vpath or "")

	if vpath == "" then
		callback(false, nil)
		return false
	end

	if not LIBString.IsValidFilepath(vpath) then
		callback(false, nil)
		return false
	end

	local globalpath = VirtualPathToGlobal(vpath)

	local fs = getFS(filetype)

	if not fs then
		callback(false, nil)
		return false
	end

	if not fs.Read then
		callback(false, nil)
		return false
	end

	if not fs.Exists then
		callback(false, nil)
		return false
	end

	if not fs:Exists(globalpath, vpath) then
		callback(false, nil)
		return false
	end

	return fs:Read(globalpath, vpath, function(success, data)
		if not success then
			callback(false, nil)
			return
		end

		if not data then
			callback(false, nil)
			return
		end

		data = SanitizeData(data)

		if SERVER then
			local urls = table.MemberValuesFromKey(data, "url")
			StreamRadioLib.Whitelist.UpdateFromPlaylist(vpath, urls)
		end

		callback(success, data)
	end)
end

function LIB.Write(vpath, filetype, data, callback)
	callback = callback or g_emptyFunction

	if not StreamRadioLib.DataDirectory then
		callback(false)
		return false
	end

	vpath = string.lower(vpath or "")

	if vpath == "" then
		callback(false)
		return false
	end

	if not LIBString.IsValidFilepath(vpath) then
		callback(false)
		return false
	end

	if not LIBString.IsValidFilepath(vpath) then
		callback(false)
		return false
	end

	local globalpath = VirtualPathToGlobal(vpath)

	if not data then
		callback(false)
		return false
	end

	data = SanitizeData(data)
	local fs = getFS(filetype)

	if not fs then
		callback(false)
		return false
	end

	if not fs.Write then
		callback(false)
		return false
	end

	return fs:Write(globalpath, vpath, data, function(success, ...)
		if SERVER and success then
			local urls = table.MemberValuesFromKey(data, "url")
			StreamRadioLib.Whitelist.UpdateFromPlaylist(vpath, urls)
			StreamRadioLib.Whitelist.InvalidateCache()
		end

		callback(success, ...)
	end)
end

function LIB.Delete(vpath, filetype, callback)
	callback = callback or g_emptyFunction

	if not StreamRadioLib.DataDirectory then
		callback(false)
		return false
	end

	vpath = string.lower(vpath or "")

	if vpath == "" then
		callback(false)
		return false
	end

	if not LIBString.IsValidFilepath(vpath) then
		callback(false)
		return false
	end

	local globalpath = VirtualPathToGlobal(vpath, LIB.IsFolder(filetype))

	local fs = getFS(filetype)

	if not fs then
		callback(false)
		return false
	end

	if not fs.Delete then
		callback(false)
		return false
	end

	return fs:Delete(globalpath, vpath, function(success, ...)
		if SERVER and success then
			StreamRadioLib.Whitelist.RemoveByPlaylist(vpath)
			StreamRadioLib.Whitelist.InvalidateCache()
		end

		callback(success, ...)
	end)
end

function LIB.Exists(vpath, filetype)
	if not StreamRadioLib.DataDirectory then
		return false
	end

	vpath = string.lower(vpath or "")

	if vpath == "" or vpath == "/" or vpath == "./" then
		return LIB.IsFolder(filetype)
	end

	local globalpath = VirtualPathToGlobal(vpath, LIB.IsFolder(filetype))

	local fs = getFS(filetype)

	if not fs then
		return false
	end

	if not fs.Exists then
		return false
	end

	return fs:Exists(globalpath, vpath)
end

local isvname = LIBString.IsVirtualPath
local lower = string.lower

local function sorter(a, b)
	local a_name = lower(a.file or "")
	local b_name = lower(b.file or "")

	local a_virtual = isvname(a_name)
	local b_virtual = isvname(b_name)

	if a_virtual == b_virtual then
		return a_name < b_name
	end

	if a_virtual then
		return true
	end

	if b_virtual then
		return false
	end

	return a_name < b_name
end

function LIB.Find(vfolder, callback)
	callback = callback or g_emptyFunction

	if not StreamRadioLib.DataDirectory then
		callback(false, nil)
		return false
	end

	vfolder = string.lower(vfolder or "")
	if not LIBString.IsValidFilepath(vfolder) then
		callback(false, nil)
		return false
	end

	local globalpath = SetupPath(g_playlistdir, vfolder) or g_playlistdir

	local wait = {}

	local folderlist = {}
	local filelist = {}
	local nodouble_folder = {}
	local nodouble_files = {}

	for id, fs in ipairs(g_Filesystem.id or {}) do
		if not fs then continue end
		if not getFS(id) then continue end
		if not fs.Find then continue end

		wait[id] = true

		local started = fs:Find(globalpath, vfolder, function(success, files, folders)
			files = files or {}
			folders = folders or {}

			wait[id] = nil

			for i, name in ipairs(folders) do
				local filepath = SetupPath(vfolder, name) or name
				if nodouble_folder[filepath] then continue end

				local typeid = vfolder == "" and g_VirtualFolderID or g_FolderID

				if id == g_FolderID then
					typeid = g_FolderID
				end

				local item = {
					isfolder = true,
					type = typeid,
					fsid = id,
					file = name,
					path = filepath,
				}

				table.insert(folderlist, item)

				nodouble_folder[filepath] = true
			end

			for i, name in ipairs(files) do
				local name = ConvertGlobalFilename(name)

				local filepath = SetupPath(vfolder, name) or name

				if nodouble_files[filepath] then continue end

				local item = {
					isfolder = false,
					type = id,
					fsid = id,
					file = name,
					path = filepath,
				}

				table.insert(filelist, item)

				nodouble_files[filepath] = true
			end
		end)

		if not started then
			wait[id] = nil
		end
	end

	local callcallback = function()
		table.sort(folderlist, sorter)
		table.sort(filelist, sorter)

		local outlist = {}
		table.Add(outlist, folderlist)
		table.Add(outlist, filelist)

		callback(true, outlist)
	end

	StreamRadioLib.Timer.Until("Filesystem_Find_" .. tostring({}), 0.2, function()
		local done = table.IsEmpty(wait)

		if not done then
			return false
		end

		callcallback()
		return true
	end)

	return true
end

function LIB.GuessType(vpath)
	if not StreamRadioLib.DataDirectory then return nil end

	vpath = string.lower(vpath or "")
	if vpath == "" then
		return nil
	end

	if not LIBString.IsValidFilepath(vpath) then
		return nil
	end

	local globalpath = VirtualPathToGlobal(vpath)

	for id, fs in ipairs(g_Filesystem.id or {}) do
		if not fs then continue end
		if not getFS(id) then continue end
		if not fs.IsType then continue end
		if not fs:IsType(globalpath, vpath) then continue end

		return id
	end

	return nil
end

do
	local function ListFS()
		MsgN("List of loaded filesystem")

		local lineFormat = "%5s | %25s | %10s | %7s"
		local topLine = string.format(lineFormat, "ID", "Name", "Type", "Active")

		MsgN(string.format(lineFormat, "ID", "Name", "Type", "Active"))
		MsgN(string.rep("-", #topLine))

		for id, fs in ipairs(g_Filesystem.id or {}) do
			if not fs then continue end
			if fs.id == g_GenericID then continue end
			if fs.type == g_GenericID then continue end


			local isActive = getFS(id) ~= nil
			local line = string.format(lineFormat, fs.id, fs.name, fs.type, isActive and "yes" or "no")

			MsgN(line)
		end
	end

	concommand.Add( "info_streamradio_playlist_filesystem_list", ListFS)
end

local function updateBlacklistFromString(backlist)
	backlist = tostring(backlist or "")
	backlist = string.Explode("[%,%;%|]", backlist, true)

	g_FilesystemBlacklist = {}

	for i, v in ipairs(backlist) do
		v = string.Trim(v)
		g_FilesystemBlacklist[v] = true
	end
end

local flags = bit.bor(FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE)

if SERVER then
	flags = bit.bor(flags, FCVAR_ARCHIVE)
end

local CVBacklist = CreateConVar( "sv_streamradio_playlist_filesystem_blacklist", "", flags, "Set the list playlist filesystems to be disabled by type, name or id. Entries are seperated by pipe ('|') or comma (','). See info_streamradio_playlist_filesystem_list for details. Default: ''" )

local oldCVValue = CVBacklist:GetString()
updateBlacklistFromString(oldCVValue)

StreamRadioLib.Hook.Add("Think", "Playlist_Filesystem", function()
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end
	if not CVBacklist then return end

	local CVvalue = CVBacklist:GetString()
	if oldCVValue == CVvalue then
		return
	end

	oldCVValue = CVvalue
	updateBlacklistFromString(CVvalue)
end)

return true

