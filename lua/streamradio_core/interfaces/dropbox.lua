local RADIOIFACE = RADIOIFACE
if not istable( RADIOIFACE ) then
	StreamRadioLib.Interface.Load()
	return
end

RADIOIFACE.name = "Dropbox"
RADIOIFACE.priority = 200
RADIOIFACE.online = true
RADIOIFACE.cache = false

RADIOIFACE.downloadTimeout = 5
RADIOIFACE.downloadFirst = true
RADIOIFACE.allowCaching = true

local ERROR_NO_PATH = 130000

StreamRadioLib.Error.AddStreamErrorCode({
	id = ERROR_NO_PATH,
	name = "STREAM_ERROR_DROPBOX_NO_PATH",
	description = "[Dropbox] Url has no path",
	helptext = [[
Make sure your Dropbox has a valid path in it.
]],
})

local DropboxPatterns = {
	"dropbox%://(.+)",
	"com/(.+)",
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

		result = string.match( result, "^/(.+)$" ) or result
		result = string.TrimLeft( result, "/" )

		if result == "" then
			continue
		end

		return result
	end

	return nil
end

local g_dropbox_content_url = "https://dl.dropboxusercontent.com/";

function RADIOIFACE:Convert(url, callback)
	local path = self:ParseURL(url)

	if not path then
		callback(self, false, nil, ERROR_NO_PATH)
		return
	end

	local streamUrl = g_dropbox_content_url .. path

	streamUrl = StreamRadioLib.Url.URIAddParameter(streamUrl, {
		dl = 1,
	})

	callback(self, true, streamUrl)
end

return true

