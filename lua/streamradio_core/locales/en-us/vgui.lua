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
-- Main Category: vgui
-- ################################################################################

-- Current: by %s
LOCALE:Set("vgui.clientconvar.locale.by_author", [[by %s]])


-- ================================================================================
-- Sub Category:  vgui.error_help_panel
-- ================================================================================

-- Current: Copy to clipboard
LOCALE:Set("vgui.error_help_panel.clipboard", [[Copy to clipboard]])

-- Current: Close
LOCALE:Set("vgui.error_help_panel.close", [[Close]])

-- Current: Stream Radio Error Information | %s
LOCALE:Set("vgui.error_help_panel.header", [[Stream Radio Error Information | %s]])

-- Current: Error %i (%s): %s
LOCALE:Set("vgui.error_help_panel.header_error_info", [[Error %i (%s): %s]])

-- Current: View online help
LOCALE:Set("vgui.error_help_panel.view_online", [[View online help]])


-- ================================================================================
-- Sub Category:  vgui.menu
-- ================================================================================

-- Current: Admin Settings
LOCALE:Set("vgui.menu.admin_button.admin_settings", [[Admin Settings]])

-- Current: Show Playlist Editor
LOCALE:Set("vgui.menu.admin_button.playlist_editor", [[Show Playlist Editor]])

-- Current: General Settings
LOCALE:Set("vgui.menu.button.general_settings", [[General Settings]])

-- Current: Stream Radio Tool
LOCALE:Set("vgui.menu.button.tool", [[Stream Radio Tool]])

-- Current: Show VRMod Panel
LOCALE:Set("vgui.menu.button.vrmod", [[Show VRMod Panel]])

-- Current: Download VRMod (Workshop)
LOCALE:Set("vgui.menu.button.vrmod_download", [[Download VRMod (Workshop)]])

-- Current: Made by Grocel
LOCALE:Set("vgui.menu.credits.madeby", [[Made by Grocel]])

-- Current: This can not be undone!
LOCALE:Set("vgui.menu.danger_button.generic.dialog_box.hint", [[This can not be undone!]])

-- Current: No
LOCALE:Set("vgui.menu.danger_button.generic.dialog_box.no", [[No]])

-- Current: Yes
LOCALE:Set("vgui.menu.danger_button.generic.dialog_box.yes", [[Yes]])

-- Current: Show CFC HTTP Whitelist Info (Workshop)
LOCALE:Set("vgui.menu.link_button.cfc_whitelist_info", [[Show CFC HTTP Whitelist Info (Workshop)]])

-- Current: Show FAQ (Workshop)
LOCALE:Set("vgui.menu.link_button.faq", [[Show FAQ (Workshop)]])

-- Current:
--  | %s
--  | 
--  | URL: %s
--  | 
--  | Right click to copy the URL to clipboard.
LOCALE:Set("vgui.menu.link_button.generic.tooltip", [[%s

URL: %s

Right click to copy the URL to clipboard.]])

-- Current: Show VR FAQ (Workshop)
LOCALE:Set("vgui.menu.link_button.vrmod_faq", [[Show VR FAQ (Workshop)]])

-- Current: Show Whitelist Info (Workshop)
LOCALE:Set("vgui.menu.link_button.whitelist_info", [[Show Whitelist Info (Workshop)]])

-- Current:
--  | VRMod is not loaded.
--  |   - Install VRMod to enable VR support.
--  |   - VR Headset required!
--  |   - VR is optional, this addon works without VR.
LOCALE:Set("vgui.menu.vrmod.error", [[VRMod is not loaded.
  - Install VRMod to enable VR support.
  - VR Headset required!
  - VR is optional, this addon works without VR.]])

-- Current:
--  | Powered by VRMod!
--  |   - VRMod is made by Catse
--  |   - VR Headset required!
--  |   - VR is optional, this addon works without VR.
LOCALE:Set("vgui.menu.vrmod.info", [[Powered by VRMod!
  - VRMod is made by Catse
  - VR Headset required!
  - VR is optional, this addon works without VR.]])


-- ================================================================================
-- Sub Category:  vgui.playlist_editor
-- ================================================================================

-- Current: Add
LOCALE:Set("vgui.playlist_editor.add.label", [[Add]])

-- Current: Apply
LOCALE:Set("vgui.playlist_editor.apply.label", [[Apply]])

