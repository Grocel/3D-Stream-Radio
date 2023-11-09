local StreamRadioLib = StreamRadioLib
local LIBNet = StreamRadioLib.Net

local string = string
local math = math
local table = table
local vgui = vgui
local net = net

local IsValid = IsValid
local unpack = unpack
local Derma_Query = Derma_Query
local Derma_StringRequest = Derma_StringRequest
local isstring = isstring
local pairs = pairs
local ipairs = ipairs
local PANEL = {}

AccessorFunc( PANEL, "m_bUnsaved", "Unsaved" ) -- edited list file Saved?
AccessorFunc( PANEL, "m_bSaving", "Saving" ) -- edited list file Saved?
AccessorFunc( PANEL, "m_strPath", "Path" ) -- List file

local OK_CODES = {
	[StreamRadioLib.EDITOR_ERROR_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_WRITE_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_READ_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_FILES_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_DIR_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_DEL_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_COPY_OK] = true,
	[StreamRadioLib.EDITOR_ERROR_RENAME_OK] = true,
}

local WRITE_ERRORS = {
	[StreamRadioLib.EDITOR_ERROR_WPATH] = true,
	[StreamRadioLib.EDITOR_ERROR_WDATA] = true,
	[StreamRadioLib.EDITOR_ERROR_WVIRTUAL] = true,
	[StreamRadioLib.EDITOR_ERROR_WFORMAT] = true,
	[StreamRadioLib.EDITOR_ERROR_WRITE] = true,
	[StreamRadioLib.EDITOR_ERROR_COMMUNITY_PROTECTED] = true,
	[StreamRadioLib.EDITOR_ERROR_VIRTUAL_PROTECTED] = true,
}

local READ_ERRORS = {
	[StreamRadioLib.EDITOR_ERROR_RPATH] = true,
	[StreamRadioLib.EDITOR_ERROR_RDATA] = true,
	[StreamRadioLib.EDITOR_ERROR_RFORMAT] = true,
	[StreamRadioLib.EDITOR_ERROR_READ] = true,
}

local DIR_ERRORS = {
	[StreamRadioLib.EDITOR_ERROR_DIR_WRITE] = true,
	[StreamRadioLib.EDITOR_ERROR_DIR_EXIST] = true,
}

local COPY_ERRORS = {
	[StreamRadioLib.EDITOR_ERROR_COPY_DIR] = true,
	[StreamRadioLib.EDITOR_ERROR_COPY_EXIST] = true,
	[StreamRadioLib.EDITOR_ERROR_COPY_WRITE] = true,
	[StreamRadioLib.EDITOR_ERROR_COPY_READ] = true,
}

local RENAME_ERRORS = {
	[StreamRadioLib.EDITOR_ERROR_RENAME_DIR] = true,
	[StreamRadioLib.EDITOR_ERROR_RENAME_EXIST] = true,
	[StreamRadioLib.EDITOR_ERROR_RENAME_WRITE] = true,
	[StreamRadioLib.EDITOR_ERROR_RENAME_READ] = true,
}

local function ShowError( errorheader, errortext, this, func, ... )
	if not IsValid(this) then return false end
	if not this:IsVisible() then return false end
	local args = {...}

	Derma_Query( errortext, errorheader, "OK", function( )
		if not IsValid(this) then return end
		if this:IsLoading() then return end
		if not func then return end

		func(this, unpack(args))
	end)

	return true
end

--Ask for save: Opens a confirmation box.
local function AsForSave( this, func, ... )
	if not IsValid(this) then return false end
	if not this:IsVisible() then return false end
	if not func then return false end

	if not this.m_bUnsaved then
		func( this, ... )
		return true
	end

	local args = {...}

	Derma_Query("Are you sure to discard the changes?", "Unsaved playlist!", "Yes", function()
		-- Discard the changes.
		if not IsValid(this) then return end
		if this:IsLoading() then return end

		this:RemoveNewFile()
		func( this, unpack( args ) )
	end, "No")

	-- Don't discard the changes.
	return true
end

local function CreateDir( self, defaultString, func, ... )
	if not IsValid(self) then return false end
	if not self:IsVisible() then return false end

	local args = {...}
	local path = self.m_strPath or ""
	local name = "new_folder"

	defaultString = string.Trim(defaultString or "")

	if not StreamRadioLib.String.IsValidFilepath(defaultString) then
		defaultString = name
	end

	local helpText = [[
Create a new folder
- All invalid characters are fitered out
- Case insensitive, converted to lowercase
]];

	helpText = string.Trim(helpText)

	Derma_StringRequest("New folder", helpText, defaultString, function( strTextOut )
		if not IsValid(self) then return end
		if self:IsLoading() then return end

		strTextOut = StreamRadioLib.String.SanitizeFilename(strTextOut)

		if not StreamRadioLib.String.IsValidFilepath(strTextOut) then
			CreateDir(self, defaultString, func, unpack(args))
			return
		end

		local fullpath = path .. "/" .. strTextOut
		fullpath = string.Trim(fullpath, "/")

		if StreamRadioLib.String.IsVirtualPath(fullpath) then
			local ErrorText = StreamRadioLib.DecodeEditorErrorCode( StreamRadioLib.EDITOR_ERROR_VIRTUAL_PROTECTED )
			ShowError( "Create error!", ErrorText, self, CreateFile, strTextOut, func, unpack( args ) )

			return
		end

		if self.FileItems[strTextOut] then
			local ErrorText = StreamRadioLib.DecodeEditorErrorCode( StreamRadioLib.EDITOR_ERROR_DIR_EXIST )
			ShowError( "Directory error!", ErrorText, self, CreateDir, strTextOut, func, unpack( args ) )

			return
		end

		local created = StreamRadioLib.Editor.CreateDir(fullpath)

		if created and func then
			func( self, unpack( args ) )
		end
	end, nil, "Create folder", "Cancel")

	return true
end

local function AsForDelete( self, func, ... )
	if not IsValid(self) then return false end
	if not self:IsVisible() then return false end
	if not IsValid(self.Files) then return false end

	local line = self.Files:GetSelectedLine( )
	line = self.Files:GetLine( line )
	if not IsValid( line ) then return false end

	local args = {...}
	local path = line.streamradio_path or ""
	local format = line.streamradio_filetype

	if path == "" then return false end
	if not format then return false end

	Derma_Query( "Are you sure to delete this file/folder?", "Delete file!", "Yes", function( )
		-- Delete.
		if not IsValid(self) then return end
		if not IsValid(line) then return end
		if self:IsLoading() then return end

		if path == "" then return end
		if not format then return end

		local removed = StreamRadioLib.Editor.Remove(path, format)

		if removed and func then
			func( self, unpack( args ) )
		end
	end, "No" )

	-- Don't delete.
	return true
end

local function CreateFile( self, defaultString, func, ... )
	if not IsValid(self) then return false end
	if not self:IsVisible() then return false end
	if not func then return false end

	local Default_Format = StreamRadioLib.Filesystem.GetTypeExt(StreamRadioLib.TYPE_DEFAULT)

	local name = "new_playlist." .. Default_Format
	defaultString = string.Trim(defaultString or "")

	if not StreamRadioLib.String.IsValidFilename(defaultString) then
		defaultString = name
	end

	local args = {...}
	local path = self.m_strPath or ""

	local helpText = [[
Create a new playlist
- All invalid characters are fitered out
- Case insensitive, converted to lowercase
- Valid formats are: %s
]]
	helpText = string.format(helpText, StreamRadioLib.VALID_FORMATS_EXTENSIONS_LIST or "")
	helpText = string.Trim(helpText)

	AsForSave(self, function( self, func, args )
		Derma_StringRequest( "New playlist..", helpText, defaultString, function( strTextOut )
			if not IsValid(self) then return end
			if self:IsLoading() then return end

			strTextOut = StreamRadioLib.String.SanitizeFilename(strTextOut)

			if not StreamRadioLib.String.IsValidFilename(strTextOut) then
				CreateFile( self, defaultString, func, unpack( args ) )
				return
			end

			local fullpath = path .. "/" .. strTextOut
			fullpath = string.Trim(fullpath, "/")

			if not StreamRadioLib.Filesystem.GuessType(fullpath) then
				strTextOut = strTextOut .. "." .. Default_Format

				CreateFile( self, strTextOut, func, unpack( args ) )
				return
			end

			if StreamRadioLib.String.IsVirtualPath(fullpath) then
				local ErrorText = StreamRadioLib.DecodeEditorErrorCode( StreamRadioLib.EDITOR_ERROR_WVIRTUAL )
				ShowError( "Create error!", ErrorText, self, CreateFile, strTextOut, func, unpack( args ) )

				return
			end

			if self.FileItems[strTextOut] then
				local ErrorText = StreamRadioLib.DecodeEditorErrorCode( StreamRadioLib.EDITOR_ERROR_FILE_EXIST )
				ShowError( "Create error!", ErrorText, self, CreateFile, strTextOut, func, unpack( args ) )

				return
			end

			local format = StreamRadioLib.Filesystem.GuessType(fullpath)
			if not StreamRadioLib.Filesystem.CanCreateFormat(format) then
				local ErrorText = StreamRadioLib.DecodeEditorErrorCode( StreamRadioLib.EDITOR_ERROR_WFORMAT )
				ShowError( "Create error!", ErrorText, self, CreateFile, strTextOut, func, unpack( args ) )

				return
			end

			if func then
				func(self, strTextOut, format, unpack(args))
			end
		end, nil, "Create new file", "Cancel")
	end, func, args)

	return true
