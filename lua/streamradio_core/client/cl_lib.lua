--////////////////////////////////////
--			Stream Radio Lip
--////////////////////////////////////
local IsValid = IsValid
local tonumber = tonumber
local tostring = tostring
local Color = Color
local LocalPlayer = LocalPlayer
local concommand = concommand
local hook = hook
local math = math
local string = string
local net = net

net.Receive( "Streamradio_Radio_PlaylistMenu", function( length )
	if ( not istable( StreamRadioLib ) ) then return end
	if ( not StreamRadioLib.NetReceiveFileEntry ) then return end
	local entity, name, type, x, y = StreamRadioLib.NetReceiveFileEntry( )
	if ( not IsValid( entity ) ) then return end
	if ( not entity.PlaylistMenu ) then return end
	local fileinfo = {}
	fileinfo.filename = name
	fileinfo.filetype = type
	entity.PlaylistMenu[x] = entity.PlaylistMenu[x] or {}
	entity.PlaylistMenu[x][y] = fileinfo
end )

net.Receive( "Streamradio_Radio_Playlist", function( length )
	if ( not istable( StreamRadioLib ) ) then return end
	if ( not StreamRadioLib.NetReceivePlaylistEntry ) then return end
	local entity, name, x, y = StreamRadioLib.NetReceivePlaylistEntry( )
	if ( not IsValid( entity ) ) then return end
	if ( not entity.Playlist ) then return end
	local fileinfo = {}
	fileinfo.filename = name
	entity.Playlist[x] = entity.Playlist[x] or {}
	entity.Playlist[x][y] = fileinfo
end )

local CamPos = nil
local InRenderScene = false

hook.Add( "RenderScene", "Streamradio_CamInfo", function( origin, angles, fov )
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end

	if StreamRadioLib.VR.IsActive() then
		CamPos = nil
		return
	end

	if InRenderScene then return end

	InRenderScene = true
	CamPos = origin
	InRenderScene = false
end )

local g_pressed = false
local g_lastradio = nil

local function ReleaseLastRadioControl()
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end

	local ply = LocalPlayer()
	if not IsValid( ply ) then return end
	if not IsValid( g_lastradio ) then return end
	if not g_lastradio.__IsRadio then return end
	if not g_lastradio.Control then return end

	local pressed = g_pressed
	g_pressed = false

	if not pressed then return end

	net.Start( "Streamradio_Radio_Control" )
		net.WriteBool( false )
	net.SendToServer()

	StreamRadioLib.Control( ply, nil, false )
	g_lastradio = nil
end

local function GetPressed(ply)
	local inVehicle = ply.InVehicle and ply:InVehicle()

	if StreamRadioLib.GameIsPaused() then
		return false
	end

	if StreamRadioLib.VR.IsActive(ply) then
		-- Only allow if there is no focus on any menu
		if StreamRadioLib.VR.MenuIsOpen() then
			return false
		end

		-- Check if trigger is pressed
		if StreamRadioLib.VR.GetTriggerPressed() then
			return true
		end

		-- Or check if the player's right hand touches the radio
		if StreamRadioLib.VR.GetRadioTouched() then
			return true
		end

		return false
	end

	if gui.IsGameUIVisible() then
		return false
	end

	local key = StreamRadioLib.GetControlKey()

	if inVehicle then
		key = StreamRadioLib.GetControlKeyVehicle()
	end

	if not key then
		return false
	end

	local pressed = input.IsButtonDown( key )
	return pressed
end

hook.Add( "Think", "Streamradio_Control", function( )
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end

	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local pressed = GetPressed(ply)
	if g_pressed == pressed then return end

	if not pressed then
		ReleaseLastRadioControl()
		g_pressed = pressed
		return
	end
	g_pressed = pressed

	local tr = StreamRadioLib.Trace( ply )
	if not tr then
		ReleaseLastRadioControl()
		return
	end

	local Radio = tr.Entity
	if not IsValid( Radio ) then
		ReleaseLastRadioControl()
		return
	end

	if not Radio.__IsRadio then
		ReleaseLastRadioControl()
		return
	end

	if not Radio.Control then
		ReleaseLastRadioControl()
		return
	end

	if Radio ~= g_lastradio then
		ReleaseLastRadioControl()
	end

	net.Start( "Streamradio_Radio_Control" )
		net.WriteBool( pressed )
	net.SendToServer()

	StreamRadioLib.Control( ply, tr, pressed )
	g_lastradio = Radio
end )


