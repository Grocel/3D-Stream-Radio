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
-- Main Category: vgui
-- ################################################################################

-- Default: by %s
-- Current: von %s
LOCALE:Set("vgui.clientconvar.locale.by_author", [[von %s]])


-- ================================================================================
-- Sub Category:  vgui.error_help_panel
-- ================================================================================

-- Default: Copy to clipboard
-- Current: In Zwischenablage kopieren
LOCALE:Set("vgui.error_help_panel.clipboard", [[In Zwischenablage kopieren]])

-- Default: Close
-- Current: Schließen
LOCALE:Set("vgui.error_help_panel.close", [[Schließen]])

-- Default: Stream Radio Error Information | %s
-- Current: Stream Radio Fehler-Information | %s
LOCALE:Set("vgui.error_help_panel.header", [[Stream Radio Fehler-Information | %s]])

-- Default: Error %i (%s): %s
-- Current: Fehler %i (%s): %s
LOCALE:Set("vgui.error_help_panel.header_error_info", [[Fehler %i (%s): %s]])

-- Default: View online help
-- Current: Online-Hilfe anzeigen
LOCALE:Set("vgui.error_help_panel.view_online", [[Online-Hilfe anzeigen]])


-- ================================================================================
-- Sub Category:  vgui.menu
-- ================================================================================

-- Default: Admin Settings
-- Current: Admin-Einstellungen
LOCALE:Set("vgui.menu.admin_button.admin_settings", [[Admin-Einstellungen]])

-- Default: Show Playlist Editor
-- Current: Wiedergabelisten-Editor anzeigen
LOCALE:Set("vgui.menu.admin_button.playlist_editor", [[Wiedergabelisten-Editor anzeigen]])

-- Default: General Settings
-- Current: Allgemeine Einstellungen
LOCALE:Set("vgui.menu.button.general_settings", [[Allgemeine Einstellungen]])

-- Current: Stream Radio Tool
LOCALE:Set("vgui.menu.button.tool", [[Stream Radio Tool]])

-- Default: Show VRMod Panel
-- Current: VRMod-Panel anzeigen
LOCALE:Set("vgui.menu.button.vrmod", [[VRMod-Panel anzeigen]])

-- Default: Download VRMod (Workshop)
-- Current: VRMod herunterladen (Workshop)
LOCALE:Set("vgui.menu.button.vrmod_download", [[VRMod herunterladen (Workshop)]])

-- Default: Made by Grocel
-- Current: Erstellt von Grocel
LOCALE:Set("vgui.menu.credits.madeby", [[Erstellt von Grocel]])

-- Default: This can not be undone!
-- Current: Dies kann nicht rückgängig gemacht werden!
LOCALE:Set("vgui.menu.danger_button.generic.dialog_box.hint", [[Dies kann nicht rückgängig gemacht werden!]])

-- Default: No
-- Current: Nein
LOCALE:Set("vgui.menu.danger_button.generic.dialog_box.no", [[Nein]])

-- Default: Yes
-- Current: Ja
LOCALE:Set("vgui.menu.danger_button.generic.dialog_box.yes", [[Ja]])

-- Default: Show CFC HTTP Whitelist Info (Workshop)
-- Current: CFC HTTP Whitelist-Info anzeigen (Workshop)
LOCALE:Set("vgui.menu.link_button.cfc_whitelist_info", [[CFC HTTP Whitelist-Info anzeigen (Workshop)]])

-- Default: Show FAQ (Workshop)
-- Current: FAQ anzeigen (Workshop)
LOCALE:Set("vgui.menu.link_button.faq", [[FAQ anzeigen (Workshop)]])

-- Default:
--  | %s
--  | 
--  | URL: %s
--  | 
--  | Right click to copy the URL to clipboard.
-- Current:
--  | %s
--  | 
--  | URL: %s
--  | 
--  | Rechtsklick zum Kopieren der URL in die Zwischenablage.
LOCALE:Set("vgui.menu.link_button.generic.tooltip", [[%s

URL: %s

Rechtsklick zum Kopieren der URL in die Zwischenablage.]])

-- Default: Show VR FAQ (Workshop)
-- Current: VR-FAQ anzeigen (Workshop)
LOCALE:Set("vgui.menu.link_button.vrmod_faq", [[VR-FAQ anzeigen (Workshop)]])

