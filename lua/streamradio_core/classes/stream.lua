local tostring = tostring
local tonumber = tonumber
local type = type
local isfunction = isfunction
local IsValid = IsValid
local Vector = Vector
local setmetatable = setmetatable

local sound = sound
local util = util
local string = string
local math = math
local hook = hook
local SERVER = SERVER
local CLIENT = CLIENT

local EmptyVector = Vector()
local catchAndErrorNoHalt = StreamRadioLib.CatchAndErrorNoHalt


local BASS3 = BASS3 or {}

StreamRadioLib.STREAM_PLAYMODE_STOP = 0
StreamRadioLib.STREAM_PLAYMODE_PAUSE = 1
StreamRadioLib.STREAM_PLAYMODE_PLAY = 2
StreamRadioLib.STREAM_PLAYMODE_PLAY_RESTART = 3

StreamRadioLib.STREAM_URLTYPE_FILE = 0
StreamRadioLib.STREAM_URLTYPE_CACHE = 1
StreamRadioLib.STREAM_URLTYPE_ONLINE = 2
StreamRadioLib.STREAM_URLTYPE_ONLINE_NOCACHE = 3

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

local function ChannelIsCacheAble( channel )
	if ( not IsValid( channel ) ) then return false end

	local len = channel:GetLength( )
	return len > 0
end

local function ChannelStop( channel )
	if ( not channel ) then
		return nil
	end

	channel:Stop()

	if channel.Remove then
		channel:Remove( )
	end

	return nil
end

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