function StreamRadioLib.GetCameraPos(ply)
	local islocal = false

	if not IsValid(ply) then
		islocal = true
	end

	if ply == LocalPlayer() then
		islocal = true
	end

	if StreamRadioLib.VR.IsActive(ply) then
		local pos = StreamRadioLib.VR.GetCameraPos(ply)
		return pos
	end

	if not CamPos or not islocal then
		local camera = StreamRadioLib.GetCameraEnt(ply)
		if not IsValid(camera) then return nil end

		local viewpos = nil
		if camera:IsPlayer() then
			viewpos = camera:EyePos()
		else
			viewpos = camera:GetPos()
		end

		return viewpos
	end

	return CamPos
end


function StreamRadioLib.CalcDistanceVolume( distance, max )
	distance = distance or 0
	local threshold = 0.25
	max = math.min( max or 0, StreamRadioLib.GetMuteDistance( ) )
	local min = ( max or 0 ) / 3
	local fullmin = min / 4
	if ( min <= 0 ) then return 0 end
	if ( max <= 0 ) then return 0 end
	if ( distance > max ) then return 0 end
	if ( distance <= 0 ) then return 1 end
	if ( distance <= fullmin ) then return 1 end
	if ( distance <= min ) then return Lerp( ( distance - fullmin ) / ( min - fullmin ), 1, threshold ) end

	return Lerp( ( distance - min ) / ( max - min ), threshold, 0 )
end

local oldfloat = 0
local oldvar = 0

function StreamRadioLib.PrintFloat( float, len, ... )
	local float = math.Clamp( float, 0, 1 )
	local str = ""

	if ( float >= oldfloat ) then
		oldfloat = float
	end

	local bar = math.Round( float * len )
	local space = len - math.Round( float * len )
	local space1 = math.Round( ( oldfloat - float ) * len )
	local space2 = space - space1 - 1
	str = string.rep( "#", bar ) .. string.rep( " ", space1 ) .. ( math.Round( oldfloat * len ) < len and "|" or "" ) .. string.rep( " ", space2 )
	MsgC( Color( 510 * ( float ), 510 * ( 1 - ( float ) ), 0, 255 ), str, " ", string.format( "% 7.2f%%\t", float * 100 ), ..., "\n" )

	if ( float < oldfloat ) then
		oldfloat = oldfloat - 0.5 * RealFrameTime( )
	end

	oldvar = float

	return str
end

if ( StreamRadioLib.TestChannel ) then
	StreamRadioLib.TestChannel:Remove()
	StreamRadioLib.TestChannel = nil
end

local function testchannel( args )
	local TestChannel = StreamRadioLib.TestChannel or StreamRadioLib.CreateStream()

	TestChannel:SetVolume( tonumber( args[2] ) )
	TestChannel:Play()
	TestChannel:SetURL( tostring( args[1] ) )
	print( TestChannel )

	print("Online", TestChannel:IsOnline())

	TestChannel.OnConnect = function(self, channel)
		print("OnConnect", self, channel)
	end

	TestChannel.OnRetry = function(self, err)
		print("OnRetry", self, err)
		return true
	end

	TestChannel.OnError = function(self, err)
		print( "OnError", self, err, StreamRadioLib.DecodeErrorCode( err ) )
	end

	StreamRadioLib.TestChannel = TestChannel
end

concommand.Add( "test_streamradio_channel_play", function( pl, cmd, args )
	testchannel( args or {} )
end )

local function testchannel_vol( pl, cmd, args )
	if ( not StreamRadioLib.TestChannel ) then return end
	args = args or {}

	StreamRadioLib.TestChannel:SetVolume( tonumber( args[1] ) )
end

concommand.Add( "test_streamradio_channel_vol", testchannel_vol )

local function testchannel_stop( pl, cmd, args )
	if ( not StreamRadioLib.TestChannel ) then return end
	args = args or {}

	StreamRadioLib.TestChannel:Remove()
	StreamRadioLib.TestChannel = nil
end

concommand.Add( "test_streamradio_channel_stop", testchannel_stop )
