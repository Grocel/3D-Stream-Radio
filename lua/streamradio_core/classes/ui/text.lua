local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()
local changehooks = {
	Text = "OnTextChange",
	Font = "OnFontChange",
	AlignX = "OnAlignChange",
	AlignY = "OnAlignChange",
}

function CLASS:Create()
	BASE.Create(self)

	self.Clickable = false

	self.Lines = {}
	self.TextData = self:CreateListener({
		Text = "",
		Font = "DermaDefault",

		AlignX = TEXT_ALIGN_LEFT,
		AlignY = TEXT_ALIGN_TOP,
		StartLine = 1,
	}, function(this, k, v)
		self:InvalidateLayout()

		if k == "Text" then
			self:QueueCall("BuildLines")
		end

		if k == "Font" then
			self:QueueCall("BuildLines")
		end

		local hookname = changehooks[k]
		if not hookname then return end

		self:CallHook(hookname)
	end)

	if CLIENT then
		self.Size = self.Size + function(this, k, v)
			if k ~= "w" then return end
			self:QueueCall("BuildLines")
		end

		self.Colors.Main = Color(0, 0, 0)
	end

	self:SetSkinAble(false)
end

function CLASS:PerformLayout(...)
	BASE.PerformLayout(self, ...)

	self:DelCacheValue("GetTextSize")
	self:DelCacheValue("GetVisibleLines")
	self:DelCacheValue("GetTotalTextSize")
end

function CLASS:BuildLines(force)
	if SERVER then return end

	self:DelCacheValue("GetTextSize")
	self:DelCacheValue("GetVisibleLines")
	self:DelCacheValue("GetTotalTextSize")

	local font = self.TextData.Font
	local text = self.TextData.Text
	local w = self:GetSize()

	self:GetWidth()

	self.Lines = {}

	local line = {}
	local linew = 0

	surface.SetFont( font )
	local checksize = {"W", "M", "L", "I", "i", "l", ".", "g", "|", "_"}

	for k, v in ipairs(checksize) do
		local tsw = surface.GetTextSize(v)

		if tsw >= w then
			self:InvalidateLayout()
			return
		end
	end

	if text == "" then
		self:InvalidateLayout()
		return
	end

	text = string.gsub(text, "\r[\n]?", "\n")

	local function newline()
		local text = table.concat(line, "")
		table.insert(self.Lines, text)

		line = {}
		linew = 0
	end

	local function addtoline(text)
		text = text or ""
		local count = #line

		if count <= 0 then
			text = string.TrimLeft(text)
		end

		if text == "" then
			return
		end

		local tsw = surface.GetTextSize( text )
		local newlinew = linew + tsw

		-- Word to long, seperate it
		if tsw > w then
			for i = 1, #text do
				addtoline(text[i])
			end

			return
		end

		-- Line length reached, insert a new line
		if newlinew > w then
			newline()
			addtoline(text)
			return
		end

		line[count + 1] = text
		linew = newlinew
	end

	for n, s, w, p in string.gmatch( text, "([\n]?)([^%w%p_\n]*)([%w_]*)([%p]*)" ) do
		if n == "\n" then
			newline()
		end

		addtoline(s)
		addtoline(w .. p)
	end

	newline()

	self:InvalidateLayout()
	self:CallHook("OnBuildLines")
end

function CLASS:DrawText( text, x, y, w, h, tsw, tsh )
	text = text or ""
	if text == "" then return end

	local tx, ty = x, y
	local xalign, yalign = self.TextData.AlignX, self.TextData.AlignY

	if ( xalign == TEXT_ALIGN_CENTER ) then
		tx = x + w / 2 - tsw / 2
	elseif ( xalign == TEXT_ALIGN_RIGHT ) then
		tx = x + w - tsw
	end

	if ( yalign == TEXT_ALIGN_CENTER ) then
		ty = y + h / 2 - tsh / 2
	elseif ( yalign == TEXT_ALIGN_BOTTOM ) then
		ty = y + h - tsh
	end

	surface.SetTextPos( math.ceil( tx ), math.ceil( ty ) )
	surface.DrawText( text )
end

function CLASS:Render()
	BASE.Render(self)

	local x, y = self:GetRenderPos()
	local w, h = self:GetSize()

	local col = self.Colors.Main or color_black
	local font = self.TextData.Font

	surface.SetFont( font )
	surface.SetTextColor( col:Unpack() )

	local lines = self:GetVisibleLines()
	local _, texth = self:GetTextSize()

	for i, v in ipairs(lines) do
		local text = v.text
		local ox = v.x
		local oy = v.y
		local ow = v.w

		self:DrawText(text, x + ox, y + oy, w, h, ow, texth)
	end
