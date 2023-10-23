local StreamRadioLib = StreamRadioLib

StreamRadioLib.Settings = StreamRadioLib.Settings or {}

local LIB = StreamRadioLib.Settings
table.Empty(LIB)

LIB.g_CV =  {}
LIB.g_CV_CMD = {}
LIB.g_CV_List = {}
LIB.g_panels = LIB.g_panels or {}

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

	LIB.g_CV[name] = CV
	LIB.g_CV_CMD[cmd] = CV
	LIB.g_CV_List[namespace] = LIB.g_CV_List[namespace] or {}
	table.insert(LIB.g_CV_List[namespace], CV)

	return CV
end

function LIB.GetConVar(name)
	name = tostring(name or "")
	return LIB.g_CV[name] or LIB.g_CV_CMD[name]
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
	return LIB.g_CV_List[namespace] or {}
end

function LIB.AddBuildMenuPanelHook(namespace, title, buildFunction)
	namespace = tostring(namespace or "")
	title = tostring(title or "")

	StreamRadioLib.Hook.Add("PopulateToolMenu", "SettingsPanel_" .. namespace, function()
		spawnmenu.AddToolMenuOption( "Utilities", "Stream Radio", "StreamRadioSettingsPanel_" .. namespace, title, "", "", buildFunction, {} )
	end)
end

return true

