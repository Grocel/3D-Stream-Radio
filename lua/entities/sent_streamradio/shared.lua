AddCSLuaFile()
DEFINE_BASECLASS( "base_streamradio_gui" )

local StreamRadioLib = StreamRadioLib
local LIBWire = StreamRadioLib.Wire

local g_isLoaded = StreamRadioLib and StreamRadioLib.Loaded
local g_isWiremodLoaded = g_isLoaded and LIBWire.HasWiremod()

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Editable = true

ENT.PrintName = "Stream Radio"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.WireDebugName = ENT.PrintName

ENT.Sounds_Tune = Sound("buttons/lightswitch2.wav")
ENT.Sounds_Noise = Sound("stream_radio/noise.wav")
ENT.Sounds_Use = Sound("common/wpn_select.wav")

function ENT:SetupDataTables( )
	if not g_isLoaded then return end
	BaseClass.SetupDataTables(self)

	self:AddDTNetworkVar("Bool", "WireMode")
	self:AddDTNetworkVar("Bool", "ToolMode")
	self:AddDTNetworkVar("Entity", "MasterRadio")

	local adv_wire = nil

	if g_isWiremodLoaded then
		adv_wire = {
			KeyName = "DisableAdvancedOutputs",
			Edit = {
				category = "Wiremod",
				title = "Disable advanced outputs",
				type = "Boolean",
				order = 70,
			}
		}
	end

	self:AddDTNetworkVar("Bool", "DisableAdvancedOutputs", adv_wire)

	self:AddDTNetworkVar("Bool", "SVMute", {
		KeyName = "SVMute",
		Edit = {
			category = "Volume",
			title = "Entity Mute",
			type = "Boolean",
			order = 20
		}
	})

	self:AddDTNetworkVar("Float", "Volume", {
		KeyName = "Volume",
		Edit = {
			category = "Volume",
			title = "Entity Volume",
			type = "Float",
			order = 21,
			min = 0,
			max = 1,
		}
	})

	self:AddDTNetworkVar("Int", "Radius", {
		KeyName = "Radius",
		Edit = {
			category = "World Sound",
			title = "Radius",
			type = "Int",
			order = 30,
			min = 0,
			max = 5000,
		}
	})

	self:AddDTNetworkVar("Bool", "Sound3D", {
		KeyName = "Sound3D",
		Edit = {
			category = "World Sound",
			title = "Enable 3D sound",
			type = "Boolean",
			order = 31
		}
	})

	self:AddDTNetworkVar("Bool", "Loop", {
		KeyName = "Loop",
		Edit = {
			category = "Loop",
			title = "Enable song loop",
			type = "Boolean",
			order = 40
		}
	})

	self:AddDTNetworkVar( "Bool", "PlaylistLoop", {
		KeyName = "PlaylistLoop",
		Edit = {
			category = "Loop",
			title = "Enable playlist loop",
			type = "Boolean",
			order = 41
		}
	})

	self:AddDTNetworkVar("Bool", "CLMute", {
		KeyName = "CLMute",
		Edit = {
			category = "Volume",
			title = "Clientside Mute",
			type = "Boolean",
			order = 22,
		}
	})

	self:AddDTNetworkVar("Float", "CLVolume", {
		KeyName = "CLVolume",
		Edit = {
			category = "Volume",
			title = "Clientside Volume",
			type = "Float",
			order = 23,
			min = 0,
			max = 1,
		}
	})

	self._radio_EditValue = self._radio_EditValue or self.EditValue
	self.EditValue = function(this, variable, value)
		-- This workaround allows for clientonly traffic on those data table vars. 

		if variable == "CLMute" then
			if SERVER then
				return
			end

			local mute = tobool(value)
			this:SetCLMute(mute)

			return
		end

		if variable == "CLVolume" then
			if SERVER then
				return
			end

			local volume = tonumber(value or 0) or 0
			this:SetCLVolume(volume)

			return
		end

		return this:_radio_EditValue(variable, value)
	end

	self:SetDTVarCallback("Loop", function(this, name, oldv, newv)
		if newv and SERVER then
			self:SetPlaylistLoop(false)
		end

		self:MarkForUpdatePlaybackLoopMode()
	end)

	self:SetDTVarCallback("PlaylistLoop", function(this, name, oldv, newv)
		if newv and SERVER then
			self:SetLoop(false)
		end

		self:MarkForUpdatePlaybackLoopMode()
	end)
end

function ENT:GetPlaybackLoopMode()
	local loop = self:GetLoop()
	local playlistLoop = self:GetPlaylistLoop()

	if loop then
		return StreamRadioLib.PLAYBACK_LOOP_MODE_SONG
	end

	if playlistLoop then
		return StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST
	end

	return StreamRadioLib.PLAYBACK_LOOP_MODE_NONE
