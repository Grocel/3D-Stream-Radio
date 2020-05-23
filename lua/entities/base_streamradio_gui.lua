AddCSLuaFile()
DEFINE_BASECLASS("base_streamradio")

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = false
ENT.AdminOnly = false

local ang_zero = Angle( )
local vec_zero = Vector( )

function ENT:SetScale(scale)
	self.Scale = scale or 0
end

function ENT:GetScale()
	return self.Scale or 0
end

function ENT:SetDisplayPosAng(pos, ang)
	self.DisplayOffset = pos
	self.DisplayAngles = ang
end

function ENT:CanControlDisplay(ply)
	if not self.__IsLibLoaded then return false end
	if self:GetDisableInput() then return false end

	if not self:HasGUI() then return false end
	if self:GetDisableDisplay() then return false end

	if StreamRadioLib.IsGUIHidden(ply) then return false end
	if not self:OnGUIShowCheck(ply) then return false end

	local pos, ang = self:GetDisplayPos()
	if not pos then return false end

	local controlpos = StreamRadioLib.GetControlPosDir(ply)
	if not controlpos then return false end

	-- Return false if from the backside
	local a = controlpos - pos
	local b = ang:Up():Dot( a ) / a:Length()

	local displayVisAng = math.acos( b ) / math.pi * 180
	return displayVisAng < 90
end

function ENT:CanSeeDisplay(ply)
	if not self.__IsLibLoaded then return false end

	if not self:HasGUI() then return false end
	if self:GetDisableDisplay() then return false end

	if StreamRadioLib.IsGUIHidden(ply) then return false end
	if not self:OnGUIShowCheck(ply) then return false end

	local pos, ang = self:GetDisplayPos()
	if not pos then return false end

	local campos = StreamRadioLib.GetCameraPos(ply)
	if not campos then return false end

	-- Return false if from the backside
	local a = campos - pos
	local b = ang:Up():Dot( a ) / a:Length()

	local displayVisAng = math.acos( b ) / math.pi * 180
	return displayVisAng < 90
end

function ENT:CursorInGUI(cx, cy)
	if not IsValid(self.GUI) then return false end

	local px, py = self.GUI:GetAbsolutePos()
	return self.GUI:IsInBounds(cx - px, cy - py)
end

function ENT:GetDisplayPos( )
	if not self:HasGUI() then return end
	if self:GetDisableDisplay() then return end

	local pos = self:GetPos( )
	local ang = self:GetAngles( )

	local DisplayPosOffset = self.DisplayOffset or vec_zero
	local DisplayAngOffset = self.DisplayAngles or ang_zero

	pos, ang = LocalToWorld( DisplayPosOffset, DisplayAngOffset, pos, ang )

	debugoverlay.Axis(pos, ang, 5, 0.05, color_white)
	debugoverlay.EntityTextAtPosition(pos, 1, "Display pos", 0.05, color_white)

	return pos, ang
end

function ENT:GetCursor( ply, trace )
	if not self.__IsLibLoaded then
		return false
	end

	local Scale = self:GetScale()
	local Pos, Ang = self:GetDisplayPos()

	if Scale <= 0 then
		return false
	end

	if not Pos then
		return false
	end

	if not IsValid(ply) then
		return false
	end

	if not ply:IsPlayer() then
		return false
	end

	if not ply:Alive() then
		return false
	end

	if not self:CanControlDisplay(ply) then
		return false
	end

	if not trace or not trace.Hit then
		trace = StreamRadioLib.Trace(ply)
		if not trace or not trace.Hit then
			return false
		end
	end

	if not self:OnGUIInteractionCheck(ply, trace) then
		return false
	end

	if self.CPPICanUse then
		local allowuse = self:CPPICanUse(ply) or false
		if not allowuse then
			return false
		end
	end

	if self:DistanceToPlayer(ply, trace.HitPos) > self.MaxCursorTraceDist then
		return false
	end

	local Cursor = trace.Entity == self

	if not Cursor then
		return false
	end

	local TraceHitPos = util.IntersectRayWithPlane( trace.StartPos, trace.Normal, Pos, Ang:Up( ) )

	if not TraceHitPos then
		return false
	end

	local HitPos = WorldToLocal( TraceHitPos, ang_zero, Pos, Ang )
	local CursorX = math.Round( HitPos.x / Scale )
	local CursorY = math.Round( -HitPos.y / Scale )

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
		ErrorNoHalt( err .. "\n" )
		return nil
	end

	return err, a, b, c, d, e, f, g
