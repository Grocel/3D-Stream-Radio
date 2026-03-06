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
-- Main Category: settings
-- ################################################################################

-- Current: Stream Radio
LOCALE:Set("settings.addon_title", [[Stream Radio]])


-- ================================================================================
-- Sub Category:  settings.admin
-- ================================================================================

-- Current: Allow clients to use GM_BASS3 if available
LOCALE:Set("settings.admin.bass3.allow_client.title", [[Allow clients to use GM_BASS3 if available]])

-- Current: Clear server stream cache
LOCALE:Set("settings.admin.bass3.cache_clear.title", [[Clear server stream cache]])

-- Current: Use GM_BASS3 on the server if available
LOCALE:Set("settings.admin.bass3.enable.title", [[Use GM_BASS3 on the server if available]])

-- Current: Maximum count
LOCALE:Set("settings.admin.bass3.max_spectrums.title", [[Maximum count]])

-- Current: Install GM_BASS3 on the server to unlock the options below.
LOCALE:Set("settings.admin.bass3.panel.gm_bass3_install.info", [[Install GM_BASS3 on the server to unlock the options below.]])

-- Current: Maximum count of radios with Advanced Wire Outputs.
LOCALE:Set("settings.admin.bass3.panel.max_spectrums.info", [[Maximum count of radios with Advanced Wire Outputs.]])

-- Current: GM_BASS3 Options
LOCALE:Set("settings.admin.bass3.panel.title", [[GM_BASS3 Options]])

-- Current: Playlists rebuild setting
LOCALE:Set("settings.admin.danger.label", [[Playlists rebuild setting]])

-- Current:
--  | CAUTION: Be careful what you in this section!
--  | Unanticipated loss of CUSTOM playlist files can be caused by mistakes!
LOCALE:Set("settings.admin.danger.playlist_data_loss_warning.info", [[CAUTION: Be careful what you in this section!
Unanticipated loss of CUSTOM playlist files can be caused by mistakes!]])

-- Current: CAUTION: This section affects ALL playlists on your server!
LOCALE:Set("settings.admin.danger.playlist_options_dangerous.info", [[CAUTION: This section affects ALL playlists on your server!]])

-- Current: Only use this if want clean up or reset ALL playlist files.
LOCALE:Set("settings.admin.danger.playlist_options_dangerous_usage.info", [[Only use this if want clean up or reset ALL playlist files.]])

-- Current: You can use this regularly to fix issues with broken playlists.
LOCALE:Set("settings.admin.danger.playlist_options_regularly_usable.info", [[You can use this regularly to fix issues with broken playlists.]])

-- Current:
--  | Reverts stock playlist files to default.
--  | This overwrites the default playlists and their changes globally!
LOCALE:Set("settings.admin.danger.rebuildplaylists.info", [[Reverts stock playlist files to default.
This overwrites the default playlists and their changes globally!]])

-- Current: Rebuild ALL playlists
LOCALE:Set("settings.admin.danger.rebuildplaylists.label", [[Rebuild ALL playlists]])

-- Current:
--  | Do you really want to rebuild stock playlists?
--  | This overwrites the default playlists and their changes globally!
LOCALE:Set("settings.admin.danger.rebuildplaylists.message", [[Do you really want to rebuild stock playlists?
This overwrites the default playlists and their changes globally!]])

-- Current:
--  | Reverts stock playlist files in 'community' to default.
--  | This overwrites default playlists and their changes in 'community'!
LOCALE:Set("settings.admin.danger.rebuildplaylists_community.info", [[Reverts stock playlist files in 'community' to default.
This overwrites default playlists and their changes in 'community'!]])

-- Current: Rebuild community playlists
LOCALE:Set("settings.admin.danger.rebuildplaylists_community.label", [[Rebuild community playlists]])

-- Current:
--  | Do you really want to rebuild stock community playlists?
--  | This overwrites default playlists and their changes in 'community'!
LOCALE:Set("settings.admin.danger.rebuildplaylists_community.message", [[Do you really want to rebuild stock community playlists?
This overwrites default playlists and their changes in 'community'!]])

-- Current:
--  | Rebuild mode for playlists in 'community'.
--  | Effective with server restarts.
LOCALE:Set("settings.admin.danger.rebuildplaylists_community_auto.info", [[Rebuild mode for playlists in 'community'.
Effective with server restarts.]])

-- Current: Rebuild mode
LOCALE:Set("settings.admin.danger.rebuildplaylists_community_auto.label", [[Rebuild mode]])

-- Current: Off
LOCALE:Set("settings.admin.danger.rebuildplaylists_community_auto.option.off", [[Off]])

