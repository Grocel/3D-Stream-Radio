local StreamRadioLib = StreamRadioLib

StreamRadioLib.Error = StreamRadioLib.Error or {}

local LIB = StreamRadioLib.Error
table.Empty(LIB)

local g_errorListById = {}
local g_errorListByName = {}

local g_emptyDescription = "Error {{ERROR_CODE}} is unknown"
local g_emptyHelpText = [[
There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).

Please report this! Include the URL and the error code in the report!
]]

local g_commonErrorFile = [[
There was no file or content found at the given path.

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
	- Create folders if they are missing.
]]

local g_commonErrorFileUrl = "https://steamcommunity.com/workshop/filedetails/discussion/246756300/523897277918001392/"

local g_commonErrorFormat = [[
You are trying to play something that the streaming API of GMod (and so the radio) does not support.

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
	*.WAV files must be not self-looping ingame as the API does not support these.
]]

local g_commonErrorFormatUrl = "https://steamcommunity.com/workshop/filedetails/discussion/246756300/523897277918028290/"

local g_commonErrorBrokenUrl = [[
Something went wrong with parsing the URL.
It could have been blocked by the server to prevent abuse.

Please talk to an admin about this before you report this issue.
]]

local function replacePlaceholder(subject, placeholder, value)
	subject = tostring(subject or "")
	placeholder = tostring(placeholder or "")
	value = tostring(value or "")

	return string.Replace(subject, placeholder, value)
end

local function cleanNewLines(str)
	str = string.gsub(str, "\r", "")
	str = string.Trim(str)

	return str
end

local function processErrorInfo(info)
	local id = info.id
	local name = info.name
	local description = info.description or ""
	local helptext = info.helptext or ""
	local helpurl = info.helpurl or ""

	description = replacePlaceholder(description, "{{ERROR_CODE}}", id)
	description = replacePlaceholder(description, "{{ERROR_NAME}}", name)

	helptext = replacePlaceholder(helptext, "{{ERROR_CODE}}", id)
	helptext = replacePlaceholder(helptext, "{{ERROR_NAME}}", name)
	helptext = replacePlaceholder(helptext, "{{ERROR_DESCRIPTION}}", description)
	helptext = replacePlaceholder(helptext, "{{ERROR_HELPURL}}", helpurl)

	helptext = cleanNewLines(helptext)

	info.description = description
	info.helptext = helptext
end

local function createUnknownErrorInfo(idOrName)
	local info = {}

	if isstring(idOrName) then
		info.id = LIB.STREAM_ERROR_UNKNOWN
		info.name = idOrName
	else
		info.id = idOrName
		info.name = "STREAM_ERROR_UNKNOWN"
	end

	info.description = g_emptyDescription
	info.helptext = g_emptyHelpText
	info.helpmenu = true

	processErrorInfo(info)
	return info
end


function LIB.AddStreamErrorCode(data)
	local id = data.id
	local name = data.name
	local description = data.description
	local helptext = data.helptext
	local helpurl = data.helpurl
	local helpmenu = data.helpmenu
	local userdata = data.userdata

	if not id then
		error("id is missing")
	end

	if not name or name == "" then
		error("name is missing or empty")
	end

	if helpmenu == nil then
		helpmenu = true
	end

	id = tonumber(id) or -1
	name = tostring(name)
	name = string.upper(name)

	local info = {
		id = id,
		name = name,
		helpmenu = helpmenu,
	}

	if userdata then
		info.userdata = table.Copy(userdata)
	end

	LIB[name] = id

	g_errorListById[id] = info
	g_errorListByName[name] = info

	LIB.AddStreamDescription(id, description)
	LIB.AddStreamErrorHelp(id, helptext, helpurl)
end

function LIB.AddStreamDescription(idOrName, description)
	local info = LIB.GetStreamErrorInfo(idOrName)
	if not info then
		return
	end

	local id = info.id
	local name = info.name

	description = tostring(description or "")

	if description == "" then
		description = g_emptyDescription
	end

	description = replacePlaceholder(description, "{{ERROR_CODE}}", id)
	description = replacePlaceholder(description, "{{ERROR_NAME}}", name)

	info.description = description
end

function LIB.AddStreamErrorHelp(idOrName, helptext, helpurl)
	local info = LIB.GetStreamErrorInfo(idOrName)
	if not info then
		return
	end

	local id = info.id
	local name = info.name
	local description = info.description

	helptext = tostring(helptext or "")
	helpurl = tostring(helpurl or "")

	if helptext == "" then
		helptext = g_emptyHelpText
	end

	helptext = replacePlaceholder(helptext, "{{ERROR_CODE}}", id)
	helptext = replacePlaceholder(helptext, "{{ERROR_NAME}}", name)
	helptext = replacePlaceholder(helptext, "{{ERROR_DESCRIPTION}}", description)
	helptext = replacePlaceholder(helptext, "{{ERROR_HELPURL}}", helpurl)

	helptext = cleanNewLines(helptext)

	info.helptext = helptext
	info.helpurl = helpurl