-- Default: Show Whitelist Info (Workshop)
-- Current: Whitelist-Info anzeigen (Workshop)
LOCALE:Set("vgui.menu.link_button.whitelist_info", [[Whitelist-Info anzeigen (Workshop)]])

-- Default:
--  | VRMod is not loaded.
--  |   - Install VRMod to enable VR support.
--  |   - VR Headset required!
--  |   - VR is optional, this addon works without VR.
-- Current:
--  | VRMod ist nicht geladen.
--  |   - Installiere VRMod, um VR-Unterstützung zu aktivieren.
--  |   - VR-Headset erforderlich!
--  |   - VR ist optional, dieses Addon funktioniert ohne VR.
LOCALE:Set("vgui.menu.vrmod.error", [[VRMod ist nicht geladen.
  - Installiere VRMod, um VR-Unterstützung zu aktivieren.
  - VR-Headset erforderlich!
  - VR ist optional, dieses Addon funktioniert ohne VR.]])

-- Default:
--  | Powered by VRMod!
--  |   - VRMod is made by Catse
--  |   - VR Headset required!
--  |   - VR is optional, this addon works without VR.
-- Current:
--  | Powered by VRMod!
--  |   - VRMod wird von Catse gemacht
--  |   - VR-Headset erforderlich!
--  |   - VR ist optional, dieses Addon funktioniert ohne VR.
LOCALE:Set("vgui.menu.vrmod.info", [[Powered by VRMod!
  - VRMod wird von Catse gemacht
  - VR-Headset erforderlich!
  - VR ist optional, dieses Addon funktioniert ohne VR.]])


-- ================================================================================
-- Sub Category:  vgui.playlist_editor
-- ================================================================================

-- Default: Add
-- Current: Hinzufügen
LOCALE:Set("vgui.playlist_editor.add.label", [[Hinzufügen]])

-- Default: Apply
-- Current: Anwenden
LOCALE:Set("vgui.playlist_editor.apply.label", [[Anwenden]])

-- Default: Apply current order to playlist
-- Current: Aktuelle Reihenfolge auf Wiedergabeliste anwenden
LOCALE:Set("vgui.playlist_editor.apply_order.tooltip", [[Aktuelle Reihenfolge auf Wiedergabeliste anwenden]])

-- Default: Cancel
-- Current: Abbrechen
LOCALE:Set("vgui.playlist_editor.dialog_box.cancel", [[Abbrechen]])

-- Default: Create folder
-- Current: Ordner erstellen
LOCALE:Set("vgui.playlist_editor.dialog_box.create_dir.create", [[Ordner erstellen]])

-- Default:
--  | Create a new folder
--  | - All invalid characters are fitered out
--  | - Case insensitive, converted to lowercase
-- Current:
--  | Erstelle einen neuen Ordner
--  | - Alle ungültigen Zeichen werden gefiltert
--  | - Groß- und Kleinschreibung wird nicht beachtet, in Kleinbuchstaben konvertiert
LOCALE:Set("vgui.playlist_editor.dialog_box.create_dir.dialog", [[Erstelle einen neuen Ordner
- Alle ungültigen Zeichen werden gefiltert
- Groß- und Kleinschreibung wird nicht beachtet, in Kleinbuchstaben konvertiert]])

-- Default: New folder
-- Current: Neuer Ordner
LOCALE:Set("vgui.playlist_editor.dialog_box.create_dir.title", [[Neuer Ordner]])

-- Default: Create new file
-- Current: Neue Datei erstellen
LOCALE:Set("vgui.playlist_editor.dialog_box.create_file.create", [[Neue Datei erstellen]])

-- Default:
--  | Create a new playlist
--  | - All invalid characters are fitered out
--  | - Case insensitive, converted to lowercase
--  | - Valid formats are: %s
-- Current:
--  | Erstelle eine neue Wiedergabeliste
--  | - Alle ungültigen Zeichen werden gefiltert
--  | - Groß- und Kleinschreibung wird nicht beachtet, in Kleinbuchstaben konvertiert
--  | - Gültige Formate sind: %s
LOCALE:Set("vgui.playlist_editor.dialog_box.create_file.dialog", [[Erstelle eine neue Wiedergabeliste
- Alle ungültigen Zeichen werden gefiltert
- Groß- und Kleinschreibung wird nicht beachtet, in Kleinbuchstaben konvertiert
- Gültige Formate sind: %s]])

