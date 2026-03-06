local StreamRadioLib = StreamRadioLib

if StreamRadioLib.ReloadAddon() then
	return
end

StreamRadioLib.Settings = StreamRadioLib.Settings or {}
local LIB = StreamRadioLib.Settings

local T = StreamRadioLib.Locale.Translate

local LIBMenu = StreamRadioLib.Menu

local g_nextThink = 0
local g_lastIsAdmin = false

LIB.g_CV_List["admin"] = {}

local function AddDangerMenuPanel(CPanel)
	local subpanel = vgui.Create("DForm")

	subpanel:SetName(T("?settings.admin.danger.label", "Playlists rebuild setting"))

	CPanel:AddPanel(subpanel)
	subpanel:SetCookieName("streamradio_admin_playlists_rebuild")

	subpanel:AddItem(
		LIBMenu.GetWarnLabel(T("?settings.admin.danger.playlist_data_loss_warning.info", "CAUTION: Be careful what you in this section!\nUnanticipated loss of CUSTOM playlist files can be caused by mistakes!"))
	)

	subpanel:AddItem(LIBMenu.GetSpacerLine())

	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.danger.rebuildplaylists_community_auto.info", "Rebuild mode for playlists in 'community'.\nEffective with server restarts."))
	)

	local rebuildplaylistsCombobox, rebuildplaylistsLabel = subpanel:ComboBox(
		T("?settings.admin.danger.rebuildplaylists_community_auto.label", "Rebuild mode"),
		"sv_streamradio_rebuildplaylists_community_auto"
	)
	StreamRadioLib.Menu.PatchComboBox(rebuildplaylistsCombobox, rebuildplaylistsLabel)

	rebuildplaylistsCombobox:SetSortItems(false)
	rebuildplaylistsCombobox:AddChoice(
		T("?settings.admin.danger.rebuildplaylists_community_auto.option.off", "Off"),
		0, false, "3dstreamradio/icon16/arrow_not_refresh.png"
	)
	rebuildplaylistsCombobox:AddSpacer()
	rebuildplaylistsCombobox:AddChoice(
		T("?settings.admin.danger.rebuildplaylists_community_auto.option.rebuild", "Auto rebuild"),
		1, false, "icon16/arrow_merge.png"
	)
	rebuildplaylistsCombobox:AddChoice(
		T("?settings.admin.danger.rebuildplaylists_community_auto.option.reset_rebuild", "Auto reset & rebuild (default)"),
		2, false, "icon16/arrow_refresh.png"
	)

	subpanel:AddItem(LIBMenu.GetSpacerLine())

	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.danger.playlist_options_regularly_usable.info", "You can use this regularly to fix issues with broken playlists."))
	)

	subpanel:AddItem(LIBMenu.GetSpacer())
	subpanel:AddItem(
		LIBMenu.AddDangerButton(
			T("?settings.admin.danger.rebuildplaylists_community.label", "Rebuild community playlists"),
			{
				message = T("?settings.admin.danger.rebuildplaylists_community.message", "Do you really want to rebuild stock community playlists?\nThis overwrites default playlists and their changes in 'community'!"),
				cmd = "sv_streamradio_rebuildplaylists_community",
			}
		)
	)
	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.danger.rebuildplaylists_community.info", "Reverts stock playlist files in 'community' to default.\nThis overwrites default playlists and their changes in 'community'!"))
	)

	subpanel:AddItem(LIBMenu.GetSpacer())
	subpanel:AddItem(
		LIBMenu.AddDangerButton(
			T("?settings.admin.danger.resetplaylists_community.label", "Factory reset community playlists"),
			{
				message = T("?settings.admin.danger.resetplaylists_community.message", "Do you really want to reset ALL community playlists to defaults?\nThis removes ALL custom playlists and changes in 'community'!"),
				cmd = "sv_streamradio_resetplaylists_community",
			}
		)
	)
	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.danger.resetplaylists_community.info", "Reverts ALL playlist files in 'community' to default.\nThis removes ALL custom playlists and changes in 'community'!"))
	)

	subpanel:AddItem(LIBMenu.GetSpacerLine())

	subpanel:AddItem(
		LIBMenu.GetWarnLabel(T("?settings.admin.danger.playlist_options_dangerous.info", "CAUTION: This section affects ALL playlists on your server!"))
	)

	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.danger.playlist_options_dangerous_usage.info", "Only use this if want clean up or reset ALL playlist files."))
	)

	subpanel:AddItem(LIBMenu.GetSpacer())
	subpanel:AddItem(
		LIBMenu.AddDangerButton(
			T("?settings.admin.danger.rebuildplaylists.label", "Rebuild ALL playlists"),
			{
				message = T("?settings.admin.danger.rebuildplaylists.message", "Do you really want to rebuild stock playlists?\nThis overwrites the default playlists and their changes globally!"),
				cmd = "sv_streamradio_rebuildplaylists",
				icon = "icon16/exclamation.png",
			}
		)
	)
	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.danger.rebuildplaylists.info", "Reverts stock playlist files to default.\nThis overwrites the default playlists and their changes globally!"))
	)

	subpanel:AddItem(LIBMenu.GetSpacer())
	subpanel:AddItem(
		LIBMenu.AddDangerButton(
			T("?settings.admin.danger.resetplaylists.label", "Factory reset ALL playlists"),
			{
				message = T("?settings.admin.danger.resetplaylists.message", "Do you really want to reset ALL playlists to defaults?\nThis removes ALL custom playlists and changes globally!"),
				cmd = "sv_streamradio_resetplaylists",
				icon = "icon16/exclamation.png",
			}
		)
	)
	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.danger.resetplaylists.info", "Reverts ALL playlist files to default.\nThis removes ALL custom playlists and changes globally!"))
	)

	return subpanel
