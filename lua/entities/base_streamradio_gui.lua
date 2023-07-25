AddCSLuaFile()
DEFINE_BASECLASS("base_streamradio")

local StreamRadioLib = StreamRadioLib
local LIBNetwork = StreamRadioLib.Network
local LIBModel = StreamRadioLib.Model
local LIBSkin = StreamRadioLib.Skin
local LIBWire = StreamRadioLib.Wire

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = false
ENT.AdminOnly = false

local ang_zero = Angle( )
local vec_zero = Vector( )

local g_isLoaded = StreamRadioLib and StreamRadioLib.Loaded
local g_isWiremodLoaded = g_isLoaded and LIBWire.HasWiremod()

local g_displayBuildTimer = 0

function ENT:SetScale(scale)
	self.Scale = scale or 0
end

function ENT:IsSeen()
	return SERVER or self.isseen
end

function ENT:GetScale()
	return self.Scale or 0
end

function ENT:SetDisplayPosAngOffset(pos, ang)
	self.DisplayPosOffset = pos
	self.DisplayPosAngles = ang
end

function ENT:GetDisplayPosAngOffset()
	return self.DisplayPosOffset, self.DisplayPosAngles
end

function ENT:CalcDisplayPosAngWorld()
	if self.DisplayLess then return end

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local dpos, dang = LocalToWorld(self.DisplayPosOffset or vec_zero, self.DisplayPosAngles or ang_zero, pos, ang)

	self.DisplayPos = dpos
	self.DisplayAng = dang

	return dpos, dang
end

function ENT:CanControlInternal(ply, userEntity)
	if self:GetDisableInput() then return false end
	if self.DisplayLess then return false end

	-- Check the player for +use permission
	if not StreamRadioLib.CheckPropProtectionAgainstUse(self, ply) then
		return false
	end

	if userEntity:IsPlayer() then
		if not userEntity:Alive() then
			return false
		end

		if StreamRadioLib.IsGUIHidden(userEntity) then
			return false
		end

		if not self:OnGUIShowCheck(userEntity) then
			return false
		end
	end

	local scale = self:GetScale()
	if scale <= 0 then return false end

	local pos = self.DisplayPos
	if not pos then return false end

	local ang = self.DisplayAng
	if not ang then return false end

	local controlpos = StreamRadioLib.GetControlPosDir(userEntity)
	if not controlpos then return false end

	-- Return false if from the backside
	local a = controlpos - pos
	local b = ang:Up():Dot( a ) / a:Length()

	local displayVisAng = math.acos( b ) / math.pi * 180
	return displayVisAng < 90
end

function ENT:CanControl(ply, userEntity)
	if not g_isLoaded then return false end

	if not IsValid(ply) then return false end
	if not ply:IsPlayer() then return false end

	if not IsValid(userEntity) then
		userEntity = ply
	end

	local cacheId = tostring(ply) .. "_" .. tostring(userEntity)
	local now = RealTime()

	-- cache the check result for a short time to avoid running expensive functions every tick
	if self._canControlCacheExpire and self._canControlCacheExpire <= now then
		self._canControlCache = nil
		self._canControlCacheExpire = nil
	end

	if self._canControlCache and self._canControlCache[cacheId] ~= nil then
		return self._canControlCache[cacheId]
	end

	if not self._canControlCache then
		self._canControlCache = {}
		self._canControlCacheExpire = now + 0.25
	end

	local result = self:CanControlInternal(ply, userEntity)

	self._canControlCache[cacheId] = result
	return result
end

function ENT:CursorInGUI(cx, cy)
	if not IsValid(self.GUI) then return false end

	local px, py = self.GUI:GetAbsolutePos()
	return self.GUI:IsInBounds(cx - px, cy - py)
end

