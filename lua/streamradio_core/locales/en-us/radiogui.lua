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
-- Main Category: radiogui
-- ################################################################################


-- ================================================================================
-- Sub Category:  radiogui.gui_browser
-- ================================================================================

-- Current: Go to parent directory
LOCALE:Set("radiogui.gui_browser.back.tooltip", [[Go to parent directory]])

-- Current: Path:
LOCALE:Set("radiogui.gui_browser.path.label", [[Path:]])

-- Current: Refresh view
LOCALE:Set("radiogui.gui_browser.refresh.tooltip", [[Refresh view]])

-- Current: Play URL from Toolgun
LOCALE:Set("radiogui.gui_browser.toolgun.tooltip", [[Play URL from Toolgun]])

-- Current: Play URL from Wiremod
LOCALE:Set("radiogui.gui_browser.wiremod.tooltip", [[Play URL from Wiremod]])


-- ================================================================================
-- Sub Category:  radiogui.gui_errorbox
-- ================================================================================

-- Current: Close
LOCALE:Set("radiogui.gui_errorbox.close.tooltip", [[Close]])

-- Current:
--  | Error: %i (%s)
--  | 
--  | Could not open playlist:
--  | %s
--  | 
--  | Make sure the file is valid and not Empty.
--  | 
--  | Click the '?' button for more details.
LOCALE:Set("radiogui.gui_errorbox.error.playlist.with_url", [[Error: %i (%s)

Could not open playlist:
%s

Make sure the file is valid and not Empty.

Click the '?' button for more details.]])

-- Current:
--  | Error: %i (%s)
--  | 
--  | Could not play stream:
--  | %s
--  | 
--  | %s
--  | 
--  | Click the '?' button for more details.
LOCALE:Set("radiogui.gui_errorbox.error.stream.with_url", [[Error: %i (%s)

Could not play stream:
%s

%s

Click the '?' button for more details.]])

-- Current:
--  | Error: %i (%s)
--  | 
--  | Could not play stream!
--  | 
--  | %s
--  | 
--  | Click the '?' button for more details.
LOCALE:Set("radiogui.gui_errorbox.error.stream.without_url", [[Error: %i (%s)

Could not play stream!

%s

Click the '?' button for more details.]])

-- Current: Help
LOCALE:Set("radiogui.gui_errorbox.help.tooltip", [[Help]])

-- Current: Retry
LOCALE:Set("radiogui.gui_errorbox.retry.tooltip", [[Retry]])

-- Current: Add to quick whitelist (admin only)
LOCALE:Set("radiogui.gui_errorbox.whitelist.tooltip", [[Add to quick whitelist (admin only)]])

-- Current: Back
LOCALE:Set("radiogui.gui_player.back.label", [[Back]])


-- ================================================================================
-- Sub Category:  radiogui.gui_player_controls
-- ================================================================================

-- Current: Pause playback
LOCALE:Set("radiogui.gui_player_controls.pause.tooltip", [[Pause playback]])

-- Current: Start playback
LOCALE:Set("radiogui.gui_player_controls.play.tooltip", [[Start playback]])

-- Current: No loop
LOCALE:Set("radiogui.gui_player_controls.playback_loop.mode.none", [[No loop]])

-- Current: Playlist loop
LOCALE:Set("radiogui.gui_player_controls.playback_loop.mode.playlist", [[Playlist loop]])

-- Current: Song loop
LOCALE:Set("radiogui.gui_player_controls.playback_loop.mode.song", [[Song loop]])

-- Current:
--  | Change loop mode
--  | (Currently: %s)
LOCALE:Set("radiogui.gui_player_controls.playback_loop.tooltip", [[Change loop mode
(Currently: %s)]])

-- Current: Buffering...
LOCALE:Set("radiogui.gui_player_controls.playbar.buffering", [[Buffering...]])

-- Current: Checking URL...
LOCALE:Set("radiogui.gui_player_controls.playbar.checkingurl", [[Checking URL...]])

-- Current: Downloading...
LOCALE:Set("radiogui.gui_player_controls.playbar.downloading", [[Downloading...]])

-- Current: Error!
LOCALE:Set("radiogui.gui_player_controls.playbar.error", [[Error!]])

-- Current: Sound stopped!
LOCALE:Set("radiogui.gui_player_controls.playbar.killed", [[Sound stopped!]])

-- Current: Loading...
LOCALE:Set("radiogui.gui_player_controls.playbar.loading", [[Loading...]])

-- Current: Muted
LOCALE:Set("radiogui.gui_player_controls.playbar.muted", [[Muted]])

-- Current: Stopped
LOCALE:Set("radiogui.gui_player_controls.playbar.stopped", [[Stopped]])

-- Current: Stop playback
LOCALE:Set("radiogui.gui_player_controls.stop.tooltip", [[Stop playback]])

-- Current: Next track
LOCALE:Set("radiogui.gui_player_controls.track_next.tooltip", [[Next track]])

-- Current: Previous track
LOCALE:Set("radiogui.gui_player_controls.track_previous.tooltip", [[Previous track]])

-- Current: Decrease volume
LOCALE:Set("radiogui.gui_player_controls.volume_decrease.tooltip", [[Decrease volume]])

-- Current: Increase volume
LOCALE:Set("radiogui.gui_player_controls.volume_increase.tooltip", [[Increase volume]])

-- This file returns true, so we know it has been loaded properly
return true

