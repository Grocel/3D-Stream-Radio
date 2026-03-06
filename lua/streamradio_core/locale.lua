local StreamRadioLib = StreamRadioLib
local LIB = StreamRadioLib:NewLib("Locale")

local LIBString = nil
local LIBFile = nil
local LIBPrint = nil
local LIBUtil = nil
local LIBHook = nil

local g_localesDirectory = "streamradio_core/locales"
local g_addonPrefix = "3dstreamradio."

local g_locales = LIB.g_locales or {}
LIB.g_locales = g_locales

local g_nativeLocalesMap = LIB.g_nativeLocalesMap or {}
LIB.g_nativeLocalesMap = g_nativeLocalesMap

local g_nativeTranslationMap = LIB.g_nativeTranslationMap or {}
LIB.g_nativeTranslationMap = g_nativeTranslationMap

local g_failbackLocaleName = "en-us"
local g_debugLocaleName = "_debug"
local g_autoLocaleName = "_auto"

local g_mark = "?"

local g_currentLocale = g_locales[g_failbackLocaleName]
local g_failbackLocale = g_locales[g_failbackLocaleName]
local g_debugLocale = g_locales[g_debugLocaleName]
local g_autoLocale = g_locales[g_autoLocaleName]
local g_cacheId = 0

local g_nextThink = 0
local g_updateNextThink = false
local g_oldDebugMode = false

local function toCodepoint(char)
	local ok, codepoint = pcall(utf8.codepoint, char)

	if not ok or not codepoint then
		return "\\u{FFFD}"
	end

	if codepoint < 0x80 then
		-- ascii codepoint
		return char
	end

	if codepoint < 0xFFFF then
		return string.format("\\u{%04X}", codepoint)
	end

	if codepoint < 0xFFFFFF then
		return string.format("\\u{%06X}", codepoint)
	end

	if codepoint < 0xFFFFFFFF then
		return string.format("\\u{%08X}", codepoint)
	end

	return char
end

function LIB.EscapeUnicode(str)
	str = string.gsub(str, utf8.charpattern, toCodepoint)
	return str
end

local function toUtf8Char(match, codepoint)
	if codepoint ~= string.upper(codepoint) then
		-- Not a valid unicode escape sequence
		return match
	end

	codepoint = tonumber(codepoint, 16)

	if not codepoint then
		return match
	end

	local char = utf8.char(codepoint)
	return char
end

local function toAsciiChar(match, codepoint, ...)
	if match ~= string.upper(match) then
		-- Not a valid ascii escape sequence
		return match
	end

	codepoint = tonumber(codepoint, 16)

	if not codepoint then
		return match
	end

	local char = string.char(codepoint)
	return char
end

function LIB.UnescapeUnicode(str)
	str = string.gsub(str, "\\\\", "\x01")

	str = string.gsub(str, "(\\x%{(%x%x)%}])", toAsciiChar)
	str = string.gsub(str, "(\\x(%x%x))", toAsciiChar)

	str = string.gsub(str, "(\\u%{(%x%x%x%x%x%x%x%x)%})", toUtf8Char)
	str = string.gsub(str, "(\\u%{(%x%x%x%x%x%x)%})", toUtf8Char)
	str = string.gsub(str, "(\\u%{(%x%x%x%x)%})", toUtf8Char)

	str = string.gsub(str, "(\\u%(%x%x%x%x%x%x%x%x)%)", toUtf8Char)
	str = string.gsub(str, "(\\u%(%x%x%x%x%x%x)%)", toUtf8Char)
	str = string.gsub(str, "(\\u%(%x%x%x%x)%)", toUtf8Char)

	str = string.gsub(str, "%\x01", "\\\\")

	return str
end

local function isMarked(identifier)
	if not identifier then
		return false
	end

	if #identifier <= 1 then
		return false
	end

	return identifier[1] == g_mark
end

local function forceMark(identifier)
	if not identifier or identifier == "" then
		return ""
	end

	if identifier[1] ~= g_mark then
		identifier = g_mark .. identifier
	end

	return identifier
end

local function removeMark(identifier)
	if not identifier or identifier == "" then
		return ""
	end

	if identifier[1] == g_mark then
		identifier = string.sub(identifier, 2)
	end

	return identifier
end


local function forceSingleLine(line)
	line = tostring(line or "")
	line = string.gsub(line, "[%s]+", " ")

	return line
end

