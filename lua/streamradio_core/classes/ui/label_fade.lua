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

	if CLIENT then
		self.TextData.FadeTime = 1
		self.TextData.StayTime = 10
		self.TextData.TextIndex = 0

		self.TextData = self.TextData + function(this, k, v)
			if k == "FadeTime" then
				self:Reset()
			end

			if k == "StayTime" then
				self:Reset()
			end

			if k == "TextIndex" then
				self:SwitchText()
			end
		end
	end

	self.TextList = {}
	self:SetSkinAble(false)

	self:Reset()
	self:SwitchText()
end

function CLASS:SwitchText()
	if SERVER then return end

	local textlist = self.TextList or {}
	local count = #textlist

	if count <= 0 then
		count = 1
	end

	local index = self.TextData.TextIndex % count + 1
	self:SetText(textlist[index])
end

function CLASS:CalcTime()
	local textlist = self.TextList or {}
	local count = #textlist

	if count <= 1 then return end

	local thistime = RealTime()
	local oldlt = self._lt or thistime
	self._lt = thistime

	self.TickTime = thistime - oldlt
	self.ObjectTime = self.ObjectTime or 0

	self.ObjectTime = self.ObjectTime + self.TickTime
end

function CLASS:GetIndex()
	if SERVER then return end

	local textlist = self.TextList or {}
	local count = #textlist

	if count <= 0 then
		count = 1
	end

	local time = self.ObjectTime or 0

	local fadetime = self.TextData.FadeTime
	local staytime = self.TextData.StayTime
	local totaltime = fadetime * 2 + staytime

	local index = math.floor(time / totaltime) % count
	return index
end

function CLASS:GetPhase()
	if SERVER then return end

	local time = self.ObjectTime or 0

	local fadetime = self.TextData.FadeTime
	local staytime = self.TextData.StayTime

	local totaltime = fadetime * 2 + staytime

	time = time % totaltime

	local fadeinend = fadetime
	local fadeoutstart = fadeinend + staytime
	local fadeoutend = staytime + fadetime

	if time < fadeinend then
		return math.Clamp(time / fadetime, 0, 1)
	end

	if time >= fadeinend and time < fadeoutstart then
		return 1
	end

	if time >= fadeoutstart and time < totaltime then
		return math.Clamp(1 - (time - fadeoutstart) / fadetime, 0, 1)
	end

	return 0
end

function CLASS:ResetTime()
	self.ObjectTime = self.TextData.FadeTime
end

function CLASS:Reset()
	self.ObjectTime = self.TextData.FadeTime
	self.TextData.TextIndex = 0
	self:SwitchText()
end

function CLASS:ClearList()
	self.TextList = nil
	self:Reset()
end

function CLASS:AddToList(text)
	if SERVER then return end

	self.TextList = self.TextList or {}

	text = tostring(text or "")
	table.insert(self.TextList, text)

	self:SwitchText()
end

function CLASS:SetList(textlist)
	if SERVER then return end

	self.TextList = textlist or {}
	self:SwitchText()
end

function CLASS:SuperThink()
	if SERVER then return end

	if not self:IsSeen() then return end
	if not self:IsVisible() then return end

	self:CalcTime()
	self:PerformRerender(true)
end

function CLASS:Render()
	self:CalcTime()

	self.TextData.TextIndex = self:GetIndex()

	local x, y = self:GetRenderPos()
	local w, h = self:GetSize()

	local col = self:GetTextColor()
	local font = self.TextData.Font

	surface.SetFont( font )
	local phase = self:GetPhase()
	local alpha = col.a * phase

	col.a = alpha
	surface.SetTextColor( col )
	self:DrawText(self.InternalText, x, y, w, h)
end
