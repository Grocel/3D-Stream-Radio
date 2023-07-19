
StreamRadioLib.properties = StreamRadioLib.properties or {}
local LIB = StreamRadioLib.properties

local LIBNet = StreamRadioLib.Net
local LIBNetwork = StreamRadioLib.Network
local LIBError = StreamRadioLib.Error

local g_mainOptionAdded = false
local g_subOptions = {}
local g_nameprefix = "3dstreamradio_properties_"

if SERVER then
	LIBNetwork.AddNetworkString("properties")

	LIBNet.Receive("properties", function(len, client)
		if not IsValid(client) then return end

		local name = net.ReadString()
		if not name then return end

		local subOption = g_subOptions[name]
		if not subOption then return end
		if not subOption.Receive then return end

		subOption:Receive(len, client)
	end)
end

function LIB.GetName(identifier)
	identifier = g_nameprefix .. tostring(identifier or "")
	identifier = string.lower(identifier)

	return identifier
end

function LIB.Get(identifier)
	identifier = LIB.GetName(identifier)

	return properties.List[identifier] or g_subOptions[identifier]
end

function LIB.Add(identifier, propertyData)
	identifier = LIB.GetName(identifier)

	return properties.Add(identifier, propertyData)
end

function LIB.CanProperty(identifier, ent, ply )
	if not IsValid( ent ) then return false end
	if not ent.__IsRadio then return false end

	identifier = LIB.GetName(identifier)
	if not gamemode.Call( "CanProperty", ply, identifier, ent ) then return false end

	return true
end

function LIB.CanBeTargeted(ent, ply)
	if not IsValid( ent ) then return false end
	if not ent.__IsRadio then return false end
	if not properties.CanBeTargeted( ent, ply ) then return false end

	return true
end

function LIB.CheckFilter(identifier, ent, ply)
	local propertyData = LIB.Get(identifier)

	if not propertyData then
		return true
	end

	if not propertyData.Filter then
		return true
	end

	return propertyData:Filter(ent, ply)
end

function LIB.CheckFilters(identifiers, ent, ply)
	for i, identifier in ipairs(identifiers) do
		if LIB.CheckFilter(identifier, ent, ply) then
			return true
		end
	end

	return false
end

local g_meta = {
	MsgStart = function(self)
		LIBNet.Start("properties")
		net.WriteString(self.InternalName)
	end,

	MsgEnd = function(self)
		net.SendToServer()
	end
}

g_meta.__index = g_meta

local function addMainOption()
	if g_mainOptionAdded then
		return
	end

	LIB.Add("radio_options", {
		MenuLabel = "Radio Options",
		Order = 10000,
		MenuIcon = "3dstreamradio/icon16/format_radio.png",

		Filter = function( self, ent, ply )
			if not LIB.CanBeTargeted( ent, ply ) then return false end
			return true
		end,

		MenuOpen = function( self, option, ent, tr )
			local ply = LocalPlayer()
			if not self:Filter(ent, ply) then return end

			local submenuPanel = option:AddSubMenu()

			submenuPanel:SetMinimumWidth(200)

			for k, subOption in SortedPairsByMemberValue( g_subOptions, "Order" ) do
				if not subOption.Filter then continue end
				if not subOption:Filter(ent, ply) then continue end

				if subOption.PrependSpacer then
					submenuPanel:AddSpacer()
				end

				local label = subOption.MenuLabel or subOption.InternalName

				local optionPanel = submenuPanel:AddOption(
					label,
					function(panel)
						if not subOption:Filter(ent, ply) then
							return
						end

						subOption:Action(ent, tr)

						panel:Think()
					end
				)

				if subOption.OnCreate then
					subOption:OnCreate(submenuPanel, optionPanel)
				end

				if subOption.MenuIcon then
					optionPanel:SetImage(subOption.MenuIcon)
				end

				if subOption.MenuOpen then
					subOption:MenuOpen(optionPanel, ent, tr)
				end

				optionPanel._oldThink = optionPanel.Think
				optionPanel.Think = function(panel, ...)
					if not subOption.Think then
						return
					end

					if not subOption:Filter(ent, ply) then
						return
					end

					subOption:Think(panel, ent)

					if panel._oldThink then
						return panel:_oldThink(...)
					end
				end
			end
		end,

		Action = function( self, ent )
		end,

		Receive = function( self, length, ply )
		end
	})

	g_mainOptionAdded = true
end

function LIB.AddSubOption(identifier, propertyData)
	addMainOption()

	identifier = LIB.GetName(identifier)

	propertyData = table.Copy(propertyData)
	propertyData.InternalName = identifier

	setmetatable(propertyData, g_meta)

	g_subOptions[identifier] = propertyData
