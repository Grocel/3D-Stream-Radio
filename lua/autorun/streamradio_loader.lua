-- Loader of the 3D Stream Radio. Made By Grocel.
local IsValid = IsValid
local error = error
local ErrorNoHalt = ErrorNoHalt
local pcall = pcall
local require = require
local tonumber = tonumber
local tostring = tostring
local collectgarbage = collectgarbage

local CL = CLIENT
local SV = SERVER
local string = string
local concommand = concommand
local system = system
local file = file
local net = net
local hook = hook

local Gmodversion = VERSION

local versiondata = file.Read("materials/3dstreamradio/_data/version.vmt", "GAME") or ""
versiondata = string.Explode("[\r\n|\r|\n]", versiondata, true) or {}

local Version = string.Trim(tostring(versiondata[1] or ""))
local VersionTime = tonumber(string.Trim(versiondata[2] or "")) or -1

if Version == "" then
	Version = "UNKNOWN"
end

local AddonTitle = ( "3D Stream Radio (ver. " .. Version .. ")" )
local AddonPrefix = ( AddonTitle .. ":\n" )

local thisfile = "autorun/streamradio_loader.lua"

StreamRadioLib = StreamRadioLib or {}
StreamRadioLib.AddonTitle = AddonTitle
StreamRadioLib.AddonPrefix = AddonPrefix
StreamRadioLib.Loaded = nil
StreamRadioLib.HasBass = false
StreamRadioLib.ErrorString = nil

function StreamRadioLib.GetVersion()
	return Version
end

function StreamRadioLib.GetVersionTime()
	return VersionTime
end

function StreamRadioLib.IsDebug()
	local devconvar = GetConVar("developer")
	if not devconvar then return end

	return devconvar:GetInt() > 0
end

local loader_ok = true

local g_loaded_dll = {}
local g_dllSupportedBranches = {
	["dev"] = true,
	["prerelease"] = true,
	["unknown"] = true,
	["none"] = true,
	["live"] = true,
	["main"] = true,
	[""] = true,
}

local function saveRequireDLL(dll, optional)
	if not StreamRadioLib then
		return false, nil
	end

	if not StreamRadioLib.IsDebug then
		return false, nil
	end

	dll = tostring(dll or "")
	dll = string.lower(dll)

	if dll == "" then
		return false, nil
	end

	if g_loaded_dll[dll] then
		return g_loaded_dll[dll] or false, nil
	end

	local realm = SERVER and "sv" or "cl"
	local osname = system.IsWindows() and "win32" or "linux"
	local dllfile = "lua/bin/gm" .. realm .. "_" .. dll .. "_" .. osname .. ".dll"
	local branch = BRANCH or ""

	local status, err = pcall(function()
		if not file.Exists(dllfile, "GAME") then
			if optional then
				return
			end

			error("Couldn't require file '" .. dllfile .. "' (File not found)", 0)
		end

		if g_dllSupportedBranches[branch] then
			if optional then
				return
			end

			error(dllfile .. " is not supported on branch '" .. branch .. "'!\n")
		end

		require(dll)
	end)

	if not status then
		err = tostring(err or "")

		if err == "" then
			err = "Unknown error"
		end

		if optional then
			if StreamRadioLib.IsDebug() then
				ErrorNoHalt((StreamRadioLib.AddonPrefix or "") .. err .. "\n")
			end

			return false, err
		end

		StreamRadioLib.ErrorString = StreamRadioLib.ErrorString or ""

		if StreamRadioLib.ErrorString == "" then
			StreamRadioLib.ErrorString = err
		else
			StreamRadioLib.ErrorString = StreamRadioLib.ErrorString .. "\n" .. err
		end

		StreamRadioLib.Loaded = nil
		g_loaded_dll[dll] = nil
		loader_ok = false

		ErrorNoHalt((StreamRadioLib.AddonPrefix or "") .. err .. "\n")
		return false, err
	end

	g_loaded_dll[dll] = true
	return true, nil
end

local g_loaded_cs = {}
local function saveCSLuaFile(lua, force)
	if not StreamRadioLib then
		return false
	end

	if not StreamRadioLib.IsDebug then
		return false
	end

	lua = tostring(lua or "")
	lua = string.lower(lua or "")

	if lua == "" then
		return false
	end

	if force then
		g_loaded_cs[lua] = nil
	end

	if g_loaded_cs[lua] then
		return g_loaded_cs[lua] or false
	end

	local status, err = pcall(function()
		if CLIENT then
			return
		end

		if not file.Exists(lua, "LUA") then
			error("Couldn't AddCSLuaFile file '" .. lua .. "' (File not found)", 0)
		end

		AddCSLuaFile(lua)
	end)

	if not status then
		err = tostring(err or "")

		if err == "" then
			err = "Unknown error"
		end

		StreamRadioLib.ErrorString = StreamRadioLib.ErrorString or ""

		if StreamRadioLib.ErrorString == "" then
			StreamRadioLib.ErrorString = err
		else
			StreamRadioLib.ErrorString = StreamRadioLib.ErrorString .. "\n" .. err
		end

		StreamRadioLib.Loaded = nil
		g_loaded_cs[lua] = nil
		loader_ok = false

		ErrorNoHalt((StreamRadioLib.AddonPrefix or "") .. err .. "\n")
		return false
	end

	g_loaded_cs[lua] = true
	return true
