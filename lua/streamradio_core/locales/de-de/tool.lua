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
-- Main Category: tool
-- ################################################################################


-- ================================================================================
-- Sub Category:  tool.streamradio
-- ================================================================================

-- Default: Enable 3D Sound
-- Current: 3D-Sound aktivieren
LOCALE:Set("tool.streamradio.3dsound", [[3D-Sound aktivieren]])

-- Default: Cleaned up all Stream Radios
-- Current: Alle Stream Radios bereinigt
LOCALE:Set("tool.streamradio.action.cleaned", [[Alle Stream Radios bereinigt]])

-- Current: Stream Radio
LOCALE:Set("tool.streamradio.action.cleanup", [[Stream Radio]])

-- Default: You've hit the Stream Radio limit!
-- Current: Du hast das Stream Radio-Limit erreicht!
LOCALE:Set("tool.streamradio.action.limit", [[Du hast das Stream Radio-Limit erreicht!]])

-- Default: Undone Stream Radio
-- Current: Stream Radio rückgängig gemacht
LOCALE:Set("tool.streamradio.action.undone", [[Stream Radio rückgängig gemacht]])

-- Default: Spawns a Stream Radio
-- Current: Erzeugt ein Stream Radio
LOCALE:Set("tool.streamradio.desc", [[Erzeugt ein Stream Radio]])

-- Default: Freeze
-- Current: Einfrieren
LOCALE:Set("tool.streamradio.freeze", [[Einfrieren]])

-- Default: Create a stream radio
-- Current: Erstelle ein Stream Radio
LOCALE:Set("tool.streamradio.left", [[Erstelle ein Stream Radio]])

-- Default: Model:
-- Current: Modell:
LOCALE:Set("tool.streamradio.model", [[Modell:]])

-- Default: Some models (usually speakers) don't have a display. Use this tool or Wiremod to control those.
-- Current: Einige Modelle (normalerweise Lautsprecher) haben kein Display. Verwende dieses Tool oder Wiremod, um diese zu steuern.
LOCALE:Set("tool.streamradio.modelinfo", [[Einige Modelle (normalerweise Lautsprecher) haben kein Display. Verwende dieses Tool oder Wiremod, um diese zu steuern.]])

-- Default:
--  | Some models (usually speakers) don't have a display.
--  | Use this tool or Wiremod to control those.
-- Current:
--  | Einige Modelle (normalerweise Lautsprecher) haben kein Display.
--  | Verwende dieses Tool oder Wiremod, um diese zu steuern.
LOCALE:Set("tool.streamradio.modelinfo.desc", [[Einige Modelle (normalerweise Lautsprecher) haben kein Display.
Verwende dieses Tool oder Wiremod, um diese zu steuern.]])

-- Default: Some selectable models might not be available on the server. Those will be replaced by a default model.
-- Current: Einige wählbare Modelle sind möglicherweise nicht auf dem Server verfügbar. Diese werden durch ein Standardmodell ersetzt.
LOCALE:Set("tool.streamradio.modelinfo_mp", [[Einige wählbare Modelle sind möglicherweise nicht auf dem Server verfügbar. Diese werden durch ein Standardmodell ersetzt.]])

-- Default:
--  | Some selectable models might not be available on the server.
--  | Those will be replaced by a default model.
-- Current:
--  | Einige wählbare Modelle sind möglicherweise nicht auf dem Server verfügbar.
--  | Diese werden durch ein Standardmodell ersetzt.
LOCALE:Set("tool.streamradio.modelinfo_mp.desc", [[Einige wählbare Modelle sind möglicherweise nicht auf dem Server verfügbar.
Diese werden durch ein Standardmodell ersetzt.]])

-- Default: Mute Radio
-- Current: Radio Stummschalten
LOCALE:Set("tool.streamradio.mute", [[Radio Stummschalten]])

-- Default: NOTE: These are entity options too. So they only affect the radio they are applied on. The global settings for your client are at 'General Settings'.
-- Current: HINWEIS: Dies sind auch Entity-Optionen. Diese beeinflussen also nur das Radio, auf dem du diese anwendest. Die globalen Einstellungen für deinen Client befinden sich unter "Allgemeine Einstellungen".
LOCALE:Set("tool.streamradio.mute_volume_info", [[HINWEIS: Dies sind auch Entity-Optionen. Diese beeinflussen also nur das Radio, auf dem du diese anwendest. Die globalen Einstellungen für deinen Client befinden sich unter "Allgemeine Einstellungen".]])

