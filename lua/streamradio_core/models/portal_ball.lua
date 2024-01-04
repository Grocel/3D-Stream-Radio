local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- Portal 1 Ball
RADIOMDL.model = "models/props/sphere.mdl"

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

	local skinid = math.Round(soundlevel * 9)
	ent:SetSkin( skinid )
end

return true

