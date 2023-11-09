TOOL.Category = "Stream Radio"
TOOL.Name = "#Tool." .. TOOL.Mode .. ".name"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
}

TOOL.SkinVars = {
	color = {
		default = Color(255, 255, 255, 255),
		order = 1,
	},

	color_foreground = {
		default = Color(0, 0, 0, 255),
		order = 2,
	},

	color_icon = {
		default = Color(255, 255, 255, 255),
		order = 3,
	},

	color_shadow = {
		default = Color(64, 64, 64, 255),
		order = 4,
	},

	color_hover = {
		default = Color(192, 192, 192, 255),
		order = 5,
	},

	color_foreground_hover = {
		default = Color(0, 0, 0, 255),
		order = 6,
	},

	color_icon_hover = {
		default = Color(255, 255, 255, 255),
		order = 7,
	},

	color_disabled = {
		default = Color(128, 128, 128, 255),
		order = 8,
	},

	color_foreground_disabled = {
		default = Color(255, 255, 255, 255),
		order = 9,
	},

	color_icon_disabled = {
		default = Color(255, 255, 255, 255),
		order = 10,
	},
}

for varname, v in pairs(TOOL.SkinVars) do
	local color = v.default or Color(255, 255, 255, 255)

	TOOL.ClientConVar[varname .. "_t"] = "1"
	TOOL.ClientConVar[varname .. "_r"] = color.r
	TOOL.ClientConVar[varname .. "_g"] = color.g
	TOOL.ClientConVar[varname .. "_b"] = color.b
	TOOL.ClientConVar[varname .. "_a"] = color.a
end

if StreamRadioLib and StreamRadioLib.Loaded then
	StreamRadioLib.Tool.RegisterClientToolHook(TOOL, "LeftClick")
	StreamRadioLib.Tool.RegisterClientToolHook(TOOL, "RightClick")
	StreamRadioLib.Tool.RegisterClientToolHook(TOOL, "Holster")

	StreamRadioLib.Tool.AddLocale(TOOL, "name", "Radio Colorer (Individual)")
	StreamRadioLib.Tool.AddLocale(TOOL, "desc", "Change colors of aimed radio GUI panels")

	StreamRadioLib.Tool.AddLocale(TOOL, "left", "Apply colors of radio GUI panels")
	StreamRadioLib.Tool.AddLocale(TOOL, "right", "Copy the colors from radio GUI panels")

	StreamRadioLib.Tool.AddLocale(TOOL, "list", "List of changeable colors:")
	StreamRadioLib.Tool.AddLocale(TOOL, "color", "Selected color:")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.common.active.desc", "If checked the color will be applied on left click.\nUncheck this if you don't want to change this color on a panel.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.color", "Background")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.color.desc", "Color of the background.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_foreground", "Foreground/Text")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_foreground.desc", "Color of the foreground such as texts or spectrum bars.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_icon", "Icon")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_icon.desc", "Color of the icons.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_shadow", "Shadow")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_shadow.desc", "Color of the shadow.")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_hover", "[Button only] Hover Background")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_hover.desc", "Color of the background when hovered. (Button only)")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_foreground_hover", "[Button only] Hover Foreground/Text")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_foreground_hover.desc", "Color of the foreground when hovered. (Button only)")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_icon_hover", "[Button only] Hover Icon")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_icon_hover.desc", "Color of the icon when hovered. (Button only)")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_disabled", "[Button only] Disabled Background")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_disabled.desc", "Color of the background when disabled. (Button only)")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_foreground_disabled", "[Button only] Disabled Foreground/Text")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_foreground_disabled.desc", "Color of the foreground when disabled. (Button only)")

	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_icon_disabled", "[Button only] Disabled Icon")
	StreamRadioLib.Tool.AddLocale(TOOL, "list.color_icon_disabled.desc", "Color of the icon when disabled. (Button only)")

	StreamRadioLib.Tool.Setup(TOOL)
else
	TOOL.Information = nil

	if CLIENT then
		local StreamRadioLib = StreamRadioLib or {}
		local _mode = TOOL.Mode

		language.Add("Tool." .. _mode .. ".name", "Radio Colorer (Individual)")
		language.Add("Tool." .. _mode .. ".desc", "Change colors of aimed radio GUI panels")
		language.Add("Tool." .. _mode .. ".0", "This tool could not be loaded.")

		function TOOL.BuildCPanel(CPanel)
			if StreamRadioLib.Loader_CreateErrorPanel then
				StreamRadioLib.Loader_CreateErrorPanel(CPanel, "This tool could not be loaded.")
			end
		end
	end
end

function TOOL:IsValid()
	return IsValid(self:GetSWEP()) and IsValid(self:GetOwner())
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

		if ( input.IsMouseDown( MOUSE_LEFT ) ) then return end
		if ( listpanel.NextConVarCheck > RealTime() ) then return end

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

