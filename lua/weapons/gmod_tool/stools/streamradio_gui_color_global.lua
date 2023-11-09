TOOL.Category = "Stream Radio"
TOOL.Name = "#Tool." .. TOOL.Mode .. ".name"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" },
}

TOOL.SkinColorsVars = {
	cursor = {
		hierarchies = {
			"",
		},

		colors = {
			color_cursor = {
				default = Color(255, 255, 255, 255),
				order = 1,
			},
		},

		order = 1,
	},

	main = {
		hierarchies = {
			"main",
		},

		colors = {
			color = {
				default = Color(0, 0, 64, 255),
				order = 1,
			},
		},

		order = 2,
	},

	border = {
		hierarchies = {
			"",
		},

		colors = {
			color_border = {
				default = Color(0, 64, 128, 255),
				order = 1,
			},
		},

		order = 3,
	},

	header = {
		hierarchies = {
			"main/browser/header",
			"main/player/header",
		},

		colors = {
			color = {
				default = Color(0, 100, 0, 255),
				order = 1,
			},

			color_foreground = {
				default = Color(255, 255, 255, 255),
				order = 2,
			},

			color_shadow = {
				default = Color(40, 40, 40, 255),
				order = 99,
			},
		},

		order = 4,
	},

	button = {
		hierarchies = {
			"main/browser/sidebutton",
			"main/browser/list/button",
			"main/browser/error/button",
			"main/browser/list/scrollbar/bar",
			"main/browser/list/scrollbar/button",
			"main/browser/error/textbox/scrollbar/bar",
			"main/browser/error/textbox/scrollbar/button",

			"main/player/button",
			"main/player/controls/button",
			"main/player/controls/progressbar",
			"main/player/spectrum/error/button",
			"main/player/spectrum/error/textbox/scrollbar/bar",
			"main/player/spectrum/error/textbox/scrollbar/button",
		},

		colors = {
			color = {
				default = Color(0, 128, 128, 255),
				order = 1,
			},

			color_foreground = {
				default = Color(255, 255, 255, 255),
				order = 2,
			},

			color_icon = {
				default = Color(255, 255, 255, 255),
				order = 3,
			},


			color_hover = {
				default = Color(150, 150, 150, 255),
				order = 4,
			},

			color_foreground_hover = {
				default = Color(0, 0, 0, 255),
				order = 5,
			},

			color_icon_hover = {
				default = Color(255, 255, 255, 255),
				order = 6,
			},


			color_disabled = {
				default = Color(100, 100, 100, 255),
				order = 7,
			},

			color_foreground_disabled = {
				default = Color(255, 255, 255, 255),
				order = 8,
			},

			color_icon_disabled = {
				default = Color(255, 255, 255, 255),
				order = 9,
			},


			color_shadow = {
				default = Color(40, 40, 40, 255),
				order = 99,
			},
		},

		order = 5,
	},

	error = {
		hierarchies = {
			"main/browser/error/textbox",
			"main/player/spectrum/error/textbox",
		},

		colors = {
			color = {
				default = Color(128, 32, 0, 255),
				order = 1,
			},

			color_foreground = {
				default = Color(255, 255, 255, 255),
				order = 2,
			},

			color_shadow = {
				default = Color(40, 40, 40, 255),
				order = 99,
			},
		},

		order = 6,
	},

	spectrum = {
		hierarchies = {
			"main/player/spectrum",
		},

		colors = {
			color = {
				default = Color(64, 32, 0, 255),
				order = 1,
			},

			color_foreground = {
				default = Color(192, 0, 0, 255),
				order = 2,
			},

			color_icon = {
				default = Color(255, 255, 255, 255),
				order = 3,
			},

			color_shadow = {
				default = Color(40, 40, 40, 255),
				order = 99,
			},
		},

		order = 7,
	},
}

TOOL.SkinVars = {}
local count = 0

for areaname, colvars in SortedPairsByMemberValue(TOOL.SkinColorsVars, "order") do
	local hierarchies = colvars.hierarchies or {}

	for colname, colvar in SortedPairsByMemberValue(colvars.colors or {}, "order") do
		local color = colvar.default or Color(255, 255, 255, 255)
		local varname = areaname .. "_" .. colname

		TOOL.ClientConVar[varname .. "_t"] = "1"
		TOOL.ClientConVar[varname .. "_r"] = color.r
		TOOL.ClientConVar[varname .. "_g"] = color.g
		TOOL.ClientConVar[varname .. "_b"] = color.b
		TOOL.ClientConVar[varname .. "_a"] = color.a

		local order = count + 1
		local skinvar = {}

		skinvar.default = color
		skinvar.hierarchies = hierarchies
		skinvar.areaname = areaname
		skinvar.name = colname
		skinvar.order = order

		TOOL.SkinVars[varname] = skinvar
		count = order
	end
