AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

local StreamRadioLib = StreamRadioLib

local LIBNetwork = StreamRadioLib.Network
local LIBWire = StreamRadioLib.Wire
local LIBUtil = StreamRadioLib.Util
local LIBHook = StreamRadioLib.Hook

local WireLib = WireLib

local g_isLoaded = StreamRadioLib and StreamRadioLib.Loaded
local g_isWiremodLoaded = g_isLoaded and LIBWire.HasWiremod()

ENT.__IsRadio = true

ENT.Editable = false
ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:AddDTNetworkVar(datatype, name, ...)
	if not g_isLoaded then
		return
	end

	return LIBNetwork.AddDTNetworkVar(self:GetTable(), datatype, name, ...)
end

function ENT:SetDTVarCallback(name, callback)
	if not g_isLoaded then
		return
	end

	LIBNetwork.SetDTVarCallback(self:GetTable(), name, function(...)
		if not IsValid(self) then
			return
		end

		callback(...)
	end)
end

function ENT:SetupDataTables()
	if not g_isLoaded then
		return
	end

	StreamRadioLib.RegisterRadio(self)
	LIBNetwork.SetupDataTables(self)

	self:AddDTNetworkVar( "Entity", "RadioOwner" )
	self:AddDTNetworkVar( "Entity", "LastUser" )
	self:AddDTNetworkVar( "Entity", "LastUsingEntity" )
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

function ENT:AddObjToNwRegister(obj)
	if not IsValid(obj) then return end

	obj:AddToNwRegister(self._3dstraemradio_classobjs_nw_register)
end

function ENT:GetOrCreateStream()
	if not g_isLoaded then
		if IsValid(self.StreamObj) then
			self.StreamObj:Remove()
		end

		self.StreamObj = nil
		return nil
	end

	if IsValid(self.StreamObj) then
		return self.StreamObj
	end

	self.StreamObj = nil

	local stream = StreamRadioLib.CreateOBJ("stream")
	if not IsValid( stream ) then
		return nil
	end

	self.StreamObj = stream

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

	stream.OnConnect = function( ... )
		return call("StreamOnConnect", ...)
	end

	stream.OnError = function( ... )
		return call("StreamOnError", ...)
	end

	stream.OnClose = function( ... )
		return call("StreamOnClose", ...)
	end

	stream.OnRetry = function( ... )
		return call("StreamOnRetry", ...)
	end

	stream.OnSearch = function( ... )
		return call("StreamOnSearch", ...)
	end

	stream.CanSkipUrlChecks = function( ... )
		return call("StreamCanSkipUrlChecks", ...)
	end

	stream.CanBypassUrlBlock = function( ... )
		return call("StreamCanBypassUrlBlock", ...)
	end

	stream.OnMute = function( ... )
		return call("StreamOnMute", ...)
	end

	stream.OnTrackEnd = function( ... )
		return call("StreamOnTrackEnd", ...)
	end

	stream:SetEvent("OnPlayModeChange", tostring(self) .. "_base", function(...)
		return call("StreamOnPlayModeChange", ...)
	end)

	stream:SetName("stream")
	stream:SetNWName("str")
	stream:SetEntity(self)

	self:AddObjToNwRegister(stream)

	stream:ActivateNetworkedMode()
	stream:OnClose()

	return stream
end

function ENT:StreamOnConnect()
	self:CheckTransmitState()

	return true
end

function ENT:StreamOnSearch()
	self:CheckTransmitState()

	return true
end

function ENT:StreamCanSkipUrlChecks()
	return false
end

function ENT:StreamCanBypassUrlBlock(blockedByHook)
	if blockedByHook then
		-- was blocked by external code
		return false
	end

	if not StreamRadioLib.IsUrlWhitelistAdminRadioTrusted() then
		return false
	end

	local owner = self:GetRealRadioOwner()
	if LIBUtil.IsAdmin(owner) then
		-- Admins are allowed to bypass built-in whitelisting for better UX.
		return true
	end

	return false
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

function ENT:SetSoundPosAngOffset(pos, ang)
	self.SoundPosOffset = pos
	self.SoundAngOffset = ang
end

function ENT:GetSoundPosAngOffset()
	return self.SoundPosOffset, self.SoundAngOffset
end

local ang_zero = Angle()
local vec_zero = Vector()