end

--Ask for override
local function AsForOverride( self, func, filename, ... )
	if not IsValid(self) then return false end
	if not self:IsVisible() then return false end
	if not func then return false end
	local args = {...}

	local filenamelower = string.lower(filename)

	if not self.FileItems[filenamelower] then
		func(self, filename, unpack( args ))
		return true
	end

	Derma_Query( "Overwrite this file?", "Save to..", "Overwrite", function( )
		if not IsValid(self) then return end
		if self:IsLoading() then return end

		func( self, filename, unpack( args ) )
	end, "Cancel" )

	return true
end

local function SaveTo(self, defaultString, func, ...)
	if not IsValid(self) then return false end
	if not self:IsVisible() then return false end
	if not IsValid(self.Files) then return false end
	if not func then return false end

	local Default_Format = StreamRadioLib.Filesystem.GetTypeExt(StreamRadioLib.TYPE_DEFAULT)

	local args = {...}
	local path = self.m_strFolderPath or ""
	local line = self.Files:GetSelectedLine( )
	line = self.Files:GetLine( line )
	local name = "new_playlist." .. Default_Format

	if IsValid(line) then
		name = line.streamradio_name
	end

	defaultString = string.Trim(defaultString or "")

	if not StreamRadioLib.String.IsValidFilename(defaultString) then
		defaultString = name
	end

	local helpText = [[
Save a file
- All invalid characters are fitered out
- Case insensitive, converted to lowercase
- Valid formats are: %s
]]
	helpText = string.format(helpText, StreamRadioLib.VALID_FORMATS_EXTENSIONS_LIST or "")
	helpText = string.Trim(helpText)

	Derma_StringRequest("Save to..", helpText, defaultString, function(strTextOut)
		if not IsValid(self) then return end
		if self:IsLoading() then return end

		strTextOut = StreamRadioLib.String.SanitizeFilename(strTextOut)

		if not StreamRadioLib.String.IsValidFilename(strTextOut) then
			SaveTo(self, defaultString, func, unpack(args))
			return
		end

		local fullpath = path .. "/" .. strTextOut
		fullpath = string.Trim(fullpath, "/")

		if not StreamRadioLib.Filesystem.GuessType(fullpath) then
			strTextOut = strTextOut .. "." .. Default_Format

			SaveTo(self, strTextOut, func, unpack(args))
			return
		end

		local format = StreamRadioLib.Filesystem.GuessType(fullpath)

		if not StreamRadioLib.Filesystem.CanWriteFormat(format) then
			if StreamRadioLib.String.IsVirtualPath(fullpath) then
				local ErrorText = StreamRadioLib.DecodeEditorErrorCode( StreamRadioLib.EDITOR_ERROR_WVIRTUAL )
				ShowError( "Save error!", ErrorText, self, SaveTo, strTextOut, func, unpack( args ) )

				return
			end

			local ErrorText = StreamRadioLib.DecodeEditorErrorCode(StreamRadioLib.EDITOR_ERROR_WFORMAT)
			ShowError("Save error!", ErrorText, self, SaveTo, strTextOut, func, unpack(args))

			return
		end

		if not self.FileItems[strTextOut] then
			if StreamRadioLib.String.IsVirtualPath(fullpath) then
				local ErrorText = StreamRadioLib.DecodeEditorErrorCode( StreamRadioLib.EDITOR_ERROR_WVIRTUAL )
				ShowError( "Create error!", ErrorText, self, SaveTo, strTextOut, func, unpack( args ) )

				return
			end

			if not StreamRadioLib.Filesystem.CanCreateFormat(format) then
				local ErrorText = StreamRadioLib.DecodeEditorErrorCode( StreamRadioLib.EDITOR_ERROR_WFORMAT )
				ShowError( "Create error!", ErrorText, self, SaveTo, strTextOut, func, unpack( args ) )

				return
			end
		end

		AsForOverride(self, function(self, fullpath, strTextOut, format, func, args)
			func(self, fullpath, strTextOut, format, unpack(args))
		end, fullpath, strTextOut, format, func, args)
	end, nil, "Save to file", "Cancel")

	return true
end

local function FileMenu(self, item, path, name, filetype, parentpath)
	if not IsValid(self) then return false end
	if not self:IsVisible() then return false end
	if self:IsLoading() then return false end


	local newfile = self.NewFileItem == item
	local Menu = DermaMenu()
	local MenuItem = nil

	MenuItem = Menu:AddOption("Open", function()
		if not IsValid(self) then return end
		if self:IsLoading() then return end

		self.Files:DoDoubleClick(item:GetID(), item)
	end)

	MenuItem:SetImage("icon16/table_add.png")
	Menu:AddSpacer( )

	MenuItem = Menu:AddOption("Refresh", function()
		if not IsValid(self) then return end
		if self:IsLoading() then return end

		self:Refresh()
	end)

	MenuItem:SetImage("icon16/arrow_refresh.png")

	if not StreamRadioLib.String.IsVirtualPath(parentpath) then
		Menu:AddSpacer( )

		--New
		MenuItem = Menu:AddOption("New", function()
			if not IsValid(self) then return end
			if self:IsLoading() then return end

			CreateFile(self, nil, self.CreateNewFile)
		end)

		MenuItem:SetImage("icon16/table_add.png")

		MenuItem = Menu:AddOption("New folder", function()
			if not IsValid(self) then return end
			if self:IsLoading() then return end

			CreateDir(self, nil, self.Lock, true)
		end)

		MenuItem:SetImage("icon16/folder_add.png")

		--Delete
		if StreamRadioLib.Filesystem.CanDeleteFormat(filetype) and not StreamRadioLib.String.IsVirtualPath(path) then
			Menu:AddSpacer( )
			MenuItem = Menu:AddOption("Delete", function()
				if not IsValid(self) then return end
				if self:IsLoading() then return end

				if newfile then
					AsForDelete(self, self.RemoveNewFile)

					return
				end

				AsForDelete(self, self.Lock, true)
			end)

			MenuItem:SetImage("icon16/bin_closed.png")
		end
	end

	Menu:Open()
	return true
end

local function PlaylistMenu( self, item, url, name, parentpath )
	if not IsValid(self) then return false end
	if not self:IsVisible() then return false end
	if self:IsLoading() then return false end

	local Menu = DermaMenu()
	local MenuItem = nil

	MenuItem = Menu:AddOption( "Copy Entry", function( )
		if not IsValid(self) then return end
		if self:IsLoading() then return end

		if self:AddPlaylistItem() then
			self:SetUnsaved(true)
		end
	end)

	MenuItem:SetImage( "icon16/add.png" )

	MenuItem = Menu:AddOption( "Remove Entry", function( )
		if not IsValid(self) then return end
		if self:IsLoading() then return end

		if self:RemovePlaylistItem(item) then
			self:SetUnsaved(true)
		end
	end)

	MenuItem:SetImage( "icon16/delete.png" )
	Menu:AddSpacer( )

	MenuItem = Menu:AddOption( "Move Up", function( )
		if not IsValid(self) then return end
		if self:IsLoading() then return end
		self:PlaylistCheckValid()

		if self:MovePlaylistItemUp(item) then
			self:SetUnsaved(true)
		end
	end )

	MenuItem:SetImage( "icon16/arrow_up.png" )

	MenuItem = Menu:AddOption( "Move Down", function( )
		if not IsValid(self) then return end
		if self:IsLoading() then return end

		self:PlaylistCheckValid()

		if self:MovePlaylistItemDown(item) then
			self:SetUnsaved( true )
		end
	end )

	MenuItem:SetImage( "icon16/arrow_down.png" )
	Menu:Open( )

	return true
