TOOL.Category = "Stream Radio"
TOOL.Name = "#Tool." .. TOOL.Mode .. ".name"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
}

if SERVER then
	CreateConVar( "sbox_max" .. TOOL.Mode, 5 )
end

cleanup.Register( TOOL.Mode )

TOOL.ClientConVar["model"] = "models/sligwolf/grocel/radio/radio.mdl"
TOOL.ClientConVar["streamurl"] = ""
TOOL.ClientConVar["play"] = "1"
TOOL.ClientConVar["3dsound"] = "1"
TOOL.ClientConVar["mute"] = "0"
TOOL.ClientConVar["volume"] = "1"
TOOL.ClientConVar["radius"] = "1200"
TOOL.ClientConVar["playbackloopmode"] = "0"

TOOL.ClientConVar["nodisplay"] = "0"
TOOL.ClientConVar["noinput"] = "0"
TOOL.ClientConVar["nospectrum"] = "0"
TOOL.ClientConVar["noadvwire"] = "1"

TOOL.ClientConVar["freeze"] = "1"
TOOL.ClientConVar["weld"] = "1"
TOOL.ClientConVar["worldweld"] = "0"
TOOL.ClientConVar["nocollide"] = "1"

if StreamRadioLib and StreamRadioLib.Loaded then
	TOOL.ClientConVar["model"] = StreamRadioLib.Util.GetDefaultModel()
	TOOL.ClientConVar["playbackloopmode"] = tostring(StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST)

	StreamRadioLib.Tool.AddLocale(TOOL, "name", "Radio Spawner")
	StreamRadioLib.Tool.AddLocale(TOOL, "desc", "Spawns a Stream Radio")

	StreamRadioLib.Tool.AddLocale(TOOL, "left", "Create a stream radio")
	StreamRadioLib.Tool.AddLocale(TOOL, "right", "Copy the settings of a radio")
	StreamRadioLib.Tool.AddLocale(TOOL, "reload", "Copy the model of an entity, but the most models will not have a display")

	StreamRadioLib.Tool.AddLocale(TOOL, "Undone_", "Undone Stream Radio")
	StreamRadioLib.Tool.AddLocale(TOOL, "SBoxLimit_", "You've hit the Stream Radio limit!")
	StreamRadioLib.Tool.AddLocale(TOOL, "Cleanup_", "Stream Radio")
	StreamRadioLib.Tool.AddLocale(TOOL, "Cleaned_", "Cleaned up all Stream Radios")

	StreamRadioLib.Tool.AddLocale(TOOL, "model", "Model:")
	StreamRadioLib.Tool.AddLocale(TOOL, "modelinfo", "Some models (usually speakers) don't have a display. Use this tool or Wiremod to control those.")
	StreamRadioLib.Tool.AddLocale(TOOL, "modelinfo.desc", "Some models (usually speakers) don't have a display.\nUse this tool or Wiremod to control those.")
	StreamRadioLib.Tool.AddLocale(TOOL, "modelinfo_mp", "Some selectable models might not be available on the server. Those will be replaced by a default model.")
	StreamRadioLib.Tool.AddLocale(TOOL, "modelinfo_mp.desc", "Some selectable models might not be available on the server.\nThose will be replaced by a default model.")
	StreamRadioLib.Tool.AddLocale(TOOL, "play", "Start playback")
	StreamRadioLib.Tool.AddLocale(TOOL, "play.desc", "If set, the radio will try to play a given URL on spawn or apply.\nThe URL can be set by this Tools or via Wiremod.")
	StreamRadioLib.Tool.AddLocale(TOOL, "nodisplay", "Disable display")
	StreamRadioLib.Tool.AddLocale(TOOL, "noadvwire", "Disable advanced wire outputs")
	StreamRadioLib.Tool.AddLocale(TOOL, "noadvwire.desc", "Disables the advanced wire outputs.\nIt is always disabled if Wiremod or GM_BASS3 is not installed on the Server.")
	StreamRadioLib.Tool.AddLocale(TOOL, "noinput", "Disable control")
	StreamRadioLib.Tool.AddLocale(TOOL, "noinput.desc", "Disable the control of the display.\nWiremod controlling will still work.")
	StreamRadioLib.Tool.AddLocale(TOOL, "nospectrum", "Disable spectrum visualization")
	StreamRadioLib.Tool.AddLocale(TOOL, "nospectrum.desc", "Disable rendering of the spectrum visualization on the display.")
	StreamRadioLib.Tool.AddLocale(TOOL, "playbackloopmode", "Loop Playback:")
	StreamRadioLib.Tool.AddLocale(TOOL, "playbackloopmode.desc", "Set what happens after a song ends.")
	StreamRadioLib.Tool.AddLocale(TOOL, "playbackloopmode.option.none", "No loop")
	StreamRadioLib.Tool.AddLocale(TOOL, "playbackloopmode.option.song", "Loop song")
	StreamRadioLib.Tool.AddLocale(TOOL, "playbackloopmode.option.playlist", "Loop playlist")
	StreamRadioLib.Tool.AddLocale(TOOL, "3dsound", "Enable 3D Sound")
	StreamRadioLib.Tool.AddLocale(TOOL, "mute", "Mute Radio")
	StreamRadioLib.Tool.AddLocale(TOOL, "volume", "Volume:")
	StreamRadioLib.Tool.AddLocale(TOOL, "radius", "Radius:")
	StreamRadioLib.Tool.AddLocale(TOOL, "radius.desc", "The radius in units the radio sound volume will drop down to 0% of the volume setting.")
	StreamRadioLib.Tool.AddLocale(TOOL, "streamurl", "Stream URL:")
	StreamRadioLib.Tool.AddLocale(TOOL, "freeze", "Freeze")
	StreamRadioLib.Tool.AddLocale(TOOL, "weld", "Weld")
	StreamRadioLib.Tool.AddLocale(TOOL, "worldweld", "Weld to world")
	StreamRadioLib.Tool.AddLocale(TOOL, "nocollide", "Nocollide")
	StreamRadioLib.Tool.AddLocale(TOOL, "spawnsettings", "Spawn settings:")

	StreamRadioLib.Tool.AddLocale(TOOL, "streamurl_info", "What can I put in as Stream URL?")
	StreamRadioLib.Tool.AddLocale(TOOL, "streamurl_info.desc", StreamRadioLib.STREAM_URL_INFO)

	StreamRadioLib.Tool.AddLocale(TOOL, "mute_volume_info", "NOTE: These are entity options too. So they only affect the radio they are applied on. The global settings for your client are at 'General Settings'.")
	StreamRadioLib.Tool.AddLocale(TOOL, "mute_volume_info.desc", "NOTE: These are entity options too. So they only affect the radio they are applied on. The global settings for your client are at 'General Settings'.")

	StreamRadioLib.Tool.AddLocale(TOOL, "streamurl_whitelist_info", "Whitelist protected server:\nOnly approved Stream URLs will work on this server!")

	StreamRadioLib.Tool.Setup(TOOL)
