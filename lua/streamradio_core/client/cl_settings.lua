local StreamRadioLib = StreamRadioLib
local LIB = StreamRadioLib:NewLib("Settings")

local LIBHook = nil
local LIBLocale = nil

local g_panels = LIB.g_panels or {}
LIB.g_panels = g_panels

local g_CV = LIB.g_CV or {}
LIB.g_CV = g_CV

local g_CV_CMD = LIB.g_CV_CMD or {}
LIB.g_CV_CMD = g_CV_CMD

local g_CV_List = LIB.g_CV_List or {}
LIB.g_CV_List = g_CV_List

function LIB.AddConVar(namespace, name, cmd, default, data)
	if not namespace then return nil end
	if not name then return nil end
	if not cmd then return nil end
	if not default then return nil end
	if not data then return nil end

	local CV = StreamRadioLib.CreateOBJ("clientconvar")
	CV:SetName(name)
	CV:SetCMD(cmd)

	CV:SetType(data.type)
	CV:SetMin(data.min)
	CV:SetMax(data.max)
	CV:SetOptions(data.options)

	CV:SetDefault(default)

	if data.save ~= nil then
		CV:SetSave(data.save)
	end

	if data.userdata ~= nil then
		CV:SetUserdata(data.userdata)
	end

	if data.help ~= nil then
		CV:SetHelptext(data.help)
	end

	if data.hidden ~= nil then
		CV:SetHidden(data.hidden)
	end

	if data.disabled ~= nil then
		CV:SetDisabled(data.disabled)
	end

	CV:SetPanellabel(data.label)
	CV:Setup()

	if not IsValid(g_CV[name]) then
		g_CV[name] = CV
	end

	g_CV[namespace .. "." .. name] = CV
	g_CV_CMD[cmd] = CV

	local cvList = g_CV_List[namespace] or {}
	g_CV_List[namespace] = cvList

	table.insert(cvList, CV)

	return CV
end

function LIB.GetConVar(name)
	name = tostring(name or "")

	local CV = LIB.TryGetConVar(name)
	if not CV then
		error("ConVar object not found: " .. tostring(name or "<empty string>"))
		return nil
	end

	return CV
end

function LIB.TryGetConVar(name)
	name = tostring(name or "")

	local CV = g_CV[name] or g_CV_CMD[name]
	if not IsValid(CV) then
		return nil
	end

	return CV
end

function LIB.GetConVarValue(name)
	local CV = LIB.GetConVar(name)
	if not CV then return nil end

	return CV:GetValue()
end

function LIB.SetConVarValue(name, ...)
	local CV = LIB.GetConVar(name)
	if not CV then return end

	CV:SetValue(...)
end

function LIB.GetConVarListByNamespace(namespace)
	namespace = tostring(namespace or "")
	return g_CV_List[namespace] or {}
end

function LIB.AddBuildMenuPanelHook(namespace, title, buildFunction)
	namespace = tostring(namespace or "")
	title = tostring(title or "")

	local buildFunctionWrapper = function(CPanel)
		if not IsValid(CPanel) then
			return
		end

		local item = g_panels[namespace] or {}
		g_panels[namespace] = item

		if IsValid(item.panel) and item.panel ~= CPanel then
			item.panel:Remove()
			item.panel = nil
		end

		item.panel = CPanel
		item.func = buildFunction

		CPanel:Clear()
		buildFunction(CPanel)
	end

	StreamRadioLib.Hook.Add("PopulateToolMenu", "SettingsPanel_" .. namespace, function()
		LIBLocale.AddNativeTranslationAuto(
			"settings.addon_title",
			"Stream Radio"
		)

		LIBLocale.AddNativeTranslationAuto(
			"settings." .. namespace .. ".title",
			title
		)

		spawnmenu.AddToolMenuOption(
			"Utilities",
			LIBLocale.GetNativeTranslationIdentifier("settings.addon_title"),
			"StreamRadioSettingsPanel_" .. namespace,
			LIBLocale.GetNativeTranslationIdentifier("settings." .. namespace .. ".title"),
			"",
			"",
			buildFunctionWrapper,
			{}
		)
	end)
end

function LIB.RebuildMenuPanelByNamespace(namespace)
	namespace = tostring(namespace or "")

	local item = g_panels[namespace]
	if not item then
		return
	end

	local CPanel = item.panel
	local buildFunction = item.func

	if not IsValid(CPanel) then
		return
	end

	if not isfunction(buildFunction) then
		return
	end

	CPanel:Clear()
	buildFunction(CPanel)
end

function LIB.RebuildMenuPanels()
	for namespace, _ in pairs(g_panels) do
		LIB.RebuildMenuPanelByNamespace(namespace)
	end
end

function LIB.Load()
	LIBHook = StreamRadioLib.Hook
	LIBLocale = StreamRadioLib.Locale

	LIB.RebuildMenuPanels()

	local function callRebuildMenuPanels()
		LIB.RebuildMenuPanels()
	end

	LIBHook.AddCustom("OnLocaleChanged", "Settings.RebuildMenuPanels", callRebuildMenuPanels)
	LIBHook.AddCustom("OnLocaleGenerate", "Settings.RebuildMenuPanels", callRebuildMenuPanels)
end

return true