-- Default: NOTE: These are entity options too. So they only affect the radio they are applied on. The global settings for your client are at 'General Settings'.
-- Current: HINWEIS: Dies sind auch Entity-Optionen. Diese beeinflussen also nur das Radio, auf dem du diese anwendest. Die globalen Einstellungen für deinen Client befinden sich unter "Allgemeine Einstellungen".
LOCALE:Set("tool.streamradio.mute_volume_info.desc", [[HINWEIS: Dies sind auch Entity-Optionen. Diese beeinflussen also nur das Radio, auf dem du diese anwendest. Die globalen Einstellungen für deinen Client befinden sich unter "Allgemeine Einstellungen".]])

-- Default: Radio Spawner
-- Current: Radio-Spawner
LOCALE:Set("tool.streamradio.name", [[Radio-Spawner]])

-- Default: Disable advanced wire outputs
-- Current: Deaktiviere erweiterte Draht-Ausgaben
LOCALE:Set("tool.streamradio.noadvwire", [[Deaktiviere erweiterte Draht-Ausgaben]])

-- Default:
--  | Disables the advanced wire outputs.
--  | It is always disabled if Wiremod or GM_BASS3 is not installed on the Server.
-- Current:
--  | Deaktiviert die erweiterten Draht-Ausgaben.
--  | Es ist immer deaktiviert, wenn Wiremod oder GM_BASS3 nicht auf dem Server installiert ist.
LOCALE:Set("tool.streamradio.noadvwire.desc", [[Deaktiviert die erweiterten Draht-Ausgaben.
Es ist immer deaktiviert, wenn Wiremod oder GM_BASS3 nicht auf dem Server installiert ist.]])

-- Default: Nocollide
-- Current: Keine Kollision
LOCALE:Set("tool.streamradio.nocollide", [[Keine Kollision]])

-- Default: Disable display
-- Current: Display deaktivieren
LOCALE:Set("tool.streamradio.nodisplay", [[Display deaktivieren]])

-- Default: Disable control
-- Current: Steuerung deaktivieren
LOCALE:Set("tool.streamradio.noinput", [[Steuerung deaktivieren]])

-- Default:
--  | Disable the control of the display.
--  | Wiremod controlling will still work.
-- Current:
--  | Deaktiviere die Steuerung des Displays.
--  | Die Wiremod-Steuerung funktioniert immer noch.
LOCALE:Set("tool.streamradio.noinput.desc", [[Deaktiviere die Steuerung des Displays.
Die Wiremod-Steuerung funktioniert immer noch.]])

-- Default: Disable spectrum visualization
-- Current: Spektrum-Visualisierung deaktivieren
LOCALE:Set("tool.streamradio.nospectrum", [[Spektrum-Visualisierung deaktivieren]])

-- Default: Disable rendering of the spectrum visualization on the display.
-- Current: Deaktiviere das Rendering der Spektrum-Visualisierung auf dem Display.
LOCALE:Set("tool.streamradio.nospectrum.desc", [[Deaktiviere das Rendering der Spektrum-Visualisierung auf dem Display.]])

-- Default: Start playback
-- Current: Wiedergabe starten
LOCALE:Set("tool.streamradio.play", [[Wiedergabe starten]])

-- Default:
--  | If set, the radio will try to play a given URL on spawn or apply.
--  | The URL can be set by this Tools or via Wiremod.
-- Current:
--  | Falls gesetzt, versucht das Radio, eine bestimmte URL beim Spawn oder Anwenden abzuspielen.
--  | Die URL kann von diesem Tool oder über Wiremod festgelegt werden.
LOCALE:Set("tool.streamradio.play.desc", [[Falls gesetzt, versucht das Radio, eine bestimmte URL beim Spawn oder Anwenden abzuspielen.
Die URL kann von diesem Tool oder über Wiremod festgelegt werden.]])

-- Default: Loop Playback:
-- Current: Wiedergabe wiederholen:
LOCALE:Set("tool.streamradio.playbackloopmode", [[Wiedergabe wiederholen:]])

-- Default: Set what happens after a song ends.
-- Current: Lege fest, was nach dem Ende eines Liedes passiert.
LOCALE:Set("tool.streamradio.playbackloopmode.desc", [[Lege fest, was nach dem Ende eines Liedes passiert.]])

