local RADIOIFACE = RADIOIFACE
if not istable( RADIOIFACE ) then
	StreamRadioLib.Interface.Load()
	return
end

local ERROR_NO_ID = 11000

RADIOIFACE.name = "SHOUTcast"
RADIOIFACE.subinterfaces_folder = "shoutcast"

local ShoutcastPatterns = {
	"shoutcast%://([%d]+)",
}

local ShoutcastURLs = {
	"shoutcast://",
}

RADIOIFACE.Errorcodes[ERROR_NO_ID] = {
	desc = "Invalid stream ID",
	text = [[
An invalid stream ID was given.

Notes:
	- Make sure you enter a URL of an existing SHOUTcast stream.
	- The URL should look like this shoutcast://123456
	- Only numbers are supported.
]]
}

function RADIOIFACE:CheckURL(url)
	for i, v in ipairs(ShoutcastURLs) do
		local result = string.find(string.lower(url), v, 1, true)

		if not result then
			continue
		end

		return true
	end

	return false
end

function RADIOIFACE:ParseURL(url)
	for i, v in ipairs(ShoutcastPatterns) do
		local result = string.Trim(string.match(url, v) or "")

		if result == "" then
			continue
		end

		return result
	end

	return nil
end

function RADIOIFACE:Convert(url, callback)
	local id = self:ParseURL(url)

	if not id then
		callback(self, false, nil, ERROR_NO_ID)
		return true
	end

	local streamUrl = StreamRadioLib.Shoutcast.GetStreamUrlById(id)
	callback(self, true, streamUrl, nil, nil)

	return true
end
