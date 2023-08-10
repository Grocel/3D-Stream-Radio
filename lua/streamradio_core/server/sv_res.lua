resource.AddWorkshop( "246756300" ) -- Workshop download

-- Workaround Garry code that disallows shipping *.txt files for the data folder to Workshop.
local WorkshopDataDirectory = "materials/3dstreamradio/_data"

local function CopyFiles( dir )
	file.CreateDir( dir )
	local files, directories = file.Find(WorkshopDataDirectory .. "/" .. dir .. "/*", "GAME")

	for _, f in pairs(files or {}) do
		local filename = dir .. "/" .. f
		local fullpath = WorkshopDataDirectory .. "/" .. filename

		if not file.Exists(fullpath, "GAME") then continue end

		local ext = string.GetExtensionFromFilename(filename)
		if ext ~= "vmt" then continue end

		local newfilename = string.StripExtension(filename) .. ".txt"
		file.Write(newfilename, file.Read(fullpath, "GAME") or "")
	end

	for _, d in pairs(directories or {}) do
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

		StreamRadioLib.Editor.Reset( ply )
		local msgstring = StreamRadioLib.AddonPrefix .. "Playlists rebuilt"
		StreamRadioLib.Print.Msg( ply, msgstring )
	end

	local function Rebuild_CommunityPlaylists( ply, cmd, args )
		if not StreamRadioLib then return end
		if not StreamRadioLib.Loaded then return end

		if not StreamRadioLib.Util.IsAdminForCMD(ply) then
			StreamRadioLib.Print.Msg( ply, "You need to be an admin to rebuild the community playlists." )
			return
		end

		CopyFiles( StreamRadioLib.DataDirectory .. "/playlists/community" )

		StreamRadioLib.Editor.Reset( ply )
		local msgstring = StreamRadioLib.AddonPrefix .. "Community playlists rebuilt"
		StreamRadioLib.Print.Msg( ply, msgstring )
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
			local msgstring = StreamRadioLib.AddonPrefix .. "Playlists could not be rebuilt"
			StreamRadioLib.Print.Msg( ply, msgstring )
			return
		end

		local msgstring = StreamRadioLib.AddonPrefix .. "Playlists deleted"
		StreamRadioLib.Print.Msg( ply, msgstring )
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
			local msgstring = StreamRadioLib.AddonPrefix .. "Community playlists could not be rebuilt"
			StreamRadioLib.Print.Msg( ply, msgstring )
			return
		end

		local msgstring = StreamRadioLib.AddonPrefix .. "Community playlists deleted"
		StreamRadioLib.Print.Msg( ply, msgstring )
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

