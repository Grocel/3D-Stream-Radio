local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- Minecraft Noteblock
-- Addon: https://steamcommunity.com/sharedfiles/filedetails/?id=116592647
RADIOMDL.model = "models/mcmodelpack/blocks/noteblock.mdl"

RADIOMDL.NoDisplay = true
RADIOMDL.SpawnAng = Angle( 0, 0, 0 )
RADIOMDL.SpawnFlatOnWall = false
RADIOMDL.SoundPosOffset = Vector( 0, 0, 18 )
RADIOMDL.SoundAngOffset = Angle( 0, 0, 0 )

return true

