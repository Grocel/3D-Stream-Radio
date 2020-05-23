AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

DEFINE_BASECLASS( "base_streamradio_gui" )

ENT.ModelVar = Model( "models/sligwolf/grocel/radio/radio.mdl" )

function ENT:Initialize( )
	self:SetModel( Model( self.ModelVar or "models/sligwolf/grocel/radio/radio.mdl" ) )
	self:SetUseType( SIMPLE_USE )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

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

	BaseClass.Initialize( self )

	if self.__IsLibLoaded then
		StreamRadioLib._AllowSpectrumCountCache = nil
	end

	self:AddWireInput("Play", "NORMAL")
	self:AddWireInput("Pause", "NORMAL")
	self:AddWireInput("Volume", "NORMAL")
	self:AddWireInput("Radius", "NORMAL")
	self:AddWireInput("Loop", "NORMAL")
	self:AddWireInput("Time", "NORMAL")
	self:AddWireInput("3D Sound", "NORMAL")
	self:AddWireInput("Stream URL", "STRING")
	self:AddWireInput("Master Radio", "ENTITY", "For synchronizing radios")


	self:AddWireOutput("Play", "NORMAL")
	self:AddWireOutput("Paused", "NORMAL")
	self:AddWireOutput("Stopped", "NORMAL")
	self:AddWireOutput("Volume", "NORMAL")
	self:AddWireOutput("Radius", "NORMAL")
	self:AddWireOutput("Loop", "NORMAL")
	self:AddWireOutput("Time", "NORMAL")
	self:AddWireOutput("Length", "NORMAL")
	self:AddWireOutput("Ended", "NORMAL")
	self:AddWireOutput("3D Sound", "NORMAL")
	self:AddWireOutput("Stream Name", "STRING")
	self:AddWireOutput("Stream URL", "STRING")

	self:AddWireOutput("Advanced Outputs", "NORMAL")
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
end

function ENT:SetSettings(settings)
	if not self.__IsLibLoaded then return end
	settings = settings or {}

	settings.StreamUrl = settings.StreamUrl or ""
	settings.StreamName = settings.StreamName or ""

	if settings.StreamUrl ~= "" then
		self:SetStreamURL(settings.StreamUrl)
	end

	local sound3d = settings.Sound3D

	if sound3d == nil then
		sound3d = true
	end

	local noadvoutputs = settings.DisableAdvancedOutputs

	if noadvoutputs == nil then
		noadvoutputs = true
	end

	local playlistloop = settings.PlaylistLoop

	if playlistloop == nil then
		playlistloop = true
	end

	self:SetStreamName(settings.StreamName)

	self:SetVolume(settings.StreamVolume or 1)
	self:SetLoop(settings.StreamLoop or false)

	self:SetRadius(settings.Radius or 1200)
	self:SetSound3D(sound3d)
	self:SetPlaylistLoop(playlistloop)

	self:SetDisableDisplay(settings.DisableDisplay or false)
	self:SetDisableInput(settings.DisableInput or false)
	self:SetDisableAdvancedOutputs(noadvoutputs)
end

function ENT:GetSettings()
	local settings = {}
	if not self.__IsLibLoaded then return settings end

	settings.StreamUrl = self:GetStreamURL()
	settings.StreamName = self:GetStreamName()

	settings.StreamVolume = self:GetVolume()
	settings.StreamLoop = self:GetLoop()

	settings.Radius = self:GetRadius()
	settings.Sound3D = self:GetSound3D()
	settings.PlaylistLoop = self:GetPlaylistLoop()

	settings.DisableDisplay = self:GetDisableDisplay()
	settings.DisableInput = self:GetDisableInput()
	settings.DisableAdvancedOutputs = self:GetDisableAdvancedOutputs()

	return settings
end

function ENT:OnTakeDamage( dmg )
	self:TakePhysicsDamage( dmg )
end

function ENT:OnReloaded( )
	if not IsValid( self ) then return end
	if not self.__IsLibLoaded then return end

	local ply, model, pos, ang = self.pl, self:GetModel( ), self:GetPos( ), self:GetAngles( )
	StreamRadioLib.Msg( ply, "Reloaded " .. tostring( self ) )
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
	if not IsValid(self.StreamObj) then
		return
	end

	local volume_ent = self:GetVolume()
	local volume_stream = self.StreamObj:GetVolume()

	if volume_ent ~= self.old.Volume_ent then
		self.StreamObj:SetVolume(volume_ent)

		self.old.Volume_ent = volume_ent
		self.old.Volume_stream = volume_ent
		return
	end

	if volume_stream ~= self.old.Volume_stream then
		self:SetVolume(volume_stream)

		self.old.Volume_ent = volume_stream
		self.old.Volume_stream = volume_stream
		return
	end
end

