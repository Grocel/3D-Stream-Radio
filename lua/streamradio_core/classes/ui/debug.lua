if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()
local g_textcol = Color( 200, 200, 200, 255 )
local g_textcolbg = Color( 32, 32, 32, 160 )
local g_renderupdatetab = {"-", "\\", "|", "/"}

function CLASS:Create()
	BASE.Create(self)

	self.debugtexttab = {}
	self:SetZPos(9999999)
	self:SetSize(1,1)
	self:SetPos(0,0)

	local superparent = self:GetSuperParent()
	self._Highlighter = superparent:AddPanelByClassname("highlighter")

	self.bgwidth = 0
	self.renderupdatetab_index = 0
	self:SetSkinAble(false)
end

function CLASS:Remove()
	if IsValid(self._Highlighter) then
		self._Highlighter:Remove()
	end

	BASE.Remove(self)
end

function CLASS:GetUpdateIndicator()
	local index = self.renderupdatetab_index + 1
	local count = #g_renderupdatetab

	self.renderupdatetab_index = index % count
	return g_renderupdatetab[index]
end

function CLASS:Render()
	local x, y = self:GetRenderPos()
	local superparent = self:GetSuperParent()
	local highlighter = self._Highlighter

	local cx, cy = superparent:GetCursor()

	local think_time = self:GetGlobalVar("base_listener_thinktime", -1)
	local superthink_time = self:GetGlobalVar("base_listener_superthinktime", -1)
	local rendertarget_time = superparent:GetFrametime()
	local render_time = superparent:ProfilerTime("Render")
	local rendertarget_active = superparent:HasRendertarget()
	local rt_w, rt_h = superparent:GetRendertargetSize()
	local f_time = RealFrameTime()

	local think_time_p = math.Round(think_time / f_time * 100, 1)
	local superthink_time_p = math.Round(superthink_time / f_time * 100, 1)
	local rendertarget_time_p = math.Round(rendertarget_time / f_time * 100, 1)
	local render_time_p = math.Round(render_time / f_time * 100, 1)

	local aimedpanel = superparent:GetTopmostPanelAtCursor()

	self.debugtexttab[1] = string.format("X, Y: %i, %i", cx, cy)
	self.debugtexttab[2] = string.format("Update Indicator:         %s", self:GetUpdateIndicator())
	self.debugtexttab[3] = string.format("Rendertarget:             %s", rendertarget_active and "Yes" or "No")
	self.debugtexttab[4] = string.format("Rendertarget Size (W, H): %i, %i", rt_w, rt_h)
	self.debugtexttab[5] = ""

	self.debugtexttab[6] = string.format("Frame:                %7.3f ms", f_time * 1000)
	self.debugtexttab[7] = string.format("Think:                %7.3f ms | %5.1f%% of Frame", think_time * 1000, think_time_p)
	self.debugtexttab[8] = string.format("Fast Think:           %7.3f ms | %5.1f%% of Frame", superthink_time * 1000, superthink_time_p)
	self.debugtexttab[9] = string.format("Render (2D3D Render): %7.3f ms | %5.1f%% of Frame", render_time * 1000, render_time_p)
	self.debugtexttab[10] = string.format("Render (Content):     %7.3f ms | %5.1f%% of Frame", rendertarget_time * 1000, rendertarget_time_p)

	if IsValid(aimedpanel) then
		self.debugtexttab[11] = ""
		self.debugtexttab[12] = "Panel Info:"
		self.debugtexttab[13] = tostring(aimedpanel)
		self.debugtexttab[14] = string.format("Name Hierarchy:    %s", aimedpanel:GetName())
		self.debugtexttab[15] = string.format("Skin ID Hierarchy: %s", aimedpanel:GetSkinIdentifyerHierarchy())
	else
		self.bgwidth = 0
		self.debugtexttab[11] = nil
	end

	local bg_h = 0

	surface.SetFont( "DebugFixed" )
	surface.SetTextColor( g_textcol )

	for i, v in ipairs(self.debugtexttab) do
		if not v then break end

		local w, h = surface.GetTextSize( v )
		bg_h = bg_h + h + 1
		if w > self.bgwidth then
			self.bgwidth = w
		end
	end

	surface.SetDrawColor( g_textcolbg )
	surface.DrawRect( x, y, self.bgwidth + 6, bg_h + 5 )

	bg_h = 0

	for i, v in ipairs(self.debugtexttab) do
		if not v then break end

		local _, h = surface.GetTextSize( v )
		surface.SetTextPos( x + 3, y + 3 + bg_h )
		surface.DrawText(v)

		bg_h = bg_h + h + 1
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
