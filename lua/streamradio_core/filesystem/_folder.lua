local RADIOFS = RADIOFS
if not istable( RADIOFS ) then
	StreamRadioLib.Filesystem.Load()
	return
end

RADIOFS.name = "Folder"
RADIOFS.type = "folder"
RADIOFS.icon = StreamRadioLib.GetPNGIcon("Folder")
RADIOFS.nocreate = true

RADIOFS.loadToWhitelist = true
RADIOFS.priority = 999999

function RADIOFS:IsType(globalpath, vpath)
	if file.Exists(globalpath, "GAME") then
		return true
	end

	if file.IsDir(globalpath, "GAME") then
		return true
	end

	return false
end

function RADIOFS:Find(globalpath, vfolder, callback)
	if not file.Exists(globalpath, "DATA") then
		callback(false, nil, nil)
		return false
	end

	if not file.IsDir(globalpath, "DATA") then
		callback(false, nil, nil)
		return false
	end

	local _, folders = file.Find(globalpath .. "/*", "DATA", "nameasc")
	folders = StreamRadioLib.Filesystem.FilterInvalidFilepaths(folders)

	callback(true, nil, folders)
	return true
end

function RADIOFS:Exists(globalpath, vpath)
	if not file.Exists(globalpath, "DATA") then
		return false
	end

	if not file.IsDir(globalpath, "DATA") then
		return false
	end

	return true
end

function RADIOFS:Delete(globalpath, vpath, callback)
	local deleted = StreamRadioLib.Util.DeleteFolder(globalpath)
	callback(deleted)

	return deleted
end

RADIOFS.Read = nil

return true

