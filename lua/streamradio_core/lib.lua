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

// Placeholder for Blocked URLs with non-Keyboard chars
StreamRadioLib.BlockedURLCode = string.char(124, 245, 142, 188, 5, 6, 2, 1, 2, 54, 12, 7, 5)

StreamRadioLib.EDITOR_ERROR_OK = 0
StreamRadioLib.EDITOR_ERROR_WRITE_OK = 1
StreamRadioLib.EDITOR_ERROR_READ_OK = 2
StreamRadioLib.EDITOR_ERROR_FILES_OK = 3
StreamRadioLib.EDITOR_ERROR_DIR_OK = 4
StreamRadioLib.EDITOR_ERROR_DEL_OK = 5
StreamRadioLib.EDITOR_ERROR_COPY_OK = 6
StreamRadioLib.EDITOR_ERROR_RENAME_OK = 7

StreamRadioLib.EDITOR_ERROR_WPATH = 10
StreamRadioLib.EDITOR_ERROR_WDATA = 11
StreamRadioLib.EDITOR_ERROR_WFORMAT = 12
StreamRadioLib.EDITOR_ERROR_WVIRTUAL = 13
StreamRadioLib.EDITOR_ERROR_WRITE = 14

StreamRadioLib.EDITOR_ERROR_DIR_WRITE = 14
StreamRadioLib.EDITOR_ERROR_DIR_EXIST = 15
StreamRadioLib.EDITOR_ERROR_FILE_EXIST = 16
StreamRadioLib.EDITOR_ERROR_DEL_ACCES = 17

StreamRadioLib.EDITOR_ERROR_RPATH = 20
StreamRadioLib.EDITOR_ERROR_RDATA = 21
StreamRadioLib.EDITOR_ERROR_RFORMAT = 22
StreamRadioLib.EDITOR_ERROR_READ = 23

StreamRadioLib.EDITOR_ERROR_COPY_DIR = 30
StreamRadioLib.EDITOR_ERROR_COPY_EXIST = 31
StreamRadioLib.EDITOR_ERROR_COPY_WRITE = 32
StreamRadioLib.EDITOR_ERROR_COPY_READ = 33

StreamRadioLib.EDITOR_ERROR_RENAME_DIR = 40
StreamRadioLib.EDITOR_ERROR_RENAME_EXIST = 41
StreamRadioLib.EDITOR_ERROR_RENAME_WRITE = 42
StreamRadioLib.EDITOR_ERROR_RENAME_READ = 43

StreamRadioLib.EDITOR_ERROR_COMMUNITY_PROTECTED = 50
StreamRadioLib.EDITOR_ERROR_VIRTUAL_PROTECTED = 51
StreamRadioLib.EDITOR_ERROR_NOADMIN = 252
StreamRadioLib.EDITOR_ERROR_RESET = 253
StreamRadioLib.EDITOR_ERROR_UNIMPLEMENTED = 254
StreamRadioLib.EDITOR_ERROR_UNKNOWN = 255

