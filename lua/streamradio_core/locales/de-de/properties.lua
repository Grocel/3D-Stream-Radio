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
-- Main Category: properties
-- ################################################################################


-- ================================================================================
-- Sub Category:  properties.radio_options
-- ================================================================================

-- Default: Admin Options
-- Current: Admin-Optionen
LOCALE:Set("properties.radio_options.admin.title", [[Admin-Optionen]])

-- Default: Add to quick whitelist
-- Current: Zur Schnell-Whitelist hinzufügen
LOCALE:Set("properties.radio_options.admin.whitelist_add.title", [[Zur Schnell-Whitelist hinzufügen]])

-- Default: Remove from quick whitelist
-- Current: Von der Schnell-Whitelist entfernen
LOCALE:Set("properties.radio_options.admin.whitelist_remove.title", [[Von der Schnell-Whitelist entfernen]])

-- Default: Copy Stream URL to clipboard
-- Current: Stream-URL in die Zwischenablage kopieren
LOCALE:Set("properties.radio_options.clientside.copy_url.title", [[Stream-URL in die Zwischenablage kopieren]])

-- Default: Error
-- Current: Fehler
LOCALE:Set("properties.radio_options.clientside.error_info.title", [[Fehler]])

-- Default:
--  | Error %i (%s): %s
--  | 
--  | Can not play this URL:
--  | %s
--  | 
--  | %s
-- Current:
--  | Fehler %i (%s): %s
--  | 
--  | Kann diese URL nicht abspielen:
--  | %s
--  | 
--  | %s
LOCALE:Set("properties.radio_options.clientside.error_info.tooltip", [[Fehler %i (%s): %s

Kann diese URL nicht abspielen:
%s

%s]])

-- Default: Click for more details.
-- Current: Für weitere Details klicken.
LOCALE:Set("properties.radio_options.clientside.error_info.tooltip.clickhint", [[Für weitere Details klicken.]])

-- Default: Reset GUI
-- Current: GUI zurücksetzen
LOCALE:Set("properties.radio_options.clientside.reset_gui.title", [[GUI zurücksetzen]])

-- Default: Clientside Options
-- Current: Clientseitige Optionen
LOCALE:Set("properties.radio_options.clientside.title", [[Clientseitige Optionen]])

-- Default: Volume
-- Current: Lautstärke
LOCALE:Set("properties.radio_options.clientside.volume.title", [[Lautstärke]])

-- Default: Fast forward %i seconds
-- Current: %i Sekunden vorspulen
LOCALE:Set("properties.radio_options.generic.playlist.forward", [[%i Sekunden vorspulen]])

-- Default: Next track
-- Current: Nächster Titel
LOCALE:Set("properties.radio_options.generic.playlist.next", [[Nächster Titel]])

-- Current: Pause
LOCALE:Set("properties.radio_options.generic.playlist.play", [[Pause]])

-- Default: Previous track
-- Current: Vorheriger Titel
LOCALE:Set("properties.radio_options.generic.playlist.previous", [[Vorheriger Titel]])

-- Default: Rewind %i seconds
-- Current: %i Sekunden zurückspulen
LOCALE:Set("properties.radio_options.generic.playlist.rewind", [[%i Sekunden zurückspulen]])

-- Default: Stop
-- Current: Stopp
LOCALE:Set("properties.radio_options.generic.playlist.stop", [[Stopp]])

-- Default: Decrease volume
-- Current: Lautstärke verringern
LOCALE:Set("properties.radio_options.generic.volume.decrease", [[Lautstärke verringern]])

-- Default: Increase volume
-- Current: Lautstärke erhöhen
LOCALE:Set("properties.radio_options.generic.volume.increase", [[Lautstärke erhöhen]])

-- Default: Mute
-- Current: Stumm
LOCALE:Set("properties.radio_options.generic.volume.mute", [[Stumm]])

-- Default: Unmute
-- Current: Stumm aufheben
LOCALE:Set("properties.radio_options.generic.volume.unmute", [[Stumm aufheben]])

-- Default: Entity Options
-- Current: Entity-Optionen
LOCALE:Set("properties.radio_options.serverside.title", [[Entity-Optionen]])

-- Default: Volume
-- Current: Lautstärke
LOCALE:Set("properties.radio_options.serverside.volume.title", [[Lautstärke]])

-- This file returns true, so we know it has been loaded properly
return true

