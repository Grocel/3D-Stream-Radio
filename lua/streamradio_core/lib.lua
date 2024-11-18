local tostring = tostring
local tonumber = tonumber
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local util = util
local string = string
local math = math
local hook = hook
local SERVER = SERVER
local CLIENT = CLIENT

local StreamRadioLib = StreamRadioLib

local catchAndErrorNoHaltWithStack = StreamRadioLib.Util.CatchAndErrorNoHaltWithStack

function StreamRadioLib.IsGUIHidden(ply)
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return true end
	if not ply:IsPlayer() then return true end
	if ply:IsBot() then return true end

	return tobool(ply:GetInfo("cl_streamradio_hidegui"))
end

function StreamRadioLib.IsMuted(ply, owner)
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return true end
	if not ply:IsPlayer() then return true end
	if ply:IsBot() then return true end

	local muted = tobool(ply:GetInfo("cl_streamradio_mute"))
	if muted then
		return true
	end

	local volume = tonumber(ply:GetInfo("cl_streamradio_volume") or 0) or 0
	if volume <= 0 then
		return true
	end

	if IsValid(owner) and owner:IsPlayer() and not owner:IsBot() and owner ~= ply then
		local mutedForeign = tobool(ply:GetInfo("cl_streamradio_mute_foreign"))
		if mutedForeign then
			return true
		end
	end

	if SERVER then
		return false
	end

	local muteunfocused = tobool(ply:GetInfo("cl_streamradio_muteunfocused"))
	if not muteunfocused then
		return false
	end

	if system.HasFocus() then
		return false
	end

	return true
end

function StreamRadioLib.GetMuteDistance( ply )
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return 0 end
	if not ply:IsPlayer() then return 0 end
	if ply:IsBot() then return 0 end

	return math.Clamp(tonumber(ply:GetInfo("cl_streamradio_mutedistance")) or 500, 500, 5000)
end

function StreamRadioLib.GetCameraEnt(ply)
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then
		return nil
	end

	local camera = ply:GetViewEntity()
	if not IsValid(camera) then
		return ply
	end

	return camera
end

function StreamRadioLib.GetCameraPos(ent)
	if not IsValid(ent) and CLIENT then
		ent = LocalPlayer()
	end

	if StreamRadioLib.VR.IsActive(ent) then
		local pos = StreamRadioLib.VR.GetCameraPos(ent)
		return pos
	end

	if StreamRadioLib.Wire.IsWireUser(ent) then
		return StreamRadioLib.Wire.GetUserPos(ent)
	end

	local camera = StreamRadioLib.GetCameraEnt(ent)
	if not IsValid(camera) then return nil end

	local pos = nil

	if camera:IsPlayer() then
		pos = camera:EyePos()
	else
		pos = camera:GetPos()
	end

	return pos
end

function StreamRadioLib.GetControlPosDir(ent)
	if not IsValid(ent) and CLIENT then
		ent = LocalPlayer()
	end

	if StreamRadioLib.VR.IsActive(ent) then
		local pos, dir = StreamRadioLib.VR.GetControlPosDir(ent)
		return pos, dir
	end

	if StreamRadioLib.Wire.IsWireUser(ent) then
		local pos, dir = StreamRadioLib.Wire.GetUserPosDir(ent)
		return pos, dir
	end

	local camera = StreamRadioLib.GetCameraEnt(ent)

	if not IsValid(ent) then return nil end
	if not IsValid(camera) then return nil end

	local pos, dir

	if camera:IsPlayer() then
		pos = camera:EyePos()
		dir = camera:GetAimVector()
	else
		pos = camera:GetPos()

		-- This is not a mistake
		-- This allows UI clicks/use via C-Menu aim
		dir = ent:GetAimVector()
	end

	return pos, dir
end

local g_PlayerTraceCache = {}
local g_PlayerTraceCacheCount = 0

