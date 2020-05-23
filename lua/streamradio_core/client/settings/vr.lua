StreamRadioLib.Settings = StreamRadioLib.Settings or {}
local LIB = StreamRadioLib.Settings

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

local function BuildMenuPanel(CPanel)
	if not IsValid(CPanel) then return end

	local toplabel = vgui.Create("DLabel")
	toplabel:SetText("3D Stream Radio VR settings")
	toplabel:SetDark(true)
	toplabel:SizeToContents()
	CPanel:AddPanel(toplabel)

	if not StreamRadioLib or not StreamRadioLib.Loaded then
		local errorlabel = vgui.Create("DLabel")

		errorlabel:SetDark(false)
		errorlabel:SetHighlight(true)
		errorlabel:SetText((StreamRadioLib.Addonname or "") .. (StreamRadioLib.ErrorString or "") .. "\nThis menu could not be loaded.")
		errorlabel:SizeToContents()
		CPanel:AddPanel(errorlabel)

		return
	end

	if not StreamRadioLib.VR.IsInstalled() then
		local errorlabel = vgui.Create("DLabel")

		errorlabel:SetDark(false)
		errorlabel:SetHighlight(true)
		errorlabel:SetText((StreamRadioLib.Addonname or "") .. "\nVRMod is not loaded, install VRMod to enable VR support.\nVR Headset required!")
		errorlabel:SizeToContents()
		CPanel:AddPanel(errorlabel)

		CPanel:AddPanel(StreamRadioLib.Menu.GetSpacer())

		CPanel:AddPanel(StreamRadioLib.Menu.GetVRAddonButton())
		CPanel:AddPanel(StreamRadioLib.Menu.GetVRFAQButton())
		return
	end

	CPanel:AddPanel(StreamRadioLib.Menu.GetVRCreditsPanel())
	CPanel:AddPanel(StreamRadioLib.Menu.GetSpacer(5))

	for i, v in ipairs(LIB.GetConVarListByNamespace("vr")) do
		if not IsValid(v) then continue end

		local p = v:BuildPanel(CPanel)
		if not IsValid(p) then continue end

		p:SetTooltip(v:GetPanellabel())
	end

	CPanel:AddPanel(StreamRadioLib.Menu.GetSpacer(15))
	CPanel:AddPanel(StreamRadioLib.Menu.GetVRFAQButton())
	CPanel:AddPanel(StreamRadioLib.Menu.GetCreditsPanel())
end

LIB.AddBuildMenuPanelHook("vr", "VR Settings", BuildMenuPanel)