function ENT:CalcSoundPosAngWorld()
	local pos = self:GetPos()
	local ang = self:GetAngles()

	local spos, sang = LocalToWorld(self.SoundPosOffset or vec_zero, self.SoundAngOffset or ang_zero, pos, ang)

	self.SoundPos = spos
	self.SoundAng = sang

	return spos, sang
end

function ENT:DistanceToEntity(ent, pos1, pos2)
	if not g_isLoaded then
		return 0
	end

	if not pos1 then
		pos1 = self.SoundPos
	end

	if not pos1 then
		return 0
	end

	if pos2 then
		return pos2:Distance(pos1)
	end

	pos2 = StreamRadioLib.GetCameraPos(ent)

	if not pos2 then
		return 0
	end

	return pos2:Distance(pos1)
end

function ENT:DistToSqrToEntity(ent, pos1, pos2)
	if not g_isLoaded then
		return 0
	end

	if not pos1 then
		pos1 = self.SoundPos
	end

	if not pos1 then
		return 0
	end

	if pos2 then
		return pos2:DistToSqr(pos1)
	end

	pos2 = StreamRadioLib.GetCameraPos(ent)

	if not pos2 then
		return 0
	end

	return pos2:DistToSqr(pos1)
end

function ENT:CheckDistanceToEntity(ent, maxDist, pos1, pos2)
	local maxDistSqr = maxDist * maxDist
	local distSqr = self:DistToSqrToEntity(ent, pos1, pos2)

	if distSqr > maxDistSqr then
		return false
	end

	return true
end

function ENT:GetRealRadioOwner()
	local getCPPIOwner = self.CPPIGetOwner
	if isfunction(getCPPIOwner) then
		local owner = getCPPIOwner(self)

		if isentity(owner) and IsValid(owner) then
			return owner
		end
	end

	local getRadioOwner = self.GetRadioOwner
	if isfunction(getRadioOwner) then
		local owner = getRadioOwner(self)

		if IsValid(owner) then
			return owner
		end
	end

	return nil
end

function ENT:Initialize()
	if g_isLoaded then
		StreamRadioLib.RegisterRadio(self)
	end

	self._3dstraemradio_classobjs_nw_register = {}

	if SERVER then
		self._WireOutputCache = {}
	end

	self:GetOrCreateStream()
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
	if not g_isLoaded then
		return true
	end

	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return true end
	if not ply:IsPlayer() then return true end
	if ply:IsBot() then return true end

	if StreamRadioLib.IsMuted(ply, self:GetRealRadioOwner()) then
		return true
	end

	local mutedist = math.min(self:GetRadius() + 1000, StreamRadioLib.GetMuteDistance(ply))
	local camPos = nil

	if CLIENT then
		camPos = StreamRadioLib.GetCameraViewPos(ply)
	end

	if not self:CheckDistanceToEntity(ply, mutedist, nil, camPos) then
		return true
	end

	return false
end

function ENT:IsMutedForAll()
	if not g_isLoaded then
		return true
	end

	if self:GetSVMute() then
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
	if not g_isLoaded then
		return
	end

	StreamRadioLib.RegisterRadio(self)
end

function ENT:OnRemove()
	local Stream = self.StreamObj
	local creationID = self:GetCreationID()

	local classobjs_data = self._3dstreamradio_classobjs_data
	local classobjs_nw_register = self._3dstraemradio_classobjs_nw_register

	-- We run it in a timer to ensure the entity is actually gone
	timer.Simple( 0.05, function()
		if IsValid(self) then
			self:PostFakeRemove()
			return
		end

		if IsValid(Stream) then
			Stream:Remove()
			Stream = nil
		end

		if g_isLoaded then
			StreamRadioLib.UnregisterRadio(creationID)

			LIBUtil.EmptyTableSafe(classobjs_data)
			LIBUtil.EmptyTableSafe(classobjs_nw_register)
		end
	end)

	if SERVER then
		self:StopStreamInternal()

		if g_isWiremodLoaded then
			WireLib.Remove(self)
		end
	end

	BaseClass.OnRemove(self)
end

function ENT:NWOverflowKill()
	self:SetNoDraw(true)

	if SERVER then
		self:Remove()
	end
end

function ENT:NonDormantThink()
	-- Override me
end

