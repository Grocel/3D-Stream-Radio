AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

DEFINE_BASECLASS( "base_streamradio_gui" )

local StreamRadioLib = StreamRadioLib
local LIBPrint = StreamRadioLib.Print
local LIBError = StreamRadioLib.Error
local LIBWire = StreamRadioLib.Wire
local LIBUtil = StreamRadioLib.Util
local LIBUrl = StreamRadioLib.Url

local g_isLoaded = StreamRadioLib and StreamRadioLib.Loaded
local g_isWiremodLoaded = g_isLoaded and LIBWire.HasWiremod()

function ENT:InitializeModel()
	if not g_isLoaded then
		return
	end

	local model = self:GetModel()

	if not StreamRadioLib.Util.IsValidModel(model) then
		self:SetModel(StreamRadioLib.Util.GetDefaultModel())
	end
end

function ENT:Initialize( )
	self:InitializeModel()

	self:SetUseType( SIMPLE_USE )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	if not g_isLoaded then
		return
	end

	BaseClass.Initialize( self )

	self.old = {}
	self.slavesradios = {}

	self.ExtraURLs = {}
	self.ExtraNames = {}

	self.ExtraURLs.Tool = ""
	self.ExtraURLs.Wire = ""
	self.ExtraURLs.Dupe = ""
	self.ExtraURLs.Mode = ""

	self.ActivateExtraURL = ""

	self.ExtraNames.Tool = "Toolgun URL"
	self.ExtraNames.Wire = "Wiremod Input"
	self.ExtraNames.Dupe = ""

	self.ActivateExtraName = ""

	self:SetCLMute(false)
	self:SetCLVolume(1)

	self:AddWireInput("Stream URL", "STRING")

	self:AddWireInput("Play", "NORMAL")
	self:AddWireInput("Pause", "NORMAL")
	self:AddWireInput("Mute", "NORMAL")
	self:AddWireInput("Volume", "NORMAL")
	self:AddWireInput("Radius", "NORMAL")
	self:AddWireInput("Loop Mode", "NORMAL")
	self:AddWireInput("Time", "NORMAL")
	self:AddWireInput("3D Sound", "NORMAL")

	self:AddWireInput("Disable Display", "NORMAL")
	self:AddWireInput("Disable User Input", "NORMAL")
	self:AddWireInput("Disable Spectrum Visualizer", "NORMAL")

	self:AddWireInput("Play Previous", "NORMAL")
	self:AddWireInput("Play Next", "NORMAL")

	self:AddWireInput("Master Radio", "ENTITY", "For synchronizing radios")


	self:AddWireOutput("Play", "NORMAL")
	self:AddWireOutput("Paused", "NORMAL")
	self:AddWireOutput("Stopped", "NORMAL")
	self:AddWireOutput("Muted", "NORMAL")
	self:AddWireOutput("Volume", "NORMAL")
	self:AddWireOutput("Radius", "NORMAL")

	self:AddWireOutput("Loop Mode", "NORMAL")
	self:AddWireOutput("Loops Song", "NORMAL")
	self:AddWireOutput("Loops Playlist", "NORMAL")
	self:AddWireOutput("Playlist Item Count", "NORMAL")
	self:AddWireOutput("Playlist Pos", "NORMAL")
	self:AddWireOutput("Playlist Names", "ARRAY")
	self:AddWireOutput("Playlist URLs", "ARRAY")

	self:AddWireOutput("Time", "NORMAL")
	self:AddWireOutput("Length", "NORMAL")
	self:AddWireOutput("Ended", "NORMAL")
	self:AddWireOutput("3D Sound", "NORMAL")
	self:AddWireOutput("Stream Name", "STRING")
	self:AddWireOutput("Stream URL", "STRING")

	self:AddWireOutput("Display Disabled", "NORMAL")
	self:AddWireOutput("User Input Disabled", "NORMAL")
	self:AddWireOutput("Spectrum Visualizer Disabled", "NORMAL")

	self:AddWireOutput("Advanced Outputs", "NORMAL", "Advanced Outputs available? Needs GM_BASS3.")
	self:AddWireOutput("Playing", "NORMAL", "Adv. Output")
	self:AddWireOutput("Loading", "NORMAL", "Adv. Output")
	self:AddWireOutput("Meta Tags", "ARRAY", "Adv. Output")
	self:AddWireOutput("Codec", "ARRAY", "Adv. Output")
	self:AddWireOutput("Spectrum", "ARRAY", "Adv. Output")
	self:AddWireOutput("Sound Level", "NORMAL", "Adv. Output")

	self:AddWireOutput("Error", "NORMAL")
	self:AddWireOutput("Error Text", "STRING")

	self:AddWireOutput("This Radio", "ENTITY", "For synchronizing radios")

	self:InitWirePorts()
	self:SetSettings()

	self:MarkForUpdatePlaybackLoopMode()
