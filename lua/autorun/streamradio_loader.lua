-- 3D Stream Radio. Made By Grocel.
AddCSLuaFile()

local g_addonBrokenError = nil

if SERVER then
	g_addonBrokenError = "Addon loadup is broken on SERVER! To many addons?"
else
	g_addonBrokenError = "Addon loadup is broken on CLIENT! To many addons?"
end

local function initStreamRadioLibGlobal()
	_G.StreamRadioLib = _G.StreamRadioLib or {}
	local lib = _G.StreamRadioLib

	table.Empty(lib)

	lib.Loaded = nil
	lib.Errors = {g_addonBrokenError}

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
		addonPrefix = string.Trim(addonPrefix)

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
		addonPrefix = string.Trim(addonPrefix)

		local errors = lib.Errors or {}

		local errorString = table.concat(errors, "\n\n")
		errorString = string.Trim(errorString)

		message = tostring(message or "")
		message = string.Trim(message)

		local err = string.format("%s\n\n%s\n\n%s", addonPrefix, errorString, message)

		ErrorNoHaltWithStack(err)
	end
end

do
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
