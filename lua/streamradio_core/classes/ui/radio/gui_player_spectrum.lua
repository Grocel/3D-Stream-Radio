local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()
local g_mat_play = StreamRadioLib.GetPNGIcon("control_play")
local g_mat_pause = StreamRadioLib.GetPNGIcon("control_pause")
local g_mat_stop = StreamRadioLib.GetPNGIcon("control_stop")
local g_mat_mute = StreamRadioLib.GetPNGIcon("sound_mute")

function CLASS:Create()
	BASE.Create(self)

	self.StreamOBJ = nil
	self.Spectrum = {}

	self.SkinMap["color_foreground"] = {
		set = "SetForegroundColor",
		get = "GetForegroundColor",
	}

	self.SkinMap["color_icon"] = {
		set = "SetIconColor",
		get = "GetIconColor",
	}

	if CLIENT then
		self.Colors.Foreground = Color(0, 0, 0, 255)
		self.Colors.Icon = Color(255, 255, 255, 255)
	end

	self.CanHaveLabel = false
	self.SkinAble = true

	if CLIENT then
		self:StartFastThink()
	end
end

function CLASS:SetForegroundColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.Foreground = color
end

function CLASS:GetForegroundColor()
	if SERVER then return end

	local col = self.Colors.Foreground
	return col
end

function CLASS:SetIconColor(color)
	if SERVER then return end

	color = color or {}
	color = Color(
		color.r or 0,
		color.g or 0,
		color.b or 0,
		color.a or 0
	)

	self.Colors.Icon = color
end

function CLASS:GetIconColor()
	if SERVER then return end

	local col = self.Colors.Icon
	return col
end

local function RenderSpectrumBar(index, level, bars, x, y, w, h, cR, cG, cB, cA)
	if ( index > w ) then return false end

	if ( bars > w ) then
		bars = w
	end

	local barwide = w / bars

	local BarX = math.Round(x + (index - 1) * barwide)
	local NextBarX = math.Round(x + index * barwide)

	-- close the bar gaps
	barwide = NextBarX - BarX

	local BarY = h + y
	local barheight = math.floor( math.Clamp( level * h, 0, h ) )

	surface.SetDrawColor( cR, cG, cB, cA )
	surface.DrawRect( BarX, BarY - barheight, barwide, barheight )

	return true
end

function CLASS:RenderSpectrum()
	local color = self:GetForegroundColor()

	local x, y = self:GetRenderPos()
	local p = self:GetPadding()
	x = x + p
	y = y + p

	local w, h = self:GetClientSize()

	local soundlevel = self.StreamOBJ:GetAverageLevel()
	soundlevel = math.Clamp( soundlevel ^ 2, 0, 1 )
	soundlevel = ( soundlevel * 0.5 ) + 0.5

	local cR, cG, cB, cA = color:Unpack()

	cR = cR * soundlevel
	cG = cG * soundlevel
	cB = cB * soundlevel

	self.StreamOBJ:GetSpectrumTable(StreamRadioLib.GetSpectrumBars(), self.Spectrum, RenderSpectrumBar, x, y, w, h, cR, cG, cB, cA)
end

function CLASS:RenderLoader()
	local color = self.Colors.Foreground

	local x, y = self:GetRenderPos()
	local p = self:GetPadding()
	x = x + p
	y = y + p

	local w, h = self:GetClientSize()

	local sqmax, sqmin = math.max(w, h), math.min(w, h)
	local isq = math.min(sqmax * 0.125, sqmin * 0.5)

	StreamRadioLib.Surface.Loading( x + (w - isq) / 2, y + (h - isq) / 2, isq, isq, color, 8)
end

function CLASS:RenderIcon(icon)
	local colIcon = self.Colors.Icon or color_white

	local x, y = self:GetRenderPos()
	local p = self:GetPadding()
	x = x + p
	y = y + p

	local w, h = self:GetClientSize()

	local sqmax, sqmin = math.max(w, h), math.min(w, h)
	local isq = math.min(sqmax * 0.125, sqmin * 0.5)

	surface.SetDrawColor( colIcon:Unpack() )
	surface.SetMaterial( icon )
	surface.DrawTexturedRectUV( x + (w - isq) / 2, y + (h - isq) / 2, isq, isq, 0, 0, 1, 1 )
end

function CLASS:RenderSpectrumReplacement()
	local isPlayMode = self.StreamOBJ:IsPlayMode()
	self:RenderIcon(isPlayMode and g_mat_play or g_mat_pause)
end

function CLASS:Render()
	BASE.Render(self)

	local stream = self.StreamOBJ

	if not IsValid(stream) then return end

	if stream:GetMuted() then
		self:RenderIcon(g_mat_mute)
		return
	end

	if stream:IsKilled() then
		self:RenderIcon(g_mat_mute)
		return
	end

	if stream:IsLoading() then
		self:RenderLoader()
		return
	end

	if stream:IsCheckingUrl() then
		self:RenderLoader()
		return
	end

	if stream:IsBuffering() then
		self:RenderLoader()
		return
	end

	if stream:IsSeeking() then
		self:RenderLoader()
		return
	end

	if stream:IsStopMode() then
		self:RenderIcon(g_mat_stop)
		return
	end

	if StreamRadioLib.IsSpectrumHidden() then
		self:RenderSpectrumReplacement()
		return
	end

	local ent = self:GetEntity()
	if IsValid(ent) and ent.CanDrawSpectrum and not ent:CanDrawSpectrum() then
		self:RenderSpectrumReplacement()
		return
	end

	if not stream:IsPlayMode() then
		self:RenderIcon(g_mat_pause)
		return
	end

	self:RenderSpectrum()
end

function CLASS:ShouldPerformRerender()
	if SERVER then return false end

	local stream = self.StreamOBJ

	if stream:GetMuted() then
		return false
	end

	if stream:IsKilled() then
		return false
	end

	if stream:HasError() then
		return false
	end

	if stream:IsLoading() then
		return true
	end

	if stream:IsCheckingUrl() then
		return true
	end

	if stream:IsBuffering() then
		return true
	end

	if stream:IsSeeking() then
		return true
	end

	if StreamRadioLib.IsSpectrumHidden() then
		return false
	end

	local ent = self:GetEntity()
	if IsValid(ent) and ent.CanDrawSpectrum and not ent:CanDrawSpectrum() then
		return false
	end

	if not stream:IsPlaying() then
		return false
	end

	return true
end

if CLIENT then
	function CLASS:FastThink()
		self.fastThinkRate = 10

		if not IsValid(self.StreamOBJ) then return end

		self.fastThinkRate = 0.25

		if not self:IsSeen() then return end
		if not self:IsVisible() then return end

		if not self:ShouldPerformRerender() then return end

		self.fastThinkRate = 0
		self:PerformRerender(true)
	end
end

function CLASS:SetStream(stream)
	if self.StreamOBJ == stream then
		return
	end

	self.StreamOBJ = stream

	self:SetFastThinkRate(0)
end

function CLASS:GetStream()
	return self.StreamOBJ
end

return true

