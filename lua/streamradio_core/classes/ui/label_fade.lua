local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

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

		self:StartFastThink()
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

function CLASS:ShouldPerformRerender()
	if SERVER then return false end

	local phase = self:GetPhase()
	if phase >= 1 then return false end
	if phase <= 0 then return false end

	return true
end

if CLIENT then
	function CLASS:FastThink()
		self.fastThinkRate = 0.25

		if not self:IsSeen() then return end
		if not self:IsVisible() then return end

		self.fastThinkRate = 0.1

		self:CalcTime()
		self.TextData.TextIndex = self:GetIndex()

		if not self:ShouldPerformRerender() then return end
		self.fastThinkRate = 0

		self:PerformRerender(true)
	end
end

function CLASS:Render()
	local x, y = self:GetRenderPos()
	local w, h = self:GetSize()

	local colText = self:GetTextColor()
	local cR, cG, cB, cA = colText:Unpack()

	local phase = self:GetPhase()
	cA = cA * phase

	local font = self.TextData.Font

	surface.SetFont(font)
	surface.SetTextColor(cR, cG, cB, cA)

	self:DrawText(self.InternalText, x, y, w, h)
end

return true

