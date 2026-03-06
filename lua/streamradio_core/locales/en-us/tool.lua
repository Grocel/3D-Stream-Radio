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
-- Main Category: tool
-- ################################################################################


-- ================================================================================
-- Sub Category:  tool.streamradio
-- ================================================================================

-- Current: Enable 3D Sound
LOCALE:Set("tool.streamradio.3dsound", [[Enable 3D Sound]])

-- Current: Cleaned up all Stream Radios
LOCALE:Set("tool.streamradio.action.cleaned", [[Cleaned up all Stream Radios]])

-- Current: Stream Radio
LOCALE:Set("tool.streamradio.action.cleanup", [[Stream Radio]])

-- Current: You've hit the Stream Radio limit!
LOCALE:Set("tool.streamradio.action.limit", [[You've hit the Stream Radio limit!]])

-- Current: Undone Stream Radio
LOCALE:Set("tool.streamradio.action.undone", [[Undone Stream Radio]])

-- Current: Spawns a Stream Radio
LOCALE:Set("tool.streamradio.desc", [[Spawns a Stream Radio]])

-- Current: Freeze
LOCALE:Set("tool.streamradio.freeze", [[Freeze]])

-- Current: Create a stream radio
LOCALE:Set("tool.streamradio.left", [[Create a stream radio]])

-- Current: Model:
LOCALE:Set("tool.streamradio.model", [[Model:]])

-- Current: Some models (usually speakers) don't have a display. Use this tool or Wiremod to control those.
LOCALE:Set("tool.streamradio.modelinfo", [[Some models (usually speakers) don't have a display. Use this tool or Wiremod to control those.]])

-- Current:
--  | Some models (usually speakers) don't have a display.
--  | Use this tool or Wiremod to control those.
LOCALE:Set("tool.streamradio.modelinfo.desc", [[Some models (usually speakers) don't have a display.
Use this tool or Wiremod to control those.]])

-- Current: Some selectable models might not be available on the server. Those will be replaced by a default model.
LOCALE:Set("tool.streamradio.modelinfo_mp", [[Some selectable models might not be available on the server. Those will be replaced by a default model.]])

-- Current:
--  | Some selectable models might not be available on the server.
--  | Those will be replaced by a default model.
LOCALE:Set("tool.streamradio.modelinfo_mp.desc", [[Some selectable models might not be available on the server.
Those will be replaced by a default model.]])

-- Current: Mute Radio
LOCALE:Set("tool.streamradio.mute", [[Mute Radio]])

-- Current: NOTE: These are entity options too. So they only affect the radio they are applied on. The global settings for your client are at 'General Settings'.
LOCALE:Set("tool.streamradio.mute_volume_info", [[NOTE: These are entity options too. So they only affect the radio they are applied on. The global settings for your client are at 'General Settings'.]])

-- Current: NOTE: These are entity options too. So they only affect the radio they are applied on. The global settings for your client are at 'General Settings'.
LOCALE:Set("tool.streamradio.mute_volume_info.desc", [[NOTE: These are entity options too. So they only affect the radio they are applied on. The global settings for your client are at 'General Settings'.]])

-- Current: Radio Spawner
LOCALE:Set("tool.streamradio.name", [[Radio Spawner]])

-- Current: Disable advanced wire outputs
LOCALE:Set("tool.streamradio.noadvwire", [[Disable advanced wire outputs]])

-- Current:
--  | Disables the advanced wire outputs.
--  | It is always disabled if Wiremod or GM_BASS3 is not installed on the Server.
LOCALE:Set("tool.streamradio.noadvwire.desc", [[Disables the advanced wire outputs.
It is always disabled if Wiremod or GM_BASS3 is not installed on the Server.]])

-- Current: Nocollide
LOCALE:Set("tool.streamradio.nocollide", [[Nocollide]])

-- Current: Disable display
LOCALE:Set("tool.streamradio.nodisplay", [[Disable display]])

-- Current: Disable control
LOCALE:Set("tool.streamradio.noinput", [[Disable control]])

-- Current:
--  | Disable the control of the display.
--  | Wiremod controlling will still work.
LOCALE:Set("tool.streamradio.noinput.desc", [[Disable the control of the display.
Wiremod controlling will still work.]])

-- Current: Disable spectrum visualization
LOCALE:Set("tool.streamradio.nospectrum", [[Disable spectrum visualization]])

-- Current: Disable rendering of the spectrum visualization on the display.
LOCALE:Set("tool.streamradio.nospectrum.desc", [[Disable rendering of the spectrum visualization on the display.]])

-- Current: Start playback
LOCALE:Set("tool.streamradio.play", [[Start playback]])

-- Current:
--  | If set, the radio will try to play a given URL on spawn or apply.
--  | The URL can be set by this Tools or via Wiremod.
LOCALE:Set("tool.streamradio.play.desc", [[If set, the radio will try to play a given URL on spawn or apply.
The URL can be set by this Tools or via Wiremod.]])

-- Current: Loop Playback:
LOCALE:Set("tool.streamradio.playbackloopmode", [[Loop Playback:]])

-- Current: Set what happens after a song ends.
LOCALE:Set("tool.streamradio.playbackloopmode.desc", [[Set what happens after a song ends.]])

-- Current: No loop
LOCALE:Set("tool.streamradio.playbackloopmode.option.none", [[No loop]])

-- Current: Loop playlist
LOCALE:Set("tool.streamradio.playbackloopmode.option.playlist", [[Loop playlist]])

-- Current: Loop song
LOCALE:Set("tool.streamradio.playbackloopmode.option.song", [[Loop song]])

-- Current: Radius:
LOCALE:Set("tool.streamradio.radius", [[Radius:]])

-- Current: The radius in units the radio sound volume will drop down to 0% of the volume setting.
LOCALE:Set("tool.streamradio.radius.desc", [[The radius in units the radio sound volume will drop down to 0% of the volume setting.]])

-- Current: Copy the model of an entity, but the most models will not have a display
LOCALE:Set("tool.streamradio.reload", [[Copy the model of an entity, but the most models will not have a display]])

-- Current: Copy the settings of a radio
LOCALE:Set("tool.streamradio.right", [[Copy the settings of a radio]])

-- Current: Spawn settings:
LOCALE:Set("tool.streamradio.spawnsettings", [[Spawn settings:]])

-- Current: Stream URL:
LOCALE:Set("tool.streamradio.streamurl", [[Stream URL:]])

-- Current: What can I put in as Stream URL?
LOCALE:Set("tool.streamradio.streamurl_info", [[What can I put in as Stream URL?]])

-- Current:
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
LOCALE:Set("tool.streamradio.streamurl_info.desc", [[You can enter this as a Stream URL:

Offline content:
   - A relative path inside your game's 'sound' folder.
   - The path must lead to a valid sound file.
   - Mounted content is supported and included.
   - Like: music/hl1_song3.mp3
   - NOT: sound/music/hl1_song3.mp3
   - NOT: C:/.../sound/music/hl1_song3.mp3

Online content:
   - An URL to an online file or stream.
   - The URL must lead to valid sound content.
   - No HTML, no Flash, no Videos, no YouTube
   - Like: https://stream.laut.fm/hiphop-forever]])

-- Current:
--  | Whitelist protected server:
--  | Only approved Stream URLs will work on this server!
LOCALE:Set("tool.streamradio.streamurl_whitelist_info", [[Whitelist protected server:
Only approved Stream URLs will work on this server!]])

-- Current: Volume:
LOCALE:Set("tool.streamradio.volume", [[Volume:]])

-- Current: Weld
LOCALE:Set("tool.streamradio.weld", [[Weld]])

-- Current: Weld to world
LOCALE:Set("tool.streamradio.worldweld", [[Weld to world]])


-- ================================================================================
-- Sub Category:  tool.streamradio_gui_color_global
-- ================================================================================

-- Current: Selected color:
LOCALE:Set("tool.streamradio_gui_color_global.color", [[Selected color:]])

-- Current: Change colors of radio GUI skins
LOCALE:Set("tool.streamradio_gui_color_global.desc", [[Change colors of radio GUI skins]])

-- Current: Apply colors of radio GUI skins
LOCALE:Set("tool.streamradio_gui_color_global.left", [[Apply colors of radio GUI skins]])

-- Current: List of changeable colors:
LOCALE:Set("tool.streamradio_gui_color_global.list", [[List of changeable colors:]])

-- Current: Border
LOCALE:Set("tool.streamradio_gui_color_global.list.border_color_border", [[Border]])

-- Current: Color of the surrounding border.
LOCALE:Set("tool.streamradio_gui_color_global.list.border_color_border.desc", [[Color of the surrounding border.]])

-- Current: Button Background
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color", [[Button Background]])

-- Current: Color of all button backgrounds.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color.desc", [[Color of all button backgrounds.]])

-- Current: Button Disabled Background
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_disabled", [[Button Disabled Background]])

-- Current: Color of all disabled button backgrounds.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_disabled.desc", [[Color of all disabled button backgrounds.]])

-- Current: Button Text
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground", [[Button Text]])

-- Current: Color of all button texts.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground.desc", [[Color of all button texts.]])

-- Current: Button Disabled Text
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground_disabled", [[Button Disabled Text]])

-- Current: Color of all disabled button texts.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground_disabled.desc", [[Color of all disabled button texts.]])

-- Current: Button Hover Text
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground_hover", [[Button Hover Text]])

-- Current: Color of all hovered button texts.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_foreground_hover.desc", [[Color of all hovered button texts.]])

-- Current: Button Hover Background
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_hover", [[Button Hover Background]])

-- Current: Color of all hovered button backgrounds.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_hover.desc", [[Color of all hovered button backgrounds.]])

-- Current: Button Icon
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon", [[Button Icon]])

-- Current: Color of all button icons.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon.desc", [[Color of all button icons.]])

-- Current: Button Disabled Icon
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon_disabled", [[Button Disabled Icon]])

-- Current: Color of all disabled button icons.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon_disabled.desc", [[Color of all disabled button icons.]])

-- Current: Button Hover Icon
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon_hover", [[Button Hover Icon]])

-- Current: Color of all hovered button icons.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_icon_hover.desc", [[Color of all hovered button icons.]])

-- Current: Button Shadow
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_shadow", [[Button Shadow]])

-- Current: Color of all button Shadow.
LOCALE:Set("tool.streamradio_gui_color_global.list.button_color_shadow.desc", [[Color of all button Shadow.]])

-- Current:
--  | If checked the color will be applied on left click.
--  | Uncheck this if you don't want to change this color on the GUI.
LOCALE:Set("tool.streamradio_gui_color_global.list.common.active.desc", [[If checked the color will be applied on left click.
Uncheck this if you don't want to change this color on the GUI.]])

-- Current: Cursor
LOCALE:Set("tool.streamradio_gui_color_global.list.cursor_color_cursor", [[Cursor]])

-- Current: Color of the Cursor.
LOCALE:Set("tool.streamradio_gui_color_global.list.cursor_color_cursor.desc", [[Color of the Cursor.]])

-- Current: Error Background
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color", [[Error Background]])

-- Current: Color of the error box background.
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color.desc", [[Color of the error box background.]])

-- Current: Error Text
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color_foreground", [[Error Text]])

-- Current: Color of the error box text.
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color_foreground.desc", [[Color of the error box text.]])

-- Current: Error Shadow
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color_shadow", [[Error Shadow]])

-- Current: Color of the error box shadow.
LOCALE:Set("tool.streamradio_gui_color_global.list.error_color_shadow.desc", [[Color of the error box shadow.]])

-- Current: Header Background
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color", [[Header Background]])

-- Current: Color of the header background.
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color.desc", [[Color of the header background.]])

-- Current: Header Text
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color_foreground", [[Header Text]])

-- Current: Color of the header text.
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color_foreground.desc", [[Color of the header text.]])

-- Current: Header Shadow
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color_shadow", [[Header Shadow]])

-- Current: Color of the header shadow.
LOCALE:Set("tool.streamradio_gui_color_global.list.header_color_shadow.desc", [[Color of the header shadow.]])

-- Current: Background
LOCALE:Set("tool.streamradio_gui_color_global.list.main_color", [[Background]])

-- Current: Color of the main background.
LOCALE:Set("tool.streamradio_gui_color_global.list.main_color.desc", [[Color of the main background.]])

-- Current: Spectrum Background
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color", [[Spectrum Background]])

-- Current: Color of the spectrum box background.
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color.desc", [[Color of the spectrum box background.]])

-- Current: Spectrum Foreground
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_foreground", [[Spectrum Foreground]])

-- Current: Color of the spectrum box foreground.
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_foreground.desc", [[Color of the spectrum box foreground.]])

-- Current: Spectrum Icon
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_icon", [[Spectrum Icon]])

-- Current: Color of the spectrum box icons.
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_icon.desc", [[Color of the spectrum box icons.]])

-- Current: Spectrum Shadow
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_shadow", [[Spectrum Shadow]])

-- Current: Color of the spectrum box shadow.
LOCALE:Set("tool.streamradio_gui_color_global.list.spectrum_color_shadow.desc", [[Color of the spectrum box shadow.]])

-- Current: Radio Colorer (Global)
LOCALE:Set("tool.streamradio_gui_color_global.name", [[Radio Colorer (Global)]])

-- Current: Reset the skin of the radio to default
LOCALE:Set("tool.streamradio_gui_color_global.reload", [[Reset the skin of the radio to default]])

-- Current: Copy the colors from radio GUI skins
LOCALE:Set("tool.streamradio_gui_color_global.right", [[Copy the colors from radio GUI skins]])


-- ================================================================================
-- Sub Category:  tool.streamradio_gui_color_individual
-- ================================================================================

-- Current: Selected color:
LOCALE:Set("tool.streamradio_gui_color_individual.color", [[Selected color:]])

-- Current: Change colors of aimed radio GUI panels
LOCALE:Set("tool.streamradio_gui_color_individual.desc", [[Change colors of aimed radio GUI panels]])

-- Current: Apply colors of radio GUI panels
LOCALE:Set("tool.streamradio_gui_color_individual.left", [[Apply colors of radio GUI panels]])

-- Current: List of changeable colors:
LOCALE:Set("tool.streamradio_gui_color_individual.list", [[List of changeable colors:]])

-- Current: Background
LOCALE:Set("tool.streamradio_gui_color_individual.list.color", [[Background]])

-- Current: Color of the background.
LOCALE:Set("tool.streamradio_gui_color_individual.list.color.desc", [[Color of the background.]])

-- Current: [Button only] Disabled Background
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_disabled", [[[Button only] Disabled Background]])

-- Current: Color of the background when disabled. (Button only)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_disabled.desc", [[Color of the background when disabled. (Button only)]])

-- Current: Foreground/Text
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground", [[Foreground/Text]])

-- Current: Color of the foreground such as texts or spectrum bars.
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground.desc", [[Color of the foreground such as texts or spectrum bars.]])

-- Current: [Button only] Disabled Foreground/Text
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground_disabled", [[[Button only] Disabled Foreground/Text]])

-- Current: Color of the foreground when disabled. (Button only)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground_disabled.desc", [[Color of the foreground when disabled. (Button only)]])

-- Current: [Button only] Hover Foreground/Text
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground_hover", [[[Button only] Hover Foreground/Text]])

-- Current: Color of the foreground when hovered. (Button only)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_foreground_hover.desc", [[Color of the foreground when hovered. (Button only)]])

-- Current: [Button only] Hover Background
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_hover", [[[Button only] Hover Background]])

-- Current: Color of the background when hovered. (Button only)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_hover.desc", [[Color of the background when hovered. (Button only)]])

-- Current: Icon
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon", [[Icon]])

-- Current: Color of the icons.
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon.desc", [[Color of the icons.]])

-- Current: [Button only] Disabled Icon
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon_disabled", [[[Button only] Disabled Icon]])

-- Current: Color of the icon when disabled. (Button only)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon_disabled.desc", [[Color of the icon when disabled. (Button only)]])

-- Current: [Button only] Hover Icon
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon_hover", [[[Button only] Hover Icon]])

-- Current: Color of the icon when hovered. (Button only)
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_icon_hover.desc", [[Color of the icon when hovered. (Button only)]])

-- Current: Shadow
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_shadow", [[Shadow]])

-- Current: Color of the shadow.
LOCALE:Set("tool.streamradio_gui_color_individual.list.color_shadow.desc", [[Color of the shadow.]])

-- Current:
--  | If checked the color will be applied on left click.
--  | Uncheck this if you don't want to change this color on a panel.
LOCALE:Set("tool.streamradio_gui_color_individual.list.common.active.desc", [[If checked the color will be applied on left click.
Uncheck this if you don't want to change this color on a panel.]])

-- Current: Radio Colorer (Individual)
LOCALE:Set("tool.streamradio_gui_color_individual.name", [[Radio Colorer (Individual)]])

-- Current: Copy the colors from radio GUI panels
LOCALE:Set("tool.streamradio_gui_color_individual.right", [[Copy the colors from radio GUI panels]])


-- ================================================================================
-- Sub Category:  tool.streamradio_gui_skin
-- ================================================================================

-- Current: Change, Copy or Save the skin of radios
LOCALE:Set("tool.streamradio_gui_skin.desc", [[Change, Copy or Save the skin of radios]])

-- Current: Delete
LOCALE:Set("tool.streamradio_gui_skin.file.button.delete", [[Delete]])

-- Current: Delete the selected skin file from your hard disk.
LOCALE:Set("tool.streamradio_gui_skin.file.button.delete.desc", [[Delete the selected skin file from your hard disk.]])

-- Current: You need to enter or select something to delete.
LOCALE:Set("tool.streamradio_gui_skin.file.button.delete.error.empty", [[You need to enter or select something to delete.]])

-- Current: The skin file does not exist.
LOCALE:Set("tool.streamradio_gui_skin.file.button.delete.error.notfound", [[The skin file does not exist.]])

-- Current: The skin file is protected and can not be deleted.
LOCALE:Set("tool.streamradio_gui_skin.file.button.delete.error.protected", [[The skin file is protected and can not be deleted.]])

-- Current: Open
LOCALE:Set("tool.streamradio_gui_skin.file.button.open", [[Open]])

-- Current:
--  | Open selected skin file.
--  | You can also double click on the file to open it.
LOCALE:Set("tool.streamradio_gui_skin.file.button.open.desc", [[Open selected skin file.
You can also double click on the file to open it.]])

-- Current: You need to enter or select something to open.
LOCALE:Set("tool.streamradio_gui_skin.file.button.open.error.empty", [[You need to enter or select something to open.]])

-- Current: The skin file does not exist.
LOCALE:Set("tool.streamradio_gui_skin.file.button.open.error.notfound", [[The skin file does not exist.]])

-- Current: Save
LOCALE:Set("tool.streamradio_gui_skin.file.button.save", [[Save]])

-- Current: Save skin to the filename as given above to your hard disk.
LOCALE:Set("tool.streamradio_gui_skin.file.button.save.desc", [[Save skin to the filename as given above to your hard disk.]])

-- Current: The skin file is protected and can not be overwritten.
LOCALE:Set("tool.streamradio_gui_skin.file.button.save.error.protected", [[The skin file is protected and can not be overwritten.]])

-- Current: Delete skin?
LOCALE:Set("tool.streamradio_gui_skin.file.delete", [[Delete skin?]])

-- Current: Do you want to delete this skin file from your hard disk?
LOCALE:Set("tool.streamradio_gui_skin.file.delete.desc", [[Do you want to delete this skin file from your hard disk?]])

-- Current: No, don't delete it.
LOCALE:Set("tool.streamradio_gui_skin.file.delete.no", [[No, don't delete it.]])

-- Current: Yes, delete it.
LOCALE:Set("tool.streamradio_gui_skin.file.delete.yes", [[Yes, delete it.]])

-- Current: Overwrite skin?
LOCALE:Set("tool.streamradio_gui_skin.file.save", [[Overwrite skin?]])

-- Current: Do you want to overwrite this skin file?
LOCALE:Set("tool.streamradio_gui_skin.file.save.desc", [[Do you want to overwrite this skin file?]])

-- Current: No, don't overwrite it.
LOCALE:Set("tool.streamradio_gui_skin.file.save.no", [[No, don't overwrite it.]])

-- Current: Yes, overwrite it.
LOCALE:Set("tool.streamradio_gui_skin.file.save.yes", [[Yes, overwrite it.]])

-- Current:
--  | Enter the name of your skin here.
--  | Press 'Save' to save it to your hard disk.
LOCALE:Set("tool.streamradio_gui_skin.file.text.desc", [[Enter the name of your skin here.
Press 'Save' to save it to your hard disk.]])

-- Current: Apply skin to the radio
LOCALE:Set("tool.streamradio_gui_skin.left", [[Apply skin to the radio]])

-- Current: List of saved skins:
LOCALE:Set("tool.streamradio_gui_skin.list", [[List of saved skins:]])

-- Current: Radio Skin Duplicator
LOCALE:Set("tool.streamradio_gui_skin.name", [[Radio Skin Duplicator]])

-- Current: Reset the skin to default
LOCALE:Set("tool.streamradio_gui_skin.reload", [[Reset the skin to default]])

-- Current: Copy skin from the radio
LOCALE:Set("tool.streamradio_gui_skin.right", [[Copy skin from the radio]])

-- This file returns true, so we know it has been loaded properly
return true

