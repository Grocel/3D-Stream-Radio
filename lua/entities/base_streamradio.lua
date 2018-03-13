AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

local WireLib = WireLib

local IsValid = IsValid
local Vector = Vector
local Angle = Angle
local pairs = pairs
local CurTime = CurTime
local tobool = tobool
local istable = istable
local Model = Model
local Sound = Sound

local NULL = NULL
local TRANSMIT_PVS = TRANSMIT_PVS
local TRANSMIT_ALWAYS = TRANSMIT_ALWAYS

local math = math
local string = string
local ents = ents
local util = util
local timer = timer
local SERVER = SERVER
local CLIENT = CLIENT

ENT.__IsRadio = true
ENT.__IsLibLoaded = StreamRadioLib and StreamRadioLib.Loaded
ENT.__IsWiremodLoaded = ENT.__IsLibLoaded and StreamRadioLib.HasWiremod()

ENT.Editable = false
ENT.Spawnable = false
ENT.AdminOnly = false

ENT.WireDebugName = "Stream Radio"

function ENT:AddDTNetworkVar(datatype, name, ...)
	if not self.__IsLibLoaded then
		return
	end

	return StreamRadioLib.Network.AddDTNetworkVar(self, datatype, name, ...)
end

function ENT:SetupDataTables()
	if not self.__IsLibLoaded then
		return
	end

	StreamRadioLib.Network.SetupDataTables(self)
end

function ENT:SetAnim( Animation, Frame, Rate )
	if not self.Animated or not self.AutomaticFrameAdvance then
		-- This must be run once on entities that will be animated
		self.Animated = true
		self:SetAutomaticFrameAdvance(true)
	end

	self:ResetSequence( Animation or 0 )
	self:SetCycle( Frame or 0 )
	self:SetPlaybackRate( Rate or 1 )
end

function ENT:EmitSoundIfExist( name, ... )
	name = name or ""
	if ( name == "" ) then
		return
	end

	self:EmitSound( name, ... )
end

function ENT:RegisterDupePose( name )
	self.DupePoses = self.DupePoses or {}
	self.DupePoses[name] = true
end

function ENT:GetDupePoses()
	self.DupePoses = self.DupePoses or {}

	local PoseParameter = {}
	for name, value in pairs( self.DupePoses ) do
		if ( not value ) then continue end
		PoseParameter[name] = self:GetPoseParameter( name )
	end

	return PoseParameter
end

function ENT:SetDupePoses( PoseParameter )
	PoseParameter = PoseParameter or {}

	for name, value in pairs( PoseParameter ) do
		if ( not value ) then continue end
		self:SetPoseParameter( name, value )
	end
end

function ENT:CreateStream()
	if not self.__IsLibLoaded then
		if IsValid(self.StreamObj) then
			self.StreamObj:Remove()
		end

		self.StreamObj = nil
		return nil
	end

	if IsValid(self.StreamObj) then
		return self.StreamObj
	end

	self.StreamObj = StreamRadioLib.CreateOBJ("stream")
	if not IsValid( self.StreamObj ) then
		self.StreamObj = nil
		return nil
	end

	local function call(name, ...)
		if not IsValid( self ) then
			return
		end

		local func = self[name]

		if not isfunction(func) then
			return nil
		end

		return func(self, ...)
	end

	self.StreamObj.OnConnect = function( ... )
		return call("StreamOnConnect", ...)
	end

	self.StreamObj.OnError = function( ... )
		return call("StreamOnError", ...)
	end

	self.StreamObj.OnClose = function( ... )
		return call("StreamOnClose", ...)
	end

	self.StreamObj.OnRetry = function( ... )
		return call("StreamOnRetry", ...)
	end

	self.StreamObj.OnSearch = function( ... )
		return call("StreamOnSearch", ...)
	end

	self.StreamObj.OnMute = function( ... )
		return call("StreamOnMute", ...)
	end

	self.StreamObj:SetEvent("OnPlayModeChange", tostring(self) .. "_base", function(...)
		return call("StreamOnPlayModeChange", ...)
	end)

	self.StreamObj:SetName("stream")
	self.StreamObj:SetEntity(self)
	self.StreamObj:ActivateNetworkedMode()
	self.StreamObj:OnClose()
	return self.StreamObj
end

function ENT:StreamOnConnect()
	self:CheckTransmitState()
	return true
end

function ENT:StreamOnSearch()
	self:CheckTransmitState()
	return true
end

function ENT:StreamOnRetry()
	self:CheckTransmitState()
	return true
end

function ENT:StreamOnError()
	self:CheckTransmitState()
end

function ENT:StreamOnClose()
	self:CheckTransmitState()
end

