local StreamRadioLib = StreamRadioLib

StreamRadioLib.Net = StreamRadioLib.Net or {}

local LIB = StreamRadioLib.Net
table.Empty(LIB)

local LIBNetwork = StreamRadioLib.Network

LIBNetwork.AddNetworkString("StaticState")
LIBNetwork.AddNetworkString("Control")

LIBNetwork.AddNetworkString("Editor_Return_Files")
LIBNetwork.AddNetworkString("Editor_Return_Playlist")
LIBNetwork.AddNetworkString("Editor_Request_Files")
LIBNetwork.AddNetworkString("Editor_Request_Playlist")
LIBNetwork.AddNetworkString("Editor_Error")

do
	-- Automaticly generated network string table map

	LIBNetwork.AddNetworkString("classsystem_listen")
	LIBNetwork.AddNetworkString("LoadError")
	LIBNetwork.AddNetworkString("ClientToolHook")
	LIBNetwork.AddNetworkString("clientstate")
	LIBNetwork.AddNetworkString("str")
	LIBNetwork.AddNetworkString("str/Volume")
	LIBNetwork.AddNetworkString("str/URL")
	LIBNetwork.AddNetworkString("str/PlayMode")
	LIBNetwork.AddNetworkString("str/Loop")
	LIBNetwork.AddNetworkString("str/Name")
	LIBNetwork.AddNetworkString("str/MasterTime")
	LIBNetwork.AddNetworkString("skin")
	LIBNetwork.AddNetworkString("skinrequest")
	LIBNetwork.AddNetworkString("skintoserver")
	LIBNetwork.AddNetworkString("g")
	LIBNetwork.AddNetworkString("gui_sk")
	LIBNetwork.AddNetworkString("gui_sk/Hash")
	LIBNetwork.AddNetworkString("data")
	LIBNetwork.AddNetworkString("datarequest")
	LIBNetwork.AddNetworkString("streamreset_on_sv")
	LIBNetwork.AddNetworkString("streamreset_on_cl")
	LIBNetwork.AddNetworkString("whitelist_check_url")
	LIBNetwork.AddNetworkString("whitelist_check_url_result")
	LIBNetwork.AddNetworkString("whitelist_quick_whitelist")
	LIBNetwork.AddNetworkString("whitelist_clear_cache")
	LIBNetwork.AddNetworkString("g/m")
	LIBNetwork.AddNetworkString("g/m/brw")
	LIBNetwork.AddNetworkString("g/m/brw/lstp")
	LIBNetwork.AddNetworkString("g/m/brw/lstp/sbar")
	LIBNetwork.AddNetworkString("g/m/brw/lstp/sbar/ScrollPos")
	LIBNetwork.AddNetworkString("g/m/brw/lstp/sbar/ScrollMax")
	LIBNetwork.AddNetworkString("g/m/brw/lstp/ListGridX")
	LIBNetwork.AddNetworkString("g/m/brw/lstp/ListGridY")
	LIBNetwork.AddNetworkString("g/m/brw/lstp/IsHorizontal")
	LIBNetwork.AddNetworkString("g/m/brw/lstp/Hash")
	LIBNetwork.AddNetworkString("g/m/brw/lstp/Path")
	LIBNetwork.AddNetworkString("g/m/brw/lstpv")
	LIBNetwork.AddNetworkString("g/m/brw/lstpv/sbar")
	LIBNetwork.AddNetworkString("g/m/brw/lstpv/sbar/ScrollPos")
	LIBNetwork.AddNetworkString("g/m/brw/lstpv/sbar/ScrollMax")
	LIBNetwork.AddNetworkString("g/m/brw/lstpv/ListGridX")
	LIBNetwork.AddNetworkString("g/m/brw/lstpv/ListGridY")
	LIBNetwork.AddNetworkString("g/m/brw/lstpv/IsHorizontal")
	LIBNetwork.AddNetworkString("g/m/brw/lstpv/Hash")
	LIBNetwork.AddNetworkString("g/m/brw/lstpv/Path")
	LIBNetwork.AddNetworkString("g/m/brw/lstpv/PathType")
	LIBNetwork.AddNetworkString("g/m/brw/lstpv/Error")
	LIBNetwork.AddNetworkString("g/m/brw/PlaylistOpened")
	LIBNetwork.AddNetworkString("g/m/ply")
	LIBNetwork.AddNetworkString("g/m/PlayerOpened")
	LIBNetwork.AddNetworkString("g/m/ply/ctrl")
	LIBNetwork.AddNetworkString("g/m/ply/ctrl/PlaylistEnabled")
	LIBNetwork.AddNetworkString("properties")
