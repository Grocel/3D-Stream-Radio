local LIBNet = StreamRadioLib.Net

LIBNet.Receive("Control", function( len, ply )
	local trace = StreamRadioLib.Trace( ply )
	StreamRadioLib.Control(ply, trace, net.ReadBool())
end)

return true

