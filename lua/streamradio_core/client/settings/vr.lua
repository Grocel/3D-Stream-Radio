local StreamRadioLib = StreamRadioLib

if StreamRadioLib.ReloadAddon() then
	return
end

StreamRadioLib.Settings = StreamRadioLib.Settings or {}
local LIB = StreamRadioLib.Settings

local T = StreamRadioLib.Locale.Translate

local LIBMenu = StreamRadioLib.Menu

LIB.g_CV_List["vr"] = {}

LIB.AddConVar("vr", "touch_enable", "cl_streamradio_vr_touch_enable", "1", {
	label = T("?settings.vr.touch_enable.label", "Enable VR Touch Control", true),
	help = "Enable Radio controlling via touch in VR when set to 1. Default: 1",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("vr", "trigger_enable", "cl_streamradio_vr_trigger_enable", "1", {
	label = T("?settings.vr.trigger_enable.label", "Enable VR Trigger Control", true),
	help = "Enable Radio controlling via trigger in VR when set to 1. Default: 1",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("vr", "gui_cursor_enable", "cl_streamradio_vr_gui_cursor_enable", "1", {
	label = T("?settings.vr.gui_cursor_enable.label", "Show cursor in VR", true),
	help = "Shows the cursor on radio GUIs in VR when set to 1. Default: 1",
	type = "bool",
})

local function BuildMenuPanel(CPanel)
	local toplabel = vgui.Create("DLabel")
	toplabel:SetText(T("?settings.vr.panel.title", "3D Stream Radio VR settings"))
	toplabel:SetDark(true)
	toplabel:SizeToContents()
	CPanel:AddPanel(toplabel)

	local StreamRadioLib = StreamRadioLib or {}

	if not StreamRadioLib.Loaded then
		if StreamRadioLib.Loader_CreateErrorPanel then
			StreamRadioLib.Loader_CreateErrorPanel(CPanel, "This menu could not be loaded.")
		end

		return
	end

	local hasVR = StreamRadioLib.VR.IsInstalled()

	if not hasVR then
		CPanel:AddPanel(LIBMenu.GetVRErrorPanel())

		CPanel:AddPanel(LIBMenu.GetSpacer())

		CPanel:AddPanel(LIBMenu.GetVRAddonButton())
		CPanel:AddItem(LIBMenu.GetSpacerLine())
	else
		CPanel:AddPanel(LIBMenu.GetVRInfoPanel())
	end


	CPanel:AddPanel(LIBMenu.GetSpacer(5))

	for i, v in ipairs(LIB.GetConVarListByNamespace("vr")) do
		if not IsValid(v) then continue end

		local p = v:BuildPanel(CPanel)
		if not IsValid(p) then continue end

		p:SetTooltip(v:GetPanellabel())
		p:SetEnabled(hasVR)
	end

	local VRAddonPanelButton = LIBMenu.GetVRAddonPanelButton()
	VRAddonPanelButton:SetEnabled(hasVR)

	CPanel:AddPanel(LIBMenu.GetSpacer(5))
	CPanel:AddPanel(VRAddonPanelButton)
	CPanel:AddPanel(LIBMenu.GetSpacer(5))
	CPanel:AddPanel(LIBMenu.GetVRFAQButton())
	CPanel:AddPanel(LIBMenu.GetCreditsPanel())
end

LIB.AddBuildMenuPanelHook("vr", "VR Settings", BuildMenuPanel)

return true

