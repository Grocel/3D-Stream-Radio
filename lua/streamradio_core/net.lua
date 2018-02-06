StreamRadioLib.Net = {}
local LIB = StreamRadioLib.Net

local pairs = pairs
local type = type
local IsValid = IsValid
local file = file
local table = table
local string = string
local util = util
local player = player
local ents = ents

if ( SERVER ) then
	util.AddNetworkString( "Streamradio_Show_Functions" )

	util.AddNetworkString( "Streamradio_Radio_Control" )
	util.AddNetworkString( "Streamradio_Radio_PlaylistMenu" )
	util.AddNetworkString( "Streamradio_Radio_Playlist" )

	util.AddNetworkString( "Streamradio_Radio_MasterCallback" )
	util.AddNetworkString( "Streamradio_Radio_ClientError" )

	util.AddNetworkString( "Streamradio_Editor_Return_Files" )
	util.AddNetworkString( "Streamradio_Editor_Return_Playlist" )
	util.AddNetworkString( "Streamradio_Editor_Request_Files" )
	util.AddNetworkString( "Streamradio_Editor_Request_Playlist" )
	util.AddNetworkString( "Streamradio_Editor_Error" )
end

local HashRegister = {}
HashRegister.To = {}
HashRegister.From = {}

function LIB.ToHash( str )
	str = tostring(str or "")
	local cachedhash = HashRegister.To[str] or {}
	local cachedhashstr = cachedhash.hex

	if cachedhashstr and HashRegister.From[cachedhashstr] == str then
		return cachedhash
	end

	local hash = StreamRadioLib.Hash(str)
	HashRegister.To[str] = hash

	local hashstr = hash.hex
	HashRegister.From[hashstr] = str

	return hash
end

function LIB.FromHash( hash )
	if not hash then return nil end

	local hashstr = hash.hex
	if not hashstr then return nil end

	local str = HashRegister.From[hashstr]

	if not str then return nil end
	if not HashRegister.To[str] then return nil end

	return str
end

function LIB.SendHash( hash )
	if not hash then return end
	hash = hash.raw or hash

	for i = 1, 6 do
		net.WriteUInt( hash[i] or 0, 24 )
	end
end

function LIB.ReceiveHash()
	local hash = {}
	hash.raw = {}

	for i = 1, 6 do
		hash.raw[i] = net.ReadUInt( 24 ) or 0
	end

	hash.hex, hash.crc = StreamRadioLib.HashToHex( hash )
	return hash
end

function LIB.SendStringHash( str )
	local hash = LIB.ToHash(str)
	LIB.SendHash(hash)
end

function LIB.ReceiveStringHash()
	local hash = LIB.ReceiveHash()
	local str = LIB.FromHash(hash)
	return str
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


function StreamRadioLib.NetSendMasterCallback( ent, code )
	if ( not IsValid( ent ) ) then return end
	if ( not code ) then return end

	net.WriteEntity( ent )
	net.WriteUInt( code, 8 )
end

function StreamRadioLib.NetReceiveMasterCallback( )
	local ent = net.ReadEntity( )
	local code = net.ReadUInt( 8 ) or 0

	return ent, code
end

function StreamRadioLib.NetSendClientError( ent, code )
	if ( not IsValid( ent ) ) then return end
	if ( not code ) then return end

	net.WriteEntity( ent )
	net.WriteUInt( code, 16 )
end

function StreamRadioLib.NetReceiveClientError( )
	local ent = net.ReadEntity( )
	local code = net.ReadUInt( 16 ) or 0

	return ent, code
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

function StreamRadioLib.NetSendFileEntry( ent, name, format, x, y )
	if ( not IsValid( ent ) ) then return end
	if ( not ent.__IsRadio ) then return end
	if ( not name ) then return end
	if ( not format ) then return end
	if ( not x ) then return end
	if ( not y ) then return end

	net.WriteEntity( ent )
	net.WriteString( name )
	net.WriteUInt( format, 8 )
	net.WriteUInt( x, 4 )
	net.WriteUInt( y, 4 )
end

function StreamRadioLib.NetReceiveFileEntry( )
	local ent = net.ReadEntity( )
	if ( not IsValid( ent ) ) then return end
	if ( not ent.__IsRadio ) then return end

	local name = net.ReadString( ) or ""
	local format = net.ReadUInt( 8 ) or StreamRadioLib.TYPE_FOLDER
	local x = net.ReadUInt( 4 ) or 1
	local y = net.ReadUInt( 4 ) or 1

	return ent, name, format, x, y
end

function StreamRadioLib.NetSendPlaylistEntry( ent, name, x, y )
	if ( not IsValid( ent ) ) then return end
	if ( not ent.__IsRadio ) then return end
	if ( not name ) then return end
	if ( not x ) then return end
	if ( not y ) then return end

	net.WriteEntity( ent )
	net.WriteString( name )
	net.WriteUInt( x, 4 )
	net.WriteUInt( y, 4 )
end

function StreamRadioLib.NetReceivePlaylistEntry( )
	local ent = net.ReadEntity( )
	if ( not IsValid( ent ) ) then return end
	if ( not ent.__IsRadio ) then return end

	local name = net.ReadString( ) or ""
	local x = net.ReadUInt( 4 ) or 1
	local y = net.ReadUInt( 4 ) or 1

	return ent, name, x, y
end
