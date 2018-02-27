local RADIOFS = RADIOFS
if not istable( RADIOFS ) then
	StreamRadioLib.Filesystem.Load()
	return
end

RADIOFS.name = "generic"
RADIOFS.type = ":generic"
RADIOFS.icon = StreamRadioLib.GetPNGIcon("page")

RADIOFS.priority = -1

function RADIOFS:Find(globalpath, vfolder)
	return nil
end

function RADIOFS:Delete(globalpath, vpath, callback)
	return false
end

function RADIOFS:Exists(globalpath, vpath)
	return false
end
