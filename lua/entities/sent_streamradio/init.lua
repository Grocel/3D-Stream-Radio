AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

DEFINE_BASECLASS( "base_streamradio_gui" )

local StreamRadioLib = StreamRadioLib
local LIBError = StreamRadioLib.Error
local LIBWire = StreamRadioLib.Wire
local LIBUtil = StreamRadioLib.Util

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

	self.old = {}
	self.slavesradios = {}

	self.ExtraURLs = {}
	self.ExtraNames = {}

	self.ExtraURLs.Tool = ""
	self.ExtraURLs.Wire = ""
	self.ExtraURLs.Mode = ""

	self.ActivateExtraURL = ""

	self.ExtraNames.Tool = "Toolgun URL"
	self.ExtraNames.Wire = "Wiremod Input"

	self.ActivateExtraName = ""

	self:SetCLMute(false)
	self:SetCLVolume(1)

	BaseClass.Initialize( self )

	self:AddWireInput("Play", "NORMAL")
	self:AddWireInput("Pause", "NORMAL")
	self:AddWireInput("Mute", "NORMAL")
	self:AddWireInput("Volume", "NORMAL")
	self:AddWireInput("Radius", "NORMAL")
	self:AddWireInput("LoopMode", "NORMAL")
	self:AddWireInput("Time", "NORMAL")
	self:AddWireInput("3D Sound", "NORMAL")
	self:AddWireInput("Stream URL", "STRING")
	self:AddWireInput("Master Radio", "ENTITY", "For synchronizing radios")


	self:AddWireOutput("Play", "NORMAL")
	self:AddWireOutput("Paused", "NORMAL")
	self:AddWireOutput("Stopped", "NORMAL")
	self:AddWireOutput("Muted", "NORMAL")
	self:AddWireOutput("Volume", "NORMAL")
	self:AddWireOutput("Radius", "NORMAL")

	self:AddWireOutput("LoopMode", "NORMAL")
	self:AddWireOutput("LoopsSong", "NORMAL")
	self:AddWireOutput("LoopsPlaylist", "NORMAL")
	self:AddWireOutput("PlaylistAvailable", "NORMAL")

	self:AddWireOutput("Time", "NORMAL")
	self:AddWireOutput("Length", "NORMAL")
	self:AddWireOutput("Ended", "NORMAL")
	self:AddWireOutput("3D Sound", "NORMAL")
	self:AddWireOutput("Stream Name", "STRING")
	self:AddWireOutput("Stream URL", "STRING")

	self:AddWireOutput("Advanced Outputs", "NORMAL", "Advanced Outputs available? Needs GM_BASS3.")
	self:AddWireOutput("Playing", "NORMAL", "Adv. Output")
	self:AddWireOutput("Loading", "NORMAL", "Adv. Output")
	self:AddWireOutput("Tag", "ARRAY", "Adv. Output")
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

function ENT:OnReloaded( )
	if not IsValid( self ) then return end
	if not g_isLoaded then return end

	local ply, model, pos, ang = self:GetRealRadioOwner(), self:GetModel( ), self:GetPos( ), self:GetAngles( )
	StreamRadioLib.Print.Msg( ply, "Reloaded " .. tostring( self ) )
	self:Remove( )

	StreamRadioLib.Timedcall( function( ply, model, pos, ang )
		local ent = StreamRadioLib.SpawnRadio( ply, model, pos, ang )
		if ( not IsValid( ent ) ) then return end
		if ( not IsValid( ply ) ) then return end
		local TOOL_Class = "streamradio"
		undo.Create( TOOL_Class )
		undo.AddEntity( ent )
		undo.SetPlayer( ply )
		undo.Finish( )
		ply:AddCleanup( TOOL_Class, ent )
	end, ply, model, pos, ang )
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
			self._spectrum[1] = "Standby mode: Connect to this Output to aktivate it."
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

	self:TriggerWireOutput("LoopMode", self:GetPlaybackLoopMode())
	self:TriggerWireOutput("LoopsSong", self:GetLoop())
	self:TriggerWireOutput("LoopsPlaylist", self:GetPlaylistLoop())
	self:TriggerWireOutput("PlaylistAvailable", self:IsPlaylistEnabled())

	self:TriggerWireOutput("Time", streamObj:GetMasterTime())
	self:TriggerWireOutput("Length", streamObj:GetMasterLength())
	self:TriggerWireOutput("Ended", streamObj:HasEnded())
	self:TriggerWireOutput("3D Sound", self:GetSound3D())
	self:TriggerWireOutput("Stream Name", streamObj:GetStreamName())
	self:TriggerWireOutput("Stream URL", streamObj:GetURL())

	self:TriggerWireOutput("Advanced Outputs", hasadvoutputs)
	self:TriggerWireOutput("Playing", streamObj:IsPlaying())
	self:TriggerWireOutput("Loading", streamObj:IsLoading() or streamObj:IsBuffering() or streamObj:IsSeeking())

	self:TriggerWireOutput("Tag", {}) -- @TODO
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

		self.ExtraURLs.Tool = self.ExtraURLs.Tool or ""
		self.ExtraURLs.Wire = self.ExtraURLs.Wire or ""
		self.ExtraURLs.Mode = self.ExtraURLs.Mode or ""

		self.ActivateExtraURL = self.ExtraURLs[self.ExtraURLs.Mode] or ""
		self.ActivateExtraName = self.ExtraNames[self.ExtraURLs.Mode] or ""

		self:SetToolMode(self.ExtraURLs.Tool ~= "")
		self:SetWireMode(self.ExtraURLs.Wire ~= "")

		if oldActivateURL ~= self.ActivateExtraURL or oldActivateName ~= self.ActivateExtraName then
			self:OnExtraURLUpdate()
		end
	end

	if IsValid(self.StreamObj) then
		self.StreamObj:SetBASSEngineEnabled(self:CanHaveSpectrum())

		-- Loop the song also when we are in playlist mode without a playlist. We pretend we have a playlist with a single item.
		local shouldLoop = self:GetLoop() or (not self:IsPlaylistEnabled() and self:GetPlaylistLoop())

		self.StreamObj:SetLoop(shouldLoop)
	end

	self:PlaybackLoopModeThink()
	self:PanelThink()

	return true
