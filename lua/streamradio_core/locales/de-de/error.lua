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
-- Main Category: error
-- ################################################################################


-- ================================================================================
-- Sub Category:  error.playlist_error_invalid_file_1100
-- ================================================================================

-- Default: Invalid Playlist
-- Current: Ungültige Wiedergabeliste
LOCALE:Set("error.playlist_error_invalid_file_1100.description", [[Ungültige Wiedergabeliste]])

-- Default:
--  | The Playlist file you are trying to load is invalid.
--  | 
--  | This could be the problem:
--  | 	- The playlist could not be found or read.
--  | 	- Its format is not supported.
--  | 	- It is broken.
--  | 	- It is empty.
--  | 
--  | Supported playlist formats:
--  | 	M3U, PLS, VDF, JSON
--  | 
--  | Playlists are located at "<path_to_game>/garrysmod/data/streamradio/playlists/".
--  | 
--  | Hint: Use the playlist editor to make playlists.
-- Current:
--  | Die Wiedergabelistendatei, die du laden möchtest, ist ungültig.
--  | 
--  | Dies könnte das Problem sein:
--  | 	- Die Wiedergabeliste konnte nicht gefunden oder gelesen werden.
--  | 	- Ihr Format wird nicht unterstützt.
--  | 	- Sie ist beschädigt.
--  | 	- Sie ist leer.
--  | 
--  | Unterstützte Wiedergabelistenformate:
--  | 	M3U, PLS, VDF, JSON
--  | 
--  | Wiedergabelisten befinden sich unter "<path_to_game>/garrysmod/data/streamradio/playlists/".
--  | 
--  | Tipp: Verwende den Wiedergabelisten-Editor, um Wiedergabelisten zu erstellen.
LOCALE:Set("error.playlist_error_invalid_file_1100.helptext", [[Die Wiedergabelistendatei, die du laden möchtest, ist ungültig.

Dies könnte das Problem sein:
	- Die Wiedergabeliste konnte nicht gefunden oder gelesen werden.
	- Ihr Format wird nicht unterstützt.
	- Sie ist beschädigt.
	- Sie ist leer.

Unterstützte Wiedergabelistenformate:
	M3U, PLS, VDF, JSON

Wiedergabelisten befinden sich unter "<path_to_game>/garrysmod/data/streamradio/playlists/".

Tipp: Verwende den Wiedergabelisten-Editor, um Wiedergabelisten zu erstellen.]])


-- ================================================================================
-- Sub Category:  error.stream_error_already_14
-- ================================================================================