local EditorErrors = {
	-- Code										// Error
	[StreamRadioLib.EDITOR_ERROR_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_WRITE_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_READ_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_FILES_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_DIR_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_DEL_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_COPY_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_RENAME_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_WPATH] = "Invalid path!",
	[StreamRadioLib.EDITOR_ERROR_WDATA] = "Invalid data!",
	[StreamRadioLib.EDITOR_ERROR_WVIRTUAL] = "This virtual file is readonly!",
	[StreamRadioLib.EDITOR_ERROR_WFORMAT] = "Invalid file format!\nValid formats are: m3u, pls, json, vdf",
	[StreamRadioLib.EDITOR_ERROR_WRITE] = "Couldn't write the file!",
	[StreamRadioLib.EDITOR_ERROR_DIR_WRITE] = "Couldn't create the directory!",
	[StreamRadioLib.EDITOR_ERROR_DIR_EXIST] = "This directory already exists!",
	[StreamRadioLib.EDITOR_ERROR_FILE_EXIST] = "This file already exists!",
	[StreamRadioLib.EDITOR_ERROR_DEL_ACCES] = "Couldn't delete the file or the directory!",
	[StreamRadioLib.EDITOR_ERROR_RPATH] = "Invalid path!",
	[StreamRadioLib.EDITOR_ERROR_RDATA] = "Couldn't read the file!",
	[StreamRadioLib.EDITOR_ERROR_RFORMAT] = "Couldn't read the file format!",
	[StreamRadioLib.EDITOR_ERROR_READ] = "Couldn't read the file!",
	[StreamRadioLib.EDITOR_ERROR_COPY_DIR] = "You can't copy a directory",
	[StreamRadioLib.EDITOR_ERROR_COPY_EXIST] = "This file already exists!",
	[StreamRadioLib.EDITOR_ERROR_COPY_WRITE] = "Couldn't create the copy!",
	[StreamRadioLib.EDITOR_ERROR_COPY_READ] = "Couldn't read the source file!",
	[StreamRadioLib.EDITOR_ERROR_RENAME_DIR] = "You can't rename a directory",
	[StreamRadioLib.EDITOR_ERROR_RENAME_EXIST] = "This file already exists!",
	[StreamRadioLib.EDITOR_ERROR_RENAME_WRITE] = "Couldn't rename/move the file!",
	[StreamRadioLib.EDITOR_ERROR_RENAME_READ] = "Couldn't read the source file!",
	[StreamRadioLib.EDITOR_ERROR_COMMUNITY_PROTECTED] = "You can not edit files inside the community folder!",
	[StreamRadioLib.EDITOR_ERROR_VIRTUAL_PROTECTED] = "You can not add or remove files inside the virtual folders!",
	[StreamRadioLib.EDITOR_ERROR_NOADMIN] = "You need admin rights!",
	[StreamRadioLib.EDITOR_ERROR_UNIMPLEMENTED] = "This is not implemented!",
	[StreamRadioLib.EDITOR_ERROR_UNKNOWN] = "Unknown Error"
}

function StreamRadioLib.DecodeEditorErrorCode( err )
	return ( EditorErrors[tonumber( err ) or StreamRadioLib.EDITOR_ERROR_UNKNOWN] or EditorErrors[StreamRadioLib.EDITOR_ERROR_UNKNOWN] )
end

function StreamRadioLib.Msg(ply, msgstring)
	msgstring = tostring(msgstring or "")
	if msgstring == "" then return end

	if IsValid(ply) then
		ply:PrintMessage(HUD_PRINTTALK, msgstring)
	else
		MsgN(msgstring)
	end
end

local catchAndNohalt = function(err)
	local msgstring = err
	msgstring = string.Trim(StreamRadioLib.Addonname .. msgstring) .. "\n"

	ErrorNoHalt(msgstring)

	return err
end

function StreamRadioLib.CatchAndErrorNoHalt(func, ...)
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
	msgstring = string.Trim(StreamRadioLib.Addonname .. msgstring) .. "\n"

	if StreamRadioLib.VR.IsActive() then
		StreamRadioLib.VR.Debug(msgstring)
	else
		MsgN(msgstring)
	end
end

local hashcache = {}

local function CRCfloat32(str)
	str = tostring(str or "")

	local crc = util.CRC(str)
	crc = tonumber(crc or 0) or 0

	local a = #str + crc
	local right = (a % 2) ~= 0

	local bits = 24
	local shift = 32 - bits

	crc = bit.tobit(crc)

	if right then
		crc = bit.rshift(crc, shift)
	else
		crc = bit.lshift(crc, shift)
		crc = bit.rshift(crc, shift)
	end

	crc = bit.tobit(crc)
	crc = bit.band(crc, (2 ^ bits) - 1)
	return crc
end

