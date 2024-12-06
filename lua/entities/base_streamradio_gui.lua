AddCSLuaFile()
DEFINE_BASECLASS("base_streamradio")

local StreamRadioLib = StreamRadioLib

local LIBModel = StreamRadioLib.Model
local LIBSkin = StreamRadioLib.Skin
local LIBWire = StreamRadioLib.Wire
local LIBUtil = StreamRadioLib.Util

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
	if self.DisplayLess then return false end
	if self:GetDisableInput() then return false end

	local GUI = self.GUI

	if not IsValid(GUI) then
		return false
	end

	if not GUI:IsReady() then
		return false
	end

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

	local modalData = self.ModelData
	if not modalData then return false end

	local func = modalData[index]
	if not isfunction(func) then return false end

	return true
end

function ENT:GetModelFunction(index)
	if not index then return end

	local modalData = self.ModelData
	if not modalData then return end

	local func = modalData[index]
	if not isfunction(func) then return end

	return func
end

function ENT:CallModelFunction(index, ...)
	if not index then return end

	local modalData = self.ModelData
	if not modalData then return end

	local func = modalData[index]
	if not isfunction(func) then return end

	return func(modalData, self, ...)
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

	self.ModelData = LIBModel.GetModelSettings(model) or {}
	local MD = self.ModelData

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
		tmpGui.OnLoadDone = nil
		tmpGui.OnReady = nil
		tmpGui:Remove()
		tmpGui = nil
	end

	if hasGuiMain then
		tmpGuiMain:Remove()
		tmpGuiMain = nil
	end
end

function ENT:SetupGui(callback)
	if not IsValid(self.GUI) then
		self.GUI = StreamRadioLib.CreateOBJ("gui_controller")
	end

	local GUI = self.GUI

	GUI:SetName("gui")
	GUI:SetNWName("g")
	GUI:SetEntity(self)
	GUI:ActivateNetworkedMode()

	if SERVER and LIBUtil.IsDebug() then
		self:SetEnableDebug(true)
	end

	GUI:SetDebug(self:GetEnableDebug())

	if not IsValid(self.GUI_Main) then
		self.GUI_Main = GUI:AddPanelByClassname("radio/gui_main")
	end

	local GUI_Main = self.GUI_Main

	GUI_Main:SetPos(0, 0)
	GUI_Main:SetName("main")
	GUI_Main:SetNWName("m")
	GUI_Main:SetSkinIdentifyer("main")
	GUI_Main:SetStream(self.StreamObj)
	GUI_Main:SetHasPlaylist(self:GetHasPlaylist())

	GUI_Main.OnToolButtonClick = function(this)
		if not IsValid(self) then return end
		self:OnToolButtonClick()
	end

	GUI_Main.OnWireButtonClick = function(this)
		if not IsValid(self) then return end
		self:OnWireButtonClick()
	end

	GUI_Main.OnPlayerClosed = function(this)
		if not IsValid(self) then return end
		self:OnPlayerClosed()
	end

	GUI_Main.OnPlayerShown = function(this)
		if not IsValid(self) then return end
		self:OnPlayerShown()
	end

	GUI_Main.OnPlaylistClose = function(this)
		if not IsValid(self) then return end
		self:ClearPlaylist()
	end

	if SERVER then
		GUI_Main.OnPlaylistBack = function(this)
			if not IsValid(self) then return end
			self:PlayPreviousPlaylistItem()
		end

		GUI_Main.OnPlaylistForward = function(this)
			if not IsValid(self) then return end
			self:PlayNextPlaylistItem()
		end

		GUI_Main.OnPlaylistStartBuild = function(this)
			if not IsValid(self) then return end

			if self._dupePlaylistData then
				self:ReapplyPlaylistFromDupe()
				return
			end

			self:ClearPlaylist()
		end

		GUI_Main.OnPlaylistEndBuild = function(this, playlistItems)
			if not IsValid(self) then return end

			if self._dupePlaylistData then
				self:ReapplyPlaylistFromDupe()
				return
			end

			if not playlistItems then
				self:ClearPlaylist()
				return
			end

			self:SetPlaylist(playlistItems, 1)
		end

		GUI_Main.OnStop = function(this)
			if not IsValid(self) then return end

			self:StopStreamInternal()
		end

		GUI_Main.OnPlayItem = function(this, item)
			if not IsValid(self) then return end

			self:PlayFromPlaylistItem(item)
		end
	end

	local model = self:GetModel()
	self:CallModelFunction("InitializeFonts", model)
	self:CallModelFunction("SetupGUI", GUI, GUI_Main)

	GUI:SetSkin(LIBSkin.GetDefaultSkin())
	GUI:PerformRerender(true)

	GUI.OnReady = function()
		GUI.OnReady = nil

		local THIS_GUI = self.GUI
		local THIS_GUI_Main = self.GUI_Main

		if not IsValid(self) then
			return
		end

		if not IsValid(THIS_GUI) then
			return
		end

		if not IsValid(THIS_GUI_Main) then
			return
		end

		self:AddObjToNwRegister(THIS_GUI)
		self:CallModelFunction("OnGUIReady", GUI, GUI_Main)

		if self.OnGUIReady then
			self:OnGUIReady(THIS_GUI, THIS_GUI_Main)
		end
	end

	if self.OnGUISetup then
		self:OnGUISetup(GUI, GUI_Main)
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