function ENT:FastThink()
	local pos, ang = self:CalcSoundPosAngWorld()

	if SERVER then
		if g_isWiremodLoaded then
			self:WiremodThink()
		end
	else
		local stream = self.StreamObj

		if CLIENT and self:ShowDebug() then
			local channeltext = "no sound"

			if stream then
				channeltext = tostring(stream)
			end

			channeltext = string.format("Sound pos, channel: %s", channeltext)

			debugoverlay.Axis(pos, ang, 5, 0.05, color_white)
			debugoverlay.EntityTextAtPosition(pos, 1, channeltext, 0.05, color_white)
		end

		if IsValid(stream) then
			stream:Set3DPosition(pos, ang:Forward())
		end
	end
end

function ENT:Think()
	BaseClass.Think(self)

	local curtime = CurTime()

	if g_isLoaded then
		self:InternalThink()
	end

	if SERVER then
		self:NextThink(curtime + 0.1)
		return true
	end

	return true
end

function ENT:InternalThink()
	local now = CurTime()

	self._nextSlowThink = self._nextSlowThink or 0

	if self._nextSlowThink < now then
		self:InternalSlowThink()
		self._nextSlowThink = now + 0.20
	end
end

function ENT:InternalSlowThink()
	local now = CurTime()

	StreamRadioLib.RegisterRadio(self)

	self._beingLookedAtCache = nil
	self._showDebugCache = nil

	if SERVER then
		if self._TransmitCheck then
			self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
			self._TransmitCheck = nil
		end

		local nextTransmitCheck = (self._LastTransmitCheck or 0) + 2.5
		if now >= nextTransmitCheck then
			self:CheckTransmitState()
		end
	else
		if g_isWiremodLoaded then
			if now >= (self._NextRBUpdate or 0) then
				Wire_UpdateRenderBounds(self)
				self._NextRBUpdate = now + math.random(30, 100) / 10
			end
		end
	end
end

function ENT:StopStreamInternal()
	if not SERVER then return end
	if not IsValid(self.StreamObj) then return end

	self.StreamObj:Stop()
	self.StreamObj:SetURL("")
	self.StreamObj:SetStreamName("")
end

function ENT:PlayStreamInternal(url, name)
	if not SERVER then return end
	if not IsValid(self.StreamObj) then return end

	url = string.Trim(tostring(url or ""))
	name = string.Trim(tostring(name or ""))

	if url == "" then
		self:StopStreamInternal()
		return
	end

	if name == "" then
		name = url
	end

	self.StreamObj:RemoveChannel(true)
	self.StreamObj:SetURL(url)
	self.StreamObj:SetStreamName(name)
	self.StreamObj:Play(true)

	self:OnPlayStreamInternal(url, name)
end

function ENT:OnPlayStreamInternal(url, name)
	local owner = self:GetRealRadioOwner()
	local lastUser = self:GetLastUser()

	if not IsValid(lastUser) then
		lastUser = owner
	end

	LIBHook.RunCustom("OnPlayStream", url, name, self, lastUser)
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

function ENT:ShowDebug()
	if self._showDebugCache ~= nil then
		return self._showDebugCache
	end

	self._showDebugCache = false

	if not LIBUtil.IsDebug() then
		return false
	end

	if CLIENT and not self:IsBeingLookedAt() then
		return false
	end

	self._showDebugCache = true
	return true
end

if CLIENT then
	function ENT:DrawTranslucent(flags)
		self:DrawModel(flags)

		if not g_isWiremodLoaded then return end
		Wire_Render(self)
	end

	function ENT:BeingLookedAtByLocalPlayer()
		local ply = LocalPlayer()
		if not IsValid( ply ) then
			return false
		end

		if not self:CheckDistanceToEntity(ply, 256) then
			return false
		end

		local tr = StreamRadioLib.Trace(ply)
		if not tr then
			return false
		end

		return tr.Entity == self
	end

	function ENT:IsBeingLookedAt()
		if self._beingLookedAtCache ~= nil then
			return self._beingLookedAtCache
		end

		local beingLookedAt = self:BeingLookedAtByLocalPlayer()
		self._beingLookedAtCache = beingLookedAt

		return beingLookedAt
	end

	return
