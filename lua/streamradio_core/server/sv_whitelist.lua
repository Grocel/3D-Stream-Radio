local StreamRadioLib = StreamRadioLib

StreamRadioLib.Whitelist = StreamRadioLib.Whitelist or {}

local LIB = StreamRadioLib.Whitelist
table.Empty(LIB)

local LIBUtil = StreamRadioLib.Util
local LIBUrl = StreamRadioLib.Url
local LIBNet = StreamRadioLib.Net
local LIBFilesystem = StreamRadioLib.Filesystem
local LIBTimer = StreamRadioLib.Timer
local LIBPrint = StreamRadioLib.Print
local LIBString = StreamRadioLib.String
local LIBHook = StreamRadioLib.Hook

local g_quickWhitelistPlaylistFolder = "quick-whitelists"

local g_whitelistByUrl = {}
local g_whitelistByPlaylist = {}
local g_whitelistFunction = {}

local g_emptyFunction = function() end

LIBNet.Receive("whitelist_check_url", function(len, ply)
	local url = net.ReadString()
	local ent = net.ReadEntity()

	url = LIBUrl.SanitizeUrl(url)
	if url == "" then
		return
	end

	local context = LIB.BuildContext(ent, ply)

	LIB.IsAllowedAsync(url, context, function(result, blockedByHook)
		LIBNet.Start("whitelist_check_url_result")
			net.WriteString(url)
			net.WriteBool(result)
			net.WriteBool(blockedByHook)
		net.Send(ply)
	end)
end)

local function addToQuickWhitelistPlaylistMsg(url, ply)
	LIB.AddToQuickWhitelistPlaylist(url, ply, function(success, added)
		if not success then
			LIBPrint.Msg(ply, "Stream URL could not be added to quick whitelist")
			return
		end

		if not added then
			LIBPrint.Msg(ply, "Stream URL is quick-whitelisted already")
			return
		end

		LIBPrint.Msg(ply, "Stream URL added to quick whitelist")
	end)
end

local function removeFromQuickWhitelistPlaylistMsg(url, ply)
	LIB.RemoveFromQuickWhitelistPlaylist(url, ply, function(success, removed)
		if not success then
			LIBPrint.Msg(ply, "Stream URL could not be removed from quick whitelist")
			return
		end

		if not removed then
			LIBPrint.Msg(ply, "Stream URL was not quick-whitelisted")
			return
		end

		LIBPrint.Msg(ply, "Stream URL removed from quick whitelist")
	end)
end

LIBNet.Receive("whitelist_quick_whitelist", function(len, ply)
	if not LIBUtil.IsAdmin(ply) then
		return
	end

	local url = net.ReadString()
	local add = net.ReadBool()

	url = LIBUrl.SanitizeUrl(url)
	if url == "" then
		return
	end

	if add then
		addToQuickWhitelistPlaylistMsg(url, ply)
	else
		removeFromQuickWhitelistPlaylistMsg(url, ply)
	end
end)

function LIB.InvalidateCache()
	LIBTimer.Once("Whitelist_InvalidateCache_Debounce", 0.2, function()
		LIBNet.Start("whitelist_clear_cache")
		net.Broadcast()
	end)
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
		context.player = nil
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

	local ply = context.player
	local ent = context.entity

	local isAllowed = LIBHook.RunCustom("UrlIsAllowed", url, ply, ent)

	if isAllowed == false then
		return false, true
	end

	if not StreamRadioLib.IsUrlWhitelistEnabled() then
		-- allow all URLs if the whitelist is disabled
		return true, false
	end

	local playlistPaths = g_whitelistByUrl[url]
	local isWhitelisted = playlistPaths and not table.IsEmpty(playlistPaths)

	if isWhitelisted then
		return true, false
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

	local result, blockedByHook = LIB.IsAllowedSync(url, context)

	if result ~= nil then
		callback(result, blockedByHook or false)
		return
	end

	if not StreamRadioLib.IsUrlWhitelistEnabled() then
		callback(true, false)
		return
	end

	callback(false, false)
end

function LIB.Add(urls, playlistPath)
	if not istable(urls) then
		urls = {urls}
	end

	playlistPath = tostring(playlistPath or "")

	if playlistPath == "" then
		return
	end

	for _, url in pairs(urls) do
		url = tostring(url)

		if url == "" then
			continue
		end

		if LIBUrl.IsOfflineURL(url) then
			continue
		end

		url = LIBUrl.SanitizeOnlineUrl(url)
		if url == "" then
			continue
		end

		g_whitelistByUrl[url] = g_whitelistByUrl[url] or {}
		g_whitelistByUrl[url][playlistPath] = playlistPath

		g_whitelistByPlaylist[playlistPath] = g_whitelistByPlaylist[playlistPath] or {}
		g_whitelistByPlaylist[playlistPath][url] = url
	end
end