end

function LIB.Receive(name, ...)
	name = LIBNetwork.TransformNWIdentifier(name)
	return net.Receive(name, ...)
end

function LIB.Start(name, ...)
	name = LIBNetwork.TransformNWIdentifier(name)
	return net.Start(name, ...)
end

function LIB.SendIdentifier(identifier)
	local identifierId = 0

	if isstring(identifier) then
		identifierId = LIBNetwork.NetworkStringToID(identifier)

		if identifierId == 0 then
			StreamRadioLib.Util.ErrorNoHaltWithStack("Identifier '" .. identifier .. "' was not added via util.AddNetworkString() yet.")
		end
	end

	net.WriteUInt(identifierId, 12)
end

function LIB.ReceiveIdentifier()
	local identifierId = net.ReadUInt(12) or 0
	local identifier = LIBNetwork.NetworkIDToString(identifierId)

	return identifier
end

function LIB.SendHash(hash)
	net.WriteString(hash or "")
end

function LIB.ReceiveHash()
	local hash = net.ReadString() or ""
	return hash
end

function LIB.SendListEntry( text, iconid )
	net.WriteString( text or "" )
	net.WriteInt( iconid or -1, 16 )
end

function LIB.ReceiveListEntry( )
	local text = net.ReadString( ) or ""
	local iconid = net.ReadInt( 16 ) or -1

	return text, iconid
end

function StreamRadioLib.NetSendEditorError( path, code )
	if ( not path ) then return end
	if ( not code ) then return end

	net.WriteString( path )
	net.WriteUInt( code, 8 )
end

function StreamRadioLib.NetReceiveEditorError( )
	local path = net.ReadString( ) or ""
	local code = net.ReadUInt( 8 ) or StreamRadioLib.EDITOR_ERROR_UNKNOWN

	return path, code
end

function StreamRadioLib.NetSendFileEditor( path, name, format, parentpath )
	if ( not path ) then return end
	if ( not name ) then return end
	if ( not format ) then return end
	if ( not parentpath ) then return end

	net.WriteString( path )
	net.WriteString( name )
	net.WriteString( parentpath )
	net.WriteUInt( format, 8 )
end

function StreamRadioLib.NetReceiveFileEditor( )
	local path = net.ReadString( ) or ""
	local name = net.ReadString( ) or ""
	local parentpath = net.ReadString( ) or ""
	local format = net.ReadUInt( 8 ) or StreamRadioLib.TYPE_FOLDER

	return path, name, format, parentpath
end

function StreamRadioLib.NetSendPlaylistEditor( url, name, parentpath )
	if ( not url ) then return end
	if ( not name ) then return end
	if ( not parentpath ) then return end

	net.WriteString( name )
	net.WriteString( url )
	net.WriteString( parentpath )
end

function StreamRadioLib.NetReceivePlaylistEditor( )
	local name = net.ReadString( ) or ""
	local url = net.ReadString( ) or ""
	local parentpath = net.ReadString( ) or ""

	return url, name, parentpath
end

local function networkStaticAddonStates()
	if SERVER then
		StreamRadioLib.Hook.Add("PlayerInitialSpawn", "StaticState", function(ply)
			if not IsValid(ply) then
				return
			end

			LIB.Start("StaticState")
				net.WriteBool(StreamRadioLib.Bass.IsInstalledOnServer())
			net.Send(ply)
		end)
	else
		LIB.Receive("StaticState", function()
			StreamRadioLib.Bass.g_IsInstalledOnServer = net.ReadBool()
		end)
	end
end

networkStaticAddonStates()

return true

