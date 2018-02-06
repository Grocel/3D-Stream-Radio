include("shared.lua")
DEFINE_BASECLASS("base_streamradio_gui")

function ENT:StopTuneSound()
	if not self.NoiseSound then return end

	if IsValid(self.StreamObj) then
		self.StreamObj:TimerRemove("tunesound")
	end

	self.NoiseSound:Stop( )
	self.NoiseSound = nil
end

function ENT:FadeoutTuneSound(time)
	if not self.NoiseSound then return end

	if IsValid(self.StreamObj) then
		self.StreamObj:TimerRemove("tunesound")
	end

	if not self.NoiseSound:IsPlaying() then
		return
	end

	self.NoiseSound_vol = 0
end

function ENT:StartTuneSound(startvol)
	self:CreateTuneSound()
	if not self.NoiseSound then return end

	if IsValid(self.StreamObj) then
		self.StreamObj:TimerRemove("tunesound")
	end

	if self.NoiseSound:IsPlaying() then
		return
	end

	self.NoiseSound_vol = 1
	self.NoiseSound:PlayEx(startvol or 0, 100)
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
	if not IsValid(self.StreamObj) then return end

	local isStopMode = self.StreamObj:IsStopMode()
	if isStopMode then
		self.streamswitchsound = true
		self:StopTuneSound()
		return
	end

	if IsValid(self.StreamObj:GetChannel()) then
		self:FadeoutTuneSound()
		return
	end

	if self.StreamObj:IsLoading() then
		self:StartTuneSound()
		return
	end

	if self.StreamObj:GetError() ~= 0 then
		self.streamswitchsound = true
		self:StartTuneSound()
		return
	end

	self.StreamObj:TimerOnce("tunesound", 0.5, function()
		if not IsValid(self) then return end
		self:ApplyTuneSound()
	end)
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self.streamswitchsound = true
	self.old = {}

	if IsValid(self.StreamObj) then
		self.StreamObj:SetEvent("OnPlayModeChange", self, function()
			if not IsValid(self) then return end
			self:ApplyTuneSound()
		end)

		self.StreamObj:SetEvent("OnSearch", self, function()
			if not IsValid(self) then return end
			if not self.streamswitchsound then return end

			self:EmitSoundIfExist(self.Sounds_Tune, 50, 100, 1, CHAN_ITEM)
			self.streamswitchsound = nil
			self:ApplyTuneSound()
		end)

		self.StreamObj:SetEvent("OnConnect", self, function()
			if not IsValid(self) then return end
			self:ApplyTuneSound()
		end)

		self.StreamObj:SetEvent("OnError", self, function()
			if not IsValid(self) then return end
			self:ApplyTuneSound()
		end)

		self.StreamObj:SetEvent("OnMute", self, function(this, muted)
			if not IsValid(self) then return end

			if muted then
				self:StopTuneSound()
			else
				self:ApplyTuneSound()
			end
		end)
	end
end

function ENT:OnSetupModelSetup()
	self:StreamStopAnimModel()
end

function ENT:UpdateStream()
	if not IsValid(self.StreamObj) then
		self:StreamStopAnimModel()
		return
	end

	if self.StreamObj:IsStopMode() then
		self:StreamStopAnimModel()
		return
	end

	local ply = LocalPlayer()
	local camerapos = StreamRadioLib.GetCameraPos()

	self.StreamObj:Set3D(StreamRadioLib.Is3DSound() and self:GetSound3D())
	self.Sound3D = self.StreamObj:Get3D()

	self.BlockedVolume = 1

	self.PlayerDistance = self:DistanceToPlayer(ply, nil, camerapos)
	self.PlayerDistanceSound = self.PlayerDistance

	if not self.Sound3D then
		self.PlayerDistanceSound = self.PlayerDistance * (2 - self.BlockedVolume)
	end

	self.Radius = self:GetRadius() or 0
	self.StreamObj:Set3DFadeDistance(self.Radius / 3)

	local distVolume = StreamRadioLib.CalcDistanceVolume(self.PlayerDistanceSound, self.Radius)
	local StreamVol = distVolume * self.BlockedVolume

	local MuteDistance = math.min(self.Radius + 1000, StreamRadioLib.GetMuteDistance())
	self.Muted = StreamRadioLib.IsMuted() or self:IsDormant() or (self.PlayerDistanceSound >= MuteDistance)

	self.StreamObj:SetMuted(self.Muted)
	self.StreamObj:SetClientVolume(StreamVol)

	if self.NoiseSound and self.NoiseSound_vol then
		local global_vol = StreamRadioLib.Settings.GetConVarValue("volume")
		global_vol = math.Clamp(global_vol, 0, 1)

		self.NoiseSound:ChangeVolume(self.StreamObj:GetVolume() * global_vol * self.BlockedVolume * self.NoiseSound_vol, 0.5)
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

	if self.PlayerDistance >= StreamRadioLib.GetSpectrumDistance() then
		self:StreamStopAnimModel()
		return
	end

	if stream:IsLoading() or stream:IsBuffering() then
		self:CallModelFunction("WhileLoading")
		return
	end

	if stream:GetError() ~= 0 then
		self:CallModelFunction("WhileError")
		return
	end

	if not stream:IsPlaying() then
		self:StreamStopAnimModel()
		return
	end

	local calcsl = self:HasModelFunction("SoundLevel")
	local calcspeaker = self:HasModelFunction("Speaker")
	local calcfft = self:HasModelFunction("FFT")

	if calcsl then
		self.AnimStopped = false

		self:CallModelFunction("SoundLevel", stream:GetAverageLevel())
	end

	if calcspeaker then
		self.AnimStopped = false

		local speakerlevel = 0
		local minfrq = self.ModelData.SpeakerMinFRQ
		local maxfrq = self.ModelData.SpeakerMaxFRQ
		local Resolution = self.ModelData.SpeakerFRQResolution or 10

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

	if calcfft then
		self.AnimStopped = false

		stream:GetSpectrumComplex( 7, function( index, frq, level_length, level_ang, level_R, level_I )
			self:CallModelFunction( "FFT", index, frq, level_length )
		end)
	end
end

function ENT:Think()
	BaseClass.Think(self)

	self:MasterRadioSyncThink()
	self:PanelThink()
	self:UpdateStream()

	self:CallModelFunction("Think")
	return true
end

function ENT:OnMasterradioChange(masterradio, oldmasterradio)
	local eventname = tostring(self) .. "_master_sync"
	local timername = eventname .. "_errorretry"

	local this_st = self.StreamObj

	this_st:RemoveEvent("OnError", eventname)
	this_st:RemoveEvent("OnConnect", eventname)
	this_st:TimerRemove(timername)

	if IsValid(oldmasterradio) and IsValid(oldmasterradio.StreamObj) then
		oldmasterradio.StreamObj:RemoveEvent("OnConnect", eventname)
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
	BaseClass.OnRemove(self)
	self:StopTuneSound()
end
