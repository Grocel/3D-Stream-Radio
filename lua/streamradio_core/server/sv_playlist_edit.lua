local StreamRadioLib = StreamRadioLib

StreamRadioLib.Editor = StreamRadioLib.Editor or {}

local LIB = StreamRadioLib.Editor
table.Empty(LIB)

local LIBNet = StreamRadioLib.Net
local LIBPrint = StreamRadioLib.Print

local pairs = pairs
local IsValid = IsValid
local string = string
local net = net
local ListenPath = ""

function LIB.GetPath( )
	return ListenPath
end

do
	local function StopLoading(ply, cmd, args)
		if not StreamRadioLib.Util.IsAdminForCMD(ply) then
			return
		end

		LIB.Reset(ply)
	end

	concommand.Add( "sv_streamradio_playlisteditor_reset", StopLoading )
end

StreamRadioLib.Hook.Add("PostCleanupMap", "reset_playlisteditor", function()
	LIB.Reset()
end)

local OK_CODES = {
	[StreamRadioLib.EDITOR_ERROR_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_WRITE_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_READ_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_FILES_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_DIR_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_DEL_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_RESET] = true
}

local function EditorLog(ply, msgstring, ...)
	msgstring = tostring(msgstring or "")
	if msgstring == "" then return end

	msgstring = LIBPrint.Format("PLAYLIST EDITOR - " .. msgstring, ...)

	LIBPrint.Log(ply, msgstring)
end

local function EditorError( ply, path, code )
	LIBNet.Start("Editor_Error")
	StreamRadioLib.NetSendEditorError( path, code )

	if ( IsValid( ply ) ) then
		net.Send( ply )
	else
		net.Broadcast( )
	end

	local ok = OK_CODES[code] or false

	if not ok then
		local errorString = StreamRadioLib.DecodeEditorErrorCode( code )

		EditorLog(ply, "User had an error at path '%s': %s (%d)", path, errorString, code)
	end

	return ok
end

function LIB.Error( ply, path, code )
	return EditorError( ply, path, code )
end

function LIB.Reset( ply )
	EditorError( ply, "*nopath*", StreamRadioLib.EDITOR_ERROR_OK )

	return EditorError( ply, "*nopath*", StreamRadioLib.EDITOR_ERROR_RESET )
end

function LIB.CreateDir( ply, path )
	path = StreamRadioLib.String.SanitizeFilepath(path)

	if string.match( path, "^community/" ) then
		local mode = StreamRadioLib.GetRebuildCommunityPlaylistsMode()

		if mode ~= 0 then
			return EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_COMMUNITY_PROTECTED)
		end
	end

	if StreamRadioLib.String.IsVirtualPath(path) then
		return EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_VIRTUAL_PROTECTED)
	end

	if StreamRadioLib.Filesystem.Exists(path, 0) then
		return EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_DIR_EXIST)
	end

	StreamRadioLib.Filesystem.CreateFolder(path, function(success)
		if not success then
			return EditorError( ply, path, StreamRadioLib.EDITOR_ERROR_DIR_WRITE )
		end

		EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_DIR_OK)
		EditorLog(ply, "User created the folder '%s'", path)
	end)
end

local FileTab = {}

function LIB.SaveAll( )
	for path, data in pairs( FileTab ) do
		LIB.Save( data["player"], path, data )
		FileTab[path] = nil
	end

	FileTab = {}
end

function LIB.Save( ply, path, data )
	path = StreamRadioLib.String.SanitizeFilepath(path)

	if path == "" then return EditorError(ply, "*nopath*", StreamRadioLib.EDITOR_ERROR_WPATH) end
	if not data then return EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_WDATA) end

	if string.match( path, "^community/" ) then
		local mode = StreamRadioLib.GetRebuildCommunityPlaylistsMode()

		if mode ~= 0 then
			return EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_COMMUNITY_PROTECTED)
		end
	end

	local format = data["format"]
	local canwrite = StreamRadioLib.Filesystem.CanWriteFormat(format)

	if not canwrite then
		if StreamRadioLib.String.IsVirtualPath(path) then
			return EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_WVIRTUAL)
		end

		return EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_WFORMAT)
	end

	data["format"] = nil
	data["player"] = nil

	StreamRadioLib.Filesystem.Write(path, format, data, function(success)
		if not success then
			return EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_WRITE)
		end

		EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_WRITE_OK)
		EditorLog(ply, "User saved the file '%s'", path)
	end)
end

function LIB.Remove(ply, path, type)
	path = StreamRadioLib.String.SanitizeFilepath(path)

	StreamRadioLib.Filesystem.Delete(path, type, function(success)
		if not success then
			return EditorError( ply, path, StreamRadioLib.EDITOR_ERROR_DEL_ACCES )
		end

		EditorError( ply, path, StreamRadioLib.EDITOR_ERROR_DEL_OK )
		EditorLog(ply, "User deleted the file '%s'", path)
	end)
end

