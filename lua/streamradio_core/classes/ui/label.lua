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

local function normalize_text(text)
	text = tostring(text or "")
	text = string.gsub(text, "[\r\n]", "" )
	text = string.gsub(text, "\t", "    " )

	return text
end

function CLASS:Create()
	BASE.Create(self)

	self.Clickable = false

	self.TextData = self:CreateListener({
		Text = "",
		Font = "DermaDefault",

		AlignX = TEXT_ALIGN_LEFT,
		AlignY = TEXT_ALIGN_TOP,

		Shorter = "...",
		ShorterEnd = true,
	}, function(this, k, v)
		self:InvalidateLayout()

		if CLIENT then
			self:QueueCall("UpdateText")
		end

		local hookname = changehooks[k]
		if not hookname then return end

		self:CallHook(hookname)
	end)

	if CLIENT then
		self.InternalText = ""
		self.Size = self.Size + function(this, k, v)
			if k ~= "w" then return end
			self:QueueCall("UpdateText")
		end

		self.Colors.Main = Color(0,0,0)
	end

	self:SetSkinAble(false)
end

function CLASS:UpdateText()
	if SERVER then return end

	self.InternalText = self:TextFit(self.TextData.Text, self:GetWidth())
	self:PerformRerender(true)
end

function CLASS:ShortText(text, len)
	if len <= 0 then
		return ""
	end

	local shorter = self.TextData.Shorter

	if self.TextData.ShorterEnd then
		return string.sub(text, 0, len) .. shorter
	end

	return shorter .. string.sub(text, -len)
end

function CLASS:GuessLen(text, width, func)
	local len2power = 2 ^ math.ceil(math.log(#text) / math.log(2))
	local len = len2power

	local repeattimes = 4

	while true do
		local bigger = func(self, text, len, width)
		local repeated = false

		if len2power <= 1 then
			if repeattimes <= 0 then
				break
			end

			repeattimes = repeattimes - 1
			repeated = true
		end

		if bigger > 0 then
			if repeated and repeattimes <= 1 then
				break
			end

			len2power = math.ceil(len2power / 2)
			len = len + len2power
			continue
		end

		if bigger < 0 then
			len2power = math.ceil(len2power / 2)
			len = len - len2power
			continue
		end

		break
	end

	return len
end

function CLASS:TryTextFit(text, len, width)
	local newstring = self:ShortText(text, len)

	if newstring == "" then
		return 1
	end

	surface.SetFont( self.TextData.Font )
	local w = surface.GetTextSize( newstring ) or 0
	local bigger = width - w

	return bigger
end

function CLASS:TextFit(text, width)
	if SERVER then return "" end

	if text == "" then
		return ""
	end

	if width <= 0 then
		return ""
	end

	surface.SetFont( self.TextData.Font )
	local w = surface.GetTextSize( text ) or 0
	if w <= 0 then
		return ""
	end

	if (w <= width) then
		return text
	end

	local len = self:GuessLen(text, width, self.TryTextFit)
	local newstring = self:ShortText(text, len)

	return newstring
end

function CLASS:DrawText( text, x, y, w, h )
	text = text or ""
	if text == "" then
		return
	end

	local tx, ty = x, y
	local xalign, yalign = self.TextData.AlignX, self.TextData.AlignY
	local tsw, tsh = surface.GetTextSize( text )

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

	self:DrawText(self.InternalText, x, y, w, h)
end

function CLASS:SetTextColor(...)
	return self:SetColor(...)
end

function CLASS:GetTextColor(...)
	return self:GetColor(...)
end

function CLASS:SetText(text)
	self.TextData.Text = normalize_text(text)
end

function CLASS:GetText()
	return self.TextData.Text or ""
end

function CLASS:GetTextSize()
	if SERVER then return 0, 0 end

	surface.SetFont(self.TextData.Font)
	local w, h = surface.GetTextSize(self.TextData.Text)
	return w or 0, h or 0
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
	self.TextData.AlignX = alignX or TEXT_ALIGN_LEFT
	self.TextData.AlignY = alignY or TEXT_ALIGN_TOP
end

function CLASS:GetAlign()
	if SERVER then return end
	return self.TextData.AlignX or TEXT_ALIGN_LEFT, self.TextData.AlignY or TEXT_ALIGN_TOP
end

function CLASS:SetShorter(text)
	if SERVER then return end
	self.TextData.Shorter = normalize_text(text)
end

function CLASS:GetShorter()
	if SERVER then return end
	return self.TextData.Shorter or ""
end

function CLASS:SetShorterAtEnd(bool)
	if SERVER then return end
	self.TextData.ShorterEnd = bool or false
end

function CLASS:GetShorterAtEnd()
	if SERVER then return end
	return self.TextData.ShorterEnd or false
end

function CLASS:AutoWidth(maxwidth)
	if SERVER then return end
	maxwidth = maxwidth or 0

	local textw = self:GetTextSize()
	textw = math.Clamp(textw, 0, maxwidth)

	self:SetWidth(textw)
end

function CLASS:AutoHeight(maxheight)
	if SERVER then return end
	maxheight = maxheight or 0

	local _, texth = self:GetTextSize()
	texth = math.Clamp(texth, 0, maxheight)

	self:SetHeight(texth)
end

function CLASS:AutoSize(maxwidth, maxheight)
	if SERVER then return end
	maxwidth = maxwidth or 0
	maxheight = maxheight or 0

	local textw, texth = self:GetTextSize()
	textw = math.Clamp(textw, 0, maxwidth)
	texth = math.Clamp(texth, 0, maxheight)

	self:SetSize(textw, texth)
end

function CLASS:OnModelSetup(setup)
	BASE.OnModelSetup(self, setup)

	if setup.font then
		self:SetFont(setup.font)
	end
end

return true