function ENT:GetCursor( ply, trace, userEntity )
	if not g_isLoaded then return false end

	if not IsValid(ply) then return false end
	if not ply:IsPlayer() then return false end

	if not IsValid(userEntity) then
		userEntity = ply
	end

	if not self:CanControl(ply, userEntity) then
		return false
	end

	if not trace then
		trace = StreamRadioLib.Trace(userEntity)
		if not trace or not trace.Hit then
			return false
		end
	end

	if not self:OnGUIInteractionCheck(ply, trace, userEntity) then
		return false
	end

	-- Ignore distances when we are using via an entity that is not a player
	if userEntity:IsPlayer() and not self:CheckDistanceToEntity(userEntity, self.MaxCursorTraceDist, trace.HitPos) then
		return false
	end

	local Cursor = trace.Entity == self

	if not Cursor then
		return false
	end

	local scale = self:GetScale()
	if scale <= 0 then return false end

	local pos = self.DisplayPos
	if not pos then return false end

	local ang = self.DisplayAng
	if not ang then return false end

	local TraceHitPos = util.IntersectRayWithPlane( trace.StartPos, trace.Normal, pos, ang:Up( ) )

	if not TraceHitPos then
		return false
	end

	local HitPos = WorldToLocal( TraceHitPos, ang_zero, pos, ang )
	local CursorX = math.Round( HitPos.x / scale )
	local CursorY = math.Round( -HitPos.y / scale )

	Cursor = self:CursorInGUI(CursorX, CursorY)

	if not Cursor then
		return false
	end

	return Cursor, CursorX, CursorY
end

function ENT:HasModelFunction(index)
	if not index then return false end
	if not self.ModelData then return false end
	if not isfunction( self.ModelData[index] ) then return false end

	return true
end

function ENT:CallModelFunction(index, ...)
	if not self:HasModelFunction(index) then return end

	local status, err, a, b, c, d, e, f, g = pcall( self.ModelData[index], self.ModelData, self, ... )

	if not status and err then
		StreamRadioLib.Util.ErrorNoHaltWithStack( err .. "\n" )
		return nil
	end

	return err, a, b, c, d, e, f, g
end

function ENT:SetUpModel()
	if not g_isLoaded then return end
	if not IsValid(self.StreamObj) then return end
	if self._badModel then return end

	local model = self:GetModel()
	if not StreamRadioLib.Util.IsValidModel(model) then
		self._badModel = true
		return
	end

	self.ModelData = LIBModel.GetModelSettings(model)
	local MD = self.ModelData or {}

	self:CallModelFunction("Initialize", model)

	self:SetDisplayPosAngOffset(MD.DisplayOffset, MD.DisplayAngles)
	self:SetScale(MD.DisplayScale or 1)

	self.NoDisplay = MD.NoDisplay or false
	self.MaxCursorTraceDist = MD.MaxCursorTraceDist or 100

	if MD.Sounds then
		self.Sounds_Tune = MD.Sounds.Tune or self.Sounds_Tune
		self.Sounds_Noise = MD.Sounds.Noise or self.Sounds_Noise
		self.Sounds_Use = MD.Sounds.Use or self.Sounds_Use
	end

	self:SetSoundPosAngOffset(MD.SoundPosOffset, MD.SoundAngOffset)

	if self.OnModelSetup then
		self:OnModelSetup()
	end
end

function ENT:RemoveGui()
	local tmpGui = self.GUI
	local tmpGuiMain = self.GUI_Main

	local hasGui = IsValid(tmpGui)
	local hasGuiMain = IsValid(tmpGuiMain)

	if (hasGui or hasGuiMain) and self.OnGUIRemove then
		self:OnGUIRemove(tmpGui, tmpGuiMain)
	end

	self.GUI = nil
	self.GUI_Main = nil

	if hasGui then
		tmpGui:Remove()
		tmpGui = nil
	end

	if hasGuiMain then
		tmpGuiMain:Remove()
		tmpGuiMain = nil
	end
end

