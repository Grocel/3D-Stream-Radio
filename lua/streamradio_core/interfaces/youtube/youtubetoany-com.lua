local RADIOIFACE = RADIOIFACE
if not istable( RADIOIFACE ) then
	StreamRadioLib.Interface.Load()
	return
end

RADIOIFACE.name = "youtubetoany.com"
RADIOIFACE.priority = 1000
RADIOIFACE.disabled = false

local es = RADIOIFACE.errorspace

local ERROR_NO_API = es + 0
local ERROR_INVALID_JSON = es + 1
local ERROR_INVALID_ID = es + 2
local ERROR_NO_URL = es + 3

local youtube_error_note = RADIOIFACE.parent.youtube_error_note
local youtube_error_end = RADIOIFACE.parent.youtube_error_end
local youtube_help_url = RADIOIFACE.parent.youtube_help_url

RADIOIFACE.Errorcodes[ERROR_NO_API] = {
	desc = "Converter API not available",
	text = [[
The converter API is not available.

]] .. youtube_error_end,
	url = youtube_help_url,
}

RADIOIFACE.Errorcodes[ERROR_INVALID_JSON] = {
	desc = "Invalid converter data",
	text = [[
The converter API is not available or the access has been denied.

]] .. youtube_error_end,
	url = youtube_help_url,
}

RADIOIFACE.Errorcodes[ERROR_INVALID_ID] = {
	desc = "Invalid ID was given",
	text = [[
An invalid video ID was given.

Notes:
  - Make sure you enter a YouTube URL of an existing video.
  - Do not try to play from YouTube playlists or channels. Those are not supported.
  - Make sure the video is not blocked.

]] .. youtube_error_note,
	url = "",
}

RADIOIFACE.Errorcodes[ERROR_NO_URL] = {
	desc = "No MP3 URL was found",
	text = [[
The MP3 URL was not found or it is invalid.

]] .. youtube_error_end,
	url = youtube_help_url,
}

function RADIOIFACE:CheckConvertCondition(...)
	return self.parent:CheckConvertCondition(...)
end

function RADIOIFACE:Convert(url, callback, id)
	local function recaller(attempt)
		attempt = attempt or 0
		if attempt > 3 then
			return false
		end

		if not self:CheckConvertCondition(url, callback) then
			return true
		end

		self:Request("https://youtubetoany.com/en/@api/json/mp3/" .. StreamRadioLib.URLEncode(id), function(suggess, data)
			if not self:CheckConvertCondition(url, callback) then
				return
			end

			if not suggess then
				if recaller(attempt + 1) then return end

				callback(self, false, nil, ERROR_NO_API, data)
				return
			end

			local body = string.Trim(data.body)

			if body == "" then
				if recaller(attempt + 1) then return end

				callback(self, false, nil, ERROR_NO_API, data)
				return
			end

			local json = self:GetJSON(body)
			if not json then
				if recaller(attempt + 1) then return end

				callback(self, false, nil, ERROR_INVALID_JSON, data)
				return
			end

			if json.error then
				if recaller(attempt + 1) then return end

				callback(self, false, nil, ERROR_INVALID_ID, data)
				return
			end

			local title = json.vidTitle or ""

			if title == "" then
				title = "Unknown Title"
			end

			local vidtable = json.vidInfo or {}

			if #vidtable <= 0 then
				if recaller(attempt + 1) then return end

				callback(self, false, nil, ERROR_NO_URL, data)
				return
			end

			local tmp = {}
			for k, v in pairs(vidtable) do
				local dlurl = tostring(v.dloadUrl or "")
				if dlurl == "" then continue end

				local bitrate = self:ConvertBitrate(v.bitrate)
				if bitrate >= 0 then
					bitrate = bitrate / 1000 ^ 2
				end

				bitrate = math.floor(bitrate)

				local size = v.mp3size or v.rSize or v.size
				size = self:ConvertFileSize(size)

				tmp[#tmp + 1] = {
					url = dlurl,
					bitrate = bitrate,
					size = size,
				}
			end

			vidtable = tmp
			table.SortByMember(vidtable, "bitrate", false)

			local download = nil
			for i, v in ipairs(vidtable) do
				if v.bitrate > self.parent.MaxBitrate then continue end

				download = v
				break
			end

			if not download then
				if recaller(attempt + 1) then return end

				callback(self, false, nil, ERROR_NO_URL, data)
				return
			end

			local downloadurl = download.url

			data.custom_data.meta = {}
			data.custom_data.meta.title = title
			data.custom_data.meta.filesize = download.size
			data.custom_data.meta.subinterface = self
			data.custom_data.meta.interface = self.parent
			data.custom_data.meta.download = true

			downloadurl = string.gsub(downloadurl, "^//", "https://")

			callback(self, true, downloadurl, nil, data)
		end)

		return true
	end

	recaller()
	return true
end
