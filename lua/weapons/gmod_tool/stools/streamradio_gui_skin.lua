TOOL.Category = "Stream Radio"
TOOL.Name = "#Tool." .. TOOL.Mode .. ".name"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
}

if StreamRadioLib and StreamRadioLib.Loaded then
	StreamRadioLib.Tool.RegisterClientToolHook(TOOL, "LeftClick")
	StreamRadioLib.Tool.RegisterClientToolHook(TOOL, "RightClick")
	StreamRadioLib.Tool.RegisterClientToolHook(TOOL, "Reload")
	StreamRadioLib.Tool.RegisterClientToolHook(TOOL, "Deploy")

	StreamRadioLib.Tool.AddLocale(TOOL, "name", "Radio Skin Duplicator")
	StreamRadioLib.Tool.AddLocale(TOOL, "desc", "Change, Copy or Save the skin of radios")

	StreamRadioLib.Tool.AddLocale(TOOL, "left", "Apply skin to the radio")
	StreamRadioLib.Tool.AddLocale(TOOL, "right", "Copy skin from the radio")
	StreamRadioLib.Tool.AddLocale(TOOL, "reload", "Reset the skin to default")

	StreamRadioLib.Tool.AddLocale(TOOL, "list", "List of saved skins:")

	StreamRadioLib.Tool.AddLocale(TOOL, "file.text.desc", "Enter the name of your skin here.\nPress 'Save' to save it to your hard disk.")

	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.delete", "Delete")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.delete.desc", "Delete the selected skin file from your hard disk.")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.delete.error.empty", "You need to enter or select something to delete.")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.delete.error.notfound", "The skin file does not exist.")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.delete.error.protected", "The skin file is protected and can not be deleted.")

	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.save", "Save")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.save.desc", "Save skin to the filename as given above to your hard disk.")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.save.error.protected", "The skin file is protected and can not be overwritten.")

	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.open", "Open")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.open.desc", "Open selected skin file.\nYou can also double click on the file to open it.")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.open.error.empty", "You need to enter or select something to open.")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.button.open.error.notfound", "The skin file does not exist.")

	StreamRadioLib.Tool.AddLocale(TOOL, "file.delete", "Delete skin?")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.delete.desc", "Do you want to delete this skin file from your hard disk?")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.delete.yes", "Yes, delete it.")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.delete.no", "No, don't delete it.")

	StreamRadioLib.Tool.AddLocale(TOOL, "file.save", "Overwrite skin?")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.save.desc", "Do you want to overwrite this skin file?")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.save.yes", "Yes, overwrite it.")
	StreamRadioLib.Tool.AddLocale(TOOL, "file.save.no", "No, don't overwrite it.")

	StreamRadioLib.Tool.Setup(TOOL)
else
	TOOL.Information = nil

	if CLIENT then
		local StreamRadioLib = StreamRadioLib or {}
		local _mode = TOOL.Mode

		language.Add("Tool." .. _mode .. ".name", "Radio Skin Duplicator")
		language.Add("Tool." .. _mode .. ".desc", "Change, Copy or Save the skin of radios")
		language.Add("Tool." .. _mode .. ".0", "This tool could not be loaded.")

		function TOOL.BuildCPanel(CPanel)
			if StreamRadioLib.Loader_CreateErrorPanel then
				StreamRadioLib.Loader_CreateErrorPanel(CPanel, "This tool could not be loaded.")
			end
		end
	end
end

local function getnewname()
	local newnamebase = "newskin"
	local newname = newnamebase
	local count = 2

	while true do
		if not StreamRadioLib.Skin.IsValidSkinFile(newname) then
			return newname
		end

		if count >= 100 then
			return ""
		end

		newname = newnamebase .. count
		count = count + 1
	end
end

function TOOL:IsValid()
	return IsValid(self:GetSWEP())
end

