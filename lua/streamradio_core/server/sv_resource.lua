resource.AddWorkshop( "246756300" ) -- Workshop download

local g_staticDataDirectory = "data_static"

local function CopyFiles( dir )
	file.CreateDir( dir )
	local files, directories = file.Find(g_staticDataDirectory .. "/" .. dir .. "/*", "GAME")

	for _, f in ipairs(files or {}) do
		local filename = dir .. "/" .. f
		local fullpath = g_staticDataDirectory .. "/" .. filename

		if not file.Exists(fullpath, "GAME") then
			continue
		end

		file.Write(filename, file.Read(fullpath, "GAME") or "")
	end

	for _, d in ipairs(directories or {}) do
		CopyFiles(dir .. "/" .. d)
	end
end

do
	local function Rebuild_Playlists( ply, cmd, args )
		if not StreamRadioLib then return end
		if not StreamRadioLib.Loaded then return end

		if not StreamRadioLib.Util.IsAdminForCMD(ply) then
			StreamRadioLib.Print.Msg( ply, "You need to be an admin to rebuild the playlists." )
			return
		end

		CopyFiles( StreamRadioLib.DataDirectory .. "/playlists" )

		StreamRadioLib.Whitelist.BuildWhitelist()

		StreamRadioLib.Editor.Reset( ply )
		StreamRadioLib.Print.Msg( ply, "Playlists rebuilt" )
	end

	local function Rebuild_CommunityPlaylists( ply, cmd, args )
		if not StreamRadioLib then return end
		if not StreamRadioLib.Loaded then return end

		if not StreamRadioLib.Util.IsAdminForCMD(ply) then
			StreamRadioLib.Print.Msg( ply, "You need to be an admin to rebuild the community playlists." )
			return
		end

		CopyFiles( StreamRadioLib.DataDirectory .. "/playlists/community" )

		StreamRadioLib.Whitelist.BuildWhitelist()

		StreamRadioLib.Editor.Reset( ply )
		StreamRadioLib.Print.Msg( ply, "Community playlists rebuilt" )
	end

	concommand.Add( "sv_streamradio_rebuildplaylists", Rebuild_Playlists )
	concommand.Add( "sv_streamradio_rebuildplaylists_community", Rebuild_CommunityPlaylists )

	local function Reset_Playlists( ply, cmd, args )
		if not StreamRadioLib then return end
		if not StreamRadioLib.Loaded then return end
		if not StreamRadioLib.DataDirectory then return end

		if not StreamRadioLib.Util.IsAdminForCMD(ply) then
			StreamRadioLib.Print.Msg( ply, "You need to be an admin to reset the playlists." )
			return
		end

		local deleted = StreamRadioLib.Util.DeleteFolder( StreamRadioLib.DataDirectory .. "/playlists" )
		if not deleted then
			StreamRadioLib.Print.Msg( ply, "Playlists could not be rebuilt" )
			return
		end

		StreamRadioLib.Print.Msg( ply, "Playlists deleted" )
		Rebuild_Playlists( ply, cmd, args )
	end

	local function Reset_CommunityPlaylists( ply, cmd, args )
		if not StreamRadioLib then return end
		if not StreamRadioLib.Loaded then return end
		if not StreamRadioLib.DataDirectory then return end

		if not StreamRadioLib.Util.IsAdminForCMD(ply) then
			StreamRadioLib.Print.Msg( ply, "You need to be an admin to reset the community playlists." )
			return
		end

		local deleted = StreamRadioLib.Util.DeleteFolder( StreamRadioLib.DataDirectory .. "/playlists/community" )
		if not deleted then
			StreamRadioLib.Print.Msg( ply, "Community playlists could not be rebuilt" )
			return
		end

		StreamRadioLib.Print.Msg( ply, "Community playlists deleted" )
		Rebuild_CommunityPlaylists( ply, cmd, args )
	end

	concommand.Add( "sv_streamradio_resetplaylists", Reset_Playlists )
	concommand.Add( "sv_streamradio_resetplaylists_community", Reset_CommunityPlaylists )
end


StreamRadioLib.Timedcall( function()
	if not StreamRadioLib.Loaded then return end
	if not StreamRadioLib.DataDirectory then return end

	if not file.IsDir( StreamRadioLib.DataDirectory, "DATA" ) then
		CopyFiles(StreamRadioLib.DataDirectory)
		return
	end

	if not file.IsDir( StreamRadioLib.DataDirectory .. "/playlists", "DATA" ) then
		CopyFiles(StreamRadioLib.DataDirectory .. "/playlists")
		return
	end

	local rebuildmode = StreamRadioLib.GetRebuildCommunityPlaylistsMode()
	local community_folder = StreamRadioLib.DataDirectory .. "/playlists/community"

	if rebuildmode == 1 then
		CopyFiles( community_folder )
	end

	if rebuildmode == 2 then
		StreamRadioLib.Util.DeleteFolder( community_folder )
		CopyFiles( community_folder )
	end
end )

return true

