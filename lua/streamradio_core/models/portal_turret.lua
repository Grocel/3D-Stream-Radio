local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- Portal 1 Turret
RADIOMDL.model = "models/props/turret_01.mdl"

RADIOMDL.NoDisplay = true
RADIOMDL.SpawnAng = Angle( 0, 0, 0 )
RADIOMDL.SpawnFlatOnWall = false
RADIOMDL.SoundPosOffset = Vector( 5, 0, 37 )
RADIOMDL.SoundAngOffset = Angle( 0, 0, 0 )

RADIOMDL.WingCloseTime = 0.371
RADIOMDL.WingOpenTime = 0.319
RADIOMDL.WingSpan = 8

RADIOMDL.WingCloseSound = "NPC_FloorTurret.Retire"
RADIOMDL.WingOpenSound = "NPC_FloorTurret.Deploy"
RADIOMDL.WingSpawnSound = "NPC_FloorTurret.TalkActive"

function RADIOMDL:Initialize(ent)
	if SERVER then return end

	ent:EmitSound(self.WingSpawnSound)

	self.RightWingDir = 1
	self.LeftWingDir = 1

	self.RightSwapTime = CurTime()
	self.LeftSwapTime = CurTime()

	self.WingOpened = false
	self.WingClosed = true
	self.PixVis = util.GetPixelVisibleHandle()
	self.EyeColor = Color(0, 128, 255)
	self.EyeColorDyn = Color(64, 0, 0)
	self.EyeColorLoading = Color(255, 255, 0)
	self.EyeColorError = Color(255, 128, 0)

	self._State = 0

	self:CloseWings(true)
end

function RADIOMDL:AnimReset(ent)
	if SERVER then return end

	self.RightWingDir = 1
	self.LeftWingDir = 1

	self.RightSwapTime = CurTime()
	self.LeftSwapTime = CurTime()

	self.EyeColor = Color(0, 128, 255)

	self:CloseWings(true)
end

function RADIOMDL:OnSearch(ent, stream)
	if SERVER then return end

	self.EyeColor = self.EyeColorLoading
	self:CloseWings()
end

function RADIOMDL:WhileLoading(ent)
	if SERVER then return end

	self.EyeColor = self.EyeColorLoading
	self:CloseWings()
end

function RADIOMDL:WhileError(ent)
	if SERVER then return end

	self.EyeColor = self.EyeColorError
	self:CloseWings()
end

function RADIOMDL:OnPlay(ent, stream)
	if SERVER then return end

	self.RightWingDir = 1
	self.LeftWingDir = 1

	self.RightSwapTime = CurTime()
	self.LeftSwapTime = CurTime()

	self.EyeColor = self.EyeColorDyn
	self:OpenWings()
end

function RADIOMDL:OnError(ent, stream)
	if SERVER then return end

	self.RightWingDir = 1
	self.LeftWingDir = 1

	self.RightSwapTime = CurTime()
	self.LeftSwapTime = CurTime()

	self.EyeColor = self.EyeColorError

	self:CloseWings()
end

function RADIOMDL:OnStop(ent, stream)
	if SERVER then return end

	self.RightWingDir = 1
	self.LeftWingDir = 1

	self.RightSwapTime = CurTime()
	self.LeftSwapTime = CurTime()

	self.EyeColor = Color(0, 128, 255)

	self:CloseWings()
	self._State = 10
end

function RADIOMDL:_StateCloseWings(ent)
	local RightWing = ent:LookupBone( "RT_Wing" ) or 0
	local LeftWing = ent:LookupBone( "LFT_Wing" ) or 0

	local RPos = math.Clamp(self.RightWing or 0, 0, 1)
	local LPos = math.Clamp(self.LeftWing or 0, 0, 1)

	if RPos <= 0 and LPos <= 0 then
		self.WingOpened = false
		self.WingClosed = true
		self._State = 0
		return true
	end

	ent:ManipulateBonePosition( RightWing, Vector( RPos * self.WingSpan, 0, 0 ) )
	ent:ManipulateBonePosition( LeftWing, Vector( -LPos * self.WingSpan, 0, 0 ) )

	self.RightWing = math.max(RPos - self.LastTickTime / self.WingCloseTime, 0)
	self.LeftWing = math.max(LPos - self.LastTickTime / self.WingCloseTime, 0)
end

function RADIOMDL:_StateOpenWings(ent)
	local RightWing = ent:LookupBone( "RT_Wing" ) or 0
	local LeftWing = ent:LookupBone( "LFT_Wing" ) or 0

	local RPos = math.Clamp(self.RightWing or 0, 0, 0.5)
	local LPos = math.Clamp(self.LeftWing or 0, 0, 0.5)

	if RPos >= 0.5 and LPos >= 0.5 then
		self.WingClosed = false
		self.WingOpened = true
		self._State = 0
		return true
	end

	ent:ManipulateBonePosition( RightWing, Vector( RPos * self.WingSpan, 0, 0 ) )
	ent:ManipulateBonePosition( LeftWing, Vector( -LPos * self.WingSpan, 0, 0 ) )

	self.RightWing = math.min(RPos + self.LastTickTime / self.WingOpenTime / 2, 0.5)
	self.LeftWing = math.min(LPos + self.LastTickTime / self.WingOpenTime / 2, 0.5)
end

function RADIOMDL:Think(ent)
	local now = CurTime()

	self.LastTickTime = now - (self.LastTick or now)
	self.LastTick = now

	if self._State == 10 then
		ent:EmitSound(self.WingCloseSound)
		self._State = 1
	end

	if self._State == 1 then
		self:_StateCloseWings(ent)
		return
	end

	if self._State == 20 then
		ent:EmitSound(self.WingOpenSound)
		self._State = 2
	end

	if self._State == 2 then
		self:_StateOpenWings(ent)
		return
	end