function TOOL:AddSkinList( panel )
	local listpanel = vgui.Create( "DListView" )
	panel:AddPanel(listpanel)

	listpanel:SetMultiSelect(false)

	local col1 = listpanel:AddColumn("No.")
	listpanel:AddColumn("Name")
	local col3 = listpanel:AddColumn("Open")

	col1:SetFixedWidth(30)
	col3:SetFixedWidth(40)

	listpanel:SetTall(200)
	listpanel:SortByColumn(1)
	return listpanel
end

function TOOL:AddFileControlPanel( panel )
	local bgpanel = vgui.Create( "DPanel" )
	panel:AddPanel(bgpanel)

	bgpanel:SetPaintBackground(false)

	local buttonpanel = vgui.Create( "DPanel", bgpanel)
	buttonpanel:Dock(BOTTOM)
	buttonpanel:SetPaintBackground(false)
	buttonpanel:SetHeight(25)

	local buttondelete = vgui.Create( "DButton", buttonpanel)
	buttondelete:Dock(LEFT)
	buttondelete:SetText(StreamRadioLib.Tool.GetLocale(self, "file.button.delete"))
	buttondelete:SetWide(70)
	buttondelete:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.delete.desc"))

	local buttonsave = vgui.Create( "DButton", buttonpanel)
	buttonsave:Dock(RIGHT)
	buttonsave:SetText(StreamRadioLib.Tool.GetLocale(self, "file.button.save"))
	buttonsave:SetWide(70)
	buttonsave:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.save.desc"))

	local buttonopen = vgui.Create( "DButton", buttonpanel)
	buttonopen:Dock(FILL)
	buttonopen:DockMargin(5, 0, 5, 0)
	buttonopen:SetText(StreamRadioLib.Tool.GetLocale(self, "file.button.open"))
	buttonopen:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.open.desc"))

	local text = vgui.Create( "DTextEntry", bgpanel)
	text:DockMargin(0, 0, 0, 5)
	text:Dock(FILL)

	text:SetHistoryEnabled(false)
	text:SetAllowNonAsciiCharacters(false)
	text:SetEnterAllowed(true)
	text:SetMultiline(false)
	text:SetUpdateOnType(true)
	text:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.text.desc"))

	bgpanel:SetHeight(55)

	local deletefile = function(name)
		local ok = StreamRadioLib.Skin.Delete(name)

		if bgpanel.OnDeleted then
			bgpanel:OnDeleted(name, ok)
		end
	end

	local openfile = function(name)
		local data = StreamRadioLib.Skin.Open(name)
		local ok = true

		if not data then
			ok = false
		else
			self:SetSkin(data)
		end

		if bgpanel.OnOpened then
			bgpanel:OnOpened(name, ok)
		end
	end

	local savefile = function(name)
		local data = self:GetSkin()
		local ok = StreamRadioLib.Skin.Save(name, data)

		if bgpanel.OnSaved then
			bgpanel:OnSaved(name, ok)
		end
	end

	local checkfile = function(filename)
		filename = StreamRadioLib.Skin.SanitizeName(filename)

		buttondelete:SetEnabled(true)
		buttonopen:SetEnabled(true)
		buttonsave:SetEnabled(true)

		buttondelete:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.delete.desc"))
		buttonopen:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.open.desc"))
		buttonsave:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.save.desc"))

		if filename == "" then
			buttondelete:SetEnabled(false)
			buttonopen:SetEnabled(false)

			buttondelete:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.delete.error.empty"))
			buttonopen:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.open.error.empty"))

			return
		end

		if not StreamRadioLib.Skin.IsValidSkinFile(filename) then
			buttondelete:SetEnabled(false)
			buttonopen:SetEnabled(false)

			buttondelete:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.delete.error.notfound"))
			buttonopen:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.open.error.notfound"))
		end

		if filename == "default" then
			buttondelete:SetEnabled(false)
			buttonsave:SetEnabled(false)

			buttondelete:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.delete.error.protected"))
			buttonsave:SetTooltip(StreamRadioLib.Tool.GetLocale(self, "file.button.save.error.protected"))
		end
	end

	text.OnValueChange = function(this, value)
		checkfile(value)
	end

	bgpanel.SetFile = function(this, filename)
		if not IsValid(text) then return end

		local filename = StreamRadioLib.Skin.SanitizeName(filename)

		if filename == "" then
			filename = getnewname()
		end

		checkfile(filename)
		text:SetText(filename)
	end

	bgpanel.GetFile = function(this)
		if not IsValid(text) then return end

		local name = StreamRadioLib.Skin.SanitizeName(text:GetText())
		return name
	end

	bgpanel.OpenFile = function()
		if not IsValid(self) then return end
		if not IsValid(text) then return end
		if not IsValid(bgpanel) then return end

		local name = bgpanel:GetFile()
		checkfile(name)

		openfile(name)
	end

	buttondelete.DoClick = function()
		if not IsValid(self) then return end
		if not IsValid(text) then return end
		if not IsValid(bgpanel) then return end

		local name = bgpanel:GetFile()
		checkfile(name)

		Derma_Query(
			StreamRadioLib.Tool.GetLocaleTranslation(self, "file.delete.desc"),
			StreamRadioLib.Tool.GetLocaleTranslation(self, "file.delete"),
			StreamRadioLib.Tool.GetLocaleTranslation(self, "file.delete.yes"),
			function()
				if not IsValid(self) then return end
				if not IsValid(panel) then return end
				if not IsValid(text) then return end
				if not IsValid(bgpanel) then return end

				deletefile(name)
			end,
			StreamRadioLib.Tool.GetLocaleTranslation(self, "file.delete.no")
		)
	end

	buttonopen.DoClick = function()
		bgpanel:OpenFile()
	end

	buttonsave.DoClick = function()
		if not IsValid(self) then return end
		if not IsValid(text) then return end
		if not IsValid(bgpanel) then return end

		local name = bgpanel:GetFile()
		checkfile(name)

		if name == "" then
			name = getnewname()
		end

		if StreamRadioLib.Skin.IsValidSkinFile(name) then
			Derma_Query(
				StreamRadioLib.Tool.GetLocaleTranslation(self, "file.save.desc"),
				StreamRadioLib.Tool.GetLocaleTranslation(self, "file.save"),
				StreamRadioLib.Tool.GetLocaleTranslation(self, "file.save.yes"),
				function()
					if not IsValid(self) then return end
					if not IsValid(panel) then return end
					if not IsValid(text) then return end
					if not IsValid(bgpanel) then return end

					savefile(name)
				end,
				StreamRadioLib.Tool.GetLocaleTranslation(self, "file.save.no")
			)

			return
		end

		savefile(name)
	end

	return bgpanel
