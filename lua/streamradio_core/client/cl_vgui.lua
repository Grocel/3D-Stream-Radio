local StreamRadioLib = StreamRadioLib or {}
local LIBError = StreamRadioLib.Error


local PANEL = {}
AccessorFunc( PANEL, "m_strValue", "Value" )
AccessorFunc( PANEL, "m_strValue", "Text" )

local STATE_FOUND = 2
local STATE_ERROR = 1
local STATE_IDLE = 0

function PANEL:Init( )
	self:SetPaintBackground( false )
	self.URLIcon = self:Add( "DImageButton" )
	self.URLIcon:SetImage( "icon16/arrow_refresh.png" )
	self.URLIcon:SetWide( 20 )
	self.URLIcon:Dock( RIGHT )
	self.URLIcon:SetStretchToFit( false )
	self.URLIcon:DockMargin( 0, 0, 0, 0 )

	self.URLIcon.DoClick = function( panel )
		if not IsValid(self) then
			return
		end

		self.URLText:OnEnter()
	end

	self.URLIcon.DoRightClick = function( panel )
		if not IsValid(self) then
			return
		end

		local stream = self.Stream
		if not IsValid(stream) then
			return
		end

		local err = self.Error
		local url = stream:GetURL()

		if not err then
			return
		end

		if err == 0 then
			return
		end

		if url == "" then
			return
		end

		StreamRadioLib.ShowErrorHelp(err, url)
	end

	self.URLText = self:Add( "DTextEntry" )
	self.URLText:SetDrawLanguageID( false )
	self.URLText:SetUpdateOnType( true )
	self.URLText:SetHistoryEnabled( true )
	self.URLText:SetEnterAllowed( false )
	self.URLText:Dock( FILL )
	self.URLText:DockMargin( 0, 0, 2, 0 )

	if self.URLText.SetPlaceholderText then
		-- Some client have some addon conflicts
		-- This causes them to not have the panel:SetPlaceholderText() function

		self.URLText:SetPlaceholderText("Enter file path or online URL")
	end

	self.URLTooltip = [[
You can enter this:
   - A path of a sound file inside and relative to your game's sound folder. Mounted content is supported and included.
   - An URL to an online file or stream. The URL must lead to valid sound content. (No HTML, no Flash, no Videos)
]]

	self.URLTooltip = string.Trim(self.URLTooltip)
	self.URLText:SetTooltip(self.URLTooltip)

	self.URLText.OnValueChange = function( panel, value, ... )
		if not IsValid(self) then
			return
		end

		self.m_strValue = tostring(value or "")
		self:CheckURL()

		if panel._OnEnterCall then
			self:OnEnter(value, ...)
		else
			self:OnChange(value, ...)
		end

		panel._OnEnterCall = nil
	end

	self.URLText.OnEnter = function( panel, ... )
		if not IsValid(self) then
			return
		end

		panel._OnEnterCall = true
		panel:OnValueChange(panel:GetValue())
	end

	local oldOnLoseFocus = self.URLText.OnLoseFocus

	self.URLText.OnLoseFocus = function( panel, ... )
		if not IsValid(self) then
			return
		end

		panel:OnEnter()
		self:OnLoseFocus(...)

		return oldOnLoseFocus( panel, ... )
	end

	self:SetValue("")
end

function PANEL:GetOrCreateStream()
	if not StreamRadioLib and StreamRadioLib.Loaded then
		if IsValid(self.Stream) then
			self.Stream:Remove()
		end

		self.Stream = nil
		self.Error = nil

		return nil
	end

	if IsValid(self.Stream) then
		return self.Stream
	end

	local stream = StreamRadioLib.CreateOBJ("stream")
	if not IsValid( stream ) then
		self.Stream = nil
		self.Error = nil

		return nil
	end

	stream:Set3D(false)
	stream:SetLoop(false)
	stream:SetVolume(0)

	stream.OnConnect = function( thisStream, channel )
		thisStream:Stop()

		if not IsValid(self) then
			return
		end

		self.Error = nil
		self:UpdateURLState(STATE_FOUND)
	end

	stream.OnError = function( thisStream, err )
		thisStream:Stop()

		if not IsValid(self) then
			return
		end

		self.Error = err
		self:UpdateURLState(STATE_ERROR)
	end

	stream.OnRetry = function( thisStream, err )
		if not IsValid(self) then
			return false
		end

		self:UpdateURLState(STATE_IDLE)
		return true
	end

	stream.OnSearch = function( thisStream, err )
		if not IsValid( self ) then
			return false
		end

		self:UpdateURLState(STATE_IDLE)
		return true
	end

	stream.OnDownload = function( thisStream, url, interface )
		return false
	end

	self.Stream = stream
	return stream
end

function PANEL:SetValue(value)
	self.m_strValue = tostring(value or "")
	self.URLText:SetValue(self.m_strValue)
	self:CheckURL()
end

function PANEL:SetText(value)
	self.m_strValue = tostring(value or "")
	self.URLText:SetText(self.m_strValue)
	self:CheckURL()
end

function PANEL:GetTextEntry()
	return self.URLText
end

