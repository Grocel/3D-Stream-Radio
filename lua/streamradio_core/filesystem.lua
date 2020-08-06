StreamRadioLib.Filesystem = StreamRadioLib.Filesystem or {}
local LIB = StreamRadioLib.Filesystem

local g_playlistdir = ( StreamRadioLib.DataDirectory or "" ) .. "/playlists"
local LuaFilesystemDirectory = "streamradio_core/filesystem"
local Filesystem = {}
local FilesystemBlacklist = {}

local g_FolderID = 0
local g_VirtualFolderID = 250
local g_GenericID = ":generic"

local g_FolderIcon = StreamRadioLib.GetPNGIcon("folder")
local g_VirtualFolderIcon = StreamRadioLib.GetPNGIcon("folder_link")

StreamRadioLib.TYPE_FOLDER = g_FolderID
StreamRadioLib.TYPE_DEFAULT = nil

local function getFS(id)
	if not Filesystem then return nil end
	if not Filesystem.id then return nil end
	if not Filesystem.type then return nil end

	if not id then return nil end

	local fs = Filesystem.id[id] or Filesystem.type[id] or Filesystem.name[id]
	if not fs then return nil end

	if fs.type ~= g_GenericID then
		if FilesystemBlacklist[fs.id] then return nil end
		if FilesystemBlacklist[fs.type] then return nil end
		if FilesystemBlacklist[fs.name] then return nil end
	end

	if isfunction(fs.IsInstalled) and not fs:IsInstalled() then
		return nil
	end

	return fs
end

local function DeleteFolder(globalpath)
	globalpath = globalpath or ""

	globalpath = string.Trim(globalpath, "/")
	globalpath = string.Trim(globalpath, "\\")
	globalpath = string.Trim(globalpath, "/")
	globalpath = string.Trim(globalpath, "\\")

	if globalpath == "" then return end

	local files, folders = file.Find(globalpath .. "/*", "DATA")

	for k, v in pairs(folders or {}) do
		DeleteFolder(globalpath .. "/" .. v)
	end

	for k, v in pairs(files or {}) do
		file.Delete(globalpath .. "/" .. v)
	end

	file.Delete(globalpath)

	if file.Exists(globalpath, "DATA") then
		return false
	end

	if file.IsDir(globalpath, "DATA") then
		return false
	end

	return true
end

