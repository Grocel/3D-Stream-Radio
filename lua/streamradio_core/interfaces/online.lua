local RADIOIFACE = RADIOIFACE
if not istable( RADIOIFACE ) then
	StreamRadioLib.Interface.Load()
	return
end

RADIOIFACE.name = "Online"
RADIOIFACE.priority = -100000
RADIOIFACE.online = true
RADIOIFACE.cache = false

RADIOIFACE.downloadTimeout = 0
RADIOIFACE.downloadFirst = false
RADIOIFACE.allowCaching = true

local LIBUrl = StreamRadioLib.Url

function RADIOIFACE:CheckURL(url)
	if LIBUrl.IsOfflineURL(url) then
		return false
	end

	return true
end

function RADIOIFACE:Convert(url, callback)
	callback(self, true, url)
	return
end

return true