end

local g_loaded = {}

local function saveinclude(lua, force)
	if not StreamRadioLib then
		return nil
	end

	if not StreamRadioLib.IsDebug then
		return nil
	end

	lua = tostring(lua or "")
	lua = string.lower(lua or "")

	if lua == "" then
		return nil
	end

	if StreamRadioLib.IsDebug() then
		-- For easier reloading during development
		local result = include(lua)
		return true, result
	end

	-- Anything below is too ensure that the addon has loaded correctly without errors

	if force then
		g_loaded[lua] = nil
	end

	if g_loaded[lua] then
		return true, g_loaded[lua]
	end

	local status, err = pcall(function()
		if not file.Exists(lua, "LUA") then
			error("Couldn't include file '" .. lua .. "' (File not found)", 0)
		end

		local func = CompileFile(lua)
		if not func then
			error("Couldn't include file '" .. lua .. "' (Syntax error)", 0)
		end

		return func()
	end)

	if not status then
		err = tostring(err or "")

		if err == "" then
			err = "Unknown error"
		end

		StreamRadioLib.ErrorString = StreamRadioLib.ErrorString or ""

		if StreamRadioLib.ErrorString == "" then
			StreamRadioLib.ErrorString = err
		else
			StreamRadioLib.ErrorString = StreamRadioLib.ErrorString .. "\n" .. err
		end

		StreamRadioLib.Loaded = nil
		g_loaded[lua] = nil
		loader_ok = false

		ErrorNoHalt((StreamRadioLib.AddonPrefix or "") .. err .. "\n")
		return nil
	end

	g_loaded[lua] = err
	return status, err
end

local function loadBASS3()
	if BASS3 and BASS3.Version and BASS3.ModuleVersion then
		return true
	end

	local dll = "bass3"
	local dll_name = string.upper("gm_" .. dll)

	local status = saveRequireDLL(dll, true)

	if not status then
		return false
	end

	if not BASS3 then
		return false
	end

	if not BASS3.Version then
		return false
	end

	if not BASS3.ModuleVersion then
		return false
	end

	local BassModuleVersion = tonumber(BASS3.ModuleVersion) or 0

	if BassModuleVersion < 14 then
		local ErrorString = dll_name .. " is outdated!\n"
		ErrorNoHalt(AddonPrefix .. ErrorString .. "\n")

		return false
	end

	return true
end

function StreamRadioLib.SaveCSLuaFile(lua, force)
	return saveCSLuaFile(lua, force)
end

function StreamRadioLib.LoadSH(lua, force)
	if not saveCSLuaFile(lua) then return end
	return saveinclude(lua, force)
end

function StreamRadioLib.LoadCL(lua, force)
	if SV then
		return saveCSLuaFile(lua)
	end

	return saveinclude(lua, force)
end

function StreamRadioLib.LoadSV(lua, force)
	if CL then return true end
	return saveinclude(lua, force)
end

local function getTextWithoutColor(text)
	text = tostring(text or "")
	text = string.gsub(text, "%[color%:[ ]?%d+[ %,][ ]?%d+[ %,][ ]?%d+%]", "")

	return text
end

local function printColored(text)
	text = tostring(text or "")

	local default = "[color:255,255,255]"
	local lastcolor = default
	local curcolor = Color(255, 255, 255, 255)

	text = default .. text .. default

	for data, color in string.gmatch(text, "(.-)(%[color%:[ ]?%d+[ %,][ ]?%d+[ %,][ ]?%d+%])") do
		data = data or ""
		color = color or ""

		if color ~= "" then
			local r, g, b = string.match(lastcolor, "%[color%:[ ]?(%d+)[ %,][ ]?(%d+)[ %,][ ]?(%d+)%]")

			if r and g and b then
				r = math.Clamp(tonumber(r) or 0, 0, 255)
				g = math.Clamp(tonumber(g) or 0, 0, 255)
				b = math.Clamp(tonumber(b) or 0, 0, 255)

				curcolor.r = r
				curcolor.g = g
				curcolor.b = b
			end
		end

		if data ~= "" then
			MsgC(curcolor, data)
		end

		lastcolor = color
	end
end

local function indentText(text, spaces)
	text = tostring(text or "")
	spaces = tonumber(spaces or 2) or 2

	spaces = string.rep(" ", spaces)
	text = string.gsub(spaces .. text, "\n", "\n" .. spaces)

	return text
end

