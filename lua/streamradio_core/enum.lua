StreamRadioLib.STREAM_PLAYMODE_STOP = 0
StreamRadioLib.STREAM_PLAYMODE_PAUSE = 1
StreamRadioLib.STREAM_PLAYMODE_PLAY = 2
StreamRadioLib.STREAM_PLAYMODE_PLAY_RESTART = 3

-- Placeholder for Blocked URLs with non-Keyboard chars (legacy)
StreamRadioLib.BlockedURLCodeSequence = string.char(124, 245, 142, 188, 5, 6, 2, 1, 2, 54, 12, 7, 5)
StreamRadioLib.BlockedURLCode = string.format("__blocked_url_replaced_with_special_sequence___[%s]___pls_ignore_this!__", StreamRadioLib.BlockedURLCodeSequence)

StreamRadioLib.PLAYBACK_LOOP_MODE_NONE = 0
StreamRadioLib.PLAYBACK_LOOP_MODE_SONG = 1
StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST = 2


StreamRadioLib.EDITOR_ERROR_OK = 0
StreamRadioLib.EDITOR_ERROR_WRITE_OK = 1
StreamRadioLib.EDITOR_ERROR_READ_OK = 2
StreamRadioLib.EDITOR_ERROR_FILES_OK = 3
StreamRadioLib.EDITOR_ERROR_DIR_OK = 4
StreamRadioLib.EDITOR_ERROR_DEL_OK = 5
StreamRadioLib.EDITOR_ERROR_COPY_OK = 6
StreamRadioLib.EDITOR_ERROR_RENAME_OK = 7

StreamRadioLib.EDITOR_ERROR_WPATH = 10
StreamRadioLib.EDITOR_ERROR_WDATA = 11
StreamRadioLib.EDITOR_ERROR_WFORMAT = 12
StreamRadioLib.EDITOR_ERROR_WVIRTUAL = 13
StreamRadioLib.EDITOR_ERROR_WRITE = 14

StreamRadioLib.EDITOR_ERROR_DIR_WRITE = 14
StreamRadioLib.EDITOR_ERROR_DIR_EXIST = 15
StreamRadioLib.EDITOR_ERROR_FILE_EXIST = 16
StreamRadioLib.EDITOR_ERROR_DEL_ACCES = 17

StreamRadioLib.EDITOR_ERROR_RPATH = 20
StreamRadioLib.EDITOR_ERROR_RDATA = 21
StreamRadioLib.EDITOR_ERROR_RFORMAT = 22
StreamRadioLib.EDITOR_ERROR_READ = 23

StreamRadioLib.EDITOR_ERROR_COPY_DIR = 30
StreamRadioLib.EDITOR_ERROR_COPY_EXIST = 31
StreamRadioLib.EDITOR_ERROR_COPY_WRITE = 32
StreamRadioLib.EDITOR_ERROR_COPY_READ = 33

StreamRadioLib.EDITOR_ERROR_RENAME_DIR = 40
StreamRadioLib.EDITOR_ERROR_RENAME_EXIST = 41
StreamRadioLib.EDITOR_ERROR_RENAME_WRITE = 42
StreamRadioLib.EDITOR_ERROR_RENAME_READ = 43

StreamRadioLib.EDITOR_ERROR_COMMUNITY_PROTECTED = 50
StreamRadioLib.EDITOR_ERROR_VIRTUAL_PROTECTED = 51
StreamRadioLib.EDITOR_ERROR_NOADMIN = 252
StreamRadioLib.EDITOR_ERROR_RESET = 253
StreamRadioLib.EDITOR_ERROR_UNIMPLEMENTED = 254
StreamRadioLib.EDITOR_ERROR_UNKNOWN = 255