end

function ENT:SetUpModel()
	if not self.__IsLibLoaded then return end
	if not IsValid(self.StreamObj) then return end

	local model = self:GetModel()
	self.ModelData = StreamRadioLib.Model.GetModelSettings(model)
	local MD = self.ModelData or {}

	self:CallModelFunction("Initialize", model)

	self:SetDisplayPosAng(MD.DisplayOffset, MD.DisplayAngles)
	self:SetScale(MD.DisplayScale or 1)

	self.NoDisplay = MD.NoDisplay or false
	self.MaxCursorTraceDist = MD.MaxCursorTraceDist or 100

	if MD.Sounds then
		self.Sounds_Tune = MD.Sounds.Tune or self.Sounds_Tune
		self.Sounds_Noise = MD.Sounds.Noise or self.Sounds_Noise
		self.Sounds_Use = MD.Sounds.Use or self.Sounds_Use
	end

	self:SetSoundPosAng(MD.SoundPosOffset, MD.SoundAngOffset)

	if self.NoDisplay then
		if IsValid(self.GUI_Main) then
			self.GUI_Main:Remove()
			self.GUI_Main = nil
		end

		if IsValid(self.GUI) then
			self.GUI:Remove()
			self.GUI = nil
		end

		if self.OnSetupModelSetup then
			self:OnSetupModelSetup()
		end

		return
	end

	if not IsValid(self.GUI) then
		self.GUI = StreamRadioLib.CreateOBJ("gui_controller")
	end

	self.GUI:SetName("gui")
	self.GUI:SetEntity(self)
	self.GUI:ActivateNetworkedMode()

	if StreamRadioLib.IsDebug() then
		self:SetEnableDebug(true)
	end

	self.GUI:SetDebug(self:GetEnableDebug())

	if not IsValid(self.GUI_Main) then
		self.GUI_Main = self.GUI:AddPanelByClassname("radio/gui_main")
	end

	self.GUI_Main:SetPos(0, 0)
	self.GUI_Main:SetName("main")
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

	self:CallModelFunction("InitializeFonts", model)
	self:CallModelFunction("SetupGUI", self.GUI, self.GUI_Main)

	self.GUI:SetSkin(StreamRadioLib.Skin.GetDefaultSkin())
	self.GUI:_PerformRerenderInternal()

	if self.OnSetupModelSetup then
		self:OnSetupModelSetup()
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

function ENT:FastThink()
	BaseClass.FastThink(self)
	self:ControlThink(self:GetLastUser())
end

function ENT:ControlThink(ply, tr)
	if not IsValid(self.GUI) then return end
	if not IsValid(ply) then return end

	local Cursor, CursorX, CursorY = self:GetCursor(ply, tr)
	self.GUI:SetCursor(CursorX or -1, CursorY or -1)
end

function ENT:Think()
	BaseClass.Think(self)
	return true
end

function ENT:Control(ply, tr, pressed)
	if not IsValid(self.GUI) then return end

	if not self:CanControlDisplay(ply) then return end

	if pressed then
		local now = RealTime()
		if (now - (self._oldusetime or 0)) < 0.1 then return end
		self._oldusetime = now
	end

	local Cursor, CursorX, CursorY = self:GetCursor(ply, tr)
	if not Cursor then return end

	self.GUI:SetCursor(CursorX or -1, CursorY or -1)
	self.GUI:Click(pressed)

	if SERVER and pressed then
		self:EmitSoundIfExist(self.Sounds_Use, 50, 100, 0.40, CHAN_ITEM)

		self:SetLastUser(ply)
	end
end

