local StreamRadioLib = StreamRadioLib

StreamRadioLib.Settings = StreamRadioLib.Settings or {}
local LIB = StreamRadioLib.Settings

local LIBMenu = StreamRadioLib.Menu

local g_drawdistance = 0
local g_hidespectrumbars = false
local g_spectrumdistance = 0
local g_spectrumbars = 0
local g_rendertarget = true
local g_rendertarget_fps = 10
local g_3dsound = true
local g_key = 0
local g_key_vehicle = 0
local g_volume = 1
local g_coveredvolume = 0

local g_lastThink = 0

LIB.g_CV_List["general"] = {}

LIB.AddConVar("general", "mute", "cl_streamradio_mute", "0", {
	label = "Mute all radios",
	help = "Mutes all radios when set to 1. Default: 0",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("general", "mute_foreign", "cl_streamradio_mute_foreign", "0", {
	label = "Mute all radios from other players",
	help = "Mutes all radios from other players when set to 1. Default: 0",
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

LIB.AddConVar("general", "key_vehicle", "cl_streamradio_key_vehicle", MOUSE_LEFT, {
	label = "Radio control/use key while in vehicles",
	help = "",
	type = "numpad",
})

LIB.AddConVar("general", "volume", "cl_streamradio_volume", "1", {
	label = "Global volume",
	help = "Set the global volume factor for all radios. Default: 1, Min: 0, Max: 1 or 10",
	type = "float",
	userdata = true,
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

LIB.AddConVar("general", "enable_cursor", "cl_streamradio_enable_cursor", "1", {
	label = "Show cursor",
	help = "Shows the cursor on radio GUIs when set to 1. Default: 1",
	type = "bool",
})

LIB.AddConVar("general", "no3dsound", "cl_streamradio_no3dsound", "0", {
	label = "Disable 3D Sound",
	help = "Disables 3D sound for all radios when set to 1. Default: 0",
	type = "bool",
})

LIB.AddConVar("general", "bass3_enable", "cl_streamradio_bass3_enable", "1", {
	label = "Use GM_BASS3 if installed",
	help = "When set to 1, it uses GM_BASS3 if installed on client and allowed on the server. Default: 1",
	type = "bool",
})

local function BuildMenuPanel(CPanel)
	if not IsValid(CPanel) then return end

	local toplabel = vgui.Create("DLabel")
	toplabel:SetText("3D Stream Radio general settings")
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

	local cvBass3Enable = LIB.GetConVar("bass3_enable")
	cvBass3Enable:SetDisabled(not StreamRadioLib.Bass.IsInstalled())

	CPanel:Button(
		"Clear client stream cache",
		"cl_streamradio_cacheclear"
	)

	CPanel:AddPanel(LIBMenu.GetSpacer())

	for i, v in ipairs(LIB.GetConVarListByNamespace("general")) do
		if not IsValid(v) then continue end

		local p = v:BuildPanel(CPanel)
		if not IsValid(p) then continue end

		p:SetTooltip(v:GetPanellabel())
	end

	CPanel:AddPanel(LIBMenu.GetSpacer())

	CPanel:AddPanel(LIBMenu.GetOpenToolButton())
	CPanel:AddPanel(LIBMenu.GetOpenAdminSettingsButton())
	CPanel:AddPanel(LIBMenu.GetPlaylistEditorButton())

	CPanel:AddPanel(LIBMenu.GetSpacer(5))
	CPanel:AddPanel(LIBMenu.GetFAQButton())
	CPanel:AddPanel(LIBMenu.GetCreditsPanel())
end

LIB.AddBuildMenuPanelHook("general", "General Settings", BuildMenuPanel)

function StreamRadioLib.GetDrawDistance()
	return g_drawdistance
end

function StreamRadioLib.IsSpectrumHidden()
	return g_hidespectrumbars
end

function StreamRadioLib.GetSpectrumDistance()
	return g_spectrumdistance
end

function StreamRadioLib.GetSpectrumBars()
	return g_spectrumbars
end

function StreamRadioLib.IsRenderTarget()
	return g_rendertarget
end

function StreamRadioLib.GetRenderTargetFPS()
	return g_rendertarget_fps
end

function StreamRadioLib.Is3DSound()
	return g_3dsound
end

function StreamRadioLib.GetControlKey()
	return g_key
end

function StreamRadioLib.GetControlKeyVehicle()
	return g_key_vehicle
end

function StreamRadioLib.GetGlobalVolume()
	return g_volume
end

function StreamRadioLib.GetCoveredVolume()
	return g_coveredvolume
end

local function calcRendertargetFps()
	if StreamRadioLib.IsGUIHidden() then
		-- When we have no GUIs, limit FPS that also affects g_fastlistenfunc think in base_listener.lua
		return 5
	end

	local fps = LIB.GetConVarValue("rendertarget_fps")

	fps = math.max(fps, 2)

	return fps
end

local function calcIsRendertarget()
	if ScrW() < 1024 then
		return false
	end

	if ScrH() < 512 then
		return false
	end

	return LIB.GetConVarValue("rendertarget")
end

StreamRadioLib.Hook.Add("Think", "SettingsUpdate", function()
	local now = RealTime()

	if g_lastThink < now then
		g_drawdistance = LIB.GetConVarValue("drawdistance")
		g_hidespectrumbars = LIB.GetConVarValue("hidespectrumbars")
		g_spectrumdistance = LIB.GetConVarValue("spectrumdistance")
		g_spectrumbars = LIB.GetConVarValue("spectrumbars")
		g_rendertarget = calcIsRendertarget()
		g_rendertarget_fps = calcRendertargetFps()
		g_3dsound = not LIB.GetConVarValue("no3dsound")

		g_lastThink = now + 1 + math.random()
	end

	g_key = LIB.GetConVarValue("key")
	g_key_vehicle = LIB.GetConVarValue("key_vehicle")
	g_volume = LIB.GetConVarValue("volume")
	g_coveredvolume = LIB.GetConVarValue("coveredvolume")
end)

return true