end

function LIB.GetStreamErrorInfo(idOrName)
	if not idOrName or idOrName == "" then
		idOrName = LIB.STREAM_ERROR_UNKNOWN
	end

	local errorList = nil

	if isstring(idOrName) then
		errorList = g_errorListByName
	else
		errorList = g_errorListById
	end

	local info = errorList[idOrName]
	if not info then
		info = createUnknownErrorInfo(idOrName)
	end

	return info
end

function LIB.GetStreamErrorId(idOrName)
	local info = LIB.GetStreamErrorInfo(idOrName)
	if not info then
		return nil
	end

	return info.id
end

function LIB.GetStreamErrorName(idOrName)
	local info = LIB.GetStreamErrorInfo(idOrName)
	if not info then
		return nil
	end

	return info.name
end

function LIB.GetStreamErrorDescription(idOrName)
	local info = LIB.GetStreamErrorInfo(idOrName)
	if not info then
		return nil
	end

	return info.description
end

LIB.AddStreamErrorCode({
	id = -1,
	name = "STREAM_ERROR_UNKNOWN",
	description = "Unknown Error",
	helptext = [[
The exact cause of this error is unknown.

This error is usually caused by:
	- Invalid file pathes or URLs without the protocol prefix such as 'http://'.
	- Attempting to play self-looping *.WAV files.
]],
})

LIB.AddStreamErrorCode({
	id = 0,
	name = "STREAM_OK",
	description = "OK",
	helpmenu = false,
	helptext = [[
Everything should be fine. You should not see this.
]],
})

LIB.AddStreamErrorCode({
	id = 1,
	name = "STREAM_ERROR_MEM",
	description = "Memory Error",
	helptext = [[
A memory error is always bad.
You proably ran out of it.
]],
})

LIB.AddStreamErrorCode({
	id = 2,
	name = "STREAM_ERROR_FILEOPEN",
	description = "Can't open the file",
	helptext = g_commonErrorFile,
	helpurl = g_commonErrorFileUrl
})

LIB.AddStreamErrorCode({
	id = 3,
	name = "STREAM_ERROR_DRIVER",
	description = "Can't find a free/valid driver",
	helptext = [[
Something is wrong with your sound hardware or your sound drivers.
]],
})

LIB.AddStreamErrorCode({
	id = 4,
	name = "STREAM_ERROR_BUFLOST",
	description = "The sample buffer was lost",
	helptext = [[
Your sound driver/interface was lost.

To fix it you need to do this:
- Plugin your speakers or head phones.
- Enable the sound device.
- Restart the game. Do not just disconnect!
- Restart your PC, if it still not works.
]],
})

LIB.AddStreamErrorCode({
	id = 5,
	name = "STREAM_ERROR_HANDLE",
	description = "Invalid handle",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 6,
	name = "STREAM_ERROR_FORMAT",
	description = "Unsupported sample format",
	helptext = g_commonErrorFormat,
	helpurl = g_commonErrorFormatUrl,
})

LIB.AddStreamErrorCode({
	id = 7,
	name = "STREAM_ERROR_POSITION",
	description = "Invalid position",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 8,
	name = "STREAM_ERROR_INIT",
	description = "BASS_Init has not been successfully called",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 9,
	name = "STREAM_ERROR_START",
	description = "BASS_Start has not been successfully called",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 10,
	name = "STREAM_ERROR_SSL",
	description = "SSL/HTTPS support isn't available",
	helptext =  [[
The SSL handshake for HTTPS did failed to validate the connection.
Please check the URL being legit and your operating system to be up to date.
]],
})

LIB.AddStreamErrorCode({
	id = 11,
	name = "STREAM_ERROR_REINIT",
	description = "Device needs to be reinitialized",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 14,
	name = "STREAM_ERROR_ALREADY",
	description = "Already initialized/paused/whatever",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 17,
	name = "STREAM_ERROR_NOTAUDIO",
	description = "File does not contain audio",
	helptext = g_commonErrorFormat,
	helpurl = g_commonErrorFormatUrl,
})

LIB.AddStreamErrorCode({
	id = 18,
	name = "STREAM_ERROR_NOCHAN",
	description = "Can't get a free channel",
	helptext = [[
A memory error is always bad.
You proably ran out of it.
]],
})

