local StreamRadioLib = StreamRadioLib

StreamRadioLib.Stream = StreamRadioLib.Stream or {}
local LIB = StreamRadioLib.Stream

local LIBUtil = StreamRadioLib.Util
local LIBUrl = StreamRadioLib.Url
local LIBError = StreamRadioLib.Error

local catchAndErrorNoHaltWithStack = LIBUtil.CatchAndErrorNoHaltWithStack

local function buildMode(bass3Mode, play3D, noBlock)
	local mode = nil

	if bass3Mode then
		mode = BASS3.ENUM.MODE_NOPLAY

		if play3D then
			mode = bit.bor(mode, BASS3.ENUM.MODE_3D)
		end

		if noBlock then
			mode = bit.bor(mode, BASS3.ENUM.MODE_NOBLOCK)
		end

		return mode
	end

	mode = "noplay "

	if play3D then
		mode = mode .. "3d "
	end

	if noBlock then
		mode = mode .. "noblock "
	end

	mode = string.Trim(mode)

	return mode
end

function LIB.PlayOffline(url, bass3Mode, play3D, noBlock, callback)
	local safeCallback = function(...)
		catchAndErrorNoHaltWithStack(callback, ...)
	end

	-- Avoid playing non existing files to avoid crashing
	if not file.Exists(url, "GAME") then
		safeCallback(nil, LIBError.STREAM_ERROR_FILEOPEN)
		return true
	end

	local mode = buildMode(bass3Mode, play3D, noBlock)

	url = LIBUrl.SanitizeOfflineUrl(url)

	if bass3Mode then
		return BASS3.PlayFile(url, mode, safeCallback)
	end

	sound.PlayFile(url, mode, safeCallback)
	return true
end

function LIB.PlayOnline(url, bass3Mode, play3D, noBlock, callback)
	local safeCallback = function(...)
		catchAndErrorNoHaltWithStack(callback, ...)
	end

	url = LIBUrl.SanitizeOnlineUrl(url)

	local mode = buildMode(bass3Mode, play3D, noBlock)

	if bass3Mode then
		return BASS3.PlayURL(url, mode, safeCallback)
	end

	sound.PlayURL(url, mode, safeCallback)
	return true
end

return true