function CLASS:Create()
	BASE.Create(self)

	self.Channel = nil
	self.Metadata = {}
	self.TimeOffset = 0
	self.ChannelChanged = false

	if CLIENT then
		self.CV_Volume = StreamRadioLib.Settings.GetConVar("volume")
		if IsValid(self.CV_Volume) then
			self.CV_Volume:SetEvent("OnChange", self:GetID(), function()
				self:UpdateChannelVolume()
			end)
		end
	end

	self.URL = self:CreateListener({
		extern = "",
		active = "",
	}, function(this, k, v)
		if k == "extern" then
			v = string.Trim(tostring(v or ""))
			self.URL.extern = v

			self:SetNWString("URL", v)

			self.TimeOffset = 0
			self._wouldpredownload = nil
			self._LastMasterState = nil
			self._server_override_timedata = nil
			self.Old_ClientStateListBuffer = nil
			self:SetClientStateOnServer("Time", 0)

			self._isCached = nil
			self._isOnline = nil
			self._converter_meta = nil

			self.ChannelChanged = true
			self:Update()
			return
		end

		if k == "active" then
			self.TimeOffset = 0
			self._wouldpredownload = nil
			self._LastMasterState = nil
			self._server_override_timedata = nil
			self.Old_ClientStateListBuffer = nil
			self:SetClientStateOnServer("Time", 0)

			self:RemoveChannel()
			return
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
				self:QueueCall("Retry")
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

	for i,v in ipairs(self.StateTable) do
		self.StateTable_r[v] = i
	end

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
		HasBass = CLIENT and StreamRadioLib.HasBass,
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
		end

		if k == "Muted" then
			self:UpdateChannelMuted()
			self:CallHook("OnMute", v)
		end

		if k == "Name" then
			self:RemoveChannel(true)
			self:Retry()
			self:SetNWString("Name", v)
		end

		if k == "Ended" and v then
			self:Pause()
			self:CallHook("OnTrackEnd")
		end

		if k == "HasBass" then
			self:Retry()
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

	self:StartSuperThink()
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)

	if SERVER then
		self:SetNWFloat("Volume", self.Volume.SVMul)
		self:SetNWString("URL", self.URL.extern)
		self:SetNWInt("PlayMode", self.State.PlayMode)
		self:SetNWBool("Loop", self.State.Loop)
		self:SetNWString("Name", self.State.Name)
		return
	end

	self:SetNWVarProxy("Volume", function(this, nwkey, oldvar, newvar)
		self.Volume.SVMul = newvar
	end)

	self:SetNWVarProxy("URL", function(this, nwkey, oldvar, newvar)
		self.URL.extern = newvar
	end)

	self:SetNWVarProxy("PlayMode", function(this, nwkey, oldvar, newvar)
		self.State.PlayMode = newvar
	end)

	self:SetNWVarProxy("Loop", function(this, nwkey, oldvar, newvar)
		self.State.Loop = newvar
	end)

	self:SetNWVarProxy("Name", function(this, nwkey, oldvar, newvar)
		self.State.Name = newvar
	end)

	self.Volume.SVMul = self:GetNWFloat("Volume", 1)
	self.URL.extern = self:GetNWString("URL", "")
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

		sendbuffer[#sendbuffer + 1] = {
			key = key,
			key_index = key_index,
			value = value,
		}

		self.Old_ClientStateListBuffer[key] = value
	end

	self:NetSend("clientstate", function()
		net.WriteUInt(#sendbuffer, 16)

		for i, v in pairs(sendbuffer) do
			local key = v.key
			local value = v.value
			local key_index = v.key_index

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

function CLASS:SuperThink()
	self:CalcTime()

	self.State.Ended = self:HasEnded()
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
			local maxDt = engine.TickInterval() * 4

			if dt >= maxDt then
				self:SetNWFloat("MasterTime", timeA)
			end
		end
	end

	self:SyncTime()
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

	if not IsValid( self.Channel ) and ( self.State.Error == 0 ) and not self:StillSearching() then
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

	self:Retry()
end

function CLASS:UpdateChannelWS()
	if not self:Is3DChannel() then return end

	self.Channel:SetPos( self.WSData.Position, self.WSData.Forward, self.WSData.Velocity )
	self.Channel:Set3DFadeDistance( self.WSData.DistanceStart, self.WSData.DistanceEnd )
	self.Channel:Set3DCone( self.WSData.InnerAngle, self.WSData.OuterAngle, self.WSData.OutVolume )
end

function CLASS:UpdateChannelVolume()
	if SERVER then return end
	if not self.Valid then return end
	if not IsValid( self.CV_Volume ) then return end
	if not IsValid( self.Channel ) then return end

	local boost3d = self:Is3DChannel() and 2.00 or 1

	local SVvol = self.Volume.SVMul
	local CLvol = self.Volume.CLMul
	local MuteSlide = self.Volume.MuteSlide

	local volume = 0

	if not MuteSlide then
		volume = SVvol * CLvol * self.CV_Volume:GetValue() * boost3d
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

	if self.URL.extern == "" then
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
		self.Channel:Play(true)
		self.State.PlayMode = StreamRadioLib.STREAM_PLAYMODE_PLAY
		return
	end

	if playmode == StreamRadioLib.STREAM_PLAYMODE_PLAY then
		self.Channel:Play(false)
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

	self.Channel = nil
	self.State.Error = 0
	self.Metadata = {}
	self._tags = nil
	self._isCached = nil
	self._isOnline = nil
	self._converter_meta = nil

	if clearlast then
		self.TimeOffset = 0
		self._wouldpredownload = nil
		self._LastMasterState = nil
		self._server_override_timedata = nil
		self.URL.active = ""

		self.Old_ClientStateListBuffer = nil
		self:SetClientStateOnServer("Time", 0)
	end
end

function CLASS:Remove()
	self:RemoveChannel(true)

	if IsValid(self.CV_Volume) then
		self.CV_Volume:RemoveEvent("OnChange", self:GetID())
	end

	BASE.Remove(self)
end

function CLASS:ToString()
	local r = BASE.ToString(self)
	if not self.Valid then
		return r
	end

	r = r .. " <" .. tostring( self:GetChannel() or "no channel" ) .. "> [err:" .. self:GetError() .. "]"
	return r
end

function CLASS:__eq( other )
	if not BASE.__eq(self, other) then return false end
	if self.Channel == other.Channel then return true end

	return false
end

function CLASS:IsLoading()
	if not self.Valid then return false end
	if not self:StillSearching() then return false end
	if IsValid(self.Channel) then return false end
	if self.State.Error ~= 0 then return false end

	return true
end

function CLASS:IsDownloading()
	if not self.Valid then return false end
	if not self._converter_downloads then return false end

	for k, v in pairs(self._converter_downloads) do
		return true
	end

	return false
end

function CLASS:IsDownloadingToCache()
	if not self.Valid then return false end
	if not self._cache_downloads then return false end

	for k, v in pairs(self._cache_downloads) do
		return true
	end

	return false
end

function CLASS:SetBASSEngineEnabled(bool)
	if not StreamRadioLib.HasBass then
		bool = false
	end

	self.State.HasBass = bool or false
end

function CLASS:IsBASSEngineEnabled()
	if not StreamRadioLib.HasBass then return false end
	return self.State.HasBass or false
end

function CLASS:StillSearching()
	if not self.Valid then return false end
	if self.URL.extern == "" then return false end
	if self.URL.active == "" then return false end
	if self.URL.active ~= self.URL.extern then return false end

	if self:GetMuted() then return false end
	if self.State.Stopped then return false end

	if IsValid(self.Channel) then return false end
	if self.State.Error ~= 0 then return false end

	return true
end

function CLASS:Retry()
	self:RemoveChannel()
	return self:Connect()
end

function CLASS:Connect()
	self.URL.active = self.URL.extern

	if self.State.PlayMode == StreamRadioLib.STREAM_PLAYMODE_STOP or self.URL.extern == "" then
		self:UpdateChannelPlayMode()
		return
	end

	if not self:CallHook("OnSearch", self.URL.extern ) then
		self.URL.active = ""
		self:AcceptStream( nil, 2 )
		return false
	end

	return self:Reconnect()
end

function CLASS:Reconnect( timeout )
	if not self:StillSearching() then
		return false
	end

	self:TimerRemove("stream")

	if StreamRadioLib.IsBlockedURLCode( self.URL.extern ) then
		self:AcceptStream( nil, 1000 )
		return true
	end

	timeout = timeout or 0

	local playfunc = function()
		if not self:StillSearching() then
			return false
		end

		local loading = self:PlayStreamInternal()

		if not loading then
			self:AcceptStream( nil, -1 )
			return false
		end

		return true
	end

	if timeout <= 0 then
		return playfunc()
	else
		self:TimerOnce("stream", timeout, playfunc)
	end

	return true
end

function CLASS:AcceptStream( channel, err )
	if not self:StillSearching() then
		return false
	end

	err = err or 0

	if not IsValid(channel) or err ~= 0 then
		ChannelStop(channel)
		channel = nil

		if err == 0 then
			err = -1
		end
	end

	ChannelStop(self.Channel)

	self:CleanUpClientStateList()

	if err == 0 then
		self.Channel = channel
		self._tags = nil
		self.State.Error = 0

		self:UpdateChannel()
		self:CallHook("OnConnect", self.Channel)
	else
		self.URL.active = ""

		self.Channel = nil
		self._tags = nil
		self.State.Error = err

		self:SetClientStateOnServer("Time", 0)
		self:CallHook("OnError", self.State.Error)
	end

	return true
end

function CLASS:PlayStreamInternal(nodownload)
	if not self.State.HasBass and SERVER then
		return false
	end

	if not self:StillSearching() then
		return true
	end

	local URL, URLtype = StreamRadioLib.ConvertURL(self.URL.extern)
	local URLonline = (URLtype ~= StreamRadioLib.STREAM_URLTYPE_FILE) and (URLtype ~= StreamRadioLib.STREAM_URLTYPE_CACHE)

	self._isCached = URLtype == StreamRadioLib.STREAM_URLTYPE_CACHE
	self._isOnline = URLonline

	self.Metadata = {}

	if not URLonline then
		return self:_PlayStreamInternal(URL, URLtype)
	end

	local function afterdl()
		if not IsValid(self) then return end

		if not self._converter_downloads then return end
		if not self._converter_downloads[URL] then return end

		self._converter_downloads[URL] = nil

		if not self:StillSearching() then return end

		self:SetTime(0)
		self:PlayStreamInternal(true)
	end

	local tryconverting = StreamRadioLib.Interface.Convert(URL, function(interface, success, convered_url, errorcode, data)
		if not IsValid(self) then return end
		if not self:StillSearching() then return end

		if not success then
			if not errorcode then return end

			self:AcceptStream(nil, errorcode)
			return
		end

		local converter_meta = data.custom_data.meta or {}
		local converter_name = nil

		if converter_meta.interface then
			converter_name = converter_meta.interface and converter_meta.interface.name

			if converter_meta.subinterface then
				converter_name = converter_name .. "/" .. converter_meta.subinterface.name
			end
		end

		self.Metadata = {
			title = converter_meta.title,
			filesize = converter_meta.filesize,
			converter_name = converter_name,
		}

		if not nodownload and interface.download then
			local dltimeout = interface.download_timeout or 0
			local filesize = -1
			local allowdl = true

			if data.custom_data.meta then
				filesize = data.custom_data.meta.filesize or -1
				allowdl = data.custom_data.meta.download or false
			end

			local CanDownload = allowdl and StreamRadioLib.Cache.CanDownload(filesize) and self:CallHook("OnDownload", URL, interface)

			if CanDownload then
				self._converter_downloads = self._converter_downloads or {}
				self._converter_downloads[URL] = true
				self._wouldpredownload = true

				self:TimerRemove("download_after")
				self:TimerRemove("download_timeout")

				if dltimeout > 0 then
					self:TimerOnce("download_timeout", dltimeout, function()
						self:TimerRemove("download_after")
						afterdl()
					end)
				end

				local dlstarted = StreamRadioLib.Cache.Download(convered_url, function(len, headers, code, saved)
					self:TimerOnce("download_after", 0.5, function()
						self:TimerRemove("download_timeout")
						afterdl()
					end)
				end, URL)

				if dlstarted then
					return
				end

				self._converter_downloads[URL] = nil
				self:TimerRemove("download_after")
				self:TimerRemove("download_timeout")
			end
		end

		self:_PlayStreamInternal(convered_url, StreamRadioLib.STREAM_URLTYPE_ONLINE_NOCACHE)
	end)

	if tryconverting then return true end
	return self:_PlayStreamInternal(URL, URLtype)
end

function CLASS:_PlayStreamInternal(URL, URLtype, no3d, noBlock, retrycount)
	if not self:StillSearching() then
		return true
	end

	local URLonline = (URLtype ~= StreamRadioLib.STREAM_URLTYPE_FILE) and (URLtype ~= StreamRadioLib.STREAM_URLTYPE_CACHE)
	local Play3D = CLIENT and self.WSData and self.WSData.WorldSound and not no3d
	retrycount = retrycount or 0

	if noBlock == nil then
		noBlock = true
	end

	local StreamCallback = function( channel, err )
		if not IsValid( self ) then
			ChannelStop( channel )
			return
		end

		self:AcceptStream( channel, err, self._converter_meta )
	end

	local callback = function( channel, err )
		err = tonumber(err) or 0

		if not IsValid( self ) then
			ChannelStop( channel )
			return
		end

		if not self:StillSearching() then
			ChannelStop( channel )
			return
		end

		if not IsValid( channel ) or ( err ~= 0 ) then
			ChannelStop( channel )
			channel = nil

			if err == 0 then
				err = -1
			end
		end

		if err == 40 then
			if self:CallHook("OnRetry", err, URL, URLtype) then
				self:TimerOnce("stream", URLonline and 2 or 0, function()
					if not IsValid( self ) then return end
					if not self:StillSearching() then return end

					if retrycount >= 3 then
						self:AcceptStream( nil, err )
						return
					end

					local loading = self:_PlayStreamInternal( URL, URLtype, no3d, noBlock, retrycount + 1 )
					if not loading then
						self:AcceptStream( nil, -1 )
					end
				end)

				return
			end
		end

		-- retry in Non-3D if 3D is not working
		if Play3D and retry_errors_non3d[err] then
			if self:CallHook("OnRetry", err, URL, URLtype) then
				self:TimerOnce("stream", URLonline and 2 or 0, function()
					if not IsValid( self ) then return end
					if not self:StillSearching() then return end

					local loading = self:_PlayStreamInternal( URL, URLtype, true, noBlock )
					if not loading then
						self:AcceptStream( nil, -1 )
					end
				end)

				return
			end
		else
			-- retry in block mode if no-block mode is not working
			if noBlock and retry_errors_block[err] then
				if self:CallHook("OnRetry", err, URL, URLtype) then
					self:TimerOnce("stream", URLonline and 2 or 0, function()
						if not IsValid( self ) then return end
						if not self:StillSearching() then return end
	
						local loading = self:_PlayStreamInternal( URL, URLtype, true, false )
						if not loading then
							self:AcceptStream( nil, -1 )
						end
					end)
	
					return
				end
			end	
		end

		if not ChannelIsCacheAble(channel) then
			-- remove broken cache file
			if URLtype == StreamRadioLib.STREAM_URLTYPE_CACHE then
				StreamRadioLib.Cache.DeleteFileRaw( URL )
			else
				StreamRadioLib.Cache.DeleteFile( URL )
			end
		else
			if URLtype == StreamRadioLib.STREAM_URLTYPE_ONLINE then
				local CanDownload = self:CallHook("OnDownload", URL, nil)

				if CanDownload then
					self._cache_downloads = self._cache_downloads or {}
					self._cache_downloads[URL] = true

					local dlstarted = StreamRadioLib.Cache.Download(URL, function(len, headers, code, saved)
						self._cache_downloads[URL] = nil
					end)

					if not dlstarted then
						self._cache_downloads[URL] = nil
					end
				end
			end
		end

		StreamCallback( channel, err )
	end

	local safeCallback = function(...)
		catchAndErrorNoHalt(callback, ...)
	end

	if not URLonline then
		-- avoid playing non existing files to avoid crashing
		if not file.Exists( URL, "GAME" ) then
			safeCallback( nil, 2 )
			return true
		end
	else
		-- make sure we have a clean online url
		URL = StreamRadioLib.NormalizeURL(URL)
	end

	local playfunc = nil
	local Mode = nil

	if self.State.HasBass then
		Mode = BASS3.ENUM.MODE_NOPLAY

		if Play3D then
			Mode = bit.bor( Mode, BASS3.ENUM.MODE_3D )
		end

		if noBlock then
			Mode = bit.bor( Mode, BASS3.ENUM.MODE_NOBLOCK )
		end

		playfunc = URLonline and BASS3.PlayURL or BASS3.PlayFile
		if not isfunction( playfunc ) then
			return false
		end

		return playfunc( URL, Mode, safeCallback )
	end

	Mode = "noplay "

	if Play3D then
		Mode = Mode .. "3d "
	end

	if noBlock then
		Mode = Mode .. "noblock "
	end

	playfunc = URLonline and sound.PlayURL or sound.PlayFile
	if not isfunction( playfunc ) then
		return false
	end

	playfunc( URL, Mode, safeCallback )
	return true
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
	if not self.Valid then return 0 end
	return self.State.Error or 0
end

function CLASS:GetMetadata()
	if not self.Valid then return {} end
	return self.Metadata or {}
end

function CLASS:SetURL( url )
	if not self.Valid then return end
	if CLIENT and self.Network.Active then return end

	self.URL.extern = url
end

function CLASS:GetURL()
	if not self.Valid then return "" end
	return self.URL.extern or ""
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

	if time < 0 then
		time = 0
	end

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
		local calctime = time + offset

		if loop and len > 0 then
			return calctime % len
		end

		if len > 0 then
			calctime = math.min(calctime, len)
		end

		return math.max(calctime, 0)
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

	if self:IsEndless() then
		time = time + self.TimeOffset
	end

	if time < 0 then
		time = 0
	end

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

	if self:IsBlockStreamed() then
		return
	end

	self:_SetTimeInternal(time)
end

function CLASS:_SetTimeInternal(time)

	time = tonumber(time) or 0
	if time < 0 then
		time = 0
	end

	local length = self:GetLength()

	if self:IsEndless() then
		self.TimeOffset = time - self:GetRealTime()
		return
	end

	self.TimeOffset = 0

	if self:IsBlockStreamed() then
		return
	end

	self.State.Seeking = true
	self._isseeking = true

	if self:GetLoop() then
		self._targettime = time % length
		self:_SetTimeToTargetInternal()

		return
	end

	if time > length then
		time = length
	end

	self._targettime = time
	self:_SetTimeToTargetInternal()
end

function CLASS:_SetTimeToTargetInternal()
	if not IsValid(self.Channel) then return end
	if not self._targettime then return end

	self:TimerRemove("SetTimeToTargetInternal")

	if self:IsBlockStreamed() then
		return
	end

	if self.State.HasBass then
		self.Channel:SetTime(self._targettime)
		return
	end

	-- avoid game hiccup during track seeking
	self:TimerUtil("SetTimeToTargetInternal", 0.001, function()
		if not IsValid(self.Channel) then return true end
		if not self._targettime then return true end

		if self:IsBlockStreamed() then
			return true
		end

		local thistime = self.Channel:GetTime()
		local targettime = self._targettime

		if thistime == targettime then return true end

		local time = 0
		local step = 10

		if thistime < targettime then
			time = math.min(thistime + step, targettime)
		else
			time = math.max(thistime - step, targettime)
		end

		self.Channel:SetTime(time)
		if time == targettime then return true end

		return false
	end)
end

function CLASS:SyncTime()
	if not self.Valid then return end
	if StreamRadioLib.GameIsPaused() then return end
	if not self:IsPlayMode() then return end

	local maxdelta = 1.5

	local time = self:GetMasterTime()

	if self:IsEndless() then
		return self:_SetTimeInternal(time)
	end

	local length = self:GetLength()

	local curtime = self:GetTime()
	local loop = self:GetLoop()
	local maxStartDelta = engine.TickInterval() * 4

	if length <= maxdelta and time > maxStartDelta then
		return
	end

	maxdelta = math.min(maxdelta, length)

	local maxdelta_half = maxdelta / 2
	local mintime = time - maxdelta_half
	local maxtime = time + maxdelta_half

	if loop then
		mintime = (length + mintime) % length
		maxtime = (length + maxtime) % length
	end

	mintime = math.max(mintime, 0)
	maxtime = math.max(maxtime, 0)

	if maxtime > mintime then
		if curtime < mintime then
			return self:_SetTimeInternal(time)
		end

		if curtime > maxtime then
			return self:_SetTimeInternal(time)
		end

		return
	end

	if curtime < mintime and curtime > maxtime then
		return self:_SetTimeInternal(time)
	end
end

function CLASS:HasEnded()
	if not self.Valid then
		return false
	end

	local curtime = 0
	local length = 0

	if self:GetMuted() then
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

	if timeleft > 0 then
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

	if self:IsEndless() then return false end
	if self:IsBlockStreamed() then return false end

	local targettime = self._targettime
	if not targettime then return false end

	local curtime = self:GetRealTime()
	local maxDelta = engine.TickInterval() * 8

	return math.abs(targettime - curtime) > maxDelta
end

function CLASS:IsSeeking()
	if not self.Valid then return end
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

function CLASS:GetTag(tag)
	if not self.Valid then return nil end
	if not self.State.HasBass then return nil end
	if not IsValid(self.Channel) then return nil end
	if not tag then return nil end

	self._tags = self._tags or {}
	self._tags[tag] = self._tags[tag] or {}

	return self.Channel:GetTag(tag, self._tags[tag])
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

	self.WSData.Position = Pos or EmptyVector
	self.WSData.Forward = For or EmptyVector
	self.WSData.Velocity = Vel or EmptyVector
end

function CLASS:Get3DPosition()
	if SERVER then return EmptyVector, EmptyVector, EmptyVector end
	if not self.Valid then return EmptyVector, EmptyVector, EmptyVector end

	return self.WSData.Position or EmptyVector, self.WSData.Forward or EmptyVector, self.WSData.Velocity or EmptyVector
end

function CLASS:Set3DFadeDistance( diststart, distend )
	if SERVER then return end
	if not self.Valid then return end

	self.WSData.DistanceStart = diststart or 0
	self.WSData.DistanceEnd = distend or 0
end

function CLASS:Get3DFadeDistance()
	if SERVER then return 0, 0 end
	if not self.Valid then return 0, 0 end

	return self.WSData.DistanceStart or 0, self.WSData.DistanceEnd or 0
end

function CLASS:Set3DCone( iAngle, oAngle, outvolume )
	if SERVER then return end
	if not self.Valid then return end

	self.WSData.InnerAngle = iAngle or 0
	self.WSData.OuterAngle = oAngle or 0
	self.WSData.OutVolume = outvolume or 0
end

function CLASS:Get3DCone()
	if SERVER then return 0, 0, 0 end
	if not self.Valid then return 0, 0, 0 end

	return self.WSData.InnerAngle or 0, self.WSData.OuterAngle or 0, self.WSData.OutVolume or 0
end

CLASS.Set3dcone = CLASS.Set3DCone
CLASS.Get3dcone = CLASS.Get3DCone

function CLASS:IsOnline()
	if not self.Valid then return false end
	return self._isOnline or false
end

function CLASS:IsCached()
	if not self.Valid then return false end
	return self._isCached or false
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

function CLASS:IsRunning()
	if not self.Valid then return false end
	if not IsValid( self.Channel ) then return false end

	if self:IsPlaying() then return true end
	if self:IsLoading() then return true end
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

local tempArray_fft = {}
local tempArray_fftc = {}
local powres_bass = {}

if StreamRadioLib.HasBass then
	powres_bass[0] = BASS3.ENUM.FFT_16
	powres_bass[1] = BASS3.ENUM.FFT_16
	powres_bass[2] = BASS3.ENUM.FFT_16
	powres_bass[3] = BASS3.ENUM.FFT_16
	powres_bass[4] = BASS3.ENUM.FFT_32
	powres_bass[5] = BASS3.ENUM.FFT_64
	powres_bass[6] = BASS3.ENUM.FFT_128
	powres_bass[7] = BASS3.ENUM.FFT_256
	powres_bass[8] = BASS3.ENUM.FFT_512
	powres_bass[9] = BASS3.ENUM.FFT_1024
	powres_bass[10] = BASS3.ENUM.FFT_2048
	powres_bass[11] = BASS3.ENUM.FFT_4096
	powres_bass[12] = BASS3.ENUM.FFT_8192
	powres_bass[13] = BASS3.ENUM.FFT_16384
	powres_bass[14] = BASS3.ENUM.FFT_32768
end

local powres_nobass = {
	[0] = FFT_256,
	[1] = FFT_256,
	[2] = FFT_256,
	[3] = FFT_256,
	[4] = FFT_256,
	[5] = FFT_256,
	[6] = FFT_256,
	[7] = FFT_256,
	[8] = FFT_512,
	[9] = FFT_1024,
	[10] = FFT_2048,
	[11] = FFT_2048,
	[12] = FFT_8192,
	[13] = FFT_16384,
	[14] = FFT_32768,
}

function CLASS:GetSpectrum( resolution, func, minfrq, maxfrq )
	if not self.Valid then return false end
	if not IsValid(self.Channel) then return false end
	if self:IsSeeking() then return false end

	local powres = self.State.HasBass and powres_bass or powres_nobass

	resolution = resolution or 0
	resolution = powres[resolution]

	if not resolution then return false end
	if not isfunction(func) then return false end

	local samplerate = self:GetSamplingRate()
	minfrq = minfrq or 0
	maxfrq = maxfrq or samplerate

	local count = self.Channel:FFT( tempArray_fft, resolution )

	local index = 0
	for i = 1, count do
		local level = tempArray_fft[i] or 0

		local frq = self:GetBarFrequency(i, count, samplerate)

		if ( frq < 0 ) then
			continue
		end

		if ( frq < minfrq ) then
			continue
		end

		if ( frq > maxfrq ) then
			break
		end

		if ( not func( index, frq, level ) ) then
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

	local powres = self.State.HasBass and powres_bass or powres_nobass

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
		count = self.Channel:FFTComplex( tempArray_fftc, resolution )

		for i = 1, count, 2 do
			local level_R = tempArray_fftc[i] or 0
			local level_I = tempArray_fftc[i+1] or 0

			local frq = self:GetBarFrequency(i, count / 2, samplerate)

			if ( frq < 0 ) then
				continue
			end

			if ( frq < minfrq ) then
				continue
			end

			if ( frq > maxfrq ) then
				break
			end

			local level_length = calcLengthFromComplex(level_R, level_I);
			local level_ang = calcAngleFromComplex(level_R, level_I);

			if ( not func( index, frq, level_length, level_ang, level_R, level_I ) ) then
				break
			end

			index = index + 1
		end
	else
		count = self.Channel:FFT( tempArray_fft, resolution )

		for i = 1, count do
			local level = tempArray_fft[i] or 0

			local frq = self:GetBarFrequency(i, count, samplerate)

			if ( frq < 0 ) then
				continue
			end

			if ( frq < minfrq ) then
				continue
			end

			if ( frq > maxfrq ) then
				break
			end

			if ( not func( index, frq, level, nil, level, nil ) ) then
				break
			end

			index = index + 1
		end
	end

	return true
end

function CLASS:GetBarFrequency( index, size, samplerate )
	index = math.floor( index or 0 )
	size = math.floor( size or 0 )
	samplerate = samplerate or self:GetSamplingRate()

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

function CLASS:PreDupe(ent)
	local data = {}

	data.url = self:GetURL()
	data.streamname = self:GetStreamName()
	data.loop = self:GetLoop()
	data.volume = self:GetVolume()

	data.playstate = self.State.PlayMode

	return data
end

function CLASS:PostDupe(ent, data)
	self:SetURL(StreamRadioLib.FilterCustomURL(data.url))

	self:SetStreamName(data.streamname)
	self:SetLoop(data.loop)
	self:SetVolume(data.volume)

	self.State.PlayMode = data.playstate
end

function CLASS:OnSearch( url, urltype )
	-- override
	return true -- Allow url to be played
end

function CLASS:OnClose()
	-- override
end

function CLASS:OnDownload( url, interface )
	-- override
	return true -- Allow download to cache
end

function CLASS:OnConnect( channel )
	-- override
end

function CLASS:OnRetry( err, url, urltype )
	-- override
	return true -- retry again?
end

function CLASS:OnError( err )
	-- override
end

function CLASS:OnMute( muted )
	-- override
end
