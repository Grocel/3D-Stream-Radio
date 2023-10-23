local StreamRadioLib = StreamRadioLib

StreamRadioLib.Cfchttp = StreamRadioLib.Cfchttp or {}

local LIB = StreamRadioLib.Cfchttp
table.Empty(LIB)

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

function LIB.IsAllowed(url)
	if not LIB.CanCheckWhitelist() then
		return true
	end

	local options = CFCHTTP.GetOptionsForURL(url)
	local isAllowed = options and options.allowed

	if isAllowed then
		return true
	end

	return false
end

local function addCfcErrorCodes()
	-- Handle CFC HTTP Whitelist custom error cases

	if CFCHTTP.BASS_ERROR_BLOCKED_URI then
		StreamRadioLib.Error.AddStreamErrorCode({
			id = CFCHTTP.BASS_ERROR_BLOCKED_URI,
			name = "STREAM_ERROR_CFCHTTP_BLOCKED_URI",
			description = "URI has been blocked by CFC HTTP Whitelist",
			helptext = [[
The server has blocked this URL via CFC HTTP Whitelist to prevent abuse.
You can ask an admin to whitelist the URL above in their CFC tool.

Keep in mind that there is probably a reason why it is forbidden on this server.
]],
		})
	end

	if CFCHTTP.BASS_ERROR_BLOCKED_CONTENT then
		StreamRadioLib.Error.AddStreamErrorCode({
			id = CFCHTTP.BASS_ERROR_BLOCKED_CONTENT,
			name = "STREAM_ERROR_CFCHTTP_BLOCKED_CONTENT",
			description = "Content has been blocked by CFC HTTP Whitelist",
			helptext = [[
The server has blocked this content via CFC HTTP Whitelist to prevent abuse.
You can ask an admin to whitelist the content from the URL above in their CFC tool.

Keep in mind that there is probably a reason why it is forbidden on this server.
]],
		})
	end
end

local function addCfcHttpWhitelist()
	StreamRadioLib.Whitelist.AddCheckFunction("cfcHttpWhitelist", function(url)
		if not LIB.CanCheckWhitelist() then
			return nil
		end

		if not LIB.IsAllowed(url) then
			return nil
		end

		--[[
			If the URL is allowed by the CFC HTTP Whitelist, we also give it a pass.
			Effectively we extend our playlist based whitelist by the CFC one.
			Hopefully this makes radios a little bit more user friendly on protected servers.

			Note: This addon does not affect the CFC HTTP protection. CFC HTTP still checks all requests of this and other addons!
			So if an URL passes THIS test, it doesn't mean it will be passed by CFC HTTP altogether.
		]]

		return true
	end)
end

function LIB.Load()
	if not LIB.IsInstalled() then
		return
	end

	addCfcErrorCodes()

	if CLIENT then
		addCfcHttpWhitelist()
	end
end

return true