function StreamRadioLib.Hash( str )
	str = tostring(str or "")

	if hashcache[str] then
		return hashcache[str]
	end

	local len = #str
	local salt = "[Hash171202]"
	salt = salt .. "[StreamRadioLib: '" .. str .. "']" .. salt .. "[len: '" .. len .. "']" .. salt
	local hash = {}

	local rstr = string.reverse(str)
	local rsalt = string.reverse(salt)

	// There is no other 'hash' than CRC in GMod,
	// so inflate it a bit to avoid collisions.

	hash[1] = CRCfloat32(salt)
	hash[2] = CRCfloat32("wdwer" .. rstr .. "jakwd")
	hash[3] = CRCfloat32("sjreb" .. str .. "gkdzh")
	hash[4] = CRCfloat32(rsalt)
	hash[5] = CRCfloat32("heasw" .. len .. "xrjhw")

	hash[6] = CRCfloat32(table.concat({
		"awkjd", salt, hash[2], "ksdew",
		"cajwe", rstr, hash[3], "nawjd",
		"wakjd", str, hash[1], "vekhw",
		"dklrg", rsalt, hash[4], "lecds",
	}))

	local output = {}
	output.raw = hash
	output.hex, output.crc = StreamRadioLib.HashToHex(hash)

	hashcache[str] = output
	return output
end

function StreamRadioLib.HashToHex( h )
	h = h or {}
	local hash = h.raw or h

	local hex = ""
	local add = 0

	for i = 1, 6 do
		local v = tonumber(hash[i] or 0) or 0
		hex = hex .. string.format("%06x", v)
		add = add + v
	end

	local crc = "yhefs" .. hex .. "laxkr" .. add .. "eawts"

	crc = #crc .. crc
	crc = crc .. #crc

	crc = "awedw" .. crc .. "pwfjh"

	return hex, CRCfloat32(crc)
end

function StreamRadioLib.HasWiremod()
	local wmod = WireAddon or WIRE_CLIENT_INSTALLED
	if not wmod then return false end
	if not WireLib then return false end

	return true
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

	if not IsValid(ply) then return nil end

	local camera = ply:GetViewEntity()
	if not IsValid(camera) then return ply end

	return camera
end

function StreamRadioLib.GetCameraPos(ply)
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if StreamRadioLib.VR.IsActive(ply) then
		local pos = StreamRadioLib.VR.GetCameraPos(ply)
		return pos
	end

	local camera = StreamRadioLib.GetCameraEnt(ply)
	if not IsValid(camera) then return nil end

	if camera:IsPlayer() then
		pos = camera:EyePos()
	else
		pos = camera:GetPos()
	end

	return pos
end

function StreamRadioLib.GetControlPosDir(ply)
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	if StreamRadioLib.VR.IsActive(ply) then
		local pos, dir = StreamRadioLib.VR.GetControlPosDir(ply)
		return pos, dir
	end

	local camera = StreamRadioLib.GetCameraEnt(ply)

	if not IsValid(ply) then return nil end
	if not IsValid(camera) then return nil end

	if camera:IsPlayer() then
		pos = camera:EyePos()
		dir = camera:GetAimVector()
	else
		pos = camera:GetPos()
		dir = ply:GetAimVector()
	end

	return pos, dir
end