-- Current: Apply current order to playlist
LOCALE:Set("vgui.playlist_editor.apply_order.tooltip", [[Apply current order to playlist]])

-- Current: Cancel
LOCALE:Set("vgui.playlist_editor.dialog_box.cancel", [[Cancel]])

-- Current: Create folder
LOCALE:Set("vgui.playlist_editor.dialog_box.create_dir.create", [[Create folder]])

-- Current:
--  | Create a new folder
--  | - All invalid characters are fitered out
--  | - Case insensitive, converted to lowercase
LOCALE:Set("vgui.playlist_editor.dialog_box.create_dir.dialog", [[Create a new folder
- All invalid characters are fitered out
- Case insensitive, converted to lowercase]])

-- Current: New folder
LOCALE:Set("vgui.playlist_editor.dialog_box.create_dir.title", [[New folder]])

-- Current: Create new file
LOCALE:Set("vgui.playlist_editor.dialog_box.create_file.create", [[Create new file]])

-- Current:
--  | Create a new playlist
--  | - All invalid characters are fitered out
--  | - Case insensitive, converted to lowercase
--  | - Valid formats are: %s
LOCALE:Set("vgui.playlist_editor.dialog_box.create_file.dialog", [[Create a new playlist
- All invalid characters are fitered out
- Case insensitive, converted to lowercase
- Valid formats are: %s]])

-- Current: New playlist..
LOCALE:Set("vgui.playlist_editor.dialog_box.create_file.title", [[New playlist..]])

-- Current: Are you sure to delete this file/folder?
LOCALE:Set("vgui.playlist_editor.dialog_box.delete.dialog", [[Are you sure to delete this file/folder?]])

-- Current: Delete file!
LOCALE:Set("vgui.playlist_editor.dialog_box.delete.title", [[Delete file!]])

-- Current: No
LOCALE:Set("vgui.playlist_editor.dialog_box.no", [[No]])

-- Current: OK
LOCALE:Set("vgui.playlist_editor.dialog_box.ok", [[OK]])

-- Current:
--  | Save a file
--  | - All invalid characters are fitered out
--  | - Case insensitive, converted to lowercase
--  | - Valid formats are: %s
LOCALE:Set("vgui.playlist_editor.dialog_box.save_to.dialog", [[Save a file
- All invalid characters are fitered out
- Case insensitive, converted to lowercase
- Valid formats are: %s]])

-- Current: Save to file
LOCALE:Set("vgui.playlist_editor.dialog_box.save_to.save", [[Save to file]])

-- Current: Save to..
LOCALE:Set("vgui.playlist_editor.dialog_box.save_to.title", [[Save to..]])

-- Current: Are you sure to discard the changes?
LOCALE:Set("vgui.playlist_editor.dialog_box.unsaved_playlist.dialog", [[Are you sure to discard the changes?]])

-- Current: Unsaved playlist!
LOCALE:Set("vgui.playlist_editor.dialog_box.unsaved_playlist.title", [[Unsaved playlist!]])

-- Current: Yes
LOCALE:Set("vgui.playlist_editor.dialog_box.yes", [[Yes]])

-- Current: Name
LOCALE:Set("vgui.playlist_editor.files.column.name.label", [[Name]])

-- Current: Type
LOCALE:Set("vgui.playlist_editor.files.column.type.label", [[Type]])

-- Current: Delete
LOCALE:Set("vgui.playlist_editor.files_menu.delete.label", [[Delete]])

-- Current: New folder
LOCALE:Set("vgui.playlist_editor.files_menu.new_folder.label", [[New folder]])

-- Current: New
LOCALE:Set("vgui.playlist_editor.files_menu.new_list.label", [[New]])

-- Current: Open
LOCALE:Set("vgui.playlist_editor.files_menu.open.label", [[Open]])

-- Current: Refresh
LOCALE:Set("vgui.playlist_editor.files_menu.refresh.label", [[Refresh]])

-- Current: Stream Radio Playlist Editor
LOCALE:Set("vgui.playlist_editor.header", [[Stream Radio Playlist Editor]])

-- Current: List mode
LOCALE:Set("vgui.playlist_editor.list_tab.label", [[List mode]])

-- Current: Edit the playlist in a list view
LOCALE:Set("vgui.playlist_editor.list_tab.tooltip", [[Edit the playlist in a list view]])