end

local function AddSecurityMenuPanel(CPanel)
	local subpanel = vgui.Create("DForm")

	subpanel:SetName(T("?settings.admin.security.label", "Security Options"))

	CPanel:AddPanel(subpanel)
	subpanel:SetCookieName("streamradio_admin_security")

	subpanel:AddItem(
		LIBMenu.GetWarnLabel(T("?settings.admin.security.security_whitelist_warning.info", "CAUTION: This affects the server security of this addon.\nOnly disable the whitelist if you know what you are doing!\nOtherwise never turn this off!"))
	)

	subpanel:AddItem(LIBMenu.GetSpacerLine())

	local urlLogCombobox, urlLogLabel = subpanel:ComboBox(
		T("?settings.admin.security.url_log_mode.label", "Log stream URLs to console"),
		"sv_streamradio_url_log_mode"
	)
	StreamRadioLib.Menu.PatchComboBox(urlLogCombobox, urlLogLabel)

	urlLogCombobox:SetSortItems(false)
	urlLogCombobox:AddChoice(
		T("?settings.admin.security.url_log_mode.option.off", "No logging"),
		0, false, "icon16/collision_off.png"
	)
	urlLogCombobox:AddSpacer()
	urlLogCombobox:AddChoice(
		T("?settings.admin.security.url_log_mode.option.online", "Log online URLs only"),
		1, false, "icon16/page_world.png"
	)
	urlLogCombobox:AddChoice(
		T("?settings.admin.security.url_log_mode.option.all", "Log all URLs"),
		2, false, "icon16/world.png"
	)

	local urlWhitelistCombobox, urlWhitelistLabel = subpanel:ComboBox(
		T("?settings.admin.security.url_whitelist_enable.label", "URL Whitelist"),
		"sv_streamradio_url_whitelist_enable"
	)
	StreamRadioLib.Menu.PatchComboBox(urlWhitelistCombobox, urlWhitelistLabel)

	urlWhitelistCombobox:SetSortItems(false)
	urlWhitelistCombobox:AddChoice(
		T("?settings.admin.security.url_whitelist_enable.option.enable", "Enable Stream URL whitelist (recommended)"),
		1, false, "icon16/shield.png"
	)
	urlWhitelistCombobox:AddChoice(
		T("?settings.admin.security.url_whitelist_enable.option.disable", "Disable Stream URL whitelist (dangerous)"),
		0, false, "icon16/exclamation.png"
	)

	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.security.url_whitelist.info.1", "The whitelist is based of the installed playlists. Edit them to change the whitelist or use the quick whitelist options on a radio entity."))
	)
	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.security.url_whitelist.info.2", "It is always disabled on single player."))
	)

	subpanel:CheckBox(
		T("?settings.admin.security.url_whitelist_trust_admin_radios.label", "Always trust radios owned by admins (skips whitelist)"),
		"sv_streamradio_url_whitelist_trust_admin_radios"
	)

	subpanel:AddItem(LIBMenu.GetSpacer())

	subpanel:AddItem(LIBMenu.GetWhitelistFAQButton())

	subpanel:AddItem(LIBMenu.GetSpacerLine())

	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.security.url_whitelist_enable_on_cfcwhitelist.info.1", "If the server has the addon 'CFC Client HTTP Whitelist' installed, the built-in whitelist is disabled automatically for better useability."))
	)
	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.security.url_whitelist_enable_on_cfcwhitelist.info.2", "If the box is checked, the built-in whitelist will be always active. Both options are safe to use."))
	)

	subpanel:CheckBox(
		T("?settings.admin.security.url_whitelist_enable_on_cfcwhitelist.label", "Enable the build-in whitelist even if CFC Whitelist is installed"),
		"sv_streamradio_url_whitelist_enable_on_cfcwhitelist"
	)

	subpanel:AddItem(LIBMenu.GetSpacer())

	subpanel:AddItem(LIBMenu.GetCFCWhitelistFAQButton())

	subpanel:AddItem(LIBMenu.GetSpacerLine())

	subpanel:Button(
		T("?settings.admin.security.url_whitelist_reload.label", "Reload URL Whitelist"),
		"sv_streamradio_url_whitelist_reload"
	)

	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.security.url_whitelist_reload.info.1", "Press this button to reload the whitelist. It is rebuilt from server's playlist files."))
	)
	subpanel:AddItem(
		LIBMenu.GetLabel(T("?settings.admin.security.url_whitelist_reload.info.2", "You can safely use it anytime you want."))
	)

	return subpanel
