local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- Wire Speaker 3
-- Addon: https://steamcommunity.com/sharedfiles/filedetails/?id=160250458
RADIOMDL.model = "models/killa-x/speakers/speaker_small.mdl"

RADIOMDL.NoDisplay = true
RADIOMDL.SpawnAng = Angle( 0, 0, 0 )
RADIOMDL.SpawnFlatOnWall = false

return true

