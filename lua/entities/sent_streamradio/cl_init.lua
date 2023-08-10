include("shared.lua")
DEFINE_BASECLASS("base_streamradio_gui")

local StreamRadioLib = StreamRadioLib

function ENT:StopTuneSound()
	if not self.NoiseSound then return end

	local stream = self.StreamObj
	if IsValid(streamj) then
		stream:TimerRemove("tunesoundstart")
		stream:TimerRemove("tunesound")
	end

	self.NoiseSound:Stop( )
	self.NoiseSound = nil
end

function ENT:FadeoutTuneSound(time)
	if not self.NoiseSound then return end

	local stream = self.StreamObj
	if IsValid(streamj) then
		stream:TimerRemove("tunesoundstart")
		stream:TimerRemove("tunesound")
	end

	if not self.NoiseSound:IsPlaying() then
		return
	end

	self.NoiseSound_vol = 0
end

function ENT:StartTuneSound(delay)
	local stream = self.StreamObj
	if not IsValid(stream) then
		return
	end

	if IsValid(stream) then
		stream:TimerRemove("tunesound")
		stream:TimerRemove("tunesoundstart")
	end

	delay = delay or 0

	stream:TimerOnce("tunesoundstart", delay, function()
		if not IsValid(self) then return end

		if IsValid(stream:GetChannel()) then
			self:StopTuneSound()
			return
		end

		self:CreateTuneSound()
		if not self.NoiseSound then return end

		if IsValid(stream) then
			stream:TimerRemove("tunesound")
			stream:TimerRemove("tunesoundstart")
		end

		if self.NoiseSound:IsPlaying() then
			return
		end

		self.NoiseSound_vol = 1
		self.NoiseSound:PlayEx(0, 100)
	end)
end

function ENT:CreateTuneSound()
	if self.NoiseSound then
		return self.NoiseSound
	end

	if not self.Sounds_Noise then return end
	if self.Sounds_Noise == "" then return end

	self.NoiseSound = CreateSound(self, self.Sounds_Noise)
	self.NoiseSound:Stop()

	return self.NoiseSound
end

function ENT:ApplyTuneSound()
	local stream = self.StreamObj
	if not IsValid(stream) then return end

	stream:TimerRemove("tunesoundstart")
	stream:TimerRemove("tunesound")

	local isStopMode = stream:IsStopMode()
	if isStopMode then
		self.streamswitchsound = true
		self:StopTuneSound()
		return
	end

	if IsValid(stream:GetChannel()) then
		self:FadeoutTuneSound()
		return
	end

	if stream:GetMuted() then
		self.streamswitchsound = nil
		self:StopTuneSound()
		return
	end

	if stream:IsLoading() then
		self:StartTuneSound(2)
		return
	end

	if stream:HasError() then
		self.streamswitchsound = true
		self:StartTuneSound(0)
		return
	end

	stream:TimerOnce("tunesound", 0.5, function()
		if not IsValid(self) then return end
		self:ApplyTuneSound()
	end)
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self.streamswitchsound = true
	self.slavesradios = {}
	self.old = {}

	local stream = self.StreamObj
	if IsValid(stream) then
		stream:SetEvent("OnPlayModeChange", self, function()
			if not IsValid(self) then return end
			self:ApplyTuneSound()
		end)

		stream:SetEvent("OnSearch", self, function()
			if not IsValid(self) then return end
			if not self.streamswitchsound then return end

			self:EmitSoundIfExist(self.Sounds_Tune, 50, 100, 1, CHAN_ITEM)
			self.streamswitchsound = nil
			self:ApplyTuneSound()
		end)

		stream:SetEvent("OnConnect", self, function()
			if not IsValid(self) then return end
			self:ApplyTuneSound()
		end)

		stream:SetEvent("OnError", self, function()
			if not IsValid(self) then return end
			self:ApplyTuneSound()
		end)

		stream:SetEvent("OnMute", self, function(this, muted)
			if not IsValid(self) then return end

			if muted then
				self:StopTuneSound()
			else
				self:ApplyTuneSound()
			end
		end)
	end

	self:MarkForUpdatePlaybackLoopMode()
