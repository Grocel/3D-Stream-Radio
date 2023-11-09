local StreamRadioLib = StreamRadioLib

StreamRadioLib.Url = StreamRadioLib.Url or {}

local LIB = StreamRadioLib.Url
table.Empty(LIB)

local LIBUtil = StreamRadioLib.Util
local LIBNetURL = StreamRadioLib.NetURL
local LIBString = StreamRadioLib.String

local g_sanitizeOnlineUrlCache = LIBUtil.CreateCacheArray(2048)
local g_sanitizeOfflineUrlCache = LIBUtil.CreateCacheArray(2048)
local g_isOfflineURLCache = LIBUtil.CreateCacheArray(2048)

local function GetProtocol(url)
	url = tostring(url or "")

	local protocol = string.match(url, "^([%w_][%w_]+):[//\\][//\\]") or ""
	protocol = string.Trim(protocol)
	protocol = string.lower(protocol)

	return protocol
end

local function SplittProtocolAndPath(url)
	local protocol = GetProtocol(url)

	if protocol == "" then
		return "", url
	end

	local path = string.match(url, ":[//\\][//\\]([ -~]+)$")
	return protocol, path
end

local function SplittDriveLetterAndPath(url)
	url = tostring(url or "")

	local letter, path = string.match(url, "^(%a):[//\\]+([ -~]+)$")

	letter = letter or ""
	path = path or ""

	if letter == "" then
		return "", url
	end

	if path == "" then
		return "", url
	end

	letter = string.Trim(letter)
	letter = string.lower(letter)

	return letter, path
end

local function ConcatProtocolAndPath(protocol, path)
	protocol = tostring(protocol or "")
	path = tostring(path or "")

	if protocol == "" then
		return path
	end

	local url = string.format("%s://%s", protocol, path)
	return url
end

local function ConcatDriveLetterAndPath(letter, path)
	letter = tostring(letter or "")
	path = tostring(path or "")

	if letter == "" then
		return path
	end

	local url = string.format("%s:/%s", letter, path)
	return url
end


function LIB.SplittProtocolAndPath(url)
	return SplittProtocolAndPath(url)
end

function LIB.IsOfflineURL(url)
	url = tostring(url or "")

	if url == "" then
		return false
	end

	if g_isOfflineURLCache:Has(url) then
		return g_isOfflineURLCache:Get(url)
	end

	g_isOfflineURLCache:Set(url, true)

	local letter = SplittDriveLetterAndPath(url)

	if letter ~= "" then
		-- drive letter paths (C:/, C://) are offline too, even though we explicitly ban them later
		return true
	end

	local protocol = GetProtocol(url)

	if protocol == "" then
		return true
	end

	if protocol == "file" then
		return true
	end

	g_isOfflineURLCache:Set(url, false)
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

function LIB.SanitizeUrl(url)
	url = tostring(url or "")

	if url == "" then
		return ""
	end

	if LIB.IsOfflineURL(url) then
		return LIB.SanitizeOfflineUrl(url)
	end

	return LIB.SanitizeOnlineUrl(url)
end

function LIB.SanitizeOnlineUrl(url)
	url = tostring(url or "")

	if url == "" then
		return ""
	end

	local cacheId = url

	if g_sanitizeOnlineUrlCache:Has(cacheId) then
		return g_sanitizeOnlineUrlCache:Get(cacheId)
	end

	url = SanitizeUrlInternal(url)

	url = LIBNetURL.normalize(url)
	url = tostring(url)

	url = string.sub(url, 0, StreamRadioLib.STREAM_URL_MAX_LEN_ONLINE)
	url = string.Trim(url)

	g_sanitizeOnlineUrlCache:Set(cacheId, url)
	g_sanitizeOnlineUrlCache:Set(url, url)

	return url
end

function LIB.SanitizeOfflineUrl(url)
	url = tostring(url or "")

	if url == "" then
		return ""
	end

	local cacheId = url

	if g_sanitizeOfflineUrlCache:Has(cacheId) then
		return g_sanitizeOfflineUrlCache:Get(cacheId)
	end

	if not LIB.IsValidURL(url) then
		return ""
	end

	url = SanitizeUrlInternal(url)

	local letter, letterPath = SplittDriveLetterAndPath(thisPath)
	if letter ~= "" then
		letterPath = LIBString.NormalizeSlashes(letterPath)
		letterPath = string.TrimLeft(letterPath, "/")

		url = ConcatDriveLetterAndPath(letter, letterPath)
	else
		local protocol, protocolPath = SplittProtocolAndPath(url)

		protocolPath = LIBString.NormalizeSlashes(protocolPath)
		protocolPath = string.TrimLeft(protocolPath, "/")

		url = ConcatProtocolAndPath(protocol, protocolPath)
	end

	url = string.sub(url, 0, StreamRadioLib.STREAM_URL_MAX_LEN_OFFLINE)
	url = string.Trim(url)

	g_sanitizeOfflineUrlCache:Set(cacheId, url)
	g_sanitizeOfflineUrlCache:Set(url, url)

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

	local _, path = SplittProtocolAndPath(url)
	local letter = SplittDriveLetterAndPath(path)

	if letter == "" then
		return false
	end

	return true
end

function LIB.Load()
	StreamRadioLib.Hook.Add("PostCleanupMap", "reset_cache_url", function()
		g_sanitizeOnlineUrlCache:Empty()
		g_sanitizeOfflineUrlCache:Empty()
		g_isOfflineURLCache:Empty()
	end)
end

return true

