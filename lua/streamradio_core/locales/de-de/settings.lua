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
-- Main Category: settings
-- ################################################################################

-- Current: Stream Radio
LOCALE:Set("settings.addon_title", [[Stream Radio]])


-- ================================================================================
-- Sub Category:  settings.admin
-- ================================================================================

-- Default: Allow clients to use GM_BASS3 if available
-- Current: Clients erlauben, GM_BASS3 zu verwenden, falls verfügbar
LOCALE:Set("settings.admin.bass3.allow_client.title", [[Clients erlauben, GM_BASS3 zu verwenden, falls verfügbar]])

-- Default: Clear server stream cache
-- Current: Server-Stream-Cache löschen
LOCALE:Set("settings.admin.bass3.cache_clear.title", [[Server-Stream-Cache löschen]])

-- Default: Use GM_BASS3 on the server if available
-- Current: GM_BASS3 auf dem Server verwenden, falls verfügbar
LOCALE:Set("settings.admin.bass3.enable.title", [[GM_BASS3 auf dem Server verwenden, falls verfügbar]])

-- Default: Maximum count
-- Current: Maximale Anzahl
LOCALE:Set("settings.admin.bass3.max_spectrums.title", [[Maximale Anzahl]])

-- Default: Install GM_BASS3 on the server to unlock the options below.
-- Current: Installiere GM_BASS3 auf dem Server, um die folgenden Optionen freizuschalten.
LOCALE:Set("settings.admin.bass3.panel.gm_bass3_install.info", [[Installiere GM_BASS3 auf dem Server, um die folgenden Optionen freizuschalten.]])

-- Default: Maximum count of radios with Advanced Wire Outputs.
-- Current: Maximale Anzahl von Radios mit Advanced Wire Outputs.
LOCALE:Set("settings.admin.bass3.panel.max_spectrums.info", [[Maximale Anzahl von Radios mit Advanced Wire Outputs.]])

-- Default: GM_BASS3 Options
-- Current: GM_BASS3 Optionen
LOCALE:Set("settings.admin.bass3.panel.title", [[GM_BASS3 Optionen]])

-- Default: Playlists rebuild setting
-- Current: Einstellung zum Neuerstellen von Wiedergabelisten
LOCALE:Set("settings.admin.danger.label", [[Einstellung zum Neuerstellen von Wiedergabelisten]])

-- Default:
--  | CAUTION: Be careful what you in this section!
--  | Unanticipated loss of CUSTOM playlist files can be caused by mistakes!
-- Current:
--  | VORSICHT: Sei vorsichtig mit dem, was du in diesem Abschnitt tust!
--  | Unerwarteter Verlust von BENUTZERDEFINIERTEN Wiedergabelistendateien kann durch Fehler verursacht werden!
LOCALE:Set("settings.admin.danger.playlist_data_loss_warning.info", [[VORSICHT: Sei vorsichtig mit dem, was du in diesem Abschnitt tust!
Unerwarteter Verlust von BENUTZERDEFINIERTEN Wiedergabelistendateien kann durch Fehler verursacht werden!]])

-- Default: CAUTION: This section affects ALL playlists on your server!
-- Current: VORSICHT: Dieser Abschnitt betrifft ALLE Wiedergabelisten auf deinem Server!
LOCALE:Set("settings.admin.danger.playlist_options_dangerous.info", [[VORSICHT: Dieser Abschnitt betrifft ALLE Wiedergabelisten auf deinem Server!]])

-- Default: Only use this if want clean up or reset ALL playlist files.
-- Current: Verwende dies nur, wenn du ALLE Wiedergabelistendateien bereinigen oder zurücksetzen möchtest.
LOCALE:Set("settings.admin.danger.playlist_options_dangerous_usage.info", [[Verwende dies nur, wenn du ALLE Wiedergabelistendateien bereinigen oder zurücksetzen möchtest.]])