function ENT:SetupGui()
	if not IsValid(self.GUI) then
		self.GUI = StreamRadioLib.CreateOBJ("gui_controller")
	end

	self.GUI:SetName("gui")
	self.GUI:SetNWName("g")
	self.GUI:SetEntity(self)
	self.GUI:ActivateNetworkedMode()

	if StreamRadioLib.Util.IsDebug() then
		self:SetEnableDebug(true)
	end

	self.GUI:SetDebug(self:GetEnableDebug())

	if not IsValid(self.GUI_Main) then
		self.GUI_Main = self.GUI:AddPanelByClassname("radio/gui_main")
	end

	self.GUI_Main:SetPos(0, 0)
	self.GUI_Main:SetName("main")
	self.GUI_Main:SetNWName("m")
	self.GUI_Main:SetSkinIdentifyer("main")
	self.GUI_Main:SetStream(self.StreamObj)

	self.GUI_Main.OnToolButtonClick = function(this)
		if not IsValid(self) then return end
		self:OnToolButtonClick()
	end

	self.GUI_Main.OnWireButtonClick = function(this)
		if not IsValid(self) then return end
		self:OnWireButtonClick()
	end

	self.GUI_Main.OnPlayerClosed = function(this)
		if not IsValid(self) then return end
		self:OnPlayerClosed()
	end

	self.GUI_Main.OnPlayerShown = function(this)
		if not IsValid(self) then return end
		self:OnPlayerShown()
	end

	local model = self:GetModel()
	self:CallModelFunction("InitializeFonts", model)
	self:CallModelFunction("SetupGUI", self.GUI, self.GUI_Main)

	self.GUI:SetSkin(LIBSkin.GetDefaultSkin())
	self.GUI:PerformRerender(true)

	if self.OnGUISetup then
		self:OnGUISetup(self.GUI, self.GUI_Main)
	end
end

function ENT:StreamOnConnect(stream, channel, metadata)
	BaseClass.StreamOnConnect(self, stream, channel, metadata)
	self:CallModelFunction("OnPlay", stream)
	return true
end

function ENT:StreamOnSearch(stream)
	BaseClass.StreamOnSearch(self, stream)
	self:CallModelFunction("OnSearch", stream)
	return true
end

function ENT:StreamOnError(stream, err)
	BaseClass.StreamOnError(self, stream, err)
	self:CallModelFunction("OnError", stream, err)
end

function ENT:StreamOnClose(stream)
	BaseClass.StreamOnClose(self, stream)
	self:CallModelFunction("OnStop", stream)
end

function ENT:HasGUI()
	if not IsValid(self.GUI) then
		return false
	end

	return true
end

function ENT:GetGUI()
	return self.GUI
end

function ENT:GetGUIMain()
	return self.GUI_Main
end

function ENT:PollGuiSetup()
	if self.DisplayLess then
		return
	end

	if self.GUI then
		return
	end

	if SysTime() > g_displayBuildTimer then
		self:SetupGui()

		-- delay the GUI rebuild in case many newly spawned radios are seen at once
		g_displayBuildTimer = SysTime() + 0.2
	end
end

function ENT:InternalThink()
	BaseClass.InternalThink(self)

	self.isseen = false
	self.DisplayLess = self.NoDisplay or self:GetDisableDisplay()

	if SERVER then
		self:PollGuiSetup()
	end
end

function ENT:NonDormantThink()
	BaseClass.NonDormantThink(self)

	if self:IsSeen() then
		self:ControlThink(self:GetLastUser(), self:GetLastUsingEntity())
	end
end

function ENT:ControlThink(ply, userEntity)
	local GUI = self.GUI

	if not IsValid(GUI) then return end
	if not IsValid(ply) then return end

	local pos, ang = self:CalcDisplayPosAngWorld()

	if CLIENT and self:ShowDebug() then
		debugoverlay.Axis(pos, ang, 5, 0.05, color_white)
		debugoverlay.EntityTextAtPosition(pos, 1, "Display pos", 0.05, color_white)
	end

	local Cursor, CursorX, CursorY = self:GetCursor(ply, nil, userEntity)

	if not Cursor then
		if GUI:GetCursor() ~= -1 then
			GUI:Click(false)
			GUI:SetCursor(-1, -1)
		end

		return
	end

	GUI:SetCursor(CursorX or -1, CursorY or -1)
end

function ENT:Control(ply, trace, pressed, userEntity)
	local GUI = self.GUI

	if not IsValid(GUI) then return end
	if not IsValid(ply) then return end

	if pressed then
		if not self:CanControl(ply, userEntity) then
			return
		end

		-- anti click spam
		local now = RealTime()

		if (now - (self._oldusetime or 0)) < 0.1 then
			return
		end

		self._oldusetime = now
	end

	local Cursor, CursorX, CursorY = self:GetCursor(ply, trace, userEntity)
	if not Cursor then
		if GUI:GetCursor() ~= -1 then
			GUI:Click(false)
			GUI:SetCursor(-1, -1)
		end

		return
	end

	GUI:SetCursor(CursorX or -1, CursorY or -1)
	GUI:Click(pressed)

	if SERVER and pressed then
		self:EmitSoundIfExist(self.Sounds_Use, 50, 100, 0.40, CHAN_ITEM)

		self:SetLastUser(ply)
		self:SetLastUsingEntity(userEntity)
	end
