local StreamRadioLib = StreamRadioLib

StreamRadioLib.Language = StreamRadioLib.Language or {}

local LIB = StreamRadioLib.Language
table.Empty(LIB)

local g_nameprefix = "3dstreamradio."
local g_translated = {}

function LIB.GetName(identifier)
	identifier = g_nameprefix .. tostring(identifier or "")
	identifier = string.lower(identifier)

	return identifier
end

function LIB.GetPhrase(identifier)
	identifier = LIB.GetName(identifier)

	if g_translated[identifier] then
		return g_translated[identifier]
	end

	local backup = '#' .. identifier
	if g_translated[backup] then
		return g_translated[backup]
	end

	if CLIENT then
		g_translated[identifier] = language.GetPhrase(identifier) or backup
	else
		g_translated[identifier] = backup
	end

	g_translated[backup] = g_translated[identifier]
	return g_translated[identifier]
end

function LIB.Translate(identifier, defaultEnglishText)
	identifier = LIB.GetName(identifier)
	defaultEnglishText = tostring(defaultEnglishText or "")

	if #defaultEnglishText >= 1024 then
		-- Limit by GMod: https://github.com/Facepunch/garrysmod-issues/issues/5524
		error("defaultEnglishText is too long (length >= 1024)")
	end

	if defaultEnglishText == "" then
		defaultEnglishText = nil
	end

	if g_translated[identifier] then
		return g_translated[identifier]
	end

	local backup = '#' .. identifier
	if g_translated[backup] then
		return g_translated[backup]
	end

	if CLIENT then
		if defaultEnglishText then
			language.Add(identifier, defaultEnglishText)
		end

		g_translated[identifier] = language.GetPhrase(identifier) or defaultEnglishText or backup
	else
		g_translated[identifier] = defaultEnglishText or backup
	end

	g_translated[backup] = g_translated[identifier]
	return g_translated[identifier]
end

LIB.T = LIB.Translate

return true

