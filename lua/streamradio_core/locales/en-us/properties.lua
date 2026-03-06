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
-- Main Category: properties
-- ################################################################################


-- ================================================================================
-- Sub Category:  properties.radio_options
-- ================================================================================

-- Current: Admin Options
LOCALE:Set("properties.radio_options.admin.title", [[Admin Options]])

-- Current: Add to quick whitelist
LOCALE:Set("properties.radio_options.admin.whitelist_add.title", [[Add to quick whitelist]])

-- Current: Remove from quick whitelist
LOCALE:Set("properties.radio_options.admin.whitelist_remove.title", [[Remove from quick whitelist]])

-- Current: Copy Stream URL to clipboard
LOCALE:Set("properties.radio_options.clientside.copy_url.title", [[Copy Stream URL to clipboard]])

-- Current: Error
LOCALE:Set("properties.radio_options.clientside.error_info.title", [[Error]])

-- Current:
--  | Error %i (%s): %s
--  | 
--  | Can not play this URL:
--  | %s
--  | 
--  | %s
LOCALE:Set("properties.radio_options.clientside.error_info.tooltip", [[Error %i (%s): %s

Can not play this URL:
%s

%s]])

-- Current: Click for more details.
LOCALE:Set("properties.radio_options.clientside.error_info.tooltip.clickhint", [[Click for more details.]])

-- Current: Reset GUI
LOCALE:Set("properties.radio_options.clientside.reset_gui.title", [[Reset GUI]])

-- Current: Clientside Options
LOCALE:Set("properties.radio_options.clientside.title", [[Clientside Options]])

-- Current: Volume
LOCALE:Set("properties.radio_options.clientside.volume.title", [[Volume]])

-- Current: Fast forward %i seconds
LOCALE:Set("properties.radio_options.generic.playlist.forward", [[Fast forward %i seconds]])

-- Current: Next track
LOCALE:Set("properties.radio_options.generic.playlist.next", [[Next track]])

-- Current: Pause
LOCALE:Set("properties.radio_options.generic.playlist.play", [[Pause]])

-- Current: Previous track
LOCALE:Set("properties.radio_options.generic.playlist.previous", [[Previous track]])

-- Current: Rewind %i seconds
LOCALE:Set("properties.radio_options.generic.playlist.rewind", [[Rewind %i seconds]])

-- Current: Stop
LOCALE:Set("properties.radio_options.generic.playlist.stop", [[Stop]])

-- Current: Decrease volume
LOCALE:Set("properties.radio_options.generic.volume.decrease", [[Decrease volume]])

-- Current: Increase volume
LOCALE:Set("properties.radio_options.generic.volume.increase", [[Increase volume]])

-- Current: Mute
LOCALE:Set("properties.radio_options.generic.volume.mute", [[Mute]])

-- Current: Unmute
LOCALE:Set("properties.radio_options.generic.volume.unmute", [[Unmute]])

-- Current: Entity Options
LOCALE:Set("properties.radio_options.serverside.title", [[Entity Options]])

-- Current: Volume
LOCALE:Set("properties.radio_options.serverside.volume.title", [[Volume]])

-- This file returns true, so we know it has been loaded properly
return true

