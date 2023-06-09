local Color = Color
local tostring = tostring
local tonumber = tonumber
local type = type
local IsValid = IsValid
local MsgN = MsgN
local MsgC = MsgC
local LocalPlayer = LocalPlayer
local file = file
local sound = sound
local debug = debug
local util = util
local string = string
local math = math
local hook = hook
local SERVER = SERVER
local CLIENT = CLIENT
local BASS3 = BASS3 or {}
local StreamRadioLib = StreamRadioLib

local _, NetURL = StreamRadioLib.LoadSH('streamradio_core/neturl.lua')
StreamRadioLib.NetURL = NetURL

function StreamRadioLib.Msg(ply, msgstring)
	msgstring = tostring(msgstring or "")
	if msgstring == "" then return end

	if IsValid(ply) then
		ply:PrintMessage(HUD_PRINTTALK, msgstring)
	else
		MsgN(msgstring)
	end
end

local colorSeparator = Color(255,255,255)
local colorDateTime = Color(180,180,180)
local colorAddonName = Color(0,200,0)
local colorPlayer = Color(200,200,0)

function StreamRadioLib.Log(ply, msgstring)
	msgstring = tostring(msgstring or "")
	if msgstring == "" then return end

	local playerStr = ""

	if IsValid(ply) then
		playerStr = string.format("%s - %s", tostring(ply), ply:SteamID())
	end

	local Timestamp = os.time()
	local TimeString = os.date("%Y-%m-%d %H:%M:%S" , Timestamp)

	MsgC(colorSeparator, "[")
	MsgC(colorDateTime, TimeString)
	MsgC(colorSeparator, "]")

	MsgC(colorSeparator, "[")
	MsgC(colorAddonName, StreamRadioLib.AddonTitle)
	MsgC(colorSeparator, "]")

	if playerStr ~= "" then
		MsgC(colorSeparator, "[")
		MsgC(colorPlayer, playerStr)
		MsgC(colorSeparator, "]")
	end

	Msg(" ")

	MsgN(msgstring)
end

function StreamRadioLib.ErrorNoHaltWithStack(err)
	err = tostring(err or "")
	ErrorNoHaltWithStack(err)
end

local catchAndNohalt = function(err)
	local msgstring = tostring(err or "")
	msgstring = string.Trim(StreamRadioLib.AddonPrefix .. msgstring) .. "\n"

	StreamRadioLib.ErrorNoHaltWithStack(err)

	return err
end

function StreamRadioLib.CatchAndErrorNoHaltWithStack(func, ...)
	return xpcall(func, catchAndNohalt, ...)
end

function StreamRadioLib.Debug(format, ...)
	if not StreamRadioLib.IsDebug() then return end

	format = tostring(format or "")
	if format == "" then return end

	local msgstring = string.format(format, ...)
	msgstring = string.Trim(msgstring)

	if msgstring == "" then return end

	local tmp = string.Explode("\n", msgstring, false)
	for i, v in ipairs(tmp) do
		tmp[i] = "  " .. v .. "\n"
	end

	msgstring = table.concat(tmp)
	msgstring = string.Trim(StreamRadioLib.AddonPrefix .. msgstring) .. "\n"

	if StreamRadioLib.VR.IsActive() then
		StreamRadioLib.VR.Debug(msgstring)
	else
		MsgN(msgstring)
	end
end

function StreamRadioLib.Hash(str)
	str = tostring(str or "")

	local salt = "StreamRadioLib_Hash230609"

	local data = string.format(
		"[%s][%s]",
		salt,
		str
	)

	local hash = util.SHA256(data)
	return hash
end

local g_uid = 0
function StreamRadioLib.Uid()
	g_uid = (g_uid + 1) % 2 ^ 31
	return g_uid
end

