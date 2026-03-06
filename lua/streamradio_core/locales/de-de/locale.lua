local LOCALE = LOCALE
if not istable(LOCALE) then
	StreamRadioLib.ReloadAddon()
	return
end

-- Translation file for locale "de-de" (German)
--   by Grocel

-- This is a sub locale file.
-- See "lua/streamradio_core/locales/de-de/init.lua" for translation notes and rules.

-- ################################################################################
-- Main Category: locale
-- ################################################################################

-- Default: Use game language if available
-- Current: Spielsprache verwenden, falls verfügbar
LOCALE:Set("locale._auto.title", [[Spielsprache verwenden, falls verfügbar]])

-- Default: Show translation identifiers
-- Current: Übersetzungs-Identifikatoren anzeigen
LOCALE:Set("locale._debug.title", [[Übersetzungs-Identifikatoren anzeigen]])

-- Default: German
-- Current: Deutsch
LOCALE:Set("locale.de-de.title", [[Deutsch]])

-- Default: English (US)
-- Current: Englisch (US)
LOCALE:Set("locale.en-us.title", [[Englisch (US)]])

-- This file returns true, so we know it has been loaded properly
return true