local function printWrapped(texts, ...)
	if not istable(texts) then
		texts = {texts}
	end

	texts = table.Add(texts, {...})

	local textlines = {}

	local longestline = 0

	for k, v in pairs(texts) do
		v = tostring(v or "")

		local lines = string.Explode("\n", v, false)
		textlines[#textlines + 1] = lines

		for i, u in ipairs(lines) do
			local collessu = getTextWithoutColor(u)
			local len = #collessu

			if len <= longestline then
				continue
			end

			longestline = len
		end
	end

	local border_color = SERVER and "[color:137,222,255]" or "[color:255,222,102]"
	local text_color = "[color:255,255,255]"

	local borderside_l = "=== "
	local borderside_r = " ==="

	local border = border_color .. string.rep("=", longestline + #borderside_l + #borderside_r)
	local border_inner = border_color .. string.rep("-", longestline)

	borderside_l = border_color .. "=== "
	borderside_r = border_color .. " ==="

	local function group(lines, addborder)
		if addborder then
			printColored(borderside_l .. border_inner .. borderside_r .. "\n")
		end

		for i, v in ipairs(lines) do
			local collessv = getTextWithoutColor(v)
			local len = #collessv
			local slen = math.Clamp(longestline - len, 0, longestline)
			local spaces = string.rep(" ", slen)

			local line = v .. spaces
			printColored(borderside_l .. text_color .. line .. borderside_r .. "\n")
		end
	end

	printColored(border .. "\n")

	for i, v in ipairs(textlines) do
		group(v, i > 1)
	end

	printColored(border .. "\n")
end

saveCSLuaFile(thisfile)
StreamRadioLib.HasBass = loadBASS3()

local bassload_msg

if SV then
	bassload_msg = "[color:255,150,50]Serverside streaming API for advanced wire outputs could not be loaded!"

	if StreamRadioLib.HasBass then
		bassload_msg = "[color:100,200,100]Serverside streaming API for advanced wire outputs loaded!"
		bassload_col = "[color:100,200,100]"
	end
else
	bassload_msg = "[color:255,150,50]No clientside streaming API using GMod's one!"

	if StreamRadioLib.HasBass then
		bassload_msg = "[color:100,200,100]Clientside streaming API loaded!"
		bassload_col = "[color:100,200,100]"
	end
end

local outdated = false

if CLIENT then
	if Gmodversion < 210402 and Gmodversion > 5 then
		StreamRadioLib.ErrorString = "Your GMod-Client (Version: " .. Gmodversion .. ") is too old!\nPlease update the GMod-Client!"
		outdated = true

		ErrorNoHalt(AddonPrefix .. StreamRadioLib.ErrorString .. "\n")
	end
else
	if Gmodversion < 210402 and Gmodversion > 5 then
		StreamRadioLib.ErrorString = "The GMod-Server (Version: " .. Gmodversion .. ") is too old!\nPlease update the GMod-Server!"
		outdated = true

		ErrorNoHalt(AddonPrefix .. StreamRadioLib.ErrorString .. "\n")
	end
end

if not outdated then
	local status, loaded = StreamRadioLib.LoadSH("streamradio_core/load.lua")
	StreamRadioLib.Loaded = status and loaded and loader_ok
end

local realmname = "clientside"
if SV then
	realmname = "serverside"
end

if not StreamRadioLib.Loaded then
	local err = StreamRadioLib.ErrorString or ""
	if err == "" then
		StreamRadioLib.ErrorString = "Unknown error"
	end

	local errcol = "[color:255,128,128]"
	local err = errcol .. indentText(StreamRadioLib.ErrorString)
	err = string.Replace(err, "\n", "\n" .. errcol)

	printWrapped(AddonTitle .. "[color:255,128,128] could not be loaded " .. realmname .. ".", "Error:\n" .. err)
else
	printWrapped(AddonTitle .. "[color:100,200,100] is loaded " .. realmname .. ".", "Optional GM_BASS3:\n" .. indentText(bassload_msg))
end

if SV then
	util.AddNetworkString("3D_StreamRadio_LoadError")

	hook.Add("PlayerInitialSpawn", "3D_StreamRadio_LoadError", function(ply)
		if not IsValid(ply) then
			return
		end

		if not StreamRadioLib then
			return
		end

		if StreamRadioLib.Loaded then
			return
		end

		net.Start("3D_StreamRadio_LoadError")
			net.WriteString(StreamRadioLib.ErrorString or "")
		net.Send(ply)
	end)
else
	net.Receive("3D_StreamRadio_LoadError", function()
		local err = net.ReadString()
		if err == "" then return end
		if not StreamRadioLib then return end

		StreamRadioLib.ErrorString = StreamRadioLib.ErrorString or ""
		StreamRadioLib.ErrorString = string.Trim(StreamRadioLib.ErrorString .. "\n\n" .. err)

		ErrorNoHalt((StreamRadioLib.AddonPrefix or "") .. StreamRadioLib.ErrorString .. "\n")
		StreamRadioLib.Loaded = nil
	end)
end

concommand.Add("debug_streamradio_reload", function()
	if not StreamRadioLib then return end
	StreamRadioLib.LoadSH(thisfile)
end)

collectgarbage( "collect" )
