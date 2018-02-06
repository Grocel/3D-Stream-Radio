local RADIOIFACE = RADIOIFACE
if not istable( RADIOIFACE ) then
	StreamRadioLib.Interface.Load()
	return
end

RADIOIFACE.name = "youtube-mp3.info"
RADIOIFACE.priority = 3000
RADIOIFACE.disabled = false

local es = RADIOIFACE.errorspace

local ERROR_NO_API = es + 0
local ERROR_NO_URL = es + 1

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

		self:Request("http://youtube-mp3.info/yt-api.php", function(suggess, data)
			if not self:CheckConvertCondition(url, callback) then
				return
			end

			if not suggess then
				if recaller(attempt + 1) then return end

				callback(self, false, nil, ERROR_NO_API, data)
				return
			end

			local curdata = data.body
			local founddownloads = {}
			local i = 0

			while true do
				i = i + 1
				if curdata == "" then break end

				local curblock, nextdata = string.match(curdata, "[%s]*%<div[%s]+class%=\"link\"%>(.-)%</div%>(.*)")

				curblock = curblock or ""
				nextdata = nextdata or ""

				if curblock == "" then break end
				if nextdata == "" then break end

				local url, linkbody = string.match(curblock, "%<a[%s]+href%=\"(.-)\".-%>(.+)%</a%>")

				url = url or ""
				linkbody = linkbody or ""

				if url == "" then break end
				if linkbody == "" then break end

				local linkdata = {}
				local pattern = "%<span.-%>(.-)%</span%>"

				for v in string.gmatch(linkbody, pattern) do
					linkdata[#linkdata + 1] = v
				end

				local format = string.Trim(string.lower(linkdata[1] or ""))
				if format == "" then break end

				local bitrate = self:ConvertBitrate(linkdata[2])
				if bitrate >= 0 then
					bitrate = bitrate / 1000
				end

				bitrate = math.floor(bitrate)

				local size = self:ConvertFileSize(linkdata[3])

				founddownloads[#founddownloads + 1] = {
					url = url,
					format = format,
					bitrate = bitrate,
					size = size,
				}

				curdata = nextdata
			end

			table.SortByMember(founddownloads, "bitrate", false)

			local download = nil
			for i, v in ipairs(founddownloads) do
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
			data.custom_data.meta.title = "Unknown Title"
			data.custom_data.meta.filesize = download.size
			data.custom_data.meta.subinterface = self
			data.custom_data.meta.interface = self.parent
			data.custom_data.meta.download = true

			downloadurl = string.gsub(downloadurl, "^//", "https://")

			-- Get the title from some where else
			self:Request("https://youtubetoany.com/en/@api/json/mp3/" .. StreamRadioLib.URLEncode(id), function(suggess, hdata)
				if not self:CheckConvertCondition(url, callback) then
					return
				end

				if not suggess then
					callback(self, true, downloadurl, nil, data)
					return
				end

				local body = string.Trim(hdata.body)

				if body == "" then
					callback(self, true, downloadurl, nil, data)
					return
				end

				local json = self:GetJSON(body)
				if not json then
					callback(self, true, downloadurl, nil, data)
					return
				end

				if json.error then
					callback(self, true, downloadurl, nil, data)
					return
				end

				local title = json.vidTitle or ""

				if title == "" then
					title = "Unknown Title"
				end

				data.custom_data.meta.title = title
				callback(self, true, downloadurl, nil, data)
			end)
		end, {
			id = id,
		})

		return true
	end

	recaller()
	return true
end