end

function ENT:SetPlaybackLoopMode(loopMode)
	if CLIENT then return end

	self:SetLoop(false)
	self:SetPlaylistLoop(false)

	if loopMode == StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST then
		self:SetPlaylistLoop(true)
	elseif loopMode == StreamRadioLib.PLAYBACK_LOOP_MODE_SONG then
		self:SetLoop(true)
	end

	self:MarkForUpdatePlaybackLoopMode()
end

function ENT:MarkForUpdatePlaybackLoopMode()
	self._callUpdatePlaybackLoopMode = true
end

function ENT:UpdatePlaybackLoopMode()
	self._callUpdatePlaybackLoopMode = nil

	local loopMode = self:GetPlaybackLoopMode()
	local GUI_Main = self.GUI_Main

	if IsValid(GUI_Main) then
		GUI_Main:UpdatePlaybackLoopMode(loopMode)
	end

	self.OnUpdatePlaybackLoopMode(loopMode)
end

function ENT:OnUpdatePlaybackLoopMode(loopMode)
	-- Override me
end

function ENT:GetMasterRadioRecursive()
	if not g_isLoaded then
		self._supermasterradio = nil
		return nil
	end

	if IsValid(self._supermasterradio) and self._supermasterradio.__IsRadio and IsValid(self._supermasterradio.StreamObj) then
		return self._supermasterradio
	end

	self._supermasterradio = nil

	local nodouble = {}
	local function recursive(radio, count)
		if nodouble[radio] then return nil end
		nodouble[radio] = true

		if count <= 0 then
			return nil
		end

		local masterradio = radio:GetMasterRadio()
		if not IsValid(masterradio) then return radio end
		if not masterradio.__IsRadio then return radio end
		if not IsValid(masterradio.StreamObj) then return radio end

		return recursive(masterradio, count - 1)
	end

	local supermasterradio = recursive(self, 10)
	if supermasterradio == self then return nil end

	if not IsValid(supermasterradio) then return nil end
	if not supermasterradio.__IsRadio then return nil end
	if not IsValid(supermasterradio.StreamObj) then return nil end

	self._supermasterradio = supermasterradio
	return supermasterradio
end

function ENT:GetSlaveRadios()
	local mr = self:GetMasterRadioRecursive()
	if mr then
		self.slavesradios = nil
	end

	self.slavesradios = self.slavesradios or {}

	for slave, v in pairs(self.slavesradios) do
		if not IsValid(slave) then
			self.slavesradios[slave] = nil
			continue
		end

		if not slave.__IsRadio then
			self.slavesradios[slave] = nil
			continue
		end

		if not IsValid(slave.StreamObj) then
			self.slavesradios[slave] = nil
			continue
		end

		if slave == self then
			self.slavesradios[slave] = nil
			continue
		end

		local slavemasterradio = slave:GetMasterRadioRecursive()
		if slavemasterradio ~= self then
			self.slavesradios[slave] = nil
			continue
		end
	end

	return self.slavesradios
end

function ENT:IsMutedForPlayer(ply)
	local muted = BaseClass.IsMutedForPlayer(self, ply)
	if not muted then return false end

	local slaves = self:GetSlaveRadios()

	for slave, v in pairs(slaves) do
		if not IsValid(slave) then continue end
		if not slave:IsMutedForPlayer(ply) then return false end
	end

	return true
end

function ENT:OnGUIShowCheck(ply)
	local masterradio = self:GetMasterRadioRecursive()
	if not masterradio then return true end

	local master_st = masterradio.StreamObj

	if master_st:HasError() then return true end
	if not master_st:IsStopMode() then return true end
	if master_st:GetURL() ~= "" then return true end

	if master_st:IsRunning() then return true end

	return false
end

function ENT:OnGUIInteractionCheck(ply, trace, userEntity)
	local masterradio = self:GetMasterRadioRecursive()
	if not masterradio then return true end

	local master_st = masterradio.StreamObj

	if master_st:HasError() then return true end
	if not master_st:IsStopMode() then return true end
	if master_st:GetURL() ~= "" then return true end

	if master_st:IsRunning() then return true end

	return false
end