local function addCommonFunctions(LOCALE)
	if not LOCALE then return end

	LOCALE.author = ""
	LOCALE.locale = ""
	LOCALE.locale_gmod = ""
	LOCALE.title = ""
	LOCALE.titleTranslated = ""
	LOCALE.icon = ""
	LOCALE.normalizeToUnescaped = true

	LOCALE.entries = {}
	LOCALE.isValid = true

	function LOCALE:Set(identifier, translationString, dontMarkForUpdate)
		identifier = tostring(identifier or "")
		translationString = tostring(translationString or "")

		identifier = string.lower(identifier)
		identifier = forceMark(identifier)

		if not LIBString then
			LIBString = StreamRadioLib.String
		end

		translationString = LIB.UnescapeUnicode(translationString)
		translationString = LIBString.NormalizeNewlines(translationString, "\n")

		if translationString == "" then
			-- Make it failback to g_failbackLocale if empty
			translationString = nil
		end

		local oldTranslationString = self.entries[identifier]
		if oldTranslationString == translationString then
			return
		end

		self.entries[identifier] = translationString

		if not dontMarkForUpdate then
			g_updateNextThink = true
		end
	end

	function LOCALE:Get(identifier)
		local translationString = self.entries[identifier]

		if not translationString then
			return nil
		end

		return translationString
	end

	function LOCALE:Clear()
		table.Empty(self.entries)
	end

	function LOCALE:GetAll()
		return self.entries
	end

	function LOCALE:Include(subLocaleFile)
		subLocaleFile = tostring(subLocaleFile or "")
		subLocaleFile = string.Replace(subLocaleFile, "..", "")
		subLocaleFile = string.Trim(subLocaleFile)

		local scriptfile = g_localesDirectory .. "/" .. self.locale .. "/" .. subLocaleFile
		local loaded = StreamRadioLib.LoadSH(scriptfile, true)

		if not loaded then
			self.isValid = false
			return false
		end

		return true
	end
end

local function loadLocaleFile(localeFile)
	localeFile = localeFile or ""
	if localeFile == "" then return false end

	local scriptfile = g_localesDirectory .. "/" .. localeFile

	local tmp = _G.LOCALE
	_G.LOCALE = {}

	local newLocale = _G.LOCALE

	addCommonFunctions(newLocale)

	local loaded = StreamRadioLib.LoadSH(scriptfile, true)
	_G.LOCALE = tmp

	if not loaded then
		return false
	end

	if not newLocale.isValid then
		return false
	end

	local localeName = newLocale.locale

	localeName = forceSingleLine(localeName)
	localeName = string.Trim(localeName)
	localeName = string.lower(localeName)

	local nativeLocaleName = newLocale.locale_gmod

	nativeLocaleName = forceSingleLine(nativeLocaleName)
	nativeLocaleName = string.Trim(nativeLocaleName)
	nativeLocaleName = string.lower(nativeLocaleName)

	if localeName == g_autoLocaleName then
		localeName = nil
	end

	if nativeLocaleName == g_autoLocaleName then
		nativeLocaleName = nil
	end

	if localeName == g_debugLocaleName then
		localeName = nil
	end

	if nativeLocaleName == g_debugLocaleName then
		nativeLocaleName = nil
	end

	if localeName == "" then
		return false
	end

	newLocale.locale = localeName
	newLocale.locale_gmod = nativeLocaleName

	newLocale.title = string.Trim(forceSingleLine(newLocale.title))
	newLocale.titleTranslated = string.Trim(forceSingleLine(newLocale.titleTranslated))
	newLocale.author = string.Trim(forceSingleLine(newLocale.author))
	newLocale.icon = string.Trim(forceSingleLine(newLocale.icon))

	if newLocale.titleTranslated == "" then
		newLocale.titleTranslated = newLocale.title
	end

	if nativeLocaleName ~= "" then
		g_nativeLocalesMap[nativeLocaleName] = localeName
	end

	local oldLocale = g_locales[localeName]

	if not oldLocale or not oldLocale.isValid then
		g_locales[localeName] = newLocale
	else
		-- Allow marging a locale entries from multiple files.

		local newLanguage = newLocale:GetAll()
		local oldLanguage = oldLocale:GetAll()

		for key, value in pairs(newLanguage) do
			value = tostring(value or "")

			if value == "" then
				continue
			end

			oldLanguage[key] = value
		end

		if oldLocale.title == "" then
			oldLocale.title = newLocale.title
		end

		if oldLocale.titleTranslated == "" then
			oldLocale.titleTranslated = newLocale.titleTranslated
		end

		if oldLocale.author == "" then
			oldLocale.author = newLocale.author
		end

		if oldLocale.locale_gmod == "" then
			oldLocale.locale_gmod = newLocale.locale_gmod
		end

		if oldLocale.icon == "" then
			oldLocale.icon = newLocale.icon
		end
	end

	return loaded
end

