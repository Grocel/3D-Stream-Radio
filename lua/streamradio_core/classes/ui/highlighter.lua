local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

local LIBUtil = StreamRadioLib.Util

function CLASS:Create()
	BASE.Create(self)

	self:SetZPos(9999000)
	self:SetSize(1,1)
	self:SetPos(0,0)

	if CLIENT then
		self.Colors.Main = Color(160, 160, 255, 80)
		self.Colors.Border1 = Color(0, 0, 0, 200)
		self.Colors.Border2 = Color(255, 255, 255, 200)
	end

	if CLIENT then
		self.Highlighted = {}
	end

	self:SetSkinAble(false)
end

function CLASS:Remove()
	self:HighlightClear()
	BASE.Remove(self)
end

function CLASS:SetBorderColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.Border1 = color
end

function CLASS:SetBorderColor2(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.Border2 = color
end

function CLASS:GetBorderColor()
	if SERVER then return end

	local col = self.Colors.Border1
	return col
end

function CLASS:GetBorderColor2()
	if SERVER then return end

	local col = self.Colors.Border2
	return col
end

function CLASS:HighlightClear()
	if SERVER then return end

	LIBUtil.EmptyTableSafe(self.Highlighted)
	self:QueueCall("PerformRerender")
end

function CLASS:HighlightPanel(panel)
	if SERVER then return end
	if not IsValid(panel) then return end

	self.Highlighted[panel:GetID()] = panel
	self:QueueCall("PerformRerender")
end

function CLASS:HighlightPanels(panels)
	if SERVER then return end

	for _, panel in pairs(panels or {}) do
		self:HighlightPanel(panel)
	end
end

function CLASS:GetHighlightedPanels()
	if SERVER then return end

	return self.Highlighted
end

function CLASS:RenderHighlight(panel)
	if SERVER then return end

	if not IsValid(panel) then return end
	if not self:IsVisibleSimple() then return end
	if not panel:IsVisibleSimple() then return end

	local sp = self:GetSuperParent()
	local spx, spy = sp:GetRenderPos()
	local spw, sph = sp:GetSize()

	local px, py = panel:GetRenderPos()
	local pw, ph = panel:GetSize()

	local thickness = 2
	local lines = 4
	local padding = thickness * lines

	px = math.max(px, spx + padding)
	py = math.max(py, spy + padding)

	pw = math.min(pw, spw - padding * 2)
	ph = math.min(ph, sph - padding * 2)

	local colMain = self.Colors.Main or color_white

	surface.SetDrawColor(colMain:Unpack())
	surface.DrawRect(px, py, pw, ph)

	local col1 = self.Colors.Border1 or color_white
	local col2 = self.Colors.Border2 or color_black

	for i = 1, lines do
		local col = ((i % 2) == 0) and col2 or col1
		surface.SetDrawColor(col:Unpack())

		for j = 0, thickness - 1 do
			local t = (i - 1) * thickness + j
			local tt = t * 2

			surface.DrawOutlinedRect(px - t, py - t, pw + tt, ph + tt)
		end
	end
end

function CLASS:Render()
	for _, panel in pairs(self.Highlighted) do
		self:RenderHighlight(panel)
	end
end

function CLASS:IsInBounds(x, y)
	return false
end

function CLASS:SetModelSetup()
end

function CLASS:OnModelSetup()
end

function CLASS:ActivateNetworkedMode()
end

return true

