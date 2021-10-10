local RADIOIFACE = RADIOIFACE
if not istable( RADIOIFACE ) then
	StreamRadioLib.Interface.Load()
	return
end

RADIOIFACE.name = "Dropbox"
RADIOIFACE.subinterfaces_folder = "dropbox"
RADIOIFACE.download = true
RADIOIFACE.download_timeout = 20

local ERROR_NO_PATH = 20002

RADIOIFACE.Errorcodes[ERROR_NO_PATH] = {
	desc = "YouTube support is not enabled",
	text = [[
Playback from YouTube is disabled.
You can enable it with the tickbox below or in the Stream Radio settings.

Notes:
  - This is slow and unreliable.
  - Use at your own risk.
]],
}

local DropboxPatterns = {
	"dropbox%://s/(.+)",
	"dropbox%://(.+)",
	"/s/(.+)",
}

local DropboxURLs = {
	"dropbox://",
	"//www.dropbox.com/",
	"//dropbox.com/",
	"//www.dl.dropboxusercontent.com/",
	"//dl.dropboxusercontent.com/",
}

function RADIOIFACE:CheckURL(url)
	for i, v in ipairs(DropboxURLs) do
		local result = string.find(string.lower(url), v, 1, true)

		if not result then
			continue
		end

		return true
	end

	return false
end

function RADIOIFACE:ParseURL(url)
	for i, v in ipairs(DropboxPatterns) do
		local result = string.Trim(string.match(url, v) or "")

		if result == "" then
			continue
		end

		result = string.match( result, "^/s/(.+)$" ) or result
		result = string.TrimLeft( result, "/" )

		if result == "" then
			continue
		end

		return result
	end

	return nil
end

function RADIOIFACE:CheckConvertCondition(url, callback)
	if CLIENT and not StreamRadioLib.HasYoutubeSupport() then
		callback(self, false, nil, ERROR_DISABLED)
		return false
	end

	return true
end

local g_dropbox_content_url = "https://www.dl.dropboxusercontent.com/s/";

function RADIOIFACE:Convert(url, callback)
	local path = self:ParseURL(url)

	if not path then
		callback(self, false, nil, ERROR_NO_PATH)
		return true
	end

	local streamUrl = g_dropbox_content_url .. path

	streamUrl = StreamRadioLib.URIAddParameter(streamUrl, {
		dl = 1,
	})

	callback(self, true, streamUrl, nil, nil)
	return true
end