function ENT:StreamOnPlayModeChange()
	self:CheckTransmitState()
end

function ENT:IsStreaming()
	if not IsValid( self.StreamObj ) then
		return false
	end

	if not IsValid( self.StreamObj:GetChannel() ) then
		return false
	end

	return true
end

function ENT:HasStream()
	if not IsValid( self.StreamObj ) then
		return false
	end

	return true
end

function ENT:GetStreamObject()
	if not self:HasStream() then
		return nil
	end

	return self.StreamObj
end

local ang_zero = Angle()
function ENT:SetSoundPosAng(pos, ang)
	self.SoundPosOffset = pos
	self.SoundAngOffset = ang
end

function ENT:GetSoundPosAng()
	local pos = self:GetPos()
	local ang = self:GetAngles()

	local stream = self.StreamObj
	local channeltext = "no sound"

	if stream then
		channeltext = tostring(stream)
	end

	if not self.SoundPosOffset then
		debugoverlay.Axis(pos, ang, 5, 0.05, color_white)
		debugoverlay.EntityTextAtPosition(pos, 1, "Sound pos: " .. channeltext, 0.05, color_white)

		return pos, ang
	end

	pos, ang = LocalToWorld(self.SoundPosOffset, self.SoundAngOffset or ang_zero, pos, ang)

	debugoverlay.Axis(pos, ang, 5, 0.05, color_white)
	debugoverlay.EntityTextAtPosition(pos, 1, "Sound pos: " .. channeltext, 0.05, color_white)

	return pos, ang
end

function ENT:DistanceToPlayer(ply, pos1, pos2)
	if not pos1 then
		pos1 = self:GetSoundPosAng()
	end

	if pos2 then
		return pos2:Distance(pos1)
	end

	if self.__IsLibLoaded then
		pos2 = StreamRadioLib.GetCameraPos(ply)
	end

	if not pos2 then
		return 0
	end

	return pos2:Distance(pos1)
end

function ENT:Initialize()
	if self.__IsLibLoaded then
		StreamRadioLib.SpawnedRadios[self] = true
	end

	if SERVER then
		self.WireOutputCache = {}
	end

	self:CreateStream()

	self:CheckTransmitState()
end

function ENT:OnTakeDamage( dmg )
	self:TakePhysicsDamage( dmg )
end

function ENT:OnReloaded()
	if CLIENT then return end
	self:Remove()
end

function ENT:IsMutedForPlayer(ply)
	if not self.__IsLibLoaded then
		return true
	end

	if StreamRadioLib.IsMuted(ply) then
		return true
	end

	local playerdist = self:DistanceToPlayer(ply)
	local mutedist = math.min(self:GetRadius() + 1000, StreamRadioLib.GetMuteDistance(ply))

	if playerdist >= mutedist then
		return true
	end

	return false
end

function ENT:IsMutedForAll()
	if not self.__IsLibLoaded then
		return true
	end

	local allplayers = player.GetHumans()

	for k, v in pairs(allplayers) do
		if not IsValid(v) then continue end

		local muted = self:IsMutedForPlayer(v)
		if muted then continue end

		return false
	end

	return true
end

function ENT:CheckTransmitState()
	if CLIENT then return end

	self._TransmitCheck = true
	self._LastTransmitCheck = CurTime()
end

function ENT:UpdateTransmitState()
	local stream = self.StreamObj

	if not IsValid(stream) then
		return TRANSMIT_PVS
	end

	if stream:IsStopMode() then return TRANSMIT_PVS end
	if stream:GetURL() == "" then return TRANSMIT_PVS end
	if self:IsMutedForAll() then return TRANSMIT_PVS end

	return TRANSMIT_ALWAYS
end

function ENT:PostFakeRemove( )
	if not self.__IsLibLoaded then
		return nil
	end

	StreamRadioLib.SpawnedRadios[self] = true
end

function ENT:OnRemove()
	local Stream = self.StreamObj
	timer.Simple( 0.05, function()
		if IsValid(self) then
			self:PostFakeRemove()
			return
		end

		if IsValid(Stream) then
			Stream:Remove()
			Stream = nil
		end
	end)

	if self.__IsLibLoaded then
		StreamRadioLib.SpawnedRadios[self] = nil
	end

	if self.__IsWiremodLoaded and SERVER then
		WireLib.Remove(self)
	end

	BaseClass.OnRemove(self)
end

function ENT:DormantThink()
	-- Override me
end

function ENT:FastThink()
	if not self.__IsLibLoaded then
		return
	end

	StreamRadioLib.Network.Pull(self)

	if SERVER then
		if self.__IsWiremodLoaded then
			self:WiremodThink()
		end

		return
	end

	if IsValid( self.StreamObj ) then
		local pos, ang = self:GetSoundPosAng()
		self.StreamObj:Set3DPosition(pos, ang:Forward())
	end
