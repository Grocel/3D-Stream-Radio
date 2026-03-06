local RADIOMDL = RADIOMDL
if not istable(RADIOMDL) then
	StreamRadioLib.ReloadAddon()
	return
end

-- Default, Failback, No Display
RADIOMDL.model = "default"

RADIOMDL.NoDisplay = true
RADIOMDL.SpawnAng = Angle( 0, 0, 0 )
RADIOMDL.SpawnFlatOnWall = false
RADIOMDL.HiddenInTool = true

return true

