local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local tostring = tostring
local tonumber = tonumber
local isfunction = isfunction
local IsValid = IsValid
local Vector = Vector

local string = string
local math = math
local SERVER = SERVER
local CLIENT = CLIENT

local EmptyVector = Vector()

local BASS3 = nil

local LIBNetwork = StreamRadioLib.Network
local LIBBass = StreamRadioLib.Bass
local LIBError = StreamRadioLib.Error
local LIBUtil = StreamRadioLib.Util
local LIBUrl = StreamRadioLib.Url
local LIBStream = StreamRadioLib.Stream
local LIBString = StreamRadioLib.String

local BASE = CLASS:GetBaseClass()
local g_maxSongLenForCache = 60 * 60 * 1.5 -- 1.5 Hours

local function LoadBass()
	local hasBass = LIBBass.LoadDLL()

	if hasBass and not BASS3 then
		BASS3 = _G.BASS3
	end

	return hasBass
end

local function ChannelIsCacheAble( channel )
	if not IsValid( channel ) then return false end

	local len = channel:GetLength( )
	if len <= 0 then
		return false
	end

	if len > g_maxSongLenForCache then
		return false
	end

	return true
end

local function ChannelStop( channel )
	if not channel then
		return
	end

	channel:Stop()

	if channel.Remove then
		channel:Remove( )
	end

	LIBBass.ClearCache()
	return
end

local retry_timeout_max = 3

local retry_errors_non3d = {
	[41] = true,
	[21] = true,
	[22] = true,
	[2] = true,
	[-1] = true
}

local retry_errors_block = {
	[41] = true,
	[21] = true,
	[22] = true,
	[2] = true,
	[-1] = true
}

local retry_errors_urlblocked = {
	[LIBError.STREAM_ERROR_URL_NOT_WHITELISTED] = true,
	[LIBError.STREAM_ERROR_URL_BLOCKED] = true,
}

local function loadLibs()
	if LIBError.STREAM_ERROR_CFCHTTP_BLOCKED_URI then
		retry_errors_urlblocked[LIBError.STREAM_ERROR_CFCHTTP_BLOCKED_URI] = true
	end
end

function CLASS:Create()
	BASE.Create(self)

	if loadLibs then
		loadLibs()
		loadLibs = nil
	end

	self.Channel = nil
	self.TimeOffset = 0
	self.ChannelChanged = false
	self.nextUrlBackgroundCheck = 0
	self.urlBackgroundCheckRuns = nil

	self._converter_downloads = {}
	self._cache_downloads = {}

	if CLIENT then
		self.ConVarGlobalVolume = StreamRadioLib.Settings.GetConVar("volume")
		if IsValid(self.ConVarGlobalVolume) then
			self.ConVarGlobalVolume:SetEvent("OnChange", self:GetID(), function()
				self:UpdateChannelVolume()
			end)
		end
	end

	self.URL = self:CreateListener({
		external = "",
		internal = "",
	}, function(this, k, v)
		if k == "external" then
			self.URL.internal = ""

			local rawv = v

			v = string.Trim(tostring(v or ""))
			v = LIBUrl.SanitizeUrl(v)

			if rawv ~= v then
				-- avoid calling it twice on unclean input
				self.URL.external = v
				return
			end

			self:SetNWString("URL", v)

			self.TimeOffset = 0
			self._wouldpredownload = nil
			self._LastMasterState = nil
			self._server_override_timedata = nil
			self.Old_ClientStateListBuffer = nil
			self:SetClientStateOnServer("Time", 0)

			self._isCached = nil
			self._isOnline = nil
			self._interfaceName = nil
			self._isOnlineUrl = LIBUrl.IsOnlineURL(v)
			self._isCheckingUrl = nil

			self.ChannelChanged = true
			self:Update()
		end
	end)

	if CLIENT then
		self.WSData = self:CreateListener({
			WorldSound = false,

			Position = EmptyVector,
			Forward = EmptyVector,
			Velocity = EmptyVector,

			DistanceStart = 0,
			DistanceEnd = 0,

			InnerAngle = 360,
			OuterAngle = 360,
			OutVolume = 1,
		}, function(this, k, v)
			if k == "WorldSound" then
				self:QueueCall("Reconnect")
			end

			self:UpdateChannelWS()
		end)
	end

	self.Volume = self:CreateListener({
		SVMul = 1,
		CLMul = 1,
		MuteSlide = false,
	}, function(this, k, v)
		if k ~= "MuteSlide" then
			v = tonumber(v) or 0
			v = math.Clamp(v, 0, 1)

			self.Volume[k] = v
		end

		if k == "SVMul" then
			self:CallHook("OnVolumeChange", v)
			self:SetNWFloat("Volume", v)
		end

		self:UpdateChannelVolume()
	end)

	self._isseeking = false

	self.StateTable = {
		"Error",
		"Time",
		"ForceTime",
		"Length",
		"Ended",
		"ValidChannel",
	}

	self.StateTable_r = {}

	for i, v in ipairs(self.StateTable) do
		self.StateTable_r[v] = i
	end

	LIBBass.ClearCache()

	self.State = self:CreateListener({
		Error = 0,
		PlayMode = StreamRadioLib.STREAM_PLAYMODE_STOP,
		Length = 0,
		Stopped = true,
		Ended = false,
		Loop = false,
		Muted = false,
		Name = "",
		Seeking = false,
		ValidChannel = false,
		HasBass = CLIENT and LoadBass(),
	}, function(this, k, v)
		if k == "PlayMode" then
			self:UpdateChannelPlayMode()
			self:SetNWInt("PlayMode", v)
			self:CallHook("OnPlayModeChange", v)
		end

		if k == "Loop" then
			self:UpdateChannelLoop()
			self:SetNWBool("Loop", v)
		end

		if k == "Stopped" and v then
			self:CallHook("OnClose")

			if CLIENT then
				self.State.HasBass = LoadBass()
			end
		end

		if k == "Muted" then
			self:UpdateChannelMuted()
			self:CallHook("OnMute", v)

			if CLIENT then
				self.State.HasBass = LoadBass()
			end
		end

		if k == "Name" then
			self:RemoveChannel(true)
			self:Reconnect()
			self:SetNWString("Name", v)
		end

		if k == "Ended" and v then
			self:Pause()
			self:CallHook("OnTrackEnd")
		end

		if k == "HasBass" then
			self:Reconnect()
		end

		if k == "Seeking" then
			if v then
				self._isseeking = true
				self:CallHook("OnSeekingStart")
				self:TimerRemove("seeking")

				if IsValid(self.Channel) then
					self.Channel:Pause()
				end

				-- force seeking to end after 10 secounds
				self:TimerOnce("seeking", 10, function()
					self._targettime = nil
					self._isseeking = false

					if not self.State.Ended then
						self:UpdateChannelPlayMode()
					end

					self:CallHook("OnSeekingEnd")
				end)
			else
				self._targettime = nil
				self:TimerOnce("seeking", 0.2, function()
					self._isseeking = false

					if not self.State.Ended then
						self:UpdateChannelPlayMode()
					end

					self:CallHook("OnSeekingEnd")
				end)
			end

			self.Volume.MuteSlide = v
		end

		self:SetClientStateOnServer(k, v)
	end)

	for i, key in ipairs(self.StateTable) do
		local value = self.State[key]
		if key == "Time" then
			value = value or 0
		end

		if key == "ForceTime" then
			value = -1
		end

		if value == nil then
			continue
		end

		self:SetClientStateOnServer(key, value)
	end

	if SERVER then
		LIBNetwork.AddNetworkString("clientstate")

		self:NetReceive("clientstate", function(this, id, len, ply)
			local bufferlen = net.ReadUInt(16)

			for i = 1, bufferlen do
				local key = net.ReadUInt(4)

				key = self.StateTable[key]
				if not key then return end

				local value = nil

				if key == "Error" then
					value = net.ReadInt(24)
				elseif key == "Time" then
					value = net.ReadDouble()
				elseif key == "ForceTime" then
					value = net.ReadDouble()
				elseif key == "Length" then
					value = net.ReadDouble()
				else
					value = net.ReadBool()
				end

				self:SetClientState(ply, key, value)
			end
		end)
	end

	self:StartFastThink()
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)

	if SERVER then
		self:SetNWFloat("Volume", self.Volume.SVMul)
		self:SetNWString("URL", self.URL.external)
		self:SetNWInt("PlayMode", self.State.PlayMode)
		self:SetNWBool("Loop", self.State.Loop)
		self:SetNWString("Name", self.State.Name)
		return
	end

	self:SetNWVarCallback("Volume", "Float", function(this, nwkey, oldvar, newvar)
		self.Volume.SVMul = newvar
	end)

	self:SetNWVarCallback("URL", "String", function(this, nwkey, oldvar, newvar)
		self.URL.external = newvar
	end)

	self:SetNWVarCallback("PlayMode", "Int", function(this, nwkey, oldvar, newvar)
		self.State.PlayMode = newvar
	end)

	self:SetNWVarCallback("Loop", "Bool", function(this, nwkey, oldvar, newvar)
		self.State.Loop = newvar
	end)

	self:SetNWVarCallback("Name", "String", function(this, nwkey, oldvar, newvar)
		self.State.Name = newvar
	end)

	self.Volume.SVMul = self:GetNWFloat("Volume", 1)
	self.URL.external = self:GetNWString("URL", "")
	self.State.PlayMode = self:GetNWInt("PlayMode", StreamRadioLib.STREAM_PLAYMODE_STOP)
	self.State.Loop = self:GetNWBool("Loop", false)
	self.State.Name = self:GetNWString("Name", "")