function LIB.Remove(urls, playlistPath)
	if not istable(urls) then
		urls = {urls}
	end

	playlistPath = tostring(playlistPath or "")

	if playlistPath == "" then
		return
	end

	for _, url in pairs(urls) do
		url = tostring(url)

		if url == "" then
			continue
		end

		if LIBUrl.IsOfflineURL(url) then
			continue
		end

		url = LIBUrl.SanitizeOnlineUrl(url)
		if url == "" then
			continue
		end

		if g_whitelistByUrl[url] then
			g_whitelistByUrl[url][playlistPath] = nil

			if table.IsEmpty(g_whitelistByUrl[url]) then
				g_whitelistByUrl[url] = nil
			end
		end

		if g_whitelistByPlaylist[playlistPath] then
			g_whitelistByPlaylist[playlistPath][url] = nil
		end
	end

	if table.IsEmpty(g_whitelistByPlaylist[playlistPath]) then
		g_whitelistByPlaylist[playlistPath] = nil
	end
end

function LIB.RemoveByPlaylist(playlistPath)
	playlistPath = tostring(playlistPath or "")

	if playlistPath == "" then
		return
	end

	local urls = g_whitelistByPlaylist[playlistPath]
	if not urls then
		return
	end

	LIB.Remove(urls, playlistPath)
end

function LIB.RemoveByUrl(url)
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

	local playlistPaths = g_whitelistByUrl[url]

	if not playlistPaths then
		return
	end

	for _, playlistPath in pairs(playlistPaths) do
		if not g_whitelistByUrl[playlistPath] then
			continue
		end

		g_whitelistByPlaylist[playlistPath][url] = nil

		if table.IsEmpty(g_whitelistByUrl[playlistPath]) then
			g_whitelistByPlaylist[playlistPath] = nil
		end
	end

	g_whitelistByUrl[url] = nil
end

function LIB.UpdateFromPlaylist(playlistPath, urls)
	playlistPath = tostring(playlistPath or "")

	if playlistPath == "" then
		return
	end

	LIB.RemoveByPlaylist(playlistPath)
	LIB.Add(urls, playlistPath)
end

local function quickWhitelistLog(ply, msgstring, ...)
	msgstring = tostring(msgstring or "")
	if msgstring == "" then return end

	msgstring = LIBPrint.Format("QUICK WHITELIST - " .. msgstring, ...)

	LIBPrint.Log(ply, msgstring)
end

local function getFilenameByPlayer(ply)
	local steamId = ply:SteamID()
	steamId = string.Replace(steamId, ":", "-")

	local filename = string.format("quick_wl_[%s].json", steamId)
	filename = LIBString.SanitizeFilename(filename)

	return filename
end

function LIB.AddToQuickWhitelistPlaylist(urls, ply, callback)
	callback = callback or g_emptyFunction

	if not LIBUtil.IsAdmin(ply) then
		callback(false, false)
		return
	end

	if not istable(urls) then
		urls = {urls}
	end

	local playerFileName = getFilenameByPlayer(ply)
	local playerFilepath = string.format("%s/%s", g_quickWhitelistPlaylistFolder, playerFileName)

	playerFilepath = LIBString.SanitizeFilepath(playerFilepath)

	LIBFilesystem.Read(playerFilepath, "json", function(_, data)
		if not LIBUtil.IsAdmin(ply) then
			callback(false, false)
			return
		end

		data = data or {}
		local urlIndex = {}

		for k, item in pairs(data) do
			local thisurl = item.url

			if not thisurl then
				continue
			end

			urlIndex[thisurl] = true
		end

		local addedCount = 0
		local hadValidUrls = false
		local singleUrl = nil

		for _, url in ipairs(urls) do
			url = tostring(url)

			if url == "" then
				continue
			end

			if LIBUrl.IsOfflineURL(url) then
				continue
			end

			url = LIBUrl.SanitizeOnlineUrl(url)
			if url == "" then
				continue
			end

			hadValidUrls = true

			if urlIndex[url] then
				continue
			end

			table.insert(data, {
				url = url
			})

			addedCount = addedCount + 1
			singleUrl = url
		end

		if not hadValidUrls then
			quickWhitelistLog(ply, "Can not add to '%s', no valid URLs given", playerFilepath)
			callback(false, false)
			return
		end

		if addedCount <= 0 then
			callback(true, false)
			return
		end

		if addedCount > 1 then
			singleUrl = nil
		end

		LIBFilesystem.CreateFolder(g_quickWhitelistPlaylistFolder, function(success)
			if not LIBUtil.IsAdmin(ply) then
				callback(false, false)
				return
			end

			if not success then
				quickWhitelistLog(ply, "Couldn't create folder '%s' for '%s'", g_quickWhitelistPlaylistFolder, playerFilepath)
				callback(false, false)
				return
			end

			LIBFilesystem.Write(playerFilepath, "json", data, function(success)
				if not success then
					quickWhitelistLog(ply, "Couldn't write to '%s'", playerFilepath)
					callback(false, false)
					return
				end

				if singleUrl then
					quickWhitelistLog(ply, "Added URL '%s' to '%s'", singleUrl, playerFilepath)
				else
					quickWhitelistLog(ply, "Added %i URLs to '%s'", addedCount, playerFilepath)
				end

				callback(true, true)
			end)
		end)
	end)