-- Default: Already initialized/paused/whatever
-- Current: Bereits initialisiert/pausiert/beliebig
LOCALE:Set("error.stream_error_already_14.description", [[Bereits initialisiert/pausiert/beliebig]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_already_14.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_bad_drive_letter_path_1030
-- ================================================================================

-- Default: Drive letter paths are not supported, use relative paths
-- Current: Laufwerksbuchstabenpfade werden nicht unterstützt, verwende relative Pfade
LOCALE:Set("error.stream_error_bad_drive_letter_path_1030.description", [[Laufwerksbuchstabenpfade werden nicht unterstützt, verwende relative Pfade]])

-- Default:
--  | Do not use drive letter paths. Use relative paths instead.
--  | 
--  | A relative path never starts with a drive letter such as "C:/" or "D:/".
--  | 
--  | This is a relative path:
--  |   music/hl1_song3.mp3
--  | 
--  | This is NOT a relative path:
--  |   C:/Program Files (x86)/Steam/steamapps/common/GarrysMod/garrysmod/sound/music/hl1_song3.mp3
-- Current:
--  | Verwende keine Laufwerksbuchstabenpfade. Verwende stattdessen relative Pfade.
--  | 
--  | Ein relativer Pfad beginnt niemals mit einem Laufwerksbuchstaben wie "C:/" oder "D:/".
--  | 
--  | Dies ist ein relativer Pfad:
--  |   music/hl1_song3.mp3
--  | 
--  | Dies ist KEIN relativer Pfad:
--  |   C:/Program Files (x86)/Steam/steamapps/common/GarrysMod/garrysmod/sound/music/hl1_song3.mp3
LOCALE:Set("error.stream_error_bad_drive_letter_path_1030.helptext", [[Verwende keine Laufwerksbuchstabenpfade. Verwende stattdessen relative Pfade.

Ein relativer Pfad beginnt niemals mit einem Laufwerksbuchstaben wie "C:/" oder "D:/".

Dies ist ein relativer Pfad:
  music/hl1_song3.mp3

Dies ist KEIN relativer Pfad:
  C:/Program Files (x86)/Steam/steamapps/common/GarrysMod/garrysmod/sound/music/hl1_song3.mp3]])


-- ================================================================================
-- Sub Category:  error.stream_error_buflost_4
-- ================================================================================

-- Default: The sample buffer was lost
-- Current: Der Beispielpuffer wurde verloren
LOCALE:Set("error.stream_error_buflost_4.description", [[Der Beispielpuffer wurde verloren]])

-- Default:
--  | Your sound driver/interface was lost.
--  | 
--  | To fix it you need to do this:
--  | - Plugin your speakers or head phones.
--  | - Enable the sound device.
--  | - Restart the game. Do not just disconnect!
--  | - Restart your PC, if it still not works.
-- Current:
--  | Dein Audiotreiber/Audio-Interface wurde unterbrochen.
--  | 
--  | Um dies zu beheben, musst du folgendes tun:
--  | - Schließe deine Lautsprecher oder Kopfhörer an.
--  | - Aktiviere das Audiogerät.
--  | - Starte das Spiel neu. Trenne es nicht einfach!
--  | - Starte deinen PC neu, wenn es immer noch nicht funktioniert.
LOCALE:Set("error.stream_error_buflost_4.helptext", [[Dein Audiotreiber/Audio-Interface wurde unterbrochen.

Um dies zu beheben, musst du folgendes tun:
- Schließe deine Lautsprecher oder Kopfhörer an.
- Aktiviere das Audiogerät.
- Starte das Spiel neu. Trenne es nicht einfach!
- Starte deinen PC neu, wenn es immer noch nicht funktioniert.]])


-- ================================================================================
-- Sub Category:  error.stream_error_busy_46
-- ================================================================================

-- Default: The device is busy
-- Current: Das Gerät ist beschäftigt
LOCALE:Set("error.stream_error_busy_46.description", [[Das Gerät ist beschäftigt]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_busy_46.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_codec_44
-- ================================================================================

-- Default: Codec is not available/supported
-- Current: Codec ist nicht verfügbar/unterstützt
LOCALE:Set("error.stream_error_codec_44.description", [[Codec ist nicht verfügbar/unterstützt]])

-- Default:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
-- Current:
--  | Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.
--  | 
--  | Diese Dinge funktionieren NICHT:
--  | 	- HTML-Seiten, die Töne abspielen.
--  | 	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
--  | 	- Alles, was eine Art Anmeldung für den Zugriff erfordert.
--  | 	- Alles, was nicht öffentlich ist.
--  | 	- Soundskripte oder Soundeigenschaften.
--  | 	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)
--  | 
--  | Diese Dinge funktionieren:
--  | 	- URLs zu Sounddateien (aka. DIREKTER Download).
--  | 	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
--  | 	- URLs in diesen Wiedergabelistendateien.
--  | 	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
--  | 	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
--  | 	- Formate, die unten aufgelistet sind.
--  | 
--  | Unterstützte Formate:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.
LOCALE:Set("error.stream_error_codec_44.helptext", [[Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.

Diese Dinge funktionieren NICHT:
	- HTML-Seiten, die Töne abspielen.
	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
	- Alles, was eine Art Anmeldung für den Zugriff erfordert.
	- Alles, was nicht öffentlich ist.
	- Soundskripte oder Soundeigenschaften.
	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)

Diese Dinge funktionieren:
	- URLs zu Sounddateien (aka. DIREKTER Download).
	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
	- URLs in diesen Wiedergabelistendateien.
	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
	- Formate, die unten aufgelistet sind.

Unterstützte Formate:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.]])


-- ================================================================================
-- Sub Category:  error.stream_error_create_33
-- ================================================================================

-- Default: Couldn't create the file
-- Current: Konnte die Datei nicht erstellen
LOCALE:Set("error.stream_error_create_33.description", [[Konnte die Datei nicht erstellen]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_create_33.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_decode_38
-- ================================================================================

-- Default: The channel is a 'decoding channel'
-- Current: Der Kanal ist ein "Dekodierungskanal"
LOCALE:Set("error.stream_error_decode_38.description", [[Der Kanal ist ein "Dekodierungskanal"]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_decode_38.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_denied_49
-- ================================================================================

-- Default: Access denied
-- Current: Zugang verweigert
LOCALE:Set("error.stream_error_denied_49.description", [[Zugang verweigert]])

-- Default:
--  | Can not access the resource. Login credentials required, but not supported.
--  | 
--  | CAUTION: Do not try to access private resources! Credentials could leak to other connected players or the server!
--  | 
--  | Better use public resources only.
-- Current:
--  | Kann nicht auf die Ressource zugreifen. Anmeldeinformationen erforderlich, aber nicht unterstützt.
--  | 
--  | WARNUNG: Versuche nicht, auf private Ressourcen zuzugreifen! Anmeldeinformationen können an andere verbundene Spieler oder den Server weitergeleitet werden!
--  | 
--  | Verwende besser nur öffentliche Ressourcen.
LOCALE:Set("error.stream_error_denied_49.helptext", [[Kann nicht auf die Ressource zugreifen. Anmeldeinformationen erforderlich, aber nicht unterstützt.

WARNUNG: Versuche nicht, auf private Ressourcen zuzugreifen! Anmeldeinformationen können an andere verbundene Spieler oder den Server weitergeleitet werden!

Verwende besser nur öffentliche Ressourcen.]])


-- ================================================================================
-- Sub Category:  error.stream_error_device_23
-- ================================================================================

-- Default: Illegal device number
-- Current: Ungültige Gerätenummer
LOCALE:Set("error.stream_error_device_23.description", [[Ungültige Gerätenummer]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_device_23.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_driver_3
-- ================================================================================

-- Default: Can't find a free/valid driver
-- Current: Kann keinen freien/gültigen Treiber finden
LOCALE:Set("error.stream_error_driver_3.description", [[Kann keinen freien/gültigen Treiber finden]])

-- Default: Something is wrong with your sound hardware or your sound drivers.
-- Current: Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.
LOCALE:Set("error.stream_error_driver_3.helptext", [[Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.]])


-- ================================================================================
-- Sub Category:  error.stream_error_dropbox_no_path_130000
-- ================================================================================

-- Default: [Dropbox] Url has no path
-- Current: [Dropbox] URL hat keinen Pfad
LOCALE:Set("error.stream_error_dropbox_no_path_130000.description", [[[Dropbox] URL hat keinen Pfad]])

-- Default: Make sure your Dropbox has a valid path in it.
-- Current: Stelle sicher, dass deine Dropbox einen gültigen Pfad enthält.
LOCALE:Set("error.stream_error_dropbox_no_path_130000.helptext", [[Stelle sicher, dass deine Dropbox einen gültigen Pfad enthält.]])


-- ================================================================================
-- Sub Category:  error.stream_error_dx_39
-- ================================================================================

-- Default: A sufficient DirectX version is not installed
-- Current: Eine ausreichende DirectX-Version ist nicht installiert
LOCALE:Set("error.stream_error_dx_39.description", [[Eine ausreichende DirectX-Version ist nicht installiert]])

-- Default:
--  | Something is wrong with your sound hardware or your sound drivers.
--  | DirectX seems to be outdated or not installed.
-- Current:
--  | Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.
--  | DirectX scheint veraltet oder nicht installiert zu sein.
LOCALE:Set("error.stream_error_dx_39.helptext", [[Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.
DirectX scheint veraltet oder nicht installiert zu sein.]])


-- ================================================================================
-- Sub Category:  error.stream_error_empty_31
-- ================================================================================

-- Default: The MOD music has no sequence data
-- Current: Die MOD-Musik hat keine Sequenzdaten
LOCALE:Set("error.stream_error_empty_31.description", [[Die MOD-Musik hat keine Sequenzdaten]])

-- Default:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
-- Current:
--  | Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.
--  | 
--  | Diese Dinge funktionieren NICHT:
--  | 	- HTML-Seiten, die Töne abspielen.
--  | 	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
--  | 	- Alles, das eine Art Anmeldung für den Zugriff erfordert.
--  | 	- Alles, das nicht öffentlich ist.
--  | 	- Soundskripte oder Soundeigenschaften.
--  | 	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)
--  | 
--  | Diese Dinge funktionieren:
--  | 	- URLs zu Sounddateien (aka. DIREKTER Download).
--  | 	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
--  | 	- URLs in diesen Wiedergabelistendateien.
--  | 	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
--  | 	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
--  | 	- Formate, die unten aufgelistet sind.
--  | 
--  | Unterstützte Formate:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.
LOCALE:Set("error.stream_error_empty_31.helptext", [[Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.

Diese Dinge funktionieren NICHT:
	- HTML-Seiten, die Töne abspielen.
	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
	- Alles, das eine Art Anmeldung für den Zugriff erfordert.
	- Alles, das nicht öffentlich ist.
	- Soundskripte oder Soundeigenschaften.
	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)

Diese Dinge funktionieren:
	- URLs zu Sounddateien (aka. DIREKTER Download).
	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
	- URLs in diesen Wiedergabelistendateien.
	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
	- Formate, die unten aufgelistet sind.

Unterstützte Formate:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.]])


-- ================================================================================
-- Sub Category:  error.stream_error_ended_45
-- ================================================================================

-- Default: The channel/file has ended
-- Current: Der Kanal/die Datei hat geendet
LOCALE:Set("error.stream_error_ended_45.description", [[Der Kanal/die Datei hat geendet]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_ended_45.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_fileform_41
-- ================================================================================

-- Default: Unsupported file format
-- Current: Nicht unterstütztes Dateiformat
LOCALE:Set("error.stream_error_fileform_41.description", [[Nicht unterstütztes Dateiformat]])

-- Default:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
-- Current:
--  | Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.
--  | 
--  | Diese Dinge funktionieren NICHT:
--  | 	- HTML-Seiten, die Töne abspielen.
--  | 	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
--  | 	- Alles, das eine Art Anmeldung für den Zugriff erfordert.
--  | 	- Alles, das nicht öffentlich ist.
--  | 	- Soundskripte oder Soundeigenschaften.
--  | 	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)
--  | 
--  | Diese Dinge funktionieren:
--  | 	- URLs zu Sounddateien (aka. DIREKTER Download).
--  | 	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
--  | 	- URLs in diesen Wiedergabelistendateien.
--  | 	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
--  | 	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
--  | 	- Formate, die unten aufgelistet sind.
--  | 
--  | Unterstützte Formate:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.
LOCALE:Set("error.stream_error_fileform_41.helptext", [[Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.

Diese Dinge funktionieren NICHT:
	- HTML-Seiten, die Töne abspielen.
	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
	- Alles, das eine Art Anmeldung für den Zugriff erfordert.
	- Alles, das nicht öffentlich ist.
	- Soundskripte oder Soundeigenschaften.
	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)

Diese Dinge funktionieren:
	- URLs zu Sounddateien (aka. DIREKTER Download).
	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
	- URLs in diesen Wiedergabelistendateien.
	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
	- Formate, die unten aufgelistet sind.

Unterstützte Formate:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.]])


-- ================================================================================
-- Sub Category:  error.stream_error_fileopen_2
-- ================================================================================

-- Default: Can't open the file
-- Current: Kann die Datei nicht öffnen
LOCALE:Set("error.stream_error_fileopen_2.description", [[Kann die Datei nicht öffnen]])

-- Default:
--  | There was no file or content found at the given path.
--  | 
--  | If you try to play an online file:
--  | 	- Do not forget the protocol prefix such as 'http://'.
--  | 	- Make sure the file exist at the given URL. It should be downloadable.
--  | 	- Make sure the format is supported and the file is not broken. (See below.)
--  | 
--  | If you try to play a local file:
--  | 	- Make sure the file exist at the given path.
--  | 	- Make sure the file is readable for Garry's Mod.
--  | 	- The path must be relative your "<path_to_game>/garrysmod/sound/" folder. (See below.)
--  | 	- The file must be in "<path_to_game>/garrysmod/sound/" folder. (See below.)
--  | 	- You can play mounted stuff in "<path_to_game>/garrysmod/sound/".
--  | 	- You can not play sound scripts or sound properties.
--  | 	- Make sure the format is supported and the file is not broken. (See below.)
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping in game as the API does not support these.
--  | 
--  | How local or mounted file paths work:
--  | 	- If you have a file located "<path_to_game>/garrysmod/sound/mymusic/song.mp3" you access it with these urls:
--  | 	* file://mymusic/song.mp3
--  | 	* mymusic/song.mp3"
--  | 
--  | 	- For files in "<path_to_game>/garrysmod/sound/filename.mp3" you get them like this:
--  | 	* file://filename.mp3
--  | 	* filename.mp3
--  | 
--  | 	- Files outside the game folder are forbidden to be accessed by the game.
--  | 	- Do not enter absolute paths.
--  | 	- Only people who also have the same file localed there, will be able to hear the music too.
--  | 	- Create folders if they are missing.
-- Current:
--  | Es wurde keine Datei oder kein Inhalt unter dem angegebenen Pfad gefunden.
--  | 
--  | Wenn du versuchst, eine Online-Datei abzuspielen:
--  | 	- Vergiss nicht das Protokoll-Präfix wie "http://".
--  | 	- Stelle sicher, dass die Datei unter der angegebenen URL vorhanden ist. Sie sollte herunterladbar sein.
--  | 	- Stelle sicher, dass das Format unterstützt und die Datei nicht beschädigt ist. (Siehe unten.)
--  | 
--  | Wenn du versuchst, eine lokale Datei abzuspielen:
--  | 	- Stelle sicher, dass die Datei unter dem angegebenen Pfad vorhanden ist.
--  | 	- Stelle sicher, dass die Datei von Garry's Mod gelesen werden kann.
--  | 	- Der Pfad muss relativ zu deinem "<path_to_game>/garrysmod/sound/" Ordner sein. (Siehe unten.)
--  | 	- Die Datei muss sich im "<path_to_game>/garrysmod/sound/" Ordner befinden. (Siehe unten.)
--  | 	- Du kannst bereitgestellte Dateien in "<path_to_game>/garrysmod/sound/" abspielen.
--  | 	- Du kannst Soundskripte oder Soundeigenschaften nicht abspielen.
--  | 	- Stelle sicher, dass das Format unterstützt und die Datei nicht beschädigt ist. (Siehe unten.)
--  | 
--  | Unterstützte Formate:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV-Dateien dürfen im Spiel nicht selbstschleifend sein, da die API diese nicht unterstützt.
--  | 
--  | Wie lokale oder bereitgestellte Dateipfade funktionieren:
--  | 	- Wenn du eine Datei unter "<path_to_game>/garrysmod/sound/mymusic/song.mp3" hast, greifst du auf diese zu mit:
--  | 	* file://mymusic/song.mp3
--  | 	* mymusic/song.mp3"
--  | 
--  | 	- Für Dateien unter "<path_to_game>/garrysmod/sound/filename.mp3" erhältst du sie wie folgt:
--  | 	* file://filename.mp3
--  | 	* filename.mp3
--  | 
--  | 	- Dateien außerhalb des Spielordners ist es dem Spiel verboten, darauf zuzugreifen.
--  | 	- Gib keine absoluten Pfade ein.
--  | 	- Nur Personen, die auch dieselbe Datei dort haben, können die Musik hören.
--  | 	- Erstelle Ordner, wenn sie fehlen.
LOCALE:Set("error.stream_error_fileopen_2.helptext", [[Es wurde keine Datei oder kein Inhalt unter dem angegebenen Pfad gefunden.

Wenn du versuchst, eine Online-Datei abzuspielen:
	- Vergiss nicht das Protokoll-Präfix wie "http://".
	- Stelle sicher, dass die Datei unter der angegebenen URL vorhanden ist. Sie sollte herunterladbar sein.
	- Stelle sicher, dass das Format unterstützt und die Datei nicht beschädigt ist. (Siehe unten.)

Wenn du versuchst, eine lokale Datei abzuspielen:
	- Stelle sicher, dass die Datei unter dem angegebenen Pfad vorhanden ist.
	- Stelle sicher, dass die Datei von Garry's Mod gelesen werden kann.
	- Der Pfad muss relativ zu deinem "<path_to_game>/garrysmod/sound/" Ordner sein. (Siehe unten.)
	- Die Datei muss sich im "<path_to_game>/garrysmod/sound/" Ordner befinden. (Siehe unten.)
	- Du kannst bereitgestellte Dateien in "<path_to_game>/garrysmod/sound/" abspielen.
	- Du kannst Soundskripte oder Soundeigenschaften nicht abspielen.
	- Stelle sicher, dass das Format unterstützt und die Datei nicht beschädigt ist. (Siehe unten.)

Unterstützte Formate:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV-Dateien dürfen im Spiel nicht selbstschleifend sein, da die API diese nicht unterstützt.

Wie lokale oder bereitgestellte Dateipfade funktionieren:
	- Wenn du eine Datei unter "<path_to_game>/garrysmod/sound/mymusic/song.mp3" hast, greifst du auf diese zu mit:
	* file://mymusic/song.mp3
	* mymusic/song.mp3"

	- Für Dateien unter "<path_to_game>/garrysmod/sound/filename.mp3" erhältst du sie wie folgt:
	* file://filename.mp3
	* filename.mp3

	- Dateien außerhalb des Spielordners ist es dem Spiel verboten, darauf zuzugreifen.
	- Gib keine absoluten Pfade ein.
	- Nur Personen, die auch dieselbe Datei dort haben, können die Musik hören.
	- Erstelle Ordner, wenn sie fehlen.]])


-- ================================================================================
-- Sub Category:  error.stream_error_format_6
-- ================================================================================

-- Default: Unsupported sample format
-- Current: Nicht unterstütztes Beispielformat
LOCALE:Set("error.stream_error_format_6.description", [[Nicht unterstütztes Beispielformat]])

-- Default:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
-- Current:
--  | Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.
--  | 
--  | Diese Dinge funktionieren NICHT:
--  | 	- HTML-Seiten, die Töne abspielen.
--  | 	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
--  | 	- Alles, das eine Art Anmeldung für den Zugriff erfordert.
--  | 	- Alles, das nicht öffentlich ist.
--  | 	- Soundskripte oder Soundeigenschaften.
--  | 	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)
--  | 
--  | Diese Dinge funktionieren:
--  | 	- URLs zu Sounddateien (aka. DIREKTER Download).
--  | 	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
--  | 	- URLs in diesen Wiedergabelistendateien.
--  | 	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
--  | 	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
--  | 	- Formate, die unten aufgelistet sind.
--  | 
--  | Unterstützte Formate:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.
LOCALE:Set("error.stream_error_format_6.helptext", [[Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.

Diese Dinge funktionieren NICHT:
	- HTML-Seiten, die Töne abspielen.
	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
	- Alles, das eine Art Anmeldung für den Zugriff erfordert.
	- Alles, das nicht öffentlich ist.
	- Soundskripte oder Soundeigenschaften.
	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)

Diese Dinge funktionieren:
	- URLs zu Sounddateien (aka. DIREKTER Download).
	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
	- URLs in diesen Wiedergabelistendateien.
	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
	- Formate, die unten aufgelistet sind.

Unterstützte Formate:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.]])


-- ================================================================================
-- Sub Category:  error.stream_error_freq_25
-- ================================================================================

-- Default: Illegal sample rate
-- Current: Ungültige Abtastrate
LOCALE:Set("error.stream_error_freq_25.description", [[Ungültige Abtastrate]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_freq_25.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_handle_5
-- ================================================================================

-- Default: Invalid handle
-- Current: Ungültiges Handle
LOCALE:Set("error.stream_error_handle_5.description", [[Ungültiges Handle]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_handle_5.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_illparam_20
-- ================================================================================

-- Default: An illegal parameter was specified
-- Current: Ein ungültiger Parameter wurde angegeben
LOCALE:Set("error.stream_error_illparam_20.description", [[Ein ungültiger Parameter wurde angegeben]])

-- Default:
--  | Something went wrong with parsing the URL.
--  | It could have been blocked by the server to prevent abuse.
--  | 
--  | Please talk to an admin about this before you report this issue.
-- Current:
--  | Beim Analysieren der URL ist etwas schief gelaufen.
--  | Möglicherweise wurde es vom Server blockiert, um Missbrauch zu verhindern.
--  | 
--  | Bitte sprich du mit einem Admin darüber, bevor du das Problem meldest.
LOCALE:Set("error.stream_error_illparam_20.helptext", [[Beim Analysieren der URL ist etwas schief gelaufen.
Möglicherweise wurde es vom Server blockiert, um Missbrauch zu verhindern.

Bitte sprich du mit einem Admin darüber, bevor du das Problem meldest.]])


-- ================================================================================
-- Sub Category:  error.stream_error_illtype_19
-- ================================================================================

-- Default: An illegal type was specified
-- Current: Ein ungültiger Typ wurde angegeben
LOCALE:Set("error.stream_error_illtype_19.description", [[Ein ungültiger Typ wurde angegeben]])

-- Default:
--  | Something went wrong with parsing the URL.
--  | It could have been blocked by the server to prevent abuse.
--  | 
--  | Please talk to an admin about this before you report this issue.
-- Current:
--  | Beim Analysieren der URL ist etwas schief gelaufen.
--  | Möglicherweise wurde es vom Server blockiert, um Missbrauch zu verhindern.
--  | 
--  | Bitte sprich du mit einem Admin darüber, bevor du das Problem meldest.
LOCALE:Set("error.stream_error_illtype_19.helptext", [[Beim Analysieren der URL ist etwas schief gelaufen.
Möglicherweise wurde es vom Server blockiert, um Missbrauch zu verhindern.

Bitte sprich du mit einem Admin darüber, bevor du das Problem meldest.]])


-- ================================================================================
-- Sub Category:  error.stream_error_init_8
-- ================================================================================

-- Default: BASS_Init has not been successfully called
-- Current: BASS_Init wurde nicht erfolgreich aufgerufen
LOCALE:Set("error.stream_error_init_8.description", [[BASS_Init wurde nicht erfolgreich aufgerufen]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_init_8.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_mem_1
-- ================================================================================

-- Default: Memory Error
-- Current: Speicherfehler
LOCALE:Set("error.stream_error_mem_1.description", [[Speicherfehler]])

-- Default:
--  | A memory error is always bad.
--  | You proably ran out of it.
-- Current:
--  | Ein Speicherfehler ist immer schlecht.
--  | Du hast ihn wahrscheinlich überschritten.
LOCALE:Set("error.stream_error_mem_1.helptext", [[Ein Speicherfehler ist immer schlecht.
Du hast ihn wahrscheinlich überschritten.]])


-- ================================================================================
-- Sub Category:  error.stream_error_missing_gm_bass3_1020
-- ================================================================================

-- Default: GM_BASS3 is missing
-- Current: GM_BASS3 fehlt
LOCALE:Set("error.stream_error_missing_gm_bass3_1020.description", [[GM_BASS3 fehlt]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_missing_gm_bass3_1020.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_no3d_21
-- ================================================================================

-- Default: No 3D support
-- Current: Keine 3D-Unterstützung
LOCALE:Set("error.stream_error_no3d_21.description", [[Keine 3D-Unterstützung]])

-- Default:
--  | Something is wrong with your sound hardware or your sound drivers.
--  | It does not support 3D world sound.
-- Current:
--  | Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.
--  | Sie unterstützen keinen 3D-Weltsound.
LOCALE:Set("error.stream_error_no3d_21.helptext", [[Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.
Sie unterstützen keinen 3D-Weltsound.]])


-- ================================================================================
-- Sub Category:  error.stream_error_nochan_18
-- ================================================================================

-- Default: Can't get a free channel
-- Current: Kann keinen freien Kanal bekommen
LOCALE:Set("error.stream_error_nochan_18.description", [[Kann keinen freien Kanal bekommen]])

-- Default:
--  | A memory error is always bad.
--  | You proably ran out of it.
-- Current:
--  | Ein Speicherfehler ist immer schlecht.
--  | Du hast ihn wahrscheinlich überschritten.
LOCALE:Set("error.stream_error_nochan_18.helptext", [[Ein Speicherfehler ist immer schlecht.
Du hast ihn wahrscheinlich überschritten.]])


-- ================================================================================
-- Sub Category:  error.stream_error_noeax_22
-- ================================================================================

-- Default: No EAX support
-- Current: Keine EAX-Unterstützung
LOCALE:Set("error.stream_error_noeax_22.description", [[Keine EAX-Unterstützung]])

-- Default:
--  | Something is wrong with your sound hardware or your sound drivers.
--  | It does not support EAX-effects.
-- Current:
--  | Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.
--  | Sie unterstützen keine EAX-Effekte.
LOCALE:Set("error.stream_error_noeax_22.helptext", [[Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.
Sie unterstützen keine EAX-Effekte.]])


-- ================================================================================
-- Sub Category:  error.stream_error_nofx_34
-- ================================================================================

-- Default: Effects are not available
-- Current: Effekte sind nicht verfügbar
LOCALE:Set("error.stream_error_nofx_34.description", [[Effekte sind nicht verfügbar]])

-- Default:
--  | Something is wrong with your sound hardware or your sound drivers.
--  | It does not support EAX-effects.
-- Current:
--  | Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.
--  | Sie unterstützen keine EAX-Effekte.
LOCALE:Set("error.stream_error_nofx_34.helptext", [[Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.
Sie unterstützen keine EAX-Effekte.]])


-- ================================================================================
-- Sub Category:  error.stream_error_nohw_29
-- ================================================================================

-- Default: No hardware voices available
-- Current: Keine Hardware-Stimmen verfügbar
LOCALE:Set("error.stream_error_nohw_29.description", [[Keine Hardware-Stimmen verfügbar]])

-- Default: Something is wrong with your sound hardware. Out of memory?
-- Current: Etwas stimmt nicht mit deiner Soundhardware. Kein Speicher mehr?
LOCALE:Set("error.stream_error_nohw_29.helptext", [[Etwas stimmt nicht mit deiner Soundhardware. Kein Speicher mehr?]])


-- ================================================================================
-- Sub Category:  error.stream_error_nonet_32
-- ================================================================================

-- Default: No internet connection could be opened
-- Current: Es konnte keine Internetverbindung geöffnet werden
LOCALE:Set("error.stream_error_nonet_32.description", [[Es konnte keine Internetverbindung geöffnet werden]])

-- Default:
--  | You internet connection is not working.
--  | Please check your network devices and your firewall.
-- Current:
--  | Deine Internetverbindung funktioniert nicht.
--  | Bitte überprüfe deine Netzwerkgeräte und deine Firewall.
LOCALE:Set("error.stream_error_nonet_32.helptext", [[Deine Internetverbindung funktioniert nicht.
Bitte überprüfe deine Netzwerkgeräte und deine Firewall.]])


-- ================================================================================
-- Sub Category:  error.stream_error_noplay_24
-- ================================================================================

-- Default: Not playing
-- Current: Wird nicht abgespielt
LOCALE:Set("error.stream_error_noplay_24.description", [[Wird nicht abgespielt]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_noplay_24.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_notaudio_17
-- ================================================================================

-- Default: File does not contain audio
-- Current: Datei enthält keinen Audio
LOCALE:Set("error.stream_error_notaudio_17.description", [[Datei enthält keinen Audio]])

-- Default:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
-- Current:
--  | Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.
--  | 
--  | Diese Dinge funktionieren NICHT:
--  | 	- HTML-Seiten, die Töne abspielen.
--  | 	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
--  | 	- Alles, das eine Art Anmeldung für den Zugriff erfordert.
--  | 	- Alles, das nicht öffentlich ist.
--  | 	- Soundskripte oder Soundeigenschaften.
--  | 	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)
--  | 
--  | Diese Dinge funktionieren:
--  | 	- URLs zu Sounddateien (aka. DIREKTER Download).
--  | 	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
--  | 	- URLs in diesen Wiedergabelistendateien.
--  | 	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
--  | 	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
--  | 	- Formate, die unten aufgelistet sind.
--  | 
--  | Unterstützte Formate:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.
LOCALE:Set("error.stream_error_notaudio_17.helptext", [[Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.

Diese Dinge funktionieren NICHT:
	- HTML-Seiten, die Töne abspielen.
	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
	- Alles, das eine Art Anmeldung für den Zugriff erfordert.
	- Alles, das nicht öffentlich ist.
	- Soundskripte oder Soundeigenschaften.
	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)

Diese Dinge funktionieren:
	- URLs zu Sounddateien (aka. DIREKTER Download).
	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
	- URLs in diesen Wiedergabelistendateien.
	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
	- Formate, die unten aufgelistet sind.

Unterstützte Formate:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.]])


-- ================================================================================
-- Sub Category:  error.stream_error_notavail_37
-- ================================================================================

-- Default: Requested data/action is not available
-- Current: Angeforderte Daten/Aktion nicht verfügbar
LOCALE:Set("error.stream_error_notavail_37.description", [[Angeforderte Daten/Aktion nicht verfügbar]])

-- Default:
--  | Your sound driver/interface was lost.
--  | 
--  | To fix it you need to do this:
--  | - Plugin your speakers or head phones.
--  | - Enable the sound device.
--  | - Restart the game. Do not just disconnect!
--  | - Restart your PC, if it still not works.
-- Current:
--  | Dein Audiotreiber/Audio-Interface wurde unterbrochen.
--  | 
--  | Um dies zu beheben, musst du folgendes tun:
--  | - Schließe deine Lautsprecher oder Kopfhörer an.
--  | - Aktiviere das Audiogerät.
--  | - Starte das Spiel neu. Trenne es nicht einfach!
--  | - Starte deinen PC neu, wenn es immer noch nicht funktioniert.
LOCALE:Set("error.stream_error_notavail_37.helptext", [[Dein Audiotreiber/Audio-Interface wurde unterbrochen.

Um dies zu beheben, musst du folgendes tun:
- Schließe deine Lautsprecher oder Kopfhörer an.
- Aktiviere das Audiogerät.
- Starte das Spiel neu. Trenne es nicht einfach!
- Starte deinen PC neu, wenn es immer noch nicht funktioniert.]])


-- ================================================================================
-- Sub Category:  error.stream_error_notfile_27
-- ================================================================================

-- Default: The stream is not a file stream
-- Current: Der Stream ist kein Datei-Stream
LOCALE:Set("error.stream_error_notfile_27.description", [[Der Stream ist kein Datei-Stream]])

-- Default:
--  | There was no file or content found at the given path.
--  | 
--  | If you try to play an online file:
--  | 	- Do not forget the protocol prefix such as 'http://'.
--  | 	- Make sure the file exist at the given URL. It should be downloadable.
--  | 	- Make sure the format is supported and the file is not broken. (See below.)
--  | 
--  | If you try to play a local file:
--  | 	- Make sure the file exist at the given path.
--  | 	- Make sure the file is readable for Garry's Mod.
--  | 	- The path must be relative your "<path_to_game>/garrysmod/sound/" folder. (See below.)
--  | 	- The file must be in "<path_to_game>/garrysmod/sound/" folder. (See below.)
--  | 	- You can play mounted stuff in "<path_to_game>/garrysmod/sound/".
--  | 	- You can not play sound scripts or sound properties.
--  | 	- Make sure the format is supported and the file is not broken. (See below.)
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping in game as the API does not support these.
--  | 
--  | How local or mounted file paths work:
--  | 	- If you have a file located "<path_to_game>/garrysmod/sound/mymusic/song.mp3" you access it with these urls:
--  | 	* file://mymusic/song.mp3
--  | 	* mymusic/song.mp3"
--  | 
--  | 	- For files in "<path_to_game>/garrysmod/sound/filename.mp3" you get them like this:
--  | 	* file://filename.mp3
--  | 	* filename.mp3
--  | 
--  | 	- Files outside the game folder are forbidden to be accessed by the game.
--  | 	- Do not enter absolute paths.
--  | 	- Only people who also have the same file localed there, will be able to hear the music too.
--  | 	- Create folders if they are missing.
-- Current:
--  | Es wurde keine Datei oder kein Inhalt unter dem angegebenen Pfad gefunden.
--  | 
--  | Wenn du versuchst, eine Online-Datei abzuspielen:
--  | 	- Vergiss nicht das Protokoll-Präfix wie "http://".
--  | 	- Stelle sicher, dass die Datei unter der angegebenen URL vorhanden ist. Sie sollte herunterladbar sein.
--  | 	- Stelle sicher, dass das Format unterstützt und die Datei nicht beschädigt ist. (Siehe unten.)
--  | 
--  | Wenn du versuchst, eine lokale Datei abzuspielen:
--  | 	- Stelle sicher, dass die Datei unter dem angegebenen Pfad vorhanden ist.
--  | 	- Stelle sicher, dass die Datei von Garry's Mod gelesen werden kann.
--  | 	- Der Pfad muss relativ zu deinem "<path_to_game>/garrysmod/sound/" Ordner sein. (Siehe unten.)
--  | 	- Die Datei muss sich im "<path_to_game>/garrysmod/sound/" Ordner befinden. (Siehe unten.)
--  | 	- Du kannst bereitgestellte Dateien in "<path_to_game>/garrysmod/sound/" abspielen.
--  | 	- Du kannst Soundskripte oder Soundeigenschaften nicht abspielen.
--  | 	- Stelle sicher, dass das Format unterstützt und die Datei nicht beschädigt ist. (Siehe unten.)
--  | 
--  | Unterstützte Formate:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV-Dateien dürfen im Spiel nicht selbstschleifend sein, da die API diese nicht unterstützt.
--  | 
--  | Wie lokale oder bereitgestellte Dateipfade funktionieren:
--  | 	- Wenn du eine Datei unter "<path_to_game>/garrysmod/sound/mymusic/song.mp3" hast, greifst du auf diese zu mit:
--  | 	* file://mymusic/song.mp3
--  | 	* mymusic/song.mp3"
--  | 
--  | 	- Für Dateien unter "<path_to_game>/garrysmod/sound/filename.mp3" erhältst du sie wie folgt:
--  | 	* file://filename.mp3
--  | 	* filename.mp3
--  | 
--  | 	- Dateien außerhalb des Spielordners ist es dem Spiel verboten, darauf zuzugreifen.
--  | 	- Gib keine absoluten Pfade ein.
--  | 	- Nur Personen, die auch dieselbe Datei dort haben, können die Musik hören.
--  | 	- Erstelle Ordner, wenn sie fehlen.
LOCALE:Set("error.stream_error_notfile_27.helptext", [[Es wurde keine Datei oder kein Inhalt unter dem angegebenen Pfad gefunden.

Wenn du versuchst, eine Online-Datei abzuspielen:
	- Vergiss nicht das Protokoll-Präfix wie "http://".
	- Stelle sicher, dass die Datei unter der angegebenen URL vorhanden ist. Sie sollte herunterladbar sein.
	- Stelle sicher, dass das Format unterstützt und die Datei nicht beschädigt ist. (Siehe unten.)

Wenn du versuchst, eine lokale Datei abzuspielen:
	- Stelle sicher, dass die Datei unter dem angegebenen Pfad vorhanden ist.
	- Stelle sicher, dass die Datei von Garry's Mod gelesen werden kann.
	- Der Pfad muss relativ zu deinem "<path_to_game>/garrysmod/sound/" Ordner sein. (Siehe unten.)
	- Die Datei muss sich im "<path_to_game>/garrysmod/sound/" Ordner befinden. (Siehe unten.)
	- Du kannst bereitgestellte Dateien in "<path_to_game>/garrysmod/sound/" abspielen.
	- Du kannst Soundskripte oder Soundeigenschaften nicht abspielen.
	- Stelle sicher, dass das Format unterstützt und die Datei nicht beschädigt ist. (Siehe unten.)

Unterstützte Formate:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV-Dateien dürfen im Spiel nicht selbstschleifend sein, da die API diese nicht unterstützt.

Wie lokale oder bereitgestellte Dateipfade funktionieren:
	- Wenn du eine Datei unter "<path_to_game>/garrysmod/sound/mymusic/song.mp3" hast, greifst du auf diese zu mit:
	* file://mymusic/song.mp3
	* mymusic/song.mp3"

	- Für Dateien unter "<path_to_game>/garrysmod/sound/filename.mp3" erhältst du sie wie folgt:
	* file://filename.mp3
	* filename.mp3

	- Dateien außerhalb des Spielordners ist es dem Spiel verboten, darauf zuzugreifen.
	- Gib keine absoluten Pfade ein.
	- Nur Personen, die auch dieselbe Datei dort haben, können die Musik hören.
	- Erstelle Ordner, wenn sie fehlen.]])


-- ================================================================================
-- Sub Category:  error.stream_error_position_7
-- ================================================================================

-- Default: Invalid position
-- Current: Ungültige Position
LOCALE:Set("error.stream_error_position_7.description", [[Ungültige Position]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_position_7.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_protocol_48
-- ================================================================================

-- Default: Unsupported protocol
-- Current: Nicht unterstütztes Protokoll
LOCALE:Set("error.stream_error_protocol_48.description", [[Nicht unterstütztes Protokoll]])

-- Default:
--  | Something went wrong with parsing the URL.
--  | It could have been blocked by the server to prevent abuse.
--  | 
--  | Please talk to an admin about this before you report this issue.
-- Current:
--  | Beim Analysieren der URL ist etwas schief gelaufen.
--  | Möglicherweise wurde es vom Server blockiert, um Missbrauch zu verhindern.
--  | 
--  | Bitte sprich du mit einem Admin darüber, bevor du das Problem meldest.
LOCALE:Set("error.stream_error_protocol_48.helptext", [[Beim Analysieren der URL ist etwas schief gelaufen.
Möglicherweise wurde es vom Server blockiert, um Missbrauch zu verhindern.

Bitte sprich du mit einem Admin darüber, bevor du das Problem meldest.]])


-- ================================================================================
-- Sub Category:  error.stream_error_reinit_11
-- ================================================================================

-- Default: Device needs to be reinitialized
-- Current: Gerät muss neu initialisiert werden
LOCALE:Set("error.stream_error_reinit_11.description", [[Gerät muss neu initialisiert werden]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_reinit_11.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_shoutcast_no_id_120000
-- ================================================================================

-- Default: [SHOUTcast] Invalid stream ID
-- Current: [SHOUTcast] Ungültige Stream-ID
LOCALE:Set("error.stream_error_shoutcast_no_id_120000.description", [[[SHOUTcast] Ungültige Stream-ID]])

-- Default:
--  | An invalid stream ID was given.
--  | 
--  | Notes:
--  | 	- Make sure you enter a URL of an existing SHOUTcast stream.
--  | 	- The URL should look like this shoutcast://123456
--  | 	- Only numbers are supported.
-- Current:
--  | Es wurde eine ungültige Stream-ID angegeben.
--  | 
--  | Hinweise:
--  | 	- Stelle sicher, dass du eine URL eines vorhandenen SHOUTcast-Streams eingibst.
--  | 	- Die URL sollte wie folgt aussehen: shoutcast://123456
--  | 	- Nur Zahlen werden unterstützt.
LOCALE:Set("error.stream_error_shoutcast_no_id_120000.helptext", [[Es wurde eine ungültige Stream-ID angegeben.

Hinweise:
	- Stelle sicher, dass du eine URL eines vorhandenen SHOUTcast-Streams eingibst.
	- Die URL sollte wie folgt aussehen: shoutcast://123456
	- Nur Zahlen werden unterstützt.]])


-- ================================================================================
-- Sub Category:  error.stream_error_speaker_42
-- ================================================================================

-- Default: Unavailable speaker
-- Current: Nicht verfügbarer Lautsprecher
LOCALE:Set("error.stream_error_speaker_42.description", [[Nicht verfügbarer Lautsprecher]])

-- Default:
--  | Something is wrong with your sound hardware or your sound drivers.
--  | Do you even have speakers?
-- Current:
--  | Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.
--  | Hast du überhaupt Lautsprecher?
LOCALE:Set("error.stream_error_speaker_42.helptext", [[Etwas stimmt nicht mit deiner Soundhardware oder deinen Audiotreibern.
Hast du überhaupt Lautsprecher?]])


-- ================================================================================
-- Sub Category:  error.stream_error_ssl_10
-- ================================================================================

-- Default: SSL/HTTPS support isn't available
-- Current: SSL/HTTPS-Unterstützung ist nicht verfügbar
LOCALE:Set("error.stream_error_ssl_10.description", [[SSL/HTTPS-Unterstützung ist nicht verfügbar]])

-- Default:
--  | The SSL handshake for HTTPS did failed to validate the connection.
--  | Please check the URL being legit and your operating system to be up to date.
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!
LOCALE:Set("error.stream_error_ssl_10.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Gib die URL und den Fehlercode in deinem Bericht an!]])


-- ================================================================================
-- Sub Category:  error.stream_error_start_9
-- ================================================================================

-- Default: BASS_Start has not been successfully called
-- Current: BASS_Start wurde nicht erfolgreich aufgerufen
LOCALE:Set("error.stream_error_start_9.description", [[BASS_Start wurde nicht erfolgreich aufgerufen]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Füge die URL und den Fehlercode in den Bericht ein!
LOCALE:Set("error.stream_error_start_9.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Füge die URL und den Fehlercode in den Bericht ein!]])


-- ================================================================================
-- Sub Category:  error.stream_error_timeout_40
-- ================================================================================

-- Default: Connection timedout
-- Current: Verbindungstimeout
LOCALE:Set("error.stream_error_timeout_40.description", [[Verbindungstimeout]])

-- Default:
--  | The connection seems being slow. Just try again in a few minutes.
--  | If it does not work, the server you are trying to stream from is available.
-- Current:
--  | Die Verbindung scheint langsam zu sein. Versuch es in ein paar Minuten noch einmal.
--  | Wenn es nicht funktioniert, ist der Server, von dem du streamen möchtest, möglicherweise nicht erreichbar.
LOCALE:Set("error.stream_error_timeout_40.helptext", [[Die Verbindung scheint langsam zu sein. Versuch es in ein paar Minuten noch einmal.
Wenn es nicht funktioniert, ist der Server, von dem du streamen möchtest, möglicherweise nicht erreichbar.]])


-- ================================================================================
-- Sub Category:  error.stream_error_unknown_-1
-- ================================================================================

-- Default: Unknown Error
-- Current: Unbekannter Fehler
LOCALE:Set("error.stream_error_unknown_-1.description", [[Unbekannter Fehler]])

-- Default:
--  | The exact cause of this error is unknown.
--  | 
--  | This error is usually caused by:
--  | 	- Invalid file pathes or URLs without the protocol prefix such as 'http://'.
--  | 	- Attempting to play self-looping *.WAV files.
-- Current:
--  | Die genaue Ursache dieses Fehlers ist unbekannt.
--  | 
--  | Dieser Fehler wird normalerweise verursacht durch:
--  | 	- Ungültige Dateipfade oder URLs ohne Protokollpräfix wie 'http://'.
--  | 	- Versuch, selbstschleifende *.WAV-Dateien abzuspielen.
LOCALE:Set("error.stream_error_unknown_-1.helptext", [[Die genaue Ursache dieses Fehlers ist unbekannt.

Dieser Fehler wird normalerweise verursacht durch:
	- Ungültige Dateipfade oder URLs ohne Protokollpräfix wie 'http://'.
	- Versuch, selbstschleifende *.WAV-Dateien abzuspielen.]])


-- ================================================================================
-- Sub Category:  error.stream_error_unstreamable_47
-- ================================================================================

-- Default: Unstreamable file
-- Current: Nicht streambare Datei
LOCALE:Set("error.stream_error_unstreamable_47.description", [[Nicht streambare Datei]])

-- Default:
--  | You are trying to play something that the streaming API of GMod (and so the radio) does not support.
--  | 
--  | These things will NOT work:
--  | 	- HTML pages that play sound.
--  | 	- Flash players/games/applications that are playing sound.
--  | 	- Anything that requires any kind of login to access.
--  | 	- Anything that is not public.
--  | 	- Sound scripts or sound properties.
--  | 	- Broken files or unsupported formats. (See below.)
--  | 
--  | These things will work:
--  | 	- URLs to sound files (aka. DIRECT download).
--  | 	- URLs to playlist files of radio stations. If they do not offer them, you will be not able to play them.
--  | 	- URLs inside these playlists files.
--  | 	- Local sound files inside your "<path_to_game>/garrysmod/sound/" folder. Examble: "music/hl1_song10.mp3"
--  | 	- You may have to install addional codices to your OS.
--  | 	- Formats that are listed below.
--  | 
--  | Supported formats:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV files must be not self-looping ingame as the API does not support these.
-- Current:
--  | Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.
--  | 
--  | Diese Dinge funktionieren NICHT:
--  | 	- HTML-Seiten, die Töne abspielen.
--  | 	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
--  | 	- Alles, was eine Art Anmeldung für den Zugriff erfordert.
--  | 	- Alles, was nicht öffentlich ist.
--  | 	- Soundskripte oder Soundeigenschaften.
--  | 	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)
--  | 
--  | Diese Dinge funktionieren:
--  | 	- URLs zu Sounddateien (aka. DIREKTER Download).
--  | 	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
--  | 	- URLs in diesen Wiedergabelistendateien.
--  | 	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
--  | 	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
--  | 	- Formate, die unten aufgelistet sind.
--  | 
--  | Unterstützte Formate:
--  | 	MP3, OGG, AAC, WAV, WMA, FLAC
--  | 	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.
LOCALE:Set("error.stream_error_unstreamable_47.helptext", [[Du versuchst, etwas zu spielen, das die Streaming-API von GMod (und somit das Radio) nicht unterstützt.

Diese Dinge funktionieren NICHT:
	- HTML-Seiten, die Töne abspielen.
	- Flash-Player/Spiele/Anwendungen, die Töne abspielen.
	- Alles, was eine Art Anmeldung für den Zugriff erfordert.
	- Alles, was nicht öffentlich ist.
	- Soundskripte oder Soundeigenschaften.
	- Beschädigte Dateien oder nicht unterstützte Formate. (Siehe unten.)

Diese Dinge funktionieren:
	- URLs zu Sounddateien (aka. DIREKTER Download).
	- URLs zu Wiedergabelistendateien von Radiostationen. Wenn diese nicht angeboten werden, kannst du nicht abspielen.
	- URLs in diesen Wiedergabelistendateien.
	- Lokale Sounddateien in deinem "<path_to_game>/garrysmod/sound/" Ordner. Beispiel: "music/hl1_song10.mp3"
	- Möglicherweise musst du zusätzliche Codecs auf deinem Betriebssystem installieren.
	- Formate, die unten aufgelistet sind.

Unterstützte Formate:
	MP3, OGG, AAC, WAV, WMA, FLAC
	*.WAV-Dateien dürfen nicht im Spiel selbstschleifend sein, da die API diese nicht unterstützt.]])


-- ================================================================================
-- Sub Category:  error.stream_error_url_blocked_1001
-- ================================================================================

-- Default: This URL is blocked on this server
-- Current: Diese URL ist auf diesem Server blockiert
LOCALE:Set("error.stream_error_url_blocked_1001.description", [[Diese URL ist auf diesem Server blockiert]])

-- Default:
--  | The server does not allow playback of this URL to prevent abuse. It has been blocked by external code.
--  | 
--  | CAUTION: Please don't ask to have this block disabled or removed. It is there for your own security. Ask your admin for details.
-- Current:
--  | Der Server erlaubt keine Wiedergabe dieser URL, um Missbrauch zu verhindern. Sie wurde von externem Code blockiert.
--  | 
--  | VORSICHT: Bitte frage nicht, ob dieser Block deaktiviert oder entfernt werden kann. Er ist zu deiner eigenen Sicherheit da. Frag deinen Admin nach Details.
LOCALE:Set("error.stream_error_url_blocked_1001.helptext", [[Der Server erlaubt keine Wiedergabe dieser URL, um Missbrauch zu verhindern. Sie wurde von externem Code blockiert.

VORSICHT: Bitte frage nicht, ob dieser Block deaktiviert oder entfernt werden kann. Er ist zu deiner eigenen Sicherheit da. Frag deinen Admin nach Details.]])


-- ================================================================================
-- Sub Category:  error.stream_error_url_not_whitelisted_1000
-- ================================================================================

-- Default: This URL is not whitelisted on this server
-- Current: Diese URL ist auf diesem Server nicht auf der Whitelist
LOCALE:Set("error.stream_error_url_not_whitelisted_1000.description", [[Diese URL ist auf diesem Server nicht auf der Whitelist]])

-- Default:
--  | The server does not allow playback of this URL to prevent abuse.
--  | You can ask an admin to whitelist this URL by adding it to the playlists.
--  | 
--  | CAUTION: Please don't ask to have the whitelist disabled or removed. It is there for your own security. Ask your admin for details.
-- Current:
--  | Der Server erlaubt keine Wiedergabe dieser URL, um Missbrauch zu verhindern.
--  | Du kannst einen Admin bitten, diese URL auf die Whitelist zu setzen, indem er sie zu den Wiedergabelisten hinzufügt.
--  | 
--  | VORSICHT: Bitte frage nicht, ob die Whitelist deaktiviert oder entfernt werden kann. Sie ist zu deiner eigenen Sicherheit da. Frag deinen Admin nach Details.
LOCALE:Set("error.stream_error_url_not_whitelisted_1000.helptext", [[Der Server erlaubt keine Wiedergabe dieser URL, um Missbrauch zu verhindern.
Du kannst einen Admin bitten, diese URL auf die Whitelist zu setzen, indem er sie zu den Wiedergabelisten hinzufügt.

VORSICHT: Bitte frage nicht, ob die Whitelist deaktiviert oder entfernt werden kann. Sie ist zu deiner eigenen Sicherheit da. Frag deinen Admin nach Details.]])


-- ================================================================================
-- Sub Category:  error.stream_error_version_43
-- ================================================================================

-- Default: Invalid BASS version (used by add-ons)
-- Current: Ungültige BASS-Version (wird von Add-ons verwendet)
LOCALE:Set("error.stream_error_version_43.description", [[Ungültige BASS-Version (wird von Add-ons verwendet)]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Füge die URL und den Fehlercode in den Bericht ein!
LOCALE:Set("error.stream_error_version_43.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Füge die URL und den Fehlercode in den Bericht ein!]])


-- ================================================================================
-- Sub Category:  error.stream_error_wire_advout_disabled_1010
-- ================================================================================

-- Default: Advanced outputs are disabled
-- Current: Erweiterte Ausgänge sind deaktiviert
LOCALE:Set("error.stream_error_wire_advout_disabled_1010.description", [[Erweiterte Ausgänge sind deaktiviert]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Füge die URL und den Fehlercode in den Bericht ein!
LOCALE:Set("error.stream_error_wire_advout_disabled_1010.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Füge die URL und den Fehlercode in den Bericht ein!]])


-- ================================================================================
-- Sub Category:  error.stream_error_youtube_unsupported_110000
-- ================================================================================

-- Default: [YouTube] YouTube is not supported
-- Current: [YouTube] YouTube wird nicht unterstützt
LOCALE:Set("error.stream_error_youtube_unsupported_110000.description", [[[YouTube] YouTube wird nicht unterstützt]])

-- Default:
--  | YouTube is not supported. Please use other media sources.
--  | You can use a Youtube to MP3 converter, but it is not recommended.
--  | 
--  | Notes:
--  | 	- Reliable YouTube support can't be added. It is impossible.
--  | 	- Please, don't ask me about it.
--  | 	- View the online help link for more information.
-- Current:
--  | YouTube wird nicht unterstützt. Bitte verwende andere Medienquellen.
--  | Du kannst einen Youtube-zu-MP3-Konverter benutzen, aber das wird nicht empfohlen.
--  | 
--  | Hinweise:
--  | 	- Zuverlässige YouTube-Unterstützung kann nicht hinzugefügt werden. Es ist unmöglich.
--  | 	- Bitte frag mich nicht danach.
--  | 	- Sieh dir den Online-Hilfe-Link für weitere Informationen an.
LOCALE:Set("error.stream_error_youtube_unsupported_110000.helptext", [[YouTube wird nicht unterstützt. Bitte verwende andere Medienquellen.
Du kannst einen Youtube-zu-MP3-Konverter benutzen, aber das wird nicht empfohlen.

Hinweise:
	- Zuverlässige YouTube-Unterstützung kann nicht hinzugefügt werden. Es ist unmöglich.
	- Bitte frag mich nicht danach.
	- Sieh dir den Online-Hilfe-Link für weitere Informationen an.]])


-- ================================================================================
-- Sub Category:  error.stream_ok_0
-- ================================================================================

-- Current: OK
LOCALE:Set("error.stream_ok_0.description", [[OK]])

-- Default: Everything should be fine. You should not see this.
-- Current: Alles sollte in Ordnung sein. Du solltest das nicht sehen.
LOCALE:Set("error.stream_ok_0.helptext", [[Alles sollte in Ordnung sein. Du solltest das nicht sehen.]])


-- ================================================================================
-- Sub Category:  error.stream_sound_stopped_1200
-- ================================================================================

-- Default: The sound has been stopped
-- Current: Der Ton wurde gestoppt
LOCALE:Set("error.stream_sound_stopped_1200.description", [[Der Ton wurde gestoppt]])

-- Default:
--  | There is no help text for error {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Please report this! Include the URL and the error code in the report!
-- Current:
--  | Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).
--  | 
--  | Bitte melde das! Füge die URL und den Fehlercode in den Bericht ein!
LOCALE:Set("error.stream_sound_stopped_1200.helptext", [[Es gibt keinen Hilfetext für den Fehler {{ERROR_CODE}} ({{ERROR_NAME}}).

Bitte melde das! Füge die URL und den Fehlercode in den Bericht ein!]])

-- This file returns true, so we know it has been loaded properly
return true