-- Current: Auto rebuild
LOCALE:Set("settings.admin.danger.rebuildplaylists_community_auto.option.rebuild", [[Auto rebuild]])

-- Current: Auto reset & rebuild (default)
LOCALE:Set("settings.admin.danger.rebuildplaylists_community_auto.option.reset_rebuild", [[Auto reset & rebuild (default)]])

-- Current:
--  | Reverts ALL playlist files to default.
--  | This removes ALL custom playlists and changes globally!
LOCALE:Set("settings.admin.danger.resetplaylists.info", [[Reverts ALL playlist files to default.
This removes ALL custom playlists and changes globally!]])

-- Current: Factory reset ALL playlists
LOCALE:Set("settings.admin.danger.resetplaylists.label", [[Factory reset ALL playlists]])

-- Current:
--  | Do you really want to reset ALL playlists to defaults?
--  | This removes ALL custom playlists and changes globally!
LOCALE:Set("settings.admin.danger.resetplaylists.message", [[Do you really want to reset ALL playlists to defaults?
This removes ALL custom playlists and changes globally!]])

-- Current:
--  | Reverts ALL playlist files in 'community' to default.
--  | This removes ALL custom playlists and changes in 'community'!
LOCALE:Set("settings.admin.danger.resetplaylists_community.info", [[Reverts ALL playlist files in 'community' to default.
This removes ALL custom playlists and changes in 'community'!]])

-- Current: Factory reset community playlists
LOCALE:Set("settings.admin.danger.resetplaylists_community.label", [[Factory reset community playlists]])

-- Current:
--  | Do you really want to reset ALL community playlists to defaults?
--  | This removes ALL custom playlists and changes in 'community'!
LOCALE:Set("settings.admin.danger.resetplaylists_community.message", [[Do you really want to reset ALL community playlists to defaults?
This removes ALL custom playlists and changes in 'community'!]])

-- Current: 3D Stream Radio admin settings
LOCALE:Set("settings.admin.panel.title", [[3D Stream Radio admin settings]])

-- Current: Security Options
LOCALE:Set("settings.admin.security.label", [[Security Options]])

-- Current:
--  | CAUTION: This affects the server security of this addon.
--  | Only disable the whitelist if you know what you are doing!
--  | Otherwise never turn this off!
LOCALE:Set("settings.admin.security.security_whitelist_warning.info", [[CAUTION: This affects the server security of this addon.
Only disable the whitelist if you know what you are doing!
Otherwise never turn this off!]])

-- Current: Log stream URLs to console
LOCALE:Set("settings.admin.security.url_log_mode.label", [[Log stream URLs to console]])

-- Current: Log all URLs
LOCALE:Set("settings.admin.security.url_log_mode.option.all", [[Log all URLs]])

-- Current: No logging
LOCALE:Set("settings.admin.security.url_log_mode.option.off", [[No logging]])

-- Current: Log online URLs only
LOCALE:Set("settings.admin.security.url_log_mode.option.online", [[Log online URLs only]])

-- Current: The whitelist is based of the installed playlists. Edit them to change the whitelist or use the quick whitelist options on a radio entity.
LOCALE:Set("settings.admin.security.url_whitelist.info.1", [[The whitelist is based of the installed playlists. Edit them to change the whitelist or use the quick whitelist options on a radio entity.]])

-- Current: It is always disabled on single player.
LOCALE:Set("settings.admin.security.url_whitelist.info.2", [[It is always disabled on single player.]])

-- Current: URL Whitelist
LOCALE:Set("settings.admin.security.url_whitelist_enable.label", [[URL Whitelist]])

-- Current: Disable Stream URL whitelist (dangerous)
LOCALE:Set("settings.admin.security.url_whitelist_enable.option.disable", [[Disable Stream URL whitelist (dangerous)]])

-- Current: Enable Stream URL whitelist (recommended)
LOCALE:Set("settings.admin.security.url_whitelist_enable.option.enable", [[Enable Stream URL whitelist (recommended)]])

-- Current: If the server has the addon 'CFC Client HTTP Whitelist' installed, the built-in whitelist is disabled automatically for better useability.
LOCALE:Set("settings.admin.security.url_whitelist_enable_on_cfcwhitelist.info.1", [[If the server has the addon 'CFC Client HTTP Whitelist' installed, the built-in whitelist is disabled automatically for better useability.]])

-- Current: If the box is checked, the built-in whitelist will be always active. Both options are safe to use.
LOCALE:Set("settings.admin.security.url_whitelist_enable_on_cfcwhitelist.info.2", [[If the box is checked, the built-in whitelist will be always active. Both options are safe to use.]])

