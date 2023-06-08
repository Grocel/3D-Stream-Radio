StreamRadioLib.STREAM_PLAYMODE_STOP = 0
StreamRadioLib.STREAM_PLAYMODE_PAUSE = 1
StreamRadioLib.STREAM_PLAYMODE_PLAY = 2
StreamRadioLib.STREAM_PLAYMODE_PLAY_RESTART = 3

StreamRadioLib.STREAM_URLTYPE_FILE = 0
StreamRadioLib.STREAM_URLTYPE_CACHE = 1
StreamRadioLib.STREAM_URLTYPE_ONLINE = 2
StreamRadioLib.STREAM_URLTYPE_ONLINE_NOCACHE = 3


-- Placeholder for Blocked URLs with non-Keyboard chars
StreamRadioLib.BlockedURLCode = string.char(124, 245, 142, 188, 5, 6, 2, 1, 2, 54, 12, 7, 5) .. "___blocked_url"

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

StreamRadioLib.PLAYBACK_LOOP_MODE_NONE = 0
StreamRadioLib.PLAYBACK_LOOP_MODE_SONG = 1
StreamRadioLib.PLAYBACK_LOOP_MODE_PLAYLIST = 2

function StreamRadioLib.DecodeEditorErrorCode( err )
	err = tonumber(err) or StreamRadioLib.EDITOR_ERROR_UNKNOWN
	local errorText = EditorErrors[err] or EditorErrors[StreamRadioLib.EDITOR_ERROR_UNKNOWN]

	if (err == StreamRadioLib.EDITOR_ERROR_WFORMAT) then
		errorText = string.format(errorText, StreamRadioLib.VALID_FORMATS_EXTENSIONS_LIST)
	end

	return errorText
end

local Errors = {
	-- Code		// Error
	[-1] = "Unknown Error",
	[0] = "OK",
	[1] = "Memory Error",
	[2] = "Can't open the file",
	[3] = "Can't find a free/valid driver",
	[4] = "The sample buffer was lost",
	[5] = "Invalid handle",
	[6] = "Unsupported sample format",
	[7] = "Invalid position",
	[8] = "BASS_Init has not been successfully called",
	[9] = "BASS_Start has not been successfully called",
	[14] = "Already initialized/paused/whatever",
	[18] = "Can't get a free channel",
	[19] = "An illegal type was specified",
	[20] = "An illegal parameter was specified",
	[21] = "No 3D support",
	[22] = "No EAX support",
	[23] = "Illegal device number",
	[24] = "Not playing",
	[25] = "Illegal sample rate",
	[27] = "The stream is not a file stream",
	[29] = "No hardware voices available",
	[31] = "The MOD music has no sequence data",
	[32] = "No internet connection could be opened",
	[33] = "Couldn't create the file",
	[34] = "Effects are not available",
	[37] = "Requested data is not available",
	[38] = "The channel is a 'decoding channel'",
	[39] = "A sufficient DirectX version is not installed",
	[40] = "Connection timedout",
	[41] = "Unsupported file format",
	[42] = "Unavailable speaker",
	[43] = "Invalid BASS version (used by add-ons)",
	[44] = "Codec is not available/supported",
	[45] = "The channel/file has ended",

	[1000] = "Custom URLs are blocked on this server",
}

function StreamRadioLib.DecodeErrorCode(errorcode)
	errorcode = tonumber(errorcode or -1) or -1

	if BASS3 and BASS3.DecodeErrorCode and errorcode < 200 and errorcode >= -1 then
		return BASS3.DecodeErrorCode(errorcode)
	end

	if Errors[errorcode] then
		return Errors[errorcode]
	end

	local errordata = StreamRadioLib.Interface.GetErrorData(errorcode) or {}
	local errordesc = string.Trim(errordata.desc or "")

	if errordesc == "" then
		errordesc = Errors[-1]
	end

	if not errordata.interface then
		return errordesc
	end

	local iname = errordata.interface.name

	if errordata.subinterface then
		iname = iname .. "/" .. errordata.subinterface.name
	end

	errordesc = "[" .. iname .. "] " .. errordesc
	return errordesc
end

do
	local function ShowErrorInfo( ply, cmd, args )
		if ( not args[1] or ( args[1] == "" ) ) then
			StreamRadioLib.Msg(ply, "You need to enter a valid error code.")

			return
		end

		local err = tonumber( args[1] ) or -1
		local errstr = StreamRadioLib.DecodeErrorCode( err )
		local msgstring = StreamRadioLib.AddonPrefix .. "Error code " .. err .. " = " .. errstr
		StreamRadioLib.Msg( ply, msgstring )
	end

	concommand.Add( "info_streamradio_errorcode", ShowErrorInfo )
end