end

function ENT:SetSettings(settings)
	if not g_isLoaded then return end
	settings = settings or {}

	local url = settings.StreamUrl or ""

	if url ~= "" then
		self:SetStreamURL(url)
	end

	local sound3d = settings.Sound3D

	if sound3d == nil then
		sound3d = true
	end

	local noadvoutputs = settings.DisableAdvancedOutputs

	if noadvoutputs == nil then
		noadvoutputs = true
	end

	self:SetStreamName(settings.StreamName or "")

	self:SetSVMute(settings.StreamMute or false)
	self:SetVolume(settings.StreamVolume or 1)

	self:SetRadius(settings.Radius or 1200)
	self:SetSound3D(sound3d)

	self:SetDisableDisplay(settings.DisableDisplay or false)
	self:SetDisableInput(settings.DisableInput or false)
	self:SetDisableSpectrum(settings.DisableSpectrum or false)
	self:SetDisableAdvancedOutputs(noadvoutputs)

	if settings.PlaybackLoopMode then
		self:SetPlaybackLoopMode(settings.PlaybackLoopMode)
	end

	-- @DEPRECATED
	if not settings.PlaybackLoopMode then
		local playlistloop = settings.PlaylistLoop

		if playlistloop == nil then
			playlistloop = true
		end

		self:SetPlaylistLoop(playlistloop)
		self:SetLoop(settings.StreamLoop or false)
	end
end

function ENT:GetSettings()
	local settings = {}
	if not g_isLoaded then return settings end

	settings.StreamUrl = self:GetStreamURL()
	settings.StreamName = self:GetStreamName()

	settings.StreamMute = self:GetSVMute()
	settings.StreamVolume = self:GetVolume()
	settings.Radius = self:GetRadius()
	settings.Sound3D = self:GetSound3D()

	settings.DisableDisplay = self:GetDisableDisplay()
	settings.DisableInput = self:GetDisableInput()
	settings.DisableSpectrum = self:GetDisableSpectrum()
	settings.DisableAdvancedOutputs = self:GetDisableAdvancedOutputs()

	settings.PlaybackLoopMode = self:GetPlaybackLoopMode()

	-- @DEPRECATED
	settings.StreamLoop = self:GetLoop()
	settings.PlaylistLoop = self:GetPlaylistLoop()

	return settings
end

function ENT:OnTakeDamage( dmg )
	self:TakePhysicsDamage( dmg )
end

function ENT:OnReloaded()
	if not IsValid(self) then return end
	if not g_isLoaded then return end

	local ply = self:GetRealRadioOwner()
	local model = self:GetModel()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local radioName = LIBPrint.GetRadioEntityString(self)

	local motion = false

	local selfPhys = self:GetPhysicsObject()
	if IsValid(selfPhys) then
		motion = selfPhys:IsMotionEnabled()
	end

	self:Remove()

	StreamRadioLib.Timedcall(function(ply, model, pos, ang)
		local ent = StreamRadioLib.SpawnRadio(ply, model, pos, ang)
		if not IsValid(ent) then
			return
		end

		local entPhys = ent:GetPhysicsObject()
		if IsValid(entPhys) then
			entPhys:EnableMotion(motion)
		end

		LIBPrint.Msg(ply, "%s respawned after reload.", radioName)

		if IsValid(ply) then
			local TOOL_Class = "streamradio"

			undo.Create(TOOL_Class)
			undo.AddEntity(ent)
			undo.SetPlayer(ply)
			undo.Finish()

			ply:AddCleanup(TOOL_Class, ent)
		end
	end, ply, model, pos, ang)
end

function ENT:UpdateVolume()
	local streamObj = self.StreamObj

	if not IsValid(streamObj) then
		return
	end

	local volume_ent = self:GetVolume()
	local volume_stream = streamObj:GetVolume()
	local old = self.old

	if volume_ent ~= old.Volume_ent then
		streamObj:SetVolume(volume_ent)

		old.Volume_ent = volume_ent
		old.Volume_stream = volume_ent
		return
	end

	if volume_stream ~= old.Volume_stream then
		self:SetVolume(volume_stream)

		old.Volume_ent = volume_stream
		old.Volume_stream = volume_stream
		return
	end
