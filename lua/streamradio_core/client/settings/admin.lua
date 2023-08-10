local StreamRadioLib = StreamRadioLib

StreamRadioLib.Settings = StreamRadioLib.Settings or {}
local LIB = StreamRadioLib.Settings

local LIBMenu = StreamRadioLib.Menu

local g_lastThink = 0
local g_panel = nil
local g_lastIsAdmin = false

LIB.g_CV_List["admin"] = {}

local function AddDangerMenuPanel(CPanel)
	local dangerPanel = vgui.Create("DForm")
	dangerPanel:SetName("Danger Zone")

	CPanel:AddPanel(dangerPanel)

	dangerPanel:AddItem(LIBMenu.GetWarnLabel("CAUTION: Be careful what you in this section!\nUnanticipated loss of CUSTOM playlist files\ncan be caused by mistakes!"))

	dangerPanel:AddItem(LIBMenu.GetSpacerLine())

	dangerPanel:AddItem(LIBMenu.GetLabel("Rebuild mode for playlists in 'community'.\nEffective with server restarts."))

	local combobox, label = dangerPanel:ComboBox(
		"Rebuild mode",
		"sv_streamradio_rebuildplaylists_community_auto"
	)
	StreamRadioLib.Menu.PatchComboBox(combobox, label)

	combobox:SetSortItems(false)
	combobox:AddChoice("Off", 0)
	combobox:AddSpacer()
	combobox:AddChoice("Auto rebuild", 1)
	combobox:AddChoice("Auto reset & rebuild (default)", 2)

	dangerPanel:AddItem(LIBMenu.GetSpacerLine())

	dangerPanel:AddItem(LIBMenu.GetLabel("You may want to use this regularly to fix\nissues with broken playlists."))

	dangerPanel:AddItem(LIBMenu.GetSpacer())
	dangerPanel:AddItem(
		LIBMenu.AddDangerButton(
			"Rebuild community playlists",
			{
				message = "Do you really want to rebuild stock community playlists?\nThis overwrites default playlists and their changes in 'community'!",
				cmd = "sv_streamradio_rebuildplaylists_community",
			}
		)
	)
	dangerPanel:AddItem(LIBMenu.GetLabel("Reverts stock playlist files in 'community' to default.\nThis overwrites default playlists\nand their changes in 'community'!"))

	dangerPanel:AddItem(LIBMenu.GetSpacer())
	dangerPanel:AddItem(
		LIBMenu.AddDangerButton(
			"Factory reset community playlists",
			{
				message = "Do you really want to reset ALL community playlists to defaults?\nThis removes ALL custom playlists and changes in 'community'!",
				cmd = "sv_streamradio_resetplaylists_community",
			}
		)
	)
	dangerPanel:AddItem(LIBMenu.GetLabel("Reverts ALL playlist files in 'community' to default.\nThis removes ALL custom playlists\nand changes in 'community'!"))

	dangerPanel:AddItem(LIBMenu.GetSpacerLine())

	dangerPanel:AddItem(LIBMenu.GetWarnLabel("CAUTION: This section affects ALL playlists\non your server!"))
	dangerPanel:AddItem(LIBMenu.GetLabel("Only use this if want clean up or reset\nall playlist files."))

	dangerPanel:AddItem(LIBMenu.GetSpacer())
	dangerPanel:AddItem(
		LIBMenu.AddDangerButton(
			"Rebuild ALL playlists",
			{
				message = "Do you really want to rebuild stock playlists?\nThis overwrites the default playlists and their changes globally!",
				cmd = "sv_streamradio_rebuildplaylists",
				icon = "icon16/exclamation.png",
			}
		)
	)
	dangerPanel:AddItem(LIBMenu.GetLabel("Reverts stock playlist files to default.\nThis overwrites the default playlists\nand their changes globally!"))

	dangerPanel:AddItem(LIBMenu.GetSpacer())
	dangerPanel:AddItem(
		LIBMenu.AddDangerButton(
			"Factory reset ALL playlists",
			{
				message = "Do you really want to reset ALL playlists to defaults?\nThis removes ALL custom playlists and changes globally!",
				cmd = "sv_streamradio_resetplaylists",
				icon = "icon16/exclamation.png",
			}
		)
	)
	dangerPanel:AddItem(LIBMenu.GetLabel("Reverts ALL playlist files to default.\nThis removes ALL custom playlists\nand changes globally!"))

	return dangerPanel
