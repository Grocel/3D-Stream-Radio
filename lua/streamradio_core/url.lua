local StreamRadioLib = StreamRadioLib

StreamRadioLib.Url = StreamRadioLib.Url or {}

local LIB = StreamRadioLib.Url
table.Empty(LIB)

local LIBUtil = StreamRadioLib.Util
local LIBNetURL = StreamRadioLib.NetURL

local g_urlSanitizeOnlineUrlCache = LIBUtil.CreateCacheArray(16384)
local g_urlSanitizeOfflineUrlCache = LIBUtil.CreateCacheArray(16384)
local g_urlIsOfflineURLCache = LIBUtil.CreateCacheArray(16384)

function LIB.IsOfflineURL(url)
	url = tostring(url or "")

	if url == "" then
		return false
	end

	if g_urlIsOfflineURLCache:Has(url) then
		return g_urlIsOfflineURLCache:Get(url)
	end

	url = string.Trim(url)

	local protocol = string.Trim(string.match(url, "^([ -~]+):[//\\][//\\]") or "")

	g_urlIsOfflineURLCache:Set(url, true)

	if protocol == "" then
		return true
	end

	if protocol == "file" then
		return true
	end

	g_urlIsOfflineURLCache:Set(url, false)
	return false
end

function LIB.IsOnlineURL(url)
	return not LIB.IsOfflineURL(url)
end

local function IsBlockedURLCode(url)
	url = url or ""

	local blockedURLCode = StreamRadioLib.BlockedURLCode or ""
	local blockedURLCodeSequence = StreamRadioLib.BlockedURLCodeSequence or ""

	if blockedURLCode == "" then
		return false
	end

	if blockedURLCodeSequence == "" then
		return false
	end

	if url == blockedURLCode then
		return true
	end

	if string.find(url, blockedURLCodeSequence, 1, true) then
		return true
	end

	return false
end

function LIB.IsValidURL(url)
	url = tostring(url or "")

	if url == "" then
		return false
	end

	if IsBlockedURLCode(url) then
		return false
	end

	return true
end

local function SanitizeUrlInternal(url)
	url = tostring(url or "")

	url = string.Trim(url)

	if not LIB.IsValidURL(url) then
		return ""
	end

	url = string.Replace(url, "\n", "")
	url = string.Replace(url, "\r", "")
	url = string.Replace(url, "\t", "")
	url = string.Replace(url, "\b", "")
	url = string.Replace(url, "\v", "")

	url = string.Trim(url)

	return url
end

local function NormalizePath(path)
	path = tostring(path or "")

	local oldpath = path

	while true do
		-- normalize slashes
		path = string.Replace(path, "\\", "/")

		-- we dont climb up
		path = string.Replace(path, "../", "")

		-- normalize dot-slashes
		path = string.Replace(path, "./", "/")

		-- remove double slashes
		path = string.Replace(path, "//", "/")

		if path == oldpath then
			break
		end

		oldpath = path
	end

	path = string.Trim(path)

	return path
end

function LIB.SanitizeUrl(url)
	url = tostring(url or "")

	if url == "" then
		return ""
	end

	if LIB.IsOfflineURL(url) then
		url = LIB.SanitizeOfflineUrl(url)
	else
		url = LIB.SanitizeOnlineUrl(url)
	end

	return url
end

function LIB.SanitizeOnlineUrl(url)
	url = tostring(url or "")

	if url == "" then
		return ""
	end

	local cacheId = url

	if g_urlSanitizeOnlineUrlCache:Has(cacheId) then
		return g_urlSanitizeOnlineUrlCache:Get(cacheId)
	end

	url = SanitizeUrlInternal(url)

	url = LIBNetURL.normalize(url)
	url = tostring(url)

	url = string.sub(url, 0, StreamRadioLib.STREAM_URL_MAX_LEN_ONLINE)
	url = string.Trim(url)

	g_urlSanitizeOnlineUrlCache:Set(cacheId, url)
	g_urlSanitizeOnlineUrlCache:Set(url, url)

	return url
end

function LIB.SanitizeOfflineUrl(url)
	url = tostring(url or "")

	if url == "" then
		return ""
	end

	local cacheId = url

	if g_urlSanitizeOfflineUrlCache:Has(cacheId) then
		return g_urlSanitizeOfflineUrlCache:Get(cacheId)
	end

	url = SanitizeUrlInternal(url)

	url = NormalizePath(url)

	url = string.sub(url, 0, StreamRadioLib.STREAM_URL_MAX_LEN_OFFLINE)
	url = string.Trim(url)

	g_urlSanitizeOfflineUrlCache:Set(cacheId, url)
	g_urlSanitizeOfflineUrlCache:Set(url, url)

	return url
end

function LIB.URIAddParameter(url, parameter)
	if not istable(parameter) then
		parameter = {parameter}
	end

	url = tostring(url or "")
	url = LIBNetURL.normalize(url)

	for k, v in pairs(parameter) do
		url.query[k] = v
	end

	url = tostring(url)
	return url
end

function LIB.IsDriveLetterOfflineURL(url)
	if not LIB.IsOfflineURL(url) then
		return false
	end

	url = string.Trim(url or "")

	local driveLetter = string.Trim(string.match(url, "([a-zA-Z]+):[//\\]") or "")
	if driveLetter == "" then
		return false
	end

	return true
end

function LIB.PrepairURL(url)
	url = LIB.SanitizeUrl(url)

	if LIB.IsOfflineURL(url) then
		local fileurl = LIB.SanitizeOfflineUrl(string.match(url, ":[//\\][//\\]([ -~]+)$") or "")

		if fileurl ~= "" then
			url = fileurl
		end

		url = "sound/" .. url
		url = NormalizePath(url)

		return url, StreamRadioLib.STREAM_URLTYPE_FILE
	end

	local Cachefile = StreamRadioLib.Cache.GetFile(url)

	if Cachefile then
		url = "data/" .. Cachefile
		url = NormalizePath(url)

		return url, StreamRadioLib.STREAM_URLTYPE_CACHE
	end

	local URLType = StreamRadioLib.STREAM_URLTYPE_ONLINE

	return url, URLType
end

function LIB.Load()
	StreamRadioLib.Hook.Add("PostCleanupMap", "reset_cache_url", function()
		g_urlSanitizeOnlineUrlCache:Empty()
		g_urlSanitizeOfflineUrlCache:Empty()
		g_urlIsOfflineURLCache:Empty()
	end)
end

return true