else
	TOOL.Information = nil

	if CLIENT then
		local StreamRadioLib = StreamRadioLib or {}
		local _mode = TOOL.Mode

		language.Add("Tool." .. _mode .. ".name", "Radio Spawner")
		language.Add("Tool." .. _mode .. ".desc", "Spawns a Stream Radio")
		language.Add("Tool." .. _mode .. ".0", "This tool could not be loaded.")

		function TOOL.BuildCPanel(CPanel)
			if StreamRadioLib.Loader_CreateErrorPanel then
				StreamRadioLib.Loader_CreateErrorPanel(CPanel, "This tool could not be loaded.")
			end
		end
	end
end


function TOOL:BuildToolPanel(CPanel)
	CPanel:PropSelect(
		StreamRadioLib.Tool.GetLocale(self, "model"),
		self.Mode .. "_model",
		StreamRadioLib.Model.RegisteredModels(),
		4
	)

	self:AddLabel( CPanel, "modelinfo", true )

	if game.IsDedicated() then
		self:AddLabel( CPanel, "modelinfo_mp", true )
	end

	CPanel:AddPanel(StreamRadioLib.Menu.GetSpacerLine())

	self:AddURLTextEntry( CPanel, "streamurl", false )
	self:AddWhitelistEnabledLabel( CPanel, "streamurl_whitelist_info", false )

	local _, StreamUrlInfoText = self:AddReadOnlyTextBox( CPanel, "streamurl_info" )
	StreamUrlInfoText:SetTall(245)

	CPanel:AddPanel(StreamRadioLib.Menu.GetSpacerLine())

	self:AddCheckbox( CPanel, "play", true )
	self:AddCheckbox( CPanel, "nodisplay", false )
	self:AddCheckbox( CPanel, "noinput", true )
	self:AddCheckbox( CPanel, "nospectrum", true )
	self:AddCheckbox( CPanel, "noadvwire", true )
	self:AddCheckbox( CPanel, "3dsound", false )

	CPanel:AddPanel(StreamRadioLib.Menu.GetSpacer())

	local iconPlaybackloopmodeNone = StreamRadioLib.GetPNGIconPath("arrow_not_refresh", true)
	local iconPlaybackloopmodeSong = StreamRadioLib.GetPNGIconPath("arrow_refresh")
	local iconPlaybackloopmodePlaylist = StreamRadioLib.GetPNGIconPath("table_refresh")

	local PlaybackLoopModeComboBox = self:AddComboBox(CPanel, "playbackloopmode", true)
	PlaybackLoopModeComboBox:SetSortItems(false)
	PlaybackLoopModeComboBox:AddChoice(StreamRadioLib.Tool.GetLocale(self, "playbackloopmode.option.none"), StreamRadioLib.PLAYBACK_LOOP_MODE_NONE, false, iconPlaybackloopmodeNone)
	PlaybackLoopModeComboBox:AddSpacer()
	PlaybackLoopModeComboBox:AddChoice(StreamRadioLib.Tool.GetLocale(self, "playbackloopmode.option.song"), StreamRadioLib.PLAYBACK_LOOP_MODE_SONG, false, iconPlaybackloopmodeSong)
	PlaybackLoopModeComboBox:AddChoice(StreamRadioLib.Tool.GetLocale(self, "playbackloopmode.option.playlist"), StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST, false, iconPlaybackloopmodePlaylist)

	CPanel:AddPanel(StreamRadioLib.Menu.GetSpacerLine())

	self:AddImportantLabel( CPanel, "mute_volume_info", true )

	CPanel:AddPanel(StreamRadioLib.Menu.GetSpacer())

	self:AddCheckbox( CPanel, "mute", false )

	local VolumeNumSlider = self:AddNumSlider( CPanel, "volume", false )
	VolumeNumSlider:SetMin( 0 )
	VolumeNumSlider:SetMax( 1 )
	VolumeNumSlider:SetDecimals( 2 )

	local RadiusNumSlider = self:AddNumSlider( CPanel, "radius", true )
	RadiusNumSlider:SetMin( 0 )
	RadiusNumSlider:SetMax( 5000 )
	RadiusNumSlider:SetDecimals( 0 )

	CPanel:AddPanel(StreamRadioLib.Menu.GetSpacerLine())

	self:AddLabel( CPanel, "spawnsettings", false )
	self:AddCheckbox( CPanel, "freeze", false )

	local WeldCheckbox = self:AddCheckbox( CPanel, "weld", false )
	local WorldWeldCheckbox = self:AddCheckbox( CPanel, "worldweld", false )
	local NoCollideCheckbox = self:AddCheckbox( CPanel, "nocollide", false )

	WeldCheckbox.OnChange = function( self, state )
		local state = ( state and 1 or 0 )

		if ( state == 0 ) then
			WorldWeldCheckbox:SetValue( 0 )
			NoCollideCheckbox:SetValue( 0 )
		end
	end

	WorldWeldCheckbox.OnChange = function( self, state )
		local state = ( state and 1 or 0 )

		if ( state == 1 ) then
			WeldCheckbox:SetValue( 1 )
		end
	end

	NoCollideCheckbox.OnChange = function( self, state )
		local state = ( state and 1 or 0 )

		if ( state == 1 ) then
			WeldCheckbox:SetValue( 1 )
		end
	end

	CPanel:AddPanel(StreamRadioLib.Menu.GetSpacer(5))
	CPanel:AddPanel(StreamRadioLib.Menu.GetOpenSettingsButton())
	CPanel:AddPanel(StreamRadioLib.Menu.GetOpenAdminSettingsButton())
	CPanel:AddPanel(StreamRadioLib.Menu.GetPlaylistEditorButton())