end

local function AddBassMenuPanel(CPanel)
	local bassPanel = vgui.Create("DForm")
	bassPanel:SetName("GM_BASS3 Options")

	CPanel:AddPanel(bassPanel)

	local hasBass = StreamRadioLib.Bass.IsInstalledOnServer()

	bassPanel:CheckBox(
		"Use GM_BASS3 on the server if available",
		"sv_streamradio_bass3_enable"
	)

	bassPanel:CheckBox(
		"Allow clients to use GM_BASS3 if available",
		"sv_streamradio_bass3_allow_client"
	)

	bassPanel:AddItem(LIBMenu.GetSpacerLine())

	if not hasBass then
		bassPanel:AddItem(LIBMenu.GetWarnLabel("Install GM_BASS3 on the server to unlock the options below."))
	end

	local infoLabel = LIBMenu.GetLabel("Maximum count of radios with Advanced Wire Outputs.")
	infoLabel:SetEnabled(hasBass)

	bassPanel:AddItem(infoLabel)

	bassPanel:NumSlider(
		"Maximum count",
		"sv_streamradio_max_spectrums",
		0,
		50,
		0
	):SetEnabled(hasBass)

	bassPanel:Button(
		"Clear server stream cache",
		"sv_streamradio_cacheclear"
	):SetEnabled(hasBass)

	return bassPanel
end

local function BuildMenuPanel(CPanel)
	if not IsValid(CPanel) then return end

	CPanel._UpdateAdminLayout = function(CPanel)
		CPanel:Clear()

		local toplabel = vgui.Create("DLabel")
		toplabel:SetText("3D Stream Radio admin settings")
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
			CPanel:AddPanel(LIBMenu.GetWarnLabel("You need to be an admin to access this panel."))

			CPanel:AddPanel(LIBMenu.GetSpacer())

			CPanel:AddPanel(LIBMenu.GetFAQButton())
			CPanel:AddPanel(LIBMenu.GetCreditsPanel())
			return
		end

		CPanel:CheckBox(
			"Allow custom stream URLs",
			"sv_streamradio_allow_customurls"
		)

		AddBassMenuPanel(CPanel)

		CPanel:AddPanel(LIBMenu.GetSpacer())

		AddDangerMenuPanel(CPanel)

		CPanel:AddPanel(LIBMenu.GetSpacer())

		CPanel:AddPanel(LIBMenu.GetOpenToolButton())
		CPanel:AddPanel(LIBMenu.GetOpenSettingsButton())
		CPanel:AddPanel(LIBMenu.GetPlaylistEditorButton())

		CPanel:AddPanel(LIBMenu.GetSpacer(5))
		CPanel:AddPanel(LIBMenu.GetFAQButton())
		CPanel:AddPanel(LIBMenu.GetCreditsPanel())
	end

	if IsValid(g_panel) then
		g_panel:Remove()
		g_panel = nil
	end

	g_panel = CPanel
	g_panel:_UpdateAdminLayout()
end

LIB.AddBuildMenuPanelHook("admin", "Admin Settings", BuildMenuPanel)

StreamRadioLib.Hook.Add("Think", "AdminSettingsUpdate", function()
	local now = RealTime()

	if g_lastThink < now then
		local isAdmin = StreamRadioLib.Util.IsAdmin()
		local adminChange = g_lastIsAdmin ~= isAdmin

		g_lastIsAdmin = isAdmin

		if adminChange and IsValid(g_panel) and g_panel._UpdateAdminLayout then
			g_panel:_UpdateAdminLayout()
		end

		g_lastThink = now + 1 + math.random()
	end
end)

