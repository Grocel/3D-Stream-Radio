local StreamRadioLib = StreamRadioLib

StreamRadioLib.Menu = StreamRadioLib.Menu or {}
local LIB = StreamRadioLib.Menu

function LIB.GetLinkButton(text, urlStr)
	text = tostring(text or "")

	local button = vgui.Create("DButton")

	button.SetURL = function(this, url)
		url = tostring(url or "")
		url = string.Trim(url)

		this._url = url

		if url == "" then
			button:SetTooltip(text)
			return
		end

		button:SetTooltip(text .. "\n\nURL: " .. url .. "\n\nRight click to copy the URL to clipboard.")
	end

	button.GetURL = function(this)
		local url = tostring(this._url or "")
		return url
	end

	button:SetURL(urlStr)

	button.DoClick = function(this)
		local url = this:GetURL()

		if url == "" then
			return
		end

		this._infoWasPressed = true

		gui.OpenURL(url)
	end

	button.DoRightClick = function(this)
		local url = this:GetURL()

		if url == "" then
			return
		end

		SetClipboardText(url)
	end

	local oldThink = button.Think
	local infoRed = Color(160, 0, 0)

	button.Think = function(this)
		oldThink(this)

		local lastGameMenuVisible = this._gameMenuVisible
		local gameMenuVisible = gui.IsGameUIVisible()
		this._gameMenuVisible = gameMenuVisible

		if lastGameMenuVisible == gameMenuVisible then
			return
		end

		local addInfo = gameMenuVisible and this._infoWasPressed

		this:SetDisabled(addInfo)

		if addInfo then
			if StreamRadioLib.VR.IsActive(ply) then
				this:SetText(text .. "\n[Please confirm on monitor]")
			else
				this:SetText(text .. "\n[Please confirm]")
			end

			this:SetTextColor(infoRed)
		else
			this._infoWasPressed = nil

			this:SetTextColor(nil)
			this:SetText(text)
			this:SetDark(true)
		end

		StreamRadioLib.VR.RenderMenu(this)
	end

	button:Think()
	button:SetImage("icon16/world_go.png")
	button:SetTall(35)

	return button
end

function LIB.GetAdminButton(label)
	local button = vgui.Create("DButton")

	local function handleAdmin(this)
		local lastIsAdmin = this._isAdmin

		local isAdmin = StreamRadioLib.Util.IsAdmin()
		this._isAdmin = isAdmin

		return lastIsAdmin == isAdmin, isAdmin
	end

	local function handleVR(this)
		local lastIsVR = this._isVR

		local isVR = StreamRadioLib.VR.IsActive()
		this._isVR = isVR

		return lastIsVR == isVR, isVR
	end

	local oldThink = button.Think
	button.Think = function(this)
		oldThink(this)

		local changeAdmin, isAdmin = handleAdmin(this)
		local changeVR, isVR = handleVR(this)

		if not changeAdmin and not changeVR then
			return
		end

		local locked = isVR or not isAdmin

		this:SetDisabled(locked)

		local tooltip = label
		local text = label

		if locked then
			tooltip = tooltip .. " (not available)"

			if not isAdmin then
				tooltip = tooltip .. "\n - You must be an admin!"
				text = text .. " (Admin only!)"
			end

			if isVR then
				tooltip = tooltip .. "\n - You must not be in VR!"
				text = text .. " (Not in VR!)"
			end
		end

		this:SetTooltip(tooltip)
		this:SetText(text)

		StreamRadioLib.VR.RenderMenu(this)
	end

	button:Think()

	return button
end

function LIB.AddDangerButton(label, data)
	local button = LIB.GetAdminButton(label)

	local message = tostring(data.message or "")
	local icon = data.icon or "icon16/error.png"

	if message ~= "" then
		message = message .. "\nThis can not be undone!"
	end

	button.DoClick = function(this)
		Derma_Query(message, label, "Yes", function()
			RunConsoleCommand(data.cmd)
		end, "No" )
	end

	button:SetImage(icon)

	return button
end

function LIB.GetLabel(text)
	local label = vgui.Create("DLabel")

	label:SetText(text)
	label:SetTooltip(text)

	label:SetDark(true)
	label:SizeToContents()

	return label
end

function LIB.GetWarnLabel(text)
	local label = LIB.GetLabel(text)

	label:SetDark(false)
	label:SetHighlight(true)

	return label
end

function LIB.GetCustomURLBlockedLabel(text)
	local label = LIB.GetWarnLabel(text)

	local function handleBlocked(this)
		local lastIsCustomURLsAllowed = this._isCustomURLsAllowed

		local isCustomURLsAllowed = StreamRadioLib.IsCustomURLsAllowed()
		this._isCustomURLsAllowed = isCustomURLsAllowed

		return lastIsCustomURLsAllowed == isCustomURLsAllowed, isCustomURLsAllowed
	end

	local oldThink = label.Think
	label.Think = function(this)
		oldThink(this)

		local changeAllowed, isAllowed = handleBlocked(this)

		if not changeAllowed then
			return
		end

		if isAllowed then
			this:SetTall(0)
		else
			this:SizeToContents()
		end

		local parent = this:GetParent()
		if IsValid(parent) then
			parent:InvalidateLayout()
			StreamRadioLib.VR.RenderMenu(parent)
		end

		this:InvalidateLayout()
		StreamRadioLib.VR.RenderMenu(this)
	end

	label:Think()

	return label