-- Current: Move item down
LOCALE:Set("vgui.playlist_editor.move_down.tooltip", [[Move item down]])

-- Current: Move item up
LOCALE:Set("vgui.playlist_editor.move_up.tooltip", [[Move item up]])

-- Current: Name:
LOCALE:Set("vgui.playlist_editor.name_edit.label", [[Name:]])

-- Current: Enter a name for this Entry
LOCALE:Set("vgui.playlist_editor.name_edit.placeholder", [[Enter a name for this Entry]])

-- Current: New folder
LOCALE:Set("vgui.playlist_editor.new_folder.tooltip", [[New folder]])

-- Current: New list
LOCALE:Set("vgui.playlist_editor.new_list.tooltip", [[New list]])

-- Current: Name
LOCALE:Set("vgui.playlist_editor.playlist.column.name.label", [[Name]])

-- Current: No.
LOCALE:Set("vgui.playlist_editor.playlist.column.number.label", [[No.]])

-- Current: URL
LOCALE:Set("vgui.playlist_editor.playlist.column.url.label", [[URL]])

-- Current: Refresh and reload
LOCALE:Set("vgui.playlist_editor.reload.tooltip", [[Refresh and reload]])

-- Current: Remove
LOCALE:Set("vgui.playlist_editor.remove.label", [[Remove]])

-- Current: Save list
LOCALE:Set("vgui.playlist_editor.save.tooltip", [[Save list]])

-- Current: Save to..
LOCALE:Set("vgui.playlist_editor.save_to.tooltip", [[Save to..]])

-- Current:
--  | About this text based playlist editor:
--  | 
--  | - Changes are automatically synchronized between this view and the list view.
--  | - Enter the name and the URL for each entry you want to add.
--  | - The syntax is independent from the playlist format.
--  | - Missing lines are skipped or are filled with placeholders.
--  | - Whitespaces are trimed on each line.
LOCALE:Set("vgui.playlist_editor.text_tab.help.general", [[About this text based playlist editor:

- Changes are automatically synchronized between this view and the list view.
- Enter the name and the URL for each entry you want to add.
- The syntax is independent from the playlist format.
- Missing lines are skipped or are filled with placeholders.
- Whitespaces are trimed on each line.]])

-- Current:
--  | Example:
--  | 
--  | 1.FM - ABSOLUTE TOP 40 RADIO [newline]
--  | http://185.33.21.112:80/top40_128 [newline]
--  | 1.FM - Alternative Rock X Hits [newline]
--  | http://185.33.21.112:80/x_128 [newline]
--  | ...
LOCALE:Set("vgui.playlist_editor.text_tab.help.syntax", [[Example:

1.FM - ABSOLUTE TOP 40 RADIO [newline]
http://185.33.21.112:80/top40_128 [newline]
1.FM - Alternative Rock X Hits [newline]
http://185.33.21.112:80/x_128 [newline]
...]])

-- Current: Text mode
LOCALE:Set("vgui.playlist_editor.text_tab.label", [[Text mode]])

-- Current: Edit the playlist in a text field (for advanced users)
LOCALE:Set("vgui.playlist_editor.text_tab.tooltip", [[Edit the playlist in a text field (for advanced users)]])

-- Current: URL:
LOCALE:Set("vgui.playlist_editor.url_edit.label", [[URL:]])


-- ================================================================================
-- Sub Category:  vgui.url_text_entry
-- ================================================================================

-- Current: Enter file path or online URL
LOCALE:Set("vgui.url_text_entry.placeholder", [[Enter file path or online URL]])

-- Current: The URL is empty!
LOCALE:Set("vgui.url_text_entry.tooltip.state_empty", [[The URL is empty!]])

-- Current: The URL is not valid!
LOCALE:Set("vgui.url_text_entry.tooltip.state_error", [[The URL is not valid!]])

-- Current: The URL is valid!
LOCALE:Set("vgui.url_text_entry.tooltip.state_found", [[The URL is valid!]])

-- Current: Checking URL...
LOCALE:Set("vgui.url_text_entry.tooltip.state_idle", [[Checking URL...]])

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
LOCALE:Set("vgui.url_text_entry.tooltip.url_hint", [[You can enter this as a Stream URL:

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

-- This file returns true, so we know it has been loaded properly
return true

