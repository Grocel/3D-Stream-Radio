local StreamRadioLib = StreamRadioLib

StreamRadioLib.Cfchttp = StreamRadioLib.Cfchttp or {}

local LIB = StreamRadioLib.Cfchttp
table.Empty(LIB)

local g_emptyFunction = function() end

-- API Wrapper for CFC HTTP Whitelist
-- https://github.com/CFC-Servers/cfc_cl_http_whitelist

function LIB.IsInstalled()
	return istable(CFCHTTP)
end

function LIB.CanCheckWhitelist()
	if not LIB.IsInstalled() then
		return false
	end

	if not isfunction(CFCHTTP.GetOptionsForURL) then
		return false
	end

	return true
end

function LIB.CanLog()
	if not LIB.IsInstalled() then
		return false
	end

	if not isfunction(CFCHTTP.GetOptionsForURL) then
		return false
	end

	if not isfunction(CFCHTTP.LogRequest) then
		return false
	end

	return true
end

local function logUrl(url, options)
	if not LIB.CanLog() then
		return
	end

	-- Reimplemented as in:
	-- https://github.com/CFC-Servers/cfc_cl_http_whitelist/blob/265ce54eea0f386c6eb0390fe31f329f905b9d1f/lua/cfc_http_restrictions/wraps/playURL.lua#L15C1-L19C48

	local stack = string.Split( debug.traceback(), "\n" )

	local isAllowed = options and options.allowed
	local noisy = options and options.noisy

	local logData = {
		noisy = noisy,
		method = "GET",
		fileLocation = stack[4],
		urls = {
			{
				url = url,
				status = isAllowed and "allowed" or "blocked"
			}
		},
	}

	CFCHTTP.LogRequest(logData)
end

function LIB.LogRequestForURL(url)
	if not LIB.CanLog() then
		return
	end

	local options = CFCHTTP.GetOptionsForURL(url)

	logUrl(url, options)
end

function LIB.IsAllowedSync(url, logFailure)
	if not LIB.CanCheckWhitelist() then
		return true
	end

	if StreamRadioLib.Url.IsOfflineURL(url) then
		-- Offline file paths are always safe to use
		return true
	end

	local options = CFCHTTP.GetOptionsForURL(url)
	local isAllowed = options and options.allowed

	if isAllowed then
		return true
	end

	if logFailure then
		logUrl(url, options)
	end

	return false
end

function LIB.IsAllowedAsync(url, callback, logFailure)
	url = tostring(url or "")
	callback = callback or g_emptyFunction

	local result = LIB.IsAllowedSync(url, logFailure)
	callback(result)
end

local function addCfcErrorCodes()
	-- Handle CFC HTTP Whitelist custom error cases

	if CFCHTTP.BASS_ERROR_BLOCKED_URI then
		StreamRadioLib.Error.AddStreamErrorCode({
			id = CFCHTTP.BASS_ERROR_BLOCKED_URI,
			name = "STREAM_ERROR_CFCHTTP_BLOCKED_URI",
			description = "[CFC HTTP Whitelist] URI has been blocked",
			helpurl = "https://steamcommunity.com/workshop/filedetails/discussion/246756300/3884977551668766829/",
			helptext = [[
On this server you are protected by CFC HTTP Whitelist.

This URL has been blocked by CFC HTTP Whitelist to prevent abuse.

You can whitelist the URL (or its domain) for your client in the CFC HTTP Whitelist settings.
BE CAREFUL WITH WHAT YOU WHITELIST! Only whitelist URLs you trust! See your console for details.

You can also ask an admin to whitelist the URL in general in their CFC HTTP Whitelist config.
Keep in mind that there probably is a reason why it has not been whitelisted on this server yet.
]],
		})
	end

	if CFCHTTP.BASS_ERROR_BLOCKED_CONTENT then
		StreamRadioLib.Error.AddStreamErrorCode({
			id = CFCHTTP.BASS_ERROR_BLOCKED_CONTENT,
			name = "STREAM_ERROR_CFCHTTP_BLOCKED_CONTENT",
			description = "[CFC HTTP Whitelist] Content has been blocked",
			helpurl = "https://steamcommunity.com/workshop/filedetails/discussion/246756300/3884977551668766829/",
			helptext = [[
On this server you are protected by CFC HTTP Whitelist.

This content has been blocked by CFC HTTP Whitelist to prevent abuse.
The content you are trying to play from contains one or more URLs that have not been whitelisted yet.

You can whitelist the URLs (or their domains) for your client in the CFC HTTP Whitelist settings.
BE CAREFUL WITH WHAT YOU WHITELIST! Only whitelist URLs you trust! See your console for details.

You can also ask an admin to whitelist the content in general in their CFC HTTP Whitelist config.
Keep in mind that there probably is a reason why it has not been whitelisted on this server yet.
]],
		})
	end
end

function LIB.Load()
	if not LIB.IsInstalled() then
		return
	end

	addCfcErrorCodes()
end

return true