function StreamRadioLib.NormalizeNewlines(text, nl)
	nl = tostring(nl or "")
	text = tostring(text or "")

	local replacemap = {
		["\r\n"] = true,
		["\r"] = true,
		["\n"] = true,
	}

	if not replacemap[nl] then
		nl = "\n"
	end

	replacemap[nl] = nil

	for k, v in pairs(replacemap) do
		replacemap[k] = nl
	end

	text = string.gsub(text, "([\r]?[\n]?)", replacemap)

	return text
end

function StreamRadioLib.IsGUIHidden(ply)
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return true end
	if not ply:IsPlayer() then return true end
	if ply:IsBot() then return true end

	return tobool(ply:GetInfo("cl_streamradio_hidegui"))
end

function StreamRadioLib.IsMuted(ply)
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

function StreamRadioLib.HasYoutubeSupport(ply)
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return false end
	if not ply:IsPlayer() then return false end
	if ply:IsBot() then return false end

	return tobool(ply:GetInfo("cl_streamradio_youtubesupport"))
end

function StreamRadioLib.GameIsPaused()
	local frametime = FrameTime()

	if frametime > 0 then
		return false
	end

	return true
end

function StreamRadioLib.GetDefaultModel()
	local defaultModel = Model("models/sligwolf/grocel/radio/radio.mdl")
	return defaultModel
end

local g_cache_IsValidModel = {}
local g_cache_IsValidModelFile = {}

function StreamRadioLib.IsValidModel(model)
	model = tostring(model or "")

	if g_cache_IsValidModel[model] then
		return true
	end

	g_cache_IsValidModel[model] = nil

	if not StreamRadioLib.IsValidModelFile(model) then
		return false
	end

	util.PrecacheModel(model)

	if not util.IsValidModel(model) then
		return false
	end

	if not util.IsValidProp(model) then
		return false
	end

	g_cache_IsValidModel[model] = true
	return true
end

function StreamRadioLib.IsValidModelFile(model)
	model = tostring(model or "")

	if g_cache_IsValidModelFile[model] then
		return true
	end

	g_cache_IsValidModelFile[model] = nil

	if model == "" then
		return false
	end

	if IsUselessModel(model) then
		return false
	end

	if not file.Exists(model, "GAME") then
		return false
	end

	g_cache_IsValidModelFile[model] = true
	return true
end

function StreamRadioLib.FrameNumber()
	local frame = nil

	if CLIENT then
		frame = FrameNumber()
	else
		frame = engine.TickCount()
	end

	return frame
end

function StreamRadioLib.RealFrameTime()
	local frameTime = nil

	if CLIENT then
		frameTime = RealFrameTime()
	else
		frameTime = FrameTime()
	end

	return frameTime
end

function StreamRadioLib.RealTimeFps()
	local fps = StreamRadioLib.RealFrameTime()

	if fps <= 0 then
		return 0
	end

	fps = 1 / fps

	return fps
end

local g_LastFrameRegister = {}
local g_LastFrameRegisterCount = 0

function StreamRadioLib.IsSameFrame(id)
	local id = tostring(id or "")
	local lastFrame = g_LastFrameRegister[id]

	local frame = StreamRadioLib.FrameNumber()

	if not lastFrame or frame ~= lastFrame then

		-- prevent the cache from overflowing
		if g_LastFrameRegisterCount > 1024 then
			table.Empty(g_LastFrameRegister)
			g_LastFrameRegisterCount = 0
		end

		g_LastFrameRegister[id] = frame

		if not lastFrame then
			g_LastFrameRegisterCount = g_LastFrameRegisterCount + 1
		end

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

	if camera:IsPlayer() then
		pos = camera:EyePos()
		dir = camera:GetAimVector()
	else
		pos = camera:GetPos()

		-- This is not a mistake
		-- This allowes UI clicks/use via C-Menu aim
		dir = ent:GetAimVector()
	end

	return pos, dir
end