-- Default: New playlist..
-- Current: Neue Wiedergabeliste..
LOCALE:Set("vgui.playlist_editor.dialog_box.create_file.title", [[Neue Wiedergabeliste..]])

-- Default: Are you sure to delete this file/folder?
-- Current: Möchtest du diese Datei/diesen Ordner wirklich löschen?
LOCALE:Set("vgui.playlist_editor.dialog_box.delete.dialog", [[Möchtest du diese Datei/diesen Ordner wirklich löschen?]])

-- Default: Delete file!
-- Current: Datei löschen!
LOCALE:Set("vgui.playlist_editor.dialog_box.delete.title", [[Datei löschen!]])

-- Default: No
-- Current: Nein
LOCALE:Set("vgui.playlist_editor.dialog_box.no", [[Nein]])

-- Current: OK
LOCALE:Set("vgui.playlist_editor.dialog_box.ok", [[OK]])

-- Default:
--  | Save a file
--  | - All invalid characters are fitered out
--  | - Case insensitive, converted to lowercase
--  | - Valid formats are: %s
-- Current:
--  | Speichere eine Datei
--  | - Alle ungültigen Zeichen werden gefiltert
--  | - Groß- und Kleinschreibung wird nicht beachtet, in Kleinbuchstaben konvertiert
--  | - Gültige Formate sind: %s
LOCALE:Set("vgui.playlist_editor.dialog_box.save_to.dialog", [[Speichere eine Datei
- Alle ungültigen Zeichen werden gefiltert
- Groß- und Kleinschreibung wird nicht beachtet, in Kleinbuchstaben konvertiert
- Gültige Formate sind: %s]])

-- Default: Save to file
-- Current: In Datei speichern
LOCALE:Set("vgui.playlist_editor.dialog_box.save_to.save", [[In Datei speichern]])

-- Default: Save to..
-- Current: Speichern unter..
LOCALE:Set("vgui.playlist_editor.dialog_box.save_to.title", [[Speichern unter..]])

-- Default: Are you sure to discard the changes?
-- Current: Möchtest du die Änderungen wirklich verwerfen?
LOCALE:Set("vgui.playlist_editor.dialog_box.unsaved_playlist.dialog", [[Möchtest du die Änderungen wirklich verwerfen?]])

-- Default: Unsaved playlist!
-- Current: Ungespeicherte Wiedergabeliste!
LOCALE:Set("vgui.playlist_editor.dialog_box.unsaved_playlist.title", [[Ungespeicherte Wiedergabeliste!]])

-- Default: Yes
-- Current: Ja
LOCALE:Set("vgui.playlist_editor.dialog_box.yes", [[Ja]])

-- Current: Name
LOCALE:Set("vgui.playlist_editor.files.column.name.label", [[Name]])

-- Default: Type
-- Current: Typ
LOCALE:Set("vgui.playlist_editor.files.column.type.label", [[Typ]])

-- Default: Delete
-- Current: Löschen
LOCALE:Set("vgui.playlist_editor.files_menu.delete.label", [[Löschen]])

-- Default: New folder
-- Current: Neuer Ordner
LOCALE:Set("vgui.playlist_editor.files_menu.new_folder.label", [[Neuer Ordner]])

-- Default: New
-- Current: Neu
LOCALE:Set("vgui.playlist_editor.files_menu.new_list.label", [[Neu]])

-- Default: Open
-- Current: Öffnen
LOCALE:Set("vgui.playlist_editor.files_menu.open.label", [[Öffnen]])

-- Default: Refresh
-- Current: Aktualisieren
LOCALE:Set("vgui.playlist_editor.files_menu.refresh.label", [[Aktualisieren]])

-- Default: Stream Radio Playlist Editor
-- Current: Stream Radio Wiedergabelisten-Editor
LOCALE:Set("vgui.playlist_editor.header", [[Stream Radio Wiedergabelisten-Editor]])

-- Default: List mode
-- Current: Listenmodus
LOCALE:Set("vgui.playlist_editor.list_tab.label", [[Listenmodus]])

-- Default: Edit the playlist in a list view
-- Current: Bearbeite die Wiedergabeliste in einer Listenansicht
LOCALE:Set("vgui.playlist_editor.list_tab.tooltip", [[Bearbeite die Wiedergabeliste in einer Listenansicht]])