end

function TOOL:RefreshList()
	if not IsValid(self.filelistpanel) then return end

	local skinlist = StreamRadioLib.Skin.GetList()

	self.filelistpanel:Clear()
	self.filelistpanel._filemap = {}

	for i, name in ipairs(skinlist) do
		if IsValid(self.filelistpanel._filemap[name]) then
			continue
		end

		local line = self.filelistpanel:AddLine(i, name, "")
		line:SetSortValue(1, i)
		line:SetSortValue(3, 0)

		self.filelistpanel._filemap[name] = line
	end

	if not IsValid(self.filecontrolpanel) then return end
	timer.Simple(0.1, function()
		if not IsValid(self) then return end
		if not IsValid(self.filecontrolpanel) then return end

		self:MakeFileAsOpen(self.OpenName)
	end)
end


function TOOL:MakeFileAsOpen(name)
	name = StreamRadioLib.Skin.SanitizeName(name)

	if IsValid(self.filecontrolpanel) and name ~= "" then
		self.filecontrolpanel:SetFile(name)
	end

	self.OpenName = name

	if not IsValid(self.filelistpanel) then return end
	if not self.filelistpanel._filemap then return end

	local openline = self.filelistpanel._filemap[name]
	if not IsValid(openline) then return end

	if IsValid(self._oldopenline) then
		self._oldopenline:SetColumnText(3, "")
		self._oldopenline:SetSortValue(3, 0)

		local column = self._oldopenline.Columns[3]
		if IsValid(column) then
			column:SetColor(Color(0, 0, 0, 255))
			column:SetBGColor(Color(255, 255, 255, 255))
			column:SetPaintBackgroundEnabled(true)
		end
	end

	openline:SetColumnText(3, "Open")
	openline:SetSortValue(3, 1)

	local column = openline.Columns[3]
	if IsValid(column) then
		column:SetColor(Color(0, 0, 0, 255))
		column:SetBGColor(Color(0, 192, 0, 255))
		column:SetPaintBackgroundEnabled(true)
	end

	self._oldopenline = openline

	self.filelistpanel:ClearSelection()
	self.filelistpanel:SelectItem(openline)
