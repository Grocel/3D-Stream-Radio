local StreamRadioLib = StreamRadioLib

StreamRadioLib.Whitelist = StreamRadioLib.Whitelist or {}

local LIB = StreamRadioLib.Whitelist
table.Empty(LIB)

local LIBUtil = StreamRadioLib.Util
local LIBUrl = StreamRadioLib.Url
local LIBNet = StreamRadioLib.Net
local LIBHook = StreamRadioLib.Hook

local g_whitelistCache = LIBUtil.CreateCacheArray(2048)
local g_whitelistCallbacks = {}
local g_whitelistFunction = {}

StreamRadioLib.Hook.Add("PostCleanupMap", "reset_cache_url_whitelist", function()
	LIB.InvalidateCache()
end)

local g_emptyFunction = function() end

local function callCallbacks(url, ...)
	local callbacksList = g_whitelistCallbacks[url]
	g_whitelistCallbacks[url] = nil

	if not callbacksList then
		return
	end

	for _, callbacks in pairs(callbacksList) do
		for _, callback in ipairs(callbacks) do
			callback(...)
		end
	end
end

LIBNet.Receive("whitelist_check_url_result", function()
	local url = net.ReadString()
	local result = net.ReadBool()
	local blockedByHook = net.ReadBool()

	url = LIBUrl.SanitizeUrl(url)
	if url == "" then
		return
	end

	local now = CurTime()
	local lifetime = blockedByHook and 600 or 3600
	local expires = now + lifetime

	g_whitelistCache:Set(url, {
		result = result,
		blockedByHook = blockedByHook,
	}, expires)

	callCallbacks(url, result, blockedByHook)
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

function LIB.BuildContext(ent, ply)
	context = context or {}

	if not IsValid(ent) or not isentity(ent) then
		ent = nil
	end

	if ent and ent.__IsRadio and not IsValid(ply) then
		ply = ent:GetRealRadioOwner()
	end

	if not IsValid(ply) or not ply:IsPlayer() then
		ply = nil
	end

	context.entity = ent
	context.player = ply

	return context
end

function LIB.SanitizeContext(context)
	context = context or {}

	local ent = context.entity
	local ply = context.player

	if not IsValid(ply) or not ply:IsPlayer() then
		context.player = LocalPlayer()
	end

	if not IsValid(ent) or not isentity(ent) then
		context.entity = nil
	end

	return context
end

function LIB.IsAllowedSync(url, context)
	url = tostring(url or "")

	if url == "" then
		return false, false
	end

	if LIBUrl.IsOfflineURL(url) then
		return true, false
	end

	url = LIBUrl.SanitizeOnlineUrl(url)
	if url == "" then
		return false, false
	end

	context = LIB.SanitizeContext(context)

	local now = CurTime()

	local cacheItem = g_whitelistCache:Get(url, now)
	if cacheItem then
		-- Use cached result instead of asking the server again

		local result = cacheItem.result or false
		local blockedByHook = cacheItem.blockedByHook or false

		return result, blockedByHook
	end

	local ply = context.player
	local ent = context.entity

	local isAllowed = LIBHook.RunCustom("UrlIsAllowed", url, ply, ent)

	if isAllowed == false then
		return false, true
	end

	if not StreamRadioLib.IsUrlWhitelistEnabled() then
		-- allow all URLs if the whitelist is disabled
		return nil, false
	end

	if callCheckFunctions(url) then
		return true, false
	end

	return nil, nil
end

function LIB.IsAllowedAsync(url, context, callback)
	url = tostring(url or "")
	callback = callback or g_emptyFunction

	context = LIB.SanitizeContext(context)
	local ent = context.entity or NULL

	local result, blockedByHook = LIB.IsAllowedSync(url, context)

	if result ~= nil then
		callback(result, blockedByHook or false)
		return
	end

	local callbacksList = g_whitelistCallbacks[url] or {}
	g_whitelistCallbacks[url] = callbacksList

	local callbacks = callbacksList[ent] or {}
	callbacksList[ent] = callbacks

	local hasSend = #callbacks > 0
	table.insert(callbacks, callback)

	if not hasSend then
		LIBNet.Start("whitelist_check_url")
			net.WriteString(url)
			net.WriteEntity(ent)
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

	g_whitelistCache:Remove(url)
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

	g_whitelistCache:Remove(url)
end

function LIB.Load()
	LIB.InvalidateCache()
end

return true