-- Default: You can use this regularly to fix issues with broken playlists.
-- Current: Du kannst dies regelmäßig verwenden, um Probleme mit fehlerhaften Wiedergabelisten zu beheben.
LOCALE:Set("settings.admin.danger.playlist_options_regularly_usable.info", [[Du kannst dies regelmäßig verwenden, um Probleme mit fehlerhaften Wiedergabelisten zu beheben.]])

-- Default:
--  | Reverts stock playlist files to default.
--  | This overwrites the default playlists and their changes globally!
-- Current:
--  | Stellt mitgelieferte Wiedergabelistendateien auf Standard zurück.
--  | Dies überschreibt die Standard-Wiedergabelisten und deine Änderungen global!
LOCALE:Set("settings.admin.danger.rebuildplaylists.info", [[Stellt mitgelieferte Wiedergabelistendateien auf Standard zurück.
Dies überschreibt die Standard-Wiedergabelisten und deine Änderungen global!]])

-- Default: Rebuild ALL playlists
-- Current: ALLE Wiedergabelisten neu erstellen
LOCALE:Set("settings.admin.danger.rebuildplaylists.label", [[ALLE Wiedergabelisten neu erstellen]])

-- Default:
--  | Do you really want to rebuild stock playlists?
--  | This overwrites the default playlists and their changes globally!
-- Current:
--  | Möchtest du wirklich mitgelieferte Wiedergabelisten neu erstellen?
--  | Dies überschreibt die Standard-Wiedergabelisten und deine Änderungen global!
LOCALE:Set("settings.admin.danger.rebuildplaylists.message", [[Möchtest du wirklich mitgelieferte Wiedergabelisten neu erstellen?
Dies überschreibt die Standard-Wiedergabelisten und deine Änderungen global!]])

-- Default:
--  | Reverts stock playlist files in 'community' to default.
--  | This overwrites default playlists and their changes in 'community'!
-- Current:
--  | Stellt mitgelieferte Wiedergabelistendateien in "community" auf Standard zurück.
--  | Dies überschreibt Standard-Wiedergabelisten und deine Änderungen in "community"!
LOCALE:Set("settings.admin.danger.rebuildplaylists_community.info", [[Stellt mitgelieferte Wiedergabelistendateien in "community" auf Standard zurück.
Dies überschreibt Standard-Wiedergabelisten und deine Änderungen in "community"!]])

-- Default: Rebuild community playlists
-- Current: Community-Wiedergabelisten neu erstellen
LOCALE:Set("settings.admin.danger.rebuildplaylists_community.label", [[Community-Wiedergabelisten neu erstellen]])

-- Default:
--  | Do you really want to rebuild stock community playlists?
--  | This overwrites default playlists and their changes in 'community'!
-- Current:
--  | Möchtest du wirklich mitgelieferte Community-Wiedergabelisten neu erstellen?
--  | Dies überschreibt Standard-Wiedergabelisten und deine Änderungen in "community"!
LOCALE:Set("settings.admin.danger.rebuildplaylists_community.message", [[Möchtest du wirklich mitgelieferte Community-Wiedergabelisten neu erstellen?
Dies überschreibt Standard-Wiedergabelisten und deine Änderungen in "community"!]])

-- Default:
--  | Rebuild mode for playlists in 'community'.
--  | Effective with server restarts.
-- Current:
--  | Neuerstellungsmodus für Wiedergabelisten in "community".
--  | Wirksam mit Server-Neustarts.
LOCALE:Set("settings.admin.danger.rebuildplaylists_community_auto.info", [[Neuerstellungsmodus für Wiedergabelisten in "community".
Wirksam mit Server-Neustarts.]])

-- Default: Rebuild mode
-- Current: Neuerstellungsmodus
LOCALE:Set("settings.admin.danger.rebuildplaylists_community_auto.label", [[Neuerstellungsmodus]])

