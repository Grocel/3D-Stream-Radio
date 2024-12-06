local StreamRadioLib = StreamRadioLib

local g_allowSpectrum = false
local g_streamUrlLogMode = 1
local g_enableUrlWhitelist = true
local g_enableUrlWhitelistOnCFCWhitelist = true
local g_enableUrlWhitelistTrustAdminRadios = true

local g_lastThink = 0

local g_cvMaxServerSpectrum = CreateConVar(
	"sv_streamradio_max_spectrums",
	"5",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Sets the maximum count of radios that can have advanced wire outputs such as FFT spectrum or song tags. 0 = Off, Default: 5"
)

local g_cvStreamUrlLogMode = CreateConVar(
	"sv_streamradio_url_log_mode",
	"1",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Log stream URLs to console. Always logs all URLs on developer > 0. 0 = Disable, 1 = Online URLs only, 2 = All URLs, Default: 1"
)

local g_cvUrlWhitelistEnable = CreateConVar(
	"sv_streamradio_url_whitelist_enable",
	"1",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Enables the Stream URL whitelist. When enabled only URLs listed in playlists can be played. DATA SECURITY: Keep it enabled for better server security. Only turn it off if you know what you are doing! 0 = Disable, 1 = Enable, Default: 1"
)

local g_cvUrlWhitelistEnableOnCFCWhitelist = CreateConVar(
	"sv_streamradio_url_whitelist_enable_on_cfcwhitelist",
	"0",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Enables built-in Stream URL whitelist even if 'CFC Client HTTP Whitelist' is installed and 'sv_streamradio_url_whitelist_enable' is on. Otherwise built-in whitelist stays inactive as long CFC's one is active. 0 = Disable, 1 = Enable, Default: 0"
)

local g_cvUrlWhitelistTrustAdminRadios = CreateConVar(
	"sv_streamradio_url_whitelist_trust_admin_radios",
	"1",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Trust Stream URLs from radios owned by admins. Skips built-in whitelist checks for admin radios. 0 = No, 1 = Yes, Default: 1"
)

local g_cvRebuildCommunityPlaylists = CreateConVar(
	"sv_streamradio_rebuildplaylists_community_auto",
	"2",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Set how the community playlists are rebuild on server start. 0 = Off, 1 = Rebuild only, 2 = Delete and rebuild, Default: 2"
)

CreateConVar(
	"sv_streamradio_bass3_allow_client",
	"1",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Allows connected clients to use GM_BASS3 when set to 1. Overrides cl_streamradio_bass3_enable. Default: 1",
	0,
	1
)

CreateConVar(
	"sv_streamradio_bass3_enable",
	"1",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL ),
	"Use GM_BASS3 on the server if installed and when the ConVar is set to 1. Default: 1",
	0,
	1
)

function StreamRadioLib.AllowSpectrum()
	return g_allowSpectrum
end

function StreamRadioLib.IsUrlWhitelistEnabled()
	return g_enableUrlWhitelist
end

function StreamRadioLib.IsUrlWhitelistEnabledOnCFCWhitelist()
	return g_enableUrlWhitelistOnCFCWhitelist
end

function StreamRadioLib.IsUrlWhitelistAdminRadioTrusted()
	return g_enableUrlWhitelistTrustAdminRadios
end

function StreamRadioLib.GetStreamLogMode()
	return g_streamUrlLogMode
end

function StreamRadioLib.GetRebuildCommunityPlaylistsMode()
	local mode = g_cvRebuildCommunityPlaylists:GetInt()
	mode = math.Clamp(mode, 0, 2)

	return mode
end

local function calcAllowSpectrum()
	if not WireAddon then return false end
	if not StreamRadioLib.Bass.CanLoadDLL() then return false end

	local max = g_cvMaxServerSpectrum:GetInt()
	if max == 0 then return false end

	return StreamRadioLib.GetStreamingRadioCount() < max
end

local function calcStreamUrlLogMode()
	if StreamRadioLib.Util.IsDebug() then
		return StreamRadioLib.LOG_STREAM_URL_ALL
	end

	local mode = g_cvStreamUrlLogMode:GetInt()
	mode = math.Clamp(mode, 0, 2)

	return mode
end

local function calcUrlWhitelistEnabled()
	if game.SinglePlayer() then return false end
	if not g_cvUrlWhitelistEnable:GetBool() then return false end

	if g_enableUrlWhitelistOnCFCWhitelist then
		-- We always enable the built-in whitelist then
		return true
	end

	if StreamRadioLib.Cfchttp.CanCheckWhitelist() then
		-- CFC Client HTTP whitelist is available, disable our whitelist system then.
		return false
	end

	return true
end

local function calcUrlWhitelistEnabledOnCFCWhitelist()
	if game.SinglePlayer() then return false end
	if not g_cvUrlWhitelistEnableOnCFCWhitelist:GetBool() then return false end

	return true
end

local function calcUrlWhitelistEnabledTrustAdminRadios()
	if game.SinglePlayer() then return true end
	if not g_cvUrlWhitelistTrustAdminRadios:GetBool() then return false end

	return true
end

local function updateUrlWhitelistEnabled()
	if CLIENT then return end

	StreamRadioLib.Whitelist.InvalidateCache()
end

StreamRadioLib.Hook.Add("Think", "ConvarsUpdate", function()
	local now = RealTime()

	if g_lastThink < now then
		g_allowSpectrum = calcAllowSpectrum()
		g_streamUrlLogMode = calcStreamUrlLogMode()

		local old_enableUrlWhitelist = g_enableUrlWhitelist
		local old_enableUrlWhitelistOnCFCWhitelist = g_enableUrlWhitelistOnCFCWhitelist

		g_enableUrlWhitelistTrustAdminRadios = calcUrlWhitelistEnabledTrustAdminRadios()
		g_enableUrlWhitelistOnCFCWhitelist = calcUrlWhitelistEnabledOnCFCWhitelist()
		g_enableUrlWhitelist = calcUrlWhitelistEnabled()

		if old_enableUrlWhitelist ~= g_enableUrlWhitelist or old_enableUrlWhitelistOnCFCWhitelist ~= g_enableUrlWhitelistOnCFCWhitelist then
			updateUrlWhitelistEnabled()
		end

		g_lastThink = now + 1 + math.random()
	end
end)

return true