end

function LIB.GetCreditsPanel()
	local credits = LIB.GetLabel(StreamRadioLib.AddonPrefix .. "Made by Grocel")
	return credits
end

function LIB.GetVRInfoPanel()
	local vrinfo = LIB.GetLabel("Powered by VRMod!\n  - VRMod is made by Catse\n  - VR Headset required!\n  - VR is optional, this addon works without VR.")
	return vrinfo
end

function LIB.GetVRErrorPanel()
	local vrinfo = LIB.GetWarnLabel((StreamRadioLib.AddonPrefix or "") .. "\nVRMod is not loaded.\n  - Install VRMod to enable VR support.\n  - VR Headset required!\n  - VR is optional, this addon works without VR.")
	return vrinfo
end

function LIB.GetSpacer(height)
	height = tonumber(height or 0) or 0

	if height <= 0 then
		height = 10
	end

	local spacer = vgui.Create("DPanel")

	spacer:SetMouseInputEnabled(false)
	spacer:SetPaintBackgroundEnabled(false)
	spacer:SetPaintBorderEnabled(false)
	spacer:SetPaintBackground(false)

	spacer:DockMargin(0, 0, 0, 0)
	spacer:DockPadding(0, 0, 0, 0)

	spacer:SetHeight(height)

	return spacer
end

function LIB.GetSpacerLine()
	local spacer = vgui.Create("DPanel")

	spacer.Paint = function( p, w, h )
		derma.SkinHook( "Paint", "MenuSpacer", p, w, h )
	end

	spacer:DockMargin(0, 0, 0, 0)
	spacer:DockPadding(0, 0, 0, 0)

	spacer:SetHeight(1)

	return spacer
end

function LIB.GetFAQButton()
	local button = LIB.GetLinkButton("Show FAQ (Workshop)", "https://steamcommunity.com/workshop/filedetails/discussion/246756300/368542844488661960/")
	return button
end

function LIB.GetVRFAQButton()
	local button = LIB.GetLinkButton("Show VR FAQ (Workshop)", "https://steamcommunity.com/workshop/filedetails/discussion/246756300/2247805152838837222/")
	return button
end

function LIB.GetVRAddonButton()
	local button = LIB.GetLinkButton("Download VRMod (Workshop)", "https://steamcommunity.com/sharedfiles/filedetails/?id=1678408548")
	return button
end

function LIB.GetVRAddonPanelButton()
	local button = vgui.Create("DButton")

	local maintext = "Show VRMod Panel"

	button.DoClick = function(this)
		RunConsoleCommand("vrmod")
	end

	button:SetTooltip(maintext)
	button:SetText(maintext)

	return button
end

function LIB.GetPlaylistEditorButton()
	local button = LIB.GetAdminButton("Show Playlist Editor")

	button.DoClick = function(this)
		RunConsoleCommand("cl_streamradio_playlisteditor")
	end

	return button
end

function LIB.GetOpenToolButton()
	local button = vgui.Create("DButton")

	local maintext = "Stream Radio Tool"

	button.DoClick = function(this)
		spawnmenu.ActivateTool("streamradio", false)
	end

	button:SetTooltip(maintext)
	button:SetText(maintext)

	return button
end

function LIB.GetOpenSettingsButton()
	local button = vgui.Create("DButton")

	local maintext = "General Settings"

	button.DoClick = function(this)
		spawnmenu.ActivateTool("StreamRadioSettingsPanel_general", true)
	end

	button:SetTooltip(maintext)
	button:SetText(maintext)

	return button
end

function LIB.GetOpenAdminSettingsButton()
	local button = LIB.GetAdminButton("Admin Settings")

	button.DoClick = function(this)
		spawnmenu.ActivateTool("StreamRadioSettingsPanel_admin", true)
	end

	return button
end

function LIB.PatchComboBox(combobox, label)
	local parent = label:GetParent()

	if IsValid(parent) then
		parent:SetTall(35)
	end

	local updateIcon = function()
		local index = combobox:GetSelectedID()

		if not combobox.ChoiceIcons then
			return
		end

		combobox:SetIcon(combobox.ChoiceIcons[index])
	end

	local oldSetText = combobox.SetText
	combobox.SetText = function(this, ...)
		oldSetText(this, ...)
		StreamRadioLib.Timedcall(updateIcon)
	end

	StreamRadioLib.Timedcall(updateIcon)
	return combobox
end

return true

