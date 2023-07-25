local StreamRadioLib = StreamRadioLib

local MaxServerSpectrum = CreateConVar( "sv_streamradio_max_spectrums", "5", bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ), "Sets the maximum count of radios that can have advanced wire outputs such as FFT spectrum or song tags. -1 = Infinite, 0 = Off, Default: 5" )
local AllowCustomURLs = CreateConVar( "sv_streamradio_allow_customurls", "1", bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ), "Allow or disallow custom URLs to be played. 1 = Allow, 0 = Disallow, Default: 1" )
local RebuildCommunityPlaylists = CreateConVar( "sv_streamradio_rebuildplaylists_community_auto", "2", bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ), "Set how the community playlists are rebuild on server start. 0 = Off, 1 = Rebuild only, 2 = Delete and rebuild, Default: 2" )

CreateConVar(
	"sv_streamradio_bass3_allow_client",
	"1",
	bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED ),
	"Allows connected clients to use GM_BASS3 when set to 1. Overrides cl_streamradio_bass3_enable. Default: 1",
	0,
	1
)

if SERVER then
	CreateConVar(
		"sv_streamradio_bass3_enable",
		"1",
		bit.bor( FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL ),
		"When set to 1, it uses GM_BASS3 on the server if installed. Default: 1",
		0,
		1
	)
end

function StreamRadioLib.AllowSpectrum()
	if not WireAddon then return false end
	if not StreamRadioLib.Bass.CanLoadDLL() then return false end

	local max = MaxServerSpectrum:GetInt()
	if max == 0 then return false end
	if max < 0 then return true end
	if game.SinglePlayer() then return true end

	return StreamRadioLib.GetStreamingRadioCount() < max
end

function StreamRadioLib.IsCustomURLsAllowed()
	if ( game.SinglePlayer( ) ) then return true end
	if ( not StreamRadioLib.BlockedURLCode ) then return true end
	if ( StreamRadioLib.BlockedURLCode == "" ) then return true end

	return AllowCustomURLs:GetBool( )
end

function StreamRadioLib.GetRebuildCommunityPlaylistsMode()
	local mode = RebuildCommunityPlaylists:GetInt()

	if ( mode <= 0 ) then return 0 end
	if ( mode > 2 ) then return 0 end

	return mode
end