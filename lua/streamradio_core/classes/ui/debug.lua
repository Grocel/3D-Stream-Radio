local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local LIBHook = StreamRadioLib.Hook
local LIBUtil = StreamRadioLib.Util

local emptyTableSafe = LIBUtil.EmptyTableSafe

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

	self.lastUpdateTimeStamp = 0
	self.lastUpdateTimeAvg = 0
	self.bgW = 0
	self.bgH = 0

	self.colW = {}
	self.colH = {}
	self.lastAimedpanel = nil

	self.renderupdatetab_index = 0
	self:SetSkinAble(false)
end

function CLASS:Remove()
	BASE.Remove(self)
end

function CLASS:GetUpdateIndicator()
	local index = self.renderupdatetab_index + 1
	local count = #g_renderupdatetab

	self.renderupdatetab_index = index % count
	return g_renderupdatetab[index]
end

function CLASS:EmptyLines(col)
	local debugtexttab = self.debugtexttab or {}
	self.debugtexttab = debugtexttab

	if col then
		local colTable = debugtexttab[col] or {}
		colTable = emptyTableSafe(colTable)

		debugtexttab[col] = colTable
		return
	end

	for i, colTable in pairs(debugtexttab) do
		colTable = colTable or {}
		colTable = emptyTableSafe(colTable)

		debugtexttab[i] = colTable
	end
end

function CLASS:AddLine(col, strFormat, ...)
	local debugtexttab = self.debugtexttab or {}
	self.debugtexttab = debugtexttab

	local colTable = debugtexttab[col] or {}
	debugtexttab[col] = colTable

	table.insert(colTable, string.format(strFormat, ...))
end

function CLASS:BuildLines()
	local now = RealTime()

	local lastUpdateTimeStamp = self.lastUpdateTimeStamp or 0
	self.lastUpdateTimeStamp = now

	local updateTime = now - lastUpdateTimeStamp
	self.lastUpdateTimeAvg = (self.lastUpdateTimeAvg + updateTime) / 2

	local updateTimeAvg = self.lastUpdateTimeAvg
	local updatesPerSecAvg = math.Round(1 / updateTimeAvg, 3)
	local superparent = self:GetSuperParent()

	local cx, cy = superparent:GetCursor()

	local think_time = self:GetGlobalVar("base_listener_thinktime", -1)
	local fastthink_time = self:GetGlobalVar("base_listener_fastthinktime", -1)
	local addonthink_time = LIBHook.GetBenchmark("Think")
	local addontick_time = LIBHook.GetBenchmark("Tick")
	local rendertarget_time = superparent:GetFrametime()
	local render_time = superparent:ProfilerTime("Render")
	local rendertarget_active = superparent:HasRendertarget()
	local rt_w, rt_h = superparent:GetRendertargetSize()

	local memory = collectgarbage("count")
	local radioCount = StreamRadioLib.GetRadioCount()
	local streamingRadioCount = StreamRadioLib.GetStreamingRadioCount()
	local idleRadioCount = math.max(radioCount - streamingRadioCount, 0)

	local f_time = RealFrameTime()

	local think_time_p = math.Round(think_time / f_time * 100, 1)
	local fastthink_time_p = math.Round(fastthink_time / f_time * 100, 1)
	local addonthink_time_p = math.Round(addonthink_time / f_time * 100, 1)
	local addontick_time_p = math.Round(addontick_time / f_time * 100, 1)
	local rendertarget_time_p = math.Round(rendertarget_time / f_time * 100, 1)
	local render_time_p = math.Round(render_time / f_time * 100, 1)

	local aimedpanel = superparent:GetTopmostPanelAtCursor()

	self:EmptyLines(1)

	local addLine = self.AddLine

	self:EmptyLines(2)

	addLine(self, 1, "Refresh")
	addLine(self, 1, " Activity:  %s", self:GetUpdateIndicator())
	addLine(self, 1, " Rate:      %5.3f Hz", updatesPerSecAvg)
	addLine(self, 1, " Time:      %7.3f ms", updateTimeAvg * 1000)
	addLine(self, 1, "")

	if rendertarget_active then
		addLine(self, 1, "Rendertarget")
		addLine(self, 1, "  W, H:     %4i, %4i", rt_w, rt_h)
	else
		addLine(self, 1, "Rendertarget")
		addLine(self, 1, "  Off")
	end

	addLine(self, 1, "")

	addLine(self, 1, "Cursor")
	addLine(self, 1, "  X, Y:     %4i, %4i", cx, cy)

	addLine(self, 1, "")

	if IsValid(aimedpanel) then
		addLine(self, 1, "Panel Info")
		addLine(self, 1, " Object:    %s", tostring(aimedpanel)) 
		addLine(self, 1, " Name:      %s", aimedpanel:GetName())
		addLine(self, 1, " NW Name:   %s", aimedpanel:GetNWName())
		addLine(self, 1, " Skin ID:   %s", aimedpanel:GetSkinIdentifyerHierarchy())
	else
		addLine(self, 1, "Panel Info")
		addLine(self, 1, " <no panel>")
	end

	addLine(self, 1, "")

	addLine(self, 1, "Radio Count")
	addLine(self, 1, " Spawned      %4i", radioCount)
	addLine(self, 1, " Streaming    %4i", streamingRadioCount)
	addLine(self, 1, " Idle         %4i", idleRadioCount)

	addLine(self, 2, "Performance")
	addLine(self, 2, " Game Frame (GF): %7.3f ms", f_time * 1000)
	addLine(self, 2, "")
	addLine(self, 2, " Addon")
	addLine(self, 2, "  Think:          %7.3f ms | %5.1f%% of GF", addonthink_time * 1000, addonthink_time_p)
	addLine(self, 2, "  Tick:           %7.3f ms | %5.1f%% of GF", addontick_time * 1000, addontick_time_p)
	addLine(self, 2, "")
	addLine(self, 2, " Classes")
	addLine(self, 2, "  Think:          %7.3f ms | %5.1f%% of GF", think_time * 1000, think_time_p)
	addLine(self, 2, "  Fast Think:     %7.3f ms | %5.1f%% of GF", fastthink_time * 1000, fastthink_time_p)
	addLine(self, 2, "")
	addLine(self, 2, " GUI Render")
	addLine(self, 2, "  2D3D:           %7.3f ms | %5.1f%% of GF", render_time * 1000, render_time_p)
	addLine(self, 2, "  Content:        %7.3f ms | %5.1f%% of GF", rendertarget_time * 1000, rendertarget_time_p)
	addLine(self, 2, "")
	addLine(self, 2, " Lua Memory:      %7.1f MB", memory / 1024)