-- Default: No loop
-- Current: Keine Wiederholung
LOCALE:Set("tool.streamradio.playbackloopmode.option.none", [[Keine Wiederholung]])

-- Default: Loop playlist
-- Current: Wiedergabeliste wiederholen
LOCALE:Set("tool.streamradio.playbackloopmode.option.playlist", [[Wiedergabeliste wiederholen]])

-- Default: Loop song
-- Current: Song wiederholen
LOCALE:Set("tool.streamradio.playbackloopmode.option.song", [[Song wiederholen]])

-- Current: Radius:
LOCALE:Set("tool.streamradio.radius", [[Radius:]])

-- Default: The radius in units the radio sound volume will drop down to 0% of the volume setting.
-- Current: Der Radius in Einheiten, in dem die Radioclautstärke auf 0% der Volumeneinstellung sinkt.
LOCALE:Set("tool.streamradio.radius.desc", [[Der Radius in Einheiten, in dem die Radioclautstärke auf 0% der Volumeneinstellung sinkt.]])

-- Default: Copy the model of an entity, but the most models will not have a display
-- Current: Kopiere das Modell eines Entitys, aber die meisten Modelle haben kein Display
LOCALE:Set("tool.streamradio.reload", [[Kopiere das Modell eines Entitys, aber die meisten Modelle haben kein Display]])

-- Default: Copy the settings of a radio
-- Current: Kopiere die Einstellungen eines Radios
LOCALE:Set("tool.streamradio.right", [[Kopiere die Einstellungen eines Radios]])

-- Default: Spawn settings:
-- Current: Spawn-Einstellungen:
LOCALE:Set("tool.streamradio.spawnsettings", [[Spawn-Einstellungen:]])

-- Default: Stream URL:
-- Current: Stream-URL:
LOCALE:Set("tool.streamradio.streamurl", [[Stream-URL:]])