-- Default: Off
-- Current: Aus
LOCALE:Set("settings.admin.danger.rebuildplaylists_community_auto.option.off", [[Aus]])

-- Default: Auto rebuild
-- Current: Automatische Neuerstellung
LOCALE:Set("settings.admin.danger.rebuildplaylists_community_auto.option.rebuild", [[Automatische Neuerstellung]])

-- Default: Auto reset & rebuild (default)
-- Current: Automatisches Zurücksetzen & Neuerstellung (Standard)
LOCALE:Set("settings.admin.danger.rebuildplaylists_community_auto.option.reset_rebuild", [[Automatisches Zurücksetzen & Neuerstellung (Standard)]])

-- Default:
--  | Reverts ALL playlist files to default.
--  | This removes ALL custom playlists and changes globally!
-- Current:
--  | Stellt ALLE Wiedergabelistendateien auf Standard zurück.
--  | Dies entfernt ALLE benutzerdefinierten Wiedergabelisten und Änderungen global!
LOCALE:Set("settings.admin.danger.resetplaylists.info", [[Stellt ALLE Wiedergabelistendateien auf Standard zurück.
Dies entfernt ALLE benutzerdefinierten Wiedergabelisten und Änderungen global!]])

-- Default: Factory reset ALL playlists
-- Current: ALLE Wiedergabelisten auf Werkseinstellung zurücksetzen
LOCALE:Set("settings.admin.danger.resetplaylists.label", [[ALLE Wiedergabelisten auf Werkseinstellung zurücksetzen]])

-- Default:
--  | Do you really want to reset ALL playlists to defaults?
--  | This removes ALL custom playlists and changes globally!
-- Current:
--  | Möchtest du wirklich ALLE Wiedergabelisten auf Standardwerte zurücksetzen?
--  | Dies entfernt ALLE benutzerdefinierten Wiedergabelisten und Änderungen global!
LOCALE:Set("settings.admin.danger.resetplaylists.message", [[Möchtest du wirklich ALLE Wiedergabelisten auf Standardwerte zurücksetzen?
Dies entfernt ALLE benutzerdefinierten Wiedergabelisten und Änderungen global!]])

-- Default:
--  | Reverts ALL playlist files in 'community' to default.
--  | This removes ALL custom playlists and changes in 'community'!
-- Current:
--  | Stellt ALLE Wiedergabelistendateien in "community" auf Standard zurück.
--  | Dies entfernt ALLE benutzerdefinierten Wiedergabelisten und Änderungen in "community"!
LOCALE:Set("settings.admin.danger.resetplaylists_community.info", [[Stellt ALLE Wiedergabelistendateien in "community" auf Standard zurück.
Dies entfernt ALLE benutzerdefinierten Wiedergabelisten und Änderungen in "community"!]])

-- Default: Factory reset community playlists
-- Current: Community-Wiedergabelisten auf Werkseinstellung zurücksetzen
LOCALE:Set("settings.admin.danger.resetplaylists_community.label", [[Community-Wiedergabelisten auf Werkseinstellung zurücksetzen]])

-- Default:
--  | Do you really want to reset ALL community playlists to defaults?
--  | This removes ALL custom playlists and changes in 'community'!
-- Current:
--  | Möchtest du wirklich ALLE Community-Wiedergabelisten auf Standardwerte zurücksetzen?
--  | Dies entfernt ALLE benutzerdefinierten Wiedergabelisten und Änderungen in "community"!
LOCALE:Set("settings.admin.danger.resetplaylists_community.message", [[Möchtest du wirklich ALLE Community-Wiedergabelisten auf Standardwerte zurücksetzen?
Dies entfernt ALLE benutzerdefinierten Wiedergabelisten und Änderungen in "community"!]])

-- Default: 3D Stream Radio admin settings
-- Current: 3D Stream Radio Admin-Einstellungen
LOCALE:Set("settings.admin.panel.title", [[3D Stream Radio Admin-Einstellungen]])