end

local function CalcSpawnAngle( normal, ply_ang, model )
	local Ang = normal:Angle( )
	local normalz = math.Round( normal.z, 4 )
	local IsWall = false
	local modelsettings = StreamRadioLib.Model.GetModelSettings( model ) or {}
	local angoffset = modelsettings.SpawnAng or Angle()
	local spawnFlatOnWall = modelsettings.SpawnFlatOnWall
	Ang.p = ( Ang.p + 90 ) % 360

	if spawnFlatOnWall and normalz == 0 then
		IsWall = true
	end

	if normalz == 1 then
		Ang.y = ( ply_ang.y + 180 ) % 360
		IsWall = false
	elseif normalz == -1 then
		Ang.y = ply_ang.y
		IsWall = false
	end

	if IsWall then
		Ang.p = 0
	end

	Ang:Normalize( )

	local _, Ang = LocalToWorld(Vector(), angoffset, Vector(), Ang)

	Ang:Normalize( )

	return Ang, IsWall
end

local function CalcSpawnPos( ent, IsWall, hitpos, normal, model )
	local modelsettings = StreamRadioLib.Model.GetModelSettings( model ) or {}
	local spawnAtOrigin = modelsettings.SpawnAtOrigin or false

	if spawnAtOrigin then
		return hitpos
	end

	local angoffset = modelsettings.SpawnAng or Angle()

	local min = ent:OBBMins()
	local max = ent:OBBMaxs()

	local rmin, rmax = ent:GetRotatedAABB( min, max )

	min:Rotate(angoffset)
	max:Rotate(angoffset)

	local size = Vector(
		math.abs( max.x - min.x ),
		math.abs( max.y - min.y ),
		math.abs( max.z - min.z )
	)

	local center = ( rmin + rmax ) / 2

	local Pos = hitpos - center
	local edge

	if IsWall then
		edge = size.x / 2
	else
		edge = size.z / 2
	end

	Pos = Pos + edge * normal

	return Pos