end

function ENT:SetupDataTables()
	if not g_isLoaded then return end

	BaseClass.SetupDataTables(self)

	self:AddDTNetworkVar( "Bool", "DisableDisplay", {
		KeyName = "DisableDisplay",
		Edit = {
			category = "GUI",
			title = "Disable display",
			type = "Boolean",
			order = 10
		}
	})

	self:AddDTNetworkVar( "Bool", "DisableInput", {
		KeyName = "DisableInput",
		Edit = {
			category = "GUI",
			title = "Disable input",
			type = "Boolean",
			order = 11
		}
	})

	self:AddDTNetworkVar( "Bool", "DisableSpectrum", {
		KeyName = "DisableSpectrum",
		Edit = {
			category = "GUI",
			title = "Disable spectrum",
			type = "Boolean",
			order = 12
		}
	})

	self:AddDTNetworkVar( "Bool", "EnableDebug", {
		KeyName = "EnableDebug",
		Edit = {
			category = "GUI",
			title = "Show debug panel",
			type = "Boolean",
			order = 13
		}
	})

	LIBNetwork.SetDTVarCallback(self, "EnableDebug", function(this, name, oldv, newv)
		if not IsValid(self.GUI) then return end
		self.GUI:SetDebug(newv)
	end)

	if CLIENT then
		LIBNetwork.SetDTVarCallback(self, "DisableDisplay", function(this, name, oldv, newv)
			if newv then
				self:RemoveGui()
			end
		end)
	end
end

function ENT:IsPlaylistEnabled()
	local GUI_Main = self.GUI_Main

	if not IsValid(GUI_Main) then
		return false
	end

	if not GUI_Main:IsPlaylistEnabled() then
		return false
	end

	return true
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetUpModel()
end

function ENT:OnRemove()
	self:CallModelFunction("OnRemove", model)
	self:RemoveGui()

	BaseClass.OnRemove(self)
end

function ENT:OnToolButtonClick()
	-- Override me
end

function ENT:OnWireButtonClick()
	-- Override me
end

function ENT:OnPlayerClosed()
	-- Override me
end

function ENT:OnPlayerShown()
	-- Override me
end

function ENT:OnModelSetup()
	-- Override me
end

function ENT:OnGUISetup()
	if self._postClasssystemPasteLoadDupeOnGUISetup then
		self:PostClasssystemPaste()
	end
end

function ENT:OnGUIRemove()
	-- Override me
end

function ENT:OnGUIShowCheck(ply)
	-- Override me
	return true
end

function ENT:OnGUIInteractionCheck(ply, trace, userEntity)
	-- Override me
	return true
end