function ENT:MasterRadioSyncThink()
	if not self.old then return end

	local GUI_Main = self.GUI_Main
	local masterradio = self:GetMasterRadioRecursive()
	local oldmasterradio = self.old.masterradio
	local statechange = false

	if masterradio ~= oldmasterradio then
		statechange = true

		if not masterradio then
			if IsValid(GUI_Main) then
				GUI_Main:SetSyncMode(false)
			end
		end

		if self.StopStreamInternal then
			self:StopStreamInternal()
		end

		if IsValid(oldmasterradio) and oldmasterradio.slavesradios then
			oldmasterradio.slavesradios[self] = nil
		end

		if IsValid(masterradio) and masterradio.slavesradios then
			masterradio.slavesradios[self] = true
		end

		if self.OnMasterradioChange then
			self:OnMasterradioChange(masterradio, oldmasterradio)
		end
	end

	self.old.masterradio = masterradio
	if not masterradio then return end

	local this_st = self.StreamObj
	if not IsValid(this_st) then return end

	local master_st = masterradio.StreamObj
	if not IsValid(master_st) then return end

	self:SetPlaybackLoopMode(masterradio:GetPlaybackLoopMode())

	local name = master_st:GetStreamName()
	local url = master_st:GetURL()
	local playingstate = master_st:GetPlayingState()

	if name ~= this_st:GetStreamName() then
		this_st:SetStreamName(name)
		statechange = true
	end

	if url ~= this_st:GetURL() or statechange then
		this_st:SetURL(url)
		this_st:Update()
		statechange = true
	end

	this_st:SetPlayingState(playingstate)

	if statechange and IsValid(GUI_Main) then
		GUI_Main:SetSyncMode(true)

		GUI_Main:EnablePlaylist(false)
		GUI_Main:Play(name, url)
	end

	if SERVER then
		if statechange then
			self._lastMasterTime = nil
		end

		local targettime = master_st:GetMasterTime()
		local tickInterval = engine.TickInterval()

		local lastTargetTime = self._lastMasterTime;
		self._lastMasterTime = targettime

		local masterDelta = nil
		if lastTargetTime then
			masterDelta = math.abs(targettime - lastTargetTime)
		end

		local maxThisDelta = tickInterval * 2
		local maxMasterDelta = tickInterval * 4
		local realTime = RealTime()

		if statechange or (self._trySetTimeAgain and realTime > self._trySetTimeAgain) or (not masterDelta or masterDelta > maxMasterDelta) then
			this_st:SetTime(targettime, true)

			local thisCurtime = this_st:GetMasterTime()
			local thisDelta = math.abs(thisCurtime - targettime)

			if thisDelta > maxThisDelta then
				self._trySetTimeAgain = realTime + tickInterval * 8
			else
				self._trySetTimeAgain = nil
			end
		end
	end

	self._supermasterradio = nil
end

function ENT:PlaybackLoopModeThink()
	if not self._callUpdatePlaybackLoopMode then
		return
	end

	self:UpdatePlaybackLoopMode()
end

function ENT:PanelThink()
	local GUI_Main = self.GUI_Main

	if not IsValid(GUI_Main) then
		return
	end

	local GUI_Main_Browser = GUI_Main.Browser
	if not IsValid(GUI_Main_Browser) then
		return
	end

	local ToolButton = GUI_Main_Browser.ToolButton
	local WireButton = GUI_Main_Browser.WireButton

	if IsValid(ToolButton) then
		local hasTool = self:GetToolMode()
		ToolButton:SetEnabled(hasTool)
	end

	if IsValid(WireButton) then
		local hasWire = self:GetWireMode()
		WireButton:SetEnabled(hasWire)
	end
end

function ENT:OnToolButtonClick()
	local hasTool = self:GetToolMode()
	if not hasTool then return end
	if not self.OnToolMode then return end

	self:OnToolMode()
end

function ENT:OnWireButtonClick()
	local hasWire = self:GetWireMode()
	if not hasWire then return end
	if not g_isWiremodLoaded then return end
	if not self.OnWireMode then return end

	self:OnWireMode()
end

function ENT:StreamStopAnimModel()
	if not self.AnimStopped then
		if CLIENT then
			self:CallModelFunction("Speaker")
			self:CallModelFunction("Beat")
			self:CallModelFunction("FFT")
			self:CallModelFunction("SoundLevel")
		end

		self:CallModelFunction("AnimReset")
	end

	if self.old then
		self.old.beatlevel = nil
	end

	self.AnimStopped = true
end

function ENT:OnGUISetup(...)
	BaseClass.OnGUISetup(self, ...)

	local GUI_Main = self.GUI_Main

	if not IsValid(GUI_Main) then
		return
	end

	GUI_Main.OnPlaybackLoopModeChange = function(this, newLoopMode)
		if not IsValid(self) then return end
		self:SetPlaybackLoopMode(newLoopMode)
	end

	self:MarkForUpdatePlaybackLoopMode()
end

function ENT:OnModelSetup()
	self.AnimStopped = nil
	self:StreamStopAnimModel()
end

function ENT:OnRemoveShared()
end