local EditorErrors = {
	-- Code										// Error
	[StreamRadioLib.EDITOR_ERROR_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_WRITE_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_READ_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_FILES_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_DIR_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_DEL_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_COPY_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_RENAME_OK] = "OK",
	[StreamRadioLib.EDITOR_ERROR_WPATH] = "Invalid path!",
	[StreamRadioLib.EDITOR_ERROR_WDATA] = "Invalid data!",
	[StreamRadioLib.EDITOR_ERROR_WVIRTUAL] = "This virtual file is readonly!",
	[StreamRadioLib.EDITOR_ERROR_WFORMAT] = "Invalid file format!\nValid formats are: %s",
	[StreamRadioLib.EDITOR_ERROR_WRITE] = "Couldn't write the file!",
	[StreamRadioLib.EDITOR_ERROR_DIR_WRITE] = "Couldn't create the directory!",
	[StreamRadioLib.EDITOR_ERROR_DIR_EXIST] = "This directory already exists!",
	[StreamRadioLib.EDITOR_ERROR_FILE_EXIST] = "This file already exists!",
	[StreamRadioLib.EDITOR_ERROR_DEL_ACCES] = "Couldn't delete the file or the directory!",
	[StreamRadioLib.EDITOR_ERROR_RPATH] = "Invalid path!",
	[StreamRadioLib.EDITOR_ERROR_RDATA] = "Couldn't read the file!",
	[StreamRadioLib.EDITOR_ERROR_RFORMAT] = "Couldn't read the file format!",
	[StreamRadioLib.EDITOR_ERROR_READ] = "Couldn't read the file!",
	[StreamRadioLib.EDITOR_ERROR_COPY_DIR] = "You can't copy a directory",
	[StreamRadioLib.EDITOR_ERROR_COPY_EXIST] = "This file already exists!",
	[StreamRadioLib.EDITOR_ERROR_COPY_WRITE] = "Couldn't create the copy!",
	[StreamRadioLib.EDITOR_ERROR_COPY_READ] = "Couldn't read the source file!",
	[StreamRadioLib.EDITOR_ERROR_RENAME_DIR] = "You can't rename a directory",
	[StreamRadioLib.EDITOR_ERROR_RENAME_EXIST] = "This file already exists!",
	[StreamRadioLib.EDITOR_ERROR_RENAME_WRITE] = "Couldn't rename/move the file!",
	[StreamRadioLib.EDITOR_ERROR_RENAME_READ] = "Couldn't read the source file!",
	[StreamRadioLib.EDITOR_ERROR_COMMUNITY_PROTECTED] = "You can not edit files inside the community folder!",
	[StreamRadioLib.EDITOR_ERROR_VIRTUAL_PROTECTED] = "You can not add or remove files inside the virtual folders!",
	[StreamRadioLib.EDITOR_ERROR_NOADMIN] = "You need admin rights!",
	[StreamRadioLib.EDITOR_ERROR_UNIMPLEMENTED] = "This is not implemented!",
	[StreamRadioLib.EDITOR_ERROR_UNKNOWN] = "Unknown Error"
}

function StreamRadioLib.DecodeEditorErrorCode( err )
	err = tonumber(err) or StreamRadioLib.EDITOR_ERROR_UNKNOWN
	local errorText = EditorErrors[err] or EditorErrors[StreamRadioLib.EDITOR_ERROR_UNKNOWN]

	if (err == StreamRadioLib.EDITOR_ERROR_WFORMAT) then
		errorText = string.format(errorText, StreamRadioLib.VALID_FORMATS_EXTENSIONS_LIST)
	end

	return errorText
end

StreamRadioLib.TAG_META = 0
StreamRadioLib.TAG_HTTP = 1
StreamRadioLib.TAG_ICY = 2
StreamRadioLib.TAG_ID3 = 3
StreamRadioLib.TAG_MF = 4
StreamRadioLib.TAG_MP4 = 5
StreamRadioLib.TAG_APE = 6
StreamRadioLib.TAG_OGG = 7
StreamRadioLib.TAG_VENDOR = 8

StreamRadioLib.STREAM_URL_INFO = [[
You can enter this as a Stream URL:

Offline content:
   - A relative path inside your game's 'sound' folder.
   - The path must lead to a valid sound file.
   - Mounted content is supported and included.
   - Like: music/hl1_song3.mp3
   - NOT: sound/music/hl1_song3.mp3
   - NOT: C:/.../sound/music/hl1_song3.mp3

Online content:
   - An URL to an online file or stream.
   - The URL must lead to valid sound content.
   - No HTML, no Flash, no Videos, no YouTube
   - Like: https://stream.laut.fm/hiphop-forever
]]

StreamRadioLib.STREAM_URL_INFO = string.gsub(StreamRadioLib.STREAM_URL_INFO, "\r", "")
StreamRadioLib.STREAM_URL_INFO = string.Trim(StreamRadioLib.STREAM_URL_INFO)

StreamRadioLib.STREAM_URL_MAX_LEN_ONLINE = 480
StreamRadioLib.STREAM_URL_MAX_LEN_OFFLINE = 260

StreamRadioLib.LOG_STREAM_URL_ALL = 2
StreamRadioLib.LOG_STREAM_URL_ONLINE = 1
StreamRadioLib.LOG_STREAM_URL_NONE = 0

return true