local g_PlayerTraceCache = {}
local g_PlayerTraceCacheCount = 0
local g_PlayerTrace = {}

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

	if cacheItem and StreamRadioLib.IsSameFrame("StreamRadioLib.Trace_" .. cacheID) then
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

	filter = {}

	for _, filterEnt in pairs(tmp) do
		if not IsValid(filterEnt) then continue end

		filter[#filter + 1] = filterEnt
	end

	g_PlayerTrace.filter = filter

	local trace = util.TraceLine(g_PlayerTrace)

	-- prevent the cache from overflowing
	if g_PlayerTraceCacheCount > 1024 then
		table.Empty(g_PlayerTraceCache)
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

function StreamRadioLib.StarTrace(traceparams, size, edges, layers)
	traceparams = traceparams or {}

	local centerpos = traceparams.start or Vector()

	size = math.abs(size or 0)
	edges = math.abs(edges or 0)
	layers = math.abs(layers or 0)

	traceparams.start = centerpos
	traceparams.output = nil

	local traceposes = {}
	local traces = {}

	for e = 1, edges do
		local u = g_TAU / edges * e

		for l = 1, layers do
			local v = g_TAU / layers * l

			local x = math.cos(u) * math.cos(v)
			local y = math.cos(u) * math.sin(v)
			local z = math.sin(u)

			local v = Vector(x, y, z)
			v:Normalize()

			if traceposes[v] then continue end
			traceposes[v] = true
		end
	end

	traceposes[Vector(0, 0, 1)] = true
	traceposes[Vector(0, 1, 0)] = true
	traceposes[Vector(1, 0, 0)] = true

	traceposes[Vector(0, 0, -1)] = true
	traceposes[Vector(0, -1, 0)] = true
	traceposes[Vector(-1, 0, 0)] = true

	for v, _ in pairs(traceposes) do
		local endpos = centerpos + v * size
		traceparams.endpos = endpos

		local trace = util.TraceLine(traceparams)

		-- Tracers Debug
		-- debugoverlay.Line(centerpos, trace.HitPos or endpos, 0.1, color_white, false)
		-- debugoverlay.Line(trace.HitPos or endpos, endpos, 0.1, color_black, false)

		traces[#traces + 1] = trace
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

		if(i >= count) then
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

	table.Empty(g_checkPropProtectionCache)

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
		local status, use = StreamRadioLib.CatchAndErrorNoHaltWithStack(ent.CPPICanUse, ent, ply)

		if not status then
			return false
		end

		if not use then
			return false
		end
	end

	if SERVER then
		local status, use = StreamRadioLib.CatchAndErrorNoHaltWithStack(hook.Run, "PlayerUse", ply, ent)

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

local function toUnicode(s)
	local s1, s2, s3, s4 = s:byte( 1, -1 )
	s = {s1, s2, s3, s4}

	local en = ""
	for i = 1, #s do
		local v = s[i]
		if ( not v ) then continue end

		en = en .. string.format( "%%%02X", v )
	end

	return en
end

local function URLEncode( str )
	str = str or ""
	if (str == "") then
		return ""
	end

	str = string.gsub( str, "\n", "\r\n" )
	str = string.gsub( str, "([^%w ])", toUnicode )
	str = string.gsub( str, " ", "+" )

	return str
end

local hex={}

for i = 0, 255 do
	hex[string.format( "%0x", i)] = string.char( i )
	hex[string.format( "%0X", i)] = string.char( i )
end

local function URLDecode( str )
	str = str or ""
	if (str == "") then
		return ""
	end

	str = string.gsub( str, '%%(%x%x)', hex )
	return str
end

StreamRadioLib.URLEncode = URLEncode
StreamRadioLib.URLDecode = URLDecode

local function NormalizeOfflineFilename( path )
	path = path or ""
	path = string.Replace( path, "\r", "" )
	path = string.Replace( path, "\n", "" )
	path = string.Replace( path, "\t", "" )
	path = string.Replace( path, "\b", "" )

	path = string.Replace( path, "\\", "/" )
	path = string.Replace( path, "../", "" )
	path = string.Replace( path, "//", "/" )

	if #path > 260 then
		return string.sub(path, 0, 260)
	end

	return path
end

function StreamRadioLib.URIAddParameter(url, parameter)
	if not istable(parameter) then
		parameter = {parameter}
	end

	url = tostring(url or "")
	url = NetURL.normalize(url)

	for k, v in pairs(parameter) do
		url.query[k] = v
	end

	url = tostring(url)
	return url
end

function StreamRadioLib.NormalizeURL(url)
	url = tostring(url or "")
	url = NetURL.normalize(url)
	url = tostring(url)

	return url
end

function StreamRadioLib.IsBlockedURLCode( url )
	if ( not StreamRadioLib.BlockedURLCode ) then return false end
	if ( StreamRadioLib.BlockedURLCode == "" ) then return false end

	url = url or ""
	local blocked = StreamRadioLib.BlockedURLCode

	return url == blocked
end

function StreamRadioLib.IsOfflineURL( url )
	url = string.Trim( url or "" )
	local protocol = string.Trim( string.match( url, ( "([ -~]+):[//\\][//\\]" ) ) or "" )

	if ( protocol == "" ) then
		return true
	end

	if ( protocol == "file" ) then
		return true
	end

	return false
end

function StreamRadioLib.ConvertURL( url )
	url = string.Trim(tostring(url or ""))

	if ( StreamRadioLib.IsOfflineURL( url ) ) then
		local fileurl = string.Trim( string.match( url, ( ":[//\\][//\\]([ -~]+)" ) ) or "" )

		if ( fileurl ~= "" ) then
			url = fileurl
		end

		url = "sound/" .. url
		url = NormalizeOfflineFilename(url)
		return url, StreamRadioLib.STREAM_URLTYPE_FILE
	end

	local URLType = StreamRadioLib.STREAM_URLTYPE_ONLINE

	local Cachefile = StreamRadioLib.Cache.GetFile( url )
	if ( Cachefile ) then
		url = "data/" .. Cachefile
		url = NormalizeOfflineFilename(url)
		URLType = StreamRadioLib.STREAM_URLTYPE_CACHE
	end

	return url, URLType
end

function StreamRadioLib.DeleteFolder(path)
	if not StreamRadioLib.DataDirectory then
		return false
	end

	if StreamRadioLib.DataDirectory == "" then
		return false
	end

	if path == "" then
		return false
	end

	if not string.StartWith(path, StreamRadioLib.DataDirectory) then
		return false
	end

	local files, folders = file.Find(path .. "/*", "DATA")

	for k, v in pairs(folders or {}) do
		StreamRadioLib.DeleteFolder(path .. "/" .. v)
	end

	for k, v in pairs(files or {}) do
		file.Delete(path .. "/" .. v)
	end

	file.Delete(path)

	if file.Exists(path, "DATA") then
		return false
	end

	if file.IsDir(path, "DATA") then
		return false
	end

	return true
end

StreamRadioLib.SpawnedRadios = {}

local LastThink = RealTime()

local g_radioCount = 0

hook.Add("Think", "Streamradio_Entity_Think", function()
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end

	local now = RealTime()
	if (now - LastThink) < 0.01 then return end
	LastThink = now

	StreamRadioLib.SpawnedRadios = StreamRadioLib.SpawnedRadios or {}
	local radioCount = 0

	for ent, _ in pairs(StreamRadioLib.SpawnedRadios) do
		if not IsValid(ent) then
			StreamRadioLib.SpawnedRadios[ent] = nil
			continue
		end

		if not ent.__IsRadio then
			StreamRadioLib.SpawnedRadios[ent] = nil
			continue
		end

		radioCount = radioCount + 1

		if ent.FastThink then
			ent:FastThink()
		end

		if ent:IsDormant() then continue end
		if not ent.DormantThink then continue end

		ent:DormantThink()
	end

	g_radioCount = radioCount

	if g_radioCount <= 0 then
		ClearCheckPropProtectionCache()
	end
end)

function StreamRadioLib.GetRadioCount()
	return g_radioCount
end

function StreamRadioLib.HasSpawnedRadios()
	return g_radioCount > 0
end