end

function PANEL:IsLoading( )
	return self.IsLocked
end

function PANEL:Init( )
	self:SetPaintBackground( false )
	self.FilesPanel = vgui.Create( "DPanel" )
	self.FilesPanel:SetPaintBackground( false )

	self.PlaylistPanel = vgui.Create( "DPanel" )
	self.PlaylistPanel:SetPaintBackground( false )

	self.Files = self.FilesPanel:Add( "DListView" )
	self.Files:SetMultiSelect( false )
	self.Files:Dock( FILL )
	self.Files:AddColumn( "Name" )
	local Column = self.Files:AddColumn( "Type" )
	Column:SetFixedWidth( 70 )
	Column:SetWide( 70 )

	self.Files.DoDoubleClick = function( parent, id, line )
		if self:IsLoading( ) then return end
		if ( self.LastFileItem == line ) then return end
		self.LastFileItem = line
		if ( self.NewFileItem == line ) then return end

		local path = line.streamradio_path
		local filetype = line.streamradio_filetype

		self:SetPath( path, filetype, false, true )
	end

	self.Files.OnRowRightClick = function( parent, id, line )
		if self:IsLoading( ) then return end
		local path = line.streamradio_path
		local name = line.streamradio_name
		local filetype = line.streamradio_filetype
		local parentpath = line.streamradio_parentpath
		FileMenu( self, line, path, name, filetype, parentpath )
	end

	self.PlaylistTabPanel = self.PlaylistPanel:Add( "DPropertySheet" )
	self.PlaylistTabPanel:Dock( FILL )
	self.PlaylistTabPanel:SetFadeTime( 0 )

	self.PlaylistTabPanel.OnActiveTabChanged = function(this, old_panel, new_panel)
		if self:IsLoading( ) then return end

		StreamRadioLib.Timedcall(function()
			self:UpdatePlaylistEditorFromTextPanel()
			self:UpdatePlaylistTextFromEditorPanel()
		end)
	end

	self.PlaylistEditorPanel = vgui.Create( "DPanel" )
	local playlistEditorSheet = self.PlaylistTabPanel:AddSheet( "list", self.PlaylistEditorPanel, "icon16/table.png" )
	self.PlaylistEditorPanel:SetPaintBackground( false )

	self.PlaylistTextPanel = vgui.Create( "DPanel" )
	local playlistTextSheet = self.PlaylistTabPanel:AddSheet( "text", self.PlaylistTextPanel, "icon16/page_white.png" )
	self.PlaylistTextPanel:SetPaintBackground( false )

	playlistEditorSheet.Tab:SetText("List mode")
	playlistEditorSheet.Tab:SetTooltip("Edit the playlist in a list view")
	playlistTextSheet.Tab:SetText("Text mode")
	playlistTextSheet.Tab:SetTooltip("Edit the playlist in a text field (for advanced users)")

	self.Playlist = self.PlaylistEditorPanel:Add( "DListView" )
	self.Playlist:SetMultiSelect( false )
	self.Playlist:Dock( FILL )
	local Column = self.Playlist:AddColumn( "No." )
	Column:SetFixedWidth( 30 )
	Column:SetWide( 30 )
	local Column = self.Playlist:AddColumn( "Name" )
	Column:SetWide( 50 )
	self.Playlist:AddColumn( "URL" )

	self.Playlist.OnRowSelected = function( parent, id, line )
		if self:IsLoading( ) then return end
		self:SelectPlaylistItem( line )
	end

	self.Playlist.DoDoubleClick = function( parent, id, line )
		if self:IsLoading( ) then return end
		self:SelectPlaylistItem( line )
	end

	self.Playlist.OnRowRightClick = function( parent, id, line )
		if self:IsLoading( ) then return end
		local url = line.streamradio_url
		local name = line.streamradio_name

		PlaylistMenu( self, line, url, name, self.PlaylistItems["parentpath"] )
		self:SelectPlaylistItem( line )
	end

	self.PlaylistBottomPanel = self.PlaylistEditorPanel:Add( "DPanel" )
	self.PlaylistBottomPanel:SetPaintBackground( false )
	self.PlaylistBottomPanel:Dock( BOTTOM )
	self.PlaylistBottomPanel:SetTall( 110 )
	self.PlaylistBottomPanel:DockMargin( 0, 3, 0, 0 )

	self.EditNamePanel = self.PlaylistBottomPanel:Add( "DPanel" )
	self.EditNamePanel:SetPaintBackground( false )
	self.EditNamePanel:Dock( TOP )
	self.EditNamePanel:SetTall( 20 )
	self.EditNamePanel:DockMargin( 0, 0, 0, 3 )

	self.EditURLPanel = self.PlaylistBottomPanel:Add( "DPanel" )
	self.EditURLPanel:SetPaintBackground( false )
	self.EditURLPanel:Dock( TOP )
	self.EditURLPanel:SetTall( 60 )
	self.EditURLPanel:DockMargin( 0, 0, 0, 3 )

	self.EditButtonsPanel = self.PlaylistBottomPanel:Add( "DPanel" )
	self.EditButtonsPanel:SetPaintBackground( false )
	self.EditButtonsPanel:Dock( BOTTOM )
	self.EditButtonsPanel:SetTall( 20 )
	self.EditButtonsPanel:DockMargin( 0, 0, 0, 0 )

	self.EditNameText = self.EditNamePanel:Add( "DTextEntry" )
	self.EditNameText:DockMargin( 0, 0, 0, 0 )
	self.EditNameText:Dock( FILL )

	if self.EditNameText.SetPlaceholderText then
		-- Some client have some addon conflicts
		-- This causes them to not have the panel:SetPlaceholderText() function

		self.EditNameText:SetPlaceholderText("Enter a name for this Entry")
	end

	self.EditNameText.OnEnter = function( panel )
		if self:IsLoading() then return end
		self:PlaylistCheckValid()
	end

	self.EditNameText.OnChange = function( panel )
		if self:IsLoading() then return end
		self:PlaylistCheckValid()
	end

	self.EditNameLabel = self.EditNamePanel:Add( "DLabel" )
	self.EditNameLabel:SetText( "Name:" )
	self.EditNameLabel:SetWide( 40 )
	self.EditNameLabel:SetDark( true )
	self.EditNameLabel:DockMargin( 6, 0, 0, 0 )
	self.EditNameLabel:Dock( LEFT )

	self.EditURLText = self.EditURLPanel:Add( "Streamradio_VGUI_URLTextEntry" )
	self.EditURLText:DockMargin( 0, 0, 0, 0 )
	self.EditURLText:Dock( FILL )

	self.EditURLText.OnEnter = function( panel )
		if self:IsLoading( ) then return end
		self:PlaylistCheckValid( )
	end

	self.EditURLText.OnChange = function( panel )
		if self:IsLoading( ) then return end
		self:PlaylistCheckValid( )
	end

	self.EditURLLabel = self.EditURLPanel:Add( "DLabel" )
	self.EditURLLabel:SetText( "URL:" )
	self.EditURLLabel:SetWide( 40 )
	self.EditURLLabel:SetDark( true )
	self.EditURLLabel:DockMargin( 6, 0, 0, 0 )
	self.EditURLLabel:Dock( LEFT )

	self.EditChangeButton = self.EditButtonsPanel:Add( "DButton" )
	self.EditChangeButton:SetWide( 100 )
	self.EditChangeButton:DockMargin( 6, 0, 0, 0 )
	self.EditChangeButton:Dock( RIGHT )
	self.EditChangeButton:SetText( "Apply" )
	self.EditChangeButton:SetImage( "icon16/pencil.png" )

	self.EditChangeButton.DoClick = function( panel )
		if self:IsLoading( ) then return end
		self:PlaylistCheckValid( )

		if ( self:ChangePlaylistItem( self.SelectedPlaylistItem ) ) then
			self:SetUnsaved( true )
		end
	end

	self.EditAddButton = self.EditButtonsPanel:Add( "DButton" )
	self.EditAddButton:SetWide( 100 )
	self.EditAddButton:DockMargin( 6, 0, 0, 0 )
	self.EditAddButton:Dock( RIGHT )
	self.EditAddButton:SetText( "Add" )
	self.EditAddButton:SetImage( "icon16/add.png" )

	self.EditAddButton.DoClick = function( panel )
		if self:IsLoading( ) then return end
		self:PlaylistCheckValid( )

		if ( self:AddPlaylistItem( ) ) then
			self:SetUnsaved( true )
		end
	end

	local starttimeout = 0.5
	local holdtimeout = 0.075

	self.EditMoveDownButton = self.EditButtonsPanel:Add( "DButton" )
	self.EditMoveDownButton:SetWide( self.EditMoveDownButton:GetTall() + 10 )
	self.EditMoveDownButton:DockMargin( 6, 0, 0, 0 )
	self.EditMoveDownButton:Dock( RIGHT )
	self.EditMoveDownButton:SetText( "" )
	self.EditMoveDownButton:SetTooltip( "Move item down" )

	self.EditMoveDownButtonImage = vgui.Create( "DImage", self.EditMoveDownButton )
	if ( IsValid( self.EditMoveDownButtonImage ) ) then
		self.EditMoveDownButtonImage:SetImage( "icon16/arrow_down.png" )
		self.EditMoveDownButtonImage:SizeToContents()

		local w1, h1 = self.EditMoveDownButton:GetSize()
		local w2, h2 = self.EditMoveDownButtonImage:GetSize()

		self.EditMoveDownButtonImage:SetPos((w1 - w2) / 2, (h1 - h2) / 2)
	end

	self.EditMoveUpButton = self.EditButtonsPanel:Add( "DButton" )
	self.EditMoveUpButton:SetWide( self.EditMoveUpButton:GetTall() + 10 )
	self.EditMoveUpButton:DockMargin( 6, 0, 0, 0 )
	self.EditMoveUpButton:Dock( RIGHT )
	self.EditMoveUpButton:SetText( "" )
	self.EditMoveUpButton:SetTooltip( "Move item up" )

	self.EditMoveUpButtonImage = vgui.Create( "DImage", self.EditMoveUpButton )
	if ( IsValid( self.EditMoveUpButtonImage ) ) then
		self.EditMoveUpButtonImage:SetImage( "icon16/arrow_up.png" )
		self.EditMoveUpButtonImage:SizeToContents()

		local w1, h1 = self.EditMoveUpButton:GetSize()
		local w2, h2 = self.EditMoveUpButtonImage:GetSize()

		self.EditMoveUpButtonImage:SetPos((w1 - w2) / 2, (h1 - h2) / 2)
	end

	self.EditMoveUpButton.DoClick = function( panel )
		if self:IsLoading( ) then return end
		self:PlaylistCheckValid( )

		if ( self:MovePlaylistItemUp( self.SelectedPlaylistItem ) ) then
			self:SetUnsaved( true )
		end

		self.EditMoveUpButton.streamradio_presstime = nil
		self.EditMoveDownButton.streamradio_presstime = nil
	end
	self.EditMoveUpButton.OnHold = function( panel )
		if ( not panel.streamradio_presstime ) then
			panel.streamradio_presstime = RealTime() + starttimeout
		end

		if ( ( RealTime() - panel.streamradio_presstime ) < holdtimeout ) then return end
		self:PlaylistCheckValid( )

		if ( self:MovePlaylistItemUp( self.SelectedPlaylistItem ) ) then
			self:SetUnsaved( true )
		end

		panel.streamradio_presstime = RealTime()
	end

	self.EditMoveDownButton.DoClick = function( panel )
		if self:IsLoading( ) then return end
		self:PlaylistCheckValid( )

		if ( self:MovePlaylistItemDown( self.SelectedPlaylistItem ) ) then
			self:SetUnsaved( true )
		end

		self.EditMoveUpButton.streamradio_presstime = nil
		self.EditMoveDownButton.streamradio_presstime = nil
	end
	self.EditMoveDownButton.OnHold = function( panel )
		if ( not panel.streamradio_presstime ) then
			panel.streamradio_presstime = RealTime() + starttimeout
		end

		if ( ( RealTime() - panel.streamradio_presstime ) < holdtimeout ) then return end
		self:PlaylistCheckValid( )

		if ( self:MovePlaylistItemDown( self.SelectedPlaylistItem ) ) then
			self:SetUnsaved( true )
		end

		panel.streamradio_presstime = RealTime()
	end

	self.EditRemoveButton = self.EditButtonsPanel:Add( "DButton" )
	self.EditRemoveButton:SetWide( 100 )
	self.EditRemoveButton:DockMargin( 0, 0, 0, 0 )
	self.EditRemoveButton:Dock( LEFT )
	self.EditRemoveButton:SetText( "Remove" )
	self.EditRemoveButton:SetImage( "icon16/delete.png" )

	self.EditRemoveButton.DoClick = function( panel )
		if self:IsLoading( ) then return end
		self:PlaylistCheckValid( )

		if ( self:RemovePlaylistItem( self.SelectedPlaylistItem ) ) then
			self:SetUnsaved( true )
		end
	end

	self.PlaylistText = self.PlaylistTextPanel:Add( "DTextEntry" )
	self.PlaylistText:Dock( FILL )

	local TextEditorFont = StreamRadioLib.Surface.AddFont(14, 1000, "Lucida Console")

	self.PlaylistText:SetEditable( true )
	self.PlaylistText:SetMultiline( true )
	self.PlaylistText:SetDrawLanguageID( false )
	self.PlaylistText:SetTabbingDisabled( true )
	self.PlaylistText:SetHistoryEnabled( false )
	self.PlaylistText:SetEnterAllowed( true )
	self.PlaylistText:SetDrawBorder( true )
	self.PlaylistText:SetVerticalScrollbarEnabled( true )
	self.PlaylistText:SetUpdateOnType( true )
	self.PlaylistText:SetFont(TextEditorFont)

	self.PlaylistText.OnValueChange = function( )
		if self:IsLoading( ) then return end

		self:MarkPlaylistEditorShouldUpdate()
		self:SetUnsaved( true )
	end

	self.PlaylistTextBottomPanel = self.PlaylistTextPanel:Add( "DPanel" )
	self.PlaylistTextBottomPanel:SetPaintBackground( false )
	self.PlaylistTextBottomPanel:Dock( BOTTOM )
	self.PlaylistTextBottomPanel:SetTall( 100 )
	self.PlaylistTextBottomPanel:DockMargin( 0, 3, 0, 0 )

	local helpTextGeneral = [[
About this text based playlist editor:

- Changes are automatically synchronized between this view and the list view.
- Enter the name and the URL for each entry you want to add.
- The syntax is independent from the playlist format.
- Missing lines are skipped or are filled with placeholders.
- Whitespaces are trimed on each line.
]]

	local helpTextSyntax = [[
Example:

1.FM - ABSOLUTE TOP 40 RADIO [newline]
http://185.33.21.112:80/top40_128 [newline]
1.FM - Alternative Rock X Hits [newline]
http://185.33.21.112:80/x_128 [newline]
...
]]

	helpTextGeneral = string.Trim(helpTextGeneral)
	helpTextSyntax = string.Trim(helpTextSyntax)

	self.PlaylistTextHelpGeneralLabel = self.PlaylistTextBottomPanel:Add( "Streamradio_VGUI_ReadOnlyTextEntry" )
	self.PlaylistTextHelpGeneralLabel:SetText(helpTextGeneral)
	self.PlaylistTextHelpGeneralLabel:DockMargin( 6, 0, 0, 0 )
	self.PlaylistTextHelpGeneralLabel:SetWide( 400 )
	self.PlaylistTextHelpGeneralLabel:Dock( LEFT )
	self.PlaylistTextHelpGeneralLabel:SetZPos(100)

	self.PlaylistTextHelpSyntaxLabel = self.PlaylistTextBottomPanel:Add( "Streamradio_VGUI_ReadOnlyTextEntry" )
	self.PlaylistTextHelpSyntaxLabel:SetText(helpTextSyntax)
	self.PlaylistTextHelpSyntaxLabel:DockMargin( 6, 0, 0, 0 )
	self.PlaylistTextHelpSyntaxLabel:SetWide( 400 )
	self.PlaylistTextHelpSyntaxLabel:Dock( LEFT )
	self.PlaylistTextHelpSyntaxLabel:SetZPos(200)


	self.TopPanel = self:Add( "DPanel" )
	self.TopPanel:SetPaintBackground( false )
	self.TopPanel:Dock( TOP )
	self.TopPanel:SetTall( 20 )
	self.TopPanel:DockMargin( 0, 0, 0, 3 )

	self.SaveIcon = self.TopPanel:Add( "DImageButton" )
	self.SaveIcon:SetImage( "icon16/table_save.png" )
	self.SaveIcon:SetWide( 20 )
	self.SaveIcon:Dock( LEFT )
	self.SaveIcon:SetTooltip( "Save list" )
	self.SaveIcon:SetStretchToFit( false )
	self.SaveIcon:DockMargin( 0, 0, 0, 0 )

	self.SaveIcon.DoClick = function( )
		if self:IsLoading( ) then return end

		if ( not self.m_strPath or self.m_strPath == "" or self.m_strPath == self.m_strFolderPath ) then
			SaveTo( self, nil, self.SavePlaylist )

			return
		end

		self:SavePlaylist( )
	end

	self.SaveToIcon = self.TopPanel:Add( "DImageButton" )
	self.SaveToIcon:SetImage( "icon16/disk.png" )
	self.SaveToIcon:SetWide( 20 )
	self.SaveToIcon:Dock( LEFT )
	self.SaveToIcon:SetTooltip( "Save to.." )
	self.SaveToIcon:SetStretchToFit( false )
	self.SaveToIcon:DockMargin( 0, 0, 0, 0 )

	self.SaveToIcon.DoClick = function( )
		if self:IsLoading( ) then return end
		SaveTo( self, nil, self.SavePlaylist )
	end

	self.NewIcon = self.TopPanel:Add( "DImageButton" )
	self.NewIcon:SetImage( "icon16/table_add.png" )
	self.NewIcon:SetWide( 20 )
	self.NewIcon:Dock( LEFT )
	self.NewIcon:SetTooltip( "New list" )
	self.NewIcon:SetStretchToFit( false )
	self.NewIcon:DockMargin( 10, 0, 0, 0 )

	self.NewIcon.DoClick = function( )
		if self:IsLoading( ) then return end
		CreateFile( self, nil, self.CreateNewFile )
	end

	self.NewFolder = self.TopPanel:Add( "DImageButton" )
	self.NewFolder:SetImage( "icon16/folder_add.png" )
	self.NewFolder:SetWide( 20 )
	self.NewFolder:Dock( LEFT )
	self.NewFolder:SetTooltip( "New folder" )
	self.NewFolder:SetStretchToFit( false )
	self.NewFolder:DockMargin( 0, 0, 0, 0 )

	self.NewFolder.DoClick = function( )
		if self:IsLoading( ) then return end
		CreateDir( self, nil, self.Lock, true )
	end

	self.RefreshIcon = self.TopPanel:Add( "DImageButton" )
	self.RefreshIcon:SetImage( "icon16/arrow_refresh.png" )
	self.RefreshIcon:SetWide( 20 )
	self.RefreshIcon:Dock( LEFT )
	self.RefreshIcon:SetTooltip( "Refresh and reload" )
	self.RefreshIcon:SetStretchToFit( false )
	self.RefreshIcon:DockMargin( 10, 0, 0, 0 )

	self.RefreshIcon.DoClick = function( )
		if self:IsLoading( ) then return end
		self:Refresh( )
	end

	self.ApplySortIcon = self.TopPanel:Add( "DImageButton" )
	self.ApplySortIcon:SetImage( "icon16/lightning.png" )
	self.ApplySortIcon:SetWide( 20 )
	self.ApplySortIcon:Dock( LEFT )
	self.ApplySortIcon:SetTooltip( "Apply current sort to playlist" )
	self.ApplySortIcon:SetStretchToFit( false )
	self.ApplySortIcon:DockMargin( 10, 0, 0, 0 )

	self.ApplySortIcon.DoClick = function( )
		if self:IsLoading( ) then return end
		self:ApplyPlaylistSort( )

		self:SetUnsaved( true )
		self:MarkPlaylistTextShouldUpdate( true )
	end

	self.ListNameLabel = self.TopPanel:Add( "Streamradio_VGUI_ReadOnlyTextEntry" )
	self.ListNameLabel:SetText( "" )
	self.ListNameLabel:SetWide( 20 )
	self.ListNameLabel:Dock( FILL )
	self.ListNameLabel:DockMargin( 12, 0, 0, 0 )
	self.ListNameLabel:SetMultiline( false )

	self.SplitPanel = self:Add( "DHorizontalDivider" )
	self.SplitPanel:Dock( FILL )
	self.SplitPanel:SetRight( self.PlaylistPanel )
	self.SplitPanel:SetLeft( self.FilesPanel )
	self.SplitPanel:SetLeftWidth( 300 )
	self.SplitPanel:SetLeftMin( 200 )
	self.SplitPanel:SetRightMin( 400 )
	self.SplitPanel:SetDividerWidth( 3 )

	self:Reset( )
