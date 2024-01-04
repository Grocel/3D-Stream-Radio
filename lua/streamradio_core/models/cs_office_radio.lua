local RADIOMDL = RADIOMDL
if not istable( RADIOMDL ) then
	StreamRadioLib.Model.LoadModelSettings()
	return
end

-- CS:S Office Radio
RADIOMDL.model = "models/props/cs_office/radio.mdl"

RADIOMDL.SpawnAng = Angle(0, 0, 0)
RADIOMDL.SpawnFlatOnWall = true
RADIOMDL.SoundPosOffset = Vector(0, -3.75, 3.5)
RADIOMDL.SoundAngOffset = Angle(0, 0, 0)

RADIOMDL.DisplayAngles = Angle(0, 90, 90)

                              --      F,     R,    U
RADIOMDL.DisplayOffset    = Vector(2.40, -6.90, 6.80) -- Top Left
RADIOMDL.DisplayOffsetEnd = Vector(2.40,  6.90, 0.50) -- Bottom Right

RADIOMDL.DisplayWidth = 768
RADIOMDL.DisplayHeight, RADIOMDL.DisplayScale = RADIOMDL:GetDisplayHeight(RADIOMDL.DisplayOffset, RADIOMDL.DisplayOffsetEnd, RADIOMDL.DisplayWidth)

RADIOMDL.FontSizes = {
--  Name 	= Size,	Weight, Parentname
	Header	= {21,	1000},
	Default	= {20,	700},
	Tooltip	= {18,	800},
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

	StreamRadioLib.SetSkinTableProperty(modelsetup, "", "cornersize", 16)
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

return true

