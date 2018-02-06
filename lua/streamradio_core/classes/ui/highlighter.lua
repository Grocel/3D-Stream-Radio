if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

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

	self:HighlightClear()
	self:SetSkinAble(false)
end

function CLASS:Remove()
	self:HighlightClear()
	BASE.Remove(self)
end

function CLASS:SetBorderColor(color)
	if SERVER then return end
	self.Colors.Border1 = color
end

function CLASS:SetBorderColor2(color)
	if SERVER then return end
	self.Colors.Border2 = color
end

function CLASS:GetBorderColor()
	if SERVER then return end
	local col = self.Colors.Border1

	return Color(col.r or 0, col.g or 0, col.b or 0, col.a or 0)
end

function CLASS:GetBorderColor2()
	if SERVER then return end
	local col = self.Colors.Border2

	return Color(col.r or 0, col.g or 0, col.b or 0, col.a or 0)
end

function CLASS:HighlightClear()
	self.Highlighted = {}
	self:QueueCall("PerformRerender")
end

function CLASS:HighlightPanel(panel)
	if not IsValid(panel) then return end
	if not CLIENT then return end

	self.Highlighted[panel] = true
	self:QueueCall("PerformRerender")
end

function CLASS:HighlightPanels(panels)
	for _, panel in pairs(panels or {}) do
		self:HighlightPanel(panel)
	end
end

function CLASS:GetHighlightedPanels()
	return table.GetKeys(self.Highlighted or {})
end

function CLASS:RenderHighlight(panel)
	if not CLIENT then return end
	if not IsValid(panel) then return end
	if not self:IsVisible() then return end
	if not panel:IsVisible() then return end

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

	surface.SetDrawColor(self.Colors.Main)
	surface.DrawRect(px, py, pw, ph)

	local col1 = self.Colors.Border1
	local col2 = self.Colors.Border2

	for i = 1, lines do
		local col = ((i % 2) == 0) and col2 or col1
		surface.SetDrawColor(col)

		for j = 0, thickness - 1 do
			local t = (i - 1) * thickness + j
			local tt = t * 2

			surface.DrawOutlinedRect(px - t, py - t, pw + tt, ph + tt)
		end
	end
end

function CLASS:Render()
	if not CLIENT then return end
	if not self:IsVisible() then return end

	for panel, bool in pairs(self.Highlighted or {}) do
		if not bool then continue end

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