local g_PlayerTrace = {}
g_PlayerTrace.filter = {}

function StreamRadioLib.Trace(ent)
	if not IsValid(ent) and CLIENT then
		ent = LocalPlayer()
	end

	if not IsValid(ent) then
		return nil
	end

	if StreamRadioLib.Wire.IsWireUser(ent) then
		local trace = StreamRadioLib.Wire.WireUserTrace(ent)
		return trace
	end

	local camera = StreamRadioLib.GetCameraEnt(ent)
	if not IsValid(camera) then return nil end

	local cacheID = tostring(ent or "")
	local cacheItem = g_PlayerTraceCache[cacheID]

	if cacheItem and StreamRadioLib.Util.IsSameFrame("StreamRadioLib.Trace_" .. cacheID) then
		return cacheItem
	end

	g_PlayerTraceCache[cacheID] = nil

	local pos, dir = StreamRadioLib.GetControlPosDir(ent)

	if not pos then
		return nil
	end

	if not dir then
		return nil
	end

	local start_pos = pos
	local end_pos = pos + dir * 5000

	g_PlayerTrace.start = start_pos
	g_PlayerTrace.endpos = end_pos

	local entVehicle = ent.GetVehicle and ent:GetVehicle() or false
	local cameraVehicle = camera.GetVehicle and camera:GetVehicle() or false

	local tmp = {}

	tmp[ent] = ent
	tmp[camera] = camera
	tmp[entVehicle] = entVehicle
	tmp[cameraVehicle] = cameraVehicle

	local filter = g_PlayerTrace.filter
	table.Empty(filter)

	for _, filterEnt in pairs(tmp) do
		if not IsValid(filterEnt) then continue end
		table.insert(filter, filterEnt)
	end

	local trace = util.TraceLine(g_PlayerTrace)

	-- prevent the cache from overflowing
	if g_PlayerTraceCacheCount > 1024 then
		StreamRadioLib.Util.EmptyTableSafe(g_PlayerTraceCache)
		g_PlayerTraceCacheCount = 0
	end

	g_PlayerTraceCache[cacheID] = trace

	if not cacheItem then
		g_PlayerTraceCacheCount = g_PlayerTraceCacheCount + 1
	end

	return g_PlayerTraceCache[cacheID]
end

local g_PI = math.pi
local g_TAU = g_PI * 2
local g_starTracePoses = {}

local function buildStarTracePoses(layers, edges)
	layers = math.abs(layers or 0)
	edges = math.abs(edges or 0)

	for l = 1, layers do
		local u = g_TAU / layers * l

		for e = 1, edges do
			local v = g_TAU / edges * e

			local x = math.cos(u) * math.cos(v)
			local y = math.cos(u) * math.sin(v)
			local z = math.sin(u)

			local v = Vector(x, y, z)
			v:Normalize()

			if g_starTracePoses[v] then continue end
			g_starTracePoses[v] = true
		end
	end

	g_starTracePoses[Vector(0, 0, 1)] = true
	g_starTracePoses[Vector(0, 1, 0)] = true
	g_starTracePoses[Vector(1, 0, 0)] = true

	g_starTracePoses[Vector(0, 0, -1)] = true
	g_starTracePoses[Vector(0, -1, 0)] = true
	g_starTracePoses[Vector(-1, 0, 0)] = true
end

buildStarTracePoses(10, 6)

function StreamRadioLib.StarTrace(traceparams, size)
	traceparams = traceparams or {}

	local centerpos = traceparams.start or Vector()

	size = math.abs(size or 0)

	traceparams.start = centerpos
	traceparams.output = nil

	local traces = {}

	for v, _ in pairs(g_starTracePoses) do
		local endpos = centerpos + v * size
		traceparams.endpos = endpos

		local trace = util.TraceLine(traceparams)

		-- Tracers Debug
		-- debugoverlay.Line(centerpos, trace.HitPos or endpos, 0.5, color_white, false)
		-- debugoverlay.Line(trace.HitPos or endpos, endpos, 0.5, color_black, false)

		table.insert(traces, trace)
	end

	return traces
