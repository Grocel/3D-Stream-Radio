local RADIOIFACE = RADIOIFACE
if not istable( RADIOIFACE ) then
	StreamRadioLib.Interface.Load()
	return
end

RADIOIFACE.name = "Dropbox"
RADIOIFACE.subinterfaces_folder = "dropbox"
RADIOIFACE.download = true
RADIOIFACE.download_timeout = 5

local ERROR_NO_PATH = 20000

RADIOIFACE.Errorcodes[ERROR_NO_PATH] = {
	desc = "Dropbox url has no path",
	text = [[
Make sure your Dropbox has a valid path in it.
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