end

if StreamRadioLib and StreamRadioLib.Loaded then
	StreamRadioLib.Tool.RegisterClientToolHook(TOOL, "LeftClick")
	StreamRadioLib.Tool.RegisterClientToolHook(TOOL, "RightClick")
	StreamRadioLib.Tool.RegisterClientToolHook(TOOL, "Reload")
	StreamRadioLib.Tool.RegisterClientToolHook(TOOL, "Holster")

	StreamRadioLib.Tool.AddLocale(TOOL, "name", "Radio Colorer (Global)")
	StreamRadioLib.Tool.AddLocale(TOOL, "desc", "Change colors of radio GUI skins")

	StreamRadioLib.Tool.AddLocale(TOOL, "left", "Apply colors of radio GUI skins")
	StreamRadioLib.Tool.AddLocale(TOOL, "right", "Copy the colors from radio GUI skins")
	StreamRadioLib.Tool.AddLocale(TOOL, "reload", "Reset the skin of the radio to default")

	StreamRadioLib.Tool.AddLocale(TOOL, "list", "List of changeable colors:")
	StreamRadioLib.Tool.AddLocale(TOOL, "color", "Selected color:")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.common.active.desc", "If checked the color will be applied on left click.\nUncheck this if you don't want to change this color on the GUI.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.main_color", "Background")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.main_color.desc", "Color of the main background.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.border_color_border", "Border")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.border_color_border.desc", "Color of the surrounding border.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.header_color", "Header Background")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.header_color_foreground", "Header Text")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.header_color_shadow", "Header Shadow")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.header_color.desc", "Color of the header background.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.header_color_foreground.desc", "Color of the header text.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.header_color_shadow.desc", "Color of the header shadow.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color", "Button Background")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_foreground", "Button Text")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_icon", "Button Icon")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color.desc", "Color of all button backgrounds.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_foreground.desc", "Color of all button texts.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_icon.desc", "Color of all button icons.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_hover", "Button Hover Background")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_foreground_hover", "Button Hover Text")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_icon_hover", "Button Hover Icon")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_hover.desc", "Color of all hovered button backgrounds.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_foreground_hover.desc", "Color of all hovered button texts.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_icon_hover.desc", "Color of all hovered button icons.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_disabled", "Button Disabled Background")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_foreground_disabled", "Button Disabled Text")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_icon_disabled", "Button Disabled Icon")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_disabled.desc", "Color of all disabled button backgrounds.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_foreground_disabled.desc", "Color of all disabled button texts.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_icon_disabled.desc", "Color of all disabled button icons.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_shadow", "Button Shadow")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.button_color_shadow.desc", "Color of all button Shadow.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.error_color", "Error Background")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.error_color_foreground", "Error Text")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.error_color_shadow", "Error Shadow")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.error_color.desc", "Color of the error box background.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.error_color_foreground.desc", "Color of the error box text.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.error_color_shadow.desc", "Color of the error box shadow.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.spectrum_color", "Spectrum Background")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.spectrum_color_foreground", "Spectrum Foreground")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.spectrum_color_icon", "Spectrum Icon")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.spectrum_color_shadow", "Spectrum Shadow")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.spectrum_color.desc", "Color of the spectrum box background.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.spectrum_color_foreground.desc", "Color of the spectrum box foreground.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.spectrum_color_icon.desc", "Color of the spectrum box icons.")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.spectrum_color_shadow.desc", "Color of the spectrum box shadow.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.cursor_color_cursor", "Cursor")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.cursor_color_cursor.desc", "Color of the Cursor.")

	StreamRadioLib.Tool.Setup(TOOL)
else
	TOOL.Information = nil

	if CLIENT then
		local StreamRadioLib = StreamRadioLib or {}
		local _mode = TOOL.Mode

		language.Add("Tool." .. _mode .. ".name", "Radio Colorer (Global)")
		language.Add("Tool." .. _mode .. ".desc", "Change colors of radio GUI skins")
		language.Add("Tool." .. _mode .. ".0", "This tool could not be loaded.")

		function TOOL.BuildCPanel(CPanel)
			if StreamRadioLib.Loader_CreateErrorPanel then
				StreamRadioLib.Loader_CreateErrorPanel(CPanel, "This tool could not be loaded.")
			end
		end
	end