end

local g_mat_cache = {}

function StreamRadioLib.GetCustomPNGPath(name)
	if SERVER then return nil end
	if not name then return nil end

	local path = "3dstreamradio/" .. name .. ".png"
	return path
end

function StreamRadioLib.GetCustomPNG(name)
	if SERVER then return nil end
	if not name then return nil end

	local path = StreamRadioLib.GetCustomPNGPath(name)
	if not path then return nil end

	local mat = g_mat_cache[path]

	if mat then
		return mat
	end

	mat = Material( path, "nocull" )
	return mat
end

function StreamRadioLib.GetPNGIconPath(name, custom)
	if SERVER then return nil end
	if not name then return nil end

	local prepath = "icon16/" .. name

	if custom then
		return StreamRadioLib.GetCustomPNGPath(prepath)
	end

	local path = prepath .. ".png"
	return path
end

function StreamRadioLib.GetPNGIcon(name, custom)
	if SERVER then return nil end
	if not name then return nil end

	local path = StreamRadioLib.GetPNGIconPath(name, custom)
	if not path then return nil end

	local mat = g_mat_cache[path]

	if mat then
		return mat
	end

	mat = Material( path, "nocull" )

	return mat
end

function StreamRadioLib.GetHierarchy(hierarchy)
	if isstring(hierarchy) then
		if hierarchy == "" then
			return {}
		end

		return string.Explode("[%/%\\]", hierarchy, true) or {}
	end

	if istable(hierarchy) then
		return hierarchy
	end

	return nil
end

function StreamRadioLib.SetSkinTableProperty(tab, hierarchy, property, value)
	hierarchy = StreamRadioLib.GetHierarchy(hierarchy)
	if not hierarchy then return tab end

	tab = tab or {}
	property = tostring(property or "")

	local count = #hierarchy

	if count <= 0 then
		tab.data = tab.data or {}
		tab.data[property] = value
		return tab
	end

	tab.children = tab.children or {}
	local curskin = tab.children

	for i, v in ipairs(hierarchy) do
		local sk = curskin[v] or {}

		if i >= count then
			sk.data = sk.data or {}
			sk.data[property] = value
			curskin[v] = sk
			break
		end

		sk.children = sk.children or {}
		curskin[v] = sk
		curskin = curskin[v].children
	end

	return tab
end

local function ReleaseLastRadioControl(ply, trace, userEntity)
	local LastRadio = userEntity._3dstreamradio_lastusedradio
	userEntity._3dstreamradio_lastusedradio = nil

	if not IsValid( LastRadio ) then return end
	if not LastRadio.__IsRadio then return end
	if not LastRadio.Control then return end

	LastRadio:Control( ply, trace, false, userEntity )
end

local g_checkPropProtectionCache = {}
local g_checkPropProtectionCacheEmpty = true
local g_checkPropProtectionCacheExpire = nil

local function ClearCheckPropProtectionCache()
	if g_checkPropProtectionCacheEmpty then
		return
	end

	StreamRadioLib.Util.EmptyTableSafe(g_checkPropProtectionCache)

	g_checkPropProtectionCacheEmpty = true
	g_checkPropProtectionCacheExpire = nil
end