end

function PANEL:SavePlaylist( filepath, name, filetype )
	if self:IsLoading() then return false end
	if self.m_bSaving then return false end

	if self.PlaylistTextPanel._isDirty then
		self:BuildPlaylistFromTextPanel()
	end

	if filepath and name and filetype then
		self.m_strPath = filepath
		self.Format = filetype

		self.PlaylistItems["format"] = filetype
		self.PlaylistItems["parentpath"] = self.m_strFolderPath
	end

	if not StreamRadioLib.Editor.Save(filepath or self.m_strPath, self.PlaylistItems) then return false end
	local fileitem = self:AddFileItem(filepath, name, self.m_strFolderPath, filetype)

	if IsValid(fileitem) then
		self.Files:ClearSelection()
		self.Files:SortByColumn(1)
		self.Files:SelectItem(fileitem)

		self.NewFileItem = fileitem
		self.LastFileItem = fileitem
	end

	self.m_bSaving = true
	self:Lock(true)

	return true
end

local function EnablePanel( button, bool )
	if ( not bool ) then
		button.Depressed = false
		button.m_bSelected = false
		button.Hovered = false

		button.streamradio_presstime = nil
	end

	button:SetMouseInputEnabled( bool )
	button:SetEnabled( bool )
	button:SetKeyboardInputEnabled( bool )