local function AddCommonFunctions(fs)
	if not fs then return end

	function fs:Find(globalpath, vfolder)
		local files = file.Find(globalpath .. "/*_" .. self.type .. ".txt", "DATA", "nameasc")
		return files
	end

	function fs:Delete(globalpath, vpath, callback)
		file.Delete(globalpath)
		local deleted = not file.Exists(globalpath, "DATA")
		callback(deleted)

		return deleted
	end

	function fs:Exists(globalpath, vpath)
		local exists = file.Exists(globalpath, "DATA")
		return exists
	end

	function fs:CreateDirForFile(globalpath)
		local folder = string.GetPathFromFilename(globalpath) or ""
		if folder == "" then return true end

		if not file.IsDir(folder, "DATA") then
			file.CreateDir(folder)
		end

		return file.IsDir(folder, "DATA")
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

	function fs:GetPathLevels(vfolder)
		local levels = string.Explode("[%/%\\]", vfolder, true) or {}
		local out = {}

		for i, v in ipairs(levels) do
			v = string.Trim(v, "/")
			v = string.Trim(v, "\\")
			v = string.Trim(v, "/")
			v = string.Trim(v, "\\")

			if v == "" then continue end
			out[#out + 1] = v
		end

		return out
	end
end

local function AddFileFormat(script)
	script = script or ""
	if script == "" then return false end

	if not Filesystem then return false end
	if not Filesystem.id then return false end
	if not Filesystem.type then return false end
	if not Filesystem.name then return false end

	local scriptpath = LuaFilesystemDirectory .. "/"
	local scriptfile = scriptpath .. script

	if not file.Exists(scriptfile, "LUA") then return false end

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
		return false
	end

	if type == "" then
		RADIOFS = nil
		return false
	end

	if RADIOFS.disabled then
		RADIOFS = nil
		return false
	end

	local fs = RADIOFS

	Filesystem.id[#Filesystem.id + 1] = fs
	Filesystem.type[type] = fs
	Filesystem.name[name] = fs

	RADIOFS = nil
	return true
end

local function IsValidFile(File)
	return not file.IsDir(File, "DATA") and file.Exists(File, "DATA")
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

	if noext == "" then
		return filename
	end

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

function LIB.Load()
	local files = file.Find(LuaFilesystemDirectory .. "/*", "LUA")

	Filesystem = {}
	Filesystem.id = {}
	Filesystem.type = {}
	Filesystem.name = {}

	for _, f in pairs(files or {}) do
		AddFileFormat(f)
	end

	table.SortByMember(Filesystem.id, "priority", false)

	for id, fs in pairs(Filesystem.id) do
		fs.id = id

		if not fs.default then
			continue
		end

		if StreamRadioLib.TYPE_DEFAULT then
			continue
		end

		StreamRadioLib.TYPE_DEFAULT = id
	end

	collectgarbage("collect")
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

	return false
end

function LIB.GetIcon(filetype)
	if SERVER then return nil end

	if not filetype then
		return LIB.GetIcon(g_GenericID)
	end

	if filetype == g_FolderID then
		return g_FolderIcon
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
	if SERVER then return nil end

	if not filetype then
		return LIB.GetTypeID(g_GenericID)
	end

	if filetype == g_FolderID then
		return g_FolderID
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

	if not fs.icon then
		if filetype == g_GenericID then
			return nil
		end

		return LIB.GetTypeID(g_GenericID)
	end

	return fs.id
end

function LIB.GetTypeName(filetype)
	if SERVER then return nil end

	if not filetype then
		return LIB.GetTypeName(g_GenericID)
	end

	if filetype == g_FolderID then
		return "Folder"
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

	if not fs.icon then
		if filetype == g_GenericID then
			return nil
		end

		return LIB.GetTypeName(g_GenericID)
	end

	return fs.name
end

function LIB.GetTypeExt(filetype)
	if SERVER then return nil end

	if not filetype then
		return LIB.GetTypeExt(g_GenericID)
	end

	if filetype == g_FolderID then
		return "Folder"
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

	if not fs.icon then
		if filetype == g_GenericID then
			return nil
		end

		return LIB.GetTypeExt(g_GenericID)
	end

	return fs.type
end

function LIB.IsVirtualPath(vpath)
	vpath = vpath or ""

	if vpath == "" then
		return false
	end

	if not string.match(vpath, "^%:") then
		return false
	end

	return true
end

function LIB.CreateFolder(vpath, callback)
	callback = callback or (function() end)

	if not StreamRadioLib.DataDirectory then
		callback(false)
		return false
	end

	vpath = string.lower(vpath or "")

	if vpath == "" then
		callback(false)
		return false
	end

	if LIB.IsVirtualPath(vpath) then
		callback(false)
		return false
	end

	local globalpath = VirtualPathToGlobal(vpath, true)
	file.CreateDir(globalpath)

	local exists = LIB.Exists(vpath, g_FolderID)

	callback(exists)
	return exists
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
		if LIB.IsVirtualPath(vpath) then
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
	callback = callback or (function() end)

	if not StreamRadioLib.DataDirectory then
		callback(false, nil)
		return false
	end

	vpath = string.lower(vpath or "")

	if vpath == "" then
		callback(false, nil)
		return false
	end

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

	local globalpath = VirtualPathToGlobal(vpath)

	if not fs:Exists(globalpath, vpath) then
		callback(false, nil)
		return false
	end

	return fs:Read(globalpath, vpath, function(suggess, data)
		if not suggess then
			callback(false, nil)
			return
		end

		if not data then
			callback(false, nil)
			return
		end

		data = SanitizeData(data)
		callback(suggess, data)
	end)
end

function LIB.Write(vpath, filetype, data, callback)
	callback = callback or (function() end)

	if not StreamRadioLib.DataDirectory then
		callback(false)
		return false
	end

	vpath = string.lower(vpath or "")

	if vpath == "" then
		callback(false)
		return false
	end

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

	local globalpath = VirtualPathToGlobal(vpath)
	return fs:Write(globalpath, vpath, data, callback)
end

function LIB.Delete(vpath, filetype, callback)
	callback = callback or (function() end)

	if not StreamRadioLib.DataDirectory then
		callback(false)
		return false
	end

	vpath = string.lower(vpath or "")

	if vpath == "" then
		callback(false)
		return false
	end

	local globalpath = VirtualPathToGlobal(vpath)
	if LIB.IsFolder(filetype) then
		globalpath = VirtualPathToGlobal(vpath, true)

		if LIB.IsVirtualPath(vpath) then
			callback(false)
			return false
		end

		local deleted = DeleteFolder(globalpath)
		callback(deleted)

		return deleted
	end

	local fs = getFS(filetype)

	if not fs then
		callback(false)
		return false
	end

	if not fs.Delete then
		callback(false)
		return false
	end

	return fs:Delete(globalpath, vpath, callback)
end

function LIB.Exists(vpath, filetype)
	if not StreamRadioLib.DataDirectory then
		return false
	end

	vpath = string.lower(vpath or "")

	if vpath == "" then
		return false
	end

	local globalpath = VirtualPathToGlobal(vpath)
	if LIB.IsFolder(filetype) then
		globalpath = VirtualPathToGlobal(vpath, true)
		local exists = file.IsDir(globalpath, "DATA")
		if exists then
			return true
		end

		if LIB.IsVirtualPath(vpath) then
			return true
		end

		return false
	end

	local fs = getFS(filetype)

	if not fs then
		return false
	end

	if not fs.Exists then
		return false
	end

	return fs:Exists(globalpath, vpath)
end

local isvname = LIB.IsVirtualPath
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

function LIB.Find(vfolder)
	if not StreamRadioLib.DataDirectory then return nil end

	vfolder = string.lower(vfolder or "")

	local globalpath = SetupPath(g_playlistdir, vfolder) or g_playlistdir
	local _, folders = file.Find(globalpath .. "/*", "DATA", "nameasc")

	local filelist = {}
	local folderlist = {}

	local nodouble_files = {}
	local nodouble_folder = {}

	for i, name in ipairs(folders or {}) do
		local filepath = SetupPath(vfolder, name) or name
		if nodouble_folder[filepath] then continue end

		folderlist[#folderlist + 1] = {
			isfolder = true,
			type = g_FolderID,
			file = name,
			path = filepath,
		}

		nodouble_folder[filepath] = true
	end

	for id, fs in ipairs(Filesystem.id) do
		if not fs then continue end
		if not getFS(id) then continue end
		if not fs.Find then continue end

		local files, folders = fs:Find(globalpath, vfolder)

		files = files or {}
		folders = folders or {}

		for i, name in ipairs(folders) do
			local filepath = SetupPath(vfolder, name) or name
			if nodouble_folder[filepath] then continue end

			folderlist[#folderlist + 1] = {
				isfolder = true,
				type = vfolder == "" and g_VirtualFolderID or g_FolderID,
				file = name,
				path = filepath,
			}

			nodouble_folder[filepath] = true
		end

		for i, name in ipairs(files) do
			local name = ConvertGlobalFilename(name)
			local filepath = SetupPath(vfolder, name) or name

			if nodouble_files[filepath] then continue end

			filelist[#filelist + 1] = {
				isfolder = false,
				type = id,
				file = name,
				path = filepath,
			}

			nodouble_files[filepath] = true
		end
	end

	table.sort(folderlist, sorter)
	table.sort(filelist, sorter)

	local outlist = {}
	table.Add(outlist, folderlist)
	table.Add(outlist, filelist)

	return outlist
end

function LIB.GuessType(vpath)
	if not StreamRadioLib.DataDirectory then return nil end

	vpath = string.lower(vpath or "")
	if vpath == "" then
		return nil
	end

	local globalpath = VirtualPathToGlobal(vpath)
	for id, fs in ipairs(Filesystem.id) do
		if not fs then continue end
		if not getFS(id) then continue end
		if not fs.IsType then continue end
		if not fs:IsType(globalpath, vpath) then continue end

		return id
	end

	return nil
end

local function ListFS()
	MsgN("List of loaded filesystem")

	local lineFormat = "%5s | %25s | %10s | %7s"
	local topLine = string.format(lineFormat, "ID", "Name", "Type", "Active")

	MsgN(string.format(lineFormat, "ID", "Name", "Type", "Active"))
	MsgN(string.rep("-", #topLine))

	for id, fs in ipairs(Filesystem.id) do
		if not fs then continue end
		if fs.type == g_GenericID then continue end

		local isActive = getFS(id) ~= nil
		local line = string.format(lineFormat, fs.id, fs.name, fs.type, isActive and "yes" or "no")

		MsgN(line)
	end
end

concommand.Add( "info_streamradio_playlist_filesystem_list", ListFS)

local function updateBlacklistFromString(backlist)
	backlist = tostring(backlist or "")
	backlist = string.Explode("[%,%;%|]", backlist, true)

	FilesystemBlacklist = {}

	for i, v in ipairs(backlist) do
		v = string.Trim(v)
		FilesystemBlacklist[v] = true
	end
end

local flags = bit.bor(FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE)

if SERVER then
	flags = bit.bor(flags, FCVAR_ARCHIVE)
end

local CVBacklist = CreateConVar( "sv_streamradio_playlist_filesystem_blacklist", "", flags, "Set the list playlist filesystems to be disabled by type, name or id. Entries are seperated by pipe ('|') or comma (','). See info_streamradio_playlist_filesystem_list for details. Default: ''" )

local oldCVValue = CVBacklist:GetString()
updateBlacklistFromString(oldCVValue)

hook.Add("Think", "Streamradio_Playlist_Filesystem_Think", function()
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

LIB.Load()
