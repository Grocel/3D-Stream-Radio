local StreamRadioLib = StreamRadioLib

local g_allowSpectrum = false
local g_enableUrlWhitelist = true

local g_lastThink = 0

local g_cvMaxServerSpectrum = CreateConVar(
	"sv_streamradio_max_spectrums",
	"5",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Sets the maximum count of radios that can have advanced wire outputs such as FFT spectrum or song tags. 0 = Off, Default: 5"
)

local g_cvUrlWhitelistEnable = CreateConVar(
	"sv_streamradio_url_whitelist_enable",
	"1",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Disables or enables the Stream URL whitelist. When enabled only URLs listed in playlists can be played. DATA SECURITY: Keep it enabled for better server security. 1 = Enable, 0 = Disable, Default: 0"
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
	"When set to 1, it uses GM_BASS3 on the server if installed. Default: 1",
	0,
	1
)

function StreamRadioLib.AllowSpectrum()
	return g_allowSpectrum
end

function StreamRadioLib.IsUrlWhitelistEnabled()
	if not g_enableUrlWhitelist then return false end
	return true
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

local function calcUrlWhitelistEnabled()
	if game.SinglePlayer() then return false end
	if not g_cvUrlWhitelistEnable:GetBool() then return false end

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

		local old_enableUrlWhitelist = g_enableUrlWhitelist
		g_enableUrlWhitelist = calcUrlWhitelistEnabled()

		if old_enableUrlWhitelist ~= g_enableUrlWhitelist then
			updateUrlWhitelistEnabled()
		end

		g_lastThink = now + 1 + math.random()
	end
end)

return true