end

function TOOL:GetSettings()
	local settings = {}

	settings.StreamMute = self:GetClientBool("mute")
	settings.StreamVolume = self:GetClientNumberMinMax("volume", 0, 1)
	settings.Radius = self:GetClientNumberMinMax("radius", 0, 5000)
	settings.PlaybackLoopMode = self:GetClientNumber("playbackloopmode", StreamRadioLib.PLAYBACK_LOOP_MODE_NONE)
	settings.Sound3D = self:GetClientBool("3dsound")
	settings.DisableDisplay = self:GetClientBool("nodisplay")
	settings.DisableInput = self:GetClientBool("noinput")
	settings.DisableSpectrum = self:GetClientBool("nospectrum")
	settings.DisableAdvancedOutputs = self:GetClientBool("noadvwire")

	return settings
end

function TOOL:SetSettings(settings)
	local url = settings.StreamUrl or ""

	url = StreamRadioLib.Url.SanitizeUrl(url)

	self:SetClientInfo("streamurl", url)

	self:SetClientBool("mute", settings.StreamMute)
	self:SetClientNumber("volume", settings.StreamVolume or 1)
	self:SetClientNumber("radius", settings.Radius or 1200)
	self:SetClientNumber("playbackloopmode", settings.PlaybackLoopMode or StreamRadioLib.PLAYBACK_LOOP_MODE_NONE)
	self:SetClientBool("3dsound", settings.Sound3D)
	self:SetClientBool("nodisplay", settings.DisableDisplay)
	self:SetClientBool("noinput", settings.DisableInput)
	self:SetClientBool("nospectrum", settings.DisableSpectrum)
	self:SetClientBool("noadvwire", settings.DisableAdvancedOutputs)
end

local _TOOL_Class = TOOL.Mode
local function MakeStreamRadio(ply, Pos, Ang, model, nocollide, Settings)
	if not SERVER then return end
	if IsValid(ply) and not ply:CheckLimit(_TOOL_Class) then return end
	Settings = Settings or {}

	if not StreamRadioLib then return end
	if not StreamRadioLib.SpawnRadio then return end

	local ent = StreamRadioLib.SpawnRadio(ply, model, Pos, Ang, Settings)
	if not IsValid(ent) then return end

	local phys = ent:GetPhysicsObject( )

	if IsValid(phys) then
		phys:EnableCollisions( not nocollide )
	end

	ent.Settings = Settings
	ent.nocollide = nocollide

	if IsValid(ply) then
		ply:AddCount(_TOOL_Class, ent)
		ply:AddCleanup(_TOOL_Class, ent)
	end

	return ent
end

if SERVER then
	duplicator.RegisterEntityClass("sent_" .. TOOL.Mode, MakeStreamRadio, "Pos", "Ang", "Model", "nocollide", "Settings")
end