function LIB.LoadLocales()
	local _, localeFolders = file.Find(g_localesDirectory .. "/*", "LUA")

	table.Empty(g_locales)
	table.Empty(g_nativeLocalesMap)

	for _, localeFolder in ipairs(localeFolders or {}) do
		loadLocaleFile(localeFolder .. "/init.lua")
	end

	g_failbackLocale = LIB.GetLocale(g_failbackLocaleName)
	g_debugLocale = LIB.GetLocale(g_debugLocaleName)
	g_autoLocale = LIB.GetLocale(g_autoLocaleName)

	if not g_failbackLocale then
		local failbackLocale = LIB.CreateLocale(g_failbackLocaleName)

		failbackLocale.title = string.format("Missing locale: %s", g_failbackLocaleName)
		failbackLocale.icon = "material/error.vmt"

		g_locales[g_failbackLocaleName] = failbackLocale

		g_failbackLocale = LIB.GetLocale(g_failbackLocaleName)
	end

	if not g_debugLocale then
		local debugLocale = LIB.CreateLocale(g_debugLocaleName)

		debugLocale.icon = "materials/icon16/cog.png"

		g_locales[g_debugLocaleName] = debugLocale

		g_debugLocale = LIB.GetLocale(g_debugLocaleName)
	end

	if not g_autoLocale then
		local autoLocale = LIB.CreateLocale(g_autoLocaleName)

		autoLocale.icon = g_failbackLocale.icon

		g_locales[g_autoLocaleName] = autoLocale

		g_autoLocale = LIB.GetLocale(g_autoLocaleName)
	end

	for _, locale in SortedPairs(g_locales) do
		local localeName = locale.locale or ""
		local localeTitle = locale.title or ""

		if localeName == "" then
			continue
		end

		if localeTitle == "" then
			continue
		end

		local identifier = string.format("locale.%s.title", localeName)
		g_failbackLocale:Set(identifier, localeTitle, true)

		if locale == g_autoLocale or locale == g_debugLocale then
		 	continue
		end

		locale:Set(identifier, locale.titleTranslated, true)
	end

	g_updateNextThink = true
	LIB.SetCurrentLocale(LIB.GetLocaleName())
end

function LIB.CreateLocale(localeName)
	localeName = tostring(localeName or "")
	localeName = string.Trim(localeName)
	localeName = string.lower(localeName)

	if localeName == "" then
		return nil
	end

	local locale = {}

	addCommonFunctions(locale)

	locale.locale = localeName
	return locale
end

function LIB.GetAutoLocale()
	return g_autoLocale
end

function LIB.GetDebugLocale()
	return g_debugLocale
end

function LIB.GetLocales()
	return g_locales
end

function LIB.GetLocaleNameByNativeLocale(ply)
	local nativeLocaleName = nil

	if CLIENT then
		local cv = GetConVar("gmod_language")

		if not cv then
			return g_failbackLocaleName
		end

		nativeLocaleName = cv:GetString()
	else
		if not IsValid(ply) then return g_failbackLocaleName end
		if not ply:IsPlayer() then return g_failbackLocaleName end
		if ply:IsBot() then return g_failbackLocaleName end

		nativeLocaleName = ply:GetInfo("gmod_language")
	end

	nativeLocaleName = forceSingleLine(nativeLocaleName)
	nativeLocaleName = string.Trim(nativeLocaleName)
	nativeLocaleName = string.lower(nativeLocaleName)

	if nativeLocaleName == "" then
		return g_failbackLocaleName
	end

	local localeName = g_nativeLocalesMap[nativeLocaleName] or ""

	if localeName == "" then
		return g_failbackLocaleName
	end

	return localeName
end

function LIB.GetLocaleName(ply)
	local localeName = nil

	if CLIENT then
		local cv = GetConVar("cl_streamradio_locale")

		if not cv then
			return g_failbackLocaleName
		end

		localeName = cv:GetString()
	else
		if not IsValid(ply) then return g_failbackLocaleName end
		if not ply:IsPlayer() then return g_failbackLocaleName end
		if ply:IsBot() then return g_failbackLocaleName end

		localeName = ply:GetInfo("cl_streamradio_locale")
	end

	localeName = forceSingleLine(localeName)
	localeName = string.Trim(localeName)
	localeName = string.lower(localeName)

	-- Aliases for convenience
	if localeName == "auto" then
		localeName = g_autoLocaleName
	elseif localeName == "debug" then
		localeName = g_debugLocaleName
	end

	if localeName == g_debugLocaleName and (not LIBUtil or not LIBUtil.IsDebug()) then
		localeName = g_autoLocaleName
	end

	if localeName == g_autoLocaleName then
		localeName = LIB.GetLocaleNameByNativeLocale(ply)
	end

	if localeName == "" or not g_locales[localeName] then
		return g_failbackLocaleName
	end

	return localeName
end

function LIB.GetLocale(localeName)
	localeName = tostring(localeName or "")
	localeName = string.Trim(localeName)
	localeName = string.lower(localeName)

	-- Aliases for convenience
	if localeName == "auto" then
		localeName = g_autoLocaleName
	elseif localeName == "debug" then
		localeName = g_debugLocaleName
	end

	local locale = g_locales[localeName]
	return locale
end

function LIB.GetLocaleByNativeLocale(ply)
	return LIB.GetLocale(LIB.GetLocaleNameByNativeLocale(ply))
end

