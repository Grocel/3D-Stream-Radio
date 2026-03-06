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
-- Main Category: filesystem
-- ################################################################################

-- Current: Folder
LOCALE:Set("filesystem.folder.name", [[Folder]])

-- Current: JSON
LOCALE:Set("filesystem.json.name", [[JSON]])

-- Current: M3U
LOCALE:Set("filesystem.m3u.name", [[M3U]])

-- Current: Virtual Folder
LOCALE:Set("filesystem.virtual-folder.name", [[Virtual Folder]])

-- This file returns true, so we know it has been loaded properly
return true