function TOOL:LeftClick(trace)
	if not self.ToolLibLoaded then return false end
	if not self:IsValidTrace(trace) then return false end

	local ent = trace.Entity
	local ply = self:GetOwner()

	if CLIENT then return true end

	local settings = self:GetSettings()

	if self:IsValidRadio(ent) then
		if not StreamRadioLib.EditRadio(ent, settings) then return false end

		ent:SetToolURL(self:GetClientInfo("streamurl"), self:GetClientBool("play"))
		return true
	end

	if not self:GetSWEP():CheckLimit(self.Mode) then
		return false
	end

	local model = self:GetModel()
	local ang, IsWall = CalcSpawnAngle(trace.HitNormal, ply:GetAngles(), model)

	local nocollide = self:GetClientBool("nocollide")
	local weld = self:GetClientBool("weld")
	local worldweld = self:GetClientBool("worldweld")
	local freeze = self:GetClientBool("freeze")

	nocollide = nocollide and ((weld and IsValid(trace.Entity)) or worldweld)

	local ent = MakeStreamRadio(ply, trace.HitPos, ang, model, nocollide, settings)
	if not IsValid(ent) then return false end

	local pos = CalcSpawnPos(ent, IsWall, trace.HitPos, trace.HitNormal, model)
	ent:SetPos(pos)

	ent:SetToolURL(self:GetClientInfo("streamurl"), self:GetClientBool("play"))

	local const = nil

	if weld or worldweld then
		const = StreamRadioLib.Tool.AdvWeld( ent, trace.Entity, trace.PhysicsBone, true, not nocollide, worldweld, freeze )
	else
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(not freeze)
		end
	end

	if IsValid(ply) then
		undo.Create(self.Mode)
		undo.AddEntity(ent)

		if IsValid(const) then
			undo.AddEntity(const)
		end

		undo.SetPlayer(ply)
		undo.Finish()
	end

	return true
end

function TOOL:RightClick( trace )
	if not self.ToolLibLoaded then return false end
	if not self:IsValidTrace(trace) then return false end

	local ent = trace.Entity
	if not self:IsValidRadio(ent) then return false end

	if CLIENT then return true end

	self:SetSettings(ent:GetSettings())
	return true
end

function TOOL:Reload( trace )
	if not self.ToolLibLoaded then return false end
	if not self:IsValidTrace(trace) then return false end

	local ent = trace.Entity

	if not IsValid(ent) then return false end
	if ent:IsPlayer() then return false end
	if ent:IsNPC() then return false end
	if ent:GetPhysicsObjectCount() > 1 then return false end -- No ragdolls!

	local model = ent:GetModel()
	if not StreamRadioLib.Util.IsValidModel(model) then return false end

	if CLIENT then return true end

	self:SetClientInfo("model", model)
	return true
end

function TOOL:UpdateGhostStreamRadio( ent, ply, model )
	if not IsValid( ent ) then return end
	if not IsValid( ply ) then return end

	if not self.ToolLibLoaded then return end

	local trace = self:GetFallbackTrace()
	if not trace then return end
	local hitent = trace.Entity

	if self:IsValidRadio(hitent) then
		ent:SetNoDraw(true)
		return
	end

	ent:SetNoDraw(false)

	local Ang, IsWall = CalcSpawnAngle(trace.HitNormal, ply:GetAngles(), model)
	ent:SetAngles(Ang)

	local Pos = CalcSpawnPos(ent, IsWall, trace.HitPos, trace.HitNormal, model)
	ent:SetPos(Pos)
end

function TOOL:Think( )
	if not self.ToolLibLoaded then return end
	local model = self:GetModel()

	if not IsValid(self.GhostEntity) then
		self:MakeGhostEntity(
			Model(model),
			vector_origin,
			angle_zero
		)
	end

	if not IsValid(self.GhostEntity) then
		return
	end

	if self.GhostEntity:GetModel() ~= model then
		self.GhostEntity:SetModel(model)
		self.GhostEntity:DrawShadow(false)
	end

	self:UpdateGhostStreamRadio(self.GhostEntity, self:GetOwner(), model)
end

function TOOL:GetModel( )
	local model = self:GetClientInfo("model")

	if not StreamRadioLib.Util.IsValidModel(model) then
		return StreamRadioLib.Util.GetDefaultModel()
	end

	return model
end

function TOOL:Holster()
	if not self.ToolLibLoaded then return end
	self:ReleaseGhostEntity()
end

function TOOL:Deploy()
end