end

function CLASS:SetTextColor(...)
	return self:SetColor(...)
end

function CLASS:GetTextColor(...)
	return self:GetColor(...)
end

function CLASS:SetText(text)
	self.TextData.Text = tostring(text or "")
end

function CLASS:GetText()
	return self.TextData.Text or ""
end

function CLASS:GetTotalTextSize()
	if SERVER then return 0, 0 end

	local chtextw, chtextw = self:GetCacheValues("GetTotalTextSize")
	if chtextw then return chtextw, chtextw end

	local textw = 0
	local texth = 0
	local count = self:GetLineCount()

	surface.SetFont(self.TextData.Font)

	for i = 1, count do
		local text = self.Lines[i] or ""
		local tsw, tsh = surface.GetTextSize( text )

		if textw < tsw then
			textw = tsw
		end

		local newlineh = texth + tsh + 1
		texth = newlineh
	end

	return self:SetCacheValues("GetTotalTextSize", textw, texth)
end

function CLASS:FitToText(minw, maxw)
	self:SetWidth(maxw)
	self:BuildLines()

	local w, h = self:GetTotalTextSize()
	w = math.Clamp(w, minw, maxw)

	self:SetSize(w, h)
end

function CLASS:GetTextSize()
	if SERVER then return 0, 0 end

	local chtextw, chtextw = self:GetCacheValues("GetTextSize")
	if chtextw then return chtextw, chtextw end

	local w, h = self:GetSize()

	local textw = 0
	local texth = 0

	local count = self:GetLineCount()
	local startline = self:GetStartLine()

	surface.SetFont(self.TextData.Font)

	for i = startline, count do
		local text = self.Lines[i] or ""
		local tsw, tsh = surface.GetTextSize( text )

		if textw < tsw then
			textw = tsw
		end

		local newlineh = texth + tsh + 1
		if newlineh > h then
			break
		end

		texth = newlineh
	end

	if textw > w then
		textw = w
	end

	if texth > h then
		texth = h
	end

	return self:SetCacheValues("GetTextSize", textw, texth)
end

function CLASS:GetVisibleLines()
	if SERVER then return end

	local chlines = self:GetCacheValue("GetVisibleLines")
	if chlines then return chlines end

	local liney = 0
	local _, texth = self:GetTextSize()

	local startline = self:GetStartLine()

	local lines = {}

	surface.SetFont(self.TextData.Font)

	local i = startline
	while (true) do
		local text = self.Lines[i] or ""
		local tsw, tsh = surface.GetTextSize( text )

		local newliney = liney + tsh + 1
		if newliney > texth then
			break
		end

		local data = {
			text = text,
			w = tsw,
			h = tsh,
			x = 0,
			y = liney,
		}

		table.insert(lines, data)
		liney = newliney
		i = i + 1
	end

	return self:SetCacheValue("GetVisibleLines", lines)
end

function CLASS:SetFont(font)
	if SERVER then return end
	self.TextData.Font = font or ""
end

function CLASS:GetFont()
	if SERVER then return end
	return self.TextData.Font or ""
end

function CLASS:SetAlign(alignX, alignY)
	if SERVER then return end
	self.TextData.AlignX = alignX or self.TextData.AlignX or TEXT_ALIGN_LEFT
	self.TextData.AlignY = alignY or self.TextData.AlignY or TEXT_ALIGN_TOP
end

function CLASS:GetAlign()
	if SERVER then return end
	return self.TextData.AlignX or TEXT_ALIGN_LEFT, self.TextData.AlignY or TEXT_ALIGN_TOP
end

function CLASS:SetStartLine(startline)
	if SERVER then return end
	self.TextData.StartLine = startline or 1
end

function CLASS:GetStartLine()
	if SERVER then return end

	local count = self:GetLineCount()
	local startline = math.Clamp(self.TextData.StartLine, 1, count)

	return startline
end

function CLASS:GetLineCount()
	if SERVER then return end
	return #self.Lines
end

function CLASS:OnModelSetup(setup)
	BASE.OnModelSetup(self, setup)

	if setup.font then
		self:SetFont(setup.font)
	end
end

return true

