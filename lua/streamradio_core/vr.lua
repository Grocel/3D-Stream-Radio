local StreamRadioLib = StreamRadioLib

StreamRadioLib.VR = StreamRadioLib.VR or {}

local LIB = StreamRadioLib.VR
table.Empty(LIB)

function LIB.IsInstalled()
	return vrmod ~= nil
end

function LIB.IsActive(ply)
	if not LIB.IsInstalled() then return false end

	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return false end
	if not ply:IsPlayer() then return false end
	if ply:IsBot() then return false end

	return vrmod.IsPlayerInVR(ply)
end

function LIB.Debug(txt)
	if not LIB.IsActive() then return end

	txt = tostring(txt)
	if txt == "" then return end

	if CLIENT then
		chat.AddText(txt)
	else
		MsgN(txt)
	end
end

function LIB.GetControlPosDir(ply)
	if not LIB.IsInstalled() then return nil end

	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return nil end

	-- Only allow for Hands
	if not LIB.HandsEquipped(ply) then
		return nil
	end

	-- Check if the player can make inputs at all
	if not LIB.GetVREnableTrigger(ply) and not LIB.GetVREnableTouch(ply) then
		return nil
	end

	-- Only allow if there is no focus on any menu
	if LIB.MenuIsOpen() then
		return nil
	end

	local pos, ang = vrmod.GetRightHandPose(ply)
	if not pos or not ang then
		return nil
	end

	local dir = ang:Forward()
	return pos, dir
end

function LIB.GetCameraPos(ply)
	if not LIB.IsInstalled() then return nil end

	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return nil end

	local pos, ang = vrmod.GetHMDPose(ply)
	if not pos then
		return nil
	end

	if not ang then
		return nil
	end

	return pos, ang
end

function LIB.HandsEquipped(ply)
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then
		return false
	end

	if ply:InVehicle() then
		return true
	end

	return vrmod.UsingEmptyHands(ply)
end

function LIB.GetTriggerPressed()
	if not CLIENT then
		return false
	end

	if not LIB.IsActive() then
		return false
	end

	if not LIB.GetVREnableTrigger() then
		return false
	end

	if not LIB.HandsEquipped() then
		return false
	end

	return vrmod.GetInput("boolean_primaryfire") or false
end

function LIB.GetRadioTouched()
	if not CLIENT then
		return false
	end

	if not LIB.GetVREnableTouch() then
		return false
	end

	if not LIB.HandsEquipped() then
		return false
	end

	local trace = LIB.TraceHand()
	if not trace then
		return false
	end

	if not trace.Hit then
		return false
	end

	local ent = trace.Entity

	if not IsValid(ent) then
		return false
	end

	if not ent.__IsRadio then
		return false
	end

	return true
end

local g_PlayerHandTraceCache = nil
local g_PlayerHandTrace = {}

g_PlayerHandTrace.output = {}
g_PlayerHandTrace.filter = {}

function LIB.TraceHand()
	if not CLIENT then
		return nil
	end

	if not LIB.IsActive() then
		g_PlayerHandTraceCache = nil
		return nil
	end

	if g_PlayerHandTraceCache and StreamRadioLib.Util.IsSameFrame("StreamRadioLib.VR.TraceHand") then
		return g_PlayerHandTraceCache
	end

	g_PlayerHandTraceCache = nil

	local pos, dir = LIB.GetControlPosDir()

	if not pos then
		return nil
	end

	if not dir then
		return nil
	end

	local start_pos = pos
	local end_pos = pos + dir * 6.5

	g_PlayerHandTrace.start = start_pos
	g_PlayerHandTrace.endpos = end_pos

	local ply = LocalPlayer()
	local plyVehicle = ply.GetVehicle and ply:GetVehicle() or false

	local tmp = {}

	tmp[ply] = ply
	tmp[plyVehicle] = plyVehicle

	local filter = g_PlayerHandTrace.filter
	table.Empty(filter)

	for _, filterEnt in pairs(tmp) do
		if not IsValid(filterEnt) then continue end
		table.insert(filter, filterEnt)
	end

	util.TraceLine(g_PlayerHandTrace)
	g_PlayerHandTraceCache = g_PlayerHandTrace.output

	return g_PlayerHandTraceCache
end

function LIB.GetVREnableTouch(ply)
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not LIB.IsActive(ply) then return false end
	return tobool(ply:GetInfo("cl_streamradio_vr_enable_touch"))
end