end

local function g_emptyFunction()
end

local g_titleOnCreate = function( self, submenuPanel, optionPanel )
	optionPanel.OnMousePressed = g_emptyFunction
	optionPanel.OnMouseReleased = g_emptyFunction
	optionPanel.DoClickInternal = g_emptyFunction

	optionPanel:SetDisabled(true)
	optionPanel:SetTextInset(2, 0)
	optionPanel:SetContentAlignment(5)
end

local g_VolumeMenuOpen = function( self, optionPanel, ent )
	optionPanel.OnMousePressed = g_emptyFunction
	optionPanel.OnMouseReleased = g_emptyFunction
	optionPanel.DoClickInternal = g_emptyFunction

	optionPanel:SetTextInset(5, 0)
	optionPanel:DockPadding(5,5,5,5)

	local ply = LocalPlayer()

	local upButton = vgui.Create( "DButton", optionPanel )
	optionPanel._upButton = upButton

	upButton:Dock(RIGHT)
	upButton:SetImage(StreamRadioLib.GetPNGIconPath("sound_add"))
	upButton:DockMargin(5,0,0,0)
	upButton:SetTooltip("Increase volume")

	upButton.DoClick = function(panel)
		if not self.VolumeUp then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:VolumeUp(ent)
		panel:Think()
	end

	local downButton = vgui.Create( "DButton", optionPanel )
	optionPanel._downButton = downButton

	downButton:Dock(RIGHT)
	downButton:SetImage(StreamRadioLib.GetPNGIconPath("sound_delete"))
	downButton:DockMargin(0,0,0,0)
	downButton:SetTooltip("Decrease volume")

	downButton.DoClick = function(panel)
		if not self.VolumeDown then
			return
		end

		if not self:Filter(ent, ply) then
			return
		end

		self:VolumeDown(ent)
		panel:Think()
	end

	-- bypass hardcoded size in internal PerformLayout
	optionPanel._SetSize = optionPanel.SetSize

	optionPanel.SetSize = function(panel, x, y)
		y = 40
		local buttonSize = y - 10

		upButton:SetSize(buttonSize, buttonSize)
		downButton:SetSize(buttonSize, buttonSize)

		return panel:_SetSize(x, y)
	end
end

LIB.AddSubOption("clientside_title", {
	MenuLabel = "Clientside Options",
	Order = 100,
	PrependSpacer = true,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end

		local allowed = LIB.CheckFilters(
			{
				"copy_url",
				"error_info",
				"clientside_mute",
				"clientside_unmute",
				"clientside_volume",
			},
			ent,
			ply
		)

		return allowed
	end,

	Action = function( self, ent )
	end,

	OnCreate = g_titleOnCreate,
})

LIB.AddSubOption("copy_url", {
	MenuLabel = "Copy Stream URL to clipboard",
	Order = 101,
	MenuIcon = StreamRadioLib.GetPNGIconPath("page_copy"),
	PrependSpacer = true,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end

		local url = ent:GetStreamURL()
		if url == "" then return false end

		return true
	end,

	Action = function( self, ent )
		local url = ent:GetStreamURL()
		SetClipboardText(url)
	end,
})

LIB.AddSubOption("error_info", {
	MenuLabel = "Error",
	Order = 102,
	MenuIcon = StreamRadioLib.GetPNGIconPath("error"),

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end

		local stream = ent:GetStreamObject()
		if not stream then return false end
		if not stream:HasError() then return false end

		return true
	end,

	Action = function( self, ent )
		local stream = ent:GetStreamObject()

		local err = stream:GetError()
		local url = stream:GetURL()

		StreamRadioLib.ShowErrorHelp(err, url)
	end,

	Think = function( self, optionPanel, ent )
		local stream = ent:GetStreamObject()

		local err = stream:GetError()
		local url = stream:GetURL()

		local errorInfo = LIBError.GetStreamErrorInfo(err)
		local errorName = errorInfo.name
		local errorDescription = errorInfo.description

		local label = string.format("%s: %i (%s)", self.MenuLabel, err, errorName)
		local tooltip = string.format("Error %i (%s): %s\n\nCan not play this URL:\n%s\n\nClick for more details.", err, errorName, errorDescription, url)

		optionPanel:SetText(label)
		optionPanel:SetTooltip(tooltip)
	end,
})

LIB.AddSubOption("clientside_mute", {
	MenuLabel = "Mute",
	Order = 111,
	MenuIcon = StreamRadioLib.GetPNGIconPath("sound_mute"),
	PrependSpacer = true,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		if ent:GetCLMute() then return false end

		return true
	end,

	Action = function( self, ent )
		ent:SetCLMute(true)
	end,
})