function LIB.Copy( ply, path_old, path_new )
	path_old = StreamRadioLib.String.SanitizeFilepath(path_old)
	path_new = StreamRadioLib.String.SanitizeFilepath(path_new)

	return EditorError( ply, path_new, StreamRadioLib.EDITOR_ERROR_UNIMPLEMENTED )
end

function LIB.Rename( ply, path_old, path_new )
	path_old = StreamRadioLib.String.SanitizeFilepath(path_old)
	path_new = StreamRadioLib.String.SanitizeFilepath(path_new)

	return EditorError( ply, path_new, StreamRadioLib.EDITOR_ERROR_UNIMPLEMENTED )
end

function LIB.OpenFolder( ply, path )
	path = StreamRadioLib.String.SanitizeFilepath(path)
	if not IsValid(ply) then return false end

	local pairsname = "Editor_OpenFolder_" .. tostring(ply)
	StreamRadioLib.TimedpairsStop(pairsname)

	StreamRadioLib.Filesystem.Find(path, function(success, files)
		files = files or {}

		StreamRadioLib.TimedpairsStop(pairsname)
		StreamRadioLib.Timedpairs(pairsname, files, 1, function( k, v )
			if not IsValid(ply) then return false end
			if not istable(v) then return true end

			LIBNet.Start("Editor_Return_Files")
				StreamRadioLib.NetSendFileEditor(v.path, v.file, v.type, ListenPath)
			net.Send(ply)
		end, function()
			EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_FILES_OK)
		end)
	end)
end

function LIB.OpenFile( ply, path, type )
	path = StreamRadioLib.String.SanitizeFilepath(path)
	if path == "" then return EditorError( ply, "*nopath*", StreamRadioLib.EDITOR_ERROR_RPATH ) end

	local canread = StreamRadioLib.Filesystem.CanReadFormat(type)
	if not canread then return EditorError( ply, path, StreamRadioLib.EDITOR_ERROR_RFORMAT ) end

	StreamRadioLib.Filesystem.Read(path, type, function(success, data)
		if not IsValid(ply) then return end

		if not success then
			return EditorError( ply, path, StreamRadioLib.EDITOR_ERROR_READ )
		end

		local pairsname = "Editor_OpenFolder_" .. tostring(ply)

		StreamRadioLib.TimedpairsStop(pairsname)
		StreamRadioLib.Timedpairs(pairsname, data, 1, function( k, v )
			if not IsValid(ply) then return false end
			if not istable(v) then return true end

			LIBNet.Start("Editor_Return_Playlist")
				StreamRadioLib.NetSendPlaylistEditor( v.url, v.name, ListenPath )
			net.Send(ply)
		end, function()
			EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_READ_OK)
		end)
	end)
end

LIBNet.Receive( "Editor_Request_Files", function( len, ply )
	if not IsValid(ply) then return false end
	if not ply:IsAdmin() then return false end
	local path, name, type, parentpath = StreamRadioLib.NetReceiveFileEditor( )
	ListenPath = parentpath

	if StreamRadioLib.Filesystem.IsFolder(type) then
		LIB.OpenFolder( ply, path )
	else
		LIB.OpenFile( ply, path, type )
	end
end )

LIBNet.Receive( "Editor_Request_Playlist", function( len, ply )
	if not IsValid(ply) then return end
	if not ply:IsAdmin() then return EditorError(ply, path, StreamRadioLib.EDITOR_ERROR_NOADMIN) end

	local flag = net.ReadUInt( 4 )

	if ( flag == 0 ) then
		local path = net.ReadString( ) or ""
		LIB.CreateDir( ply, path )
	elseif ( flag == 1 ) then
		--Start
		local filepath = net.ReadString( ) or ""
		FileTab[filepath] = {}
	elseif ( flag == 2 ) then
		--Body
		local url, name, filepath = StreamRadioLib.NetReceivePlaylistEditor( )

		FileTab[filepath][#FileTab[filepath] + 1] = {
			url = url,
			name = name
		}
	elseif ( flag == 3 ) then
		--Finish
		local format = net.ReadUInt( 8 ) or 0
		local count = net.ReadUInt( 16 ) or 0
		local filepath = net.ReadString( ) or ""
		FileTab[filepath] = FileTab[filepath] or {}
		FileTab[filepath]["format"] = format
		FileTab[filepath]["player"] = ply
		LIB.SaveAll( )
	elseif ( flag == 4 ) then
		--Remove
		local format = net.ReadUInt( 8 ) or 0
		local filepath = net.ReadString( ) or ""
		FileTab[filepath] = nil
		LIB.Remove( ply, filepath, format )
	elseif ( flag == 5 ) then
		--Copy
		local path_old = net.ReadString( ) or ""
		local path_new = net.ReadString( ) or ""
		LIB.Copy( ply, path_old, path_new )
	elseif ( flag == 6 ) then
		--Rename/Move
		local path_old = net.ReadString( ) or ""
		local path_new = net.ReadString( ) or ""
		FileTab[path_old] = nil
		LIB.Rename( ply, path_old, path_new )
	end
end )
--CreateDir

return true

