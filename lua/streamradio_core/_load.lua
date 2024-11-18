-- 3D Stream Radio. Made By Grocel.

local LIB = StreamRadioLib
if not LIB then
	return
end

LIB.Loaded = nil
LIB.Errors = {}

local function getVersion()
	local versiondata = file.Read("data_static/streamradio/version.txt", "GAME") or ""
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

LIB.AddonTitle = AddonTitle
LIB.AddonPrefix = AddonPrefix

function LIB.GetVersion()
	return g_version
end

function LIB.GetVersionTime()
	return g_versionTime
end

local g_loader_ok = true

local g_loaded_cs = {}
local g_loaded_lua = {}
local g_exists_lua = {}
local g_errors = {}
local g_maxErrors = 32

local function appendError(err)
	local liberrors = LIB.Errors
	if not liberrors then
		return
	end

	err = tostring(err or "")
	err = string.Trim(err or "")
	if err == "" then
		return
	end

	if g_errors[err] then
		return
	end

	local count = #liberrors

	if count >= g_maxErrors then
		return
	end

	table.insert(liberrors, err)
	g_errors[err] = true
end

local function throwError(err)
	err = tostring(err or "")
	err = string.Trim(err or "")
	if err == "" then
		return
	end

	local addonPrefix = LIB.AddonPrefix or ""

	appendError(err)

	g_loader_ok = false
	LIB.Loaded = nil

	ErrorNoHaltWithStack(addonPrefix .. err .. "\n")
end

local function registerErrorFeedbackHook()
	if SERVER then
		util.AddNetworkString("3DStreamRadio_LoadError")

		hook.Add("PlayerInitialSpawn", "3DStreamRadio_LoadError", function(ply)
			if not IsValid(ply) then
				return
			end

			if LIB.Loaded then
				return
			end

			local errors = LIB.Errors or {}
			if table.IsEmpty(errors) then
				return
			end

			local count = #errors

			net.Start("3DStreamRadio_LoadError")
				net.WriteUInt(count, 8)

				for i, err in ipairs(errors) do
					net.WriteString(err)
				end
			net.Send(ply)
		end)
	else
		net.Receive("3DStreamRadio_LoadError", function()
			local count = net.ReadUInt(8)

			for i = 1, count do
				local err = net.ReadString()
				appendError(err)
			end
		end)
	end
end

local function luaExists(lua)
	lua = tostring(lua or "")
	lua = string.lower(lua or "")

	if lua == "" then
		return false
	end

	if g_exists_lua[lua] ~= nil then
		return g_exists_lua[lua] or false
	end

	local exists = file.Exists(lua, "LUA")

	if not exists then
		g_exists_lua[lua] = false
		return false
	end

	g_exists_lua[lua] = true
	return true
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

	local status = xpcall(function()
		if CLIENT then
			return
		end

		if not luaExists(lua) then
			error("Couldn't AddCSLuaFile file '" .. lua .. "' (File not found)")
		end

		AddCSLuaFile(lua)
	end, throwError)

	if not status then
		g_loaded_cs[lua] = false
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

	local status, result = xpcall(function()
		if SERVER then
			-- Too slow on clientside on some servers
			-- See: https://github.com/Facepunch/garrysmod-issues/issues/5674

			if not luaExists(lua) then
				error("Couldn't include file '" .. lua .. "' (File not found)")
				return nil
			end
		end

		local r = include(lua)

		if not r then
			error("Couldn't include file '" .. lua .. "' (Error during execution or file not found)")
			return nil
		end

		return r
	end, throwError)

	if not status then
		g_loaded_lua[lua] = nil
		return nil
	end

	g_loaded_lua[lua] = result
	return status, result
end

function LIB.SaveCSLuaFile(lua, force)
	return saveCSLuaFile(lua, force)
end

function LIB.LoadSH(lua, force)
	if not saveCSLuaFile(lua) then return end
	return saveInclude(lua, force)
end

function LIB.LoadCL(lua, force)
	if SERVER then
		return saveCSLuaFile(lua)
	end

	return saveInclude(lua, force)
end

function LIB.LoadSV(lua, force)
	if CLIENT then return true end
	return saveInclude(lua, force)
end

local g_loadTime = 0

local function loadAddon()
	local loadStartTime = SysTime()

	local VERSION = VERSION or 0
	local versionError = nil

	if VERSION > 5 then
		-- Sometimes the version is not known, yet.

		if CLIENT then
			local NEED_VERSION = 241029

			if VERSION < NEED_VERSION then
				versionError = string.format("Your GMod-Client (version: %s) is too old!\nPlease update the GMod-Client to version %s or newer!", VERSION, NEED_VERSION)
			end
		else
			local NEED_VERSION = 241029

			if VERSION < NEED_VERSION then
				versionError = string.format("The GMod-Server (version: %s) is too old!\nPlease update the GMod-Server to version %s or newer!\nTell an Admin!", VERSION, NEED_VERSION)
			end
		end
	end

	if versionError then
		throwError(versionError)
	else
		LIB.Loaded = true
		LIB.Loading = true

		local status, loaded = LIB.LoadSH("streamradio_core/_include.lua")

		if not status then
			g_loader_ok = false
		end

		if not loaded then
			g_loader_ok = false
		end
	end

	if not g_loader_ok then
		LIB.Loaded = nil
	end

	LIB.Loading = nil

	g_loadTime = SysTime() - loadStartTime
end

local g_colDefault = Color(255, 255, 255)
local g_colError = Color(255, 128, 128)
local g_colOk = Color(100, 200, 100)
local g_colCL = Color(255, 222, 137)
local g_colSV = Color(137, 222, 255)

local function printAddon()
	local errors = LIB.Errors
	if not errors then
		return
	end

	local realmname = "CLIENT"
	local realmcol = g_colCL
	if SERVER then
		realmname = "SERVER"
		realmcol = g_colSV
	end

	local loadTimeString = string.format("Took %0.3f sec.", g_loadTime)
	local border = "##########################################################################################"

	MsgN()
	MsgN()
	MsgC(realmcol, border)
	MsgN()
	MsgN()

	MsgC(g_colDefault, "    ", LIB.AddonTitle, " ")

	if not LIB.Loaded then
		if table.IsEmpty(errors) then
			appendError(string.format("Error loading addon on the %s!", realmname))
		end

		MsgC(g_colError, "could not be loaded on the " .. realmname .. ". " .. loadTimeString)
		MsgN()
		MsgN()

		MsgC(realmcol, border)
		MsgN()
		MsgN()

		MsgC(g_colError, "Errors:")
		MsgN()

		for i, thiserr in ipairs(errors) do
			thiserr = tostring(thiserr or "")
			thiserr = string.Trim(thiserr)

			if thiserr == "" then
				continue
			end

			MsgC(g_colDefault, i .. ": ", g_colError, thiserr)
			MsgN()
		end
	else
		MsgC(g_colOk, "is loaded on the " .. realmname .. ". " .. loadTimeString)
		MsgN()
	end

	MsgN()
	MsgC(realmcol, border)
	MsgN()
	MsgN()
end

loadAddon()
printAddon()
registerErrorFeedbackHook()

return LIB.Loaded
