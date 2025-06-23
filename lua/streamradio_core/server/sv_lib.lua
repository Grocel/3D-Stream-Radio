local StreamRadioLib = StreamRadioLib

local LIBNet = StreamRadioLib.Net
local LIBUrl = StreamRadioLib.Url
local LIBHook = StreamRadioLib.Hook
local LIBUtil = StreamRadioLib.Util
local LIBPrint = StreamRadioLib.Print

LIBNet.Receive("Control", function( len, ply )
	local trace = StreamRadioLib.Trace( ply )
	StreamRadioLib.Control(ply, trace, net.ReadBool())
end)

local g_logDebounce = LIBUtil.CreateCacheArray(4096)

LIBHook.Add("PostCleanupMap", "ResetDebounceUrlLogging", function()
	g_logDebounce:Empty()
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

	local debounceKey = string.format(
		"%s_%d_%s_%s",
		LIBPrint.GetPlayerString(user),
		ent:GetCreationID(),
		url,
		name
	)

	-- Prevent shenanigans with ultra long urls or player names.
	debounceKey = StreamRadioLib.Util.Hash(debounceKey)
	local now = RealTime()

	if g_logDebounce:Has(debounceKey, now) then
		return
	end

	local msgstring = nil
	local onlinestring = offline and "file" or "online"
	local radioName = LIBPrint.GetRadioEntityString(ent)

	if nameHasUrl then
		msgstring = LIBPrint.Format("STREAM - Radio '%s' plays %s => %s", radioName, onlinestring, name)
	else
		msgstring = LIBPrint.Format("STREAM - Radio '%s' plays %s => %s: %s", radioName, onlinestring, name, url)
	end

	LIBPrint.Log(user, msgstring)

	-- Allow a new log entry/print with the same content after one minute.
	g_logDebounce:Set(debounceKey, true, now + 60)
end)

return true