function StreamRadioLib.CheckPropProtectionAgainstUse(ent, ply)
	if not IsValid( ent ) then return false end
	if not IsValid( ply ) then return false end

	if CLIENT and not ent.CPPICanUse then
		return true
	end

	local cacheId = tostring(ent) .. "_" .. tostring(ply)
	local now = RealTime()

	-- cache the check result for a short time to avoid spam calling the hook "PlayerUse" and CPPI
	if g_checkPropProtectionCacheExpire and g_checkPropProtectionCacheExpire <= now then
		ClearCheckPropProtectionCache()
	end

	if g_checkPropProtectionCache[cacheId] ~= nil then
		return g_checkPropProtectionCache[cacheId]
	end

	if g_checkPropProtectionCacheEmpty then
		g_checkPropProtectionCacheExpire = now + 3
		g_checkPropProtectionCacheEmpty = false
	end

	g_checkPropProtectionCache[cacheId] = false

	-- Support for prop protections
	if ent.CPPICanUse then
		local status, use = catchAndErrorNoHaltWithStack(ent.CPPICanUse, ent, ply)

		if not status then
			return false
		end

		if not use then
			return false
		end
	end

	if SERVER then
		local status, use = catchAndErrorNoHaltWithStack(StreamRadioLib.Hook.Run, "PlayerUse", ply, ent)

		if not status then
			return false
		end

		if not use then
			return false
		end
	end

	g_checkPropProtectionCache[cacheId] = true
	return true
end

function StreamRadioLib.CanUseRadio(ply, radio, userEntity)
	if not IsValid( ply ) then return false end
	if not IsValid( radio ) then return false end
	if not radio.__IsRadio then return false end
	if not radio.Control then return false end
	if not radio.CanControl then return false end

	if not IsValid(userEntity) then
		userEntity = ply
	end

	local use = radio:CanControl(ply, userEntity)
	if not use then
		return false
	end

	return true
end

function StreamRadioLib.Control( ply, trace, keydown, userEntity )
	if not IsValid( ply ) then return end

	if not IsValid(userEntity) then
		userEntity = ply
	end

	if not trace then
		ReleaseLastRadioControl( ply, nil, userEntity )
		return
	end

	if not keydown then
		ReleaseLastRadioControl( ply, trace, userEntity )
		return
	end

	local Radio = trace.Entity
	local LastRadio = userEntity._3dstreamradio_lastusedradio

	if not StreamRadioLib.CanUseRadio( ply, Radio, userEntity ) then
		ReleaseLastRadioControl( ply, trace, userEntity )
		return
	end

	if Radio ~= LastRadio then
		ReleaseLastRadioControl( ply, trace, userEntity )
	end

	local rv = Radio:Control( ply, trace, true, userEntity )
	userEntity._3dstreamradio_lastusedradio = Radio

	return rv
end

function StreamRadioLib.TabControl( ply, trace, userEntity )
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then
		return
	end

	if not trace then
		return
	end

	if not IsValid(userEntity) then
		userEntity = ply
	end

	local ent = trace.Entity
	if not IsValid( ent ) then
		return
	end

	if not ent.__IsRadio then
		return
	end

	local name = tostring(ent) .. "_" .. tostring(ply) .. "_TabControl"

	trace = table.Copy(trace)

	StreamRadioLib.Control(ply, trace, true, userEntity)

	StreamRadioLib.Timer.NextFrame(name, function()
		if not IsValid(ply) then
			return
		end

		if not IsValid(ent) then
			return
		end

		if not IsValid(userEntity) then
			return
		end

		StreamRadioLib.Control(ply, trace, false, userEntity)
	end)
end

local g_PlayerCache = {}
local g_LocalPlayer = nil

function StreamRadioLib.GetPlayerId(ply)
	if not IsValid(ply) then
		return nil
	end

	if not ply:IsPlayer() then
		return nil
	end

	if ply:IsBot() then
		return nil
	end

	if game.SinglePlayer() then
		return "LOCAL_CLIENT"
	end

	if SERVER and not ply:IsConnected() then
		return nil
	end

	local id = ply:SteamID64()
	if not id then
		-- fallback to player string on invalid ids
		id = tostring(ply) .. "[" .. ply:UserID() .. "]";
	end

	g_PlayerCache[id] = ply
	return id
end