end

function ENT:OnExtraURLUpdate()
	local name = self.ActivateExtraName
	local urlForDisplay = self.ActivateExtraURL

	if StreamRadioLib.Util.IsBlockedURLCode(urlForDisplay) then
		urlForDisplay = "(Blocked URL)"
	end

	if urlForDisplay ~= "" then
		name = name .. ": " .. urlForDisplay
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
end

function ENT:SetToolURL(url, setmode)
	if not g_isLoaded then return end

	self.ExtraURLs.Tool = StreamRadioLib.Util.FilterCustomURL(url)

	if not setmode and self.ExtraURLs.Mode == "Tool" then
		self.ExtraURLs.Mode = ""
	end

	if setmode and (self.ExtraURLs.Mode == "" or self.ExtraURLs.Mode == "Tool") then
		self.ActivateExtraName = ""
		self:OnToolMode()
	end
end

function ENT:GetToolURL(url)
	return self.ExtraURLs.Tool
end

function ENT:SetWireURL(url, setmode)
	if not g_isLoaded then return end

	self.ExtraURLs.Wire = StreamRadioLib.Util.FilterCustomURL(url)

	if setmode then
		self.ActivateExtraName = ""
		self:OnWireMode()
	end
end

function ENT:GetWireURL(url)
	return self.ExtraURLs.Wire
end

function ENT:OnToolMode()
	self.ExtraURLs.Mode = "Tool"
end

function ENT:OnWireMode()
	self.ExtraURLs.Mode = "Wire"
end

function ENT:OnExtraURL(name, url)
	if not IsValid(self.StreamObj) then
		return
	end

	if url == "" then
		self:_StopInternal()
		return
	end

	if IsValid(self.GUI_Main) then
		self.GUI_Main:EnablePlaylist(false)
		self.GUI_Main:Play(name, url)
		return
	end

	self.StreamObj:RemoveChannel(true)
	self.StreamObj:SetURL(url)
	self.StreamObj:SetStreamName(name)
	self.StreamObj:Play(true)
end

function ENT:_StopInternal()
	if not IsValid(self.StreamObj) then
		return
	end

	self.ExtraURLs = self.ExtraURLs or {}
	self.ExtraURLs.Mode = ""
	self.StreamObj:Stop()

	if IsValid(self.GUI_Main) then
		self.GUI_Main:Play("", "")
	end
end

function ENT:OnPlayerClosed()
	self:_StopInternal()
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
	self:_StopInternal()

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

		local addonTitle = StreamRadioLib.AddonTitle

		local message = string.format(
			"Network overflow/spam detected. Stream Radio '%s' removed! Owner: %s, Last user: %s.",
			tostring(self),
			getPlayerName(owner),
			getPlayerName(user)
		)

		local msgWithAddonTitle = addonTitle .. ": " .. message

		StreamRadioLib.Print.Msg(owner, msgWithAddonTitle)

		if user ~= owner then
			StreamRadioLib.Print.Msg(user, msgWithAddonTitle)
		end

		StreamRadioLib.Print.Log(logForPly, message)
	end

	BaseClass.NWOverflowKill(self)
end

function ENT:OnPreEntityCopy()
	self:SetDupeData("ExtraURLs", self.ExtraURLs)
end

function ENT:DupeDataApply(key, value)
	if key ~= "ExtraURLs" then return end

	local wireurl = self.ExtraURLs.Wire or ""
	self.ExtraURLs = value
	self.ExtraURLs.Wire = wireurl
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

		local hasTool = self:GetToolMode()
		local hasWire = self:GetWireMode()

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

	if name == "LoopMode" then
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
