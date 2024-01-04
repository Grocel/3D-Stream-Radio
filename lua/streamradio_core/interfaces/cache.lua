local RADIOIFACE = RADIOIFACE
if not istable( RADIOIFACE ) then
	StreamRadioLib.Interface.Load()
	return
end

RADIOIFACE.name = "Cache"
RADIOIFACE.priority = 99000
RADIOIFACE.online = false
RADIOIFACE.cache = true

RADIOIFACE.downloadTimeout = 0
RADIOIFACE.downloadFirst = false
RADIOIFACE.allowCaching = false

local LIBUrl = StreamRadioLib.Url
local LIBString = StreamRadioLib.String
local LIBCache = StreamRadioLib.Cache

function RADIOIFACE:CheckURL(url)
	if LIBUrl.IsOfflineURL(url) then
		return false
	end

	if not LIBCache.GetFile(url) then
		return false
	end

	return true
end

function RADIOIFACE:ParseURL(url)
	local cachefile = LIBCache.GetFile(url)

	if not cachefile then
		return nil
	end

	local urlResult = "data/" .. cachefile
	urlResult = LIBString.NormalizeSlashes(urlResult)

	return urlResult
end

function RADIOIFACE:Convert(url, callback)
	local path = self:ParseURL(url)

	if not path then
		callback(self, false)
		return
	end

	callback(self, true, path)
end

return true