else
	function ENT:WiremodThink()
		-- Override me
	end

	function ENT:AddWireInput(name, ptype, desc)
		if not g_isWiremodLoaded then return end

		name = string.Trim(tostring(name or ""))
		ptype = string.upper(string.Trim(tostring(ptype or "NORMAL")))
		desc = string.Trim(tostring(desc or ""))

		self._wireports = self._wireports or {}
		local wireports = self._wireports

		wireports.In = wireports.In or {}
		local inputs = wireports.In

		inputs.names = inputs.names or {}
		inputs.types = inputs.types or {}
		inputs.descs = inputs.descs or {}

		inputs.once = inputs.once or {}
		if inputs.once[name] then return end

		inputs.names[#inputs.names + 1] = name
		inputs.types[#inputs.types + 1] = ptype
		inputs.descs[#inputs.descs + 1] = desc
		inputs.once[name] = true
	end

	function ENT:AddWireOutput(name, ptype, desc)
		if not g_isWiremodLoaded then return end

		name = string.Trim(tostring(name or ""))
		ptype = string.upper(string.Trim(tostring(ptype or "NORMAL")))
		desc = string.Trim(tostring(desc or ""))

		self._wireports = self._wireports or {}
		local wireports = self._wireports

		wireports.Out = wireports.Out or {}
		local outputs = wireports.Out

		outputs.names = outputs.names or {}
		outputs.types = outputs.types or {}
		outputs.descs = outputs.descs or {}

		outputs.once = outputs.once or {}
		if outputs.once[name] then return end

		outputs.names[#outputs.names + 1] = name
		outputs.types[#outputs.types + 1] = ptype
		outputs.descs[#outputs.descs + 1] = desc
		outputs.once[name] = true
	end

	function ENT:InitWirePorts()
		if not g_isWiremodLoaded then return end

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
		if not g_isWiremodLoaded then return false end

		local wireinputs = self.Inputs
		if not istable(wireinputs) then return false end

		local wireinput = wireinputs[name]
		if not istable(wireinput) then return false end
		if not IsValid(wireinput.Src) then return false end

		return true
	end

	function ENT:IsConnectedOutputWire(name)
		if not g_isWiremodLoaded then return false end

		local wireoutputs = self.Outputs
		if not istable(wireoutputs) then return false end

		local wireoutput = wireoutputs[name]
		if not istable(wireoutput) then return false end
		if not istable(wireoutput.Connected) then return false end
		if not istable(wireoutput.Connected[1]) then return false end
		if not IsValid(wireoutput.Connected[1].Entity) then return false end

		return true
	end

	function ENT:HasWirelink(name)
		if not g_isWiremodLoaded then return false end

		local wireoutputs = self.Outputs
		if not istable(wireoutputs) then return false end

		local wireoutput = wireoutputs[name]
		if not istable(wireoutput) then return false end

		local value = wireoutput.Value
		if not isentity(value) then return false end
		if not IsValid(value) then return false end

		return true
	end

	local g_wirelinkName = "wirelink"

	function ENT:IsConnectedWirelink()
		if not g_isWiremodLoaded then return false end

		if not self.extended then
			-- wirelink had not been created yet
			return false
		end

		if self:HasWirelink(g_wirelinkName) then
			-- wirelink had been triggered via E2 code
			return true
		end

		if self:IsConnectedOutputWire(g_wirelinkName) then
			-- wirelink had been connected via Wire Tool
			return true
		end

		return false
	end

	function ENT:TriggerWireOutput(name, value)
		if not g_isWiremodLoaded then return end

		if isbool(value) or value == nil then
			value = value and 1 or 0
		end

		if value == self._WireOutputCache[name] and not istable(value) then return end
		self._WireOutputCache[name] = value

		WireLib.TriggerOutput(self, name, value)
	end

	function ENT:TriggerInput(name, value, ext)
		local wired = self:IsConnectedInputWire(name) or self:IsConnectedWirelink() or istable(ext) and ext.wirelink
		self:OnWireInputTrigger(name, value, wired)
	end

	function ENT:OnWireInputTrigger(name, value, wired)
		-- Override me
	end

	function ENT:OnRestore()
		if not g_isWiremodLoaded then return end

		WireLib.Restored( self )
	end

	function ENT:SetDupeData(key, value)
		self.DupeData = self.DupeData or {}
		self.DupeData[key] = table.Copy(value)
	end

	function ENT:GetDupeData(key)
		self.DupeData = self.DupeData or {}
		return self.DupeData[key]
	end

	function ENT:PermaPropSave()
		return {}
	end

	function ENT:PermaPropLoad(data)
		return true
	end

	function ENT:OnEntityCopyTableFinish(data)
		local done = {}

		-- Filter out all variables/members with an storable values
		-- to avoid any abnormal, invalid or unexpectedly shared entity stats on duping (especially for Garry-Dupe)
		local function recursive_filter(tab, newtable)
			if done[tab] then return tab end
			done[tab] = true

			if newtable then
				for k, v in pairs(tab) do
					if isfunction(k) or isfunction(v) then
						continue
					end

					if isentity(k) or isentity(v) then
						continue
					end

					if istable(k) then
						k = recursive_filter(k, {})
					end

					if istable(v) then
						newtable[k] = recursive_filter(v, {})
						continue
					end

					newtable[k] = v
				end

				return newtable
			end

			for k, v in pairs(tab) do
				if isfunction(k) or isfunction(v) then
					tab[k] = nil
					continue
				end

				if isentity(k) or isentity(v) then
					tab[k] = nil
					continue
				end

				if istable(k) then
					tab[k] = nil
					continue
				end

				if istable(v) then
					tab[k] = recursive_filter(v, {})
					continue
				end

				tab[k] = v
			end

			return tab
		end

		local EntityMods = data.EntityMods
		local PhysicsObjects = data.PhysicsObjects

		data.StreamObj = nil
		data._3dstreamradio_classobjs_data = nil
		data._3dstraemradio_classobjs_nw_register = nil
		data.StreamRadioDT = nil
		data.pl = nil
		data.Owner = nil

		data.Inputs = nil
		data.Outputs = nil

		data.BaseClass = nil
		data.OnDieFunctions = nil
		data.PhysicsObjects = nil
		data.EntityMods = nil

		data.old = nil

		if self.OnSetupCopyData then
			self:OnSetupCopyData(data)
		end

		-- Filter out all variables/members with an underscore in the beginning
		-- to avoid any abnormal, invalid or unexpectedly shared entity stats on duping (especially for Garry-Dupe)
		for k, v in pairs(data) do
			if isstring(k) and #k > 0 and k[1] == "_" then
				data[k] = nil
				continue
			end
		end

		recursive_filter(data)
		data.EntityMods = EntityMods
		data.PhysicsObjects = PhysicsObjects
	end

	function ENT:PreEntityCopy()
		if g_isWiremodLoaded then
			self:SetDupeData("Wire", WireLib.BuildDupeInfo(self))
		end

		local classsystem_classobjs_data = {}

		self:PreClasssystemCopy(classsystem_classobjs_data)

		self:SetDupeData("Classsystem", classsystem_classobjs_data)

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

		local dupeData = table.Copy(ent.EntityMods.DupeData or {})

		local WireData = dupeData.Wire
		dupeData.Wire = nil

		if g_isWiremodLoaded and WireData then
			WireLib.ApplyDupeInfo(ply, ent, WireData, function(id, default)
				if id == nil then return default end
				if id == 0 then return game.GetWorld() end

				local ident = CreatedEntities[id]

				if not IsValid(ident) then
					if isnumber(id) then
						ident = ents.GetByIndex(id)
					end
				end

				if not IsValid(ident) then
					ident = default
				end

				return ident
			end)

			WireData = nil
		end

		local classobjs_data = dupeData.Classsystem
		dupeData.Classsystem = nil

		ent._3dstreamradio_classobjs_data = classobjs_data

		ent:PostClasssystemPaste(classobjs_data)

		if dupeData.Skin then
			ent:SetSkin(dupeData.Skin.Skin or 0)
			ent:SetColor(dupeData.Skin.Color or color_white)
		end

		dupeData.Skin = nil

		ent:SetDupePoses(dupeData.DupePoses)
		dupeData.DupePoses = nil

		if not ent.DupeDataApply then return end

		for key, value in pairs(dupeData) do
			ent:DupeDataApply(key, value)
		end
	end

	function ENT:ReapplyClasssystemPaste()
		local data = self._3dstreamradio_classobjs_data

		if not data then
			return
		end

		self:PostClasssystemPaste(data)
	end

	function ENT:PostClasssystemPaste(data)
		if not IsValid(self.StreamObj) then
			return
		end

		self.StreamObj:LoadFromDupe(data)
	end

	function ENT:PreClasssystemCopy(data)
		if not IsValid(self.StreamObj) then
			return
		end

		self.StreamObj:LoadToDupe(data)
	end

	function ENT:OnSetupCopyData(data)
		-- override me
	end

	function ENT:OnPreEntityCopy()
		-- override me
	end

	function ENT:DupeDataApply(key, value)
		-- override me
	end
end
