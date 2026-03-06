-- 3D Stream Radio. Made By Grocel.
AddCSLuaFile()

local g_addonBrokenError = nil
local g_reloadAddonTimerName = "3DStreamRadio_ReloadAddon"

if SERVER then
	g_addonBrokenError = "Addon loadup is broken on SERVER! To many addons?"
else
	g_addonBrokenError = "Addon loadup is broken on CLIENT! To many addons?"
end

local init = nil

local function unloadSublib(sublib)
	if not istable(sublib) then
		return
	end

	if not sublib.__isLib then
		return
	end

	local func = sublib.Unload
	if not isfunction(func) then
		return
	end

	func()

	sublib.Unload = nil
end

local function emptySublib(sublib)
	if not istable(sublib) then
		return
	end

	if not sublib.__isLib then
		return
	end

	unloadSublib(sublib)

	-- Sublib, e.g. StreamRadioLib.File
	for sublibKey, sublibValue in pairs(sublib) do
		-- Sublib values, e.g. StreamRadioLib.File.Write

		if istable(sublibValue) then
			-- keep tables in case we want to pass them on
			continue
		end

		if sublibKey == "__isLib" then
			continue
		end

		sublib[sublibKey] = nil
	end
end

local function emptyLib(lib)
	-- Mainlib, e.g. StreamRadioLib

	for key, sublib in pairs(lib) do
		unloadSublib(sublib)
	end

	for key, sublib in pairs(lib) do
		if istable(sublib) then
			emptySublib(sublib)
			continue
		end

		lib[key] = nil
	end
end

local function initStreamRadioLibGlobal()
	timer.Remove(g_reloadAddonTimerName)

	local lib = _G.StreamRadioLib or {}
	_G.StreamRadioLib = lib

	emptyLib(lib)

	lib.Loaded = nil
	lib.Errors = {g_addonBrokenError}

	lib.NewLib = function(thislib, name)
		name = tostring(name or "")

		local sublib = thislib[name] or {}
		thislib[name] = sublib

		sublib.__isLib = true

		emptySublib(sublib)

		lib.ReloadAddon()

		return sublib
	end

	lib.ReloadAddon = function(force)
		if lib.Loading and not force then
			-- already loading, this prevents recursive reloads
			return false
		end

		-- debounce rapid reload calls
		timer.Remove(g_reloadAddonTimerName)
		timer.Create(g_reloadAddonTimerName, 0.25, 1, function()
			timer.Remove(g_reloadAddonTimerName)

			if lib.Loading and not force then
				return
			end

			if not init then
				return
			end

			init()
		end)

		-- we are reloading, if we return true here, the caller should return immediately
		return true
	end

	-- this is the failback content for tools and menus
	lib.Loader_CreateErrorPanel = function(CPanel, message)
		if not IsValid(CPanel) then
			return
		end

		local lib = _G.StreamRadioLib or {}
		if lib.Loaded then
			return
		end

		local addonPrefix = tostring(lib.AddonPrefix or "")

		if addonPrefix ~= "" then
			local prefixlabel = vgui.Create("DLabel")

			prefixlabel:SetDark(true)
			prefixlabel:SetHighlight(false)
			prefixlabel:SetWrap(true)
			prefixlabel:SetText(addonPrefix)

			prefixlabel:SetAutoStretchVertical(true)
			prefixlabel:SizeToContents()

			CPanel:AddPanel(prefixlabel)
		end

		local errors = lib.Errors or {}

		for i, thiserr in ipairs(errors) do
			thiserr = tostring(thiserr or "")
			thiserr = string.Trim(thiserr)

			if thiserr == "" then
				continue
			end

			local errorlabel = vgui.Create("DLabel")

			errorlabel:SetDark(false)
			errorlabel:SetHighlight(true)
			errorlabel:SetWrap(true)
			errorlabel:SetText(i .. ". " .. thiserr)
			errorlabel:SetTooltip(thiserr)

			errorlabel:SetAutoStretchVertical(true)
			errorlabel:SizeToContents()

			CPanel:AddPanel(errorlabel)
		end

		message = tostring(message or "")
		message = string.Trim(message)

		if message ~= "" then
			local messagelabel = vgui.Create("DLabel")

			messagelabel:SetDark(false)
			messagelabel:SetHighlight(true)
			messagelabel:SetWrap(true)
			messagelabel:SetText(message)
			messagelabel:SetTooltip(message)

			messagelabel:SetAutoStretchVertical(true)
			messagelabel:SizeToContents()

			CPanel:AddPanel(messagelabel)
		end
	end

	-- this is the failback error message for radio entity spawn
	lib.Loader_ShowSpawnError = function(message)
		local lib = _G.StreamRadioLib or {}
		if lib.Loaded then
			return
		end

		local addonPrefix = tostring(lib.AddonPrefix or "")

		local errors = lib.Errors or {}

		local errorString = table.concat(errors, "\n\n")
		errorString = string.Trim(errorString)

		message = tostring(message or "")
		message = string.Trim(message)

		local err = string.format("%s\n\n%s\n\n%s", addonPrefix, errorString, message)

		ErrorNoHaltWithStack(err)
	end
end

init = function()
	initStreamRadioLibGlobal()

	local status, loaded = xpcall(function()
		AddCSLuaFile("streamradio_core/_load.lua")
		return include("streamradio_core/_load.lua")
	end, ErrorNoHaltWithStack)

	if not _G.StreamRadioLib then
		initStreamRadioLibGlobal()
	end

	if not status then
		_G.StreamRadioLib.Loaded = nil
	end

	if not loaded then
		_G.StreamRadioLib.Loaded = nil
	end

	local errors = _G.StreamRadioLib.Errors or {}

	local errorString = tostring(errors[1] or "")
	errorString = string.Trim(errorString)

	if errorString ~= "" then
		_G.StreamRadioLib.Loaded = nil
	end

	if errorString == g_addonBrokenError then
		-- something went horribly wrong, so tell the user about it.

		error(g_addonBrokenError)
		return
	end
end

init()
