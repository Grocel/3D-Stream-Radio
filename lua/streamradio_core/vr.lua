StreamRadioLib.VR = {}
local LIB = StreamRadioLib.VR

function LIB.IsInstalled()
	return istable(g_VR)
end

function LIB.IsActive(ply)
	if not LIB.IsInstalled() then return false end

	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return false end
	if not ply:IsPlayer() then return false end
	if ply:IsBot() then return false end

	if CLIENT and ply == LocalPlayer() then
		if not g_VR.active then return false end
		return true
	end

	return LIB.GetNetworkedFrame(ply) ~= nil
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

function LIB.GetNetworkedFrame(ply)
	if not LIB.IsInstalled() then return nil end

	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return nil end

	local steamId = ply:SteamID()

	if SERVER then
		local playerBuffer = nil

		if game.SinglePlayer() then
			playerBuffer = g_VR['STEAM_0:0:0:']
		else
			playerBuffer = g_VR[steamId]
		end

		if not playerBuffer then
			return nil
		end

		local frame = playerBuffer.latestFrame
		if not frame then
			return nil
		end

		return frame
	end

	local netBuffer = g_VR.net
	if not netBuffer then
		return nil
	end

	local playerBuffer = netBuffer[steamId]
	if not playerBuffer then
		return nil
	end

	local frame = playerBuffer.lerpedFrame
	if not frame then
		return nil
	end

	return frame
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

	local vehicle = ply.GetVehicle and ply:GetVehicle()
	if IsValid(vehicle) then
		return nil -- API is broken for vehicles
	end

	if CLIENT and ply == LocalPlayer() then
		if g_VR.tracking and g_VR.tracking.pose_righthand and g_VR.tracking.pose_righthand.pos and g_VR.tracking.pose_righthand.ang then
			local pos = g_VR.tracking.pose_righthand.pos
			local dir = g_VR.tracking.pose_righthand.ang:Forward()

			return pos, dir
		end
	end

	local networkedFrame = LIB.GetNetworkedFrame(ply)
	if not networkedFrame then return nil end

	local pos = networkedFrame.righthandPos
	local ang = networkedFrame.righthandAng

	if not pos then return nil end
	if not ang then return nil end

	if SERVER then
		pos, ang = LocalToWorld(pos, ang, ply:GetPos(), Angle())
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

	if CLIENT and ply == LocalPlayer() then
		if g_VR.tracking and g_VR.tracking.hmd and g_VR.tracking.hmd.pos and g_VR.tracking.hmd.ang then
			local pos = g_VR.tracking.hmd.pos
			local ang = g_VR.tracking.hmd.ang
			return pos, ang
		end
	end

	local networkedFrame = LIB.GetNetworkedFrame(ply)
	if not networkedFrame then return nil end

	local pos = networkedFrame.hmdPos
	if not pos then return nil end

	local ang = networkedFrame.hmdAng
	if not ang then return nil end

	if SERVER then
		local vehicle = ply.GetVehicle and ply:GetVehicle()
		if IsValid(vehicle) then
			return nil -- API is broken for vehicles
		end

		pos, ang = LocalToWorld(pos, ang, ply:GetPos(), Angle())
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

	local wep = ply:GetActiveWeapon()

	if IsValid(wep) then
		local class = wep:GetClass()

		if class ~= "weapon_vrmod_empty" then
			return false
		end
	end

	return true
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

	return g_VR.input and g_VR.input.boolean_primaryfire or false
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

	local tr = LIB.TraceHand()
	if not tr then
		return false
	end

	if not tr.Hit then
		return false
	end

	local ent = tr.Entity

	if not IsValid(ent) then
		return false
	end

	if not ent.__IsRadio then
		return false
	end

	return true
end

local trace = {}
function LIB.TraceHand()
	if not CLIENT then
		return nil
	end

	if not LIB.IsActive() then
		return nil
	end

	local pos, dir = StreamRadioLib.VR.GetControlPosDir()

	if not pos then
		return nil
	end

	if not dir then
		return nil
	end

	local start_pos = pos
	local end_pos = pos + dir * 6.5

	trace.start = start_pos
	trace.endpos = end_pos

	local ply = LocalPlayer()

	trace.filter = function(ent)
		if not IsValid(ent) then return false end
		if not IsValid(ply) then return false end

		if ent == ply then return false end

		if ply.GetVehicle and ent == ply:GetVehicle() then return false end
		return true
	end

	return util.TraceLine(trace)
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

		return panel
	end

	local curPanel = panel

	while true do
		if not IsValid(curPanel) then
			return nil
		end

		if curPanel == g_SpawnMenu then
			return "spawnmenu"
		end

		if curPanel == g_ContextMenu then
			return "spawnmenu"
		end

		local uid = tostring(curPanel._streamradio_vr_uid or "")
		if uid ~= "" then
			return uid
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
		panelOrUid = g_VR.menuFocus
	end

	panelOrUid = LIB.GetMenuUid(panelOrUid)

	if not panelOrUid then
		return false
	end

	if not VRUtilIsMenuOpen then
		return false
	end

	if not VRUtilIsMenuOpen(panelOrUid) then
		return false
	end

	return true
end

function LIB.CloseMenu(panel)
	if not CLIENT then
		return
	end

	local uid = LIB.GetMenuUid(panel)
	if not uid then
		return
	end

	LIB.g_openMenus = LIB.g_openMenus or {}
	LIB.g_openMenus[uid] = nil

	panel:Close()

	if not LIB.MenuIsOpen(uid) then
		return
	end

	if not VRUtilMenuClose then
		return
	end

	VRUtilMenuClose(uid)
end

function LIB.RenderMenu(panel)
	if not CLIENT then
		return
	end

	local uid = LIB.GetMenuUid(panel)
	if not uid then
		return
	end

	if not LIB.MenuIsOpen(uid) then
		return
	end

	if not VRUtilMenuRenderPanel then
		return
	end

	VRUtilMenuRenderPanel(uid)
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

	if not VRUtilMenuOpen then
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

	local ang = Angle(0, camang.y - 90, 80)
	local pos = campos + Vector(0, 0, -10) + Angle(0, camang.y, 0):Forward() * 30 - ang:Forward() * w / 2 * scale - ang:Right() * h / 2 * scale
	pos, ang = WorldToLocal(pos, ang, g_VR.origin, g_VR.originAngle)

	VRUtilMenuOpen(uid, w, h, panel, 4, pos, ang, scale, cursorEnabled, closeFunc)
end

if CLIENT then
	local function clearMenus()
		for k, v in pairs(LIB.g_openMenus or {}) do
			LIB.CloseMenu(v)
		end

		LIB.g_openMenus = nil
	end

	hook.Add("VRUtilStart", "StreamRadioCloseMenusOnVRStart", function()
		clearMenus()
	end)

	hook.Add("VRUtilExit", "StreamRadioCloseMenusOnVRExit", function()
		clearMenus()
	end)

	clearMenus()
end