end

function TOOL:IsValid()
	return IsValid(self:GetSWEP())
end

function TOOL:GetColors(forceall)
	local data = {}

	for varname, v in pairs(self.SkinVars) do
		if not forceall then
			local ticked = self:GetClientBool(varname .. "_t")
			if not ticked then continue end
		end

		local r = self:GetClientNumber(varname .. "_r")
		local g = self:GetClientNumber(varname .. "_g")
		local b = self:GetClientNumber(varname .. "_b")
		local a = self:GetClientNumber(varname .. "_a")

		data[varname] = Color(r, g, b, a)
	end

	return data
end

function TOOL:SetColors(data)
	data = data or {}

	for varname, v in pairs(self.SkinVars) do
		local color = data[varname] or v.default or Color(255, 255, 255, 255)

		self:SetClientNumber(varname .. "_r", color.r)
		self:SetClientNumber(varname .. "_g", color.g)
		self:SetClientNumber(varname .. "_b", color.b)
		self:SetClientNumber(varname .. "_a", color.a)
	end
end

function TOOL:AddModeList( panel )
	local listpanel = vgui.Create( "DListView" )
	panel:AddPanel(listpanel)

	listpanel:SetMultiSelect(false)

	local col1 = listpanel:AddColumn("No.")
	listpanel:AddColumn("Item")
	local col3 = listpanel:AddColumn("Color")
	local col4 = listpanel:AddColumn("Active")

	col1:SetFixedWidth(30)
	col3:SetMinWidth(40)
	col3:SetMaxWidth(70)
	col4:SetFixedWidth(40)

	local lines = {}

	listpanel.NextConVarCheck = 0

	local update = function()
		if not IsValid(self) then return end
		if not IsValid(listpanel) then return end

		local data = self:GetColors(true)
		local changed = false

		if input.IsMouseDown(MOUSE_LEFT) then return end
		if listpanel.NextConVarCheck > RealTime() then return end

		listpanel.NextConVarCheck = RealTime() + 0.2

		for varname, line in pairs(lines) do
			if not self.SkinVars[varname] then continue end
			if not IsValid(line) then continue end

			local colortile = line.Columns[line._colorindex]
			if not IsValid(colortile) then continue end

			local activecheckbox = line.Columns[line._activeindex]
			if not IsValid(activecheckbox) then continue end

			local color = data[varname]
			if not color then continue end

			local oldcolor = colortile:GetColor()
			if color == oldcolor then continue end

			colortile:SetColor(color)
			line:SetSortValue(line._colorindex, tostring(color))
			changed = true
		end

		if changed and listpanel.OnColorUpdate then
			listpanel:OnColorUpdate(data)
		end
	end

	local data = self:GetColors(true)

	for varname, color in pairs(data) do
		local colortile = vgui.Create( "DColorButton" )
		local activecheckbox = vgui.Create( "DCheckBoxLabel" )
		if not self.SkinVars[varname] then continue end

		activecheckbox:SetText("")
		activecheckbox:SetConVar(self.Mode .. "_" .. varname  .. "_t")
		activecheckbox:SetIndent(12)
		activecheckbox:SetTooltip(StreamRadioLib.Tool.GetLocaleTranslation(self, "list.common.active.desc"))

		local order = self.SkinVars[varname].order or 0

		local line = listpanel:AddLine(order, StreamRadioLib.Tool.GetLocaleTranslation(self, "list." .. varname), colortile, activecheckbox)
		colortile.DoClick = function()
			listpanel:ClearSelection()
			listpanel:SelectItem(line)
		end

		line:SetTooltip(StreamRadioLib.Tool.GetLocaleTranslation(self, "list." .. varname .. ".desc"))
		line:SetSortValue(1, order)

		line._colorindex = 3
		line._activeindex = 4

		activecheckbox.OnChange = function(this, value)
			local sort = value and 1 or 0
			sort = sort * 1000 - order

			line:SetSortValue(line._activeindex, sort)
		end

		line._varname = varname
		lines[varname] = line
	end

	listpanel:SetTall(230)
	listpanel:SortByColumn(1)

	listpanel.Think = function()
		update()
	end

	update()

	return listpanel
end