end

function PANEL:Lock( bool )
	bool = bool or false

	EnablePanel( self, not bool )
	self.IsLocked = bool
end

function PANEL:BuildPlaylistFromTextPanel()
	if not self.PlaylistItems then
		self.PlaylistItems = {}

		self.PlaylistTextPanel._isDirty = nil
		self.PlaylistEditorPanel._isDirty = nil
		return
	end

	local lines = self.PlaylistText:GetText()
	lines = StreamRadioLib.String.NormalizeNewlines(lines, '\n')

	lines = string.Explode("\n", lines, false) or {}

	local len = #lines

	self.Playlist:Clear( )
	self.PlaylistItems = self:GetEmptyPlaylistItems()

	local index = 1

	for i = 1, len, 2 do
		local name = string.Trim(lines[i] or "")
		local url = string.Trim(lines[i + 1] or "")

		if name == "" and url == "" then
			continue
		end

		if name == "" then
			name = string.format("(no name #%d)", index)
		end

		if url == "" then
			url = string.format("(no url #%d)", index)
		end

		self:AddPlaylistItem(url, name)
		index = index + 1
	end

	self:SelectPlaylistItem( )
	self:PlaylistCheckValid( )

	self.PlaylistTextPanel._isDirty = nil
	self.PlaylistEditorPanel._isDirty = nil
