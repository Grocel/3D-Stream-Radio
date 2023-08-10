local StreamRadioLib = StreamRadioLib

local LIBUtil = StreamRadioLib.Util

local g_allowSpectrum = false
local g_allowCustomURLs = false

local g_lastThink = 0

local g_cvMaxServerSpectrum = CreateConVar(
	"sv_streamradio_max_spectrums",
	"5",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Sets the maximum count of radios that can have advanced wire outputs such as FFT spectrum or song tags. 0 = Off, Default: 5"
)

local g_cvAllowCustomURLs = CreateConVar(
	"sv_streamradio_allow_customurls",
	"1",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Allow or disallow custom URLs to be played. 1 = Allow, 0 = Disallow, Default: 1"
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

function StreamRadioLib.IsCustomURLsAllowed(ply)
	if g_allowCustomURLs then return true end

	-- Admins can always use custom stream URLs
	if LIBUtil.IsAdmin(ply) then return true end -- @TODO

	return false
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

local function calcAllowCustomURLs()
	if game.SinglePlayer() then return true end

	local blockedURLCode = StreamRadioLib.BlockedURLCode or ""
	local blockedURLCodeSequence = StreamRadioLib.BlockedURLCodeSequence or ""

	if blockedURLCode == "" then return true end
	if blockedURLCodeSequence == "" then return true end

	if g_cvAllowCustomURLs:GetBool() then return true end

	return false
end

StreamRadioLib.Hook.Add("Think", "ConvarsUpdate", function()
	local now = RealTime()

	if g_lastThink < now then
		g_allowSpectrum = calcAllowSpectrum()
		g_allowCustomURLs = calcAllowCustomURLs()

		g_lastThink = now + 1 + math.random()
	end
end)