function TOOL:HighlightHoverPanels(entgui, panels)
	if SERVER then return nil end

	if not IsValid(entgui._ToolHoverHighlighter) then
		entgui._ToolHoverHighlighter = entgui:AddPanelByClassname("highlighter")
		entgui._ToolHoverHighlighter:SetColor(Color(0, 0, 0, 0))
		entgui._ToolHoverHighlighter:SetBorderColor(Color(255, 255, 0, 255))
		entgui._ToolHoverHighlighter:SetBorderColor2(Color(0, 0, 0, 255))
		entgui._ToolHoverHighlighter:SetZPos(9999000)
	end

	if IsValid(self.highlighter_hover) then
		if self.highlighter_hover ~= entgui._ToolHoverHighlighter then
			self.highlighter_hover:Remove()
		end
	end

	local highlighter_hover = entgui._ToolHoverHighlighter
	self.highlighter_hover = highlighter_hover

	if not IsValid(highlighter_hover) then
		return nil
	end

	highlighter_hover:HighlightClear()
	highlighter_hover:HighlightPanels(panels)
	highlighter_hover:Open()

	return highlighter_hover
end

function TOOL:GetTopMostPanel(panels)
	local area = nil
	local panel = nil

	for i, v in ipairs(panels or {}) do
		if not IsValid(v) then continue end
		if not v:IsSkinAble() then continue end

		local w, h = v:GetSize()
		local a = w * h

		if not area or area >= a then
			area = a
			panel = v
		end
	end

	return panel
end

function TOOL:GetAimedObject(trace)
	if not self.ToolLibLoaded then return end

	trace = trace or self:GetFallbackTrace()

	if not trace then return end
	if not trace.Hit then return end

	local ent = trace.Entity
	local owner = self:GetOwner()

	if not self:IsValidGUIRadio(ent) then return end

	local hit, x, y = ent:GetCursor( owner, trace )
	if not hit then return end

	local entgui = ent:GetGUI()
	if not IsValid(entgui) then return end

	local aimedpanel = self:GetTopMostPanel(entgui:GetPanelsAtPos(x, y))
	if not IsValid(aimedpanel) then return end

	return aimedpanel, entgui, ent
end

function TOOL:GetSelectionPanels(entgui, aimedpanel)
	if not self.ToolLibLoaded then return end
	local skinhierarchy = aimedpanel:GetSkinIdentifyerHierarchy()
	local selectedpanels = entgui:GetPanelsBySkinIdentifyer(skinhierarchy)

	return selectedpanels
end

function TOOL:LeftClick(trace)
	if not self.ToolLibLoaded then return end
	local aimedpanel = self:GetAimedObject(trace)
	if not IsValid(aimedpanel) then return false end

	if CLIENT then return true end

	StreamRadioLib.Tool.CallClientToolHook(self, "LeftClick")
	return true
end

function TOOL:RightClick(trace)
	if not self.ToolLibLoaded then return end
	local aimedpanel = self:GetAimedObject(trace)
	if not IsValid(aimedpanel) then return false end

	if CLIENT then return true end

	StreamRadioLib.Tool.CallClientToolHook(self, "RightClick")
	return true
end

function TOOL:LeftClickClient()
	if not self.ToolLibLoaded then return end
	local aimedpanel, entgui = self:GetAimedObject()
	if not IsValid(aimedpanel) then return end

	local skinhierarchy = aimedpanel:GetSkinIdentifyerHierarchy()
	if not skinhierarchy then return false end

	local data = self:GetColors()

	for varname, color in pairs(data) do
		local global = self.SkinVars[varname].global

		if global then
			entgui:SetSkinPropertyOnServer("", varname, color)
			continue
		end

		entgui:SetSkinPropertyOnServer(skinhierarchy, varname, color)
	end
end

function TOOL:RightClickClient()
	if not self.ToolLibLoaded then return end
	local aimedpanel, entgui = self:GetAimedObject()
	if not IsValid(aimedpanel) then return end

	local skindata = aimedpanel:GetSkinValues() or {}

	for varname, v in pairs(self.SkinVars) do
		if not v.global then continue end
		skindata[varname] = entgui:GetSkinValue(varname)
	end

	self:SetColors(skindata)
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
	if IsValid(self.highlighter_hover) then
		self.highlighter_hover:Remove()
	end
end

function TOOL:Think()
	if not self.ToolLibLoaded then return end
	if SERVER then return end

	local aimedpanel, entgui = self:GetAimedObject()
	if not IsValid(aimedpanel) then
		if IsValid(self.highlighter_hover) then
			self.highlighter_hover:Remove()
			self._oldthink_aimedpanel = nil
		end
		return
	end

	if self._oldthink_aimedpanel == aimedpanel then return end
	self._oldthink_aimedpanel = aimedpanel

	local selectedpanels = self:GetSelectionPanels(entgui, aimedpanel)
	self:HighlightHoverPanels(entgui, selectedpanels)
end
