local StreamRadioLib = StreamRadioLib

StreamRadioLib.Whitelist = StreamRadioLib.Whitelist or {}

local LIB = StreamRadioLib.Whitelist
table.Empty(LIB)

local LIBUtil = StreamRadioLib.Util
local LIBUrl = StreamRadioLib.Url
local LIBNet = StreamRadioLib.Net

local g_whitelistCache = LIBUtil.CreateCacheArray(2048)
local g_whitelistCallbacks = {}
local g_whitelistFunction = {}

StreamRadioLib.Hook.Add("PostCleanupMap", "reset_cache_url_whitelist", function()
	LIB.InvalidateCache()
end)

local g_emptyFunction = function() end

local function callCallbacks(result, url)
	local callbacks = g_whitelistCallbacks[url]
	g_whitelistCallbacks[url] = nil

	if not callbacks then
		return
	end

	for _, callback in ipairs(callbacks) do
		callback(result)
	end
end

LIBNet.Receive("whitelist_check_url_result", function()
	local url = net.ReadString()
	local result = net.ReadBool()

	url = LIBUrl.SanitizeUrl(url)
	if url == "" then
		return
	end

	g_whitelistCache:Set(url, result)

	callCallbacks(result, url)
end)

LIBNet.Receive("whitelist_clear_cache", function()
	LIB.InvalidateCache()
end)

function LIB.InvalidateCache()
	g_whitelistCache:Empty()
end

local function callCheckFunctions(url)
	for name, func in pairs(g_whitelistFunction) do
		local result = func(url)

		if result == nil then
			continue
		end

		return result
	end

	return false
end

function LIB.AddCheckFunction(name, func)
	g_whitelistFunction[name] = func
end

function LIB.IsAllowedSync(url)
	url = tostring(url or "")

	if url == "" then
		return false
	end

	if LIBUrl.IsOfflineURL(url) then
		return true
	end

	url = LIBUrl.SanitizeOnlineUrl(url)
	if url == "" then
		return false
	end

	if not StreamRadioLib.IsUrlWhitelistEnabled() then
		-- allow all URLs if the whitelist is disabled
		return true
	end

	if callCheckFunctions(url) then
		return true
	end

	if g_whitelistCache:Has(url) then
		local result = g_whitelistCache:Get(url)
		return result
	end

	return nil
end

function LIB.IsAllowedAsync(url, callback)
	url = tostring(url or "")
	callback = callback or g_emptyFunction

	local result = LIB.IsAllowedSync(url)

	if result ~= nil then
		callback(result)
		return
	end

	local callbacks = g_whitelistCallbacks[url] or {}
	g_whitelistCallbacks[url] = callbacks

	local hasSend = #callbacks > 0
	table.insert(callbacks, callback)

	if not hasSend then
		LIBNet.Start("whitelist_check_url")
			net.WriteString(url)
		net.SendToServer()
	end
end

function LIB.QuickWhitelistAdd(url)
	if not LIBUtil.IsAdmin() then
		return
	end

	url = tostring(url or "")

	if url == "" then
		return
	end

	if LIBUrl.IsOfflineURL(url) then
		return
	end

	url = LIBUrl.SanitizeOnlineUrl(url)
	if url == "" then
		return
	end

	LIBNet.Start("whitelist_quick_whitelist")
		net.WriteString(url)
		net.WriteBool(true)
	net.SendToServer()
end

function LIB.QuickWhitelistRemove(url)
	if not LIBUtil.IsAdmin() then
		return
	end

	url = tostring(url or "")

	if url == "" then
		return
	end

	if LIBUrl.IsOfflineURL(url) then
		return
	end

	url = LIBUrl.SanitizeOnlineUrl(url)
	if url == "" then
		return
	end

	LIBNet.Start("whitelist_quick_whitelist")
		net.WriteString(url)
		net.WriteBool(false)
	net.SendToServer()
end

return true

