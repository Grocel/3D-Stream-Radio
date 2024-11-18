local StreamRadioLib = StreamRadioLib

local LIBError = StreamRadioLib.Error
local LIBUrl = StreamRadioLib.Url

local PANEL = {}
AccessorFunc( PANEL, "m_showLimit", "ShowLimit" )
AccessorFunc( PANEL, "m_maxLength", "MaxLength" )

function PANEL:Init()
	self:SetShowLimit(false)
	self:SetMaxLength(0)

	self:SetDrawLanguageID(false)
end

function PANEL:PaintOver(w, h)
	if not self:IsEditing() then
		return
	end

	if not self:GetShowLimit() then
		return
	end

	local maxLen = self:GetMaxLength()
	if maxLen <= 0 then
		return
	end

	local len = #self:GetText()

	local cx, cy = self:LocalCursorPos()

	local text = string.format("%i / %i", len, maxLen)

	surface.SetFont(self:GetFont())
	local tw, th = surface.GetTextSize(text)

	local tpw, tph = tw + 6, th + 6

	tpw = math.min(tpw, w - 2)
	tph = math.min(tph, h - 2)

	local tpx, tpy = w - tpw - 1, h - tph - 1

	tpx = math.max(tpx, 0)
	tpy = math.max(tpy, 0)

	if cx >= tpx - 5 and cy >= tpy - 10 and cx < w and cy < h then
		return
	end

	surface.SetDrawColor(190, 255, 255)
	surface.DrawRect(tpx, tpy, tpw, tph)

	surface.SetTextColor( 0, 0, 0)
	surface.SetTextPos(tpx + 3, tpy + 3)
	surface.DrawText(text)
end

function PANEL:GetLength()
	local value = self:GetText()
	return #value
end

function PANEL:AllowInput(change)
	local maxLen = self:GetMaxLength()
	if maxLen <= 0 then
		return false
	end

	local valueLen = self:GetLength()
	local changeLen = #change
	local len = valueLen + changeLen

	if len > maxLen then
		-- Limit reached
		return true
	end

	return false
end

vgui.Register( "Streamradio_VGUI_TextEntryWithLimit", PANEL, "DTextEntry" )


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

		self.URLText:OnEnter(self.URLText:GetText())
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

	self.URLText = self:Add( "Streamradio_VGUI_TextEntryWithLimit" )
	self.URLText:SetDrawLanguageID(false)
	self.URLText:SetUpdateOnType(true)
	self.URLText:SetHistoryEnabled(false)
	self.URLText:SetEnterAllowed(true)
	self.URLText:SetMultiline(true)
	self.URLText:Dock(FILL)
	self.URLText:DockMargin( 0, 0, 2, 0 )

	self.URLText:SetShowLimit(true)
	self.URLText:SetMaxLength(StreamRadioLib.STREAM_URL_MAX_LEN_ONLINE)

	if self.URLText.SetPlaceholderText then
		-- Some client have addon conflicts
		-- This causes them to not have the panel:SetPlaceholderText() function

		self.URLText:SetPlaceholderText("Enter file path or online URL")
	end

	self.URLTooltip = StreamRadioLib.STREAM_URL_INFO
	self.URLText:SetTooltip(self.URLTooltip)

	local function callChangeEvent(panel, value, enter)
		local newValue = LIBUrl.SanitizeUrl(value)

		self.m_strValue = newValue
		self:CheckURL()

		if enter then
			self:OnEnter(newValue)
		else
			self:OnChange(newValue)
		end
	end

	local oldGetText = self.URLText.GetText
	self.URLText.GetText = function( panel, change )
		local value = oldGetText(panel)

		value = LIBUrl.SanitizeUrl(value)

		return value
	end

	local oldOnValueChange = self.URLText.OnValueChange
	self.URLText.OnValueChange = function( panel, value, ... )
		if not IsValid(self) then
			return oldOnValueChange( panel, value, ... )
		end

		callChangeEvent(panel, value, false)

		return oldOnValueChange( panel, newValue, ... )
	end

	local oldOnKeyCode = self.URLText.OnKeyCode
	self.URLText.OnKeyCode = function( panel, code, ... )
		oldOnKeyCode( panel, code, ... )

		if not IsValid(self) then
			return
		end

		if code == KEY_ENTER or
			code == KEY_PAD_ENTER or
			code == KEY_ESCAPE
		then
			timer.Simple(0, function()
				if not IsValid(self) then
					return
				end

				if not IsValid(panel) then
					return
				end

				local text = panel:GetText()
				panel:SetText(text)

				panel:OnEnter(text)
				panel:FocusNext()
			end)
		end
	end

	local oldOnEnter = self.URLText.OnEnter
	self.URLText.OnEnter = function( panel, ... )
		if not IsValid(self) then
			return oldOnEnter( panel, ... )
		end

		local value = panel:GetText()
		local newValue = LIBUrl.SanitizeUrl(value)

		if value ~= newValue then
			panel:SetText(newValue)
		end

		callChangeEvent(panel, newValue, true)

		return oldOnEnter( panel, ... )
	end

	local oldOnLoseFocus = self.URLText.OnLoseFocus

	self.URLText.OnLoseFocus = function( panel, ... )
		if not IsValid(self) then
			return oldOnLoseFocus( panel, ... )
		end

		panel:OnEnter(panel:GetText())
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

	stream.OnRetry = function( thisStream )
		if not IsValid(self) then
			return false
		end

		self:UpdateURLState(STATE_IDLE)
		return true
	end

	stream.OnSearch = function( thisStream )
		if not IsValid( self ) then
			return false
		end

		self:UpdateURLState(STATE_IDLE)
		return true
	end

	stream.CanSkipUrlChecks = function( thisStream )
		if not IsValid( self ) then
			return false
		end

		-- This stream is for the local client only and safe to use.
		-- No whitelist is needed here. Avoids UX problems also.
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

function PANEL:SetShowLimit(showLimit)
	self.URLText:SetShowLimit(showLimit)
end

function PANEL:GetShowLimit()
	return self.URLText:GetShowLimit()
end

function PANEL:SetMaxLength(maxLen)
	self.URLText:SetMaxLength(maxLen)
end

function PANEL:GetMaxLength()
	return self.URLText:GetMaxLength()
end

function PANEL:SetMultiline(multiline)
	self.URLText:SetMultiline(multiline)
end

function PANEL:GetMultiline()
	return self.URLText:GetMultiline()
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
			local errorHasHelpmenu = errorInfo.helpmenu

			local errorString = string.format("Error %i (%s): %s", err, errorName, errorDescription)

			tooltip = tooltipbase .. "\n" .. errorString
			tooltipurl = tooltipbase .. "\n" .. errorString

			if errorHasHelpmenu then
				tooltip = tooltip .. "\n\nRight click for more details."
				tooltipurl = tooltip .. "\n\nRight click on the red cross button for more details."
			end
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
		return false
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

	stream:TimerOnce("gui_url_checker", 0.5, function()
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
end

function PANEL:OnEnter( ... )
	-- Override me
end

function PANEL:OnChange( ... )
	-- Override me
end

function PANEL:OnLoseFocus( ... )
	-- Override me
end

function PANEL:OnURLCheck( ... )
	-- Override me
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

	self._SetText = self._SetText or self.SetText
	self.SetText = function(this, text, ...)
		this.m_text = tostring(text or "")
		this:_SetText(this.m_text, ...)
	end
end

function PANEL:OnValueChange()
	self:_SetText(self.m_text or "")
	self:KillFocus()
end

vgui.Register( "Streamradio_VGUI_ReadOnlyTextEntry", PANEL, "DTextEntry" )

return true