function ENT:SetupDataTables()
	if not self.__IsLibLoaded then return end

	BaseClass.SetupDataTables(self)

	self:AddDTNetworkVar( "Bool", "DisableDisplay", {
		KeyName = "DisableDisplay",
		Edit = {
			category = "GUI",
			title = "Disable display",
			type = "Boolean",
			order = 1
		}
	})

	self:AddDTNetworkVar( "Bool", "DisableInput", {
		KeyName = "DisableInput",
		Edit = {
			category = "GUI",
			title = "Disable input",
			type = "Boolean",
			order = 2
		}
	})

	self:AddDTNetworkVar( "Bool", "EnableDebug", {
		KeyName = "EnableDebug",
		Edit = {
			category = "GUI",
			title = "Show debug panel",
			type = "Boolean",
			order = 3
		}
	})

	self:AddDTNetworkVar( "Bool", "PlaylistLoop", {
		KeyName = "PlaylistLoop",
		Edit = {
			category = "Playlist",
			title = "Enable playlist track switch",
			type = "Boolean",
			order = 1
		}
	})

	StreamRadioLib.Network.SetDTVarCallback(self, "EnableDebug", function(this, name, oldv, newv)
		if not IsValid(self.GUI) then return end
		self.GUI:SetDebug(newv)
	end)
end

function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetUpModel()
end

function ENT:OnRemove()
	local GUI = self.GUI

	self:CallModelFunction("OnRemove", model)

	timer.Simple(0.05, function()
		if IsValid(self) then
			return
		end

		if IsValid(GUI) then
			GUI:Remove()
			GUI = nil
		end
	end)

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

function ENT:OnSetupModelSetup()
	-- Override me
end

function ENT:OnGUIShowCheck(ply)
	-- Override me
	return true
end

function ENT:OnGUIInteractionCheck(ply, tr)
	-- Override me
	return true
end

if CLIENT then

	function ENT:CanPlayerUse(ply)
		if not IsValid(self.GUI) then return false end
		if not IsValid(ply) then return false end

		if not self:CanControlDisplay(ply) then return false end
		return true
	end

	function ENT:GetCurserFromUser()
		local lastuser = self:GetLastUser()
		local lp = LocalPlayer()

		local Cursor, CursorX, CursorY

		if self:CanPlayerUse(lastuser) then
			Cursor, CursorX, CursorY = self:GetCursor(lastuser)
		end

		if Cursor then
			return Cursor, CursorX, CursorY
		end

		if self:CanPlayerUse(lp) then
			Cursor, CursorX, CursorY = self:GetCursor(lp)
		end

		return Cursor, CursorX, CursorY
	end

	function ENT:DrawGUI()
		if not self.__IsLibLoaded then return end
		if not IsValid(self.GUI) then return end

		local ply = LocalPlayer()
		if not self:CanSeeDisplay(ply) then return end

		local dist = self:DistanceToPlayer(ply)
		if dist > StreamRadioLib.GetDrawDistance() then return end

		local Scale = self:GetScale()
		local Pos, Ang = self:GetDisplayPos()

		if Scale <= 0 then return end
		if not Pos then return end

		local Cursor, CursorX, CursorY = self:GetCurserFromUser()

		local col = self:GetColor()
		self.GUI:SetAllowCursor(not StreamRadioLib.IsCursorHidden())
		self.GUI:SetDrawAlpha(col.a / 255)
		self.GUI:SetCursor(CursorX or -1, CursorY or -1)

		cam.Start3D2D( Pos, Ang, Scale )
			self.GUI:RenderSystem()
		cam.End3D2D( )
	end

	function ENT:DrawTranslucent( )
		BaseClass.DrawTranslucent( self )
		self.IsSeen = true
		self:DrawGUI()
	end

	function ENT:CanDrawSpectrum()
		if not self.__IsLibLoaded then return false end
		if not IsValid(self.GUI) then return false end
		if StreamRadioLib.IsSpectrumHidden() then return false end

		local ply = LocalPlayer()
		if not self:CanSeeDisplay(ply) then return false end

		local dist = self:DistanceToPlayer(ply)
		if dist > StreamRadioLib.GetSpectrumDistance() then return false end

		return true
	end
else
	function ENT:OnSetupCopyData(data)
		data.GUI = nil
		data.GUI_Main = nil
	end

	function ENT:PostClasssystemPaste()
		BaseClass.PostClasssystemPaste( self )
		if not IsValid(self.GUI) then return end
		self.GUI:LoadFromDupe()
	end
end
