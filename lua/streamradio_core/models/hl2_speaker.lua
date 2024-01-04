local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- HL2 Industrial Speaker
RADIOMDL.model = "models/props_wasteland/speakercluster01a.mdl"

RADIOMDL.NoDisplay = true
RADIOMDL.SpawnAng = Angle( -90, 0, 0 )
RADIOMDL.SpawnFlatOnWall = false
RADIOMDL.SpawnAtOrigin = false

return true