end

function ENT:CanHaveSpectrum()
	if not g_isWiremodLoaded then return false end
	if not StreamRadioLib.AllowSpectrum() then return false end
	if self:GetDisableAdvancedOutputs() then return false end

	return true
end

function ENT:FastThink()
	BaseClass.FastThink(self)

	self:MasterRadioSyncThink()
end

function ENT:WiremodThink()
	local streamObj = self.StreamObj
	if not IsValid(streamObj) then return end

	self._codec = self._codec or {}
	self._spectrum = self._spectrum or {}

	local hasadvoutputs = streamObj:IsBASSEngineEnabled()

	if self:IsConnectedOutputWire("Spectrum") or self:IsConnectedWirelink() then
		if hasadvoutputs then
			streamObj:GetSpectrumTable(128, self._spectrum)
		else
			LIBUtil.EmptyTableSafe(self._spectrum)
		end
	else
		LIBUtil.EmptyTableSafe(self._spectrum)

		if hasadvoutputs then
			self._spectrum[1] = "Standby mode: Connect to this Output to activate it."
		end
	end

	if hasadvoutputs then
		self._codec[1] = streamObj:GetSamplingRate()
		self._codec[2] = streamObj:GetBitsPerSample()
		self._codec[3] = streamObj:GetAverageBitRate()
		self._codec[4] = streamObj:GetType()
	end

	self:TriggerWireOutput("Play", streamObj:IsPlayMode())
	self:TriggerWireOutput("Paused", streamObj:IsPauseMode())
	self:TriggerWireOutput("Stopped", streamObj:IsStopMode())
	self:TriggerWireOutput("Volume", self:GetVolume())
	self:TriggerWireOutput("Muted", self:GetSVMute())
	self:TriggerWireOutput("Radius", self:GetRadius())

	self:TriggerWireOutput("Loop Mode", self:GetPlaybackLoopMode())
	self:TriggerWireOutput("Loops Song", self:GetLoop())
	self:TriggerWireOutput("Loops Playlist", self:GetPlaylistLoop())
	self:TriggerWireOutput("Playlist Pos", self:GetPlaylistPos())

	self:TriggerWireOutput("Time", streamObj:GetMasterTime())
	self:TriggerWireOutput("Length", streamObj:GetMasterLength())
	self:TriggerWireOutput("Ended", streamObj:HasEnded())
	self:TriggerWireOutput("3D Sound", self:GetSound3D())
	self:TriggerWireOutput("Stream Name", streamObj:GetStreamName())

	self:TriggerWireOutput("Stream URL", streamObj:GetURL())

	self:TriggerWireOutput("Display Disabled", self:GetDisableDisplay())
	self:TriggerWireOutput("User Input Disabled", self:GetDisableInput())
	self:TriggerWireOutput("Spectrum Visualizer Disabled", self:GetDisableSpectrum())

	self:TriggerWireOutput("Advanced Outputs", hasadvoutputs)
	self:TriggerWireOutput("Playing", streamObj:IsPlaying())
	self:TriggerWireOutput("Loading", streamObj:IsLoading() or streamObj:IsCheckingUrl() or streamObj:IsBuffering() or streamObj:IsSeeking())

	self:TriggerWireOutput("Codec", self._codec)
	self:TriggerWireOutput("Spectrum", self._spectrum)
	self:TriggerWireOutput("Sound Level", streamObj:GetAverageLevel())

	self:TriggerWireOutput("This Radio", self)

	local err = LIBError.STREAM_ERROR_WIRE_ADVOUT_DISABLED

	if hasadvoutputs then
		err = streamObj:GetError()
	end

	self:TriggerWireOutput("Error", err)
	self:TriggerWireOutput("Error Text", LIBError.GetStreamErrorDescription(err))
end

function ENT:InternalThink( )
	BaseClass.InternalThink( self )

	self:UpdateVolume()
end