function LIB.GetVREnableTrigger(ply)
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not LIB.IsActive(ply) then return false end
	return tobool(ply:GetInfo("cl_streamradio_vr_enable_trigger"))
end

function LIB.GetMenuUid(panel)
	if not panel then
		return nil
	end

	if isstring(panel) then
		if panel == "" then
			return nil
		end

		return panel, LIB.g_openMenus and LIB.g_openMenus[panel]
	end

	local curPanel = panel

	while true do
		if not IsValid(curPanel) then
			return nil
		end

		if curPanel == g_SpawnMenu then
			return "spawnmenu", curPanel
		end

		if curPanel == g_ContextMenu then
			return "spawnmenu", curPanel
		end

		local uid = tostring(curPanel._streamradio_vr_uid or "")
		if uid ~= "" then
			return uid, curPanel
		end

		curPanel = curPanel:GetParent()
	end

	return nil
end

function LIB.MenuIsOpen(panelOrUid)
	if not CLIENT then
		return false
	end

	if not LIB.IsActive() then
		return false
	end

	if not panelOrUid then
		panelOrUid = vrmod.MenuFocused()
	end

	panelOrUid = LIB.GetMenuUid(panelOrUid)

	if not panelOrUid then
		return false
	end

	if not vrmod.MenuExists(panelOrUid) then
		return false
	end

	return true
end

function LIB.CloseMenu(panel)
	if not CLIENT then
		return
	end

	local uid, mainPanel = LIB.GetMenuUid(panel)
	if not uid then
		return
	end

	if not IsValid(mainPanel) then
		mainPanel = panel
	end

	LIB.g_openMenus = LIB.g_openMenus or {}
	LIB.g_openMenus[uid] = nil

	if ispanel(mainPanel) then
		mainPanel:Close()
	end

	if not LIB.MenuIsOpen(uid) then
		return
	end

	vrmod.MenuClose(uid)
end

function LIB.RenderMenu(panel)
	if not CLIENT then
		return
	end

	local uid, mainPanel = LIB.GetMenuUid(panel)
	if not uid then
		return
	end

	if not LIB.MenuIsOpen(uid) then
		return
	end

	if not IsValid(mainPanel) then
		mainPanel = panel
	end

	if ispanel(mainPanel) then
		timer.Simple(0.1, function()
			if not LIB.MenuIsOpen(uid) then
				return
			end

			if not IsValid(mainPanel) then
				return
			end

			vrmod.MenuRenderStart(uid)

			StreamRadioLib.Util.CatchAndErrorNoHaltWithStack(function()
				mainPanel:PaintManual()
			end)

			vrmod.MenuRenderEnd(uid)
		end)
	end
end

function LIB.MenuOpen(uid, panel, cursorEnabled, closeFunc)
	if not CLIENT then
		return
	end

	if not IsValid(panel) then
		return
	end

	uid = tostring(uid or "")
	if uid == "" then
		return
	end

	panel._streamradio_vr_uid = uid
	LIB.CloseMenu(panel)

	LIB.g_openMenus = LIB.g_openMenus or {}
	LIB.g_openMenus[uid] = panel

	panel:SetVisible(true)
	panel:MakePopup()
	panel:InvalidateLayout(true)

	if not LIB.IsActive() then
		return
	end

	local campos, camang = LIB.GetCameraPos()

	if not campos then
		return
	end

	if not camang then
		return
	end

	local scale = 0.04

	local w, h = panel:GetSize()

	local ang = Angle(0, camang.y - 90, 85)
	local pos = campos + Vector(0, 0, -10) + Angle(0, camang.y, 0):Forward() * 30 - ang:Forward() * w / 2 * scale - ang:Right() * h / 2 * scale
	local originPos, originAng = vrmod.GetOrigin()

	pos, ang = WorldToLocal(pos, ang, originPos, originAng)

	vrmod.MenuCreate(uid, w, h, panel, 4, pos, ang, scale, cursorEnabled, closeFunc)
end

if CLIENT then
	local function clearMenus()
		for k, v in pairs(LIB.g_openMenus or {}) do
			LIB.CloseMenu(v)
		end

		LIB.g_openMenus = nil
	end

	StreamRadioLib.Hook.Add("VRUtilStart", "CloseMenusOnVRStart", function()
		clearMenus()
	end)

	StreamRadioLib.Hook.Add("VRUtilExit", "CloseMenusOnVRExit", function()
		clearMenus()
	end)

	clearMenus()
end

return true