-- Default: Security Options
-- Current: Sicherheitsoptionen
LOCALE:Set("settings.admin.security.label", [[Sicherheitsoptionen]])

-- Default:
--  | CAUTION: This affects the server security of this addon.
--  | Only disable the whitelist if you know what you are doing!
--  | Otherwise never turn this off!
-- Current:
--  | VORSICHT: Dies beeinflusst die Server-Sicherheit dieses Addons.
--  | Deaktiviere die Whitelist nur, wenn du weißt, was du tust!
--  | Schalte dies sonst niemals aus!
LOCALE:Set("settings.admin.security.security_whitelist_warning.info", [[VORSICHT: Dies beeinflusst die Server-Sicherheit dieses Addons.
Deaktiviere die Whitelist nur, wenn du weißt, was du tust!
Schalte dies sonst niemals aus!]])

-- Default: Log stream URLs to console
-- Current: Stream-URLs auf Konsole protokollieren
LOCALE:Set("settings.admin.security.url_log_mode.label", [[Stream-URLs auf Konsole protokollieren]])

-- Default: Log all URLs
-- Current: Alle URLs protokollieren
LOCALE:Set("settings.admin.security.url_log_mode.option.all", [[Alle URLs protokollieren]])

-- Default: No logging
-- Current: Keine Protokollierung
LOCALE:Set("settings.admin.security.url_log_mode.option.off", [[Keine Protokollierung]])

-- Default: Log online URLs only
-- Current: Nur Online-URLs protokollieren
LOCALE:Set("settings.admin.security.url_log_mode.option.online", [[Nur Online-URLs protokollieren]])

-- Default: The whitelist is based of the installed playlists. Edit them to change the whitelist or use the quick whitelist options on a radio entity.
-- Current: Die Whitelist basiert auf den installierten Wiedergabelisten. Bearbeite diese, um die Whitelist zu ändern, oder verwende die Quick-Whitelist-Optionen auf einem Radio-Entity.
LOCALE:Set("settings.admin.security.url_whitelist.info.1", [[Die Whitelist basiert auf den installierten Wiedergabelisten. Bearbeite diese, um die Whitelist zu ändern, oder verwende die Quick-Whitelist-Optionen auf einem Radio-Entity.]])

-- Default: It is always disabled on single player.
-- Current: Dies ist immer im Einzelspielermodus deaktiviert.
LOCALE:Set("settings.admin.security.url_whitelist.info.2", [[Dies ist immer im Einzelspielermodus deaktiviert.]])

-- Default: URL Whitelist
-- Current: URL-Whitelist
LOCALE:Set("settings.admin.security.url_whitelist_enable.label", [[URL-Whitelist]])

-- Default: Disable Stream URL whitelist (dangerous)
-- Current: Stream-URL-Whitelist deaktivieren (gefährlich)
LOCALE:Set("settings.admin.security.url_whitelist_enable.option.disable", [[Stream-URL-Whitelist deaktivieren (gefährlich)]])

-- Default: Enable Stream URL whitelist (recommended)
-- Current: Stream-URL-Whitelist aktivieren (empfohlen)
LOCALE:Set("settings.admin.security.url_whitelist_enable.option.enable", [[Stream-URL-Whitelist aktivieren (empfohlen)]])

-- Default: If the server has the addon 'CFC Client HTTP Whitelist' installed, the built-in whitelist is disabled automatically for better useability.
-- Current: Wenn der Server das Addon "CFC Client HTTP Whitelist" installiert hat, wird die integrierte Whitelist automatisch deaktiviert, um die Benutzerfreundlichkeit zu verbessern.
LOCALE:Set("settings.admin.security.url_whitelist_enable_on_cfcwhitelist.info.1", [[Wenn der Server das Addon "CFC Client HTTP Whitelist" installiert hat, wird die integrierte Whitelist automatisch deaktiviert, um die Benutzerfreundlichkeit zu verbessern.]])

