local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- Minecraft Noteblock
RADIOMDL.model = "models/mcmodelpack/blocks/noteblock.mdl"

RADIOMDL.NoDisplay = true
RADIOMDL.SpawnAng = Angle( 0, 0, 0 )
RADIOMDL.FlatOnWall = false
RADIOMDL.SoundPosOffset = Vector( 0, 0, 18 )
RADIOMDL.SoundAngOffset = Angle( 0, 0, 0 )

