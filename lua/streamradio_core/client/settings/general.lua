local StreamRadioLib = StreamRadioLib

if StreamRadioLib.ReloadAddon() then
	return
end

StreamRadioLib.Settings = StreamRadioLib.Settings or {}
local LIB = StreamRadioLib.Settings

local T = StreamRadioLib.Locale.Translate

local LIBMenu = StreamRadioLib.Menu

local g_gui_distance = 0
local g_spectrum_hide = false
local g_spectrum_distance = 0
local g_spectrum_barcount = 0
local g_rendertarget = true
local g_rendertarget_fps = 30
local g_sfx_3dsound = true
local g_usekey_global = 0
local g_usekey_vehicle = 0
local g_volume_global = 1
local g_volume_occluded = 0

local g_nextThink = 0

LIB.g_CV_List["general"] = {}

LIB.AddConVar("general", "mute_global", "cl_streamradio_mute_global", "0", {
	label = T("?settings.general.mute_global.label", "Mute all radios", true),
	help = "Mutes all radios when set to 1. Default: 0",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("general", "mute_foreign", "cl_streamradio_mute_foreign", "0", {
	label = T("?settings.general.mute_foreign.label", "Mute all radios from other players", true),
	help = "Mutes all radios from other players when set to 1. Default: 0",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("general", "mute_unfocused", "cl_streamradio_mute_unfocused", "0", {
	label = T("?settings.general.mute_unfocused.label", "Mute radios on game unfocus", true),
	help = "Mutes all radios when the game is not in focus if set to 1. Default: 0",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("general", "mute_distance", "cl_streamradio_mute_distance", "2000", {
	label = T("?settings.general.mute_distance.label", "Mute at distance", true),
	help = "Mutes all radios which are further away than the given units. Min: 500, Max: 5000, Default: 2000",
	type = "int",
	userdata = true,
	min = 500,
	max = 5000,
})

LIB.AddConVar("general", "gui_hide", "cl_streamradio_gui_hide", "0", {
	label = T("?settings.general.gui_hide.label", "Hide GUIs", true),
	help = "Disables the drawing of GUIs for all radios when set to 1. Default: 0",
	type = "bool",
	userdata = true,
})

LIB.AddConVar("general", "gui_distance", "cl_streamradio_gui_distance", "1000", {
	label = T("?settings.general.gui_distance.label", "GUI draw distance", true),
	help = "Stops GUIs drawing on radios which are further away than the given distance units. Min: 400, Max: 4000, Default: 1000",
	type = "int",
	userdata = true,
	min = 400,
	max = 4000,
})

LIB.AddConVar("general", "spectrum_hide", "cl_streamradio_spectrum_hide", "0", {
	label = T("?settings.general.spectrum_hide.label", "Hide spectrum", true),
	help = "Disables the drawing of FFT spectrums for all radios when set to 1. Default: 0",
	type = "bool",
})

LIB.AddConVar("general", "spectrum_distance", "cl_streamradio_spectrum_distance", "500", {
	label = T("?settings.general.spectrum_distance.label", "Spectrum draw distance", true),
	help = "Stops FFT spectrum drawing on radios which are further away than the given distance units. Min: 250, Max: 2500, Default: 500",
	type = "int",
	min = 250,
	max = 2500,
})

LIB.AddConVar("general", "spectrum_barcount", "cl_streamradio_spectrum_barcount", "128", {
	label = T("?settings.general.spectrum_barcount.label", "Spectrum bars", true),
	help = "Sets the max count of FFT spectrum bars on radios. Higher amounts can decrease performance. Min: 8, Max: 2048, Default: 128",
	type = "int",
	min = 8,
	max = 2048,
})

LIB.AddConVar("general", "rendertarget", "cl_streamradio_rendertarget", "1", {
	label = T("?settings.general.rendertarget.label", "Enable rendertargets", true),
	help = "Enable rendertargets for drawing radio GUIs when set to 1. Disable this if you see graphics glitches. Default: 1",
	type = "bool",
})

LIB.AddConVar("general", "rendertarget_fps", "cl_streamradio_rendertarget_fps", "30", {
	label = T("?settings.general.rendertarget_fps.label", "Rendertarget FPS", true),
	help = "Sets the max FPS of rendertargets. Higher amounts can decrease performance. Min: 5, Max: 300, Default: 40",
	type = "int",
	min = 5,
	max = 300,
})

LIB.AddConVar("general", "usekey_global", "cl_streamradio_usekey_global", KEY_E, {
	label = T("?settings.general.usekey_global.label", "Radio control/use key", true),
	help = "Radio control/use key",
	type = "numpad",
})

LIB.AddConVar("general", "usekey_vehicle", "cl_streamradio_usekey_vehicle", MOUSE_LEFT, {
	label = T("?settings.general.usekey_vehicle.label", "Radio control/use key while in vehicles", true),
	help = "Radio control/use key while in vehicles",
	type = "numpad",
})

LIB.AddConVar("general", "volume_global", "cl_streamradio_volume_global", "1", {
	label = T("?settings.general.volume_global.label", "Global volume", true),
	help = "Set the global volume factor for all radios. Default: 1, Min: 0, Max: 10",
	type = "float",
	userdata = true,
	min = 0,
	max = 10,
})

LIB.AddConVar("general", "volume_occluded", "cl_streamradio_volume_occluded", "0.33", {
	label = T("?settings.general.volume_occluded.label", "Volume factor of radios behind walls (sound occlusion)", true),
	help = "Set the volume factor of radios that are behind walls (sound occlusion). Default: 0.33, Min: 0, Max: 1",
	type = "float",
	min = 0,
	max = 1,
})

LIB.AddConVar("general", "gui_cursor_enable", "cl_streamradio_gui_cursor_enable", "1", {
	label = T("?settings.general.gui_cursor_enable.label", "Show cursor", true),
	help = "Shows the cursor on radio GUIs when set to 1. Default: 1",
	type = "bool",
})

LIB.AddConVar("general", "sfx_3dsound", "cl_streamradio_sfx_3dsound", "1", {
	label = T("?settings.general.sfx_3dsound.label", "Enable 3D Sound", true),
	help = "Enables 3D sound for all radios when set to 1. Default: 1",
	type = "bool",
})

LIB.AddConVar("general", "bass3_enable", "cl_streamradio_bass3_enable", "1", {
	label = T("?settings.general.bass3_enable.label", "Use GM_BASS3 if installed", true),
	help = "When set to 1, it uses GM_BASS3 if installed on client and allowed on the server. Default: 1",
	type = "bool",
})

LIB.AddConVar("general", "locale", "cl_streamradio_locale", "auto", {
	label = T("?settings.general.locale.label", "Language", true),
	help = "Set the language being used for all interfaces of Stream Radio addon. Set to 'auto' to use gmod_language. Might need to reconnect for all changes to take effect. Default: auto",
	type = "locale",
	userdata = true,
})

local function BuildMenuPanel(CPanel)
	local toplabel = vgui.Create("DLabel")
	toplabel:SetText(T("?settings.general.panel.title", "3D Stream Radio general settings"))
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

	local cvBass3Enable = LIB.TryGetConVar("bass3_enable")
	if cvBass3Enable then
		cvBass3Enable:SetDisabled(not StreamRadioLib.Bass.IsInstalled())
	end

	CPanel:Button(
		T("?settings.general.cache_clear.label", "Clear client stream cache"),
		"cl_streamradio_cache_clear"
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
	return g_gui_distance
end

function StreamRadioLib.IsSpectrumHidden()
	return g_spectrum_hide
end

function StreamRadioLib.GetSpectrumDistance()
	return g_spectrum_distance
end

function StreamRadioLib.GetSpectrumBars()
	return g_spectrum_barcount
end

function StreamRadioLib.IsRenderTarget()
	return g_rendertarget
end

function StreamRadioLib.GetRenderTargetFPS()
	return g_rendertarget_fps
end

function StreamRadioLib.Is3DSound()
	return g_sfx_3dsound
end

function StreamRadioLib.GetControlKey()
	return g_usekey_global
end

function StreamRadioLib.GetControlKeyVehicle()
	return g_usekey_vehicle
end

function StreamRadioLib.GetGlobalVolume()
	return g_volume_global
end

function StreamRadioLib.GetOccludedVolume()
	return g_volume_occluded
end

local function calcRendertargetFps()
	-- Limit the rendertarget FPS.
	-- It also affects g_fastlistenfunc think in base_listener.lua

	if not system.HasFocus() then
		return 5
	end

	if StreamRadioLib.IsGUIHidden() then
		return 5
	end

	local fps = LIB.GetConVarValue("rendertarget_fps")
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

local g_hadFocus = true

StreamRadioLib.Hook.Add("Think", "SettingsUpdate", function()
	local now = RealTime()
	local hasFocus = system.HasFocus()

	if g_hadFocus ~= hasFocus and hasFocus then
		-- Force calling the value evals on focus change
		g_nextThink = 0
	end

	g_hadFocus = hasFocus

	if g_nextThink < now then
		g_gui_distance = LIB.GetConVarValue("gui_distance")
		g_spectrum_hide = LIB.GetConVarValue("spectrum_hide")
		g_spectrum_distance = LIB.GetConVarValue("spectrum_distance")
		g_spectrum_barcount = LIB.GetConVarValue("spectrum_barcount")
		g_rendertarget = calcIsRendertarget()
		g_rendertarget_fps = calcRendertargetFps()
		g_sfx_3dsound = LIB.GetConVarValue("sfx_3dsound")

		g_nextThink = now + 1 + math.random()
	end

	g_usekey_global = LIB.GetConVarValue("usekey_global")
	g_usekey_vehicle = LIB.GetConVarValue("usekey_vehicle")
	g_volume_global = LIB.GetConVarValue("volume_global")
	g_volume_occluded = LIB.GetConVarValue("volume_occluded")
end)

return true