LIB.AddStreamErrorCode({
	id = 19,
	name = "STREAM_ERROR_ILLTYPE",
	description = "An illegal type was specified",
	helptext = g_commonErrorBrokenUrl,
})

LIB.AddStreamErrorCode({
	id = 20,
	name = "STREAM_ERROR_ILLPARAM",
	description = "An illegal parameter was specified",
	helptext = g_commonErrorBrokenUrl,
})

LIB.AddStreamErrorCode({
	id = 21,
	name = "STREAM_ERROR_NO3D",
	description = "No 3D support",
	helptext = [[
Something is wrong with your sound hardware or your sound drivers.
It does not support 3D world sound.
]],
})

LIB.AddStreamErrorCode({
	id = 22,
	name = "STREAM_ERROR_NOEAX",
	description = "No EAX support",
	helptext = [[
Something is wrong with your sound hardware or your sound drivers.
It does not support EAX-effects.
]],
})

LIB.AddStreamErrorCode({
	id = 23,
	name = "STREAM_ERROR_DEVICE",
	description = "Illegal device number",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 24,
	name = "STREAM_ERROR_NOPLAY",
	description = "Not playing",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 25,
	name = "STREAM_ERROR_FREQ",
	description = "Illegal sample rate",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 27,
	name = "STREAM_ERROR_NOTFILE",
	description = "The stream is not a file stream",
	helptext = g_commonErrorFile,
	helpurl = g_commonErrorFileUrl
})

LIB.AddStreamErrorCode({
	id = 29,
	name = "STREAM_ERROR_NOHW",
	description = "No hardware voices available",
	helptext = [[
Something is wrong with your sound hardware. Out of memory?
]],
})

LIB.AddStreamErrorCode({
	id = 31,
	name = "STREAM_ERROR_EMPTY",
	description = "The MOD music has no sequence data",
	helptext = g_commonErrorFormat,
	helpurl = g_commonErrorFormatUrl,
})

LIB.AddStreamErrorCode({
	id = 32,
	name = "STREAM_ERROR_NONET",
	description = "No internet connection could be opened",
	helptext = [[
You internet connection is not working.
Please check your network devices and your firewall.
]],
})

LIB.AddStreamErrorCode({
	id = 33,
	name = "STREAM_ERROR_CREATE",
	description = "Couldn't create the file",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 34,
	name = "STREAM_ERROR_NOFX",
	description = "Effects are not available",
	helptext = [[
Something is wrong with your sound hardware or your sound drivers.
It does not support EAX-effects.
]],
})

LIB.AddStreamErrorCode({
	id = 37,
	name = "STREAM_ERROR_NOTAVAIL",
	description = "Requested data/action is not available",
	helptext = [[
Your sound driver/interface was lost.

To fix it you need to do this:
- Plugin your speakers or head phones.
- Enable the sound device.
- Restart the game. Do not just disconnect!
- Restart your PC, if it still not works.
]],
})

LIB.AddStreamErrorCode({
	id = 38,
	name = "STREAM_ERROR_DECODE",
	description = "The channel is a 'decoding channel'",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 39,
	name = "STREAM_ERROR_DX",
	description = "A sufficient DirectX version is not installed",
	helptext = [[
Something is wrong with your sound hardware or your sound drivers.
DirectX seems to be outdated or not installed.
]],
})

LIB.AddStreamErrorCode({
	id = 40,
	name = "STREAM_ERROR_TIMEOUT",
	description = "Connection timedout",
	helptext = [[
The connection seems being slow. Just try again in a few minutes.
If it does not work, the server you are trying to stream from is available.
]],
})

LIB.AddStreamErrorCode({
	id = 41,
	name = "STREAM_ERROR_FILEFORM",
	description = "Unsupported file format",
	helptext = g_commonErrorFormat,
	helpurl = g_commonErrorFormatUrl,
})

LIB.AddStreamErrorCode({
	id = 42,
	name = "STREAM_ERROR_SPEAKER",
	description = "Unavailable speaker",
	helptext = [[
Something is wrong with your sound hardware or your sound drivers.
Do you even have speakers?
]],
})

LIB.AddStreamErrorCode({
	id = 43,
	name = "STREAM_ERROR_VERSION",
	description = "Invalid BASS version (used by add-ons)",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 44,
	name = "STREAM_ERROR_CODEC",
	description = "Codec is not available/supported",
	helptext = g_commonErrorFormat,
	helpurl = g_commonErrorFormatUrl,
})

LIB.AddStreamErrorCode({
	id = 45,
	name = "STREAM_ERROR_ENDED",
	description = "The channel/file has ended",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 46,
	name = "STREAM_ERROR_BUSY",
	description = "The device is busy",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 47,
	name = "STREAM_ERROR_UNSTREAMABLE",
	description = "Unstreamable file",
	helptext = g_commonErrorFormat,
	helpurl = g_commonErrorFormatUrl,
})

