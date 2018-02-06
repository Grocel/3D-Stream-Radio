local pairs = pairs
if ( not istable( StreamRadioLib ) ) then return end
StreamRadioLib.Editor = {}
local type = type
local IsValid = IsValid
local file = file
local table = table
local string = string
local util = util
local player = player
local ents = ents
local net = net
local ListenPath = ""
local CallbackFunc = nil
local CallbackArgs = {}
local CallbackSelf = nil

function StreamRadioLib.Editor.ListenToPath( path )
	ListenPath = tostring( path or "" )

	return ListenPath
end

function StreamRadioLib.Editor.GetListenPath( )
	return ListenPath
end

function StreamRadioLib.Editor.CreateDir( path )
	if ( not path ) then return false end
	if ( path == "" ) then return false end
	net.Start( "Streamradio_Editor_Request_Playlist" )
	net.WriteUInt( 0, 4 )
	net.WriteString( path )
	net.SendToServer( )

	return true
end

function StreamRadioLib.Editor.Save( path, DataTab )
	if ( not path ) then return false end
	if ( path == "" ) then return false end
	if ( not DataTab ) then return false end
	if ( not DataTab["format"] ) then return false end
	if ( DataTab["format"] == StreamRadioLib.TYPE_FOLDER ) then return false end
	local ply = LocalPlayer( )
	if ( not IsValid( ply ) ) then return false end
	if ( not ply:IsAdmin( ) ) then return false end
	--Start
	net.Start( "Streamradio_Editor_Request_Playlist" )
	net.WriteUInt( 1, 4 )
	net.WriteString( path )
	net.SendToServer( )
	StreamRadioLib.TimedpairsStop( "Editor_SaveFile_" .. path )

	StreamRadioLib.Timedpairs( "Editor_SaveFile_" .. path, DataTab, 1, function( k, v )
		if ( not IsValid( ply ) ) then return false end
		if ( not ply:IsAdmin( ) ) then return false end
		if ( isstring( k ) ) then return end
		--Body
		net.Start( "Streamradio_Editor_Request_Playlist" )
		net.WriteUInt( 2, 4 )
		StreamRadioLib.NetSendPlaylistEditor( v["url"], v["name"], path )
		net.SendToServer( )
	end, function( k, v )
		if ( not IsValid( ply ) ) then return false end
		if ( not ply:IsAdmin( ) ) then return false end
		--Finish
		net.Start( "Streamradio_Editor_Request_Playlist" )
		net.WriteUInt( 3, 4 )
		net.WriteUInt( DataTab["format"], 8 )
		net.WriteUInt( #DataTab, 16 )
		net.WriteString( path )
		net.SendToServer( )
	end )

	return true
end

function StreamRadioLib.Editor.Remove( path )
	if ( not path ) then return false end
	if ( path == "" ) then return false end
	local ply = LocalPlayer( )
	if ( not IsValid( ply ) ) then return false end
	if ( not ply:IsAdmin( ) ) then return false end
	net.Start( "Streamradio_Editor_Request_Playlist" )
	net.WriteUInt( 4, 4 )
	net.WriteString( path )
	net.SendToServer( )

	return true
end

function StreamRadioLib.Editor.Copy( path_old, path_new )
	if ( not path_old ) then return false end
	if ( not path_new ) then return false end
	if ( path_old == "" ) then return false end
	if ( path_new == "" ) then return false end
	if ( path_old == path_new ) then return false end
	local ply = LocalPlayer( )
	if ( not IsValid( ply ) ) then return false end
	if ( not ply:IsAdmin( ) ) then return false end
	net.Start( "Streamradio_Editor_Request_Playlist" )
	net.WriteUInt( 5, 4 )
	net.WriteString( path_old )
	net.WriteString( path_new )
	net.SendToServer( )

	return true
end

function StreamRadioLib.Editor.Rename( path_old, path_new )
	if ( not path_old ) then return false end
	if ( not path_new ) then return false end
	if ( path_old == "" ) then return false end
	if ( path_new == "" ) then return false end
	if ( path_old == path_new ) then return false end
	local ply = LocalPlayer( )
	if ( not IsValid( ply ) ) then return false end
	if ( not ply:IsAdmin( ) ) then return false end
	net.Start( "Streamradio_Editor_Request_Playlist" )
	net.WriteUInt( 6, 4 )
	net.WriteString( path_old )
	net.WriteString( path_new )
	net.SendToServer( )

	return true
end

function StreamRadioLib.Editor.SetCallback( func, self, ... )
	if ( not isfunction( func ) ) then
		CallbackFunc = nil
		CallbackArgs = {}
		CallbackSelf = nil

		return
	end

	CallbackFunc = func
	CallbackArgs = {...}
	CallbackSelf = self
end

net.Receive( "Streamradio_Editor_Return_Files", function( length )
	local path, name, type, filepath = StreamRadioLib.NetReceiveFileEditor( )
	--if ( filepath ~= ListenPath ) then return end
	if ( not isfunction( CallbackFunc ) ) then return end

	if ( CallbackSelf ) then
		CallbackFunc( CallbackSelf, "files", path, name, filepath, type, unpack( CallbackArgs or {} ) )
	else
		CallbackFunc( "files", path, name, filepath, type, unpack( CallbackArgs or {} ) )
	end
end )

net.Receive( "Streamradio_Editor_Return_Playlist", function( length )
	local url, name, filepath = StreamRadioLib.NetReceivePlaylistEditor( )
	--if ( filepath ~= ListenPath ) then return end
	if ( not isfunction( CallbackFunc ) ) then return end

	if ( CallbackSelf ) then
		CallbackFunc( CallbackSelf, "playlist", url, name, filepath, unpack( CallbackArgs or {} ) )
	else
		CallbackFunc( "playlist", url, name, filepath, unpack( CallbackArgs or {} ) )
	end
end )

net.Receive( "Streamradio_Editor_Error", function( length )
	local path, code = StreamRadioLib.NetReceiveEditorError( )
	if ( not isfunction( CallbackFunc ) ) then return end

	if ( CallbackSelf ) then
		CallbackFunc( CallbackSelf, "error", path, code, unpack( CallbackArgs or {} ) )
	else
		CallbackFunc( "error", path, code, unpack( CallbackArgs or {} ) )
	end
end )

local MainPanel
local EditorPanel

local function CreateMainPanel( )
	if ( IsValid( MainPanel ) ) then
		MainPanel:Remove( )
	end

	if ( IsValid( EditorPanel ) ) then
		EditorPanel:Remove( )
	end

	MainPanel = vgui.Create( "DFrame" ) -- The main frame.
	MainPanel:SetPos( 25, 25 )

	local W = math.Clamp( ScrW( ) - 50, 750, 1200 )
	local H = math.Clamp( ScrH( ) - 50, 400, 800 )
	MainPanel:SetSize( W, H )

	MainPanel:SetMinWidth( 750 )
	MainPanel:SetMinHeight( 400 )
	MainPanel:SetSizable( true )
	MainPanel:SetDeleteOnClose( false )
	MainPanel:SetTitle( "Stream Radio Playlist Editor" )
	MainPanel:SetVisible( false )
	MainPanel:GetParent( ):SetWorldClicker( true )

	EditorPanel = vgui.Create( "Streamradio_VGUI_PlaylistEditor", MainPanel )
	EditorPanel:DockMargin( 5, 5, 5, 5 )
	EditorPanel:Dock( FILL )
end

local function ClosePanel( ply, cmd, args )
	if ( not IsValid( MainPanel ) ) then
		return
	end

	MainPanel:Close()
end

local function OpenPanel( ply, cmd, args )
	if ( not IsValid( ply ) ) then return end

	if ( not ply:IsAdmin( ) ) then
		StreamRadioLib.Msg( ply, "You need to be an admin to use the playlist editor." )

		return
	end

	if ( not IsValid( MainPanel ) ) then
		CreateMainPanel( )
	end

	if ( not IsValid( MainPanel ) ) then
		return
	end

	MainPanel:SetVisible( true )
	MainPanel:MakePopup( )
	MainPanel:InvalidateLayout( true )
end

concommand.Add( "cl_streamradio_playlisteditor", OpenPanel )
concommand.Add( "+cl_streamradio_playlisteditor", OpenPanel )
concommand.Add( "-cl_streamradio_playlisteditor", ClosePanel )