function ENT:StreamOnTrackEnd(stream)
	self:CallModelFunction("OnTrackEnd", stream)
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

	-- delay the GUI rebuild in case many newly spawned radios are seen at once
	if SysTime() > g_displayBuildTimer then
		self:SetupGui()

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

function ENT:InternalSlowThink()
	BaseClass.InternalSlowThink(self)

	self:PlaylistThink()
end

function ENT:NonDormantThink()
	BaseClass.NonDormantThink(self)

	if self:IsSeen() then
		self:ControlThink(self:GetLastUser(), self:GetLastUsingEntity())
	end
end

function ENT:ControlThink(ply, userEntity)
	local GUI = self.GUI

	if not IsValid(GUI) then
		return
	end

	local pos, ang = self:CalcDisplayPosAngWorld()

	if CLIENT and self:ShowDebug() then
		debugoverlay.Axis(pos, ang, 5, 0.05, color_white)
		debugoverlay.EntityTextAtPosition(pos, 1, "Display pos", 0.05, color_white)
	end

	if not IsValid(ply) then
		return
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

	self:AddDTNetworkVar( "Bool", "HasPlaylist" )

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
			title = "Disable user input",
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

	self:SetDTVarCallback("EnableDebug", function(this, name, oldv, newv)
		if not IsValid(self.GUI) then return end
		self.GUI:SetDebug(newv)
	end)

	self:SetDTVarCallback("HasPlaylist", function(this, name, oldv, newv)
		if not IsValid(self.GUI_Main) then return end
		self.GUI_Main:SetHasPlaylist(newv)
	end)

	if CLIENT then
		self:SetDTVarCallback("DisableDisplay", function(this, name, oldv, newv)
			if newv then
				self:RemoveGui()
			end
		end)
	end
end

function ENT:AddItemToPlaylist(newItem)
	if CLIENT then return end

	local url = string.Trim(
		tostring(
			newItem.url or
			newItem.uri or
			newItem.link or
			newItem.source or
			newItem.path or ""
		)
	)

	local name = string.Trim(
		tostring(
			newItem.name or
			newItem.title or ""
		)
	)

	if url == "" then
		return
	end

	if name == "" then
		name = url
	end

	local playlistObj = self.PlaylistData
	local data = playlistObj.data

	local index = #data + 1

	local entry = {
		name = name,
		url = url,
		index = index,
	}

	data[index] = entry

	self._updatedPlaylist = true
	self._nextPlaylistSwitch = nil

	if index > 1 then
		self:SetHasPlaylist(true)
	end
end

function ENT:AddItemsToPlaylist(newItems)
	if CLIENT then return end

	for i, newItem in ipairs(newItems) do
		self:AddItemToPlaylist(newItem)
	end