local trace = {}
function StreamRadioLib.Trace(ply)
	if not IsValid(ply) and CLIENT then
		ply = LocalPlayer()
	end

	local pos, dir = StreamRadioLib.GetControlPosDir(ply)

	if not pos then
		return nil
	end

	if not dir then
		return nil
	end

	local camera = StreamRadioLib.GetCameraEnt(ply)
	if not IsValid(ply) then return nil end
	if not IsValid(camera) then return nil end

	local start_pos = pos
	local end_pos = pos + dir * 5000

	trace.start = start_pos
	trace.endpos = end_pos

	trace.filter = function(ent)
		if not IsValid(ent) then return false end
		if not IsValid(ply) then return false end
		if not IsValid(camera) then return false end

		if ent == ply then return false end
		if ent == camera then return false end

		if ply.GetVehicle and ent == ply:GetVehicle() then return false end
		if camera.GetVehicle and ent == camera:GetVehicle() then return false end

		return true
	end

	return util.TraceLine(trace)
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

		traces[#traces + 1] = trace
	end

	return traces
end

local g_mat_cache = {}

function StreamRadioLib.GetPNG(name)
	if SERVER then return nil end
	if not name then return nil end

	local path = "3dstreamradio/" .. name .. ".png"
	local mat = g_mat_cache[path]

	if mat then
		return mat
	end

	mat = Material( path, "nocull" )
	return mat
end

function StreamRadioLib.GetPNGIcon(name, custom)
	if SERVER then return nil end
	if not name then return nil end

	local prepath = "icon16/" .. name

	if custom then
		return StreamRadioLib.GetPNG(prepath)
	end

	local path = prepath .. ".png"
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

local g_pressed = false
local g_lastradio = nil
local g_addonnamespace = "_3dstreamradio"

local function getplayervar(ply, name)
	local arr = ply[g_addonnamespace]
	if not arr then return nil end
	return arr[name]
end

local function setplayervar(ply, name, var)
	ply[g_addonnamespace] = ply[g_addonnamespace] or {}
	ply[g_addonnamespace][name] = var
end

local function ReleaseLastRadioControl(ply)
	local LastRadio = getplayervar(ply, "lastusedradio")
	setplayervar(ply, "lastusedradio", nil)

	if not IsValid( LastRadio ) then return end
	if not LastRadio.__IsRadio then return end
	if not LastRadio.Control then return end

	LastRadio:Control( ply, tr, false )
end

local function CanUseRadio(ply, Radio)
	if not IsValid( Radio ) then return false end
	if not Radio.__IsRadio then return false end
	if not Radio.Control then return false end

	-- Support for prop protections
	if Radio.CPPICanUse then
		local use = Radio:CPPICanUse( ply ) or false
		if not use then return false end
	end

	if SERVER then
		local use = hook.Run( "PlayerUse", ply, Radio )
		if not use then return false end
	end

	return true
end

function StreamRadioLib.Control( ply, tr, keydown )
	if not IsValid( ply ) then return end

	tr = tr or StreamRadioLib.Trace( ply )
	if not tr then
		ReleaseLastRadioControl( ply )
		return
	end

	if not keydown then
		ReleaseLastRadioControl( ply )
		return
	end

	local Radio = tr.Entity
	local LastRadio = getplayervar(ply, "lastusedradio")

	if Radio ~= LastRadio then
		ReleaseLastRadioControl( ply )
	end

	if not CanUseRadio( ply, Radio ) then
		ReleaseLastRadioControl( ply )
		return
	end

	local rv = Radio:Control( ply, tr, true )
	setplayervar(ply, "lastusedradio", Radio)

	return rv
end

local Errors = {
	-- Code		// Error
	[-1] = "Unknown Error",
	[0] = "OK",
	[1] = "Memory Error",
	[2] = "Can't open the file",
	[3] = "Can't find a free/valid driver",
	[4] = "The sample buffer was lost",
	[5] = "Invalid handle",
	[6] = "Unsupported sample format",
	[7] = "Invalid position",
	[8] = "BASS_Init has not been successfully called",
	[9] = "BASS_Start has not been successfully called",
	[14] = "Already initialized/paused/whatever",
	[18] = "Can't get a free channel",
	[19] = "An illegal type was specified",
	[20] = "An illegal parameter was specified",
	[21] = "No 3D support",
	[22] = "No EAX support",
	[23] = "Illegal device number",
	[24] = "Not playing",
	[25] = "Illegal sample rate",
	[27] = "The stream is not a file stream",
	[29] = "No hardware voices available",
	[31] = "The MOD music has no sequence data",
	[32] = "No internet connection could be opened",
	[33] = "Couldn't create the file",
	[34] = "Effects are not available",
	[37] = "Requested data is not available",
	[38] = "The channel is a 'decoding channel'",
	[39] = "A sufficient DirectX version is not installed",
	[40] = "Connection timedout",
	[41] = "Unsupported file format",
	[42] = "Unavailable speaker",
	[43] = "Invalid BASS version (used by add-ons)",
	[44] = "Codec is not available/supported",
	[45] = "The channel/file has ended",

	[1000] = "Custom URLs are blocked on this server",
}

function StreamRadioLib.DecodeErrorCode(errorcode)
	errorcode = tonumber(errorcode or -1) or -1

	if BASS3 and BASS3.DecodeErrorCode and errorcode < 200 and errorcode >= -1 then
		return BASS3.DecodeErrorCode(errorcode)
	end

	if Errors[errorcode] then
		return Errors[errorcode]
	end

	local errordata = StreamRadioLib.Interface.GetErrorData(errorcode) or {}
	local errordesc = string.Trim(errordata.desc or "")

	if errordesc == "" then
		errordesc = Errors[-1]
	end

	if not errordata.interface then
		return errordesc
	end

	local iname = errordata.interface.name

	if errordata.subinterface then
		iname = iname .. "/" .. errordata.subinterface.name
	end

	errordesc = "[" .. iname .. "] " .. errordesc
	return errordesc
end

local function ShowErrorInfo( ply, cmd, args )
	if ( not args[1] or ( args[1] == "" ) ) then
		MsgN( "You need to enter a valid error code." )

		return
	end

	local err = tonumber( args[1] ) or -1
	local errstr = StreamRadioLib.DecodeErrorCode( err )
	local msgstring = StreamRadioLib.Addonname .. "Error code " .. err .. " = " .. errstr
	StreamRadioLib.Msg( ply, msgstring )
end

concommand.Add( "info_streamradio_errorcode", ShowErrorInfo )

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

	if(#path > 260) then
		return string.sub(path, 0, 260)
	end

	return path
end

function StreamRadioLib.URIAddParameter(url, parameter)
	if not istable(parameter) then
		parameter = {parameter}
	end

	url = tostring(url or "")

	local start = "?"

	if string.find(url, "?", 1, true) then
		start = "&"
	end

	local uri = {}
	uri[#uri + 1] = url
	uri[#uri + 1] = start

	local first = true

	for k, v in pairs(parameter) do
		if not first then
			uri[#uri + 1] = "&"
		end

		first = false

		uri[#uri + 1] = URLEncode(k)
		uri[#uri + 1] = "="
		uri[#uri + 1] = URLEncode(v)
	end

	uri = table.concat(uri)
	return uri
end

function StreamRadioLib.IsBlockedURLCode( url )
	if ( not StreamRadioLib.BlockedURLCode ) then return false end
	if ( StreamRadioLib.BlockedURLCode == "" ) then return false end

	url = string.Trim( url or "" )
	local blocked = string.Trim( StreamRadioLib.BlockedURLCode )

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

	local IsConverted = false
	local URLType = StreamRadioLib.STREAM_URLTYPE_ONLINE

	local Cachefile = StreamRadioLib.Cache.GetFile( url )
	if ( Cachefile ) then
		url = "data/" .. Cachefile
		url = NormalizeOfflineFilename(url)
		URLType = StreamRadioLib.STREAM_URLTYPE_CACHE
	end

	return url, URLType
end

function StreamRadioLib.CreateStream()
	return StreamRadioLib.CreateOBJ("stream", false)
end

StreamRadioLib.SpawnedRadios = {}
local LastThink = RealTime()

hook.Add("Think", "Streamradio_Think", function()
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end

	local now = RealTime()
	if (now - LastThink) < 0.01 then return end
	LastThink = now

	StreamRadioLib.SpawnedRadios = StreamRadioLib.SpawnedRadios or {}

	for ent, _ in pairs(StreamRadioLib.SpawnedRadios) do
		if not IsValid(ent) then continue end
		if not ent.__IsRadio then continue end

		if ent.FastThink then
			ent:FastThink()
		end

		if ent:IsDormant() then continue end
		if not ent.DormantThink then continue end

		ent:DormantThink()
	end
end)