function PANEL:SetConVar(convar)
	self.URLText:SetConVar(convar)
end

function PANEL:UpdateURLState(state)
	if state == STATE_IDLE then
		self.URLIcon:SetImage("icon16/arrow_refresh.png")
		self.URLIcon:SetTooltip("Checking URL...")
		self.URLText:SetTooltip(self.URLTooltip .. "\n\nChecking URL...")

		StreamRadioLib.VR.RenderMenu(self)
		self:InvalidateLayout()
		return
	end

	local err = self.Error or 0
	local url = ""

	if IsValid(self.Stream) then
		url = self.Stream:GetURL()
	end

	if state == STATE_ERROR then

		local tooltipbase = "The URL is not valid!"
		local tooltip = ""
		local tooltipurl = ""

		if err ~= 0 and url ~= "" then
			self.URLIcon:SetImage("icon16/cross.png")

			local errorInfo = LIBError.GetStreamErrorInfo(err)

			local errorName = errorInfo.name
			local errorDescription = errorInfo.description

			local errorString = string.format("Error %i (%s): %s", err, errorName, errorDescription)

			tooltip = tooltipbase .. "\n" .. errorString .. "\n\nRight click for more details."
			tooltipurl = tooltipbase .. "\n" .. errorString .. "\n\nRight click on the red cross button for more details."
		else
			self.URLIcon:SetImage("icon16/information.png")
			tooltip = "The URL is empty!"
		end

		tooltip = string.Trim(tooltip)
		tooltipurl = string.Trim(tooltipurl)

		self.URLIcon:SetTooltip(tooltip)
		self.URLText:SetTooltip(string.Trim(self.URLTooltip .. "\n\n" .. tooltipurl))

		self:OnURLCheck(false, err, url)

		StreamRadioLib.VR.RenderMenu(self)
		self:InvalidateLayout()

		return
	end

	if state == STATE_FOUND then
		self.URLIcon:SetImage("icon16/accept.png")
		self.URLIcon:SetTooltip("The URL is valid!")
		self.URLText:SetTooltip(self.URLTooltip)

		self:OnURLCheck(true, err, url)

		StreamRadioLib.VR.RenderMenu(self)
		self:InvalidateLayout()

		return
	end
end

function PANEL:CheckURL()
	local stream = self:GetOrCreateStream()

	if IsValid(stream) then
		stream:TimerRemove("gui_url_checker")
	end

	self:UpdateURLState(STATE_IDLE)

	if not IsValid(stream) then
		self.Error = nil
		self:UpdateURLState(STATE_ERROR)
		return
	end

	if not self.m_strValue then
		self.Error = nil
		self:UpdateURLState(STATE_ERROR)
		stream:SetURL("")
		stream:Stop()

		return false
	end

	if self.m_strValue == "" then
		self.Error = nil
		self:UpdateURLState(STATE_ERROR)
		stream:SetURL("")
		stream:Stop()

		return false
	end

	stream:TimerOnce("gui_url_checker", 1, function()
		if not IsValid(stream) then
			return
		end

		if not IsValid(self) then
			return
		end

		self:UpdateURLState(STATE_IDLE)
		stream:SetURL(self.m_strValue)
		stream:Play()
	end)

	return true
end

function PANEL:OnRemove()
	if IsValid(self.Stream) then
		self.Stream:TimerRemove("gui_url_checker")
		self.Stream:Remove()
		self.Stream = nil
	end

	if IsValid(self.URLIcon) then
		self.URLIcon:Remove()
		self.URLIcon = nil
	end

	if IsValid(self.URLText) then
		self.URLText:Remove()
		self.URLText = nil
	end

	if IsValid(self.WireSoundBrowserIcon) then
		self.WireSoundBrowserIcon:Remove()
		self.WireSoundBrowserIcon = nil
	end
end

-- Override
function PANEL:OnEnter( ... )
end

-- Override
function PANEL:OnChange( ... )
end

-- Override
function PANEL:OnLoseFocus( ... )
end

-- Override
function PANEL:OnURLCheck( ... )
end

vgui.Register( "Streamradio_VGUI_URLTextEntry", PANEL, "DPanel" )

local PANEL = {}

function PANEL:Init( )
	self:SetEditable( true )
	self:SetMultiline( true )
	self:SetDrawLanguageID( false )
	self:SetTabbingDisabled( true )
	self:SetHistoryEnabled( false )
	self:SetEnterAllowed( false )
	self:SetDrawBorder( false )
	self:SetPaintBackground( false )
	self:SetUpdateOnType( true )
	self:SetNumeric( false )
	self:SetVerticalScrollbarEnabled( false )
	self:SetHistoryEnabled( false )
	self:SetCursorColor( Color( 0, 0, 0, 0 ) )
	self:SetCursor( "arrow" )

	self._SetText = self.SetText
	self.SetText = function(this, text, ...)
		this.m_text = tostring(text or "")
		this:_SetText(this.m_text, ...)
	end
end

function PANEL:OnValueChange()
	self:_SetText(self.m_text or "")
end

vgui.Register( "Streamradio_VGUI_ReadOnlyTextEntry", PANEL, "DTextEntry" )

