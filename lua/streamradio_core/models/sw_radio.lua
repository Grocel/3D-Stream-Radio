local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- SligWolf's Radio
RADIOMDL.model = "models/sligwolf/grocel/radio/radio.mdl"

RADIOMDL.SpawnAng = Angle(0, 180, 0)
RADIOMDL.SpawnFlatOnWall = true
RADIOMDL.SoundPosOffset = Vector(0, -3.1, 3.45)
RADIOMDL.SoundAngOffset = Angle(0, 0, 0)

RADIOMDL.DisplayAngles = Angle(0, -90, 90)

                              --       F,     R,    U
RADIOMDL.DisplayOffset    = Vector(-1.45,  5.85, 6.00) -- Top Left
RADIOMDL.DisplayOffsetEnd = Vector(-1.45, -5.85, 0.95) -- Bottom Right

RADIOMDL.DisplayWidth = 768
RADIOMDL.DisplayHeight, RADIOMDL.DisplayScale = RADIOMDL:GetDisplayHeight(RADIOMDL.DisplayOffset, RADIOMDL.DisplayOffsetEnd, RADIOMDL.DisplayWidth)


RADIOMDL.FontSizes = {
--  Name 	= Size,	Weight, Parentname
	Header	= {20,	1000},
	Default	= {19,	700},
	Tooltip	= {15,	800},
	Big		= {22,	700},
}

function RADIOMDL:SetupGUI(ent, gui_controller, mainpanel)
	gui_controller:SetPos(0, 0)
	gui_controller:SetSize(self.DisplayWidth, self.DisplayHeight)

	mainpanel:SetSize(gui_controller:GetClientSize())

	local modelsetup = {}
	if CLIENT then
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/header/text", "font", self.Fonts.Header)
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/header/pretext", "font", self.Fonts.Header)
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlists/button", "font", self.Fonts.Default)
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlistview/button", "font", self.Fonts.Default)

		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/header", "font", self.Fonts.Header)
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/controls/progressbar/label", "font", self.Fonts.Default)
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/button", "font", self.Fonts.Big)

		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/spectrum/volume/progressbar/label", "font", self.Fonts.Default)
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/spectrum/error/textbox", "font", self.Fonts.Big)
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/spectrum/error/button", "font", self.Fonts.Big)

		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/error/textbox", "font", self.Fonts.Big)
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/error/button", "font", self.Fonts.Big)

		StreamRadioLib.SetSkinTableProperty(modelsetup, "tooltip", "font", self.Fonts.Tooltip)
	end

	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/header", "sizeh", 40)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/header", "sizeh", 40)

	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlists", "gridsize", {x = 2, y = 6})
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlistview", "gridsize", {x = 2, y = 6})
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlists/scrollbar", "sizew", 30)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlistview/scrollbar", "sizew", 30)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/sidebutton", "sizew", 50)

	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/spectrum/error/textbox/scrollbar", "sizew", 30)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/error/textbox/scrollbar", "sizew", 30)

	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/button", "sizeh", 45)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/spectrum/error/button", "sizew", 35)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/error/button", "sizew", 35)

	StreamRadioLib.SetSkinTableProperty(modelsetup, "", "cornersize", 0)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "", "borderwidth", 16)

	local shadow = 5
	local padding = 5
	local margin = 5

	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlists/button", "shadowwidth", shadow)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlistview/button", "shadowwidth", shadow)

	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlists/button", "padding", padding)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlistview/button", "padding", padding)

	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlists/button", "margin", margin)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlistview/button", "margin", margin)

	gui_controller:SetModelSetup(modelsetup)

	mainpanel:ForEachChildRecursive(function(panel, child)
		if child.SetShadowWidth and child:GetShadowWidth() == 5 then
			child:SetShadowWidth(shadow)
		end

		if child.SetPadding and child:GetPadding() == 5 then
			child:SetPadding(padding)
		end

		if child.SetMargin and child:GetMargin() == 5 then
			child:SetMargin(margin)
		end
	end)
end

function RADIOMDL:Initialize(ent)
	if CLIENT then
		ent:InvalidateBoneCache()
		return
	end

	if ent._mdl_skinset then return end

	local color = ColorRand()
	ent:SetColor( color )

	ent._mdl_skinset = true
end

function RADIOMDL:AnimReset(ent)
	if SERVER then return end

	ent:SetPoseParameter("speakers", 0)
	ent:InvalidateBoneCache()
end

function RADIOMDL:WhileLoading(ent)
	if SERVER then return end

	ent:SetPoseParameter("speakers", 0)
	ent:InvalidateBoneCache()
end

RADIOMDL.SpeakerMinFRQ = 20
RADIOMDL.SpeakerMaxFRQ = 2000
RADIOMDL.SpeakerFRQResolution = 12

function RADIOMDL:Speaker(ent, speakerlevel)
	if SERVER then return end

	speakerlevel = speakerlevel or 0

	local soundlevel = 0

	if IsValid(ent.StreamObj) then
		soundlevel = ent.StreamObj:GetAverageLevel() ^ 0.25
	end

	local vol = ent:GetVolume()

	speakerlevel = speakerlevel * vol * 1.5 * soundlevel
	speakerlevel = math.Clamp(speakerlevel, -1, 1)

	ent:SetPoseParameter("speakers", speakerlevel)
	ent:InvalidateBoneCache()
end

return true