end

function LIB.RemoveFromQuickWhitelistPlaylist(urls, ply, callback)
	callback = callback or g_emptyFunction

	if not LIBUtil.IsAdmin(ply) then
		callback(false, false)
		return
	end

	if not istable(urls) then
		urls = {urls}
	end

	local playerFileName = getFilenameByPlayer(ply)
	local playerFilepath = string.format("%s/%s", g_quickWhitelistPlaylistFolder, playerFileName)

	playerFilepath = LIBString.SanitizeFilepath(playerFilepath)

	LIBFilesystem.Read(playerFilepath, "json", function(_, data)
		if not LIBUtil.IsAdmin(ply) then
			callback(false, false)
			return
		end

		data = data or {}

		local newData = {}
		local urlsToRemove = {}

		local hadValidUrls = false

		for _, url in ipairs(urls) do
			url = tostring(url)

			if url == "" then
				continue
			end

			if LIBUrl.IsOfflineURL(url) then
				continue
			end

			url = LIBUrl.SanitizeOnlineUrl(url)
			if url == "" then
				continue
			end

			urlsToRemove[url] = true
			hadValidUrls = true
		end

		if not hadValidUrls then
			quickWhitelistLog(ply, "Can not remove from '%s', no valid URLs given", playerFilepath)
			callback(false, false)
			return
		end

		local removedCount = 0
		local singleUrl = nil

		for k, item in pairs(data) do
			local thisurl = item.url

			if not thisurl then
				continue
			end

			if urlsToRemove[thisurl] then
				removedCount = removedCount + 1
				singleUrl = thisurl
				continue
			end

			table.insert(newData, item)
		end

		if removedCount <= 0 then
			callback(true, false)
			return
		end

		if removedCount > 1 then
			singleUrl = nil
		end

		LIBFilesystem.CreateFolder(g_quickWhitelistPlaylistFolder, function(success)
			if not LIBUtil.IsAdmin(ply) then
				callback(false, false)
				return
			end

			if not success then
				quickWhitelistLog(ply, "Couldn't create folder '%s' for '%s'", g_quickWhitelistPlaylistFolder, playerFilepath)
				callback(false, false)
				return
			end

			if table.IsEmpty(newData) then
				LIBFilesystem.Delete(playerFilepath, "json", function(success)
					if not success then
						quickWhitelistLog(ply, "Couldn't delete '%s'", playerFilepath)
						callback(false, false)
						return
					end

					if singleUrl then
						quickWhitelistLog(ply, "Removed URL '%s' from '%s' and deleted the file", singleUrl, playerFilepath)
					else
						quickWhitelistLog(ply, "Removed %i URLs from '%s' and deleted the file", removedCount, playerFilepath)
					end

					callback(true, true)
				end)
			else
				LIBFilesystem.Write(playerFilepath, "json", newData, function(success)
					if not success then
						quickWhitelistLog(ply, "Couldn't write to '%s'", playerFilepath)
						callback(false, false)
						return
					end

					if singleUrl then
						quickWhitelistLog(ply, "Removed URL '%s' from '%s'", singleUrl, playerFilepath)
					else
						quickWhitelistLog(ply, "Removed %i URLs from '%s'", removedCount, playerFilepath)
					end

					callback(true, true)
				end)
			end
		end)
	end)
end

local g_taskId = nil

local function BuildWhitelistInternal()
	LIBUtil.EmptyTableSafe(g_whitelistByUrl)
	LIBUtil.EmptyTableSafe(g_whitelistByPlaylist)

	g_taskId = LIBUtil.Uid()
	local currentTaskId = g_taskId

	local recursiveLookup = nil

	recursiveLookup = function(success, files)
		if g_taskId ~= currentTaskId then
			-- don't run this async process when it is restarted
			return
		end

		if not files then
			return
		end

		for _, fileEntry in ipairs(files) do
			local isfolder = fileEntry.isfolder
			local filetype = fileEntry.type
			local fsid = fileEntry.fsid
			local path = fileEntry.path

			if not LIBFilesystem.CanLoadToWhitelist(fsid) then
				continue
			end

			if isfolder then
				LIBFilesystem.Find(path, recursiveLookup)
			else
				LIBFilesystem.Read(path, filetype)
			end
		end
	end

	LIBFilesystem.Find("", recursiveLookup)
end

function LIB.Load()
	BuildWhitelistInternal()
end

function LIB.BuildWhitelist()
	BuildWhitelistInternal()
	LIB.InvalidateCache()
end

do
	local function ReloadWhitelist(ply, cmd, args)
		if not StreamRadioLib then return end
		if not StreamRadioLib.Loaded then return end

		if not LIBUtil.IsAdminForCMD(ply) then
			StreamRadioLib.Print.Msg(ply, "You need to be an admin to reload the Stream URL Whitelist.")

			return
		end

		LIB.BuildWhitelist()

		StreamRadioLib.Print.Msg(ply, "Stream URL Whitelist reloaded")
	end

	concommand.Add("sv_streamradio_url_whitelist_reload", ReloadWhitelist)
end

return true