function ENT:InternalSlowThink()
	BaseClass.InternalSlowThink(self)

	if not self:GetMasterRadioRecursive() then
		local oldActivateURL = self.ActivateExtraURL or ""
		local oldActivateName = self.ActivateExtraName or ""

		local extraURLs = self.ExtraURLs
		local extraNames = self.ExtraNames

		extraURLs.Tool = extraURLs.Tool or ""
		extraURLs.Wire = extraURLs.Wire or ""
		extraURLs.Dupe = extraURLs.Dupe or ""
		extraURLs.Mode = extraURLs.Mode or ""

		self.ActivateExtraURL = LIBUrl.SanitizeUrl(extraURLs[extraURLs.Mode] or "")
		self.ActivateExtraName = extraNames[extraURLs.Mode] or ""

		self:SetWireMode(LIBUrl.IsValidURL(extraURLs.Wire))
		self:SetToolMode(LIBUrl.IsValidURL(extraURLs.Tool))

		if oldActivateURL ~= self.ActivateExtraURL or oldActivateName ~= self.ActivateExtraName then
			self:OnExtraURLUpdate()
		end
	end

	local streamObj = self.StreamObj

	if IsValid(streamObj) then
		local canHaveSpectrum = self:CanHaveSpectrum()

		if g_isWiremodLoaded and canHaveSpectrum then
			local MetaTags = table.ClearKeys(streamObj:GetMetaTags() or {})
			self:TriggerWireOutput("Meta Tags", MetaTags) -- @TODO: better format, better tags. Maybe CLIENT -> SERVER transmission, so it works without GM_BASS3.
		end

		streamObj:SetBASSEngineEnabled(canHaveSpectrum)

		-- Loop the song also when we are in playlist mode without a playlist. We pretend we have a playlist with a single item.
		local shouldLoop = self:GetLoop() or (not self:GetHasPlaylist() and self:GetPlaylistLoop())

		streamObj:SetLoop(shouldLoop)
	end

	self:PlaybackLoopModeThink()
	self:PanelThink()
end

function ENT:OnExtraURLUpdate()
	local name = self.ActivateExtraName
	local url = self.ActivateExtraURL

	if url ~= "" then
		name = name .. ": " .. url
	end

	self:OnExtraURL(name, self.ActivateExtraURL)
end

function ENT:OnGUIReady(...)
	BaseClass.OnGUIReady(self, ...)

	if self:GetMasterRadioRecursive() then
		return
	end

	if self.ActivateExtraURL ~= "" then
		self:OnExtraURLUpdate()
	end

	if IsValid(self.StreamObj) then
		if self.StreamObj:GetURL() == "" then
			self:StopStreamInternal()
		end
	end
end

function ENT:OnPlaylistChanged()
	BaseClass.OnPlaylistChanged(self)

	if not g_isWiremodLoaded then
		return
	end

	local playlist = self:GetPlaylist()

	local len = #playlist

	local names = {}
	local urls = {}

	self:TriggerWireOutput("Playlist Item Count", len)

	for i, v in ipairs(playlist) do
		table.insert(names, v.name)
		table.insert(urls, v.url)
	end

	self:TriggerWireOutput("Playlist Names", names)
	self:TriggerWireOutput("Playlist URLs", urls)
end

function ENT:SetToolURL(url, setmode)
	if not g_isLoaded then return end

	local extraURLs = self.ExtraURLs

	extraURLs.Tool = LIBUrl.SanitizeUrl(url)

	if not setmode and extraURLs.Mode == "Tool" then
		extraURLs.Mode = ""
	end

	if setmode and (extraURLs.Mode == "" or extraURLs.Mode == "Tool") then
		self.ActivateExtraName = ""
		self:OnToolMode()
	end
end

function ENT:GetToolURL()
	return self.ExtraURLs.Tool
end

function ENT:SetWireURL(url, setmode)
	if not g_isLoaded then return end

	self.ExtraURLs.Wire = LIBUrl.SanitizeUrl(url)

	if setmode then
		self.ActivateExtraName = ""
		self:OnWireMode()
	end
end

function ENT:SetDupeURL(url, name, setmode)
	if not g_isLoaded then return end

	name = tostring(name or "")
	name = string.Trim(name)

	if name == "" then
		name = "Duped URL"
	end

	self.ExtraURLs.Dupe = LIBUrl.SanitizeUrl(url)
	self.ExtraNames.Dupe = name

	if setmode then
		self.ActivateExtraName = ""
		self:OnDupeMode()
	end
end

function ENT:GetWireURL()
	return self.ExtraURLs.Wire
end

function ENT:OnToolMode()
	self.ExtraURLs.Mode = "Tool"
end

function ENT:OnWireMode()
	self.ExtraURLs.Mode = "Wire"
end

function ENT:OnDupeMode()
	self.ExtraURLs.Mode = "Dupe"
end

