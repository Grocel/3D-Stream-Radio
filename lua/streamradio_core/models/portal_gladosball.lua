local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- Portal 1 GlaDOS Ball
RADIOMDL.model = "models/props_bts/glados_ball_reference.mdl"

local skins = {0,  1,  3,  2}

RADIOMDL.NoDisplay = true
RADIOMDL.SpawnAng = Angle( 0, 0, 0 )
RADIOMDL.SpawnFlatOnWall = false

function RADIOMDL:SoundLevel(ent, soundlevel)
	if SERVER then return end

	soundlevel = soundlevel or 0
	if soundlevel <= 0 then
		ent:SetSkin(0)
		return
	end

	local vol = ent:GetVolume()

	soundlevel = soundlevel * 100000
	soundlevel = math.log10(soundlevel) / 5
	soundlevel = soundlevel ^ 20 * 1.1
	soundlevel = soundlevel * vol

	soundlevel = math.Clamp(soundlevel, 0, 1)

	local skinid = skins[math.Round(soundlevel * 3) + 1] or 0
	ent:SetSkin( skinid )
end

return true