end

function ENT:OnModelSetup()
	self:StreamStopAnimModel()
end

function ENT:GetWallTraceParamenters()
	if not self.WallTraceParamenters then
		self.WallTraceParamenters = {
			mask = MASK_SHOT_PORTAL,
			filter = function(ent)
				if not IsValid(ent) then return false end
				if not IsValid(self) then return false end

				if ent == self then return false end
				if ent.__IsRadio then return false end
				if ent:IsPlayer() then return false end
				if ent:IsVehicle() then return false end
				if ent:IsNPC() then return false end

				local camera = StreamRadioLib.GetCameraEnt()
				if IsValid(camera) and ent == camera then return false end

				return true
			end
		}
	end

	self.WallTraceParamenters.output = self.WallTraceParamenters.output or {}

	return self.WallTraceParamenters
end

function ENT:TraceToCamera(frompos)
	local endpos = StreamRadioLib.GetCameraViewPos()
	local traceparams = self:GetWallTraceParamenters()

	traceparams.start = frompos
	traceparams.endpos = endpos

	util.TraceLine(traceparams)

	local result = traceparams.output

	-- Tracers Debug
	-- debugoverlay.Line(frompos, result.HitPos or endpos, 0.1, color_white, false)
	-- debugoverlay.Line(result.HitPos or endpos, endpos, 0.1, color_black, false)

	return result
end

function ENT:TraceWalls(radius)
	local coveredvol = StreamRadioLib.GetCoveredVolume()
	if coveredvol >= 1 then
		return 1
	end

	local startpos = self.SoundPos

	local camtrace = self:TraceToCamera(startpos)
	if not camtrace then return 1 end
	if not camtrace.Hit then return 1 end
	if not camtrace.HitPos then return 1 end

	local traceparams = self:GetWallTraceParamenters()

	traceparams.start = startpos

	local traces = StreamRadioLib.StarTrace(traceparams, radius, 16, 16)

	local blockcount = 0
	local wallcount = 0

	for i, trace in ipairs(traces) do
		if not trace.Hit then
			continue
		end

		if not trace.HitPos then
			continue
		end

		wallcount = wallcount + 1

		local camtrace = self:TraceToCamera(trace.HitPos)
		if not camtrace then continue end
		if not camtrace.Hit then continue end
		if not camtrace.HitPos then continue end

		blockcount = blockcount + 1
	end

	if wallcount <= 0 then
		return 1
	end

	if blockcount <= 0 then
		return 1
	end

	local f = blockcount / wallcount

	local volfactor = math.Clamp((1 - f) * 2, coveredvol, 1)
	return volfactor
end

function ENT:GetWallVolumeFactor()
	if self.Muted then
		self.wallvolcache = nil
		return 0
	end

	if self:GetVolume() <= 0 then
		self.wallvolcache = nil
		return 0
	end

	if StreamRadioLib.GetCoveredVolume() >= 1 then
		self.wallvolcache = nil
		return 1
	end

	local now = RealTime()

	self.wallvolcache = self.wallvolcache or {}
	if (self.wallvolcache.nexttime or 0) >= now then
		return self.wallvolcache.value or 0
	end

	local mintime = math.max(FrameTime() * 3, 0.075)

	self.wallvolcache.value = self:TraceWalls(self.Radius)
	self.wallvolcache.nexttime = now + math.Rand(mintime, mintime * 4)

	return self.wallvolcache.value or 1
end