function ENT:OnExtraURL(name, url)
	if not IsValid(self.StreamObj) then
		return
	end

	url = LIBUrl.SanitizeUrl(url)

	if url == "" then
		self:StopStreamInternal()
		return
	end

	if self.ExtraURLs.Mode ~= "Dupe" then
		local playlist = {
			{
				url = url,
				name = name,
			}
		}

		self:SetPlaylist(playlist, 1)
		self._dupePlaylistData = playlist

		if IsValid(self.GUI_Main) then
			self.GUI_Main:EnablePlaylist(false)
		end
	end

	self:PlayStreamInternal(url, name)
end

function ENT:OnPlayStreamInternal(url, name)
	BaseClass.OnPlayStreamInternal(self, url, name)

	if IsValid(self.GUI_Main) then
		self.GUI_Main:OpenPlayer()
	end
end

function ENT:StopStreamInternal()
	BaseClass.StopStreamInternal(self)

	self.ExtraURLs = self.ExtraURLs or {}
	local extraURLs = self.ExtraURLs

	extraURLs.Mode = ""
	extraURLs.Dupe = ""

	if IsValid(self.GUI_Main) then
		self.GUI_Main:Stop()
	end
end

function ENT:StreamOnTrackEnd(stream)
	BaseClass.StreamOnTrackEnd(self, stream)

	if not self:GetHasPlaylist() then
		return
	end

	local masterradio = self:GetMasterRadioRecursive()
	if masterradio then
		return
	end

	local loopMode = self:GetPlaybackLoopMode()
	if loopMode ~= StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST then
		return
	end

	-- Song ended, so ignore cooldown
	self._nextPlaylistSwitch = nil
	self:PlayNextPlaylistItem()

	stream:Play(true)
end

function ENT:OnMasterradioChange(masterradio, oldmasterradio)
	if IsValid(masterradio) then return end

	if self._wire_reenableports then
		for k, v in pairs(self._wire_reenableports) do
			if k == "Master Radio" then continue end
			self:OnWireInputTrigger(k, v, true)
		end

		self._wire_reenableports = nil
	end
end

function ENT:OnRemove()
	self:OnRemoveShared()
	BaseClass.OnRemove(self)
end

local function getPlayerName(ply)
	if not IsValid(ply) then
		return "<Unknown>"
	end

	return "'" .. StreamRadioLib.Print.GetPlayerString(ply) .. "'"
end

function ENT:NWOverflowKill()
	if SERVER then
		local message = nil
		local owner = self:GetRealRadioOwner()
		local user = self:GetLastUser()
		local logForPly = owner

		if not IsValid(user) then
			user = owner
		end

		if not IsValid(logForPly) then
			logForPly = user
		end

		local message = string.format(
			"Network overflow/spam detected. Stream Radio '%s' removed! Owner: %s, Last user: %s.",
			tostring(self),
			getPlayerName(owner),
			getPlayerName(user)
		)

		StreamRadioLib.Print.Msg(owner, message)

		if user ~= owner then
			StreamRadioLib.Print.Msg(user, message)
		end

		StreamRadioLib.Print.Log(logForPly, message)
	end

	BaseClass.NWOverflowKill(self)
end

function ENT:OnPreEntityCopy()
	BaseClass.OnPreEntityCopy(self)

	local extraURLs = table.Copy(self.ExtraURLs)

	extraURLs.Mode = extraURLs.Mode or ""

	if extraURLs.Mode == "Dupe" then
		extraURLs.Mode = ""
	end

	extraURLs.Dupe = ""

	if not LIBUrl.IsValidURL(extraURLs.Tool) then
		extraURLs.Tool = ""

		if extraURLs.Mode == "Tool" then
			extraURLs.Mode = ""
		end
	end

	if not LIBUrl.IsValidURL(extraURLs.Wire) then
		extraURLs.Wire = ""

		if extraURLs.Mode == "Wire" then
			extraURLs.Mode = ""
		end
	end

	self:SetDupeData("ExtraURLs", extraURLs)
end

function ENT:DupeDataApply(key, value)
	BaseClass.DupeDataApply(self, key, value)

	if key ~= "ExtraURLs" then return end

	local extraURLs = self.ExtraURLs

	local mode = extraURLs.Mode
	local wireurl = extraURLs.Wire or ""
	local dupeurl = extraURLs.Dupe or ""

	table.CopyFromTo(value, extraURLs)

	extraURLs.Wire = wireurl
	extraURLs.Dupe = dupeurl

	if LIBUrl.IsValidURL(dupeurl) and extraURLs.Mode == "" and mode == "Dupe" then
		extraURLs.Mode = "Dupe"
	end