function LIB.SetCurrentLocale(localeName)
	g_autoLocale = LIB.GetLocale(g_autoLocaleName)
	g_debugLocale = LIB.GetLocale(g_debugLocaleName)
	g_failbackLocale = LIB.GetLocale(g_failbackLocaleName)
	g_currentLocale = LIB.GetLocale(localeName) or g_failbackLocale

	LIB.ApplyLocale()
end

function LIB.GetCurrentLocale()
	return g_currentLocale
end

function LIB.Translate(identifier, failback, lazy)
	if isbool(failback) and lazy == nil then
		lazy = failback
		failback = ""
	end

	if lazy then
		return LIB.TranslateLazy(identifier, failback)
	end

	identifier = tostring(identifier or "")
	failback = tostring(failback or "")

	if not isMarked(identifier) then
		-- string already translated or not translatable
		return identifier
	end

	local currentLocale = g_currentLocale

	if not currentLocale then
		currentLocale = g_failbackLocale
	end

	identifier = string.lower(identifier)
	identifier = forceMark(identifier)

	if failback ~= "" then
		g_failbackLocale:Set(identifier, failback)
	end

	if currentLocale == g_debugLocale then
		return identifier
	end

	local translation = currentLocale:Get(identifier)

	if not translation then
		translation = g_failbackLocale:Get(identifier) or identifier
	end

	return translation
end

function LIB.TranslateLocaleTitle(locale)
	local identifier = string.format("?locale.%s.title", locale.locale)
	return LIB.Translate(identifier)
end

local function translateLazyInternal(lazyString, data)
	if g_cacheId and g_cacheId == data.cacheid and data.cache then
		return data.cache
	end

	local result = LIB.Translate(data.identifier, data.failback, false)
	data.cache = result

	return result
end

function LIB.TranslateLazy(identifier, failback)
	identifier = tostring(identifier or "")
	failback = tostring(failback or "")

	if not isMarked(identifier) then
		-- string already translated or not translatable
		return identifier
	end

	local data = {
		cacheid = g_cacheId,
		identifier = identifier,
		failback = failback,
	}

	local lazyString = LIBString.CreateLazyString(translateLazyInternal, data)
	return lazyString
end

function LIB.TranslateNativeAuto(identifier)
	identifier = tostring(identifier or "")
	identifier = string.lower(identifier)
	identifier = removeMark(identifier)

	local nativeIdentifier = g_addonPrefix .. identifier

	return LIB.TranslateNative(nativeIdentifier)
end

function LIB.TranslateNative(nativeIdentifier)
	nativeIdentifier = tostring(nativeIdentifier or "")

	local nativeTranslation = g_nativeTranslationMap[nativeIdentifier]
	if not nativeTranslation then
		if SERVER then
			return nativeIdentifier
		end

		return language.GetPhrase(nativeIdentifier)
	end

	local translation = LIB.Translate(nativeTranslation.identifier, nativeTranslation.failback)
	if not translation then
		if SERVER then
			return nativeIdentifier
		end

		return language.GetPhrase(nativeIdentifier)
	end

	return translation
end

function LIB.AddNativeTranslationAuto(identifier, failback, lazy)
	identifier = tostring(identifier or "")
	identifier = string.lower(identifier)
	identifier = removeMark(identifier)

	local nativeIdentifier = g_addonPrefix .. identifier

	LIB.AddNativeTranslation(nativeIdentifier, identifier, failback, lazy)
end

function LIB.AddNativeTranslation(nativeIdentifier, identifier, failback, lazy)
	nativeIdentifier = tostring(nativeIdentifier or "")
	identifier = tostring(identifier or "")

	identifier = string.lower(identifier)
	identifier = forceMark(identifier)

	g_nativeTranslationMap[nativeIdentifier] = {
		identifier = identifier,
		failback = failback,
		lazy = lazy,
	}

	LIB.ApplyNativeTranslation(nativeIdentifier)
end

function LIB.ApplyNativeTranslation(nativeIdentifier)
	nativeIdentifier = tostring(nativeIdentifier or "")

	local nativeTranslation = g_nativeTranslationMap[nativeIdentifier]
	if not nativeTranslation then
		return
	end

	local translation = LIB.Translate(
		nativeTranslation.identifier,
		nativeTranslation.failback,
		nativeTranslation.lazy
	)

	translation = tostring(translation or "")

	language.Add(nativeIdentifier, translation)
end

function LIB.GetNativeTranslationIdentifier(identifier)
	identifier = tostring(identifier or "")
	identifier = string.lower(identifier)
	identifier = removeMark(identifier)

	local nativeIdentifier = "#" .. g_addonPrefix .. identifier
	return nativeIdentifier
end

function LIB.Format(identifier, failback, ...)
	local translation = LIB.Translate(identifier, failback)

	if not LIBPrint then
		LIBPrint = StreamRadioLib.Print
	end

	return LIBPrint.Format(translation, ...)
end