end

function PANEL:BuildTextFromPlaylistPanel()
	local lines = {}
	local index = 1

	for i, v in ipairs( self.PlaylistItems or {} ) do
		local name = string.Trim(v.name or "")
		local url = string.Trim(v.url or "")

		if name == "" and url == "" then
			continue
		end

		if name == "" then
			name = string.format("(no name #%d)", index)
		end

		if url == "" then
			url = string.format("(no url #%d)", index)
		end

		table.insert(lines, name)
		table.insert(lines, url)

		index = index + 1
	end

	lines = table.concat(lines, "\n")
	self.PlaylistText:SetText(lines)

	self.PlaylistTextPanel._isDirty = nil
	self.PlaylistEditorPanel._isDirty = nil
end

function PANEL:MarkPlaylistEditorShouldUpdate(alsoTryUpdate)
	self.PlaylistTextPanel._isDirty = true

	if alsoTryUpdate then
		self:UpdatePlaylistEditorFromTextPanel()
	end
end

function PANEL:MarkPlaylistTextShouldUpdate(alsoTryUpdate)
	self.PlaylistEditorPanel._isDirty = true

	if alsoTryUpdate then
		self:UpdatePlaylistTextFromEditorPanel()
	end
end

function PANEL:UpdatePlaylistEditorFromTextPanel()
	if not self.PlaylistItems then
		return
	end

	local tab = self.PlaylistTabPanel:GetActiveTab()
	if not IsValid(tab) then
		return
	end

	local activePanel = tab:GetPanel()
	if not IsValid(activePanel) then
		return
	end

	if activePanel ~= self.PlaylistEditorPanel then
		return
	end

	if not self.PlaylistTextPanel._isDirty then
		return
	end

	self:BuildPlaylistFromTextPanel()
end

function PANEL:UpdatePlaylistTextFromEditorPanel()
	if not self.PlaylistItems then
		return
	end

	local tab = self.PlaylistTabPanel:GetActiveTab()
	if not IsValid(tab) then
		return
	end

	local activePanel = tab:GetPanel()
	if not IsValid(activePanel) then
		return
	end

	if activePanel ~= self.PlaylistTextPanel then
		return
	end

	if not self.PlaylistEditorPanel._isDirty then
		return
	end

	self:BuildTextFromPlaylistPanel()
end

function PANEL:Clear( )
	self:ClearFiles( )
	self:ClearPlaylist( )
end

function PANEL:ClearFiles( )
	self.Files:Clear( )
	self.FileItems = {}
	self:InvalidateLayout( )
end

function PANEL:ClearPlaylist( )
	self.Playlist:Clear( )
	self.PlaylistItems = {}
	self:SelectPlaylistItem( )
	self:PlaylistCheckValid( )
	self:SetUnsaved( false )
	self:ClearPlaylistText( )
	self:InvalidateLayout( )
end

function PANEL:ClearPlaylistText( )
	self.PlaylistText:SetText( "" )
	self:MarkPlaylistTextShouldUpdate( true )
	self:InvalidateLayout( )
end

function PANEL:GetEmptyPlaylistItems()
	local tmpTab = {}

	for k, v in pairs( self.PlaylistItems or {} ) do
		if not isstring( k ) then continue end
		tmpTab[k] = v
	end

	return tmpTab
end

function PANEL:PerformLayout( )
	if ( IsValid( self.SplitPanel ) ) then
		local minw = self:GetWide( ) - self.SplitPanel:GetRightMin( ) - self.SplitPanel:GetDividerWidth( )
		local oldminw = self.SplitPanel:GetLeftWidth( minw )

		if ( oldminw > minw ) then
			self.SplitPanel:SetLeftWidth( minw )
		end
	end

	--Fixes scrollbar glitches on resize
	if ( IsValid( self.Playlist ) ) then
		self.Playlist:OnMouseWheeled( 0 )
	end

	if ( IsValid( self.Files ) ) then
		self.Files:OnMouseWheeled( 0 )
	end

	StreamRadioLib.VR.RenderMenu(self)
end

local function Refresh( self )
	local filepath = self.m_strPath or ""
	local format = self.Format or StreamRadioLib.TYPE_FOLDER
	filepath = string.Trim( filepath, "\\" )
	filepath = string.Trim( filepath, "/" )
	filepath = string.Trim( filepath, "\\" )
	filepath = string.Trim( filepath, "/" )
	self:SetPath( filepath, format, true )

	if not StreamRadioLib.Filesystem.IsFolder(format) then
		self:SetPath( self.m_strFolderPath, StreamRadioLib.TYPE_FOLDER, true, true )
	end

	self.m_strPath = filepath
	self.Format = format
	self:UpdateListNameLabel( )
	self:InvalidateLayout( )
end

function PANEL:Reset( )
	self:Clear( )
	self.m_strPath = nil
	self.Format = nil
	self:Refresh( true )
end

function PANEL:Refresh( force )
	if ( force ) then
		Refresh( self )
	else
		AsForSave( self, Refresh )
	end
end

local function CallOnHold(panel)
	if ( not IsValid( panel ) ) then return end
	if ( not isfunction( panel.OnHold ) ) then return end
	if ( panel.IsDown and (not panel:IsDown() ) ) then return end

	panel.OnHold(panel)
end

function PANEL:Think( )
	if self:IsLoading( ) then return end

	CallOnHold(self.EditMoveUpButton)
	CallOnHold(self.EditMoveDownButton)
end

local loadcol = Color( 255, 0, 0, 255 )

function PANEL:PaintOver( w, h )
	if not self:IsLoading() then return end

	local sqmax, sqmin = math.max(w, h), math.min(w, h)
	local isq = math.min(sqmax * 0.125, sqmin * 0.5)

	StreamRadioLib.Surface.Loading((w - isq) / 2, (h - isq) / 2, isq, isq, loadcol, 8 )
end

function PANEL:PlaylistCheckValid( )
	local url = self.EditURLText:GetText( )
	local name = self.EditNameText:GetText( )
	local EnableEdit = ( url ~= "" and name ~= "" and self.EditURLText:CheckURL( true ) )
	local EnableSelect = IsValid( self.SelectedPlaylistItem ) and self.SelectedPlaylistItem.streamradio_id

	local EnableUp = EnableSelect and self.Playlist:GetSortedID(self.SelectedPlaylistItem:GetID()) > 1
	local EnableDown = EnableSelect and self.Playlist:GetSortedID(self.SelectedPlaylistItem:GetID()) < #self.PlaylistItems

	EnablePanel( self.EditAddButton, EnableEdit )
	EnablePanel( self.EditChangeButton, EnableEdit and EnableSelect )
	EnablePanel( self.EditRemoveButton, EnableSelect )
	EnablePanel( self.EditMoveUpButton, EnableUp )
	EnablePanel( self.EditMoveDownButton, EnableDown )
end

function PANEL:Callback(CallbackType, path, name, parentpath, filetype)
	if CallbackType == "files" then

		self:Lock(true)

		if StreamRadioLib.Filesystem.IsFolder(filetype) then
			self:AddFolderItem( path, name, parentpath, filetype )
		else
			self:AddFileItem( path, name, parentpath, filetype )
		end

	elseif CallbackType == "playlist" then

		self:SetUnsaved( false )
		self:Lock( true )
		self:AddPlaylistItem( path, name, parentpath, filetype )

	elseif CallbackType == "error" then

		if name == StreamRadioLib.EDITOR_ERROR_RESET then
			self:Reset( )
			return
		end

		if OK_CODES[name] then
			self:OnFinish( path, name )
		else
			self:OnError( path, name )
		end

	end
end