end

function ENT:PermaPropSave()
	local dataA = BaseClass.PermaPropSave(self)
	local dataB = {
		Model = self:GetModel()
	}

	return table.Merge(dataA, dataB)
end

function ENT:PermaPropLoad(data)
	if data.Model then
		local model = Model(data.Model)

		if StreamRadioLib.Util.IsValidModel(model) then
			self:SetModel(model)
		end
	end

	BaseClass.PermaPropLoad(self, data)

	self:Spawn()
	self:Activate()

	return true
end

function ENT:OnWireInputTrigger(name, value, wired)
	if not IsValid(self.StreamObj) then return end

	if name == "Master Radio" then
		if not IsValid(value) then
			value = nil
		end

		if not wired then
			value = nil
		end

		if value and not value.__IsRadio then
			value = nil
		end

		if value and not IsValid(value.StreamObj) then
			value = nil
		end

		if value == self then
			value = nil
		end

		self:SetMasterRadio(value or NULL)
		return
	end

	if name == "Mute" then
		value = tobool(value)

		if not wired then
			value = false
		end

		self:SetSVMute(value)
		return
	end

	if name == "Volume" then
		value = tonumber(value) or 0

		if not wired then
			value = 1
		end

		self:SetVolume(value)
		return
	end

	if name == "Radius" then
		value = tonumber(value) or 0

		if not wired then
			value = 1200
		end

		value = math.Clamp( value, 0, 5000 )
		self:SetRadius(value)
		return
	end

	if name == "3D Sound" then
		value = tobool(value)

		if not wired then
			value = false
		end

		self:SetSound3D(value)
		return
	end

	if name == "Disable Display" then
		value = tobool(value)

		if not wired then
			value = false
		end

		self:SetDisableDisplay(value)
		return
	end

	if name == "Disable User Input" then
		value = tobool(value)

		if not wired then
			value = false
		end

		self:SetDisableInput(value)
		return
	end

	if name == "Disable Spectrum Visualizer" then
		value = tobool(value)

		if not wired then
			value = false
		end

		self:SetDisableSpectrum(value)
		return
	end

	if name == "Play Previous" then
		value = tobool(value)

		if not wired then
			value = false
		end

		if not value then
			return
		end

		self:PlayPreviousPlaylistItem()
		return
	end

	if name == "Play Next" then
		value = tobool(value)

		if not wired then
			value = false
		end

		if not value then
			return
		end

		self:PlayNextPlaylistItem()
		return
	end

	-- Disable Wire inputs in case of a synchronisation with a master radio
	if self:GetMasterRadioRecursive() then
		self._wire_reenableports = self._wire_reenableports or {}

		if wired then
			self._wire_reenableports[name] = value
		else
			self._wire_reenableports[name] = nil
		end

		return
	end

	if name == "Play" then
		value = tobool(value)

		if not wired then
			value = false
		end

		if not value then
			self.ExtraURLs.Mode = ""
			self.StreamObj:Stop()
			return
		end

		local hasWire = self:GetWireMode()
		local hasTool = self:GetToolMode()

		if hasWire then
			self:OnWireMode()
			return
		end

		if hasTool then
			self:OnToolMode()
			return
		end

		if IsValid(self.GUI_Main) then
			self:OnExtraURL(self.StreamObj:GetStreamName(), self.StreamObj:GetURL())
		end

		return
	end

	if name == "Pause" then
		value = tobool(value)

		if not wired then
			value = false
		end

		if not value then
			self.StreamObj:UnPause()
			return
		end

		self.StreamObj:Pause()
		return
	end

	if name == "Loop Mode" then
		value = tobool(value)

		if not wired then
			value = false
		end

		self:SetPlaybackLoopMode(value)
		return
	end

	if name == "Time" then
		value = tonumber(value or 0)
		local curtime = self.StreamObj:GetMasterTime()

		if not wired then
			self.StreamObj:SetTime(curtime, true)
			return
		end

		local delta = math.abs(curtime - value)
		local maxDelta = engine.TickInterval() * 4

		if delta < maxDelta then
			return
		end

		self.StreamObj:SetTime(value, true)
		return
	end

	if name == "Stream URL" then
		value = tostring(value or "")

		if not wired then
			value = ""
		end

		self:SetWireURL(value, self.ExtraURLs.Mode ~= "")
		return
	end
end
