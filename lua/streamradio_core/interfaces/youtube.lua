local RADIOIFACE = RADIOIFACE
if not istable( RADIOIFACE ) then
	StreamRadioLib.Interface.Load()
	return
end

RADIOIFACE.name = "YouTube"
RADIOIFACE.priority = -10000
RADIOIFACE.online = true
RADIOIFACE.cache = false

RADIOIFACE.downloadTimeout = 0
RADIOIFACE.downloadFirst = false
RADIOIFACE.allowCaching = false

local ERROR_UNSUPPORTED = 110000

local youtube_help_url = "https://steamcommunity.com/workshop/filedetails/discussion/246756300/4523281307928803506/"

StreamRadioLib.Error.AddStreamErrorCode({
	id = ERROR_UNSUPPORTED,
	name = "STREAM_ERROR_YOUTUBE_UNSUPPORTED",
	description = "[YouTube] YouTube is not supported",
	helptext = [[
YouTube is not supported. Please use other media sources.
You can use a Youtube to MP3 converter, but it is not recommended.

Notes:
	- Reliable YouTube support can't be added. It is impossible.
	- Please, don't ask me about it.
	- View the online help link for more information.
]],
	helpurl = youtube_help_url,
})

local YoutubeURLs = {
	"youtube://",
	"yt://",
	"://youtube.",
	".youtube.",
	"://youtu.be",
}

function RADIOIFACE:CheckURL(url)
	for i, v in ipairs(YoutubeURLs) do
		local result = string.find(string.lower(url), v, 1, true)

		if not result then
			continue
		end

		return true
	end

	return false
end

function RADIOIFACE:Convert(url, callback)
	callback(self, false, nil, ERROR_UNSUPPORTED)
	return
end

return true