-- Default: If the box is checked, the built-in whitelist will be always active. Both options are safe to use.
-- Current: Wenn das Kontrollkästchen aktiviert ist, wird die integrierte Whitelist immer aktiv sein. Beide Optionen sind sicher zu verwenden.
LOCALE:Set("settings.admin.security.url_whitelist_enable_on_cfcwhitelist.info.2", [[Wenn das Kontrollkästchen aktiviert ist, wird die integrierte Whitelist immer aktiv sein. Beide Optionen sind sicher zu verwenden.]])

-- Default: Enable the build-in whitelist even if CFC Whitelist is installed
-- Current: Aktiviere die integrierte Whitelist auch wenn CFC Whitelist installiert ist
LOCALE:Set("settings.admin.security.url_whitelist_enable_on_cfcwhitelist.label", [[Aktiviere die integrierte Whitelist auch wenn CFC Whitelist installiert ist]])

-- Default: Press this button to reload the whitelist. It is rebuilt from server's playlist files.
-- Current: Drücke diese Schaltfläche, um die Whitelist neu zu laden. Diese wird aus den Wiedergabelistendateien des Servers neu erstellt.
LOCALE:Set("settings.admin.security.url_whitelist_reload.info.1", [[Drücke diese Schaltfläche, um die Whitelist neu zu laden. Diese wird aus den Wiedergabelistendateien des Servers neu erstellt.]])

-- Default: You can safely use it anytime you want.
-- Current: Du kannst dies jederzeit sicher verwenden.
LOCALE:Set("settings.admin.security.url_whitelist_reload.info.2", [[Du kannst dies jederzeit sicher verwenden.]])

-- Default: Reload URL Whitelist
-- Current: URL-Whitelist neu laden
LOCALE:Set("settings.admin.security.url_whitelist_reload.label", [[URL-Whitelist neu laden]])

-- Default: Always trust radios owned by admins (skips whitelist)
-- Current: Vertraue Radios, die von Admins besessen werden (überspringt Whitelist)
LOCALE:Set("settings.admin.security.url_whitelist_trust_admin_radios.label", [[Vertraue Radios, die von Admins besessen werden (überspringt Whitelist)]])

-- Default: Admin Settings
-- Current: Admin-Einstellungen
LOCALE:Set("settings.admin.title", [[Admin-Einstellungen]])


-- ================================================================================
-- Sub Category:  settings.general
-- ================================================================================

-- Default: Use GM_BASS3 if installed
-- Current: GM_BASS3 verwenden, falls installiert
LOCALE:Set("settings.general.bass3_enable.label", [[GM_BASS3 verwenden, falls installiert]])

-- Default: Clear client stream cache
-- Current: Client-Stream-Cache löschen
LOCALE:Set("settings.general.cache_clear.label", [[Client-Stream-Cache löschen]])

-- Default: Show cursor
-- Current: Cursor anzeigen
LOCALE:Set("settings.general.gui_cursor_enable.label", [[Cursor anzeigen]])

-- Default: GUI draw distance
-- Current: GUI-Zeichnungsabstand
LOCALE:Set("settings.general.gui_distance.label", [[GUI-Zeichnungsabstand]])

-- Default: Hide GUIs
-- Current: GUIs ausblenden
LOCALE:Set("settings.general.gui_hide.label", [[GUIs ausblenden]])

-- Default: Language
-- Current: Sprache
LOCALE:Set("settings.general.locale.label", [[Sprache]])

-- Default: Mute at distance
-- Current: Bei Distanz stummschalten
LOCALE:Set("settings.general.mute_distance.label", [[Bei Distanz stummschalten]])

-- Default: Mute all radios from other players
-- Current: Alle Radios anderer Spieler stummschalten
LOCALE:Set("settings.general.mute_foreign.label", [[Alle Radios anderer Spieler stummschalten]])

