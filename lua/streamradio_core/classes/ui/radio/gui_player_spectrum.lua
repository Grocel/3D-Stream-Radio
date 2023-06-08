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
		self:StartSuperThink()
	end
end

function CLASS:SetForegroundColor(color)
	if SERVER then return end
	self.Colors.Foreground = color
end

function CLASS:GetForegroundColor()
	if SERVER then return end
	local col = self.Colors.Foreground

	return Color(col.r or 0, col.g or 0, col.b or 0, col.a or 0)
end

function CLASS:SetIconColor(color)
	if SERVER then return end
	self.Colors.Icon = color
end

function CLASS:GetIconColor()
	if SERVER then return end
	local col = self.Colors.Icon

	return Color(col.r or 0, col.g or 0, col.b or 0, col.a or 0)
end

local function RenderSpectrumBar(index, level, bars, soundlevel, x, y, w, h, color)
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

	surface.SetDrawColor( color )
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

	color.r = color.r * soundlevel
	color.g = color.g * soundlevel
	color.b = color.b * soundlevel

	self.StreamOBJ:GetSpectrumTable(StreamRadioLib.GetSpectrumBars(), self.Spectrum, RenderSpectrumBar, soundlevel, x, y, w, h, color)
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
	local color = self.Colors.Icon

	local x, y = self:GetRenderPos()
	local p = self:GetPadding()
	x = x + p
	y = y + p

	local w, h = self:GetClientSize()

	local sqmax, sqmin = math.max(w, h), math.min(w, h)
	local isq = math.min(sqmax * 0.125, sqmin * 0.5)

	surface.SetDrawColor( color )
	surface.SetMaterial( icon )
	surface.DrawTexturedRectUV( x + (w - isq) / 2, y + (h - isq) / 2, isq, isq, 0, 0, 1, 1 )
end

function CLASS:RenderSpectrumReplacement()
	local isPlayMode = self.StreamOBJ:IsPlayMode()
	self:RenderIcon(isPlayMode and g_mat_play or g_mat_pause)
end

function CLASS:Render()
	BASE.Render(self)
	if not IsValid(self.StreamOBJ) then return end
	if not self:IsVisible() then return end

	if self.StreamOBJ:GetMuted() then
		self:RenderIcon(g_mat_mute)
		return
	end

	if self.StreamOBJ:IsLoading() then
		self:RenderLoader()
		return
	end

	if self.StreamOBJ:IsBuffering() then
		self:RenderLoader()
		return
	end

	if self.StreamOBJ:IsSeeking() then
		self:RenderLoader()
		return
	end

	if self.StreamOBJ:IsStopMode() then
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

	if not self.StreamOBJ:IsPlayMode() then
		self:RenderIcon(g_mat_pause)
		return
	end

	self:RenderSpectrum()
end

function CLASS:ShouldPerformRerender()
	if SERVER then return false end

	if self.StreamOBJ:GetMuted() then
		return false
	end

	if self.StreamOBJ:IsLoading() then
		return true
	end

	if self.StreamOBJ:IsBuffering() then
		return true
	end

	if self.StreamOBJ:IsSeeking() then
		return true
	end

	if StreamRadioLib.IsSpectrumHidden() then
		return false
	end

	local ent = self:GetEntity()
	if IsValid(ent) and ent.CanDrawSpectrum and not ent:CanDrawSpectrum() then
		return false
	end

	if not self.StreamOBJ:IsPlaying() then
		return false
	end

	return true
end

function CLASS:SuperThink()
	if SERVER then return end
	if not IsValid(self.StreamOBJ) then return end

	if not self:IsSeen() then return end
	if not self:IsVisible() then return end

	if not self:ShouldPerformRerender() then return end
	self:PerformRerender(true)
end

function CLASS:SetStream(stream)
	self.StreamOBJ = stream
end

function CLASS:GetStream()
	return self.StreamOBJ
end