function ENT:GetWallVolumeFactorSmoothed()
	local now = RealTime()
	local last = self._wallvoltime or now
	self._wallvoltime = now

	local ticktime = now - last

	if ticktime <= 0 then
		return self._wallvolvalue or 0
	end

	local curwallvol = self:GetWallVolumeFactor()
	self._wallvolvalue = self._wallvolvalue or 0

	if self._wallvolvalue == curwallvol then
		return curwallvol
	end

	local speed = ticktime * 2

	self._wallvolvalue = math.Approach(self._wallvolvalue, curwallvol, speed)
	return self._wallvolvalue
end

function ENT:IsMuted()
	ply = LocalPlayer()

	if not IsValid(ply) then return true end
	if not ply:IsPlayer() then return true end
	if ply:IsBot() then return true end

	if StreamRadioLib.IsMuted(ply, self:GetRealRadioOwner()) then
		return true
	end

	if self:GetSVMute() then
		return true
	end

	if self:GetCLMute() then
		return true
	end

	local willMute = self:IsMutedForPlayer(ply)
	local now = RealTime()

	if willMute then
		if not self._mutedTimer then
			self._mutedTimer = now + 1
		end

		if self._mutedTimer < now then
			return true
		end

		return false
	else
		self._mutedTimer = nil
	end

	return false
end

function ENT:UpdateStream()
	local streamObj = self.StreamObj

	if not IsValid(streamObj) then
		self:StreamStopAnimModel()
		return
	end

	if streamObj:IsStopMode() then
		self:StreamStopAnimModel()
		return
	end

	local ply = LocalPlayer()

	streamObj:Set3D(StreamRadioLib.Is3DSound() and self:GetSound3D())
	self.Sound3D = streamObj:Get3D()

	self.Radius = self:GetRadius() or 0
	streamObj:Set3DFadeDistance(self.Radius / 3)

	local muted = self:IsMuted()
	local clVolume = self:GetCLVolume()

	local wallvol = 0
	local distVolume = 0
	local playerDistance = nil

	if not muted then
		playerDistance = self:DistanceToEntity(ply, nil, StreamRadioLib.GetCameraViewPos(ply))

		wallvol = self:GetWallVolumeFactorSmoothed()
		distVolume = StreamRadioLib.CalcDistanceVolume(playerDistance, self.Radius)
	end

	self.PlayerDistance = playerDistance

	local StreamVol = distVolume * clVolume * wallvol

	streamObj:SetMuted(muted)
	streamObj:SetClientVolume(StreamVol)

	self.Muted = muted

	if self.NoiseSound and self.NoiseSound_vol then
		local global_vol = StreamRadioLib.GetGlobalVolume()
		global_vol = math.Clamp(global_vol, 0, 1)

		self.NoiseSound:ChangeVolume(streamObj:GetVolume() * global_vol * clVolume * wallvol * self.NoiseSound_vol, 0.5)
	end

	self:StreamAnimModel()
end

function ENT:StreamAnimModel()
	local stream = self.StreamObj

	if not IsValid(stream) then
		self:StreamStopAnimModel()
		return
	end

	if not self.ModelData then
		self:StreamStopAnimModel()
		return
	end

	if self:IsDormant() then
		self:StreamStopAnimModel()
		return
	end

	if self.Muted then
		self:StreamStopAnimModel()
		return
	end

	if not self.PlayerDistance or self.PlayerDistance >= StreamRadioLib.GetSpectrumDistance() then
		self:StreamStopAnimModel()
		return
	end

	if stream:IsLoading() or stream:IsBuffering() then
		self:CallModelFunction("WhileLoading")
		return
	end

	if stream:HasError() then
		self:CallModelFunction("WhileError")
		return
	end

	if not stream:IsPlaying() then
		self:StreamStopAnimModel()
		return
	end

	local calcsl = self:HasModelFunction("SoundLevel")
	local calcspeaker = self:HasModelFunction("Speaker")
	local fftFunc = self:GetModelFunction("FFT")

	local modalData = self.ModelData

	if calcsl then
		self.AnimStopped = false

		self:CallModelFunction("SoundLevel", stream:GetAverageLevel())
	end

	if calcspeaker then
		self.AnimStopped = false

		local speakerlevel = 0
		local minfrq = modalData.SpeakerMinFRQ
		local maxfrq = modalData.SpeakerMaxFRQ
		local Resolution = modalData.SpeakerFRQResolution or 10

		stream:GetSpectrumComplex(Resolution, function( index, frq, level_length, level_ang, level_R, level_I )
			if not level_ang then
				local lambda = (1 / frq) / 2
				level_ang = math.random( -lambda, lambda )
			end

			local sin = math.sin( frq * math.pi * 2 + level_ang ) * level_length

			speakerlevel = speakerlevel + sin
			return true
		end, minfrq, maxfrq)

		speakerlevel = speakerlevel
		speakerlevel = math.Clamp( speakerlevel, -1, 1 )

		self:CallModelFunction("Speaker", speakerlevel)
	end

	if fftFunc then
		self.AnimStopped = false

		stream:GetSpectrumComplex( 7, function( index, frq, level_length, level_ang, level_R, level_I )
			fftFunc(modalData, index, frq, level_length)
		end)
	end
