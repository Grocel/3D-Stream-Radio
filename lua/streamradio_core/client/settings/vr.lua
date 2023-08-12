local StreamRadioLib = StreamRadioLib

StreamRadioLib.Settings = StreamRadioLib.Settings or {}
local LIB = StreamRadioLib.Settings

local LIBMenu = StreamRadioLib.Menu

LIB.g_CV_List["vr"] = {}

LIB.AddConVar("vr", "vr_enable_touch", "cl_streamradio_vr_enable_touch", "1", {
	label = "Enable VR Touch Control",
	help = "Enable Radio controlling via touch in VR when set to 1. Default: 1",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("vr", "vr_enable_trigger", "cl_streamradio_vr_enable_trigger", "1", {
	label = "Enable VR Trigger Control",
	help = "Enable Radio controlling via trigger in VR when set to 1. Default: 1",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("vr", "vr_enable_cursor", "cl_streamradi_vr_enable_cursor", "1", {
	label = "Show cursor in VR",
	help = "Shows the cursor on radio GUIs in VR when set to 1. Default: 1",
	type = "bool",
})

local function BuildMenuPanel(CPanel)
	if not IsValid(CPanel) then return end

	local toplabel = vgui.Create("DLabel")
	toplabel:SetText("3D Stream Radio VR settings")
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

	if not StreamRadioLib.VR.IsInstalled() then
		CPanel:AddPanel(LIBMenu.GetVRErrorPanel())

		CPanel:AddPanel(LIBMenu.GetSpacer())

		CPanel:AddPanel(LIBMenu.GetVRAddonButton())
		CPanel:AddPanel(LIBMenu.GetVRFAQButton())
		return
	end

	CPanel:AddPanel(LIBMenu.GetVRInfoPanel())
	CPanel:AddPanel(LIBMenu.GetSpacer(5))

	for i, v in ipairs(LIB.GetConVarListByNamespace("vr")) do
		if not IsValid(v) then continue end

		local p = v:BuildPanel(CPanel)
		if not IsValid(p) then continue end

		p:SetTooltip(v:GetPanellabel())
	end

	CPanel:AddPanel(LIBMenu.GetSpacer(5))
	CPanel:AddPanel(LIBMenu.GetVRAddonPanelButton())
	CPanel:AddPanel(LIBMenu.GetSpacer(5))
	CPanel:AddPanel(LIBMenu.GetVRFAQButton())
	CPanel:AddPanel(LIBMenu.GetCreditsPanel())
end

LIB.AddBuildMenuPanelHook("vr", "VR Settings", BuildMenuPanel)

return true