LIB.AddSubOption("clientside_unmute", {
	MenuLabel = "Unmute",
	Order = 112,
	MenuIcon = StreamRadioLib.GetPNGIconPath("sound"),

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		if not ent:GetCLMute() then return false end

		return true
	end,

	Action = function( self, ent )
		ent:SetCLMute(false)
	end,
})


LIB.AddSubOption("clientside_volume", {
	MenuLabel = "Volume",
	Order = 113,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		return true
	end,

	Action = function( self, ent )
	end,

	ChangeVolume = function( self, ent, up )
		local volume = ent:GetCLVolume()
		local value = up and 0.2 or -0.2

		volume = math.Clamp(volume + value, 0, 1)
		volume = math.Round(volume, 2)

		ent:SetCLVolume(volume)
	end,

	VolumeUp = function( self, ent )
		self:ChangeVolume(ent, true)
	end,

	VolumeDown = function( self, ent )
		self:ChangeVolume(ent, false)
	end,

	Think = function( self, optionPanel, ent )
		local volume = ent:GetCLVolume()

		local label = string.format("%s: %3i%%", self.MenuLabel, volume * 100)

		optionPanel:SetText(label)

		local upButton = optionPanel._upButton
		local downButton = optionPanel._downButton

		if IsValid(upButton) then
			if volume >= 1 then
				upButton:SetDisabled(true)
			else
				upButton:SetDisabled(false)
			end
		end

		if IsValid(downButton) then
			if volume <= 0 then
				downButton:SetDisabled(true)
			else
				downButton:SetDisabled(false)
			end
		end
	end,

	MenuOpen = g_VolumeMenuOpen,
})

LIB.AddSubOption("serverside_title", {
	MenuLabel = "Entity Options",
	Order = 200,
	PrependSpacer = true,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end

		local allowed = LIB.CheckFilters(
			{
				"serverside_mute",
				"serverside_unmute",
				"serverside_volume",
			},
			ent,
			ply
		)

		return allowed
	end,

	Action = function( self, ent )
	end,

	OnCreate = g_titleOnCreate,
})

LIB.AddSubOption("serverside_mute", {
	MenuLabel = "Mute",
	Order = 201,
	MenuIcon = StreamRadioLib.GetPNGIconPath("sound_mute"),
	PrependSpacer = true,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		if not LIB.CanProperty("serverside_mute", ent, ply ) then return false end
		if ent:GetSVMute() then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()
		if not self:Filter( ent, ply ) then return end

		ent:SetSVMute(true)
	end
})

LIB.AddSubOption("serverside_unmute", {
	MenuLabel = "Unmute",
	Order = 202,
	MenuIcon = StreamRadioLib.GetPNGIconPath("sound"),

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		if not LIB.CanProperty("serverside_unmute", ent, ply ) then return false end
		if not ent:GetSVMute() then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()
		if not self:Filter( ent, ply ) then return end

		ent:SetSVMute(false)
	end
})

LIB.AddSubOption("serverside_volume", {
	MenuLabel = "Volume",
	Order = 203,

	Filter = function( self, ent, ply )
		if not LIB.CanBeTargeted( ent, ply ) then return false end
		if not LIB.CanProperty("serverside_volume", ent, ply ) then return false end

		return true
	end,

	Action = function( self, ent )
	end,

	ChangeVolume = function( self, ent, up )
		self:MsgStart()
			net.WriteEntity( ent )
			net.WriteBool( up )
		self:MsgEnd()
	end,

	VolumeUp = function( self, ent )
		self:ChangeVolume(ent, true)
	end,

	VolumeDown = function( self, ent )
		self:ChangeVolume(ent, false)
	end,

	Think = function( self, optionPanel, ent )
		local volume = ent:GetVolume()

		local label = string.format("%s: %3i%%", self.MenuLabel, volume * 100)

		optionPanel:SetText(label)

		local upButton = optionPanel._upButton
		local downButton = optionPanel._downButton

		if IsValid(upButton) then
			if volume >= 1 then
				upButton:SetDisabled(true)
			else
				upButton:SetDisabled(false)
			end
		end

		if IsValid(downButton) then
			if volume <= 0 then
				downButton:SetDisabled(true)
			else
				downButton:SetDisabled(false)
			end
		end
	end,

	MenuOpen = g_VolumeMenuOpen,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()
		local up = net.ReadBool()

		local value = up and 0.2 or -0.2
		if not self:Filter( ent, ply ) then return end

		local volume = ent:GetVolume()

		volume = math.Clamp(volume + value, 0, 1)
		volume = math.Round(volume, 2)

		ent:SetVolume(volume)
	end
})