end

function CLASS:SetClientStateOnServer(key, value)
	if not self.Network.Active then return end
	if not key then return end
	if not self.StateTable_r[key] then return end

	if SERVER then
		if key ~= "ForceTime" then
			if self._wouldpredownload then return end
		end

		self:SetClientState("SERVER", key, value)
		return
	end

	self.ClientStateListBuffer = self.ClientStateListBuffer or {}
	self.ClientStateListBuffer[key] = value

	self:QueueCall("NetworkClientState")
end

function CLASS:NetworkClientState()
	if SERVER then return end

	self.Old_ClientStateListBuffer = self.Old_ClientStateListBuffer or {}

	local sendbuffer = {}

	for key, value in pairs(self.ClientStateListBuffer or {}) do
		local key_index = self.StateTable_r[key]
		if not key_index then continue end

		if value == self.Old_ClientStateListBuffer[key] then
			continue
		end

		local item = {
			key = key,
			key_index = key_index,
			value = value,
		}

		table.insert(sendbuffer, item)

		self.Old_ClientStateListBuffer[key] = value
	end

	self:NetSend("clientstate", function()
		net.WriteUInt(#sendbuffer, 16)

		for i, v in pairs(sendbuffer) do
			local key = v.key
			local value = v.value

			net.WriteUInt(v.key_index, 4)

			if key == "Error" then
				net.WriteInt(value or 0, 24)
			elseif key == "Time" then
				net.WriteDouble(value or 0)
			elseif key == "ForceTime" then
				net.WriteDouble(value or 0)
			elseif key == "Length" then
				net.WriteDouble(value or 0)
			else
				net.WriteBool(value or false)
			end
		end
	end)
end

function CLASS:CleanUpClientStateList()
	if not self.ClientStateList then
		return
	end

	for pId, state in pairs(self.ClientStateList) do
		if pId == "SERVER" then
			continue
		end

		if StreamRadioLib.IsPlayerNetworkable(pId) then
			continue
		end

		self.ClientStateList[pId] = nil
	end
end

function CLASS:SetClientState(ply, key, value)
	if CLIENT then return end
	if not self.Network.Active then return end

	if not ply then return end
	if not key then return end

	local key_index = self.StateTable_r[key]
	if not key_index then return end

	local pId = nil

	if ply == "SERVER" then
		pId = ply
	else
		pId = StreamRadioLib.GetPlayerId(ply)
	end

	if not pId then return end

	self.ClientStateList = self.ClientStateList or {}
	self.ClientStateList[pId] = self.ClientStateList[pId] or {
		Error = 0,
		Ended = false,
		ValidChannel = false,
		Time = 0,
		Length = -1,
		TimeStamp = self.PlayTime or 0,
	}

	if key == "Time" then
		value = math.max(value, 0)
		self.ClientStateList[pId].TimeStamp = self.PlayTime or 0
	end

	if key == "ForceTime" then
		if value >= 0 then
			if pId ~= "SERVER" then
				self.TimeMaster = nil
				self._LastMasterState = nil
				self._server_override_timedata = nil
			end

			for k, v in pairs(self.ClientStateList) do
				self.ClientStateList[k].Time = value
				self.ClientStateList[k].TimeStamp = self.PlayTime or 0
			end
		end

		value = nil
	end

	self.ClientStateList[pId][key] = value

	if not self:IsValidTimeMaster(self.TimeMaster) then
		self.TimeMaster = nil

		if self:IsValidTimeMaster(pId) then
			self.TimeMaster = pId
			self._LastMasterState = nil
			self._server_override_timedata = nil
		end
	end

	if pId == "SERVER" then
		self:CallHook("OnServerStateChange", ply, key, value)
	else
		self:CallHook("OnClientStateChange", ply, key, value)
	end
end

function CLASS:GetClientStates(plyOrPId)
	if CLIENT then return nil end

	if not plyOrPId then return nil end
	if not self.ClientStateList then return nil end

	if plyOrPId == "SERVER" then
		return self.ClientStateList["SERVER"]
	end

	if not StreamRadioLib.IsPlayerNetworkable(plyOrPId) then
		self:CleanUpClientStateList()
		return nil
	end

	if isentity(plyOrPId) then
		plyOrPId = StreamRadioLib.GetPlayerId(plyOrPId)
	end

	if not plyOrPId then
		return nil
	end

	return self.ClientStateList[plyOrPId]
end

function CLASS:IsValidTimeMaster(plyOrPId)
	if CLIENT then return false end

	local state = self:GetClientStates(plyOrPId)
	if not state then return false end

	local haschannel = state.ValidChannel
	if not haschannel then return false end

	local err = state.Error or 0
	if err ~= 0 then return false end

	local timestamp = state.TimeStamp or 0
	if timestamp < 0 then return false end

	local time = state.Time
	if not time then return false end

	return true
end

function CLASS:GetTimeMasterClientState()
	if self:IsValidTimeMaster(self.TimeMaster) then
		local state = self:GetClientStates(self.TimeMaster)

		if state and not state._comp then
			state._comp = self.TimeMaster
		end

		return state
	end

	self.TimeMaster = nil

	if not self.ClientStateList then
		return nil
	end

	for pId, state in pairs(self.ClientStateList) do
		if not self:IsValidTimeMaster(pId) then continue end

		self.TimeMaster = pId

		if state and not state._comp then
			state._comp = self.TimeMaster
		end

		return state
	end

	return nil
end

function CLASS:CalcTime()
	local thistime = RealTime()
	local oldlt = self._lt or thistime
	self._lt = thistime

	self.TickTime = thistime - oldlt

	self.PlayTime = self.PlayTime or 0

	if self:IsPlayMode() then
		self.PlayTime = self.PlayTime + self.TickTime
	end
end

function CLASS:FastThink()
	self:CalcTime()

	local masterLength = self:GetMasterLength()

	self.State.Ended = self:HasEndedInternal()
	self.State.Seeking = self:_IsSeekingInternal()
	self.State.Length = self:GetLength()
	self.State.ValidChannel = IsValid(self.Channel)

	if SERVER then
		local timeA = self:GetMasterTime()

		if game.SinglePlayer() then
			self:SetNWFloat("MasterTime", timeA)
		else
			local timeB = self:GetNWFloat("MasterTime", 0)
			local dt = math.abs(timeA - timeB)
			local tickTime = engine.TickInterval()

			-- add random noise to avoid uneven network load
			local random = math.random() * 0.2
			local maxDt = 0.4 + random

			if masterLength > 0 then
				maxDt = math.min(math.max(masterLength / 4, tickTime * 4), maxDt)
			end

			if dt >= maxDt then
				self:SetNWFloat("MasterTime", timeA)
			end
		end
	end

	self:SyncTime()
	self:DoUrlBackgroundCheck()

	if CLIENT then
		self:DoUnexpectedStopCheck()
	end
end

function CLASS:DoUnexpectedStopCheck()
	if not self:HasChannel() then
		return
	end

	if self:HasError() then
		return
	end

	if not self:IsStopped() then
		return
	end

	if not self:IsPlayMode() then
		return
	end

	if self:HasEnded() then
		return
	end

	self:KillStream()
end

function CLASS:IsAllowedUrlPair(externalUrl, internalUrl, callback, logFailure)
	self:IsAllowedInternalUrl(internalUrl, function(this, allowed, err)
		-- Ask CFC first (internal URL), so we can show errors right away.
		-- It should appear in a higher priority to the user then the in-addon whitelisting.

		if not allowed then
			callback(this, false, err)
			return
		end

		self:IsAllowedExternalUrl(externalUrl, callback)
	end, logFailure)
end

function CLASS:IsAllowedInternalUrl(url, callback, logFailure)
	StreamRadioLib.Cfchttp.IsAllowedAsync(url, function(allowed)
		if not IsValid(self) then return end

		if not allowed then
			callback(self, allowed, LIBError.STREAM_ERROR_CFCHTTP_BLOCKED_URI)
			return
		end

		callback(self, true, nil)
	end, logFailure)
end

function CLASS:IsAllowedExternalUrl(url, callback)
	if self:CallHook("CanSkipUrlChecks", url) then
		-- Sometimes we want to ignore the addon's whitelist
		callback(self, true, nil)
		return
	end

	local ent = self:GetEntity()
	local context = StreamRadioLib.Whitelist.BuildContext(ent)

	StreamRadioLib.Whitelist.IsAllowedAsync(url, context, function(allowed, blockedByHook)
		if not IsValid(self) then return end

		if not allowed then
			if self:CallHook("CanBypassUrlBlock", url, blockedByHook) then
				-- Sometimes we want to ignore the block, but still to perform the checks.
				callback(self, true, nil)
				return
			end

			if blockedByHook then
				callback(self, allowed, LIBError.STREAM_ERROR_URL_BLOCKED)
				return
			end

			callback(self, false, LIBError.STREAM_ERROR_URL_NOT_WHITELISTED)
			return
		end

		callback(self, true, nil)
	end)
end

function CLASS:DoUrlBackgroundCheck()
	-- This will automatically stop the running stream if its URL is not allowed.
	-- And it also will automatically reconnect the stream if it was blocked/stopped by the whitelist protection.

	if self.urlBackgroundCheckRuns then
		return
	end

	local now = RealTime()

	if self.nextUrlBackgroundCheck > now then
		return
	end

	self.nextUrlBackgroundCheck = now + 1 + math.random() * 9

	if self:GetMuted() then
		return
	end

	if self:IsKilled() then
		return
	end

	if not self:IsActive() then
		return
	end

	if not self:IsOnlineUrl() then
		return
	end

	local externalUrl = self.URL.external
	local internalUrl = self.URL.internal

	if externalUrl == "" then
		return
	end

	if internalUrl == "" then
		return
	end

	self.urlBackgroundCheckRuns = true

	self:IsAllowedUrlPair(externalUrl, internalUrl, function(this, isAllowed)
		self.nextUrlBackgroundCheck = RealTime() + 1 + math.random() * 9
		self.urlBackgroundCheckRuns = nil

		if self:GetMuted() then
			return
		end

		if self:IsKilled() then
			return
		end

		if not self:IsActive() then
			return
		end

		if not self:IsOnlineUrl() then
			return
		end

		local isWhitelistError = retry_errors_urlblocked[self:GetError()]

		if not isAllowed then
			if not isWhitelistError then
				-- Attempt to reconnect respecting the changed rules. It will likely fail and run its complex error handling.
				self:Reconnect()
			end
		else
			if isWhitelistError then
				-- We are allowed to play again, so let's go.
				self:Reconnect()
			end
		end
	end, false)
end

function CLASS:CallEx(func, callnow, ...)
	if callnow then
		self:CallHook(func, ...)
		return
	end

	self:QueueCall(func, ...)
end

function CLASS:Update(callnow)
	self:CallEx("UpdateInternal", callnow)
end

function CLASS:UpdateInternal()
	if not self.Valid then return end
	self.State.Stopped = false

	if self:GetMuted() then
		return
	end

	if self.ChannelChanged then
		self:Connect()
		self.ChannelChanged = false
		return
	end

	if not self:IsActiveOrLoading() then
		self:Connect()
		self.ChannelChanged = false
		return
	end

	self:UpdateChannel()
	return
end

function CLASS:UpdateChannelMuted()
	if self:GetMuted() then
		self:RemoveChannel()
		return
	end

	self:Reconnect()
end

function CLASS:UpdateChannelWS()
	if not self:Is3DChannel() then return end

	local WSData = self.WSData
	local Channel = self.Channel

	Channel:SetPos( WSData.Position, WSData.Forward, WSData.Velocity )
	Channel:Set3DFadeDistance( WSData.DistanceStart, WSData.DistanceEnd )
	Channel:Set3DCone( WSData.InnerAngle, WSData.OuterAngle, WSData.OutVolume )
end

function CLASS:UpdateChannelVolume()
	if SERVER then return end
	if not self.Valid then return end
	if not IsValid( self.ConVarGlobalVolume ) then return end
	if not IsValid( self.Channel ) then return end

	local boost3d = self:Is3DChannel() and 2.00 or 1.00

	local SVvol = self.Volume.SVMul
	local CLvol = self.Volume.CLMul
	local MuteSlide = self.Volume.MuteSlide

	local volume = 0

	if not MuteSlide then
		volume = SVvol * CLvol * self.ConVarGlobalVolume:GetValue() * boost3d
	end

	-- Max 5000% normal volume on all cases.
	volume = math.Clamp(volume, 0, 50)

	self.Channel:SetVolume(volume)
end

function CLASS:UpdateChannel()
	if not self.Valid then return end
	if not IsValid( self.Channel ) then return end

	self:UpdateChannelPlayMode()
	self:UpdateChannelVolume()
	self:UpdateChannelLoop()
	self:UpdateChannelWS()
end

function CLASS:UpdateChannelPlayMode()
	if not self.Valid then return end
	local playmode = self.State.PlayMode

	if self.URL.external == "" then
		self:RemoveChannel(true)
		self.State.Stopped = true
		return
	end

	if playmode == StreamRadioLib.STREAM_PLAYMODE_STOP then
		self:RemoveChannel(true)
		self.State.Stopped = true
		return
	end

	if not IsValid(self.Channel) then
		self.ChannelChanged = true
		self:Update()
		return
	end

	if playmode == StreamRadioLib.STREAM_PLAYMODE_PAUSE then
		self.Channel:Pause()
		return
	end

	if playmode == StreamRadioLib.STREAM_PLAYMODE_PLAY_RESTART then
		self:SetTime(0)
		self.Channel:Play()
		self.State.PlayMode = StreamRadioLib.STREAM_PLAYMODE_PLAY
		return
	end

	if playmode == StreamRadioLib.STREAM_PLAYMODE_PLAY then
		self.Channel:Play()
		return
	end
end

function CLASS:UpdateChannelLoop()
	if not self.Valid then return end
	if not IsValid(self.Channel) then return end
	if self.Channel:IsBlockStreamed() then return end

	self.Channel:EnableLooping(self.State.Loop)
end

function CLASS:RemoveChannel(clearlast)
	ChannelStop(self.Channel)

	self._streamTaskUid = nil
	self.urlBackgroundCheckRuns = nil

	self.Channel = nil
	self.State.Error = LIBError.STREAM_OK
	self._tags = nil
	self._isCached = nil
	self._isOnline = nil
	self._interfaceName = nil
	self._isCheckingUrl = nil

	LIBUtil.EmptyTableSafe(self._converter_downloads)
	LIBUtil.EmptyTableSafe(self._cache_downloads)

	if clearlast then
		self.TimeOffset = 0
		self._wouldpredownload = nil
		self._LastMasterState = nil
		self._server_override_timedata = nil

		self.Old_ClientStateListBuffer = nil
		self:SetClientStateOnServer("Time", 0)
	end
end

function CLASS:Remove()
	self:RemoveChannel(true)

	if IsValid(self.ConVarGlobalVolume) then
		self.ConVarGlobalVolume:RemoveEvent("OnChange", self:GetID())
	end

	BASE.Remove(self)
end

local g_string_format = string.format

function CLASS:ToString()
	local baseToString = BASE.ToString

	if not baseToString then
		return nil
	end

	local r = baseToString(self)
	if not self.Valid then
		return r
	end

	local channel = self:GetChannel()
	local channelStr = tostring(channel or "no channel")

	local err = self:GetError()
	local errName = LIBError.GetStreamErrorName(err) or ""

	local str = g_string_format("%s <%s> [err: %i, %s]", r, channelStr, err, errName)
	return str
end

function CLASS:__eq( other )
	if not BASE.__eq(self, other) then return false end
	if self.Channel == other.Channel then return true end

	return false
end

function CLASS:IsDownloading()
	if not self.Valid then return false end
	if not self._converter_downloads then return false end

	return not table.IsEmpty(self._converter_downloads)
end

function CLASS:IsDownloadingToCache()
	if not self.Valid then return false end
	if not self._cache_downloads then return false end

	return not table.IsEmpty(self._cache_downloads)
end

function CLASS:SetBASSEngineEnabled(bool)
	bool = bool or false

	if bool then
		bool = LoadBass()
	end

	self.State.HasBass = bool
end

function CLASS:IsBASSEngineEnabled()
	if not LIBBass.HasLoadedDLL() then return false end
	return self.State.HasBass or false
end

function CLASS:_IsActiveStreamTaskUid(streamTaskUid)
	if not self.Valid then return false end

	if not streamTaskUid then
		ErrorNoHaltWithStack("Bad streamTaskUid!")
		return false
	end

	if self.URL.external == "" then return false end
	if not self._streamTaskUid then return false end
	if self._streamTaskUid ~= streamTaskUid then return false end

	if self:GetMuted() then return false end
	if self.State.Stopped then return false end

	if IsValid(self.Channel) then return false end
	if self:HasError() then return false end

	return true
end

function CLASS:AcceptError(err)
	self:AcceptStream(nil, err)
end

function CLASS:AcceptStream(channel, err)
	local errOk = LIBError.STREAM_OK

	err = tonumber(err or errOk) or errOk

	if not IsValid(channel) or err ~= errOk then
		ChannelStop(channel)
		channel = nil

		if err == errOk then
			err = LIBError.STREAM_ERROR_UNKNOWN
		end
	end

	ChannelStop(self.Channel)

	self:CleanUpClientStateList()

	self._streamTaskUid = nil
	self._isCheckingUrl = nil

	if err == errOk then
		self.Channel = channel
		self._tags = nil
		self.State.Error = errOk

		self:UpdateChannel()
		self:CallHook("OnConnect", self.Channel)
	else
		self.Channel = nil
		self._tags = nil
		self.State.Error = err

		self:SetClientStateOnServer("Time", 0)
		self:CallHook("OnError", self.State.Error)

		-- make sure we also trigger mute on "stopsound" concommand
		if err == LIBError.STREAM_SOUND_STOPPED then
			self:CallHook("OnMute", true)
		end
	end
end

function CLASS:Reconnect()
	self:RemoveChannel()
	self:Connect()
end

function CLASS:Connect()
	self._streamTaskUid = LIBUtil.Uid()
	local streamTaskUid = self._streamTaskUid

	self:TimerOnce("stream", 0.01, function()
		if not self:_IsActiveStreamTaskUid(streamTaskUid) then
			return
		end

		local externalUrl = self.URL.external

		if self.State.PlayMode == StreamRadioLib.STREAM_PLAYMODE_STOP or externalUrl == "" then
			self:UpdateChannelPlayMode()
			return
		end

		if not self:CallHook("OnSearch", externalUrl) then
			self:AcceptError(LIBError.STREAM_ERROR_FILEOPEN)
			return
		end

		self:StartConnectingProcess(streamTaskUid, false)
	end)
end

function CLASS:StartConnectingProcess(streamTaskUid, nodownload)
	if not self:_IsActiveStreamTaskUid(streamTaskUid) then
		return
	end

	if not self.State.HasBass and SERVER then
		self:AcceptError(LIBError.STREAM_ERROR_MISSING_GM_BASS3)
		return
	end

	local externalUrl = self.URL.external

	StreamRadioLib.Interface.Convert(externalUrl, function(interface, success, internalUrl, errorcode)
		if not self:_IsActiveStreamTaskUid(streamTaskUid) then
			return
		end

		if not interface then
			self:AcceptError(LIBError.STREAM_ERROR_UNKNOWN)
			return
		end

		self.URL.internal = internalUrl

		local isOnline = interface.online
		local isCached = interface.cache
		local interfaceName = interface.name

		self._isCached = isCached
		self._isOnline = isOnline
		self._interfaceName = interfaceName

		if not success then
			self:AcceptError(errorcode)
			return
		end

		self:IsAllowedUrlPair(externalUrl, internalUrl, function(this, allowed, blockErrorCode)
			if not self:_IsActiveStreamTaskUid(streamTaskUid) then
				return
			end

			if not allowed then
				self:AcceptError(blockErrorCode)
				return
			end

			if not isOnline then
				self:RunConnectingProcessWithoutDownload(streamTaskUid, interface, internalUrl)
				return
			end

			local downloadFirst = interface.downloadFirst

			if isCached then
				downloadFirst = false
			end

			if nodownload then
				downloadFirst = false
			end

			-- Avoid many connection requests starting at once by adding a random delay
			local loadBalanceTimeout = 0.25 + math.random() * 0.75

			self:TimerOnce("stream", loadBalanceTimeout, function()
				if not downloadFirst then
					self:RunConnectingProcessWithoutDownload(streamTaskUid, interface, internalUrl)
					return
				end

				self:RunConnectingProcessWithDownload(streamTaskUid, interface, internalUrl)
			end)
		end, true)
	end)
end

function CLASS:RunConnectingProcessWithDownload(streamTaskUid, interface, internalUrl)
	if not self:_IsActiveStreamTaskUid(streamTaskUid) then
		return
	end

	local canDownload = self:CallHook("OnDownload", internalUrl, interface)

	if not canDownload then
		self:RunConnectingProcessWithoutDownload(streamTaskUid, interface, internalUrl)
		return
	end

	local downloadTimeout = interface.downloadTimeout or 0
	local externalUrl = self.URL.external

	local function afterConvertedDownload()
		if not IsValid(self) then return end

		self:TimerRemove("download_timeout")

		if not self._converter_downloads[streamTaskUid] then return end
		self._converter_downloads[streamTaskUid] = nil

		if not self:_IsActiveStreamTaskUid(streamTaskUid) then return end

		-- restart the process, so we can switch to a newly created cache

		self:SetTime(0)
		self:StartConnectingProcess(streamTaskUid, true)
	end

	self._converter_downloads[streamTaskUid] = true
	self._wouldpredownload = true

	self:TimerRemove("download_timeout")

	if downloadTimeout > 0 then
		self:TimerOnce("download_timeout", downloadTimeout, afterConvertedDownload)
	end

	StreamRadioLib.Cache.Download(internalUrl, afterConvertedDownload, externalUrl)
end

function CLASS:RunConnectingProcessWithoutDownload(streamTaskUid, interface, internalUrl)
	if not self:_IsActiveStreamTaskUid(streamTaskUid) then
		return
	end

	self:_RunConnectingProcessInternal(streamTaskUid, interface, internalUrl)
end

function CLASS:_RunConnectingProcessInternal(streamTaskUid, interface, internalUrl, state)
	if not self:_IsActiveStreamTaskUid(streamTaskUid) then
		return
	end

	local WSData = self.WSData

	local isOnline = interface.online

	state = state or {}
	state = table.Copy(state)

	state.no3d = state.no3d or false
	state.retrycount = state.retrycount or 0

	if state.noBlock == nil then
		state.noBlock = true
	end

	if SERVER then
		state.no3d = true
	end

	if not WSData or not WSData.WorldSound then
		state.no3d = true
	end

	local worldSound = not state.no3d
	local noBlock = state.noBlock

	local errOk = LIBError.STREAM_OK

	local callback = function(channel, err)
		err = tonumber(err or errOk) or errOk

		if not IsValid(self) then
			ChannelStop(channel)
			return
		end

		if not self:_IsActiveStreamTaskUid(streamTaskUid) then
			ChannelStop(channel)
			return
		end

		if not IsValid(channel) or err ~= errOk then
			ChannelStop(channel)
			channel = nil

			if err == errOk then
				err = LIBError.STREAM_ERROR_UNKNOWN
			end
		end

		self:_ConnectChannelCallback(streamTaskUid, channel, err, interface, internalUrl, state)
	end

	local hasBass = self.State.HasBass

	if isOnline then
		LIBStream.PlayOnline(internalUrl, hasBass, worldSound, noBlock, callback)
		return
	end

	LIBStream.PlayOffline(internalUrl, hasBass, worldSound, noBlock, callback)
end

local function debugRetry(format, err, externalUrl, internalUrl, ...)
	if not LIBUtil.IsDebug() then return end

	local text = string.format(format, ...)

	local errorInfo = LIBError.GetStreamErrorInfo(err)

	local errorCode = errorInfo.id
	local errorName = errorInfo.name

	StreamRadioLib.Print.Debug(
		"%s\n- Error: %d, %s\n- External URL: %s\n- Internal URL: %s",
		text,
		errorCode,
		errorName,
		externalUrl,
		internalUrl
	)
end

function CLASS:_ConnectChannelCallback(streamTaskUid, channel, err, interface, internalUrl, state)
	local externalUrl = self.URL.external

	state = state or {}

	local no3d = state.no3d
	local noBlock = state.noBlock
	local isOnline = interface.online

	local retryDelay = isOnline and 2 or 0

	-- retry max 3 times on timeout
	if err == LIBError.STREAM_ERROR_TIMEOUT then
		local retrycount = state.retrycount

		if retrycount >= retry_timeout_max then
			debugRetry(
				"[Timeout] Timeout after %d attempts.",
				err,
				externalUrl,
				internalUrl,
				retrycount
			)

			self:AcceptError(err)
			return
		end

		if not self:CallHook("OnRetry", err, internalUrl, state, interface) then
			self:AcceptError(err)
			return
		end

		self:TimerOnce("stream", retryDelay, function()
			if not self:_IsActiveStreamTaskUid(streamTaskUid) then return end

			retrycount = retrycount + 1
			state.retrycount = retrycount

			debugRetry(
				"[Timeout] Retrying stream after timeout, attempt #%d / %d.",
				err,
				externalUrl,
				internalUrl,
				retrycount,
				retry_timeout_max
			)

			self:_RunConnectingProcessInternal(streamTaskUid, interface, internalUrl, state)
		end)

		return
	end

	state.retrycount = 0

	-- retry in Non-3D if 3D is not working
	if not no3d and retry_errors_non3d[err] then
		if not self:CallHook("OnRetry", err, internalUrl, state, interface) then
			self:AcceptError(err)
			return
		end

		self:TimerOnce("stream", retryDelay, function()
			if not self:_IsActiveStreamTaskUid(streamTaskUid) then return end

			state.no3d = true

			debugRetry(
				"[3D sound] Retrying stream without 3D sound after error.",
				err,
				externalUrl,
				internalUrl
			)

			self:_RunConnectingProcessInternal(streamTaskUid, interface, internalUrl, state)
		end)

		return
	end

	-- retry in block mode if no-block mode is not working
	if noBlock and retry_errors_block[err] then
		if not self:CallHook("OnRetry", err, internalUrl, state, interface) then
			self:AcceptError(err)
			return
		end

		self:TimerOnce("stream", retryDelay, function()
			if not self:_IsActiveStreamTaskUid(streamTaskUid) then return end

			state.noBlock = false

			debugRetry(
				"[Block mode] Retrying stream in block mode after error.",
				err,
				externalUrl,
				internalUrl
			)

			self:_RunConnectingProcessInternal(streamTaskUid, interface, internalUrl, state)
		end)

		return
	end

	self:_SaveChannelToCache(streamTaskUid, channel, interface, internalUrl)

	self:AcceptStream(channel, err)
end

function CLASS:_SaveChannelToCache(streamTaskUid, channel, interface, internalUrl)
	local externalUrl = self.URL.external

	local isOnline = interface.online
	local isCache = interface.cache
	local allowCaching = interface.allowCaching

	if not ChannelIsCacheAble(channel) then
		-- remove broken cache file

		if isOnline then
			StreamRadioLib.Cache.DeleteFileForUrl(externalUrl)
		end

		if isCache then
			StreamRadioLib.Cache.DeleteFileRaw(internalUrl)
		end

		return
	end

	if not isOnline then
		return
	end

	if not allowCaching then
		StreamRadioLib.Cache.DeleteFileForUrl(externalUrl)
		return
	end

	local canDownload = self:CallHook("OnDownload", internalUrl, interface)
	if not canDownload then
		return
	end

	local afterCacheDownload = function()
		if not IsValid( self ) then
			return
		end

		self._cache_downloads[streamTaskUid] = nil
	end

	self._cache_downloads[streamTaskUid] = true

	StreamRadioLib.Cache.Download(internalUrl, afterCacheDownload, externalUrl)
end

function CLASS:GetStreamName( )
	if not self.Valid then return "" end
	return self.State.Name or ""
end

function CLASS:SetStreamName(name)
	if not self.Valid then return end
	self.State.Name = name or ""
end

function CLASS:Play( restart )
	if not self.Valid then return end
	if CLIENT and self.Network.Active then return end

	self.State.PlayMode = restart and StreamRadioLib.STREAM_PLAYMODE_PLAY_RESTART or StreamRadioLib.STREAM_PLAYMODE_PLAY
end

function CLASS:IsPlayMode()
	if not self.Valid then return false end

	if self.State.PlayMode == StreamRadioLib.STREAM_PLAYMODE_PLAY then return true end
	if self.State.PlayMode == StreamRadioLib.STREAM_PLAYMODE_PLAY_RESTART then return true end

	return false
end

function CLASS:Pause()
	if not self.Valid then return end
	if CLIENT and self.Network.Active then return end
	if self:IsPauseMode() then return end

	self._oldbeforepause = self.State.PlayMode
	self.State.PlayMode = StreamRadioLib.STREAM_PLAYMODE_PAUSE
end

function CLASS:UnPause()
	if not self.Valid then return end
	if CLIENT and self.Network.Active then return end

	if not self._oldbeforepause then return end
	if not self:IsPauseMode() then return end

	local oldbeforepause = self._oldbeforepause
	self._oldbeforepause = nil

	if oldbeforepause == StreamRadioLib.STREAM_PLAYMODE_PLAY then
		self:Play(self:HasEnded())
		return
	end

	if oldbeforepause == StreamRadioLib.STREAM_PLAYMODE_PLAY_RESTART then
		self:Play(true)
		return
	end

	self.State.PlayMode = StreamRadioLib.STREAM_PLAYMODE_STOP
end

function CLASS:IsPauseMode()
	if not self.Valid then return false end
	return self.State.PlayMode == StreamRadioLib.STREAM_PLAYMODE_PAUSE
end

function CLASS:Stop()
	if not self.Valid then return end
	if CLIENT and self.Network.Active then return end

	self.State.PlayMode = StreamRadioLib.STREAM_PLAYMODE_STOP
end

function CLASS:IsStopMode()
	if not self.Valid then return true end
	return self.State.PlayMode == StreamRadioLib.STREAM_PLAYMODE_STOP
end

function CLASS:SetPlayingState(mode)
	if not self.Valid then return end
	if CLIENT and self.Network.Active then return end

	self.State.PlayMode = mode or StreamRadioLib.STREAM_PLAYMODE_STOP
end

function CLASS:GetPlayingState()
	if not self.Valid then return StreamRadioLib.STREAM_PLAYMODE_STOP end

	return self.State.PlayMode or StreamRadioLib.STREAM_PLAYMODE_STOP
end

function CLASS:GetChannel()
	if not self.Valid then return nil end
	if not IsValid( self.Channel ) then return nil end

	return self.Channel
end

function CLASS:GetError()
	if not self.Valid then
		return LIBError.STREAM_OK
	end

	local state = self.State
	if not state then
		return LIBError.STREAM_OK
	end

	return state.Error or LIBError.STREAM_OK
end

function CLASS:HasError()
	if not self.Valid then return false end
	return self:GetError() ~= LIBError.STREAM_OK
end

function CLASS:HasChannel()
	if not self.Valid then return false end
	return self:GetChannel() ~= nil
end

function CLASS:SetURL(url)
	if not self.Valid then return end
	if CLIENT and self.Network.Active then return end

	self.URL.external = LIBUrl.SanitizeUrl(url)
end

function CLASS:GetURL()
	if not self.Valid then return "" end

	local url = LIBUrl.SanitizeUrl(self.URL.external)
	return url
end

function CLASS:GetInternalURL()
	if not self.Valid then return "" end

	local url = self.URL.internal
	return url
end

function CLASS:SetLoop(var)
	if not self.Valid then return end
	if CLIENT and self.Network.Active then return end

	self.State.Loop = var or false
end

function CLASS:GetLoop()
	if not self.Valid then return false end
	return self.State.Loop or false
end

function CLASS:Set3D(var)
	if SERVER then return end
	if not self.Valid then return end

	self.WSData.WorldSound = var or false
end

function CLASS:Get3D()
	if SERVER then return false end
	if not self.Valid then return false end

	return self.WSData.WorldSound
end

function CLASS:Is3DChannel()
	if SERVER then return false end
	if not self.Valid then return false end
	if not IsValid( self.Channel ) then return false end

	return self.Channel:Is3D()
end

function CLASS:GetFilename()
	if not self.Valid then return "" end
	if not IsValid( self.Channel ) then return "" end

	return self.Channel:GetFileName( )
end

function CLASS:GetLevel()
	if not self.Valid then return 0, 0 end
	if not IsValid( self.Channel ) then return 0, 0 end

	local L, R = self.Channel:GetLevel()
	return L or 0, R or 0
end

function CLASS:GetAverageLevel()
	local L, R = self:GetLevel()

	return (L + R) / 2
end

function CLASS:GetLength()
	if not self.Valid then return -1 end
	if not IsValid(self.Channel) then return -1 end

	local length = self.Channel:GetLength( )

	if length <= 0 then
		length = -1
	end

	return length
end

function CLASS:GetRealTime()
	if not self.Valid then return 0 end
	if not IsValid( self.Channel ) then return 0 end

	local time = self.Channel:GetTime() or 0
	local length = self.Channel:GetLength()

	if length > 0 then
		time = math.min(time, length)
	end

	time = math.max(time, 0)
	return time
end

function CLASS:GetMasterTime()
	if not self.Valid then return 0 end

	if SERVER then
		local state = self:GetTimeMasterClientState() or self._LastMasterState
		if not state then return 0 end

		if not self._LastMasterState or self._LastMasterState._comp ~= state._comp then
			self._LastMasterState = table.Copy(state)
		end

		if self._server_override_timedata then
			-- Server should be able to override the time even so if not players can hear the stream
			state = self._server_override_timedata
		end

		local thistime = self.PlayTime or 0

		local timestamp = state.TimeStamp
		if not timestamp then return 0 end

		local time = state.Time
		if not time then return 0 end

		local len = self:GetMasterLength()
		local loop = self:GetLoop()

		local offset = thistime - timestamp
		local calctime = math.max(time + offset, 0)

		if len > 0 then
			if loop then
				calctime = calctime % len
			end

			calctime = math.min(calctime, len)
		end

		return calctime
	end

	return self:GetNWFloat("MasterTime", 0)
end

function CLASS:GetMasterLength()
	if not self.Valid then return -1 end

	if SERVER then
		local state = self:GetTimeMasterClientState() or self._LastMasterState
		if not state then return self:GetLength() end

		if not self._LastMasterState or self._LastMasterState._comp ~= state._comp then
			self._LastMasterState = table.Copy(state)
		end

		local len = state.Length or self:GetLength()
		return len
	end

	return self:GetLength()
end

function CLASS:GetTime()
	if not self.Valid then return 0 end
	if not IsValid( self.Channel ) then return 0 end

	local time = self:GetRealTime()
	local length = self:GetLength()

	if self:IsEndless() then
		time = time + self.TimeOffset
	end

	if length > 0 then
		time = math.min(time, length)
	end

	time = math.max(time, 0)
	return time
end

function CLASS:SetTime(time, force)
	if not self.Valid then return end

	time = tonumber(time) or 0

	if time <= 0 then
		time = 0
	end

	self.State.Time = time

	if force then
		self:SetClientStateOnServer("ForceTime", time)

		if SERVER then
			self._server_override_timedata = {
				TimeStamp = self.PlayTime or 0,
				Time = time,
			}
		end
	else
		self:SetClientStateOnServer("ForceTime", -1)
	end

	if not IsValid(self.Channel) then return end

	if not self:CanSeek() then
		return
	end

	self:_SetTimeInternal(time)
end

function CLASS:_SetTimeInternal(time)

	time = tonumber(time) or 0
	time = math.max(time, 0)

	local length = self:GetLength()

	if self:IsEndless() then
		self.TimeOffset = time - self:GetRealTime()
		return
	end

	self.TimeOffset = 0

	if not self:CanSeek() then
		return
	end

	self.State.Seeking = true
	self._isseeking = true

	if self:GetLoop() then
		time = time % length
	end

	time = math.min(time, length)

	self._targettime = time
	self:_SetTimeToTargetInternal()
end

function CLASS:_SetTimeToTargetInternal()
	if not IsValid(self.Channel) then return end
	if not self._targettime then return end

	self:TimerRemove("SetTimeToTargetInternal")

	if not self:CanSeek() then
		return
	end

	if self.State.HasBass then
		self.Channel:SetTime(self._targettime)
		return
	end

	local seakToFunc = function()
		if not IsValid(self.Channel) then return true end
		if not self._targettime then return true end

		if not self:CanSeek() then
			return true
		end

		local length = self:GetLength()

		local thistime = self.Channel:GetTime()
		thistime = math.Clamp(thistime, 0, length)

		local targettime = self._targettime
		targettime = math.Clamp(targettime, 0, length)

		if thistime == targettime then
			return true
		end

		-- an attempt to ease it a bit on the performance impact
		local random = math.random() * 2
		local step = math.Clamp(LIBUtil.RealTimeFps() * 0.03 + random, 2, 15)
		local time = math.Approach(thistime, targettime, step)

		time = math.Clamp(time, 0, length)

		-- set the time in non-decode mode, so we keep sane frame rates
		self.Channel:SetTime(time, true)

		if time == targettime then
			return true
		end

		return false
	end

	-- avoid game hiccup during track seeking
	self:TimerUntil("SetTimeToTargetInternal", 0.001, seakToFunc)
	seakToFunc()
end

function CLASS:SyncTime()
	if not self.Valid then return end
	if LIBUtil.GameIsPaused() then return end
	if self:IsStopMode() then return end

	local maxdelta = 1.5

	local time = self:GetMasterTime()

	local length = self:GetLength()
	local curtime = self:GetTime()
	local loop = self:GetLoop()

	if length > 0 then
		local tickLen = engine.TickInterval()
		local minDelta = tickLen * 2
		local maxStartDelta = tickLen * 4

		if length <= maxStartDelta then
			-- never time synchronize extremely short sounds
			return
		end

		if length <= maxdelta and time > maxStartDelta then
			-- prevent permanent seeking loop for very short sounds (length less then 1.5s)
			-- <maxStartDelta> makes sure all clients start at the same time
			-- but ignore further synchronisations past <maxStartDelta>

			return
		end

		-- limit <maxdelta> to the length minus a small margin
		maxdelta = math.min(maxdelta, math.max(length - minDelta, maxStartDelta))
	end

	local maxdelta_half = maxdelta / 2
	local mintime = time - maxdelta_half
	local maxtime = time + maxdelta_half

	if loop and length > 0 then
		-- make sure we wrap the time around start and end currently
		mintime = (length + mintime) % length
		maxtime = (length + maxtime) % length
	end

	mintime = math.max(mintime, 0)
	maxtime = math.max(maxtime, 0)

	if maxtime > mintime then
		-- classic in between check
		if curtime < mintime then
			return self:_SetTimeInternal(time)
		end

		if curtime > maxtime then
			return self:_SetTimeInternal(time)
		end

		return
	end

	if curtime < mintime and curtime > maxtime then
		-- in between check that wraps around looped time positions
		return self:_SetTimeInternal(time)
	end
end

function CLASS:HasEnded()
	if not self.Valid then
		return false
	end

	return self.State.Ended
end

function CLASS:HasEndedInternal()
	if not self.Valid then
		return false
	end

	local curtime = 0
	local length = 0

	if self:GetMuted() then
		return false
	end

	if self:IsKilled() then
		return false
	end

	if not IsValid( self.Channel ) then
		if SERVER then
			local state = self:GetTimeMasterClientState()
			if not state then return false end

			return state.Ended
		end

		return false
	end

	if self:IsEndless() then
		return false
	end

	if self:GetLoop() then
		return false
	end

	local curtime = self:GetTime()
	local length = self:GetLength()
	local timeleft = length - curtime

	-- Sometimes the time can actually lag a bit behind the actual playback position.
	-- So we add a small tolerance to make sure it doesn't get stuck at like 99.999% of the track.
	local minTimeLeft = engine.TickInterval() * 2

	if timeleft > minTimeLeft then
		return false
	end

	return true
end

function CLASS:_IsSeekingInternal()
	if not self.Valid then return false end
	if not IsValid(self.Channel) then return false end

	if self.State.HasBass then
		return self.Channel:IsSeeking()
	end

	if not self:CanSeek() then return false end

	local targettime = self._targettime
	if not targettime then return false end

	local curtime = self:GetRealTime()
	local maxDelta = engine.TickInterval() * 8

	return math.abs(targettime - curtime) > maxDelta
end

function CLASS:IsSeeking()
	if not self.Valid then return false end
	return self._isseeking or false
end

function CLASS:SetMuted( muted )
	if not self.Valid then return end
	self.State.Muted = muted or false
end

function CLASS:GetMuted()
	if not self.Valid then return false end
	return self.State.Muted or false
end

function CLASS:IsKilled()
	if SERVER then return false end
	if not self.Valid then return false end

	return self:GetError() == LIBError.STREAM_SOUND_STOPPED
end

function CLASS:KillStream()
	if SERVER then return end
	if not self.Valid then return end
	if self:IsKilled() then return end

	self:RemoveChannel()
	self:AcceptError(LIBError.STREAM_SOUND_STOPPED)
end

function CLASS:ReviveStream()
	if SERVER then return end
	if not self.Valid then return end
	if not self:IsKilled() then return end

	self:Reconnect()
end

local function getTagsMetaAsTable(channel)
	local meta = channel:GetTagsMeta()
	if not meta then
		return nil
	end

	local result = LIBString.StreamMetaStringToTable(meta)
	return result
end

local g_tagFunctionMap = {
	[StreamRadioLib.TAG_META] = getTagsMetaAsTable,
	[StreamRadioLib.TAG_HTTP] = "GetTagsHTTP",
	[StreamRadioLib.TAG_ID3] = "GetTagsID3",
	[StreamRadioLib.TAG_OGG] = "GetTagsOGG",
	[StreamRadioLib.TAG_VENDOR] = "GetTagsVendor",
}

function CLASS:GetTag(tag)
	if not self.Valid then
		return nil
	end

	local channel = self.Channel
	if not IsValid(channel) then
		return nil
	end

	self._tags = self._tags or {}

	local tab = self._tags[tag] or {}
	self._tags[tag] = tab

	local data = tab.data or {}
	tab.data = data

	local nextCall = tab.nextCall or 0

	local now = RealTime()
	if nextCall > now then
		return data
	end

	tab.nextCall = now + 1

	if self.State.HasBass then
		channel:GetTag(tag, data)
		return data
	end

	local func = g_tagFunctionMap[tag]

	if isstring(func) then
		func = channel[func]
	end

	if not func then
		return nil
	end

	local result = func(channel)
	if not result then
		return nil
	end

	table.CopyFromTo(result, data)
	return data
end

function CLASS:GetMetaTags()
	if not self.Valid then
		return nil
	end

	local data = self:GetTag(StreamRadioLib.TAG_META)
	if not data then
		return nil
	end

	return data
end


function CLASS:GetSamplingRate()
	if not self.Valid then return -1 end
	if not IsValid( self.Channel ) then return -1 end

	return self.Channel:GetSamplingRate( )
end

function CLASS:GetBitsPerSample()
	if not self.Valid then return -1 end
	if not IsValid( self.Channel ) then return -1 end

	return self.Channel:GetBitsPerSample( )
end

function CLASS:GetAverageBitRate()
	if not self.Valid then return -1 end
	if self.State.HasBass then return -1 end -- not in gm_bass yet
	if not IsValid( self.Channel ) then return -1 end

	return self.Channel:GetAverageBitRate( )
end

function CLASS:GetType()
	if not self.Valid then return -1 end
	if not self.State.HasBass then return "UNKNOWN" end
	if not IsValid( self.Channel ) then return "UNKNOWN" end

	return self.Channel:GetFileFormat( )
end

function CLASS:SetVolume( volume )
	if CLIENT then return end
	if not self.Valid then return end
	self.Volume.SVMul = volume or 1
end

function CLASS:GetVolume()
	if not self.Valid then return 0 end
	return self.Volume.SVMul or 0
end

function CLASS:SetClientVolume( volume )
	if SERVER then return end
	if not self.Valid then return end

	self.Volume.CLMul = volume or 1
end

function CLASS:GetClientVolume()
	if SERVER then return 0 end
	if not self.Valid then return 0 end

	return self.Volume.CLMul or 0
end

function CLASS:Set3DPosition( Pos, For, Vel )
	if SERVER then return end
	if not self.Valid then return end

	local WSData = self.WSData

	WSData.Position = Pos or EmptyVector
	WSData.Forward = For or EmptyVector
	WSData.Velocity = Vel or EmptyVector
end

function CLASS:Get3DPosition()
	if SERVER then return EmptyVector, EmptyVector, EmptyVector end
	if not self.Valid then return EmptyVector, EmptyVector, EmptyVector end

	local WSData = self.WSData

	return WSData.Position or EmptyVector, WSData.Forward or EmptyVector, WSData.Velocity or EmptyVector
end

function CLASS:Set3DFadeDistance( diststart, distend )
	if SERVER then return end
	if not self.Valid then return end

	local WSData = self.WSData

	WSData.DistanceStart = diststart or 0
	WSData.DistanceEnd = distend or 0
end

function CLASS:Get3DFadeDistance()
	if SERVER then return 0, 0 end
	if not self.Valid then return 0, 0 end

	local WSData = self.WSData

	return WSData.DistanceStart or 0, WSData.DistanceEnd or 0
end

function CLASS:Set3DCone( iAngle, oAngle, outvolume )
	if SERVER then return end
	if not self.Valid then return end

	local WSData = self.WSData

	WSData.InnerAngle = iAngle or 0
	WSData.OuterAngle = oAngle or 0
	WSData.OutVolume = outvolume or 0
end

function CLASS:Get3DCone()
	if SERVER then return 0, 0, 0 end
	if not self.Valid then return 0, 0, 0 end

	local WSData = self.WSData

	return WSData.InnerAngle or 0, WSData.OuterAngle or 0, WSData.OutVolume or 0
end

CLASS.Set3dcone = CLASS.Set3DCone
CLASS.Get3dcone = CLASS.Get3DCone

function CLASS:IsOnline()
	if not self.Valid then return false end
	return self._isOnline or false
end

function CLASS:IsOnlineUrl()
	if not self.Valid then return false end
	return self._isOnlineUrl or false
end

function CLASS:GetActiveInterfaceName()
	if not self.Valid then return nil end

	local interfaceName = self._interfaceName
	if not interfaceName then return nil end

	return interfaceName
end

function CLASS:IsCached()
	if not self.Valid then return false end
	return self._isCached or false
end

function CLASS:IsCheckingUrl()
	if not self.Valid then return false end
	return self._isCheckingUrl or false
end

function CLASS:IsStopped()
	if not self.Valid then return false end
	if not IsValid( self.Channel ) then return true end

	if self.State.HasBass then
		return self.Channel:GetState( ) == BASS3.ENUM.CHANNEL_STOPPED
	else
		return self.Channel:GetState( ) == GMOD_CHANNEL_STOPPED
	end
end

function CLASS:IsPlaying()
	if not self.Valid then return false end
	if not IsValid( self.Channel ) then return false end

	if self.State.HasBass then
		return self.Channel:GetState( ) == BASS3.ENUM.CHANNEL_PLAYING
	else
		return self.Channel:GetState( ) == GMOD_CHANNEL_PLAYING
	end
end

function CLASS:IsBuffering()
	if not self.Valid then return false end
	if not IsValid( self.Channel ) then return false end

	if self.State.HasBass then
		return self.Channel:GetState( ) == BASS3.ENUM.CHANNEL_STALLED
	else
		return self.Channel:GetState( ) == GMOD_CHANNEL_STALLED
	end
end

function CLASS:IsLoading()
	if not self.Valid then return false end

	if self:HasChannel() then return false end
	if self:HasError() then return false end
	if self._streamTaskUid then return true end

	return false
end

function CLASS:IsActive()
	if not self.Valid then return false end

	if self._streamTaskUid then return false end
	if self:HasChannel() then return true end
	if self:HasError() then return true end

	return false
end

function CLASS:IsActiveOrLoading()
	if not self.Valid then return false end

	if self._streamTaskUid then return true end
	if self:HasChannel() then return true end
	if self:HasError() then return true end

	return false
end

function CLASS:IsRunning()
	if not self.Valid then return false end
	if not IsValid( self.Channel ) then return false end

	if self:IsPlaying() then return true end
	if self:IsLoading() then return true end
	if self:IsCheckingUrl() then return true end
	if self:IsBuffering() then return true end
	if self:IsSeeking() then return true end
	if IsValid( self.Channel ) then return true end

	return false
end

function CLASS:IsCacheAble()
	if not self.Valid then return false end

	return ChannelIsCacheAble( self.Channel )
end

function CLASS:IsEndless()
	if not self.Valid then return false end

	if self.State.HasBass then
		if not IsValid( self.Channel ) then return false end
		return self.Channel:IsEndless()
	end

	return self:GetLength() <= 0
end

function CLASS:IsBlockStreamed()
	if not self.Valid then return false end
	if not IsValid( self.Channel ) then return false end

	return self.Channel:IsBlockStreamed( )
end

function CLASS:CanSeek()
	if not self.Valid then return false end
	if not IsValid( self.Channel ) then return false end

	if self:IsEndless() then return false end
	if self:IsBlockStreamed() then return false end
	if self:IsStopped() then return false end

	local minLen = engine.TickInterval() * 4
	if self:GetMasterLength() <= minLen then return false end

	return true
end

function CLASS:IsLooping()
	if not self.Valid then return false end
	if self:IsEndless() then return false end

	if not IsValid( self.Channel ) then return false end
	return self.Channel:IsLooping()
end

function CLASS:GetSpectrumTable( bars, SPout, func, ... )
	if not self.Valid then return 0 end
	if not IsValid( self.Channel ) then return 0 end
	if self:IsSeeking() then return 0 end

	if ( not bars ) then return 0 end
	if ( bars <= 0 ) then return 0 end

	local count = 0
	local puffersize = bars

	if ( CLIENT ) then
		puffersize = math.Round( bars * ( 22050 / 17000 ) )
	end

	if self.State.HasBass then
		if ( puffersize <= 8 ) then
			count = self.Channel:FFT( SPout, BASS3.ENUM.FFT_16 )
		elseif ( puffersize > 8 ) and ( puffersize <= 16 ) then
			count = self.Channel:FFT( SPout, BASS3.ENUM.FFT_32 )
		elseif ( puffersize > 16 ) and ( puffersize <= 32 ) then
			count = self.Channel:FFT( SPout, BASS3.ENUM.FFT_64 )
		elseif ( puffersize > 32 ) and ( puffersize <= 64 ) then
			count = self.Channel:FFT( SPout, BASS3.ENUM.FFT_128 )
		elseif ( puffersize > 64 ) and ( puffersize <= 128 ) then
			count = self.Channel:FFT( SPout, BASS3.ENUM.FFT_256 )
		elseif ( puffersize > 128 ) and ( puffersize <= 256 ) then
			count = self.Channel:FFT( SPout, BASS3.ENUM.FFT_512 )
		elseif ( puffersize > 256 ) and ( puffersize <= 512 ) then
			count = self.Channel:FFT( SPout, BASS3.ENUM.FFT_1024 )
		elseif ( puffersize > 512 ) and ( puffersize <= 1024 ) then
			count = self.Channel:FFT( SPout, BASS3.ENUM.FFT_2048 )
		elseif ( puffersize > 1024 ) and ( puffersize <= 2048 ) then
			count = self.Channel:FFT( SPout, BASS3.ENUM.FFT_4096 )
		elseif ( puffersize > 2048 ) and ( puffersize <= 4096 ) then
			count = self.Channel:FFT( SPout, BASS3.ENUM.FFT_8192 )
		elseif ( puffersize > 4096 ) then
			count = self.Channel:FFT( SPout, BASS3.ENUM.FFT_16384 )
		end
	else
		if ( puffersize <= 128 ) then
			count = self.Channel:FFT( SPout, FFT_256 )
		elseif ( puffersize > 128 ) and ( puffersize <= 256 ) then
			count = self.Channel:FFT( SPout, FFT_512 )
		elseif ( puffersize > 256 ) and ( puffersize <= 512 ) then
			count = self.Channel:FFT( SPout, FFT_1024 )
		elseif ( puffersize > 512 ) and ( puffersize <= 1024 ) then
			count = self.Channel:FFT( SPout, FFT_2048 )
		elseif ( puffersize > 1024 ) and ( puffersize <= 2048 ) then
			count = self.Channel:FFT( SPout, FFT_4096 )
		elseif ( puffersize > 2048 ) and ( puffersize <= 4096 ) then
			count = self.Channel:FFT( SPout, FFT_8192 )
		elseif ( puffersize > 4096 ) then
			count = self.Channel:FFT( SPout, FFT_16384 )
		end
	end

	if ( SERVER ) then return count end
	if ( not func ) then return count end
	local crash = 100000

	for i = 1, bars do
		crash = crash - 1

		if ( crash == 0 ) then
			error( "Crash!" )
		end

		local bin = math.Round( count / puffersize * i )
		local level = ( SPout[bin] or 0 ) ^ 2
		level = ( math.log10( level ) / 10 )
		level = ( 1 - math.abs( level ) ) ^ 3 * 1.4
		if level <= 0 then continue end
		local Continue = func( i, level, bars, ... )
		if not Continue then break end
	end

	return count
end

local g_tempArray_fft = {}
local g_tempArray_fftc = {}

local g_powres_nobass = nil
local g_powres_bass = nil

local function buildpowres()
	if not g_powres_nobass then
		g_powres_nobass = {}

		g_powres_nobass[0] = FFT_256
		g_powres_nobass[1] = FFT_256
		g_powres_nobass[2] = FFT_256
		g_powres_nobass[3] = FFT_256
		g_powres_nobass[4] = FFT_256
		g_powres_nobass[5] = FFT_256
		g_powres_nobass[6] = FFT_256
		g_powres_nobass[7] = FFT_256
		g_powres_nobass[8] = FFT_512
		g_powres_nobass[9] = FFT_1024
		g_powres_nobass[10] = FFT_2048
		g_powres_nobass[11] = FFT_2048
		g_powres_nobass[12] = FFT_8192
		g_powres_nobass[13] = FFT_16384
		g_powres_nobass[14] = FFT_32768
	end

	if not g_powres_bass then
		if BASS3 and BASS3.ENUM and BASS3.ENUM.FFT_16 then
			g_powres_bass = {}

			g_powres_bass[0] = BASS3.ENUM.FFT_16
			g_powres_bass[1] = BASS3.ENUM.FFT_16
			g_powres_bass[2] = BASS3.ENUM.FFT_16
			g_powres_bass[3] = BASS3.ENUM.FFT_16
			g_powres_bass[4] = BASS3.ENUM.FFT_32
			g_powres_bass[5] = BASS3.ENUM.FFT_64
			g_powres_bass[6] = BASS3.ENUM.FFT_128
			g_powres_bass[7] = BASS3.ENUM.FFT_256
			g_powres_bass[8] = BASS3.ENUM.FFT_512
			g_powres_bass[9] = BASS3.ENUM.FFT_1024
			g_powres_bass[10] = BASS3.ENUM.FFT_2048
			g_powres_bass[11] = BASS3.ENUM.FFT_4096
			g_powres_bass[12] = BASS3.ENUM.FFT_8192
			g_powres_bass[13] = BASS3.ENUM.FFT_16384
			g_powres_bass[14] = BASS3.ENUM.FFT_32768
		end
	end
end

local function getBarFrequency( index, size, samplerate )
	index = math.floor( index or 0 )
	size = math.floor( size or 0 )

	if ( samplerate <= 0 ) then
		return -1
	end

	if ( size <= 0 ) then
		return -1
	end

	if ( index <= 0 ) then
		return -1
	end

	if ( index > size ) then
		size = index
	end

	return (index - 1) / (size * 2) * samplerate
end

function CLASS:GetSpectrum( resolution, func, minfrq, maxfrq )
	if not self.Valid then return false end
	if not IsValid(self.Channel) then return false end
	if self:IsSeeking() then return false end

	buildpowres()

	local powres = self.State.HasBass and g_powres_bass or g_powres_nobass

	resolution = resolution or 0
	resolution = powres[resolution]

	if not resolution then return false end
	if not isfunction(func) then return false end

	local samplerate = self:GetSamplingRate()
	minfrq = minfrq or 0
	maxfrq = maxfrq or samplerate

	local count = self.Channel:FFT( g_tempArray_fft, resolution )

	local index = 0
	for i = 1, count do
		local level = g_tempArray_fft[i] or 0

		local frq = getBarFrequency(i, count, samplerate)

		if frq < 0 then
			continue
		end

		if frq < minfrq then
			continue
		end

		if frq > maxfrq then
			break
		end

		if not func( index, frq, level ) then
			break
		end

		index = index + 1
	end

	return true
end

local function calcAngleFromComplex(R, I)
	R = R or 0
	I = I or 0

	return math.atan2( I, R )
end

local function calcLengthFromComplex(R, I)
	R = R or 0
	I = I or 0

	if ( ( R == 0 ) and ( I == 0 ) ) then
		return 0
	end

	return math.sqrt( ( R ^ 2 ) + ( I ^ 2 ) )
end

function CLASS:GetSpectrumComplex( resolution, func, minfrq, maxfrq )
	if not self.Valid then return false end
	if not IsValid(self.Channel) then return false end
	if self:IsSeeking() then return false end

	buildpowres()

	local powres = self.State.HasBass and g_powres_bass or g_powres_nobass

	resolution = resolution or 0
	resolution = powres[resolution]

	if not resolution then return false end
	if not isfunction(func) then return false end

	local samplerate = self:GetSamplingRate()
	minfrq = minfrq or 0
	maxfrq = maxfrq or samplerate

	local count = 0
	local index = 0

	if self.State.HasBass then
		count = self.Channel:FFTComplex( g_tempArray_fftc, resolution )

		for i = 1, count, 2 do
			local level_R = g_tempArray_fftc[i] or 0
			local level_I = g_tempArray_fftc[i + 1] or 0

			local frq = getBarFrequency(i, count / 2, samplerate)

			if frq < 0 then
				continue
			end

			if frq < minfrq then
				continue
			end

			if frq > maxfrq then
				break
			end

			local level_length = calcLengthFromComplex(level_R, level_I);
			local level_ang = calcAngleFromComplex(level_R, level_I);

			if not func( index, frq, level_length, level_ang, level_R, level_I ) then
				break
			end

			index = index + 1
		end
	else
		count = self.Channel:FFT( g_tempArray_fft, resolution )

		for i = 1, count do
			local level = g_tempArray_fft[i] or 0

			local frq = getBarFrequency(i, count, samplerate)

			if frq < 0 then
				continue
			end

			if frq < minfrq then
				continue
			end

			if frq > maxfrq then
				break
			end

			if not func( index, frq, level, nil, level, nil ) then
				break
			end

			index = index + 1
		end
	end

	return true
end

function CLASS:PreDupe()
	local data = {}

	data.url = self:GetURL()
	data.streamname = self:GetStreamName()
	data.loop = self:GetLoop()
	data.volume = self:GetVolume()

	data.playstate = self.State.PlayMode

	return data
end

function CLASS:PostDupe(data)
	local ent = self:GetEntity()

	if not IsValid(ent) then
		return
	end

	self:SetLoop(data.loop)
	self:SetVolume(data.volume)

	ent:SetDupeURL(data.url, data.streamname, data.playstate ~= StreamRadioLib.STREAM_PLAYMODE_STOP)

	self.State.PlayMode = data.playstate
end

function CLASS:OnSearch(url)
	-- override
	return true -- Allow url to be played
end

function CLASS:CanSkipUrlChecks(url)
	-- override
	return false -- Ignore the build-in whitelist?
end

function CLASS:CanBypassUrlBlock(url, blockedByHook)
	-- override
	return false -- Bypass the URL block?
end

function CLASS:OnClose()
	-- override
end

function CLASS:OnDownload(internalUrl, interface)
	-- override
	return true -- Allow download to cache
end

function CLASS:OnConnect(channel)
	-- override
end

function CLASS:OnRetry(err, internalUrl, state, interface)
	-- override
	return true -- Retry again?
end

function CLASS:OnError(err)
	-- override
end

function CLASS:OnMute(muted)
	-- override
end

return true

