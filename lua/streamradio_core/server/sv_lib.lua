local StreamRadioLib = StreamRadioLib

local LIBNet = StreamRadioLib.Net
local LIBUrl = StreamRadioLib.Url
local LIBHook = StreamRadioLib.Hook
local LIBPrint = StreamRadioLib.Print

LIBNet.Receive("Control", function( len, ply )
	local trace = StreamRadioLib.Trace( ply )
	StreamRadioLib.Control(ply, trace, net.ReadBool())
end)

LIBHook.AddCustom("OnPlayStream", "UrlLogging", function(url, name, ent, user)
	local mode = StreamRadioLib.GetStreamLogMode()

	if mode == StreamRadioLib.LOG_STREAM_URL_NONE then
		return
	end

	local offline = LIBUrl.IsOfflineURL(url)
	if mode == StreamRadioLib.LOG_STREAM_URL_ONLINE and offline then
		return
	end

	if name == "" then
		name = url
	end

	local nameHasUrl = false

	if string.find(name, url, 0, true) then
		nameHasUrl = true
	end

	local msgstring = nil
	local onlinestring = offline and "file" or "online"

	if nameHasUrl then
		msgstring = LIBPrint.Format("STREAM - Radio '%s' plays %s => %s", ent, onlinestring, name)
	else
		msgstring = LIBPrint.Format("STREAM - Radio '%s' plays %s => %s: %s", ent, onlinestring, name, url)
	end

	LIBPrint.Log(user, msgstring)
end)

return true