-- Current: Enable the build-in whitelist even if CFC Whitelist is installed
LOCALE:Set("settings.admin.security.url_whitelist_enable_on_cfcwhitelist.label", [[Enable the build-in whitelist even if CFC Whitelist is installed]])

-- Current: Press this button to reload the whitelist. It is rebuilt from server's playlist files.
LOCALE:Set("settings.admin.security.url_whitelist_reload.info.1", [[Press this button to reload the whitelist. It is rebuilt from server's playlist files.]])

-- Current: You can safely use it anytime you want.
LOCALE:Set("settings.admin.security.url_whitelist_reload.info.2", [[You can safely use it anytime you want.]])

-- Current: Reload URL Whitelist
LOCALE:Set("settings.admin.security.url_whitelist_reload.label", [[Reload URL Whitelist]])

-- Current: Always trust radios owned by admins (skips whitelist)
LOCALE:Set("settings.admin.security.url_whitelist_trust_admin_radios.label", [[Always trust radios owned by admins (skips whitelist)]])

-- Current: Admin Settings
LOCALE:Set("settings.admin.title", [[Admin Settings]])


-- ================================================================================
-- Sub Category:  settings.general
-- ================================================================================

-- Current: Use GM_BASS3 if installed
LOCALE:Set("settings.general.bass3_enable.label", [[Use GM_BASS3 if installed]])

-- Current: Clear client stream cache
LOCALE:Set("settings.general.cache_clear.label", [[Clear client stream cache]])

-- Current: Show cursor
LOCALE:Set("settings.general.gui_cursor_enable.label", [[Show cursor]])

-- Current: GUI draw distance
LOCALE:Set("settings.general.gui_distance.label", [[GUI draw distance]])

-- Current: Hide GUIs
LOCALE:Set("settings.general.gui_hide.label", [[Hide GUIs]])

-- Current: Language
LOCALE:Set("settings.general.locale.label", [[Language]])

-- Current: Mute at distance
LOCALE:Set("settings.general.mute_distance.label", [[Mute at distance]])

-- Current: Mute all radios from other players
LOCALE:Set("settings.general.mute_foreign.label", [[Mute all radios from other players]])

-- Current: Mute all radios
LOCALE:Set("settings.general.mute_global.label", [[Mute all radios]])

-- Current: Mute radios on game unfocus
LOCALE:Set("settings.general.mute_unfocused.label", [[Mute radios on game unfocus]])

-- Current: 3D Stream Radio general settings
LOCALE:Set("settings.general.panel.title", [[3D Stream Radio general settings]])

-- Current: Enable rendertargets
LOCALE:Set("settings.general.rendertarget.label", [[Enable rendertargets]])

-- Current: Rendertarget FPS
LOCALE:Set("settings.general.rendertarget_fps.label", [[Rendertarget FPS]])

-- Current: Enable 3D Sound
LOCALE:Set("settings.general.sfx_3dsound.label", [[Enable 3D Sound]])

-- Current: Spectrum bars
LOCALE:Set("settings.general.spectrum_barcount.label", [[Spectrum bars]])

-- Current: Spectrum draw distance
LOCALE:Set("settings.general.spectrum_distance.label", [[Spectrum draw distance]])

-- Current: Hide spectrum
LOCALE:Set("settings.general.spectrum_hide.label", [[Hide spectrum]])

-- Current: General Settings
LOCALE:Set("settings.general.title", [[General Settings]])

-- Current: Radio control/use key
LOCALE:Set("settings.general.usekey_global.label", [[Radio control/use key]])

-- Current: Radio control/use key while in vehicles
LOCALE:Set("settings.general.usekey_vehicle.label", [[Radio control/use key while in vehicles]])

-- Current: Global volume
LOCALE:Set("settings.general.volume_global.label", [[Global volume]])

-- Current: Volume factor of radios behind walls (sound occlusion)
LOCALE:Set("settings.general.volume_occluded.label", [[Volume factor of radios behind walls (sound occlusion)]])


-- ================================================================================
-- Sub Category:  settings.vr
-- ================================================================================

-- Current: Show cursor in VR
LOCALE:Set("settings.vr.gui_cursor_enable.label", [[Show cursor in VR]])

-- Current: 3D Stream Radio VR settings
LOCALE:Set("settings.vr.panel.title", [[3D Stream Radio VR settings]])

-- Current: VR Settings
LOCALE:Set("settings.vr.title", [[VR Settings]])

-- Current: Enable VR Touch Control
LOCALE:Set("settings.vr.touch_enable.label", [[Enable VR Touch Control]])

-- Current: Enable VR Trigger Control
LOCALE:Set("settings.vr.trigger_enable.label", [[Enable VR Trigger Control]])

-- This file returns true, so we know it has been loaded properly
return true

