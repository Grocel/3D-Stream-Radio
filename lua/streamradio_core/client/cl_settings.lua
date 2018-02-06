StreamRadioLib.Settings = StreamRadioLib.Settings or {}
local LIB = StreamRadioLib.Settings
LIB.g_CV =  {}
LIB.g_CV_CMD = {}
LIB.g_CV_List = {}

function LIB.AddConVar(name, cmd, default, data)
	if not name then return nil end
	if not cmd then return nil end
	if not default then return nil end
	if not data then return nil end

	local CV = StreamRadioLib.CreateOBJ("clientconvar")
	CV:SetName(name)
	CV:SetCMD(cmd)
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

	CV:SetPanellabel(data.label)

	CV:SetType(data.type)
	CV:SetMin(data.min)
	CV:SetMax(data.max)

	CV:Setup()

	LIB.g_CV[name] = CV
	LIB.g_CV_CMD[cmd] = CV
	table.insert(LIB.g_CV_List, CV)

	StreamRadioLib.Timer.NextFrame("cl_settings_convars", LIB.RebuildBuildMenuPanel)
	return CV
end

function LIB.GetConVar(name)
	name = name or ""
	return LIB.g_CV[name] or LIB.g_CV_CMD[cmd]
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

LIB.AddConVar("mute", "cl_streamradio_mute", "0", {
	label = "Mute radios",
	help = "Mutes all radios when set to 1. Default: 0",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("mutedistance", "cl_streamradio_mutedistance", "2000", {
	label = "Mute at distance",
	help = "Mutes all radios which are further away than the given units. Min: 500, Max: 5000, Default: 2000",
	type = "int",
	userdata = true,
	min = 500,
	max = 5000,
})

LIB.AddConVar("hidegui", "cl_streamradio_hidegui", "0", {
	label = "Hide GUIs",
	help = "Disables the drawing of GUIs for all radios when set to 1. Default: 0",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("drawdistance", "cl_streamradio_drawdistance", "1000", {
	label = "GUI draw distance",
	help = "Stops GUIs drawing on radios which are further away than the given distance units. Min: 400, Max: 4000, Default: 1000",
	type = "int",
	userdata = true,
	min = 400,
	max = 4000,
})

LIB.AddConVar("hidespectrumbars", "cl_streamradio_hidespectrumbars", "0", {
	label = "Hide spectrum bars",
	help = "Disables the drawing of FFT spectrums for all radios when set to 1. Default: 0",
	type = "bool",
})

LIB.AddConVar("spectrumdistance", "cl_streamradio_spectrumdistance", "500", {
	label = "Spectrum draw distance",
	help = "Stops FFT spectrum drawing on radios which are further away than the given distance units. Min: 250, Max: 2500, Default: 500",
	type = "int",
	min = 250,
	max = 2500,
})

LIB.AddConVar("spectrumbars", "cl_streamradio_spectrumbars", "128", {
	label = "Spectrum bars",
	help = "Sets the max count of FFT spectrum bars on radios. Higher amounts can decrease performance. Min: 8, Max: 2048, Default: 128",
	type = "int",
	min = 8,
	max = 2048,
})

LIB.AddConVar("rendertarget", "cl_streamradio_rendertarget", "1", {
	label = "Enable rendertargets",
	help = "Enable rendertargets for drawing radio GUIs when set to 1. Disable this if you see graphics glitches. Default: 1",
	type = "bool",
})

LIB.AddConVar("rendertarget_fps", "cl_streamradio_rendertarget_fps", "40", {
	label = "Rendertarget FPS",
	help = "Sets the max FPS of rendertargets. Higher amounts can decrease performance. Min: 5, Max: 300, Default: 40",
	type = "int",
	min = 5,
	max = 300,
})

LIB.AddConVar("key", "cl_streamradio_key", KEY_E, {
	label = "Radio control/use key",
	help = "",
	type = "numpad",
})

LIB.AddConVar("vehiclekey", "cl_streamradio_vehiclekey", MOUSE_LEFT, {
	label = "Radio control/use key while in vehicles",
	help = "",
	type = "numpad",
})

LIB.AddConVar("volume", "cl_streamradio_volume", "1", {
	label = "Global volume",
	help = "Set the global volume factor for all radios. Default: 1, Min: 0, Max: 1 or 10 (with GM_BASS3 installed)",
	type = "float",
	min = 0,
	max = StreamRadioLib.HasBass and 10 or 1,
})

LIB.AddConVar("coveredvolume", "cl_streamradio_coveredvolume", "0.33", {
	label = "Volume factor of radios behind walls",
	help = "Set the volume factor of radios that are behind walls. Default: 0.33, Min: 0, Max: 1",
	type = "float",
	min = 0,
	max = 1,
})

LIB.AddConVar("hidecursor", "cl_streamradio_hidecursor", "0", {
	label = "Hide cursor",
	help = "Hides the cursor on radio GUIs when set to 1. Default: 0",
	type = "bool",
})

LIB.AddConVar("no3dsound", "cl_streamradio_no3dsound", "0", {
	label = "Disable 3D Sound (makes radios louder)",
	help = "Disables 3D sound for all radios when set to 1. Default: 0",
	type = "bool",
})

LIB.AddConVar("youtubesupport", "cl_streamradio_youtubesupport", "0", {
	label = "Enable YouTube support (slow and unreliable!)",
	help = "Enable YouTube support when set to 1. (slow and unreliable!) Default: 0",
	type = "bool",
})


local function BuildMenuPanel(CPanel)
	if not IsValid(CPanel) then return end

	if IsValid(LIB.g_panel) then
		LIB.g_panel:Clear()
	end

	LIB.g_panel = CPanel

	local toplabel = vgui.Create("DLabel")
	toplabel:SetText("3D Stream Radio client settings.")
	toplabel:SetDark(true)
	toplabel:SizeToContents()
	CPanel:AddPanel(toplabel)

	if not StreamRadioLib.Loaded then
		local errorlabel = vgui.Create("DLabel")

		errorlabel:SetDark(false)
		errorlabel:SetHighlight(true)
		errorlabel:SetText((StreamRadioLib.Addonname or "") .. (StreamRadioLib.ErrorString or "") .. "\nThis menu could not be loaded.")
		errorlabel:SizeToContents()
		CPanel:AddPanel(errorlabel)

		return
	end

	for i, v in ipairs(LIB.g_CV_List) do
		if not IsValid(v) then continue end
		v:BuildPanel(CPanel)
	end

	CPanel:AddControl( "button", {
		label = "Open Playlist Editor (Admin only!)",
		command = "cl_streamradio_playlisteditor"
	} )

	CPanel:AddControl( "button", {
		label = "Clear Client Stream Cache",
		command = "cl_streamradio_cacheclear"
	} )

	CPanel:AddControl( "button", {
		label = "Clear Server Stream Cache (Admin only!)",
		command = "sv_streamradio_cacheclear"
	} )

	local credits = vgui.Create("DLabel")
	credits:SetDark(true)
	credits:SetText(StreamRadioLib.Addonname .. "Made by Grocel")
	credits:SizeToContents()
	CPanel:AddPanel(credits)
end

hook.Add("PopulateToolMenu", "AddStreamRadioSettingsPanel", function()
	spawnmenu.AddToolMenuOption( "Utilities", "Stream Radio", "StreamRadioSettingsPanel", "Settings", "", "", BuildMenuPanel, {} )
end)

function LIB.RebuildBuildMenuPanel()
	BuildMenuPanel(LIB.g_panel)
end

function StreamRadioLib.GetDrawDistance( )
	return LIB.GetConVarValue("drawdistance")
end

function StreamRadioLib.IsSpectrumHidden( )
	return LIB.GetConVarValue("hidespectrumbars")
end

function StreamRadioLib.GetSpectrumDistance( )
	return LIB.GetConVarValue("spectrumdistance")
end

function StreamRadioLib.GetSpectrumBars( )
	return LIB.GetConVarValue("spectrumbars")
end

function StreamRadioLib.IsRenderTarget( )
	if ScrW() < 1024 then
		return false
	end

	if ScrH() < 512 then
		return false
	end

	return LIB.GetConVarValue("rendertarget")
end

function StreamRadioLib.RenderTargetFPS( )
	return LIB.GetConVarValue("rendertarget_fps")
end

function StreamRadioLib.IsCursorHidden( )
	return LIB.GetConVarValue("hidecursor")
end

function StreamRadioLib.Is3DSound( )
	return not LIB.GetConVarValue("no3dsound")
end

function StreamRadioLib.HasYoutubeSupport()
	return LIB.GetConVarValue("youtubesupport")
end

function StreamRadioLib.GetControlKey( )
	return LIB.GetConVarValue("key")
end

function StreamRadioLib.GetControlKeyVehicle( )
	return LIB.GetConVarValue("vehiclekey")
end

function StreamRadioLib.GetGlobalVolume( )
	return LIB.GetConVarValue("volume")
end

function StreamRadioLib.GetCoveredVolume( )
	return LIB.GetConVarValue("coveredvolume")
end