end

function ENT:Think()
	BaseClass.Think(self)

	local curtime = CurTime()

	if SERVER then
		if self._TransmitCheck then
			self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
			self._TransmitCheck = nil
		end

		if curtime >= ((self._LastTransmitCheck or 0) + 2.5) then
			self:CheckTransmitState()
		end

		self:NextThink(curtime + 0.1)
		return true
	end

	if self.__IsWiremodLoaded then
		if curtime >= (self._NextRBUpdate or 0) then
			self._NextRBUpdate = curtime + math.random(30, 100) / 10
			Wire_UpdateRenderBounds(self)
		end
	end

	return true
end

function ENT:GetStreamURL()
	if not IsValid(self.StreamObj) then return "" end
	return self.StreamObj:GetURL()
end

function ENT:GetStreamName()
	if not IsValid(self.StreamObj) then return "" end
	return self.StreamObj:GetStreamName()
end

if SERVER then
	function ENT:SetStreamURL(...)
		if not IsValid(self.StreamObj) then return end

		self.StreamObj:SetURL(...)
	end

	function ENT:SetStreamName(...)
		if not IsValid(self.StreamObj) then return end
		self.StreamObj:SetStreamName(...)
	end
end

if CLIENT then
	function ENT:DrawTranslucent()
		self:DrawModel()

		if not self.__IsWiremodLoaded then return end
		Wire_Render(self)
	end

	return
