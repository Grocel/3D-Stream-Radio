local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- All NM Speakers
-- Addon: https://steamcommunity.com/sharedfiles/filedetails/?id=605223544
RADIOMDL.NoDisplay = true
RADIOMDL.SpawnAng = Angle( 0, 0, 90 )
RADIOMDL.SpawnFlatOnWall = false
RADIOMDL.SpawnAtOrigin = false

local SpeakerSize = string.StripExtension(RADIOMDL.modelname or "")
SpeakerSize = string.Explode("_", SpeakerSize, false) or {}
SpeakerSize = tonumber(SpeakerSize[#SpeakerSize]) or 12

RADIOMDL.SpeakerMinFRQ = 20
RADIOMDL.SpeakerMaxFRQ = 2000
RADIOMDL.SpeakerFRQResolution = 12

function RADIOMDL:Speaker(ent, speakerlevel)
	if SERVER then return end

	local Speaker = ent:LookupBone( "SpeakerMorph" ) or 0

	if Speaker == 0 then
		Speaker = ent:LookupBone( "Morph" ) or 0
	end
	if Speaker == 0 then return end

	speakerlevel = speakerlevel or 0

	local soundlevel = 0

	if IsValid(ent.StreamObj) then
		soundlevel = ent.StreamObj:GetAverageLevel() ^ 0.25
	end

	local vol = ent:GetVolume()

	speakerlevel = speakerlevel * vol * 1.5 * soundlevel
	speakerlevel = math.Clamp(speakerlevel, -1, 1)

	ent:ManipulateBonePosition( Speaker, Vector( 0, speakerlevel * (SpeakerSize / 36), 0 ) )
end

return true