function LIB.FormatNative(nativeIdentifier, ...)
	local translation = LIB.TranslateNative(nativeIdentifier)

	if not LIBPrint then
		LIBPrint = StreamRadioLib.Print
	end

	return LIBPrint.Format(translation, ...)
end

local function replacePlaceholder(data, name, value)
	value = string.PatternSafe(value)

	local pattern = "%-%-[ \t]*%{%{" .. string.PatternSafe(name) .. "%}%}"
	data = string.gsub(data, pattern, "{{" .. name .. "}}")

	pattern = "%{%{" .. string.PatternSafe(name) .. "%}%}"
	data = string.gsub(data, pattern, value)

	return data
end

local function preCategorize(tab, identifier, translation)
	identifier = removeMark(identifier)

	local category1 = ""
	local category2 = ""

	local _, dotcount = string.gsub(identifier, "%.", "")

	if dotcount > 0 then
		local categories = string.Explode(".", identifier, false)

		category1 = tostring(categories[1] or "")
		local tmp = tostring(categories[3] or "")

		if dotcount > 1 and tmp ~= "" then
			category2 = tostring(categories[2] or "")
		end
	end

	if category1 == "" then
		category1 = "<none>"
		category2 = ""
	end

	local c1 = tab[category1] or {}
	tab[category1] = c1

	local c2 = c1[category2] or {}
	c1[category2] = c2

	c2[identifier] = translation
end

local function formatTranslationComment(translation, title)
	if not translation then
		translation = "<none>"
	end

	translation = string.Trim(translation)
	translation = LIB.EscapeUnicode(translation)
	translation = LIB.UnescapeUnicode(translation)

	if translation == "" then
		translation = "<empty>"
	end

	if not LIBString.IsMultiline(translation) then
		return string.format("-- %s %s", title, translation)
	end

	local formated = {}

	table.insert(formated, string.format("-- %s", title))
	table.insert(formated, "\n")

	local lines = string.Explode("\n", translation, false)

	for _, line in ipairs(lines) do
		table.insert(formated, string.format("--  | %s", line))
		table.insert(formated, "\n")
	end

	formated[#formated] = nil
	formated = table.concat(formated)

	return formated
end

local function formatTranslation(translation, normalizeToUnescaped)
	if not translation then
		translation = ""
	end

	translation = string.Trim(translation)
	translation = LIB.EscapeUnicode(translation)

	if normalizeToUnescaped then
		translation = LIB.UnescapeUnicode(translation)
	end

	-- Encode square bracket sequences to avoid premature string termination
	translation = string.Replace(translation, "[[", "\\x5B\\x5B")
	translation = string.Replace(translation, "]]", "\\x5D\\x5D")

	local formated = {}

	local lines = string.Explode("\n", translation, false)

	for _, line in ipairs(lines) do
		table.insert(formated, string.format("%s", line))
		table.insert(formated, "\n")
	end

	formated[#formated] = nil

	formated = table.concat(formated)

	return formated
end

local function formatName(name)
	name = tostring(name or "")
	name = string.Trim(name)

	name = LIB.EscapeUnicode(name)
	name = LIBString.EscapeSlashes(name)

	return name
end

local g_fileTemplate = [====[
local LOCALE = LOCALE
if not istable(LOCALE) then
	StreamRadioLib.ReloadAddon()
	return
end

-- Translation file for locale "{{LOCALE}}" ({{TITLE}})
--   by {{AUTHOR}}

-- Important notes for translation:
--   1.) These files and strings must be encoded in UTF8.
--   2.) These files must return true, so we know they have been loaded properly.
--   3.) You may use both unescaped and escaped strings.
--       * Valid escape sequences are \uXXXX or \u{XXXX} for unicode characters (UTF8 codepoints) and
--         \xXX or \x{XX} for raw ascii characters.
--       * 4, 6 or 8 hex digits for unicode, 2 hex digits ascii characters.
--       * Use upper case hex digits only.
--       * e.g. "\u{01F36A}" for "🍪" (cookie emoji).
--   4.) It is recommented to use [[square brackets]] formated strings.
--   5.) An empty entry (nil or "") will failback to their default translation.
--   6.) After changes to locale files you might need to restart
--       the game for them to take full effect.
--   7.) Take note of these comments on top of each item.
--       They tell you something about their context.
--       * Default: That's how it was translated by default (English).
--         The entry will failback to that default if it is empty.
--       * Current: That's how it was translated at the time this file was generated.

-- Content Rules:
--   1.) Keep the content formal and civil. No insults, no swearing, no slang, etc.
--   2.) Make sure the content is free from spelling and grammar mistakes.
--   3.) Do not translate proper names or GMod specfic words.
--       It depents on the context and your language.
--       * Proper name: "3D Stream Radio" should stay "3D Stream Radio" in other languages.
--       * GMod specfic word: "entity" should stay "entity" too.
--         It might be adjusted to grammar/plural, though.
--       * Mixed case: "'3D Stream Radio' error" can be partly changed when appropriate.
--         In German it could look like this "'3D Stream Radio'-Fehler".
--   4.) Keep string.format placerholders (e.g. "%s") present when you find them.
--   5.) Do not add extra logic, loops, function calls or comments.
--       It will be lost upon regeneration.