function ENT:CanHaveSpectrum()
	if not self.__IsWiremodLoaded then return false end
	if not StreamRadioLib.AllowSpectrum() then return false end
	if self:GetDisableAdvancedOutputs() then return false end

	return true
end

function ENT:FastThink()
	BaseClass.FastThink(self)

	self:MasterRadioSyncThink()
	self:PanelThink()
	self:UpdateVolume()
end

function ENT:WiremodThink( )
	if not IsValid(self.StreamObj) then return end

	self._codec = self._codec or {}

	self._codec[1] = self.StreamObj:GetSamplingRate()
	self._codec[2] = self.StreamObj:GetBitsPerSample()
	self._codec[3] = self.StreamObj:GetAverageBitRate()
	self._codec[4] = self.StreamObj:GetType()

	self._spectrum = self._spectrum or {}

	local hasadvoutputs = self.StreamObj:IsBASSEngineEnabled()

	if self:IsConnectedOutputWire("Spectrum") or self:IsConnectedWirelink() then
		if hasadvoutputs then
			self.StreamObj:GetSpectrumTable(128, self._spectrum)
			self._spectrumfilled = true
		else
			if self._spectrumfilled then
				self._spectrum = {}
				self._spectrumfilled = nil
			end
		end
	else
		if self._spectrumfilled then
			self._spectrum = {}
			self._spectrumfilled = nil
		end

		if hasadvoutputs then
			self._spectrum[1] = "Standby mode: Connect to this Output to aktivate it."
		end
	end

	self:TriggerWireOutput("Play", self.StreamObj:IsPlayMode())
	self:TriggerWireOutput("Paused", self.StreamObj:IsPauseMode())
	self:TriggerWireOutput("Stopped", self.StreamObj:IsStopMode())
	self:TriggerWireOutput("Volume", self:GetVolume())
	self:TriggerWireOutput("Radius", self:GetRadius())
	self:TriggerWireOutput("Loop", self:GetLoop())
	self:TriggerWireOutput("Time", self.StreamObj:GetMasterTime())
	self:TriggerWireOutput("Length", self.StreamObj:GetMasterLength())
	self:TriggerWireOutput("Ended", self.StreamObj:HasEnded())
	self:TriggerWireOutput("3D Sound", self:GetSound3D())
	self:TriggerWireOutput("Stream Name", self.StreamObj:GetStreamName())
	self:TriggerWireOutput("Stream URL", self.StreamObj:GetURL())

	self:TriggerWireOutput("Advanced Outputs", hasadvoutputs)
	self:TriggerWireOutput("Playing", self.StreamObj:IsPlaying())
	self:TriggerWireOutput("Loading", self.StreamObj:IsLoading() or self.StreamObj:IsBuffering() or self.StreamObj:IsSeeking())

	self:TriggerWireOutput("Tag", {}) // todo
	self:TriggerWireOutput("Codec", self._codec)
	self:TriggerWireOutput("Spectrum", self._spectrum)
	self:TriggerWireOutput("Sound Level", self.StreamObj:GetAverageLevel())

	self:TriggerWireOutput("This Radio", self)

	if not hasadvoutputs then
		local err = self.StreamObj:GetError()
		self:TriggerWireOutput("Error", err)
		self:TriggerWireOutput("Error Text", StreamRadioLib.DecodeErrorCode(err))
	else
		self:TriggerWireOutput("Error", 500)
		self:TriggerWireOutput("Error Text", "Advanced outputs are disabled")
	end
end

function ENT:Think( )
	BaseClass.Think( self )

	if self.__IsLibLoaded then
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
				local name = self.ActivateExtraName

				if self.ActivateExtraURL ~= "" then
					name = name .. ": " .. self.ActivateExtraURL
				end

				self:OnExtraURL(name, self.ActivateExtraURL)
			end
		end

		if IsValid(self.StreamObj) then
			self.StreamObj:SetBASSEngineEnabled(self:CanHaveSpectrum())
			self.StreamObj:SetLoop(self:GetLoop())
		end
	end

	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:SetToolURL(url, setmode)
	if not self.__IsLibLoaded then return end

	self.ExtraURLs.Tool = StreamRadioLib.FilterCustomURL(url)

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
	if not self.__IsLibLoaded then return end

	self.ExtraURLs.Wire = StreamRadioLib.FilterCustomURL(url)

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

function ENT:OnRemove( )
	if self.__IsLibLoaded then
		StreamRadioLib._AllowSpectrumCountCache = nil
	end

	self:_StopInternal()
	BaseClass.OnRemove( self )
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

		if model ~= "" and util.IsValidModel(model) then
			self.ModelVar = model
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

	if name == "Loop" then
		value = tobool(value)

		if not wired then
			value = false
		end

		self:SetLoop(value)
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

		if delta < 0.25 then
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