-- Default: What can I put in as Stream URL?
-- Current: Was kann ich als Stream-URL eingeben?
LOCALE:Set("tool.streamradio.streamurl_info", [[Was kann ich als Stream-URL eingeben?]])

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
--  |    - Ein relativer Pfad in deinem Spielordner "sound".
--  |    - Der Pfad muss zu einer gültigen Sounddatei führen.
--  |    - Eingebundene Inhalte werden unterstützt und einbezogen.
--  |    - Wie: music/hl1_song3.mp3
--  |    - NICHT: sound/music/hl1_song3.mp3
--  |    - NICHT: C:/.../sound/music/hl1_song3.mp3
--  | 
--  | Online-Inhalte:
--  |    - Eine URL zu einer Online-Datei oder einem Stream.
--  |    - Die URL muss zu gültigen Sound-Inhalten führen.
--  |    - Kein HTML, kein Flash, keine Videos, kein YouTube
--  |    - Wie: https://stream.laut.fm/hiphop-forever
LOCALE:Set("tool.streamradio.streamurl_info.desc", [[Du kannst dies als Stream-URL eingeben:

Offline-Inhalte:
   - Ein relativer Pfad in deinem Spielordner "sound".
   - Der Pfad muss zu einer gültigen Sounddatei führen.
   - Eingebundene Inhalte werden unterstützt und einbezogen.
   - Wie: music/hl1_song3.mp3
   - NICHT: sound/music/hl1_song3.mp3
   - NICHT: C:/.../sound/music/hl1_song3.mp3

Online-Inhalte:
   - Eine URL zu einer Online-Datei oder einem Stream.
   - Die URL muss zu gültigen Sound-Inhalten führen.
   - Kein HTML, kein Flash, keine Videos, kein YouTube
   - Wie: https://stream.laut.fm/hiphop-forever]])

-- Default:
--  | Whitelist protected server:
--  | Only approved Stream URLs will work on this server!
-- Current:
--  | Whitelist-geschützter Server:
--  | Nur genehmigte Stream-URLs funktionieren auf diesem Server!
LOCALE:Set("tool.streamradio.streamurl_whitelist_info", [[Whitelist-geschützter Server:
Nur genehmigte Stream-URLs funktionieren auf diesem Server!]])

-- Default: Volume:
-- Current: Lautstärke:
LOCALE:Set("tool.streamradio.volume", [[Lautstärke:]])

-- Default: Weld
-- Current: Verschweißen
LOCALE:Set("tool.streamradio.weld", [[Verschweißen]])

-- Default: Weld to world
-- Current: Mit Welt verschweißen
LOCALE:Set("tool.streamradio.worldweld", [[Mit Welt verschweißen]])


-- ================================================================================
-- Sub Category:  tool.streamradio_gui_color_global
-- ================================================================================

-- Default: Selected color:
-- Current: Ausgewählte Farbe:
LOCALE:Set("tool.streamradio_gui_color_global.color", [[Ausgewählte Farbe:]])

-- Default: Change colors of radio GUI skins
-- Current: Farben der Radio-GUI-Skins ändern
LOCALE:Set("tool.streamradio_gui_color_global.desc", [[Farben der Radio-GUI-Skins ändern]])

-- Default: Apply colors of radio GUI skins
-- Current: Farben der Radio-GUI-Skins anwenden
LOCALE:Set("tool.streamradio_gui_color_global.left", [[Farben der Radio-GUI-Skins anwenden]])

-- Default: List of changeable colors:
-- Current: Liste der änderbaren Farben:
LOCALE:Set("tool.streamradio_gui_color_global.list", [[Liste der änderbaren Farben:]])

-- Default: Border
-- Current: Rand
LOCALE:Set("tool.streamradio_gui_color_global.list.border_color_border", [[Rand]])

-- Default: Color of the surrounding border.
-- Current: Farbe des umgebenden Rands.
LOCALE:Set("tool.streamradio_gui_color_global.list.border_color_border.desc", [[Farbe des umgebenden Rands.]])

-- Default: Button Background
-- Current: Button-Hintergrund
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color", [[Button-Hintergrund]])

-- Default: Color of all button backgrounds.
-- Current: Farbe aller Button-Hintergründe.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color.desc", [[Farbe aller Button-Hintergründe.]])

-- Default: Button Disabled Background
-- Current: Button deaktivierter Hintergrund
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_disabled", [[Button deaktivierter Hintergrund]])

-- Default: Color of all disabled button backgrounds.
-- Current: Farbe aller deaktivierten Button-Hintergründe.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_disabled.desc", [[Farbe aller deaktivierten Button-Hintergründe.]])

-- Default: Button Text
-- Current: Button-Text
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground", [[Button-Text]])

-- Default: Color of all button texts.
-- Current: Farbe aller Button-Texte.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground.desc", [[Farbe aller Button-Texte.]])

-- Default: Button Disabled Text
-- Current: Button deaktivierter Text
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground_disabled", [[Button deaktivierter Text]])

-- Default: Color of all disabled button texts.
-- Current: Farbe aller deaktivierten Button-Texte.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground_disabled.desc", [[Farbe aller deaktivierten Button-Texte.]])

-- Default: Button Hover Text
-- Current: Button-Hover-Text
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground_hover", [[Button-Hover-Text]])

-- Default: Color of all hovered button texts.
-- Current: Farbe aller gehoverten Button-Texte.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground_hover.desc", [[Farbe aller gehoverten Button-Texte.]])

-- Default: Button Hover Background
-- Current: Button-Hover-Hintergrund
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_hover", [[Button-Hover-Hintergrund]])

-- Default: Color of all hovered button backgrounds.
-- Current: Farbe aller gehoverten Button-Hintergründe.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_hover.desc", [[Farbe aller gehoverten Button-Hintergründe.]])

-- Default: Button Icon
-- Current: Button-Icon
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon", [[Button-Icon]])

-- Default: Color of all button icons.
-- Current: Farbe aller Button-Icons.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon.desc", [[Farbe aller Button-Icons.]])

-- Default: Button Disabled Icon
-- Current: Button deaktiviertes Icon
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon_disabled", [[Button deaktiviertes Icon]])

-- Default: Color of all disabled button icons.
-- Current: Farbe aller deaktivierten Button-Icons.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon_disabled.desc", [[Farbe aller deaktivierten Button-Icons.]])

-- Default: Button Hover Icon
-- Current: Button-Hover-Icon
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon_hover", [[Button-Hover-Icon]])

-- Default: Color of all hovered button icons.
-- Current: Farbe aller gehoverten Button-Icons.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon_hover.desc", [[Farbe aller gehoverten Button-Icons.]])

-- Default: Button Shadow
-- Current: Button-Schatten
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_shadow", [[Button-Schatten]])

-- Default: Color of all button Shadow.
-- Current: Farbe aller Button-Schatten.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_shadow.desc", [[Farbe aller Button-Schatten.]])

-- Default:
--  | If checked the color will be applied on left click.
--  | Uncheck this if you don't want to change this color on the GUI.
-- Current:
--  | Falls angekreuzt, wird die Farbe bei Linksklick angewendet.
--  | Entferne das Häkchen, wenn du diese Farbe in der GUI nicht ändern möchtest.
LOCALE:Set("tool.streamradio_gui_color_global.list.common.active.desc", [[Falls angekreuzt, wird die Farbe bei Linksklick angewendet.
Entferne das Häkchen, wenn du diese Farbe in der GUI nicht ändern möchtest.]])

-- Current: Cursor
LOCALE:Set("tool.streamradio_gui_color_global.list.cursor_color_cursor", [[Cursor]])

-- Default: Color of the Cursor.
-- Current: Farbe des Cursors.
LOCALE:Set("tool.streamradio_gui_color_global.list.cursor_color_cursor.desc", [[Farbe des Cursors.]])

-- Default: Error Background
-- Current: Fehler-Hintergrund
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color", [[Fehler-Hintergrund]])

-- Default: Color of the error box background.
-- Current: Farbe des Fehlerbox-Hintergrunds.
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color.desc", [[Farbe des Fehlerbox-Hintergrunds.]])

-- Default: Error Text
-- Current: Fehler-Text
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color_foreground", [[Fehler-Text]])

-- Default: Color of the error box text.
-- Current: Farbe des Fehlerbox-Texts.
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color_foreground.desc", [[Farbe des Fehlerbox-Texts.]])

-- Default: Error Shadow
-- Current: Fehler-Schatten
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color_shadow", [[Fehler-Schatten]])

-- Default: Color of the error box shadow.
-- Current: Farbe des Fehlerbox-Schattens.
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color_shadow.desc", [[Farbe des Fehlerbox-Schattens.]])

-- Default: Header Background
-- Current: Header-Hintergrund
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color", [[Header-Hintergrund]])

-- Default: Color of the header background.
-- Current: Farbe des Header-Hintergrunds.
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color.desc", [[Farbe des Header-Hintergrunds.]])

-- Default: Header Text
-- Current: Header-Text
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color_foreground", [[Header-Text]])

-- Default: Color of the header text.
-- Current: Farbe des Header-Texts.
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color_foreground.desc", [[Farbe des Header-Texts.]])

-- Default: Header Shadow
-- Current: Header-Schatten
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color_shadow", [[Header-Schatten]])

-- Default: Color of the header shadow.
-- Current: Farbe des Header-Schattens.
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color_shadow.desc", [[Farbe des Header-Schattens.]])

-- Default: Background
-- Current: Hintergrund
LOCALE:Set("tool.streamradio_gui_color_global.list.main_color", [[Hintergrund]])

-- Default: Color of the main background.
-- Current: Farbe des Haupt-Hintergrunds.
LOCALE:Set("tool.streamradio_gui_color_global.list.main_color.desc", [[Farbe des Haupt-Hintergrunds.]])

-- Default: Spectrum Background
-- Current: Spektrum-Hintergrund
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color", [[Spektrum-Hintergrund]])

-- Default: Color of the spectrum box background.
-- Current: Farbe des Spektrum-Box-Hintergrunds.
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color.desc", [[Farbe des Spektrum-Box-Hintergrunds.]])

-- Default: Spectrum Foreground
-- Current: Spektrum-Vordergrund
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_foreground", [[Spektrum-Vordergrund]])

-- Default: Color of the spectrum box foreground.
-- Current: Farbe des Spektrum-Box-Vordergrunds.
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_foreground.desc", [[Farbe des Spektrum-Box-Vordergrunds.]])

-- Default: Spectrum Icon
-- Current: Spektrum-Icon
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_icon", [[Spektrum-Icon]])

-- Default: Color of the spectrum box icons.
-- Current: Farbe der Spektrum-Box-Icons.
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_icon.desc", [[Farbe der Spektrum-Box-Icons.]])

-- Default: Spectrum Shadow
-- Current: Spektrum-Schatten
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_shadow", [[Spektrum-Schatten]])

-- Default: Color of the spectrum box shadow.
-- Current: Farbe des Spektrum-Box-Schattens.
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_shadow.desc", [[Farbe des Spektrum-Box-Schattens.]])

-- Default: Radio Colorer (Global)
-- Current: Radio-Färber (Global)
LOCALE:Set("tool.streamradio_gui_color_global.name", [[Radio-Färber (Global)]])

-- Default: Reset the skin of the radio to default
-- Current: Setze die Skin des Radios auf Standard zurück
LOCALE:Set("tool.streamradio_gui_color_global.reload", [[Setze die Skin des Radios auf Standard zurück]])

-- Default: Copy the colors from radio GUI skins
-- Current: Kopiere die Farben von Radio-GUI-Skins
LOCALE:Set("tool.streamradio_gui_color_global.right", [[Kopiere die Farben von Radio-GUI-Skins]])


-- ================================================================================
-- Sub Category:  tool.streamradio_gui_color_individual
-- ================================================================================

-- Default: Selected color:
-- Current: Ausgewählte Farbe:
LOCALE:Set("tool.streamradio_gui_color_individual.color", [[Ausgewählte Farbe:]])

-- Default: Change colors of aimed radio GUI panels
-- Current: Farben der anvisierten Radio-GUI-Panels ändern
LOCALE:Set("tool.streamradio_gui_color_individual.desc", [[Farben der anvisierten Radio-GUI-Panels ändern]])

-- Default: Apply colors of radio GUI panels
-- Current: Farben der Radio-GUI-Panels anwenden
LOCALE:Set("tool.streamradio_gui_color_individual.left", [[Farben der Radio-GUI-Panels anwenden]])

-- Default: List of changeable colors:
-- Current: Liste der änderbaren Farben:
LOCALE:Set("tool.streamradio_gui_color_individual.list", [[Liste der änderbaren Farben:]])

-- Default: Background
-- Current: Hintergrund
LOCALE:Set("tool.streamradio_gui_color_individual.list.color", [[Hintergrund]])

-- Default: Color of the background.
-- Current: Farbe des Hintergrunds.
LOCALE:Set("tool.streamradio_gui_color_individual.list.color.desc", [[Farbe des Hintergrunds.]])

-- Default: [Button only] Disabled Background
-- Current: [Nur Button] Deaktivierter Hintergrund
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_disabled", [[[Nur Button] Deaktivierter Hintergrund]])

-- Default: Color of the background when disabled. (Button only)
-- Current: Farbe des Hintergrunds, wenn deaktiviert. (Nur Button)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_disabled.desc", [[Farbe des Hintergrunds, wenn deaktiviert. (Nur Button)]])

-- Default: Foreground/Text
-- Current: Vordergrund/Text
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground", [[Vordergrund/Text]])

-- Default: Color of the foreground such as texts or spectrum bars.
-- Current: Farbe des Vordergrunds wie Texte oder Spektrum-Balken.
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground.desc", [[Farbe des Vordergrunds wie Texte oder Spektrum-Balken.]])

-- Default: [Button only] Disabled Foreground/Text
-- Current: [Nur Button] Deaktivierter Vordergrund/Text
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground_disabled", [[[Nur Button] Deaktivierter Vordergrund/Text]])

-- Default: Color of the foreground when disabled. (Button only)
-- Current: Farbe des Vordergrunds, wenn deaktiviert. (Nur Button)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground_disabled.desc", [[Farbe des Vordergrunds, wenn deaktiviert. (Nur Button)]])

-- Default: [Button only] Hover Foreground/Text
-- Current: [Nur Button] Hover-Vordergrund/Text
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground_hover", [[[Nur Button] Hover-Vordergrund/Text]])

-- Default: Color of the foreground when hovered. (Button only)
-- Current: Farbe des Vordergrunds beim Hover. (Nur Button)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground_hover.desc", [[Farbe des Vordergrunds beim Hover. (Nur Button)]])

-- Default: [Button only] Hover Background
-- Current: [Nur Button] Hover-Hintergrund
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_hover", [[[Nur Button] Hover-Hintergrund]])

-- Default: Color of the background when hovered. (Button only)
-- Current: Farbe des Hintergrunds beim Hover. (Nur Button)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_hover.desc", [[Farbe des Hintergrunds beim Hover. (Nur Button)]])

-- Current: Icon
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon", [[Icon]])

-- Default: Color of the icons.
-- Current: Farbe der Icons.
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon.desc", [[Farbe der Icons.]])

-- Default: [Button only] Disabled Icon
-- Current: [Nur Button] Deaktiviertes Icon
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon_disabled", [[[Nur Button] Deaktiviertes Icon]])

-- Default: Color of the icon when disabled. (Button only)
-- Current: Farbe des Icons, wenn deaktiviert. (Nur Button)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon_disabled.desc", [[Farbe des Icons, wenn deaktiviert. (Nur Button)]])

-- Default: [Button only] Hover Icon
-- Current: [Nur Button] Hover-Icon
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon_hover", [[[Nur Button] Hover-Icon]])

-- Default: Color of the icon when hovered. (Button only)
-- Current: Farbe des Icons beim Hover. (Nur Button)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon_hover.desc", [[Farbe des Icons beim Hover. (Nur Button)]])

-- Default: Shadow
-- Current: Schatten
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_shadow", [[Schatten]])

-- Default: Color of the shadow.
-- Current: Farbe des Schattens.
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_shadow.desc", [[Farbe des Schattens.]])

-- Default:
--  | If checked the color will be applied on left click.
--  | Uncheck this if you don't want to change this color on a panel.
-- Current:
--  | Falls angekreuzt, wird die Farbe bei Linksklick angewendet.
--  | Entferne das Häkchen, wenn du diese Farbe auf einem Panel nicht ändern möchtest.
LOCALE:Set("tool.streamradio_gui_color_individual.list.common.active.desc", [[Falls angekreuzt, wird die Farbe bei Linksklick angewendet.
Entferne das Häkchen, wenn du diese Farbe auf einem Panel nicht ändern möchtest.]])

-- Default: Radio Colorer (Individual)
-- Current: Radio-Färber (Individuell)
LOCALE:Set("tool.streamradio_gui_color_individual.name", [[Radio-Färber (Individuell)]])

-- Default: Copy the colors from radio GUI panels
-- Current: Kopiere die Farben von Radio-GUI-Panels
LOCALE:Set("tool.streamradio_gui_color_individual.right", [[Kopiere die Farben von Radio-GUI-Panels]])


-- ================================================================================
-- Sub Category:  tool.streamradio_gui_skin
-- ================================================================================

-- Default: Change, Copy or Save the skin of radios
-- Current: Skin der Radios ändern, kopieren oder speichern
LOCALE:Set("tool.streamradio_gui_skin.desc", [[Skin der Radios ändern, kopieren oder speichern]])

-- Default: Delete
-- Current: Löschen
LOCALE:Set("tool.streamradio_gui_skin.file.button.delete", [[Löschen]])

-- Default: Delete the selected skin file from your hard disk.
-- Current: Lösche die ausgewählte Skin-Datei von deiner Festplatte.
LOCALE:Set("tool.streamradio_gui_skin.file.button.delete.desc", [[Lösche die ausgewählte Skin-Datei von deiner Festplatte.]])

-- Default: You need to enter or select something to delete.
-- Current: Du musst etwas eingeben oder auswählen, um es zu löschen.
LOCALE:Set("tool.streamradio_gui_skin.file.button.delete.error.empty", [[Du musst etwas eingeben oder auswählen, um es zu löschen.]])

-- Default: The skin file does not exist.
-- Current: Die Skin-Datei existiert nicht.
LOCALE:Set("tool.streamradio_gui_skin.file.button.delete.error.notfound", [[Die Skin-Datei existiert nicht.]])

-- Default: The skin file is protected and can not be deleted.
-- Current: Die Skin-Datei ist geschützt und kann nicht gelöscht werden.
LOCALE:Set("tool.streamradio_gui_skin.file.button.delete.error.protected", [[Die Skin-Datei ist geschützt und kann nicht gelöscht werden.]])

-- Default: Open
-- Current: Öffnen
LOCALE:Set("tool.streamradio_gui_skin.file.button.open", [[Öffnen]])

-- Default:
--  | Open selected skin file.
--  | You can also double click on the file to open it.
-- Current:
--  | Öffne die ausgewählte Skin-Datei.
--  | Du kannst auch doppelt auf die Datei klicken, um sie zu öffnen.
LOCALE:Set("tool.streamradio_gui_skin.file.button.open.desc", [[Öffne die ausgewählte Skin-Datei.
Du kannst auch doppelt auf die Datei klicken, um sie zu öffnen.]])

-- Default: You need to enter or select something to open.
-- Current: Du musst etwas eingeben oder auswählen, um es zu öffnen.
LOCALE:Set("tool.streamradio_gui_skin.file.button.open.error.empty", [[Du musst etwas eingeben oder auswählen, um es zu öffnen.]])

-- Default: The skin file does not exist.
-- Current: Die Skin-Datei existiert nicht.
LOCALE:Set("tool.streamradio_gui_skin.file.button.open.error.notfound", [[Die Skin-Datei existiert nicht.]])

-- Default: Save
-- Current: Speichern
LOCALE:Set("tool.streamradio_gui_skin.file.button.save", [[Speichern]])

-- Default: Save skin to the filename as given above to your hard disk.
-- Current: Speichere die Skin unter dem oben angegebenen Dateinamen auf deiner Festplatte.
LOCALE:Set("tool.streamradio_gui_skin.file.button.save.desc", [[Speichere die Skin unter dem oben angegebenen Dateinamen auf deiner Festplatte.]])

-- Default: The skin file is protected and can not be overwritten.
-- Current: Die Skin-Datei ist geschützt und kann nicht überschrieben werden.
LOCALE:Set("tool.streamradio_gui_skin.file.button.save.error.protected", [[Die Skin-Datei ist geschützt und kann nicht überschrieben werden.]])

-- Default: Delete skin?
-- Current: Skin löschen?
LOCALE:Set("tool.streamradio_gui_skin.file.delete", [[Skin löschen?]])

-- Default: Do you want to delete this skin file from your hard disk?
-- Current: Möchtest du diese Skin-Datei von deiner Festplatte löschen?
LOCALE:Set("tool.streamradio_gui_skin.file.delete.desc", [[Möchtest du diese Skin-Datei von deiner Festplatte löschen?]])

-- Default: No, don't delete it.
-- Current: Nein, nicht löschen.
LOCALE:Set("tool.streamradio_gui_skin.file.delete.no", [[Nein, nicht löschen.]])

-- Default: Yes, delete it.
-- Current: Ja, lösche sie.
LOCALE:Set("tool.streamradio_gui_skin.file.delete.yes", [[Ja, lösche sie.]])

-- Default: Overwrite skin?
-- Current: Skin überschreiben?
LOCALE:Set("tool.streamradio_gui_skin.file.save", [[Skin überschreiben?]])

-- Default: Do you want to overwrite this skin file?
-- Current: Möchtest du diese Skin-Datei überschreiben?
LOCALE:Set("tool.streamradio_gui_skin.file.save.desc", [[Möchtest du diese Skin-Datei überschreiben?]])

-- Default: No, don't overwrite it.
-- Current: Nein, nicht überschreiben.
LOCALE:Set("tool.streamradio_gui_skin.file.save.no", [[Nein, nicht überschreiben.]])

-- Default: Yes, overwrite it.
-- Current: Ja, überschreibe sie.
LOCALE:Set("tool.streamradio_gui_skin.file.save.yes", [[Ja, überschreibe sie.]])

-- Default:
--  | Enter the name of your skin here.
--  | Press 'Save' to save it to your hard disk.
-- Current:
--  | Gib den Namen deiner Skin hier ein.
--  | Drücke 'Speichern', um sie auf deiner Festplatte zu speichern.
LOCALE:Set("tool.streamradio_gui_skin.file.text.desc", [[Gib den Namen deiner Skin hier ein.
Drücke 'Speichern', um sie auf deiner Festplatte zu speichern.]])

-- Default: Apply skin to the radio
-- Current: Skin auf das Radio anwenden
LOCALE:Set("tool.streamradio_gui_skin.left", [[Skin auf das Radio anwenden]])

-- Default: List of saved skins:
-- Current: Liste der gespeicherten Skins:
LOCALE:Set("tool.streamradio_gui_skin.list", [[Liste der gespeicherten Skins:]])

-- Default: Radio Skin Duplicator
-- Current: Radio-Skin-Duplikator
LOCALE:Set("tool.streamradio_gui_skin.name", [[Radio-Skin-Duplikator]])

-- Default: Reset the skin to default
-- Current: Setze die Skin auf Standard zurück
LOCALE:Set("tool.streamradio_gui_skin.reload", [[Setze die Skin auf Standard zurück]])

-- Default: Copy skin from the radio
-- Current: Kopiere Skin vom Radio
LOCALE:Set("tool.streamradio_gui_skin.right", [[Kopiere Skin vom Radio]])

-- This file returns true, so we know it has been loaded properly
return true

