local LOCALE = LOCALE
if not istable(LOCALE) then
	StreamRadioLib.ReloadAddon()
	return
end

-- Translation file for locale "en-us" (English (US))
--   by Grocel

-- This is a sub locale file.
-- See "lua/streamradio_core/locales/en-us/init.lua" for translation notes and rules.

-- ################################################################################
-- Main Category: locale
-- ################################################################################

-- Current: Use game language if available
LOCALE:Set("locale._auto.title", [[Use game language if available]])

-- Current: Show translation identifiers
LOCALE:Set("locale._debug.title", [[Show translation identifiers]])

-- Current: German
LOCALE:Set("locale.de-de.title", [[German]])

-- Current: English (US)
LOCALE:Set("locale.en-us.title", [[English (US)]])

-- This file returns true, so we know it has been loaded properly
return true