else
	function ENT:WiremodThink()
		-- Override me
	end

	function ENT:AddWireInput(name, ptype, desc)
		if not self.__IsWiremodLoaded then return end

		name = string.Trim(tostring(name or ""))
		ptype = string.upper(string.Trim(tostring(ptype or "NORMAL")))
		desc = string.Trim(tostring(desc or ""))

		self._wireports = self._wireports or {}
		self._wireports.In = self._wireports.In or {}
		self._wireports.In.names = self._wireports.In.names or {}
		self._wireports.In.types = self._wireports.In.types or {}
		self._wireports.In.descs = self._wireports.In.descs or {}

		self._wireports.In.once = self._wireports.In.once or {}
		if(self._wireports.In.once[name]) then return end

		self._wireports.In.names[#self._wireports.In.names + 1] = name
		self._wireports.In.types[#self._wireports.In.types + 1] = ptype
		self._wireports.In.descs[#self._wireports.In.descs + 1] = desc
		self._wireports.In.once[name] = true
	end

	function ENT:AddWireOutput(name, ptype, desc)
		if not self.__IsWiremodLoaded then return end

		name = string.Trim(tostring(name or ""))
		ptype = string.upper(string.Trim(tostring(ptype or "NORMAL")))
		desc = string.Trim(tostring(desc or ""))

		self._wireports = self._wireports or {}
		self._wireports.Out = self._wireports.Out or {}
		self._wireports.Out.names = self._wireports.Out.names or {}
		self._wireports.Out.types = self._wireports.Out.types or {}
		self._wireports.Out.descs = self._wireports.Out.descs or {}

		self._wireports.Out.once = self._wireports.Out.once or {}
		if(self._wireports.Out.once[name]) then return end

		self._wireports.Out.names[#self._wireports.Out.names + 1] = name
		self._wireports.Out.types[#self._wireports.Out.types + 1] = ptype
		self._wireports.Out.descs[#self._wireports.Out.descs + 1] = desc
		self._wireports.Out.once[name] = true
	end

	function ENT:InitWirePorts()
		if not self.__IsWiremodLoaded then return end

		if not self._wireports then return end

		if self._wireports.In then
			self.Inputs = WireLib.CreateSpecialInputs(self, self._wireports.In.names, self._wireports.In.types, self._wireports.In.descs)
		end

		if self._wireports.Out then
			self.Outputs = WireLib.CreateSpecialOutputs(self, self._wireports.Out.names, self._wireports.Out.types, self._wireports.Out.descs)
		end

		self._wireports = nil
	end

	function ENT:IsConnectedInputWire(name)
		if not self.__IsWiremodLoaded then return false end
		if not istable(self.Inputs) then return false end

		local wireinput = self.Inputs[name]
		if not istable(wireinput) then return false end
		if not IsValid(wireinput.Src) then return false end

		return true
	end

	function ENT:IsConnectedOutputWire(name)
		if not self.__IsWiremodLoaded then return false end
		if not istable(self.Outputs) then return false end
		local wireoutput = self.Outputs[name]

		if not istable(wireoutput) then return false end
		if not istable(wireoutput.Connected) then return false end
		if not istable(wireoutput.Connected[1]) then return false end
		if not IsValid(wireoutput.Connected[1].Entity) then return false end

		return true
	end

	function ENT:IsConnectedWirelink()
		return self:IsConnectedOutputWire("wirelink");
	end

	function ENT:TriggerWireOutput(name, value)
		if not self.__IsWiremodLoaded then return end

		if isbool(value) or value == nil then
			value = value and 1 or 0
		end

		if value == self.WireOutputCache[name] and not istable(value) then return end
		self.WireOutputCache[name] = value

		WireLib.TriggerOutput(self, name, value)
	end

	function ENT:TriggerInput(name, value)
		local wired = self:IsConnectedInputWire(name) or self:IsConnectedWirelink()
		self:OnWireInputTrigger(name, value, wired)
	end

	function ENT:OnWireInputTrigger(name, value)
		-- Override me
	end

	function ENT:OnRestore()
		if not self.__IsWiremodLoaded then return end

		WireLib.Restored( self )
	end

	function ENT:SetDupeData(key, value)
		self.DupeData = self.DupeData or {}
		self.DupeData[key] = value
	end

	function ENT:GetDupeData(key)
		self.DupeData = self.DupeData or {}
		return self.DupeData[key]
	end

	function ENT:OnEntityCopyTableFinish(data)
		for k, v in pairs(data) do
			if isfunction(v) then
				data[k] = nil
				continue
			end

			if isstring(k) and #k > 0 and k[1] == "_" then
				data[k] = nil
				continue
			end
		end

		data.__IsRadio = self.__IsRadio
		data.__IsLibLoaded = self.__IsLibLoaded
		data.__IsWiremodLoaded = self.__IsWiremodLoaded

		data.Inputs = nil
		data.Outputs = nil

		data.StreamObj = nil
		data.pl = nil
		data.Owner = nil

		data.old = nil
		data.WireOutputCache = nil

		if self.OnSetupCopyData then
			self:OnSetupCopyData(data)
		end
	end

	function ENT:PreEntityCopy()
		if self.__IsWiremodLoaded then
			self:SetDupeData("Wire", WireLib.BuildDupeInfo(self))
		end

		local classsystem_objs = {}

		for k, v in pairs(self._3dstreamradio_classobjs or {}) do
			if not IsValid(v) then continue end

			local name = v:GetName()
			local ent = v:GetEntity()
			if ent ~= self then continue end

			local func = v.PreDupe
			if not func then continue end

			classsystem_objs[name] = func(v, self)
		end

		self:SetDupeData("Classsystem", classsystem_objs)

		self:SetDupeData("Skin", {
			Color = self:GetColor(),
			Skin = self:GetSkin(),
		})

		self:SetDupeData("DupePoses", self:GetDupePoses())

		if self.OnPreEntityCopy then
			self:OnPreEntityCopy()
		end

		duplicator.StoreEntityModifier(self, "DupeData", self.DupeData)
	end

	function ENT:PostEntityPaste( ply, ent, CreatedEntities )
		if not IsValid(ent) then return end
		if not ent.EntityMods then return end

		ent.DupeData = ent.EntityMods.DupeData or {}

		ent._WireData = ent.DupeData.Wire
		ent.DupeData.Wire = nil

		if self.__IsWiremodLoaded and ent._WireData then
			timer.Simple(0.2, function()
				if not IsValid(ent) then return end
				if not ent._WireData then return end

				WireLib.ApplyDupeInfo(ply, ent, ent._WireData, function(id)
					return CreatedEntities[id]
				end)

				ent._WireData = nil
			end)
		end

		ent._3dstreamradio_classobjs_data = ent.DupeData.Classsystem
		ent.DupeData.Classsystem = nil

		if ent._3dstreamradio_classobjs_data and ent.PostClasssystemPaste then
			timer.Simple(0.1, function()
				if not IsValid(ent) then return end
				if not ent._3dstreamradio_classobjs_data then return end
				if not ent.PostClasssystemPaste then return end

				ent:PostClasssystemPaste()
			end)
		end

		if ent.DupeData.Skin then
			ent:SetSkin(ent.DupeData.Skin.Skin or 0)
			ent:SetColor(ent.DupeData.Skin.Color or color_white)
		end

		ent.DupeData.Skin = nil

		ent:SetDupePoses(ent.DupeData.DupePoses)
		ent.DupeData.DupePoses = nil

		if not ent.DupeDataApply then return end

		for key, value in pairs(ent.DupeData) do
			ent:DupeDataApply(key, value)
		end
	end

	function ENT:PostClasssystemPaste()
		if not IsValid(self.StreamObj) then return end
		self.StreamObj:LoadFromDupe()
	end
end
