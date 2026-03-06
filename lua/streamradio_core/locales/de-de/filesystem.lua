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
-- Main Category: filesystem
-- ################################################################################

-- Default: Folder
-- Current: Ordner
LOCALE:Set("filesystem.folder.name", [[Ordner]])

-- Current: JSON
LOCALE:Set("filesystem.json.name", [[JSON]])

-- Current: M3U
LOCALE:Set("filesystem.m3u.name", [[M3U]])

-- Default: Virtual Folder
-- Current: Virtueller Ordner
LOCALE:Set("filesystem.virtual-folder.name", [[Virtueller Ordner]])

-- This file returns true, so we know it has been loaded properly
return true

