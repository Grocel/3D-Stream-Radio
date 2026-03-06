local LOCALE = LOCALE
if not istable(LOCALE) then
	StreamRadioLib.ReloadAddon()
	return
end

-- Translation file for locale "en-us" (English (US))
--   by Grocel

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
--   1.) Run the console command "debug_streamradio_generate_locale en-us" on the client.
--   2.) Copy and rename the files printed in the console
--       to: "lua/streamradio_core/locales/en-us/*.lua"
--   3.) Edit it as you wish. And regenerate + copy again for clean up.
--   4.) Restart the game to have it taken full effect.

-- Author of this file
LOCALE.author = "Grocel"

-- Locale. It is ll-cc formated and all lowercase. Standard: ISO 639 and ISO 3166 respectively.
LOCALE.locale = "en-us"

-- Locale as used by gmod translation system. Used for ConVar "cl_streamradio_locale auto".
LOCALE.locale_gmod = "en"

-- Title of the language in English, e.g. "German" for German.
LOCALE.title = "English (US)"

-- Title of the language in that language, e.g. "Deutsch" for German.
LOCALE.titleTranslated = "English (US)"

-- Icon for this language, e.g. the flag of its country.
LOCALE.icon = "materials/flags16/us.png"

-- Set to true if you want to normalize the translation to unescaped strings upon template generation.
-- Removes escape sequences for better readability.
LOCALE.normalizeToUnescaped = true

-- Include sub locale files for better organization.
LOCALE:Include("error.lua")
LOCALE:Include("filesystem.lua")
LOCALE:Include("locale.lua")
LOCALE:Include("properties.lua")
LOCALE:Include("radiogui.lua")
LOCALE:Include("settings.lua")
LOCALE:Include("tool.lua")
LOCALE:Include("vgui.lua")



-- This file returns true, so we know it has been loaded properly
return true