function PANEL:OnFinish( path, code )
	if code == StreamRadioLib.EDITOR_ERROR_OK then
		self.m_bSaving = false
		self:Lock( false )
		self:SetUnsaved( false )
		self:MarkPlaylistTextShouldUpdate( true )
	end

	if code == StreamRadioLib.EDITOR_ERROR_WRITE_OK then
		self.m_bSaving = false
		self:Lock( false )
		self:SetUnsaved( false )
	end

	if code == StreamRadioLib.EDITOR_ERROR_READ_OK then
		self:Lock( false )
		self:SetUnsaved( false )
		self:MarkPlaylistTextShouldUpdate( true )
	end

	if code == StreamRadioLib.EDITOR_ERROR_FILES_OK then
		self:Lock( false )
	end

	if code == StreamRadioLib.EDITOR_ERROR_DIR_OK then
		self:Lock( false )
		local name = string.GetFileFromFilename( path ) or ""

		if ( name == "" ) then
			name = path
		end

		local fileitem = self:AddFolderItem( path, name, self.m_strFolderPath, StreamRadioLib.TYPE_FOLDER )
		self.Files:ClearSelection( )
		self.Files:SortByColumn( 1 )
		if ( not IsValid( fileitem ) ) then return end
		self.Files:SelectItem( fileitem )
	end

	if code == StreamRadioLib.EDITOR_ERROR_DEL_OK then
		self:Lock( false )
		local line = self.Files:GetSelectedLine( )
		local linepanel = self.Files:GetLine( line )

		if not IsValid( linepanel ) then
			self:Refresh( true )

			return
		end

		if linepanel.streamradio_path ~= path then
			self:Refresh( true )

			return
		end

		if self.Clipboard == linepanel.streamradio_path then
			self.Clipboard = nil
		end

		if path == self.m_strPath and linepanel.streamradio_filetype ~= StreamRadioLib.TYPE_FOLDER then
			self.m_strPath = self.m_strFolderPath
			self.Format = StreamRadioLib.TYPE_FOLDER
			self:Refresh( true )

			return
		end

		local namelower = string.lower(linepanel.streamradio_name or "")
		self.FileItems[namelower] = nil

		self.Files:RemoveLine( line )
		self.Files:SortByColumn( 1 )
	end
end

function PANEL:OnError( path, code )
	local ErrorString = StreamRadioLib.DecodeEditorErrorCode( code )

	if WRITE_ERRORS[code] then
		self.m_bSaving = false
		self:Lock( false )
		ShowError( "Write error!", ErrorString, self )

		return
	end

	if READ_ERRORS[code] then
		self:Lock( false )
		self:SetUnsaved( false )
		ShowError( "Read error!", ErrorString, self )

		return
	end

	if DIR_ERRORS[code] then
		self:Lock( false )
		ShowError( "Directory error!", ErrorString, self )

		return
	end

	if code == StreamRadioLib.EDITOR_ERROR_DEL_ACCES then
		self:Lock( false )
		ShowError( "Delete error!", ErrorString, self )

		return
	end

	if COPY_ERRORS[code] then
		self:Lock( false )
		ShowError( "Copy error!", ErrorString, self )

		return
	end

	if RENAME_ERRORS[code] then
		self:Lock( false )
		ShowError( "Rename or move error!", ErrorString, self )

		return
	end

	self:Lock( false )
	ShowError( "General error! (" .. code .. ")", ErrorString, self )
end

function PANEL:RemoveNewFile()
	if not IsValid(self.Files) then return end
	if not IsValid(self.NewFileItem) then return end

	if self.Clipboard == self.NewFileItem.streamradio_path then
		self.Clipboard = nil
	end

	local namelower = string.lower(self.NewFileItem.streamradio_name or "")

	self.FileItems[namelower] = nil
	self.Files:RemoveLine(self.NewFileItem:GetID())
end

function PANEL:CreateNewFile(name, filetype)
	if not name then return false end
	if name == "" then return false end
	if not filetype then return false end

	local path = self.m_strFolderPath .. "/" .. name
	path = string.Trim(path, "/")

	local fileitem = self:AddFileItem(path, name, self.m_strFolderPath, filetype)
	if not IsValid(fileitem) then return false end

	self:ClearPlaylist()

	self.m_strPath = path
	self.Format = filetype
	self.PlaylistItems["format"] = filetype
	self.PlaylistItems["parentpath"] = self.m_strFolderPath

	self:SetUnsaved(true)

	self.Files:ClearSelection()
	self.Files:SortByColumn(1)
	self.Files:SelectItem(fileitem)

	self.NewFileItem = fileitem
	self.LastFileItem = fileitem

	self:ClearPlaylistText()
	return true
end

function PANEL:AddFolderItem(path, name, parentpath, filetype)
	if not path then return end
	if not name then return end
	if not parentpath then return end
	if not filetype then return end
	if not IsValid(self.Files) then return end

	local namelower = string.lower(name)
	if self.FileItems[namelower] then return end

	local item = self.Files:AddLine("./" .. name, StreamRadioLib.Filesystem.GetTypeName(filetype))

	item.streamradio_path = path
	item.streamradio_name = name
	item.streamradio_filetype = filetype
	item.streamradio_parentpath = parentpath

	self.FileItems[namelower] = true
	return item
end

function PANEL:AddFileItem( path, name, parentpath, filetype )
	if not path then return end
	if not name then return end
	if not parentpath then return end
	if not filetype then return end
	if not IsValid(self.Files) then return end

	local namelower = string.lower(name)
	if self.FileItems[namelower] then return end

	local item = self.Files:AddLine(name, StreamRadioLib.Filesystem.GetTypeName(filetype))

	item.streamradio_path = path
	item.streamradio_name = name
	item.streamradio_filetype = filetype
	item.streamradio_parentpath = parentpath

	self.FileItems[namelower] = true

	return item
end

function PANEL:AddPlaylistItem(url, name, parentpath)
	if not self.PlaylistItems then return false end

	url = url or self.EditURLText:GetText()
	name = name or self.EditNameText:GetText()
	parentpath = parentpath or self.PlaylistItems["parentpath"]

	if url == "" then return false end
	if name == "" then return false end

	local id = #self.PlaylistItems + 1
	local item = self.Playlist:AddLine(id, name, url)
	if not IsValid(item) then return false end

	item.streamradio_url = url
	item.streamradio_name = name
	item.streamradio_id = id

	self.PlaylistItems[id] = {
		url = url,
		name = name,
		item = item
	}

	self.PlaylistItems["format"] = self.PlaylistItems["format"] or self.Format
	self.PlaylistItems["parentpath"] = parentpath

	self:MarkPlaylistTextShouldUpdate()
	return true
end

function PANEL:RemovePlaylistItem(item)
	if not IsValid(item) then return false end
	if not self.PlaylistItems then return false end
	if self:IsLoading() then return false end

	local id = item.streamradio_id

	self.PlaylistItems[id] = nil
	self.Playlist:RemoveLine(item:GetID())
	self:SelectPlaylistItem()
	self:CleanUpPlaylist()

	self:MarkPlaylistTextShouldUpdate()
	return true
end

function PANEL:ChangePlaylistItem(item, url, name)
	if not IsValid(item) then return false end
	if not self.PlaylistItems then return false end
	if self:IsLoading() then return false end

	url = url or self.EditURLText:GetText()
	name = name or self.EditNameText:GetText()
	if url == "" then return false end
	if name == "" then return false end

	item.streamradio_url = url or self.EditURLText:GetText()
	item.streamradio_name = name or self.EditNameText:GetText()

	local id = item.streamradio_id or 0
	if id <= 0 then return false end

	item:SetColumnText(1, id)
	item:SetColumnText(2, name)
	item:SetColumnText(3, url)

	self.PlaylistItems[id] = {
		url = url,
		name = name,
		item = item
	}

	self:MarkPlaylistTextShouldUpdate()
	return true
end

function PANEL:SelectPlaylistItem( item )
	if not IsValid( item ) then
		self.Playlist:ClearSelection( )
		self.SelectedPlaylistItem = nil

		self.EditNameText:KillFocus()
		self.EditURLText:GetTextEntry():KillFocus()

		self.EditNameText:SetText( "" )
		self.EditURLText:SetText( "" )

		self:PlaylistCheckValid( )

		return false
	end

	if self:IsLoading( ) then return false end

	local url = item.streamradio_url
	local name = item.streamradio_name

	self.EditNameText:KillFocus()
	self.EditURLText:GetTextEntry():KillFocus()

	self.EditNameText:SetText( name )
	self.EditURLText:SetText( url )

	self:PlaylistCheckValid( )

	if self.SelectedPlaylistItem == item then return true end
	self.SelectedPlaylistItem = item
	self.Playlist:ClearSelection( )
	self.Playlist:SelectItem( item )

	return true
end

