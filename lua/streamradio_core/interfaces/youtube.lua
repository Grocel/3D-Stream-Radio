local RADIOIFACE = RADIOIFACE
if not istable( RADIOIFACE ) then
	StreamRadioLib.Interface.Load()
	return
end

RADIOIFACE.name = "YouTube"
RADIOIFACE.subinterfaces_folder = "youtube"

local ERROR_DISABLED = 110000
local ERROR_UNSUPPORTED = 110001
local ERROR_NO_ID = 110002

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

StreamRadioLib.Error.AddStreamErrorCode({
	id = ERROR_NO_ID,
	name = "STREAM_ERROR_YOUTUBE_NO_ID",
	description = "[YouTube] Invalid video ID",
	helptext = [[
An invalid video ID was given.

Notes:
	- Make sure you enter a YouTube URL of an existing video.
	- Do not try to play from YouTube playlists or channels. Those are not supported.
]],
	helpurl = youtube_help_url,
})

StreamRadioLib.Error.AddStreamErrorCode({
	id = ERROR_DISABLED,
	name = "STREAM_ERROR_YOUTUBE_DISABLED",
	description = "[YouTube] Invalid video ID",
	helptext = [[
Playback from YouTube is disabled.
You can enable it with the tickbox below or in the Stream Radio settings.

Notes:
	- This is slow and unreliable.
	- Use at your own risk.
]],
	helpurl = youtube_help_url,
	userdata = {
		tickbox = {
			text = "Enable YouTube support\n(slow and unreliable!)",
			cmd = "cl_streamradio_youtubesupport",
		},
	},
})

local YoutubePatterns = {
	"youtube%://([%w%-%_]+)",
	"yt%://([%w%-%_]+)",
	"%?v=([%w%-%_]+)",
	"%&v=([%w%-%_]+)",
	"/v/([%w%-%_]+)",
	"/videos/([%w%-%_]+)",
	"/embed/([%w%-%_]+)",
	"youtu%.be/([%w%-%_]+)",
	"%?video=([%w%-%_]+)",
	"%&video=([%w%-%_]+)",
}

local YoutubeURLs = {
	"youtube://",
	"yt://",
	"://youtube.",
	".youtube.",
	"://youtu.be",
}

function RADIOIFACE:PrintError(url, code)
	StreamRadioLib.Print.Debug([[
Error Converting YouTube URL: '%s'
Code: %d (%s), %s
Retrying with next module...
]], url, code, StreamRadioLib.Error.GetStreamErrorName(code), StreamRadioLib.Error.GetStreamErrorDescription(code))

end

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

function RADIOIFACE:ParseURL(url)
	for i, v in ipairs(YoutubePatterns) do
		local result = string.Trim(string.match(url, v) or "")

		if result == "" then
			continue
		end

		return result
	end

	return nil
end

function RADIOIFACE:CheckConvertCondition(url, callback)

	if CLIENT and not StreamRadioLib.HasYoutubeSupport() then
		-- Youtube support is dropped anyways
		-- callback(self, false, nil, ERROR_DISABLED)
		callback(self, false, nil, ERROR_UNSUPPORTED)
		return false
	end

	return true
end

function RADIOIFACE:Convert(url, callback)
	local id = self:ParseURL(url)

	if not id then
		callback(self, false, nil, ERROR_NO_ID)
		return true
	end

	self._quene = self._quene or {}
	self._quene[id] = self._quene[id] or {}

	local q = self._quene[id]

	q.quene = q.quene or {}
	q.quene[callback] = true

	local function callcallbacks(...)
		if not q.quene then return end
		if not q.started then return end

		local tmp = q.quene

		q.quene = nil
		q.started = nil

		for func, v in pairs(tmp) do
			if not isfunction(func) then continue end
			func(...)
		end
	end

	if q.started then return true end

	local stack = self:GetSubInterfaceStack()
	if not stack then
		q.started = true
		callcallbacks(self, false, nil, ERROR_UNSUPPORTED)
		return true
	end

	local lasterror = nil

	local function iterration()
		if not self:CheckConvertCondition(url, callcallbacks) then
			return
		end

		if lasterror then
			self:PrintError(url, lasterror)
		end

		local subiface = stack:Top()
		if not subiface then
			callcallbacks(self, false, nil, lasterror or ERROR_UNSUPPORTED)
			return
		end

		stack:Pop()

		if not subiface.Convert then
			callcallbacks(self, false, nil, lasterror or ERROR_UNSUPPORTED)
			return
		end

		subiface:Convert(url, function(this, success, convered_url, errorcode, data)
			if not self:CheckConvertCondition(url, callback) then
				return
			end

			if not success then
				lasterror = errorcode
				iterration()
				return
			end

			callcallbacks(self, success, convered_url, errorcode, data)
		end, id)
	end

	q.started = true
	iterration()

	return true
end