-- To generate/update this template:
--   1.) Run the console command "debug_streamradio_generate_locale {{LOCALE}}" on the client.
--   2.) Copy and rename the files printed in the console
--       to: "lua/streamradio_core/locales/{{LOCALE}}/*.lua"
--   3.) Edit it as you wish. And regenerate + copy again for clean up.
--   4.) Restart the game to have it taken full effect.

-- Author of this file
LOCALE.author = "{{AUTHOR_E}}"

-- Locale. It is ll-cc formated and all lowercase. Standard: ISO 639 and ISO 3166 respectively.
LOCALE.locale = "{{LOCALE_E}}"

-- Locale as used by gmod translation system. Used for ConVar "cl_streamradio_locale auto".
LOCALE.locale_gmod = "{{LOCALE_GMOD_E}}"

-- Title of the language in English, e.g. "German" for German.
LOCALE.title = "{{TITLE_E}}"

-- Title of the language in that language, e.g. "Deutsch" for German.
LOCALE.titleTranslated = "{{TITLE_TRANSLATED_E}}"

-- Icon for this language, e.g. the flag of its country.
LOCALE.icon = "{{ICON}}"

-- Set to true if you want to normalize the translation to unescaped strings upon template generation.
-- Removes escape sequences for better readability.
LOCALE.normalizeToUnescaped = {{NORMALIZE_TO_UNESCAPED}}

{{INCLUDES}}
{{ITEMS}}

-- This file returns true, so we know it has been loaded properly
return true

]====]

local g_subFileTemplate = [====[
local LOCALE = LOCALE
if not istable(LOCALE) then
	StreamRadioLib.ReloadAddon()
	return
end

-- Translation file for locale "{{LOCALE}}" ({{TITLE}})
--   by {{AUTHOR}}

-- This is a sub locale file.
-- See "lua/streamradio_core/locales/{{LOCALE}}/init.lua" for translation notes and rules.

{{ITEMS}}

-- This file returns true, so we know it has been loaded properly
return true

]====]

local g_itemTemplate = [====[
{{TRANSLATION_DEFAULT}}
{{TRANSLATION_CURRENT}}
LOCALE:Set("{{IDENTIFIER}}", [[{{TRANSLATION}}]])
]====]

local function writeFileTemplate(localeMeta, fileName, template, itemContents, subFileIncludes)
	subFileIncludes = subFileIncludes or ""
	itemContents = itemContents or ""

	local content = template

	content = replacePlaceholder(content, "AUTHOR", localeMeta.author)
	content = replacePlaceholder(content, "AUTHOR_E", localeMeta.authorE)

	content = replacePlaceholder(content, "LOCALE", localeMeta.localeName)
	content = replacePlaceholder(content, "LOCALE_E", localeMeta.localeNameE)

	content = replacePlaceholder(content, "LOCALE_GMOD", localeMeta.nativeLocaleName)
	content = replacePlaceholder(content, "LOCALE_GMOD_E", localeMeta.nativeLocaleNameE)

	content = replacePlaceholder(content, "TITLE", localeMeta.title)
	content = replacePlaceholder(content, "TITLE_E", localeMeta.titleE)

	content = replacePlaceholder(content, "TITLE_TRANSLATED", localeMeta.titleTranslated)
	content = replacePlaceholder(content, "TITLE_TRANSLATED_E", localeMeta.titleTranslatedE)

	content = replacePlaceholder(content, "ICON", localeMeta.icon)
	content = replacePlaceholder(content, "NORMALIZE_TO_UNESCAPED", localeMeta.normalizeToUnescaped and "true" or "false")

	if subFileIncludes ~= "" then
		subFileIncludes = string.format(
			"-- Include sub locale files for better organization.\n%s\n",
			subFileIncludes
		)
	end

	content = replacePlaceholder(content, "INCLUDES", subFileIncludes)
	content = replacePlaceholder(content, "ITEMS", itemContents)

	content = LIBString.NormalizeNewlines(content, "\r\n")

	local success = LIBFile.Write(fileName, content)
	local path = LIBFile.GetAbsolutePath(fileName)

	if success then
		LIBPrint.Msg(nil, "Language.GenerateLocaleFile: Written to 'data/%s'. Ready for copy and paste.", path)
	else
		LIBPrint.Msg(nil, "Language.GenerateLocaleFile: Could not Write to 'data/%s'", path)
	end
end