end

function ENT:FastThink()
	BaseClass.FastThink(self)

	self:MasterRadioSyncThink()
end

function ENT:InternalThink()
	BaseClass.InternalThink(self)

	self:UpdateStream()

	self:CallModelFunction("Think")
end

function ENT:InternalSlowThink()
	BaseClass.InternalSlowThink(self)

	self:PlaybackLoopModeThink()
	self:PanelThink()

	return true
end

function ENT:OnMasterradioChange(masterradio, oldmasterradio)
	local eventname = tostring(self) .. "_master_sync"
	local timername = eventname .. "_errorretry"

	local this_st = self.StreamObj

	this_st:RemoveEvent("OnError", eventname)
	this_st:RemoveEvent("OnConnect", eventname)
	this_st:TimerRemove(timername)

	if IsValid(oldmasterradio) then
		if IsValid(oldmasterradio.StreamObj) then
			oldmasterradio.StreamObj:RemoveEvent("OnConnect", eventname)
		end
	end

	if IsValid(masterradio) then
		local master_st = masterradio.StreamObj

		master_st:RemoveEvent("OnConnect", eventname)
		master_st:SetEvent("OnConnect", eventname, function()
			if not IsValid(self) then
				master_st:RemoveEvent("OnConnect", eventname)
				return
			end

			if not IsValid(masterradio) then
				master_st:RemoveEvent("OnConnect", eventname)
				return
			end

			if this_st:IsRunning() and this_st:GetError() == 0 then
				return
			end

			this_st:TimerRemove(timername)
			this_st:Retry()
		end)

		this_st:SetEvent("OnError", eventname, function()
			this_st:TimerRemove(timername)

			if not IsValid(self) then
				this_st:RemoveEvent("OnError", eventname)
				return
			end

			if not IsValid(masterradio) then
				this_st:RemoveEvent("OnError", eventname)
				return
			end

			if not IsValid(master_st) then
				this_st:RemoveEvent("OnError", eventname)
				return
			end

			this_st:TimerOnce(eventname .. "_errorretry", 10, function()
				if not IsValid(self) then
					this_st:RemoveEvent("OnError", eventname)
					return
				end

				if not IsValid(masterradio) then
					this_st:RemoveEvent("OnError", eventname)
					return
				end

				if not IsValid(master_st) then
					this_st:RemoveEvent("OnError", eventname)
					return
				end

				if this_st:IsRunning() and this_st:GetError() == 0 then
					return
				end

				this_st:Retry()
			end)
		end)
	end
end

function ENT:DrawTranslucent()
	BaseClass.DrawTranslucent(self)
	self:CallModelFunction("Draw")
end

function ENT:PostFakeRemove()
	self:ApplyTuneSound()
end

function ENT:OnRemove()
	self:OnRemoveShared()

	BaseClass.OnRemove(self)

	self:StopTuneSound()
end