function TOOL:BuildToolPanel( CPanel )
	self:AddLabel(CPanel, "list")

	local listpanel = self:AddModeList(CPanel)
	local colorpanel = nil
	local selectedline = nil

	listpanel.OnRowSelected = function(this, LineID, Line)
		selectedline = Line
		if not IsValid(selectedline) then return end
		if not IsValid(colorpanel) then return end
		if not selectedline._varname then return end

		local precmd = self.Mode .. "_" .. selectedline._varname

		colorpanel:SetConVarR(precmd .. "_r")
		colorpanel:SetConVarG(precmd .. "_g")
		colorpanel:SetConVarB(precmd .. "_b")
		colorpanel:SetConVarA(precmd .. "_a")
		colorpanel.txtA:SetConVar(precmd .. "_a")

		local colortile = selectedline.Columns[selectedline._colorindex]
		if not IsValid(colortile) then return end
		colorpanel:SetColor(colortile:GetColor())
	end

	listpanel.DoDoubleClick = function(this, LineID, Line)
		if not IsValid(Line) then return end
		if not IsValid(colorpanel) then return end

		local activecheckbox = selectedline.Columns[selectedline._activeindex]
		if not IsValid(activecheckbox) then return end
		activecheckbox:Toggle()
	end

	listpanel.OnColorUpdate = function(this, data)
		this:OnRowSelected(selectedline:GetID(), selectedline)
	end

	self:AddLabel(CPanel, "color")
	colorpanel = self:AddColorMixer(CPanel)

	listpanel:SelectFirstItem()
end

function TOOL:GetAimedGui(trace)
	if not self.ToolLibLoaded then return end

	trace = trace or self:GetFallbackTrace()

	if not trace then return end
	if not trace.Hit then return end

	local ent = trace.Entity

	if not self:IsValidGUIRadio(ent) then return end

	local entgui = ent:GetGUI()
	if not IsValid(entgui) then return end

	return entgui, ent
end

function TOOL:LeftClick(trace)
	if not self.ToolLibLoaded then return end

	local entgui = self:GetAimedGui(trace)
	if not IsValid(entgui) then return false end

	if CLIENT then return true end

	StreamRadioLib.Tool.CallClientToolHook(self, "LeftClick")
	return true
end

function TOOL:RightClick(trace)
	if not self.ToolLibLoaded then return end

	local entgui = self:GetAimedGui(trace)
	if not IsValid(entgui) then return false end

	if CLIENT then return true end

	StreamRadioLib.Tool.CallClientToolHook(self, "RightClick")
	return true
end

function TOOL:LeftClickClient()
	if not self.ToolLibLoaded then return end

	local entgui = self:GetAimedGui()
	if not IsValid(entgui) then return end

	local data = self:GetColors()

	for varname, color in pairs(data) do
		local skinvar = self.SkinVars[varname] or {}
		local hierarchies = skinvar.hierarchies or {}
		local hrvarname = skinvar.name

		for _, skinhierarchy in pairs(hierarchies) do
			entgui:SetSkinPropertyOnServer(skinhierarchy, hrvarname, color)
		end
	end
end

function TOOL:RightClickClient()
	if not self.ToolLibLoaded then return end

	local entgui = self:GetAimedGui()
	if not IsValid(entgui) then return end

	local skindata = {}

	for varname, skinvar in pairs(self.SkinVars) do
		local hierarchies = skinvar.hierarchies or {}
		local hrvarname = skinvar.name
		local value = nil

		for _, skinhierarchy in pairs(hierarchies) do
			local panels = entgui:GetPanelsBySkinIdentifyer(skinhierarchy)

			for _, panel in pairs(panels) do
				if not IsValid(panel) then continue end
				value = panel:GetSkinValue(hrvarname)

				if value then break end
			end

			if value then break end
		end

		skindata[varname] = value
	end

	self:SetColors(skindata)
end

function TOOL:Reload(trace)
	if not self.ToolLibLoaded then return end

	local entgui = self:GetAimedGui()
	if not IsValid(entgui) then return false end

	if CLIENT then return true end

	StreamRadioLib.Tool.CallClientToolHook(self, "Reload")
	return true
end

function TOOL:ReloadClient()
	if not self.ToolLibLoaded then return end

	local entgui = self:GetAimedGui()
	if not IsValid(entgui) then return end

	entgui:SetSkinOnServer(StreamRadioLib.Skin.GetDefaultSkin(), false)
end

function TOOL:Holster()
	if not self.ToolLibLoaded then return end

	self:Clear()
	StreamRadioLib.Tool.CallClientToolHook(self, "Holster")
end

function TOOL:HolsterClient()
	if not self.ToolLibLoaded then return end
	self:Clear()
end

function TOOL:Clear()

end

function TOOL:Think()
	if SERVER then return end
end