-- Default: Mute all radios
-- Current: Alle Radios stummschalten
LOCALE:Set("settings.general.mute_global.label", [[Alle Radios stummschalten]])

-- Default: Mute radios on game unfocus
-- Current: Radios bei Spielverlust stummschalten
LOCALE:Set("settings.general.mute_unfocused.label", [[Radios bei Spielverlust stummschalten]])

-- Default: 3D Stream Radio general settings
-- Current: 3D Stream Radio allgemeine Einstellungen
LOCALE:Set("settings.general.panel.title", [[3D Stream Radio allgemeine Einstellungen]])

-- Default: Enable rendertargets
-- Current: Renderziele aktivieren
LOCALE:Set("settings.general.rendertarget.label", [[Renderziele aktivieren]])

-- Default: Rendertarget FPS
-- Current: Renderziel FPS
LOCALE:Set("settings.general.rendertarget_fps.label", [[Renderziel FPS]])

-- Default: Enable 3D Sound
-- Current: 3D-Sound aktivieren
LOCALE:Set("settings.general.sfx_3dsound.label", [[3D-Sound aktivieren]])

-- Default: Spectrum bars
-- Current: Spektrumbalken
LOCALE:Set("settings.general.spectrum_barcount.label", [[Spektrumbalken]])

-- Default: Spectrum draw distance
-- Current: Spektrumzeichnungsabstand
LOCALE:Set("settings.general.spectrum_distance.label", [[Spektrumzeichnungsabstand]])

-- Default: Hide spectrum
-- Current: Spektrum ausblenden
LOCALE:Set("settings.general.spectrum_hide.label", [[Spektrum ausblenden]])

-- Default: General Settings
-- Current: Allgemeine Einstellungen
LOCALE:Set("settings.general.title", [[Allgemeine Einstellungen]])

-- Default: Radio control/use key
-- Current: Benutzertaste
LOCALE:Set("settings.general.usekey_global.label", [[Benutzertaste]])

-- Default: Radio control/use key while in vehicles
-- Current: Benutzertaste während der Fahrt in Fahrzeugen
LOCALE:Set("settings.general.usekey_vehicle.label", [[Benutzertaste während der Fahrt in Fahrzeugen]])

-- Default: Global volume
-- Current: Globale Lautstärke
LOCALE:Set("settings.general.volume_global.label", [[Globale Lautstärke]])

-- Default: Volume factor of radios behind walls (sound occlusion)
-- Current: Lautstärkefaktor für Radios hinter Wänden (Schallabsorption)
LOCALE:Set("settings.general.volume_occluded.label", [[Lautstärkefaktor für Radios hinter Wänden (Schallabsorption)]])


-- ================================================================================
-- Sub Category:  settings.vr
-- ================================================================================

-- Default: Show cursor in VR
-- Current: Cursor in VR anzeigen
LOCALE:Set("settings.vr.gui_cursor_enable.label", [[Cursor in VR anzeigen]])

-- Default: 3D Stream Radio VR settings
-- Current: 3D Stream Radio VR-Einstellungen
LOCALE:Set("settings.vr.panel.title", [[3D Stream Radio VR-Einstellungen]])

-- Default: VR Settings
-- Current: VR-Einstellungen
LOCALE:Set("settings.vr.title", [[VR-Einstellungen]])

-- Default: Enable VR Touch Control
-- Current: VR-Touch-Steuerung aktivieren
LOCALE:Set("settings.vr.touch_enable.label", [[VR-Touch-Steuerung aktivieren]])

-- Default: Enable VR Trigger Control
-- Current: VR-Trigger-Steuerung aktivieren
LOCALE:Set("settings.vr.trigger_enable.label", [[VR-Trigger-Steuerung aktivieren]])

-- This file returns true, so we know it has been loaded properly
return true