end

function TOOL:BuildToolPanel( CPanel )
	self:AddLabel(CPanel, "list")

	self.filelistpanel = self:AddSkinList(CPanel)
	local listpanel = self.filelistpanel
	local filepanel = nil

	listpanel.OnRowSelected = function(this, LineID, Line)
		if not IsValid(Line) then return end
		if not IsValid(filepanel) then return end

		local name = Line:GetColumnText(2)
		filepanel:SetFile(name)
	end

	listpanel.DoDoubleClick = function(this, LineID, Line)
		if not IsValid(Line) then return end
		if not IsValid(filepanel) then return end

		local name = Line:GetColumnText(2)
		filepanel:SetFile(name)
		filepanel:OpenFile()
	end

	listpanel:SelectFirstItem()

	self.filecontrolpanel = self:AddFileControlPanel(CPanel)
	filepanel = self.filecontrolpanel

	filepanel.OnOpened = function(this, name, ok)
		if not ok then return end
		self:MakeFileAsOpen(name)
	end

	filepanel.OnDeleted = function(this, name, ok)
		if not ok then
			return
		end

		self:RefreshList()
	end

	filepanel.OnSaved = function(this, name, ok)
		if not ok then
			return
		end

		local data = StreamRadioLib.Skin.Open(name)

		if not data then
			return
		end

		self:SetSkin(data)
		self:RefreshList()
	end

	self:RefreshList()

	filepanel:SetFile("default")
	filepanel:OpenFile()

	self.filelistpanel:SelectFirstItem()
end

function TOOL:SetSkin(skindata)
	self.skin = table.Copy(skindata or {})

	local name = StreamRadioLib.Skin.SanitizeName(self.skin.name)

	if name == "" then
		name = getnewname()
	end

	self:MakeFileAsOpen(name)
end

function TOOL:GetSkin()
	return self.skin or StreamRadioLib.Skin.GetDefaultSkin()
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

function TOOL:LeftClickClient()
	if not self.ToolLibLoaded then return end
	local entgui = self:GetAimedGui()
	if not IsValid(entgui) then return false end

	entgui:SetSkinOnServer(self:GetSkin(), false)
end

function TOOL:RightClick(trace)
	if not self.ToolLibLoaded then return end
	local entgui = self:GetAimedGui(trace)
	if not IsValid(entgui) then return false end

	if CLIENT then return true end

	StreamRadioLib.Tool.CallClientToolHook(self, "RightClick")
	return true
end

function TOOL:RightClickClient()
	if not self.ToolLibLoaded then return end
	local entgui = self:GetAimedGui()
	if not IsValid(entgui) then return false end

	self:SetSkin(entgui:GetSkin())
end

function TOOL:Reload(trace)
	if not self.ToolLibLoaded then return end
	local entgui = self:GetAimedGui(trace)
	if not IsValid(entgui) then return false end

	if CLIENT then return true end

	StreamRadioLib.Tool.CallClientToolHook(self, "Reload")
	return true
end

function TOOL:ReloadClient()
	if not self.ToolLibLoaded then return end
	local entgui = self:GetAimedGui()
	if not IsValid(entgui) then return false end

	entgui:SetSkinOnServer(StreamRadioLib.Skin.GetDefaultSkin(), false)
end

function TOOL:Deploy()
	if not self.ToolLibLoaded then return end
	StreamRadioLib.Tool.CallClientToolHook(self, "Deploy")
end

function TOOL:DeployClient()
	if not self.ToolLibLoaded then return end
	self:RefreshList()
end
