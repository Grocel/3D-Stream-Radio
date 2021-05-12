StreamRadioLib.Settings = StreamRadioLib.Settings or {}
local LIB = StreamRadioLib.Settings

LIB.g_CV_List["general"] = {}

LIB.AddConVar("general", "mute", "cl_streamradio_mute", "0", {
	label = "Mute radios",
	help = "Mutes all radios when set to 1. Default: 0",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("general", "muteunfocused", "cl_streamradio_muteunfocused", "0", {
	label = "Mute radios on game unfocus",
	help = "Mutes all radios when the game is not in focus if set to 1. Default: 0",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("general", "mutedistance", "cl_streamradio_mutedistance", "2000", {
	label = "Mute at distance",
	help = "Mutes all radios which are further away than the given units. Min: 500, Max: 5000, Default: 2000",
	type = "int",
	userdata = true,
	min = 500,
	max = 5000,
})

LIB.AddConVar("general", "hidegui", "cl_streamradio_hidegui", "0", {
	label = "Hide GUIs",
	help = "Disables the drawing of GUIs for all radios when set to 1. Default: 0",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("general", "drawdistance", "cl_streamradio_drawdistance", "1000", {
	label = "GUI draw distance",
	help = "Stops GUIs drawing on radios which are further away than the given distance units. Min: 400, Max: 4000, Default: 1000",
	type = "int",
	userdata = true,
	min = 400,
	max = 4000,
})

LIB.AddConVar("general", "hidespectrumbars", "cl_streamradio_hidespectrumbars", "0", {
	label = "Hide spectrum bars",
	help = "Disables the drawing of FFT spectrums for all radios when set to 1. Default: 0",
	type = "bool",
})

LIB.AddConVar("general", "spectrumdistance", "cl_streamradio_spectrumdistance", "500", {
	label = "Spectrum draw distance",
	help = "Stops FFT spectrum drawing on radios which are further away than the given distance units. Min: 250, Max: 2500, Default: 500",
	type = "int",
	min = 250,
	max = 2500,
})

LIB.AddConVar("general", "spectrumbars", "cl_streamradio_spectrumbars", "128", {
	label = "Spectrum bars",
	help = "Sets the max count of FFT spectrum bars on radios. Higher amounts can decrease performance. Min: 8, Max: 2048, Default: 128",
	type = "int",
	min = 8,
	max = 2048,
})

LIB.AddConVar("general", "rendertarget", "cl_streamradio_rendertarget", "1", {
	label = "Enable rendertargets",
	help = "Enable rendertargets for drawing radio GUIs when set to 1. Disable this if you see graphics glitches. Default: 1",
	type = "bool",
})

LIB.AddConVar("general", "rendertarget_fps", "cl_streamradio_rendertarget_fps", "40", {
	label = "Rendertarget FPS",
	help = "Sets the max FPS of rendertargets. Higher amounts can decrease performance. Min: 5, Max: 300, Default: 40",
	type = "int",
	min = 5,
	max = 300,
})

LIB.AddConVar("general", "key", "cl_streamradio_key", KEY_E, {
	label = "Radio control/use key",
	help = "",
	type = "numpad",
})

LIB.AddConVar("general", "vehiclekey", "cl_streamradio_vehiclekey", MOUSE_LEFT, {
	label = "Radio control/use key while in vehicles",
	help = "",
	type = "numpad",
})

LIB.AddConVar("general", "volume", "cl_streamradio_volume", "1", {
	label = "Global volume",
	help = "Set the global volume factor for all radios. Default: 1, Min: 0, Max: 1 or 10",
	type = "float",
	min = 0,
	max = 10,
})

LIB.AddConVar("general", "coveredvolume", "cl_streamradio_coveredvolume", "0.33", {
	label = "Volume factor of radios behind walls",
	help = "Set the volume factor of radios that are behind walls. Default: 0.33, Min: 0, Max: 1",
	type = "float",
	min = 0,
	max = 1,
})

LIB.AddConVar("general", "hidecursor", "cl_streamradio_hidecursor", "0", {
	label = "Hide cursor",
	help = "Hides the cursor on radio GUIs when set to 1. Default: 0",
	type = "bool",
})

LIB.AddConVar("general", "no3dsound", "cl_streamradio_no3dsound", "0", {
	label = "Disable 3D Sound",
	help = "Disables 3D sound for all radios when set to 1. Default: 0",
	type = "bool",
})

LIB.AddConVar("general", "youtubesupport", "cl_streamradio_youtubesupport", "0", {
	label = "Enable YouTube support (slow and unreliable!)",
	help = "Enable YouTube support when set to 1. (slow and unreliable!) Default: 0",
	type = "bool",
	userdata = true,
	hidden = true,
	disabled = true,
})

local function BuildMenuPanel(CPanel)
	if not IsValid(CPanel) then return end

	local toplabel = vgui.Create("DLabel")
	toplabel:SetText("3D Stream Radio general settings")
	toplabel:SetDark(true)
	toplabel:SizeToContents()
	CPanel:AddPanel(toplabel)

	if not StreamRadioLib or not StreamRadioLib.Loaded then
		local errorlabel = vgui.Create("DLabel")

		errorlabel:SetDark(false)
		errorlabel:SetHighlight(true)
		errorlabel:SetText((StreamRadioLib.AddonPrefix or "") .. (StreamRadioLib.ErrorString or "") .. "\nThis menu could not be loaded.")
		errorlabel:SizeToContents()
		CPanel:AddPanel(errorlabel)

		return
	end

	for i, v in ipairs(LIB.GetConVarListByNamespace("general")) do
		if not IsValid(v) then continue end

		local p = v:BuildPanel(CPanel)
		if not IsValid(p) then continue end

		p:SetTooltip(v:GetPanellabel())
	end

	CPanel:AddPanel(StreamRadioLib.Menu.GetSpacer())
	CPanel:AddPanel(StreamRadioLib.Menu.GetPlaylistEditorButton())

	CPanel:AddControl( "button", {
		label = "Clear Client Stream Cache",
		command = "cl_streamradio_cacheclear"
	} )

	CPanel:AddControl( "button", {
		label = "Clear Server Stream Cache (Admin only!)",
		command = "sv_streamradio_cacheclear"
	} )

	CPanel:AddPanel(StreamRadioLib.Menu.GetSpacer(15))
	CPanel:AddPanel(StreamRadioLib.Menu.GetFAQButton())
	CPanel:AddPanel(StreamRadioLib.Menu.GetCreditsPanel())
end

LIB.AddBuildMenuPanelHook("general", "General Settings", BuildMenuPanel)

function StreamRadioLib.GetDrawDistance()
	return LIB.GetConVarValue("drawdistance")
end

function StreamRadioLib.IsSpectrumHidden()
	return LIB.GetConVarValue("hidespectrumbars")
end

function StreamRadioLib.GetSpectrumDistance()
	return LIB.GetConVarValue("spectrumdistance")
end

function StreamRadioLib.GetSpectrumBars()
	return LIB.GetConVarValue("spectrumbars")
end

function StreamRadioLib.IsRenderTarget()
	if ScrW() < 1024 then
		return false
	end

	if ScrH() < 512 then
		return false
	end

	return LIB.GetConVarValue("rendertarget")
end

function StreamRadioLib.RenderTargetFPS()
	return LIB.GetConVarValue("rendertarget_fps")
end

function StreamRadioLib.IsCursorHidden()
	return LIB.GetConVarValue("hidecursor")
end

function StreamRadioLib.Is3DSound()
	return not LIB.GetConVarValue("no3dsound")
end

function StreamRadioLib.GetControlKey()
	return LIB.GetConVarValue("key")
end

function StreamRadioLib.GetControlKeyVehicle()
	return LIB.GetConVarValue("vehiclekey")
end

function StreamRadioLib.GetGlobalVolume()
	return LIB.GetConVarValue("volume")
end

function StreamRadioLib.GetCoveredVolume()
	return LIB.GetConVarValue("coveredvolume")
end
