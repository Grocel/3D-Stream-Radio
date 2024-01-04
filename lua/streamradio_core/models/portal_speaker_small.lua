local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- Portal 2 Old Speaker, Small
RADIOMDL.model = "models/props_underground/old_speaker.mdl"

RADIOMDL.NoDisplay = true
RADIOMDL.SpawnAng = Angle( -90, 0, 0 )
RADIOMDL.SpawnFlatOnWall = false
RADIOMDL.SpawnAtOrigin = true
RADIOMDL.SoundPosOffset = Vector( 10.5, 0, -1.9 )
RADIOMDL.SoundAngOffset = Angle( 22.5, 0, 0 )

return true

