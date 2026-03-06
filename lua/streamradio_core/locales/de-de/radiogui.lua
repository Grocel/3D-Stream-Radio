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
-- Main Category: radiogui
-- ################################################################################


-- ================================================================================
-- Sub Category:  radiogui.gui_browser
-- ================================================================================

-- Default: Go to parent directory
-- Current: Zum übergeordneten Verzeichnis wechseln
LOCALE:Set("radiogui.gui_browser.back.tooltip", [[Zum übergeordneten Verzeichnis wechseln]])

-- Default: Path:
-- Current: Pfad:
LOCALE:Set("radiogui.gui_browser.path.label", [[Pfad:]])

-- Default: Refresh view
-- Current: Ansicht aktualisieren
LOCALE:Set("radiogui.gui_browser.refresh.tooltip", [[Ansicht aktualisieren]])

-- Default: Play URL from Toolgun
-- Current: URL aus Toolgun abspielen
LOCALE:Set("radiogui.gui_browser.toolgun.tooltip", [[URL aus Toolgun abspielen]])

-- Default: Play URL from Wiremod
-- Current: URL aus Wiremod abspielen
LOCALE:Set("radiogui.gui_browser.wiremod.tooltip", [[URL aus Wiremod abspielen]])


-- ================================================================================
-- Sub Category:  radiogui.gui_errorbox
-- ================================================================================

-- Default: Close
-- Current: Schließen
LOCALE:Set("radiogui.gui_errorbox.close.tooltip", [[Schließen]])

-- Default:
--  | Error: %i (%s)
--  | 
--  | Could not open playlist:
--  | %s
--  | 
--  | Make sure the file is valid and not Empty.
--  | 
--  | Click the '?' button for more details.
-- Current:
--  | Fehler: %i (%s)
--  | 
--  | Wiedergabeliste konnte nicht geöffnet werden:
--  | %s
--  | 
--  | Stelle sicher, dass die Datei gültig und nicht leer ist
--  | 
--  | Klicke auf die Schaltfläche "?" für weitere Details.
LOCALE:Set("radiogui.gui_errorbox.error.playlist.with_url", [[Fehler: %i (%s)

Wiedergabeliste konnte nicht geöffnet werden:
%s

Stelle sicher, dass die Datei gültig und nicht leer ist

Klicke auf die Schaltfläche "?" für weitere Details.]])

-- Default:
--  | Error: %i (%s)
--  | 
--  | Could not play stream:
--  | %s
--  | 
--  | %s
--  | 
--  | Click the '?' button for more details.
-- Current:
--  | Fehler: %i (%s)
--  | 
--  | Stream konnte nicht abgespielt werden:
--  | %s
--  | 
--  | %s
--  | 
--  | Klicke auf die Schaltfläche "?" für weitere Details.
LOCALE:Set("radiogui.gui_errorbox.error.stream.with_url", [[Fehler: %i (%s)

Stream konnte nicht abgespielt werden:
%s

%s

Klicke auf die Schaltfläche "?" für weitere Details.]])

-- Default:
--  | Error: %i (%s)
--  | 
--  | Could not play stream!
--  | 
--  | %s
--  | 
--  | Click the '?' button for more details.
-- Current:
--  | Fehler: %i (%s)
--  | 
--  | Stream konnte nicht abgespielt werden!
--  | 
--  | %s
--  | 
--  | Klicke auf die Schaltfläche "?" für weitere Details.
LOCALE:Set("radiogui.gui_errorbox.error.stream.without_url", [[Fehler: %i (%s)

Stream konnte nicht abgespielt werden!

%s

Klicke auf die Schaltfläche "?" für weitere Details.]])

-- Default: Help
-- Current: Hilfe
LOCALE:Set("radiogui.gui_errorbox.help.tooltip", [[Hilfe]])

-- Default: Retry
-- Current: Erneut versuchen
LOCALE:Set("radiogui.gui_errorbox.retry.tooltip", [[Erneut versuchen]])

