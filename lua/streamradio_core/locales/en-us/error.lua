local LOCALE = LOCALE
if not istable(LOCALE) then
	StreamRadioLib.ReloadAddon()
	return
end

-- Translation file for locale "en-us" (English (US))
--   by Grocel

-- This is a sub locale file.
-- See "lua/streamradio_core/locales/en-us/init.lua" for translation notes and rules.

-- ################################################################################
-- Main Category: error
-- ################################################################################


-- ================================================================================
-- Sub Category:  error.playlist_error_invalid_file_1100
-- ================================================================================

-- Current: Invalid Playlist
LOCALE:Set("error.playlist_error_invalid_file_1100.description", [[Invalid Playlist]])

-- Current:
--  | The Playlist file you are trying to load is invalid.
--  | 
--  | This could be the problem:
--  | 	- The playlist could not be found or read.
--  | 	- Its format is not supported.
--  | 	- It is broken.
--  | 	- It is empty.
--  | 
--  | Supported playlist formats:
--  | 	M3U, PLS, VDF, JSON
--  | 
--  | Playlists are located at "<path_to_game>/garrysmod/data/streamradio/playlists/".
--  | 
--  | Hint: Use the playlist editor to make playlists.
LOCALE:Set("error.playlist_error_invalid_file_1100.helptext", [[The Playlist file you are trying to load is invalid.

This could be the problem:
	- The playlist could not be found or read.
	- Its format is not supported.
	- It is broken.
	- It is empty.

Supported playlist formats:
	M3U, PLS, VDF, JSON

Playlists are located at "<path_to_game>/garrysmod/data/streamradio/playlists/".

Hint: Use the playlist editor to make playlists.]])


-- ================================================================================
-- Sub Category:  error.stream_error_already_14
-- ================================================================================