LIB.AddStreamErrorCode({
	id = 48,
	name = "STREAM_ERROR_PROTOCOL",
	description = "Unsupported protocol",
	helptext = g_commonErrorBrokenUrl,
})

LIB.AddStreamErrorCode({
	id = 49,
	name = "STREAM_ERROR_DENIED",
	description = "Access denied",
	helptext = [[
Can not access the resource. Login credentials required, but not supported.

CAUTION: Do not try to access private resources! Credentials could leak to other connected players or the server!

Better use public resources only.
]],
})


LIB.AddStreamErrorCode({
	id = 1000,
	name = "STREAM_ERROR_URL_NOT_WHITELISTED",
	description = "This URL is not whitelisted on this server",
	helpurl = "https://steamcommunity.com/workshop/filedetails/discussion/246756300/3884977551668761564/",
	helptext = [[
The server does not allow playback of this URL to prevent abuse.
You can ask an admin to whitelist this URL by adding it to the playlists.

CAUTION: Please don't ask to have the whitelist disabled or removed. It is there for your own security. Ask your admin for details.
]],
})

LIB.AddStreamErrorCode({
	id = 1001,
	name = "STREAM_ERROR_URL_BLOCKED",
	description = "This URL is blocked on this server",
	helpurl = "https://steamcommunity.com/workshop/filedetails/discussion/246756300/3884977551668761564/",
	helptext = [[
The server does not allow playback of this URL to prevent abuse. It has been blocked by external code.

CAUTION: Please don't ask to have this block disabled or removed. It is there for your own security. Ask your admin for details.
]],
})

LIB.AddStreamErrorCode({
	id = 1010,
	name = "STREAM_ERROR_WIRE_ADVOUT_DISABLED",
	description = "Advanced outputs are disabled",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 1020,
	name = "STREAM_ERROR_MISSING_GM_BASS3",
	description = "GM_BASS3 is missing",
	helptext = "",
})

LIB.AddStreamErrorCode({
	id = 1030,
	name = "STREAM_ERROR_BAD_DRIVE_LETTER_PATH",
	description = "Drive letter paths are not supported, use relative paths",
	helptext = [[
Do not use drive letter paths. Use relative paths instead.

A relative path never starts with a drive letter such as "C:/" or "D:/".

This is a relative path:
  music/hl1_song3.mp3

This is NOT a relative path:
  C:/Program Files (x86)/Steam/steamapps/common/GarrysMod/garrysmod/sound/music/hl1_song3.mp3
]],
})

LIB.AddStreamErrorCode({
	id = 1100,
	name = "PLAYLIST_ERROR_INVALID_FILE",
	description = "Invalid Playlist",
	helptext = [[
The Playlist file you are trying to load is invalid.

This could be the problem:
	- The playlist could not be found or read.
	- Its format is not supported.
	- It is broken.
	- It is empty.

Supported playlist formats:
	M3U, PLS, VDF, JSON

Playlists are located at "<path_to_game>/garrysmod/data/streamradio/playlists/".

Hint: Use the playlist editor to make playlists.
]],
	helpurl = "https://steamcommunity.com/workshop/filedetails/discussion/246756300/523897277917951293/",
})

LIB.AddStreamErrorCode({
	id = 1200,
	name = "STREAM_SOUND_STOPPED", -- triggered by "stopsound" concommand
	description = "The sound has been stopped",
	helpmenu = false,
	helptext = "",
})


if CLIENT then
	local function ShowErrorInfo( ply, cmd, args )
		local param = args[1]

		if not param or param == "" then
			MsgN("You need to enter a valid error code.")
			return
		end

		local errorcode = tonumber(param) or tostring(param)
		local errorInfo = LIB.GetStreamErrorInfo(errorcode)

		local id = errorInfo.id
		local name = errorInfo.name
		local description = errorInfo.description
		local helptext = errorInfo.helptext
		local helpurl = errorInfo.helpurl or ""

		if helpurl == "" then
			helpurl = "(no url)"
		end

		local format = [[
Getting info for error code "%s":

Id: %i
Name: %s
Description: %s

Help text:
%s

Help URL: %s
]]

		format = cleanNewLines(format)

		local errstr = string.format(
			format,
			errorcode,
			id,
			name,
			description,
			helptext,
			helpurl
		)

		local message = StreamRadioLib.AddonPrefix .. errstr
		MsgN(message)
	end

	concommand.Add( "info_streamradio_errorcode", ShowErrorInfo )
end

return true