end


function CLASS:Render()
	local x, y = self:GetRenderPos()

	self:BuildLines()

	surface.SetFont( "DebugFixed" )
	surface.SetTextColor( g_textcol:Unpack() )

	local colW = self.colW
	local colH = self.colH

	local margin = 12
	local margin2 = margin / 2
	local margin4 = margin / 4

	do
		for i, cols in ipairs(self.debugtexttab) do
			local bg_col_w = 0
			local bg_col_h = 0

			if cols then
				for j, row in ipairs(cols) do
					row = row or ""

					local w, h = surface.GetTextSize(row)

					bg_col_w = math.max(bg_col_w, w + margin)
					bg_col_h = bg_col_h + h + 1
				end
			end

			bg_col_h = bg_col_h + margin2

			colW[i] = math.max(colW[i] or 0, bg_col_w)
			colH[i] = math.max(colH[i] or 0, bg_col_h)
		end
	end

	do
		local bg_w = 0
		local bg_h = 0

		for i, w in ipairs(colW) do
			bg_w = bg_w + w + margin4
		end

		for i, h in ipairs(colH) do
			bg_h = math.max(bg_h, h) + margin2
		end

		self.bgW = math.max(self.bgW, bg_w)
		self.bgH = math.max(self.bgH, bg_h)

		surface.SetDrawColor(g_textcolbg:Unpack())
		surface.DrawRect(x, y, self.bgW, self.bgH)
	end

	do
		local text_x = 0

		for i, cols in ipairs(self.debugtexttab) do
			local text_y = 0

			if i > 1 then
				text_x = text_x + (colW[i - 1] or 0)
			end

			local hasText = false

			if cols then
				for j, row in ipairs(cols) do
					row = row or ""

					local _, h = surface.GetTextSize(row)
					surface.SetTextPos(x + text_x + margin, y + text_y + margin2)
					surface.DrawText(row)

					text_y = text_y + h + 1
					hasText = true
				end
			end

			if not hasText then
				continue
			end

			if i > 1 then
				surface.SetDrawColor(g_textcol:Unpack())
				surface.DrawRect(x + text_x + margin2, y + margin2, 1, self.bgH - margin)
			end
		end
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