function PANEL:SwapItem( itemA, itemB )
	if ( not IsValid( itemA ) ) then return false end
	if ( not IsValid( itemB ) ) then return false end
	if ( not self.PlaylistItems ) then return false end
	if self:IsLoading( ) then return false end

	if ( itemA == itemB ) then return false end

	local idA = itemA.streamradio_id or 0
	if ( idA <= 0 ) then return false end
	if ( idA > #self.PlaylistItems ) then return false end

	local idB = itemB.streamradio_id or 0
	if ( idB <= 0 ) then return false end
	if ( idB > #self.PlaylistItems ) then return false end

	if ( idA == idB ) then return false end

	local lineA = self.PlaylistItems[idA]
	local lineB = self.PlaylistItems[idB]

	if ( not lineA ) then return false end
	if ( not lineB ) then return false end

	local temp = nil

	temp = lineA.item.streamradio_url
	lineA.item.streamradio_url = lineB.item.streamradio_url
	lineB.item.streamradio_url = temp

	temp = lineA.item.streamradio_name
	lineA.item.streamradio_name = lineB.item.streamradio_name
	lineB.item.streamradio_name = temp

	temp = lineA.url
	lineA.url = lineB.url
	lineB.url = temp

	temp = lineA.name
	lineA.name = lineB.name
	lineB.name = temp

	lineA.item:SetColumnText( 2, lineA.name )
	lineA.item:SetColumnText( 3, lineA.url )

	lineB.item:SetColumnText( 2, lineB.name )
	lineB.item:SetColumnText( 3, lineB.url )

	self:CleanUpPlaylist()

	self:MarkPlaylistTextShouldUpdate()
	return true
end

function PANEL:MovePlaylistItemUp( item )
	if ( not IsValid( item ) ) then return false end
	if ( not self.PlaylistItems ) then return false end
	if self:IsLoading( ) then return false end

	local id = item.streamradio_id or 0
	if ( id <= 1 ) then return false end

	local nextitem = nil
	for k, Line in pairs( self.Playlist.Sorted or self.Playlist:GetLines() or {} ) do
		if ( not Line.streamradio_id ) then continue end
		if ( not item.streamradio_id ) then continue end

		if (Line.streamradio_id ~= item.streamradio_id) then
			nextitem = Line
			continue
		end
		break
	end

	if ( not self:SwapItem( item, nextitem ) ) then return false end
	if ( not self:SelectPlaylistItem( nextitem ) ) then return false end

	self:MarkPlaylistTextShouldUpdate()
	return true
end

function PANEL:MovePlaylistItemDown( item )
	if ( not IsValid( item ) ) then return false end
	if ( not self.PlaylistItems ) then return false end
	if self:IsLoading( ) then return false end

	local id = item.streamradio_id or 0
	if ( id > #self.PlaylistItems ) then return false end

	local nextitem = nil
	for k, Line in pairs( self.Playlist.Sorted or self.Playlist:GetLines() or {} ) do
		if ( not Line.streamradio_id ) then continue end
		if ( not item.streamradio_id ) then continue end

		if (Line.streamradio_id == item.streamradio_id) then
			nextitem = Line
			continue
		end
		if ( not IsValid( nextitem ) ) then continue end

		if (nextitem.streamradio_id == item.streamradio_id) then
			nextitem = Line
			break
		end
	end

	if ( not self:SwapItem( item, nextitem ) ) then return false end
	if ( not self:SelectPlaylistItem( nextitem ) ) then return false end

	self:MarkPlaylistTextShouldUpdate()
	return true
end

function PANEL:ApplyPlaylistSort( )
	if not self.PlaylistItems then
		self.PlaylistItems = {}
		return
	end

	local tmpTab = self:GetEmptyPlaylistItems()
	local i = 0

	for k, v in pairs( self.Playlist.Sorted or self.Playlist:GetLines() or {} ) do
		if ( not IsValid( v ) ) then continue end

		v.streamradio_name = v.streamradio_name or ""
		v.streamradio_url = v.streamradio_url or ""

		if ( v.streamradio_name == "" ) then continue end
		if ( v.streamradio_url == "" ) then continue end

		i = i + 1
		v.streamradio_id = i

		v:SetColumnText( 1, v.streamradio_id )
		v:SetColumnText( 2, v.streamradio_name )
		v:SetColumnText( 3, v.streamradio_url )

		tmpTab[i] =  {
			url = v.streamradio_url,
			name = v.streamradio_name,
			item = v
		}
	end

	self.PlaylistItems = tmpTab
	self:MarkPlaylistTextShouldUpdate()
end

function PANEL:CleanUpPlaylist( )
	if not self.PlaylistItems then
		self.PlaylistItems = {}
		return
	end

	local tmpTab = self:GetEmptyPlaylistItems()
	local i = 0

	for k, v in pairs( self.PlaylistItems ) do
		if isstring( k ) then
			continue
		end

		local item = v.item
		if ( not IsValid( item ) ) then continue end

		item.streamradio_url = v.url or ""
		item.streamradio_name = v.name or ""

		if ( item.streamradio_name == "" ) then continue end
		if ( item.streamradio_url == "" ) then continue end

		i = i + 1
		item.streamradio_id = i

		item:SetColumnText( 1, item.streamradio_id )
		item:SetColumnText( 2, item.streamradio_name )
		item:SetColumnText( 3, item.streamradio_url )

		tmpTab[i] = {
			url = item.streamradio_url,
			name = item.streamradio_name,
			item = item
		}
	end

	self.PlaylistItems = tmpTab
	self:MarkPlaylistTextShouldUpdate()
end

function PANEL:GetPath( )
	return self.m_strPath, self.Format
end

function PANEL:SetPath( filepath, filetype, force, nofullclear )
	filepath = filepath or ""
	filepath = string.Trim( filepath, "\\" )
	filepath = string.Trim( filepath, "/" )
	filepath = string.Trim( filepath, "\\" )
	filepath = string.Trim( filepath, "/" )

	filetype = filetype or StreamRadioLib.TYPE_FOLDER
	local isFolder = StreamRadioLib.Filesystem.IsFolder(filetype)

	local function LoadFile( self, isFolder, filepath, filetype )
		if self:IsLoading() then return end

		if isFolder then
			if nofullclear then
				self:ClearFiles( )
			else
				self:Clear( )
			end

			self:Lock( true )
			self.m_strFolderPath = filepath
		else
			self:ClearPlaylist()
			self:Lock( true )

			local folderpath = string.GetPathFromFilename( filepath ) or ""
			folderpath = string.Trim( folderpath, "\\" )
			folderpath = string.Trim( folderpath, "/" )
			folderpath = string.Trim( folderpath, "\\" )
			folderpath = string.Trim( folderpath, "/" )

			self.m_strFolderPath = folderpath
		end

		self.m_strPath = filepath
		self.Format = filetype

		local backpath = string.GetPathFromFilename( filepath ) or ""

		if filepath ~= "" and not IsValid(self.BackItem) and isFolder then
			self.BackItem = self.Files:AddLine( "../", "" )
			self.BackItem.streamradio_path = backpath
			self.BackItem.streamradio_filetype = StreamRadioLib.TYPE_FOLDER
		end

		self:UpdateListNameLabel()

		local ListenID = StreamRadioLib.Editor.ListenToPath( filepath )
		StreamRadioLib.Editor.SetCallback( self.Callback, self )

		LIBNet.Start( "Editor_Request_Files" )
			StreamRadioLib.NetSendFileEditor( filepath, "", filetype or StreamRadioLib.TYPE_FOLDER, ListenID )
		net.SendToServer( )
	end

	if force or isFolder then
		LoadFile( self, isFolder, filepath, filetype )
	else
		AsForSave( self, LoadFile, isFolder, filepath, filetype )
	end
end

function PANEL:SetUnsaved( bool )
	self.m_bUnsaved = bool

	if not bool then
		self.NewFileItem = nil
	end

	self:UpdateListNameLabel( )
end

function PANEL:UpdateListNameLabel( )
	if not IsValid(self.ListNameLabel) then return end
	self.ListNameLabel:SetText((self.m_bUnsaved and "*" or "") .. (self.m_strPath or ""))
end

vgui.Register( "Streamradio_VGUI_PlaylistEditor", PANEL, "DPanel" )

return true