function LIB.GenerateLocaleFile(localeName)
	localeName = tostring(localeName or "")
	localeName = string.Trim(localeName)
	localeName = string.lower(localeName)

	if localeName == g_autoLocaleName then
		return
	end

	if localeName == g_debugLocaleName then
		return
	end

	local locale = LIB.GetLocale(localeName)
	if not locale then
		locale = LIB.CreateLocale(localeName)

		if not locale then
			return
		end
	end

	local title = forceSingleLine(locale.title or "")
	local titleTranslated = forceSingleLine(locale.titleTranslated or "")
	local localeName = forceSingleLine(locale.locale or "")
	local nativeLocaleName = forceSingleLine(locale.locale_gmod or "")
	local author = forceSingleLine(locale.author or "")
	local icon = forceSingleLine(locale.icon or "")

	local normalizeToUnescaped = locale.normalizeToUnescaped or false

	title = LIB.UnescapeUnicode(title)
	titleTranslated = LIB.UnescapeUnicode(titleTranslated)
	localeName = LIB.UnescapeUnicode(localeName)
	nativeLocaleName = LIB.UnescapeUnicode(nativeLocaleName)
	author = LIB.UnescapeUnicode(author)
	icon = LIBString.SanitizeFilepath(icon)

	local localeMeta = {
		title = title,
		titleE = formatName(title),

		titleTranslated = titleTranslated,
		titleTranslatedE = formatName(titleTranslated),

		localeName = localeName,
		localeNameE = formatName(localeName),

		nativeLocaleName = nativeLocaleName,
		nativeLocaleNameE = formatName(nativeLocaleName),

		author = author,
		authorE = formatName(author),

		icon = icon,
		normalizeToUnescaped = normalizeToUnescaped,
	}

	local tmp = {}

	for identifier, translation in pairs(g_failbackLocale:GetAll()) do
		preCategorize(tmp, identifier, "")
	end

	for identifier, translation in pairs(locale:GetAll()) do
		preCategorize(tmp, identifier, translation)
	end

	local itemsMainFile = {}
	local subFileIncludes = {}

	for category1, category1Items in SortedPairs(tmp) do
		local itemsSubFile = {}
		local itemsSubFileCount = 0

		local category1Title = string.format("-- Main Category: %s", category1)
		table.insert(itemsSubFile, "-- ################################################################################")
		table.insert(itemsSubFile, category1Title)
		table.insert(itemsSubFile, "-- ################################################################################")
		table.insert(itemsSubFile, "")

		for category2, category2Items in SortedPairs(category1Items) do
			local itemsInner = {}

			local hasSubCategoryHeader = category2 ~= "" and table.Count(category2Items) > 1

			if hasSubCategoryHeader then
				local category2Title = string.format("-- Sub Category:  %s.%s", category1, category2)
				table.insert(itemsInner, "-- ================================================================================")
				table.insert(itemsInner, category2Title)
				table.insert(itemsInner, "-- ================================================================================")
				table.insert(itemsInner, "")
			end

			for identifier, translation in SortedPairs(category2Items) do
				local identifierMarked = forceMark(identifier)

				local defaultTranslation = g_failbackLocale:Get(identifierMarked) or ""
				local currentTranslation = locale:Get(identifierMarked) or ""

				if currentTranslation ~= "" and defaultTranslation ~= "" and currentTranslation == defaultTranslation then
					defaultTranslation = ""
					currentTranslation = formatTranslationComment(currentTranslation, "Current:")
				else
					defaultTranslation = formatTranslationComment(defaultTranslation, "Default:")
					currentTranslation = formatTranslationComment(currentTranslation, "Current:")
				end

				translation = formatTranslation(translation, normalizeToUnescaped)

				local itemString = g_itemTemplate

				itemString = replacePlaceholder(itemString, "TRANSLATION_DEFAULT", defaultTranslation)
				itemString = replacePlaceholder(itemString, "TRANSLATION_CURRENT", currentTranslation)

				itemString = replacePlaceholder(itemString, "IDENTIFIER", formatName(identifier))
				itemString = replacePlaceholder(itemString, "TRANSLATION", translation)

				itemString = string.Trim(itemString)

				table.insert(itemsInner, itemString)
				table.insert(itemsInner, "")

				itemsSubFileCount = itemsSubFileCount + 1
			end

			itemsInner = table.concat(itemsInner, "\n")
			itemsInner = string.Trim(itemsInner)

			if hasSubCategoryHeader then
				table.insert(itemsSubFile, "")
			end

			table.insert(itemsSubFile, itemsInner)
			table.insert(itemsSubFile, "")
		end

		itemsSubFile = table.concat(itemsSubFile, "\n")
		itemsSubFile = string.Trim(itemsSubFile)

		local shouldWriteSubFile = itemsSubFileCount > 1

		if shouldWriteSubFile then
			local category1FileName = string.lower(category1)
			category1FileName = string.Replace(category1FileName, " ", "_")

			if category1FileName == "<none>" then
				category1FileName = "_none"
			end

			local subFileName = "locales/" .. localeName .. "/" .. category1FileName .. ".lua.txt"

			writeFileTemplate(localeMeta, subFileName, g_subFileTemplate, itemsSubFile)

			local category1Include = string.format("LOCALE:Include(\"%s\")", category1 .. ".lua")
			table.insert(subFileIncludes, category1Include)
		else
			table.insert(itemsMainFile, itemsSubFile)
			table.insert(itemsMainFile, "")
		end
	end

	itemsMainFile = table.concat(itemsMainFile, "\n")
	itemsMainFile = string.Trim(itemsMainFile)

	subFileIncludes = table.concat(subFileIncludes, "\n")
	subFileIncludes = string.Trim(subFileIncludes)

	-- NOTE: This is a generated template file for translation.
	-- To use it at runtime, copy and rename to "lua/streamradio_core/locales/<locale>/init.lua"
	local fileName = "locales/" .. localeName .. "/init.lua.txt"

	writeFileTemplate(localeMeta, fileName, g_fileTemplate, itemsMainFile, subFileIncludes)
