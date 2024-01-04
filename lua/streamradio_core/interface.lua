local StreamRadioLib = StreamRadioLib

StreamRadioLib.Interface = StreamRadioLib.Interface or {}

local LIB = StreamRadioLib.Interface
table.Empty(LIB)

local LIBUtil = StreamRadioLib.Util
local LIBUrl = StreamRadioLib.Url

local LuaInterfaceDirectory = "streamradio_core/interfaces"

local g_intefaces = {}
local g_intefacesByName = {}

local g_emptyFunction = function() end

local function AddInterface(script)
	script = script or ""
	if script == "" then return false end

	local scriptpath = LuaInterfaceDirectory .. "/"
	local scriptfile = scriptpath .. script

	RADIOIFACE = nil
	RADIOIFACE = {}

	RADIOIFACE.scriptpath = scriptpath
	RADIOIFACE.scriptfile = scriptfile

	RADIOIFACE.subinterfaces = {}

	local loaded = StreamRadioLib.LoadSH(scriptfile, true)

	if not loaded then
		RADIOIFACE = nil
		return false
	end

	local name = string.Trim(RADIOIFACE.name or "")
	RADIOIFACE.priority = tonumber(RADIOIFACE.priority or 0) or 0

	if name == "" then
		RADIOIFACE = nil
		return false
	end

	if RADIOIFACE.disabled then
		RADIOIFACE = nil
		return false
	end

	local iface = RADIOIFACE
	RADIOIFACE = nil

	table.insert(g_intefaces, iface)
	g_intefacesByName[name] = iface

	return true
end

local function GetInterfaceFromURL(url)
	for i, v in ipairs(g_intefaces) do
		if not v then continue end

		if not v.CheckURL then continue end
		if not v:CheckURL(url) then continue end

		return v
	end

	return nil
end

function LIB.Load()
	local files = file.Find(LuaInterfaceDirectory .. "/*", "LUA")
	g_intefaces = {}
	g_intefacesByName = {}

	for _, f in ipairs(files or {}) do
		AddInterface(f)
	end

	table.SortByMember(g_intefaces, "priority", false)
end

function LIB.GetInterface(name)
	return g_intefacesByName[name]
end

function LIB.Convert(url, callback)
	url = LIBUrl.SanitizeUrl(url)

	callback = callback or g_emptyFunction

	if url == "" then
		callback(nil, false, "", -1)
		return
	end

	local I = GetInterfaceFromURL(url)
	if not I then
		LIBUtil.ErrorNoHaltWithStack(string.format("Could not convert url '%s', interface was not found.", url))
		callback(nil, false, "", -1)
		return
	end

	if not I.Convert then
		callback(I, true, url)
		return
	end

	I:Convert(url, function(this, success, convertedUrl, errorcode)
		if success then
			errorcode = nil
			convertedUrl = tostring(convertedUrl or "")
		else
			errorcode = tonumber(errorcode or -1) or -1
			convertedUrl = ""
		end

		callback(this, success, convertedUrl, errorcode)
	end)
end

return true