-- Default: Move item down
-- Current: Element nach unten verschieben
LOCALE:Set("vgui.playlist_editor.move_down.tooltip", [[Element nach unten verschieben]])

-- Default: Move item up
-- Current: Element nach oben verschieben
LOCALE:Set("vgui.playlist_editor.move_up.tooltip", [[Element nach oben verschieben]])

-- Current: Name:
LOCALE:Set("vgui.playlist_editor.name_edit.label", [[Name:]])

-- Default: Enter a name for this Entry
-- Current: Gib einen Namen für diesen Eintrag ein
LOCALE:Set("vgui.playlist_editor.name_edit.placeholder", [[Gib einen Namen für diesen Eintrag ein]])

-- Default: New folder
-- Current: Neuer Ordner
LOCALE:Set("vgui.playlist_editor.new_folder.tooltip", [[Neuer Ordner]])

-- Default: New list
-- Current: Neue Liste
LOCALE:Set("vgui.playlist_editor.new_list.tooltip", [[Neue Liste]])

-- Current: Name
LOCALE:Set("vgui.playlist_editor.playlist.column.name.label", [[Name]])

-- Default: No.
-- Current: Nr.
LOCALE:Set("vgui.playlist_editor.playlist.column.number.label", [[Nr.]])

-- Current: URL
LOCALE:Set("vgui.playlist_editor.playlist.column.url.label", [[URL]])

-- Default: Refresh and reload
-- Current: Aktualisieren und neu laden
LOCALE:Set("vgui.playlist_editor.reload.tooltip", [[Aktualisieren und neu laden]])

-- Default: Remove
-- Current: Entfernen
LOCALE:Set("vgui.playlist_editor.remove.label", [[Entfernen]])

-- Default: Save list
-- Current: Liste speichern
LOCALE:Set("vgui.playlist_editor.save.tooltip", [[Liste speichern]])

-- Default: Save to..
-- Current: Speichern unter..
LOCALE:Set("vgui.playlist_editor.save_to.tooltip", [[Speichern unter..]])

-- Default:
--  | About this text based playlist editor:
--  | 
--  | - Changes are automatically synchronized between this view and the list view.
--  | - Enter the name and the URL for each entry you want to add.
--  | - The syntax is independent from the playlist format.
--  | - Missing lines are skipped or are filled with placeholders.
--  | - Whitespaces are trimed on each line.
-- Current:
--  | Über diesen textbasierten Wiedergabelisten-Editor:
--  | 
--  | - Änderungen werden automatisch zwischen dieser Ansicht und der Listenansicht synchronisiert.
--  | - Gib den Namen und die URL für jeden Eintrag ein, den du hinzufügen möchtest.
--  | - Die Syntax ist unabhängig vom Wiedergabelistenformat.
--  | - Fehlende Zeilen werden übersprungen oder mit Platzhaltern gefüllt.
--  | - Leerzeichen werden in jeder Zeile entfernt.
LOCALE:Set("vgui.playlist_editor.text_tab.help.general", [[Über diesen textbasierten Wiedergabelisten-Editor:

- Änderungen werden automatisch zwischen dieser Ansicht und der Listenansicht synchronisiert.
- Gib den Namen und die URL für jeden Eintrag ein, den du hinzufügen möchtest.
- Die Syntax ist unabhängig vom Wiedergabelistenformat.
- Fehlende Zeilen werden übersprungen oder mit Platzhaltern gefüllt.
- Leerzeichen werden in jeder Zeile entfernt.]])

-- Default:
--  | Example:
--  | 
--  | 1.FM - ABSOLUTE TOP 40 RADIO [newline]
--  | http://185.33.21.112:80/top40_128 [newline]
--  | 1.FM - Alternative Rock X Hits [newline]
--  | http://185.33.21.112:80/x_128 [newline]
--  | ...
-- Current:
--  | Beispiel:
--  | 
--  | 1.FM - ABSOLUTE TOP 40 RADIO [newline]
--  | http://185.33.21.112:80/top40_128 [newline]
--  | 1.FM - Alternative Rock X Hits [newline]
--  | http://185.33.21.112:80/x_128 [newline]
--  | ...
LOCALE:Set("vgui.playlist_editor.text_tab.help.syntax", [[Beispiel:

1.FM - ABSOLUTE TOP 40 RADIO [newline]
http://185.33.21.112:80/top40_128 [newline]
1.FM - Alternative Rock X Hits [newline]
http://185.33.21.112:80/x_128 [newline]
...]])

