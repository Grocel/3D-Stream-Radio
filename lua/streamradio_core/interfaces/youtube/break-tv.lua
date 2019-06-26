local RADIOIFACE = RADIOIFACE
if not istable( RADIOIFACE ) then
	StreamRadioLib.Interface.Load()
	return
end

RADIOIFACE.name = "break.tv"
RADIOIFACE.priority = 2000
RADIOIFACE.disabled = false

local es = RADIOIFACE.errorspace

local ERROR_NO_API = es + 0
local ERROR_INVALID_COREID = es + 1
local ERROR_INVALID_HASH = es + 2
local ERROR_ACCESS = es + 3

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

RADIOIFACE.Errorcodes[ERROR_ACCESS] = {
	desc = "No ACCESS to the API",
	text = [[
The converter API is not available or the access has been denied.

]] .. youtube_error_end,
	url = youtube_help_url,
}

RADIOIFACE.Errorcodes[ERROR_INVALID_COREID] = {
	desc = "Invalid converter CoreID",
	text = [[
The converter API is not available or the access has been denied.

]] .. youtube_error_end,
	url = youtube_help_url,
}

RADIOIFACE.Errorcodes[ERROR_INVALID_HASH] = {
	desc = "Invalid converter hash",
	text = [[
The converter API has denied the access or the file is timed out.

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

		self:Request("https://break.tv/widget/button/", function(suggess, data)
			if not self:CheckConvertCondition(url, callback) then
				return
			end

			if not suggess then
				if recaller(attempt + 1) then return end

				callback(self, false, nil, ERROR_NO_API, data)
				return
			end

			local coreid = string.Trim(string.match(data.body, "https?%://d(%d+)%.ytcore%.org/") or "")
			if coreid == "" then
				if recaller(attempt + 1) then return end

				callback(self, false, nil, ERROR_INVALID_COREID, data)
				return
			end

			local title = string.Trim(string.match(data.body, "%<input[%s]+type%=\"hidden\"[%s]+class%=\"video%-title%-hidden\"[%s]+value%=\"([ -~]-)\"[%s]*/%>") or "")
			if title == "" then
				title = "Unknown Title"
			end

			local coreservername = "d" .. coreid .. ".ytcore.org"
			local unixtime = os.time()

			local hashrequestdata = {
				idv = id,
				type = "mp3",
				qu = tostring(self.parent.MaxBitrate),
				title = title,
				server = "https://" .. coreservername .. "/",
				i = "",
				["_"] = unixtime,
				callback = "",
			}

			self:Request("https://" .. coreservername .. "/widget1/dl.php", function(suggess, data)
				if not self:CheckConvertCondition(url, callback) then
					return
				end

				if not suggess then
					if recaller(attempt + 1) then return end

					callback(self, false, nil, ERROR_INVALID_COREID, data)
					return
				end

				local body = string.Trim(data.body)

				if body == "Access Denied" then
					if recaller(attempt + 1) then return end

					callback(self, false, nil, ERROR_ACCESS, data)
					return
				end

				local json = self:GetJSON(body)
				if not json then
					if recaller(attempt + 1) then return end

					callback(self, false, nil, ERROR_INVALID_HASH, data)
					return
				end

				local hash = json.success or ""

				if hash == "" then
					if recaller(attempt + 1) then return end

					callback(self, false, nil, ERROR_INVALID_HASH, data)
					return
				end

				local downloadurl = "https://d" .. coreid .. ".ytcore.org/sse1/?jobid=" .. StreamRadioLib.URLEncode(hash)

				data.custom_data.meta = {}
				data.custom_data.meta.title = title
				data.custom_data.meta.filesize = -1
				data.custom_data.meta.subinterface = self
				data.custom_data.meta.interface = self.parent
				data.custom_data.meta.download = true

				callback(self, true, downloadurl, nil, data)
			end, hashrequestdata, "POST")
		end, {
			link = "https://www.youtube.com/watch?v=" .. id,
			color = "000000",
			text = "FFFFFF",
		})

		return true
	end

	recaller()
	return true
end