-- Current: Already initialized/paused/whatever
LOCALE:Set("error.stream_error_already_14.description", [[Already initialized/paused/whatever]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_already_14.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_bad_drive_letter_path_1030
-- ================================================================================

-- Current: Drive letter paths are not supported, use relative paths
LOCALE:Set("error.stream_error_bad_drive_letter_path_1030.description", [[Drive letter paths are not supported, use relative paths]])

-- Current:
--  | Do not use drive letter paths. Use relative paths instead.
--  | 
--  | A relative path never starts with a drive letter such as "C:/" or "D:/".
--  | 
--  | This is a relative path:
--  |   music/hl1_song3.mp3
--  | 
--  | This is NOT a relative path:
--  |   C:/Program Files (x86)/Steam/steamapps/common/GarrysMod/garrysmod/sound/music/hl1_song3.mp3
LOCALE:Set("error.stream_error_bad_drive_letter_path_1030.helptext", [[Do not use drive letter paths. Use relative paths instead.

A relative path never starts with a drive letter such as "C:/" or "D:/".

This is a relative path:
  music/hl1_song3.mp3

This is NOT a relative path:
  C:/Program Files (x86)/Steam/steamapps/common/GarrysMod/garrysmod/sound/music/hl1_song3.mp3]])


-- ================================================================================
-- Sub Category:  error.stream_error_buflost_4
-- ================================================================================

-- Current: The sample buffer was lost
LOCALE:Set("error.stream_error_buflost_4.description", [[The sample buffer was lost]])

-- Current:
--  | Your sound driver/interface was lost.
--  | 
--  | To fix it you need to do this:
--  | - Plugin your speakers or head phones.
--  | - Enable the sound device.
--  | - Restart the game. Do not just disconnect!
--  | - Restart your PC, if it still not works.
LOCALE:Set("error.stream_error_buflost_4.helptext", [[Your sound driver/interface was lost.

To fix it you need to do this:
- Plugin your speakers or head phones.
- Enable the sound device.
- Restart the game. Do not just disconnect!
- Restart your PC, if it still not works.]])


-- ================================================================================
-- Sub Category:  error.stream_error_busy_46
-- ================================================================================

-- Current: The device is busy
LOCALE:Set("error.stream_error_busy_46.description", [[The device is busy]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_busy_46.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_codec_44
-- ================================================================================

-- Current: Codec is not available/supported
LOCALE:Set("error.stream_error_codec_44.description", [[Codec is not available/supported]])

-- Current:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
LOCALE:Set("error.stream_error_codec_44.helptext", [[You are trying to play something that the streaming API of GMod (and so the radio) does not support.

These things will NOT work:
	- HTML pages that play sound.
	- Flash players/games/applications that are playing sound.
	- Anything that requires any kind of login to access.
	- Anything that is not public.
	- Sound scripts or sound properties.
	- Broken files or unsupported formats. (See below.)

These things will work:
	- URLs to sound files (aka. DIRECT download).
	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
	- URLs inside these playlists files.
	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
	- You may have to install addional codices to your OS.
	- Formats that are listed below.

Supported formats:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV files must be not self-looping ingame as the API does not support these.]])


-- ================================================================================
-- Sub Category:  error.stream_error_create_33
-- ================================================================================

-- Current: Couldn't create the file
LOCALE:Set("error.stream_error_create_33.description", [[Couldn't create the file]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_create_33.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_decode_38
-- ================================================================================

-- Current: The channel is a 'decoding channel'
LOCALE:Set("error.stream_error_decode_38.description", [[The channel is a 'decoding channel']])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_decode_38.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_denied_49
-- ================================================================================

-- Current: Access denied
LOCALE:Set("error.stream_error_denied_49.description", [[Access denied]])

-- Current:
--  | Can not access the resource. Login credentials required, but not supported.
--  | 
--  | CAUTION: Do not try to access private resources! Credentials could leak to other connected players or the server!
--  | 
--  | Better use public resources only.
LOCALE:Set("error.stream_error_denied_49.helptext", [[Can not access the resource. Login credentials required, but not supported.

CAUTION: Do not try to access private resources! Credentials could leak to other connected players or the server!

Better use public resources only.]])


-- ================================================================================
-- Sub Category:  error.stream_error_device_23
-- ================================================================================

-- Current: Illegal device number
LOCALE:Set("error.stream_error_device_23.description", [[Illegal device number]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_device_23.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_driver_3
-- ================================================================================

-- Current: Can't find a free/valid driver
LOCALE:Set("error.stream_error_driver_3.description", [[Can't find a free/valid driver]])

-- Current: Something is wrong with your sound hardware or your sound drivers.
LOCALE:Set("error.stream_error_driver_3.helptext", [[Something is wrong with your sound hardware or your sound drivers.]])


-- ================================================================================
-- Sub Category:  error.stream_error_dropbox_no_path_130000
-- ================================================================================

-- Current: [Dropbox] Url has no path
LOCALE:Set("error.stream_error_dropbox_no_path_130000.description", [[[Dropbox] Url has no path]])

-- Current: Make sure your Dropbox has a valid path in it.
LOCALE:Set("error.stream_error_dropbox_no_path_130000.helptext", [[Make sure your Dropbox has a valid path in it.]])


-- ================================================================================
-- Sub Category:  error.stream_error_dx_39
-- ================================================================================

-- Current: A sufficient DirectX version is not installed
LOCALE:Set("error.stream_error_dx_39.description", [[A sufficient DirectX version is not installed]])

-- Current:
--  | Something is wrong with your sound hardware or your sound drivers.
--  | DirectX seems to be outdated or not installed.
LOCALE:Set("error.stream_error_dx_39.helptext", [[Something is wrong with your sound hardware or your sound drivers.
DirectX seems to be outdated or not installed.]])


-- ================================================================================
-- Sub Category:  error.stream_error_empty_31
-- ================================================================================

-- Current: The MOD music has no sequence data
LOCALE:Set("error.stream_error_empty_31.description", [[The MOD music has no sequence data]])

-- Current:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
LOCALE:Set("error.stream_error_empty_31.helptext", [[You are trying to play something that the streaming API of GMod (and so the radio) does not support.

These things will NOT work:
	- HTML pages that play sound.
	- Flash players/games/applications that are playing sound.
	- Anything that requires any kind of login to access.
	- Anything that is not public.
	- Sound scripts or sound properties.
	- Broken files or unsupported formats. (See below.)

These things will work:
	- URLs to sound files (aka. DIRECT download).
	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
	- URLs inside these playlists files.
	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
	- You may have to install addional codices to your OS.
	- Formats that are listed below.

Supported formats:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV files must be not self-looping ingame as the API does not support these.]])


-- ================================================================================
-- Sub Category:  error.stream_error_ended_45
-- ================================================================================

-- Current: The channel/file has ended
LOCALE:Set("error.stream_error_ended_45.description", [[The channel/file has ended]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_ended_45.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_fileform_41
-- ================================================================================

-- Current: Unsupported file format
LOCALE:Set("error.stream_error_fileform_41.description", [[Unsupported file format]])

-- Current:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
LOCALE:Set("error.stream_error_fileform_41.helptext", [[You are trying to play something that the streaming API of GMod (and so the radio) does not support.

These things will NOT work:
	- HTML pages that play sound.
	- Flash players/games/applications that are playing sound.
	- Anything that requires any kind of login to access.
	- Anything that is not public.
	- Sound scripts or sound properties.
	- Broken files or unsupported formats. (See below.)

These things will work:
	- URLs to sound files (aka. DIRECT download).
	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
	- URLs inside these playlists files.
	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
	- You may have to install addional codices to your OS.
	- Formats that are listed below.

Supported formats:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV files must be not self-looping ingame as the API does not support these.]])


-- ================================================================================
-- Sub Category:  error.stream_error_fileopen_2
-- ================================================================================

-- Current: Can't open the file
LOCALE:Set("error.stream_error_fileopen_2.description", [[Can't open the file]])

-- Current:
--  | There was no file or content found at the given path.
--  | 
--  | If you try to play an online file:
--  | 	- Do not forget the protocol prefix such as 'http://'.
--  | 	- Make sure the file exist at the given URL. It should be downloadable.
--  | 	- Make sure the format is supported and the file is not broken. (See below.)
--  | 
--  | If you try to play a local file:
--  | 	- Make sure the file exist at the given path.
--  | 	- Make sure the file is readable for Garry's Mod.
--  | 	- The path must be relative your "<path_to_game>/garrysmod/sound/" folder. (See below.)
--  | 	- The file must be in "<path_to_game>/garrysmod/sound/" folder. (See below.)
--  | 	- You can play mounted stuff in "<path_to_game>/garrysmod/sound/".
--  | 	- You can not play sound scripts or sound properties.
--  | 	- Make sure the format is supported and the file is not broken. (See below.)
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping in game as the API does not support these.
--  | 
--  | How local or mounted file paths work:
--  | 	- If you have a file located "<path_to_game>/garrysmod/sound/mymusic/song.mp3" you access it with these urls:
--  | 	* file://mymusic/song.mp3
--  | 	* mymusic/song.mp3"
--  | 
--  | 	- For files in "<path_to_game>/garrysmod/sound/filename.mp3" you get them like this:
--  | 	* file://filename.mp3
--  | 	* filename.mp3
--  | 
--  | 	- Files outside the game folder are forbidden to be accessed by the game.
--  | 	- Do not enter absolute paths.
--  | 	- Only people who also have the same file localed there, will be able to hear the music too.
--  | 	- Create folders if they are missing.
LOCALE:Set("error.stream_error_fileopen_2.helptext", [[There was no file or content found at the given path.

If you try to play an online file:
	- Do not forget the protocol prefix such as 'http://'.
	- Make sure the file exist at the given URL. It should be downloadable.
	- Make sure the format is supported and the file is not broken. (See below.)

If you try to play a local file:
	- Make sure the file exist at the given path.
	- Make sure the file is readable for Garry's Mod.
	- The path must be relative your "<path_to_game>/garrysmod/sound/" folder. (See below.)
	- The file must be in "<path_to_game>/garrysmod/sound/" folder. (See below.)
	- You can play mounted stuff in "<path_to_game>/garrysmod/sound/".
	- You can not play sound scripts or sound properties.
	- Make sure the format is supported and the file is not broken. (See below.)

Supported formats:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV files must be not self-looping in game as the API does not support these.

How local or mounted file paths work:
	- If you have a file located "<path_to_game>/garrysmod/sound/mymusic/song.mp3" you access it with these urls:
	* file://mymusic/song.mp3
	* mymusic/song.mp3"

	- For files in "<path_to_game>/garrysmod/sound/filename.mp3" you get them like this:
	* file://filename.mp3
	* filename.mp3

	- Files outside the game folder are forbidden to be accessed by the game.
	- Do not enter absolute paths.
	- Only people who also have the same file localed there, will be able to hear the music too.
	- Create folders if they are missing.]])


-- ================================================================================
-- Sub Category:  error.stream_error_format_6
-- ================================================================================

-- Current: Unsupported sample format
LOCALE:Set("error.stream_error_format_6.description", [[Unsupported sample format]])

-- Current:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
LOCALE:Set("error.stream_error_format_6.helptext", [[You are trying to play something that the streaming API of GMod (and so the radio) does not support.

These things will NOT work:
	- HTML pages that play sound.
	- Flash players/games/applications that are playing sound.
	- Anything that requires any kind of login to access.
	- Anything that is not public.
	- Sound scripts or sound properties.
	- Broken files or unsupported formats. (See below.)

These things will work:
	- URLs to sound files (aka. DIRECT download).
	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
	- URLs inside these playlists files.
	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
	- You may have to install addional codices to your OS.
	- Formats that are listed below.

Supported formats:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV files must be not self-looping ingame as the API does not support these.]])


-- ================================================================================
-- Sub Category:  error.stream_error_freq_25
-- ================================================================================

-- Current: Illegal sample rate
LOCALE:Set("error.stream_error_freq_25.description", [[Illegal sample rate]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_freq_25.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_handle_5
-- ================================================================================

-- Current: Invalid handle
LOCALE:Set("error.stream_error_handle_5.description", [[Invalid handle]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_handle_5.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_illparam_20
-- ================================================================================

-- Current: An illegal parameter was specified
LOCALE:Set("error.stream_error_illparam_20.description", [[An illegal parameter was specified]])

-- Current:
--  | Something went wrong with parsing the URL.
--  | It could have been blocked by the server to prevent abuse.
--  | 
--  | Please talk to an admin about this before you report this issue.
LOCALE:Set("error.stream_error_illparam_20.helptext", [[Something went wrong with parsing the URL.
It could have been blocked by the server to prevent abuse.

Please talk to an admin about this before you report this issue.]])


-- ================================================================================
-- Sub Category:  error.stream_error_illtype_19
-- ================================================================================

-- Current: An illegal type was specified
LOCALE:Set("error.stream_error_illtype_19.description", [[An illegal type was specified]])

-- Current:
--  | Something went wrong with parsing the URL.
--  | It could have been blocked by the server to prevent abuse.
--  | 
--  | Please talk to an admin about this before you report this issue.
LOCALE:Set("error.stream_error_illtype_19.helptext", [[Something went wrong with parsing the URL.
It could have been blocked by the server to prevent abuse.

Please talk to an admin about this before you report this issue.]])


-- ================================================================================
-- Sub Category:  error.stream_error_init_8
-- ================================================================================

-- Current: BASS_Init has not been successfully called
LOCALE:Set("error.stream_error_init_8.description", [[BASS_Init has not been successfully called]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_init_8.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_mem_1
-- ================================================================================

-- Current: Memory Error
LOCALE:Set("error.stream_error_mem_1.description", [[Memory Error]])

-- Current:
--  | A memory error is always bad.
--  | You proably ran out of it.
LOCALE:Set("error.stream_error_mem_1.helptext", [[A memory error is always bad.
You proably ran out of it.]])


-- ================================================================================
-- Sub Category:  error.stream_error_missing_gm_bass3_1020
-- ================================================================================

-- Current: GM_BASS3 is missing
LOCALE:Set("error.stream_error_missing_gm_bass3_1020.description", [[GM_BASS3 is missing]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_missing_gm_bass3_1020.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_no3d_21
-- ================================================================================

-- Current: No 3D support
LOCALE:Set("error.stream_error_no3d_21.description", [[No 3D support]])

-- Current:
--  | Something is wrong with your sound hardware or your sound drivers.
--  | It does not support 3D world sound.
LOCALE:Set("error.stream_error_no3d_21.helptext", [[Something is wrong with your sound hardware or your sound drivers.
It does not support 3D world sound.]])


-- ================================================================================
-- Sub Category:  error.stream_error_nochan_18
-- ================================================================================

-- Current: Can't get a free channel
LOCALE:Set("error.stream_error_nochan_18.description", [[Can't get a free channel]])

-- Current:
--  | A memory error is always bad.
--  | You proably ran out of it.
LOCALE:Set("error.stream_error_nochan_18.helptext", [[A memory error is always bad.
You proably ran out of it.]])


-- ================================================================================
-- Sub Category:  error.stream_error_noeax_22
-- ================================================================================

-- Current: No EAX support
LOCALE:Set("error.stream_error_noeax_22.description", [[No EAX support]])

-- Current:
--  | Something is wrong with your sound hardware or your sound drivers.
--  | It does not support EAX-effects.
LOCALE:Set("error.stream_error_noeax_22.helptext", [[Something is wrong with your sound hardware or your sound drivers.
It does not support EAX-effects.]])


-- ================================================================================
-- Sub Category:  error.stream_error_nofx_34
-- ================================================================================

-- Current: Effects are not available
LOCALE:Set("error.stream_error_nofx_34.description", [[Effects are not available]])

-- Current:
--  | Something is wrong with your sound hardware or your sound drivers.
--  | It does not support EAX-effects.
LOCALE:Set("error.stream_error_nofx_34.helptext", [[Something is wrong with your sound hardware or your sound drivers.
It does not support EAX-effects.]])


-- ================================================================================
-- Sub Category:  error.stream_error_nohw_29
-- ================================================================================

-- Current: No hardware voices available
LOCALE:Set("error.stream_error_nohw_29.description", [[No hardware voices available]])

-- Current: Something is wrong with your sound hardware. Out of memory?
LOCALE:Set("error.stream_error_nohw_29.helptext", [[Something is wrong with your sound hardware. Out of memory?]])


-- ================================================================================
-- Sub Category:  error.stream_error_nonet_32
-- ================================================================================

-- Current: No internet connection could be opened
LOCALE:Set("error.stream_error_nonet_32.description", [[No internet connection could be opened]])

-- Current:
--  | You internet connection is not working.
--  | Please check your network devices and your firewall.
LOCALE:Set("error.stream_error_nonet_32.helptext", [[You internet connection is not working.
Please check your network devices and your firewall.]])


-- ================================================================================
-- Sub Category:  error.stream_error_noplay_24
-- ================================================================================

-- Current: Not playing
LOCALE:Set("error.stream_error_noplay_24.description", [[Not playing]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_noplay_24.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_notaudio_17
-- ================================================================================

-- Current: File does not contain audio
LOCALE:Set("error.stream_error_notaudio_17.description", [[File does not contain audio]])

-- Current:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
LOCALE:Set("error.stream_error_notaudio_17.helptext", [[You are trying to play something that the streaming API of GMod (and so the radio) does not support.

These things will NOT work:
	- HTML pages that play sound.
	- Flash players/games/applications that are playing sound.
	- Anything that requires any kind of login to access.
	- Anything that is not public.
	- Sound scripts or sound properties.
	- Broken files or unsupported formats. (See below.)

These things will work:
	- URLs to sound files (aka. DIRECT download).
	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
	- URLs inside these playlists files.
	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
	- You may have to install addional codices to your OS.
	- Formats that are listed below.

Supported formats:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV files must be not self-looping ingame as the API does not support these.]])


-- ================================================================================
-- Sub Category:  error.stream_error_notavail_37
-- ================================================================================

-- Current: Requested data/action is not available
LOCALE:Set("error.stream_error_notavail_37.description", [[Requested data/action is not available]])

-- Current:
--  | Your sound driver/interface was lost.
--  | 
--  | To fix it you need to do this:
--  | - Plugin your speakers or head phones.
--  | - Enable the sound device.
--  | - Restart the game. Do not just disconnect!
--  | - Restart your PC, if it still not works.
LOCALE:Set("error.stream_error_notavail_37.helptext", [[Your sound driver/interface was lost.

To fix it you need to do this:
- Plugin your speakers or head phones.
- Enable the sound device.
- Restart the game. Do not just disconnect!
- Restart your PC, if it still not works.]])


-- ================================================================================
-- Sub Category:  error.stream_error_notfile_27
-- ================================================================================

-- Current: The stream is not a file stream
LOCALE:Set("error.stream_error_notfile_27.description", [[The stream is not a file stream]])

-- Current:
--  | There was no file or content found at the given path.
--  | 
--  | If you try to play an online file:
--  | 	- Do not forget the protocol prefix such as 'http://'.
--  | 	- Make sure the file exist at the given URL. It should be downloadable.
--  | 	- Make sure the format is supported and the file is not broken. (See below.)
--  | 
--  | If you try to play a local file:
--  | 	- Make sure the file exist at the given path.
--  | 	- Make sure the file is readable for Garry's Mod.
--  | 	- The path must be relative your "<path_to_game>/garrysmod/sound/" folder. (See below.)
--  | 	- The file must be in "<path_to_game>/garrysmod/sound/" folder. (See below.)
--  | 	- You can play mounted stuff in "<path_to_game>/garrysmod/sound/".
--  | 	- You can not play sound scripts or sound properties.
--  | 	- Make sure the format is supported and the file is not broken. (See below.)
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping in game as the API does not support these.
--  | 
--  | How local or mounted file paths work:
--  | 	- If you have a file located "<path_to_game>/garrysmod/sound/mymusic/song.mp3" you access it with these urls:
--  | 	* file://mymusic/song.mp3
--  | 	* mymusic/song.mp3"
--  | 
--  | 	- For files in "<path_to_game>/garrysmod/sound/filename.mp3" you get them like this:
--  | 	* file://filename.mp3
--  | 	* filename.mp3
--  | 
--  | 	- Files outside the game folder are forbidden to be accessed by the game.
--  | 	- Do not enter absolute paths.
--  | 	- Only people who also have the same file localed there, will be able to hear the music too.
--  | 	- Create folders if they are missing.
LOCALE:Set("error.stream_error_notfile_27.helptext", [[There was no file or content found at the given path.

If you try to play an online file:
	- Do not forget the protocol prefix such as 'http://'.
	- Make sure the file exist at the given URL. It should be downloadable.
	- Make sure the format is supported and the file is not broken. (See below.)

If you try to play a local file:
	- Make sure the file exist at the given path.
	- Make sure the file is readable for Garry's Mod.
	- The path must be relative your "<path_to_game>/garrysmod/sound/" folder. (See below.)
	- The file must be in "<path_to_game>/garrysmod/sound/" folder. (See below.)
	- You can play mounted stuff in "<path_to_game>/garrysmod/sound/".
	- You can not play sound scripts or sound properties.
	- Make sure the format is supported and the file is not broken. (See below.)

Supported formats:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV files must be not self-looping in game as the API does not support these.

How local or mounted file paths work:
	- If you have a file located "<path_to_game>/garrysmod/sound/mymusic/song.mp3" you access it with these urls:
	* file://mymusic/song.mp3
	* mymusic/song.mp3"

	- For files in "<path_to_game>/garrysmod/sound/filename.mp3" you get them like this:
	* file://filename.mp3
	* filename.mp3

	- Files outside the game folder are forbidden to be accessed by the game.
	- Do not enter absolute paths.
	- Only people who also have the same file localed there, will be able to hear the music too.
	- Create folders if they are missing.]])


-- ================================================================================
-- Sub Category:  error.stream_error_position_7
-- ================================================================================

-- Current: Invalid position
LOCALE:Set("error.stream_error_position_7.description", [[Invalid position]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_position_7.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_protocol_48
-- ================================================================================

-- Current: Unsupported protocol
LOCALE:Set("error.stream_error_protocol_48.description", [[Unsupported protocol]])

-- Current:
--  | Something went wrong with parsing the URL.
--  | It could have been blocked by the server to prevent abuse.
--  | 
--  | Please talk to an admin about this before you report this issue.
LOCALE:Set("error.stream_error_protocol_48.helptext", [[Something went wrong with parsing the URL.
It could have been blocked by the server to prevent abuse.

Please talk to an admin about this before you report this issue.]])


-- ================================================================================
-- Sub Category:  error.stream_error_reinit_11
-- ================================================================================

-- Current: Device needs to be reinitialized
LOCALE:Set("error.stream_error_reinit_11.description", [[Device needs to be reinitialized]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_reinit_11.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_shoutcast_no_id_120000
-- ================================================================================

-- Current: [SHOUTcast] Invalid stream ID
LOCALE:Set("error.stream_error_shoutcast_no_id_120000.description", [[[SHOUTcast] Invalid stream ID]])

-- Current:
--  | An invalid stream ID was given.
--  | 
--  | Notes:
--  | 	- Make sure you enter a URL of an existing SHOUTcast stream.
--  | 	- The URL should look like this shoutcast://123456
--  | 	- Only numbers are supported.
LOCALE:Set("error.stream_error_shoutcast_no_id_120000.helptext", [[An invalid stream ID was given.

Notes:
	- Make sure you enter a URL of an existing SHOUTcast stream.
	- The URL should look like this shoutcast://123456
	- Only numbers are supported.]])


-- ================================================================================
-- Sub Category:  error.stream_error_speaker_42
-- ================================================================================

-- Current: Unavailable speaker
LOCALE:Set("error.stream_error_speaker_42.description", [[Unavailable speaker]])

-- Current:
--  | Something is wrong with your sound hardware or your sound drivers.
--  | Do you even have speakers?
LOCALE:Set("error.stream_error_speaker_42.helptext", [[Something is wrong with your sound hardware or your sound drivers.
Do you even have speakers?]])


-- ================================================================================
-- Sub Category:  error.stream_error_ssl_10
-- ================================================================================

-- Current: SSL/HTTPS support isn't available
LOCALE:Set("error.stream_error_ssl_10.description", [[SSL/HTTPS support isn't available]])

-- Current:
--  | The SSL handshake for HTTPS did failed to validate the connection.
--  | Please check the URL being legit and your operating system to be up to date.
LOCALE:Set("error.stream_error_ssl_10.helptext", [[The SSL handshake for HTTPS did failed to validate the connection.
Please check the URL being legit and your operating system to be up to date.]])


-- ================================================================================
-- Sub Category:  error.stream_error_start_9
-- ================================================================================

-- Current: BASS_Start has not been successfully called
LOCALE:Set("error.stream_error_start_9.description", [[BASS_Start has not been successfully called]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_start_9.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_timeout_40
-- ================================================================================

-- Current: Connection timedout
LOCALE:Set("error.stream_error_timeout_40.description", [[Connection timedout]])

-- Current:
--  | The connection seems being slow. Just try again in a few minutes.
--  | If it does not work, the server you are trying to stream from is available.
LOCALE:Set("error.stream_error_timeout_40.helptext", [[The connection seems being slow. Just try again in a few minutes.
If it does not work, the server you are trying to stream from is available.]])


-- ================================================================================
-- Sub Category:  error.stream_error_unknown_-1
-- ================================================================================

-- Current: Unknown Error
LOCALE:Set("error.stream_error_unknown_-1.description", [[Unknown Error]])

-- Current:
--  | The exact cause of this error is unknown.
--  | 
--  | This error is usually caused by:
--  | 	- Invalid file pathes or URLs without the protocol prefix such as 'http://'.
--  | 	- Attempting to play self-looping *.WAV files.
LOCALE:Set("error.stream_error_unknown_-1.helptext", [[The exact cause of this error is unknown.

This error is usually caused by:
	- Invalid file pathes or URLs without the protocol prefix such as 'http://'.
	- Attempting to play self-looping *.WAV files.]])


-- ================================================================================
-- Sub Category:  error.stream_error_unstreamable_47
-- ================================================================================

-- Current: Unstreamable file
LOCALE:Set("error.stream_error_unstreamable_47.description", [[Unstreamable file]])

-- Current:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
LOCALE:Set("error.stream_error_unstreamable_47.helptext", [[You are trying to play something that the streaming API of GMod (and so the radio) does not support.

These things will NOT work:
	- HTML pages that play sound.
	- Flash players/games/applications that are playing sound.
	- Anything that requires any kind of login to access.
	- Anything that is not public.
	- Sound scripts or sound properties.
	- Broken files or unsupported formats. (See below.)

These things will work:
	- URLs to sound files (aka. DIRECT download).
	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
	- URLs inside these playlists files.
	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
	- You may have to install addional codices to your OS.
	- Formats that are listed below.

Supported formats:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV files must be not self-looping ingame as the API does not support these.]])


-- ================================================================================
-- Sub Category:  error.stream_error_url_blocked_1001
-- ================================================================================

-- Current: This URL is blocked on this server
LOCALE:Set("error.stream_error_url_blocked_1001.description", [[This URL is blocked on this server]])

-- Current:
--  | The server does not allow playback of this URL to prevent abuse. It has been blocked by external code.
--  | 
--  | CAUTION: Please don't ask to have this block disabled or removed. It is there for your own security. Ask your admin for details.
LOCALE:Set("error.stream_error_url_blocked_1001.helptext", [[The server does not allow playback of this URL to prevent abuse. It has been blocked by external code.

CAUTION: Please don't ask to have this block disabled or removed. It is there for your own security. Ask your admin for details.]])


-- ================================================================================
-- Sub Category:  error.stream_error_url_not_whitelisted_1000
-- ================================================================================

-- Current: This URL is not whitelisted on this server
LOCALE:Set("error.stream_error_url_not_whitelisted_1000.description", [[This URL is not whitelisted on this server]])

-- Current:
--  | The server does not allow playback of this URL to prevent abuse.
--  | You can ask an admin to whitelist this URL by adding it to the playlists.
--  | 
--  | CAUTION: Please don't ask to have the whitelist disabled or removed. It is there for your own security. Ask your admin for details.
LOCALE:Set("error.stream_error_url_not_whitelisted_1000.helptext", [[The server does not allow playback of this URL to prevent abuse.
You can ask an admin to whitelist this URL by adding it to the playlists.

CAUTION: Please don't ask to have the whitelist disabled or removed. It is there for your own security. Ask your admin for details.]])


-- ================================================================================
-- Sub Category:  error.stream_error_version_43
-- ================================================================================

-- Current: Invalid BASS version (used by add-ons)
LOCALE:Set("error.stream_error_version_43.description", [[Invalid BASS version (used by add-ons)]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_version_43.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_wire_advout_disabled_1010
-- ================================================================================

-- Current: Advanced outputs are disabled
LOCALE:Set("error.stream_error_wire_advout_disabled_1010.description", [[Advanced outputs are disabled]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_error_wire_advout_disabled_1010.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])


-- ================================================================================
-- Sub Category:  error.stream_error_youtube_unsupported_110000
-- ================================================================================

-- Current: [YouTube] YouTube is not supported
LOCALE:Set("error.stream_error_youtube_unsupported_110000.description", [[[YouTube] YouTube is not supported]])

-- Current:
--  | YouTube is not supported. Please use other media sources.
--  | You can use a Youtube to MP3 converter, but it is not recommended.
--  | 
--  | Notes:
--  | 	- Reliable YouTube support can't be added. It is impossible.
--  | 	- Please, don't ask me about it.
--  | 	- View the online help link for more information.
LOCALE:Set("error.stream_error_youtube_unsupported_110000.helptext", [[YouTube is not supported. Please use other media sources.
You can use a Youtube to MP3 converter, but it is not recommended.

Notes:
	- Reliable YouTube support can't be added. It is impossible.
	- Please, don't ask me about it.
	- View the online help link for more information.]])


-- ================================================================================
-- Sub Category:  error.stream_ok_0
-- ================================================================================

-- Current: OK
LOCALE:Set("error.stream_ok_0.description", [[OK]])

-- Current: Everything should be fine. You should not see this.
LOCALE:Set("error.stream_ok_0.helptext", [[Everything should be fine. You should not see this.]])


-- ================================================================================
-- Sub Category:  error.stream_sound_stopped_1200
-- ================================================================================

-- Current: The sound has been stopped
LOCALE:Set("error.stream_sound_stopped_1200.description", [[The sound has been stopped]])

-- Current:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
LOCALE:Set("error.stream_sound_stopped_1200.helptext", [[There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!]])

-- This file returns true, so we know it has been loaded properly
return true

