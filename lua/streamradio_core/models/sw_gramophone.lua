local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- SligWolf's Gramophone
RADIOMDL.model = "models/sligwolf/grocel/radio/gramophone.mdl"

RADIOMDL.SpawnAng = Angle(0, 0, 0)
RADIOMDL.SpawnFlatOnWall = false
RADIOMDL.SoundPosOffset = Vector(-8, 0, 13.5)
RADIOMDL.SoundAngOffset = Angle(-10, 0, 0)

RADIOMDL.DisplayAngles = Angle(0, 90, 90)

                              --      F,     R,    U
RADIOMDL.DisplayOffset    = Vector(6.35, -5.85, 6.15) -- Top Left
RADIOMDL.DisplayOffsetEnd = Vector(6.35,  5.85, 2.35) -- Bottom Right

RADIOMDL.DisplayWidth = 1024
RADIOMDL.DisplayHeight, RADIOMDL.DisplayScale = RADIOMDL:GetDisplayHeight(RADIOMDL.DisplayOffset, RADIOMDL.DisplayOffsetEnd, RADIOMDL.DisplayWidth)


RADIOMDL.FontSizes = {
--  Name 	= Size,	Weight, Parentname
	Header	= {23,	1000},
	Default	= {25,	700},
	Tooltip	= {22,	1000},
	Big		= {30,	700},
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
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/button", "font", self.Fonts.Default)

		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/spectrum/volume/progressbar/label", "font", self.Fonts.Default)
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/spectrum/error/textbox", "font", self.Fonts.Default)
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/spectrum/error/button", "font", self.Fonts.Default)

		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/error/textbox", "font", self.Fonts.Default)
		StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/error/button", "font", self.Fonts.Default)

		StreamRadioLib.SetSkinTableProperty(modelsetup, "tooltip", "font", self.Fonts.Tooltip)
	end

	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/header", "sizeh", 40)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/header", "sizeh", 40)

	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlists", "gridsize", {x = 2, y = 5})
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlistview", "gridsize", {x = 2, y = 5})
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlists/scrollbar", "sizew", 30)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/list-playlistview/scrollbar", "sizew", 30)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/sidebutton", "sizew", 60)

	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/spectrum/error/textbox/scrollbar", "sizew", 30)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/error/textbox/scrollbar", "sizew", 30)

	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/button", "sizeh", 50)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/player/spectrum/error/button", "sizew", 40)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "main/browser/error/button", "sizew", 40)

	StreamRadioLib.SetSkinTableProperty(modelsetup, "", "cornersize", 0)
	StreamRadioLib.SetSkinTableProperty(modelsetup, "", "borderwidth", 32)

	gui_controller:SetModelSetup(modelsetup)
end

RADIOMDL.Sounds = {
	Noise = "",
}

function RADIOMDL:Initialize(ent)
	if CLIENT then
		ent:InvalidateBoneCache()
		return
	end

	if ent._mdl_skinset then return end

	local spin = math.random( 0, 360 )
	ent:SetPoseParameter( "spin_speaker", spin )
	ent:RegisterDupePose( "spin_speaker" )

	local skinid = math.random( 0, 3 )
	ent:SetSkin( skinid )

	ent._mdl_skinset = true
end

function RADIOMDL:AnimReset(ent)
	local sequence = ent:LookupSequence( "idle" )
	ent:SetAnim( sequence, 0, 1 )
end

function RADIOMDL:WhileLoading(ent)
	if SERVER then return end

	local sequence = ent:LookupSequence( "idle" )
	ent:SetAnim( sequence, 0, 1 )
end

function RADIOMDL:OnPlay(ent, stream)
	if SERVER then return end

	local sequence = ent:LookupSequence( "playidle" )
	ent:SetAnim( sequence, 0, 1 )

	ent:SetPoseParameter( "move_needle", 0 )
	ent:InvalidateBoneCache()
end

function RADIOMDL:OnError(ent, stream)
	if SERVER then return end

	local sequence = ent:LookupSequence( "idle" )
	ent:SetAnim( sequence, 0, 1 )

	ent:SetPoseParameter( "move_needle", 0 )
	ent:InvalidateBoneCache()
end

function RADIOMDL:OnStop(ent, stream)
	if SERVER then return end

	local sequence = ent:LookupSequence( "idle" )
	ent:SetAnim( sequence, 0, 1 )

	ent:SetPoseParameter( "move_needle", 0 )
	ent:InvalidateBoneCache()
end

function RADIOMDL:Think(ent)
	if SERVER then return end

	local spin = ent:GetPoseParameter( "spin_speaker" ) or 0

	spin = spin * 360

	spin = spin + 28
	spin = math.NormalizeAngle( -spin )

	ent.SoundAngOffset = Angle( ent.SoundAngOffset.p, spin, ent.SoundAngOffset.r )

	local armpos = 0

	if not ent.StreamObj:IsEndless() then
		armpos = ent.StreamObj:GetTime() / ent.StreamObj:GetLength()
	end

	ent:SetPoseParameter( "move_needle", armpos )
	ent:InvalidateBoneCache()
end

return true