end

local g_mat_glow = Material("sprites/light_glow02_add_noz")
local g_mat_bg = Material("debug/debugvertexcolor")
local g_mat_bg2 = Material("sprites/light_glow02_add")
local g_glow_pos = Vector(12.5, 0, 36.75)

function RADIOMDL:Draw(ent)
	local glowpos = ent:LocalToWorld(g_glow_pos)
	local offset = 3

	local quadpos1 = ent:LocalToWorld(g_glow_pos + Vector(-0.30,  offset,  offset))
	local quadpos2 = ent:LocalToWorld(g_glow_pos + Vector(-0.30,  offset, -offset))
	local quadpos3 = ent:LocalToWorld(g_glow_pos + Vector(-0.30, -offset, -offset))
	local quadpos4 = ent:LocalToWorld(g_glow_pos + Vector(-0.30, -offset,  offset))

	render.SetMaterial(g_mat_bg)
	render.DrawQuad(
		quadpos1,
		quadpos2,
		quadpos3,
		quadpos4,
		color_black
	)

	render.SetMaterial(g_mat_bg2)
	render.DrawQuad(
		quadpos1,
		quadpos2,
		quadpos3,
		quadpos4,
		Color(self.EyeColor.r > 0 and 255 or 0, self.EyeColor.g, self.EyeColor.b)
	)

	local Visibile = util.PixelVisible(glowpos, 3, self.PixVis)

	if not Visibile then return end
	if Visibile < 0.50 then return end

	render.SetMaterial(g_mat_glow)
	render.DrawSprite(glowpos, 8, 8, self.EyeColor)
end

function RADIOMDL:CloseWings(nosound)
	if self._State == 1 then
		return
	end

	if self._State == 10 then
		return
	end

	if self.WingClosed then
		return
	end

	self.WingOpened = false
	self.WingClosed = false

	self._State = nosound and 1 or 10
end

function RADIOMDL:OpenWings(nosound)
	if self._State == 2 then
		return
	end

	if self._State == 20 then
		return
	end

	if self.WingOpened then
		return
	end

	self.WingClosed = false
	self.WingOpened = false

	self._State = nosound and 2 or 20
end

RADIOMDL.SpeakerMinFRQ = 20
RADIOMDL.SpeakerMaxFRQ = 3000
RADIOMDL.SpeakerFRQResolution = 12

function RADIOMDL:Speaker(ent, speakerlevel)
	if SERVER then return end

	local now = CurTime()
	self.SL_LastTickTime = now - (self.SL_LastTick or now)
	self.SL_LastTick = now

	if not speakerlevel then
		self:CloseWings(true)
		return
	end

	if not self.WingOpened then
		self:OpenWings(true)
		return
	end

	self.EyeColor = self.EyeColorDyn

	speakerlevel = speakerlevel ^ 2
	speakerlevel = math.Clamp(speakerlevel * 35, 0, 1)

	local RightSwapTime = self.RightSwapTime or 0
	local LeftSwapTime = self.LeftSwapTime or 0
	local SwappedTime = self.SwappedTime or 0

	if speakerlevel >= 0.85 then
		if not self.Swapped then
			if (now - RightSwapTime) > 0.25 then
				self.RightWingDir = ( self.RightWingDir or 1 ) * -1
				self.RightSwapTime = now
				self.Swapped = true
			end
		end

		if not self.Swapped then
			if (now - LeftSwapTime) > 0.25 then
				self.LeftWingDir = ( self.LeftWingDir or 1 ) * -1
				self.LeftSwapTime = now
				self.Swapped = true
			end
		end
	else
		if self.Swapped then
			if (now - SwappedTime) > 0.25 then
				self.SwappedTime = now
				self.Swapped = false
			end
		end
	end

	local RightWing = ent:LookupBone( "RT_Wing" ) or 0
	local LeftWing = ent:LookupBone( "LFT_Wing" ) or 0

	local RPos = math.Clamp(self.RightWing or 0, 0.25, 1)
	local LPos = math.Clamp(self.LeftWing or 0, 0.25, 1)

	ent:ManipulateBonePosition( RightWing, Vector( RPos * self.WingSpan, 0, 0 ) )
	ent:ManipulateBonePosition( LeftWing, Vector( -LPos * self.WingSpan, 0, 0 ) )

	local movelevel = speakerlevel * self.SL_LastTickTime * 3

	self.RightWing = RPos + (self.RightWingDir or 1) * movelevel
	self.LeftWing = LPos + (self.LeftWingDir or 1) * movelevel

	if self.RightWing >= 1 then
		self.RightWingDir = -1
	end

	if self.RightWing <= 0.25 then
		self.RightWingDir = 1
	end

	if self.LeftWing >= 1 then
		self.LeftWingDir = -1
	end

	if self.LeftWing <= 0.25 then
		self.LeftWingDir = 1
	end
end

function RADIOMDL:SoundLevel(ent, soundlevel)
	if SERVER then return end

	soundlevel = soundlevel or 0
	if soundlevel <= 0 then
		soundlevel = 0
	else
		soundlevel = soundlevel * 100000
		soundlevel = math.log10(soundlevel) / 5
		soundlevel = soundlevel ^ 20 * 1.1
	end

	soundlevel = math.Clamp( soundlevel, 0, 1 )

	self.EyeColorDyn.b = 0
	self.EyeColorDyn.g = 0
	self.EyeColorDyn.r = math.floor(31 + 224 * soundlevel)
end

return true