end

function LIB.ApplyLocale()
	if not g_currentLocale then
		return
	end

	if not LIBUtil then
		LIBUtil = StreamRadioLib.Util
	end

	if LIBUtil then
		g_cacheId = LIBUtil.Uid()
	else
		g_cacheId = nil
	end

	local autoLocale = LIB.GetAutoLocale()
	local debugLocale = LIB.GetDebugLocale()
	local localeFromNative = LIB.GetLocaleByNativeLocale()

	if autoLocale then
		autoLocale.titleTranslated = LIB.Translate("?locale._auto.title", "Use game language if available")
		autoLocale.icon = ""

		if isMarked(autoLocale.titleTranslated) then
			autoLocale.titleTranslated = "Use game language if available (?locale._auto.title)"
		end

		if localeFromNative then
			autoLocale.icon = localeFromNative.icon or ""
		end
	end

	if debugLocale then
		debugLocale.titleTranslated = LIB.Translate("?locale._debug.title", "Show translation identifiers")
		debugLocale.icon = "materials/icon16/cog.png"

		if isMarked(debugLocale.titleTranslated) then
			debugLocale.titleTranslated = "Show translation identifiers (?locale._debug.title)"
		end
	end

	for nativeIdentifier, _ in pairs(g_nativeTranslationMap) do
		LIB.ApplyNativeTranslation(nativeIdentifier)
	end

	if not LIBHook then
		LIBHook = StreamRadioLib.Hook
	end

	if LIBHook then
		LIBHook.RunCustom("OnLocaleChanged", g_currentLocale.locale)
	end

	g_updateNextThink = false
end

function LIB.Refresh()
	g_updateNextThink = true
end

if CLIENT then
	concommand.Add("debug_streamradio_generate_locale", function(ply, cmd, args)
		if not LIBUtil.IsAdminForCMD(ply) then
			return
		end

		local localeName = tostring(args[1] or "")

		if localeName == "" or localeName == "auto" or localeName == g_autoLocaleName then
			localeName = LIB.GetLocaleName(ply)

			if localeName == "" then
				return
			end

			if localeName == "auto" or localeName == g_autoLocaleName then
				return
			end
		end

		if localeName == "debug" or localeName == g_debugLocaleName then
			return
		end

		LIBHook.RunCustom("OnLocaleGenerate")

		LIBPrint.MsgStartBuffer()

		if localeName == "all" then
			for locale, _ in SortedPairs(g_locales) do
				LIB.GenerateLocaleFile(locale)
			end

			LIBPrint.MsgDumpBuffer()
			return
		end

		LIB.GenerateLocaleFile(localeName)

		LIBPrint.MsgDumpBuffer()
	end)
end

LIB.LoadLocales()

function LIB.Load()
	LIBString = StreamRadioLib.String
	LIBFile = StreamRadioLib.File
	LIBPrint = StreamRadioLib.Print
	LIBUtil = StreamRadioLib.Util
	LIBHook = StreamRadioLib.Hook

	LIB.LoadLocales()

	LIBHook.Add("Think", "LocaleUpdate", function()
		local now = RealTime()

		if g_nextThink < now then
			local localeName = LIB.GetLocaleName()
			local debugMode = LIBUtil.IsDebug()

			if not g_currentLocale or g_currentLocale.locale ~= localeName or g_oldDebugMode ~= debugMode then
				g_updateNextThink = true
			end

			if g_updateNextThink then
				if not debugMode and localeName == g_debugLocaleName then
					localeName = g_failbackLocaleName
				end

				LIB.SetCurrentLocale(localeName)
			end

			g_updateNextThink = false
			g_oldDebugMode = debugMode

			g_nextThink = now + 1 + math.random()
		end
	end)
end

function LIB.PostLoad()
	if g_currentLocale then
		LIBHook.RunCustom("OnLocaleChanged", g_currentLocale.locale)
	end
end

return true

