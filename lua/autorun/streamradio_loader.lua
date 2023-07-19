-- Loader of the 3D Stream Radio. Made By Grocel.
AddCSLuaFile()

local function getVersion()
	local versiondata = file.Read("materials/3dstreamradio/_data/version.vmt", "GAME") or ""
	versiondata = string.Explode("[\r\n|\r|\n]", versiondata, true) or {}

	local Version = string.Trim(tostring(versiondata[1] or ""))
	local VersionTime = tonumber(string.Trim(versiondata[2] or "")) or -1

	if Version == "" then
		Version = "UNKNOWN"
	end

	return Version, VersionTime
end

local g_version, g_versionTime = getVersion()

local AddonTitle = ( "3D Stream Radio (ver. " .. g_version .. ")" )
local AddonPrefix = ( AddonTitle .. ":\n" )

StreamRadioLib = StreamRadioLib or {}
table.Empty(StreamRadioLib)

StreamRadioLib.AddonTitle = AddonTitle
StreamRadioLib.AddonPrefix = AddonPrefix
StreamRadioLib.Loaded = nil
StreamRadioLib.ErrorString = nil

function StreamRadioLib.GetVersion()
	return g_version
end

function StreamRadioLib.GetVersionTime()
	return g_versionTime
end

local g_loader_ok = true

local g_loaded_cs = {}
local g_loaded_lua = {}

local function appendError(err)
	local lib = StreamRadioLib or {}

	err = tostring(err or "")
	if err == "" then
		return
	end

	lib.ErrorString = lib.ErrorString or ""
	lib.ErrorString = string.Trim(lib.ErrorString .. "\n\n" .. err)
end

local function throwError(err)
	local lib = StreamRadioLib or {}

	err = tostring(err or "")

	if err == "" then
		err = "Unknown error"
	end

	appendError(err)

	g_loader_ok = false
	lib.Loaded = nil

	ErrorNoHaltWithStack((lib.AddonPrefix or "") .. err .. "\n")
	return false, err
end

local function saveCSLuaFile(lua, force)
	lua = tostring(lua or "")
	lua = string.lower(lua or "")

	if lua == "" then
		return false
	end

	if force then
		g_loaded_cs[lua] = nil
	end

	if g_loaded_cs[lua] ~= nil then
		return g_loaded_cs[lua] or false
	end

	g_loaded_cs[lua] = false

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
		throwError(err)
		return false
	end

	g_loaded_cs[lua] = true
	return true
end

local function saveInclude(lua, force)
	lua = tostring(lua or "")
	lua = string.lower(lua or "")

	if lua == "" then
		return nil
	end

	if force then
		g_loaded_lua[lua] = nil
	end

	if g_loaded_lua[lua] then
		-- Prevent loading twice
		return true, g_loaded_lua[lua]
	end

	local status, errOrResult = pcall(function()
		if not file.Exists(lua, "LUA") then
			error("Couldn't include file '" .. lua .. "' (File not found)", 0)
		end

		return include(lua)
	end)

	if not status then
		throwError(errOrResult)

		g_loaded_lua[lua] = nil

		return nil
	end

	g_loaded_lua[lua] = errOrResult
	return status, errOrResult
end

function StreamRadioLib.SaveCSLuaFile(lua, force)
	return saveCSLuaFile(lua, force)
end

function StreamRadioLib.LoadSH(lua, force)
	if not saveCSLuaFile(lua) then return end
	return saveInclude(lua, force)
end

function StreamRadioLib.LoadCL(lua, force)
	if SERVER then
		return saveCSLuaFile(lua)
	end

	return saveInclude(lua, force)
end

function StreamRadioLib.LoadSV(lua, force)
	if CLIENT then return true end
	return saveInclude(lua, force)
end

do
	local printLoaded = StreamRadioLib.LoadSH("streamradio_core/print.lua")

	if not printLoaded or not StreamRadioLib.Print then
		throwError(AddonTitle .. "Fatal error: Print and reporting system not loaded!")
		return
	end
end

local outdated = false

if CLIENT then
	if VERSION < 230714 and VERSION > 5 then
		throwError("Your GMod-Client (Version: " .. VERSION .. ") is too old!\nPlease update the GMod-Client!")
		outdated = true
	end
else
	if VERSION < 230714 and VERSION > 5 then
		throwError("The GMod-Server (Version: " .. VERSION .. ") is too old!\nPlease update the GMod-Server. Tell an Admin!")
		outdated = true
	end
end

if not outdated then
	local status, loaded = StreamRadioLib.LoadSH("streamradio_core/load.lua")
	StreamRadioLib.Loaded = status and loaded and g_loader_ok
end

local realmname = "clientside"
if SERVER then
	realmname = "serverside"
end

if not StreamRadioLib.Loaded then
	local err = StreamRadioLib.ErrorString or ""
	if err == "" then
		StreamRadioLib.ErrorString = "Unknown error"
	end

	local errcol = "[color:255,128,128]"
	local err = errcol .. StreamRadioLib.Print.IndentText(StreamRadioLib.ErrorString)
	err = string.Replace(err, "\n", "\n" .. errcol)

	StreamRadioLib.Print.Wrapped(AddonTitle .. "[color:255,128,128] could not be loaded " .. realmname .. ".", "Error:\n" .. err)
else
	StreamRadioLib.Print.Wrapped(AddonTitle .. "[color:100,200,100] is loaded " .. realmname .. ".")
end

if SERVER then
	util.AddNetworkString("3DStreamRadio/LoadError")

	hook.Add("PlayerInitialSpawn", "3DStreamRadio/LoadError", function(ply)
		if not IsValid(ply) then
			return
		end

		if not StreamRadioLib then
			return
		end

		if StreamRadioLib.Loaded then
			return
		end

		net.Start("3DStreamRadio/LoadError")
			net.WriteString(StreamRadioLib.ErrorString or "")
		net.Send(ply)
	end)
else
	net.Receive("3DStreamRadio/LoadError", function()
		local err = net.ReadString()
		if err == "" then return end

		throwError(err)
	end)
end

collectgarbage( "collect" )