-- Default: Add to quick whitelist (admin only)
-- Current: Zur Schnell-Whitelist hinzufügen (nur Admin)
LOCALE:Set("radiogui.gui_errorbox.whitelist.tooltip", [[Zur Schnell-Whitelist hinzufügen (nur Admin)]])

-- Default: Back
-- Current: Zurück
LOCALE:Set("radiogui.gui_player.back.label", [[Zurück]])


-- ================================================================================
-- Sub Category:  radiogui.gui_player_controls
-- ================================================================================

-- Default: Pause playback
-- Current: Wiedergabe pausieren
LOCALE:Set("radiogui.gui_player_controls.pause.tooltip", [[Wiedergabe pausieren]])

-- Default: Start playback
-- Current: Wiedergabe starten
LOCALE:Set("radiogui.gui_player_controls.play.tooltip", [[Wiedergabe starten]])

-- Default: No loop
-- Current: Keine Schleife
LOCALE:Set("radiogui.gui_player_controls.playback_loop.mode.none", [[Keine Schleife]])

-- Default: Playlist loop
-- Current: Wiedergabelisten-Schleife
LOCALE:Set("radiogui.gui_player_controls.playback_loop.mode.playlist", [[Wiedergabelisten-Schleife]])

-- Default: Song loop
-- Current: Lied-Schleife
LOCALE:Set("radiogui.gui_player_controls.playback_loop.mode.song", [[Lied-Schleife]])

-- Default:
--  | Change loop mode
--  | (Currently: %s)
-- Current:
--  | Schleife ändern
--  | (Aktuell: %s)
LOCALE:Set("radiogui.gui_player_controls.playback_loop.tooltip", [[Schleife ändern
(Aktuell: %s)]])

-- Default: Buffering...
-- Current: Wird gepuffert...
LOCALE:Set("radiogui.gui_player_controls.playbar.buffering", [[Wird gepuffert...]])

-- Default: Checking URL...
-- Current: URL wird überprüft...
LOCALE:Set("radiogui.gui_player_controls.playbar.checkingurl", [[URL wird überprüft...]])

-- Default: Downloading...
-- Current: Wird heruntergeladen...
LOCALE:Set("radiogui.gui_player_controls.playbar.downloading", [[Wird heruntergeladen...]])

-- Default: Error!
-- Current: Fehler!
LOCALE:Set("radiogui.gui_player_controls.playbar.error", [[Fehler!]])

-- Default: Sound stopped!
-- Current: Sound gestoppt!
LOCALE:Set("radiogui.gui_player_controls.playbar.killed", [[Sound gestoppt!]])

-- Default: Loading...
-- Current: Wird geladen...
LOCALE:Set("radiogui.gui_player_controls.playbar.loading", [[Wird geladen...]])

-- Default: Muted
-- Current: Stummgeschaltet
LOCALE:Set("radiogui.gui_player_controls.playbar.muted", [[Stummgeschaltet]])

-- Default: Stopped
-- Current: Gestoppt
LOCALE:Set("radiogui.gui_player_controls.playbar.stopped", [[Gestoppt]])

-- Default: Stop playback
-- Current: Wiedergabe stoppen
LOCALE:Set("radiogui.gui_player_controls.stop.tooltip", [[Wiedergabe stoppen]])

-- Default: Next track
-- Current: Nächster Titel
LOCALE:Set("radiogui.gui_player_controls.track_next.tooltip", [[Nächster Titel]])

-- Default: Previous track
-- Current: Vorheriger Titel
LOCALE:Set("radiogui.gui_player_controls.track_previous.tooltip", [[Vorheriger Titel]])

-- Default: Decrease volume
-- Current: Lautstärke verringern
LOCALE:Set("radiogui.gui_player_controls.volume_decrease.tooltip", [[Lautstärke verringern]])

-- Default: Increase volume
-- Current: Lautstärke erhöhen
LOCALE:Set("radiogui.gui_player_controls.volume_increase.tooltip", [[Lautstärke erhöhen]])

-- This file returns true, so we know it has been loaded properly
return true