end

function ENT:SetPlaylist(playlist, pos)
	if CLIENT then return end

	if not pos then
		pos = 1
	end

	self:ClearPlaylist()
	self:AddItemsToPlaylist(playlist)

	local playlistObj = self.PlaylistData
	playlistObj.pos = math.Clamp(pos or 1, 1, #playlistObj.data)
end

function ENT:ClearPlaylist()
	if CLIENT then return end

	local playlistObj = self.PlaylistData

	StreamRadioLib.Util.EmptyTableSafe(playlistObj.data)
	playlistObj.pos = 0

	self._updatedPlaylist = true
	self._nextPlaylistSwitch = nil

	self:SetHasPlaylist(false)
end

function ENT:HasPlaylistInternal()
	if CLIENT then
		return false
	end

	local playlistObj = self.PlaylistData
	local data = playlistObj.data

	if #data <= 1 then
		return false
	end

	return true
end

function ENT:PlayPreviousPlaylistItem()
	if CLIENT then return end

	local playlistObj = self.PlaylistData
	local data = playlistObj.data

	local len = #data
	if len <= 1 then return end

	local index = playlistObj.pos - 1
	if index <= 0 then
		index = len
	end

	index = math.Clamp(index, 1, len)

	local playlistItem = data[index]
	self:PlayFromPlaylistItem(playlistItem)
end

function ENT:PlayNextPlaylistItem()
	if CLIENT then return end

	local playlistObj = self.PlaylistData
	local data = playlistObj.data

	local len = #data
	if len <= 1 then return end

	local index = playlistObj.pos + 1
	if index > len then
		index = 1
	end

	index = math.Clamp(index, 1, len)

	local playlistItem = data[index]
	self:PlayFromPlaylistItem(playlistItem)
end

function ENT:PlayFromPlaylistItemByIndex(index)
	if CLIENT then return end

	local playlistObj = self.PlaylistData
	local data = playlistObj.data

	index = math.Clamp(index or 1, 1, #data)

	local playlistItem = data[index]
	if not playlistItem then return end

	self:PlayFromPlaylistItem(playlistItem)
end

function ENT:PlayFromCurrentPlaylistItem()
	if CLIENT then return end

	local playlistObj = self.PlaylistData
	self:PlayFromPlaylistItemByIndex(playlistObj.pos or 1)
end

function ENT:PlayFromPlaylistItem(playlistItem)
	if CLIENT then return end
	if not playlistItem then return end

	local now = RealTime()
	if self._nextPlaylistSwitch and self._nextPlaylistSwitch > now then
		-- Prevent playlist abuse/spam
		return
	end

	local url = playlistItem.url
	local name = playlistItem.name

	local playlistObj = self.PlaylistData
	local data = playlistObj.data

	playlistObj.pos = math.Clamp(playlistItem.index or 1, 1, #data)
	self:PlayStreamInternal(url, name)

	self._nextPlaylistSwitch = now + 0.25
end

function ENT:GetPlaylist()
	if CLIENT then return end

	local playlistObj = self.PlaylistData
	local data = playlistObj.data

	return data
end

function ENT:GetPlaylistPos()
	if CLIENT then return end

	local playlistObj = self.PlaylistData
	local pos = playlistObj.pos or 1

	return pos
end

function ENT:PlaylistThink()
	if CLIENT then return end

	if not self._updatedPlaylist then return end
	self._updatedPlaylist = nil

	self:SetHasPlaylist(self:HasPlaylistInternal())

	self:OnPlaylistChanged()
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	if SERVER then
		self.PlaylistData = {
			data = {},
			pos = 0,
		}

		self:ClearPlaylist()
	end

	self:SetUpModel()
end

function ENT:OnRemove()
	self:CallModelFunction("OnRemove", model)
	self:RemoveGui()
	self:ClearPlaylist()

	BaseClass.OnRemove(self)
end

function ENT:OnToolButtonClick()
	-- Override me
end

function ENT:OnWireButtonClick()
	-- Override me
end

function ENT:OnPlaylistChanged()
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

function ENT:OnGUIReady()
	if CLIENT then return end

	if self._postClasssystemPasteLoadDupeOnGUIReady then
		self:ReapplyClasssystemPaste()
	end

	if self._dupePlaylistData then
		self:ReapplyPlaylistFromDupe()
	end
end

function ENT:OnGUISetup(GUI, GUI_Main)
	-- Override me
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
		if self.DisplayLess then
			return true
		end

		local ply = LocalPlayer()
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

		local ply = LocalPlayer()
		if not self:CheckDistanceToEntity(ply, StreamRadioLib.GetDrawDistance(), nil, StreamRadioLib.GetCameraViewPos(ply)) then
			return
		end

		self:PollGuiSetup()

		local GUI = self.GUI

		if not IsValid(GUI) then
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
		GUI:SetAllowCursor(StreamRadioLib.IsCursorEnabled())
		GUI:SetDrawAlpha(col.a / 255)

		if Cursor or not IsValid(lastUser) then
			GUI:SetCursor(CursorX or -1, CursorY or -1)
		end

		cam.Start3D2D( pos, ang, scale )
			GUI:RenderSystem()
		cam.End3D2D( )
	end

	function ENT:DrawTranslucent(...)
		BaseClass.DrawTranslucent(self, ...)
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

		local GUI = self.GUI

		if not IsValid(GUI) then
			return false
		end

		if not GUI:IsReady() then
			return false
		end

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

	function ENT:ReapplyPlaylistFromDupe()
		-- Reapply the duped playlist data once.
		-- This is needed, because gui would override it on creation, which is not wanted.

		local timerId = "KillDupePlaylist_" .. tostring(self)
		StreamRadioLib.Timer.Remove(timerId)

		if self.DisplayLess then
			self._dupePlaylistData = nil
			return
		end

		local playlist = self._dupePlaylistData
		if not playlist then
			return
		end

		StreamRadioLib.Timer.Once(timerId, 1, function()
			if not IsValid(self) then
				return
			end

			-- Remove the list data late to avoid any race conditions
			self._dupePlaylistData = nil
		end)

		local data = playlist.data
		if not data then return end

		local pos = playlist.pos or 1

		self:SetPlaylist(data, pos)
	end

	function ENT:OnSetupCopyData(data)
		BaseClass.OnPreEntityCopy(self, data)

		data.GUI = nil
		data.GUI_Main = nil
		data.PlaylistData = nil
	end

	function ENT:OnPreEntityCopy()
		BaseClass.OnPreEntityCopy(self)

		self:SetDupeData("PlaylistData", self.PlaylistData)
	end

	function ENT:DupeDataApply(key, value)
		BaseClass.DupeDataApply(self, key, value)

		if key ~= "PlaylistData" then return end

		local data = value.data
		if not data then return end

		local pos = value.pos or 1

		self:SetPlaylist(data, pos)

		if self.DisplayLess then
			self._dupePlaylistData = nil
			return
		end

		self._dupePlaylistData = value
	end

	function ENT:PostClasssystemPaste(data)
		if not IsValid(self.StreamObj) then
			return
		end

		if not self._postClasssystemPasteBaseCalled then
			BaseClass.PostClasssystemPaste(self, data)
			self._postClasssystemPasteBaseCalled = true
		end

		if self.DisplayLess then
			return
		end

		if not IsValid(self.GUI) then
			self._postClasssystemPasteLoadDupeOnGUIReady = true
			return
		end

		if self.GUI:IsLoading() then
			self._postClasssystemPasteLoadDupeOnGUIReady = true
			return
		end

		self._postClasssystemPasteLoadDupeOnGUIReady = nil
		self.GUI:LoadFromDupe(data)
	end

	function ENT:PreClasssystemCopy(data)
		BaseClass.PreClasssystemCopy(self, data)

		if IsValid(self.GUI) then
			self.GUI:LoadToDupe(data)
		end
	end
end