if CLIENT then
	function ENT:CanSeeDisplay()
		if not g_isLoaded then return false end

		if self._cacheCanSeeDisplay ~= nil then
			return self._cacheCanSeeDisplay
		end

		self._cacheCanSeeDisplay = false

		if self.DisplayLess then return false end

		local ply = LocalPlayer()
		if StreamRadioLib.IsGUIHidden(ply) then return false end
		if not self:OnGUIShowCheck(ply) then return false end
		local scale = self:GetScale()
		if scale <= 0 then return false end

		local pos = self.DisplayPos
		if not pos then return false end
	
		local ang = self.DisplayAng
		if not ang then return false end

		local campos = StreamRadioLib.GetCameraViewPos(ply)
		if not campos then return false end

		-- Return false if from the backside
		local a = campos - pos
		local b = ang:Up():Dot( a ) / a:Length()

		local displayVisAng = math.acos( b ) / math.pi * 180
		local isSeen = displayVisAng < 90

		if not isSeen then return false end

		self._cacheCanSeeDisplay = true
		return true
	end

	function ENT:GetCursorFromLastUser()
		if not g_isLoaded then return false end

		local lastUser = self:GetLastUser()
		local userEntity = self:GetLastUsingEntity()

		if not IsValid(lastUser) then
			lastUser = LocalPlayer()
		end

		if not IsValid(userEntity) then
			userEntity = lastUser
		end

		return self:GetCursor(lastUser, nil, userEntity)
	end

	function ENT:ShouldRemoveGUI()
		local ply = LocalPlayer()

		if self.DisplayLess then
			return true
		end

		if StreamRadioLib.IsGUIHidden(ply) then
			return true
		end

		return false
	end

	function ENT:DrawGUI()
		if not g_isLoaded then return end

		self._cacheCanSeeDisplay = nil
		self._cacheCanDrawSpectrum = nil

		if self:ShouldRemoveGUI() then
			if self.GUI then
				self:RemoveGui()
			end

			return
		end

		if not self:CheckDistanceToEntity(ply, StreamRadioLib.GetDrawDistance(), nil, StreamRadioLib.GetCameraViewPos(ply)) then
			return
		end

		self:PollGuiSetup()

		if not IsValid(self.GUI) then
			return
		end

		local pos, ang = self:CalcDisplayPosAngWorld()
		if not pos then
			return
		end

		if not ang then
			return
		end

		if not self:CanSeeDisplay() then
			return
		end

		local lastUser = self:GetLastUsingEntity()
		local scale = self:GetScale()

		local Cursor, CursorX, CursorY = self:GetCursorFromLastUser()

		local col = self:GetColor()
		self.GUI:SetAllowCursor(StreamRadioLib.IsCursorEnabled())
		self.GUI:SetDrawAlpha(col.a / 255)

		if Cursor or not IsValid(lastUser) then
			self.GUI:SetCursor(CursorX or -1, CursorY or -1)
		end

		cam.Start3D2D( pos, ang, scale )
			self.GUI:RenderSystem()
		cam.End3D2D( )
	end

	function ENT:DrawTranslucent( )
		BaseClass.DrawTranslucent( self )
		self.isseen = true
		self:DrawGUI()
	end

	function ENT:CanDrawSpectrum()
		if not g_isLoaded then return false end

		if self._cacheCanDrawSpectrum ~= nil then
			return self._cacheCanDrawSpectrum
		end

		self._cacheCanDrawSpectrum = false

		if not IsValid(self.GUI) then return false end

		if StreamRadioLib.IsSpectrumHidden() then return false end
		if self:GetDisableSpectrum() then return false end

		if not self:CanSeeDisplay() then return false end

		local ply = LocalPlayer()
		if not self:CheckDistanceToEntity(ply, StreamRadioLib.GetSpectrumDistance(), nil, StreamRadioLib.GetCameraViewPos(ply)) then return false end

		self._cacheCanDrawSpectrum = true
		return true
	end
else
	function ENT:Use(activator, ...)
		if not g_isWiremodLoaded then return false end
		if not IsValid(self.GUI) then return false end

		if not IsValid(activator) then
			return false
		end

		if not activator:IsPlayer() then
			return false
		end

		local data = LIBWire.FindCallingWireUserEntityData()
		if not data then
			return false
		end

		local now = RealTime()

		if (now - (self._oldwireusetime or 0)) < 0.1 then
			return false
		end

		self._oldwireusetime = now

		StreamRadioLib.TabControl(activator, data.trace, data.userEntity)
		return true
	end

	function ENT:OnSetupCopyData(data)
		data.GUI = nil
		data.GUI_Main = nil
	end

	function ENT:PostClasssystemPaste()
		if self.DisplayLess then
			BaseClass.PostClasssystemPaste(self)
			return
		end

		if not IsValid(self.GUI) then
			self._postClasssystemPasteLoadDupeOnGUISetup = true
			return
		end

		self._postClasssystemPasteLoadDupeOnGUISetup = nil

		timer.Simple(engine.TickInterval() * 18, function()
		 	if not IsValid(self) then return end

			BaseClass.PostClasssystemPaste(self)
			if self.DisplayLess then
				return
			end

			if not IsValid(self.GUI) then
				return
			end

		 	self.GUI:LoadFromDupe()
		end)
	end
end