function StreamRadioLib.GetPlayerFromId(id)
	id = tostring(id or "")

	if id == "" then
		return nil
	end

	if game.SinglePlayer() then
		if id == "LOCAL_CLIENT" then
			if not IsValid(g_LocalPlayer) then
				g_LocalPlayer = player.GetHumans()[1]
			end

			if not IsValid(g_LocalPlayer) then
				return nil
			end

			return g_LocalPlayer
		end

		return nil
	end


	local ply = g_PlayerCache[id]

	if not IsValid(ply) then
		ply = player.GetBySteamID64(id)
	end

	g_PlayerCache[id] = nil

	if not IsValid(ply) then
		return nil
	end

	if ply:IsBot() then
		return nil
	end

	if SERVER and not ply:IsConnected() then
		return nil
	end

	g_PlayerCache[id] = ply
	return ply
end

local _GetPlayerId = StreamRadioLib.GetPlayerId
local _GetPlayerFromId = StreamRadioLib.GetPlayerFromId

function StreamRadioLib.IsPlayerNetworkable(plyOrId)
	if isentity(plyOrPId) then
		return _GetPlayerId(plyOrId) ~= nil
	end

	return IsValid(_GetPlayerFromId(plyOrId))
end

StreamRadioLib.SpawnedRadios = {}

local g_nextFastThink = 0
local g_radioCount = 0
local g_streamingRadioCount = 0

StreamRadioLib.Hook.Add("Think", "RadioCounter", function()
	StreamRadioLib.SpawnedRadios = StreamRadioLib.SpawnedRadios or {}
	local spawnedRadios = StreamRadioLib.SpawnedRadios

	local radioCount = 0
	local streamingRadioCount = 0

	for index, ent in pairs(spawnedRadios) do
		if not IsValid(ent) then
			spawnedRadios[index] = nil
			continue
		end

		if not ent.__IsRadio then
			spawnedRadios[index] = nil
			continue
		end

		radioCount = radioCount + 1

		if ent.IsStreaming and ent:IsStreaming() then
			streamingRadioCount = streamingRadioCount + 1
		end
	end

	g_radioCount = radioCount
	g_streamingRadioCount = streamingRadioCount

	if g_radioCount <= 0 then
		ClearCheckPropProtectionCache()
		return
	end
end)

StreamRadioLib.Hook.Add("Think", "EntityFastThink", function()
	local now = RealTime()
	if g_nextFastThink > now then return end

	g_nextFastThink = now + 0.01

	local radios = StreamRadioLib.SpawnedRadios
	if not radios then
		return
	end

	for index, ent in pairs(radios) do
		if not IsValid(ent) then
			continue
		end

		if ent.FastThink then
			-- Think with a faster rate that doesn't interfere with model animations
			ent:FastThink()
		end

		if ent:IsDormant() then
			continue
		end

		if not ent.NonDormantThink then
			continue
		end

		-- Called when the radio is not Dormant
		ent:NonDormantThink()
	end
end)

function StreamRadioLib.GetRadioCount()
	return g_radioCount
end

function StreamRadioLib.HasSpawnedRadios()
	return g_radioCount > 0
end

function StreamRadioLib.GetStreamingRadioCount()
	return g_streamingRadioCount
end

function StreamRadioLib.HasStreamingRadios()
	return g_streamingRadioCount > 0
end

function StreamRadioLib.RegisterRadio(ent)
	if not IsValid(ent) then
		return
	end

	if not ent.__IsRadio then
		return
	end

	StreamRadioLib.Network.SetupEntityTable(ent)
	StreamRadioLib.SpawnedRadios[ent:GetCreationID()] = ent
end

function StreamRadioLib.UnregisterRadio(entOrCreationID)
	if isnumber(entOrCreationID) then
		StreamRadioLib.SpawnedRadios[entOrCreationID] = nil
		return
	end

	if not IsValid(ent) then
		return
	end

	StreamRadioLib.SpawnedRadios[ent:GetCreationID()] = nil
end

return true