-- Default: Text mode
-- Current: Textmodus
LOCALE:Set("vgui.playlist_editor.text_tab.label", [[Textmodus]])

-- Default: Edit the playlist in a text field (for advanced users)
-- Current: Bearbeite die Wiedergabeliste in einem Textfeld (für fortgeschrittene Benutzer)
LOCALE:Set("vgui.playlist_editor.text_tab.tooltip", [[Bearbeite die Wiedergabeliste in einem Textfeld (für fortgeschrittene Benutzer)]])

-- Current: URL:
LOCALE:Set("vgui.playlist_editor.url_edit.label", [[URL:]])


-- ================================================================================
-- Sub Category:  vgui.url_text_entry
-- ================================================================================

-- Default: Enter file path or online URL
-- Current: Dateipfad oder Online-URL eingeben
LOCALE:Set("vgui.url_text_entry.placeholder", [[Dateipfad oder Online-URL eingeben]])

-- Default: The URL is empty!
-- Current: Die URL ist leer!
LOCALE:Set("vgui.url_text_entry.tooltip.state_empty", [[Die URL ist leer!]])

-- Default: The URL is not valid!
-- Current: Die URL ist ungültig!
LOCALE:Set("vgui.url_text_entry.tooltip.state_error", [[Die URL ist ungültig!]])

-- Default: The URL is valid!
-- Current: Die URL ist gültig!
LOCALE:Set("vgui.url_text_entry.tooltip.state_found", [[Die URL ist gültig!]])

-- Default: Checking URL...
-- Current: URL wird überprüft...
LOCALE:Set("vgui.url_text_entry.tooltip.state_idle", [[URL wird überprüft...]])

-- Default:
--  | You can enter this as a Stream URL:
--  | 
--  | Offline content:
--  |    - A relative path inside your game's 'sound' folder.
--  |    - The path must lead to a valid sound file.
--  |    - Mounted content is supported and included.
--  |    - Like: music/hl1_song3.mp3
--  |    - NOT: sound/music/hl1_song3.mp3
--  |    - NOT: C:/.../sound/music/hl1_song3.mp3
--  | 
--  | Online content:
--  |    - An URL to an online file or stream.
--  |    - The URL must lead to valid sound content.
--  |    - No HTML, no Flash, no Videos, no YouTube
--  |    - Like: https://stream.laut.fm/hiphop-forever
-- Current:
--  | Du kannst dies als Stream-URL eingeben:
--  | 
--  | Offline-Inhalte:
--  |    - Ein relativer Pfad in deinem Spielordner 'sound'.
--  |    - Der Pfad muss zu einer gültigen Sounddatei führen.
--  |    - Gemountete Inhalte werden unterstützt und einbezogen.
--  |    - Wie: music/hl1_song3.mp3
--  |    - NICHT: sound/music/hl1_song3.mp3
--  |    - NICHT: C:/.../sound/music/hl1_song3.mp3
--  | 
--  | Online-Inhalte:
--  |    - Eine URL zu einer Online-Datei oder einem Stream.
--  |    - Die URL muss zu gültigem Sound-Inhalt führen.
--  |    - Kein HTML, kein Flash, keine Videos, kein YouTube
--  |    - Wie: https://stream.laut.fm/hiphop-forever
LOCALE:Set("vgui.url_text_entry.tooltip.url_hint", [[Du kannst dies als Stream-URL eingeben:

Offline-Inhalte:
   - Ein relativer Pfad in deinem Spielordner 'sound'.
   - Der Pfad muss zu einer gültigen Sounddatei führen.
   - Gemountete Inhalte werden unterstützt und einbezogen.
   - Wie: music/hl1_song3.mp3
   - NICHT: sound/music/hl1_song3.mp3
   - NICHT: C:/.../sound/music/hl1_song3.mp3

Online-Inhalte:
   - Eine URL zu einer Online-Datei oder einem Stream.
   - Die URL muss zu gültigem Sound-Inhalt führen.
   - Kein HTML, kein Flash, keine Videos, kein YouTube
   - Wie: https://stream.laut.fm/hiphop-forever]])

-- This file returns true, so we know it has been loaded properly
return true