end

local function AddBassMenuPanel(CPanel)
	local subpanel = vgui.Create("DForm")

	subpanel:SetName(T("?settings.admin.bass3.panel.title", "GM_BASS3 Options"))

	CPanel:AddPanel(subpanel)
	subpanel:SetCookieName("streamradio_admin_bass3")

	local hasBass = StreamRadioLib.Bass.IsInstalledOnServer()

	subpanel:CheckBox(
		T("?settings.admin.bass3.enable.title", "Use GM_BASS3 on the server if available"),
		"sv_streamradio_bass3_enable"
	)

	subpanel:CheckBox(
		T("?settings.admin.bass3.allow_client.title", "Allow clients to use GM_BASS3 if available"),
		"sv_streamradio_bass3_allow_client"
	)

	subpanel:AddItem(LIBMenu.GetSpacerLine())

	if not hasBass then
		subpanel:AddItem(
			LIBMenu.GetWarnLabel(T("?settings.admin.bass3.panel.gm_bass3_install.info", "Install GM_BASS3 on the server to unlock the options below."))
		)
	end

	local infoLabel = LIBMenu.GetLabel(T("?settings.admin.bass3.panel.max_spectrums.info", "Maximum count of radios with Advanced Wire Outputs."))

	infoLabel:SetEnabled(hasBass)

	subpanel:AddItem(infoLabel)

	subpanel:NumSlider(
		T("?settings.admin.bass3.max_spectrums.title", "Maximum count"),
		"sv_streamradio_max_spectrums",
		0,
		50,
		0
	):SetEnabled(hasBass)

	subpanel:Button(
		T("?settings.admin.bass3.cache_clear.title", "Clear server stream cache"),
		"sv_streamradio_cache_clear"
	):SetEnabled(hasBass)

	return subpanel
end

local function BuildMenuPanel(CPanel)
	local toplabel = vgui.Create("DLabel")
	toplabel:SetText(T("?settings.admin.panel.title", "3D Stream Radio admin settings"))
	toplabel:SetDark(true)
	toplabel:SizeToContents()
	CPanel:AddPanel(toplabel)

	local StreamRadioLib = StreamRadioLib or {}

	if not StreamRadioLib.Loaded then
		if StreamRadioLib.Loader_CreateErrorPanel then
			StreamRadioLib.Loader_CreateErrorPanel(CPanel, "This menu could not be loaded.")
		end

		return
	end

	if not StreamRadioLib.Util.IsAdmin() then
		CPanel:AddPanel(
			LIBMenu.GetWarnLabel(T("?settings.admin.panel.admin-only.info", "You need to be an admin to access this panel."))
		)

		CPanel:AddPanel(LIBMenu.GetSpacer())

		CPanel:AddPanel(LIBMenu.GetFAQButton())
		CPanel:AddPanel(LIBMenu.GetCreditsPanel())
		return
	end

	AddBassMenuPanel(CPanel)

	CPanel:AddPanel(LIBMenu.GetSpacer())

	AddDangerMenuPanel(CPanel)

	CPanel:AddPanel(LIBMenu.GetSpacer())

	AddSecurityMenuPanel(CPanel)

	CPanel:AddPanel(LIBMenu.GetSpacer())

	CPanel:AddPanel(LIBMenu.GetOpenToolButton())
	CPanel:AddPanel(LIBMenu.GetOpenSettingsButton())
	CPanel:AddPanel(LIBMenu.GetPlaylistEditorButton())

	CPanel:AddPanel(LIBMenu.GetSpacer(5))
	CPanel:AddPanel(LIBMenu.GetFAQButton())
	CPanel:AddPanel(LIBMenu.GetCreditsPanel())
end

LIB.AddBuildMenuPanelHook("admin", "Admin Settings", BuildMenuPanel)

StreamRadioLib.Hook.Add("Think", "AdminSettingsUpdate", function()
	local now = RealTime()

	if g_nextThink < now then
		local isAdmin = StreamRadioLib.Util.IsAdmin()
		local adminChange = g_lastIsAdmin ~= isAdmin

		g_lastIsAdmin = isAdmin

		if adminChange then
			LIB.RebuildMenuPanelByNamespace("admin")
		end

		g_nextThink = now + 1 + math.random()
	end
end)

return true

