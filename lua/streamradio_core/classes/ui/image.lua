local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()
local changehooks = {
	Material = "OnMaterialChange",
	AlignX = "OnAlignChange",
	AlignY = "OnAlignChange",
}

function CLASS:Create()
	BASE.Create(self)

	self.Clickable = false

	if not SERVER then
		self.ImageData = self:CreateListener({
			Material = nil,
			AlignX = TEXT_ALIGN_CENTER,
			AlignY = TEXT_ALIGN_CENTER,
			SizeW = 16,
			SizeH = 16,
		}, function(this, k)
			self:InvalidateLayout()

			local hookname = changehooks[k]
			if not hookname then return end

			self:CallHook(hookname)
		end)

		self.Colors.Main = Color(255,255,255)
	end

	self:SetSkinAble(false)
end

function CLASS:Render()
	local mat = self.ImageData.Material
	if not mat then return end

	local x, y = self:GetRenderPos()
	local w, h = self:GetSize()

	local tx, ty = x, y
	local tsw, tsh = self:GetTextureSize()
	local xalign, yalign = self.ImageData.AlignX, self.ImageData.AlignY
	local colMain = self.Colors.Main or color_white

	if ( xalign == TEXT_ALIGN_CENTER ) then
		tx = x + w / 2 - tsw / 2
	elseif ( xalign == TEXT_ALIGN_RIGHT ) then
		tx = x + w - tsw
	end

	if ( yalign == TEXT_ALIGN_CENTER ) then
		ty = y + h / 2 - tsh / 2
	elseif ( yalign == TEXT_ALIGN_BOTTOM ) then
		ty = y + h - tsh
	end

	surface.SetDrawColor( colMain:Unpack() )
	surface.SetMaterial( mat )
	surface.DrawTexturedRectUV( tx, ty, tsw, tsh, 0, 0, 1, 1 )
end

function CLASS:GetMaterial()
	if SERVER then return end
	return self.ImageData.Material
end

function CLASS:SetMaterial(mat)
	if SERVER then return end
	self.ImageData.Material = mat
end

function CLASS:GetMaterialName()
	if SERVER then return end
	local mat = self.ImageData.Material
	if not mat then
		return nil
	end

	return self.ImageData.Material:GetName()
end

function CLASS:SetTexture(mat, ...)
	if SERVER then return end
	if not mat then
		return self:SetMaterial(nil)
	end

	self:SetMaterial(Material(mat, ...))
end

function CLASS:GetTextureSize()
	if SERVER then return end
	return self.ImageData.SizeW or 0, self.ImageData.SizeH or 0
end

function CLASS:SetTextureSize(w, h)
	if SERVER then return end
	w = w or 0
	h = h or 0

	if w < 0 then
		w = 0
	end

	if h < 0 then
		h = 0
	end

	self.ImageData.SizeW = w
	self.ImageData.SizeH = h
end

function CLASS:TextureSizeToPanel()
	if SERVER then return end
	self:SetTextureSize(self:GetSize())
	self:InvalidateLayout()
end

function CLASS:TextureFitToPanel()
	if SERVER then return end
	local mat = self.ImageData.Material

	if not mat then
		return
	end

	local dw, dh = self:GetSize()

	if dw > dh then
		dw = dh
	end

	if dh > dw then
		dh = dw
	end

	local w = mat:Width()
	local h = mat:Height()
	local diff = 0

	if ( w > dw and h > dh ) then
		if ( w > dw ) then
			diff = dw / w
			w = w * diff
			h = h * diff
		end

		if ( h > dh ) then
			diff = dh / h
			w = w * diff
			h = h * diff
		end
	end

	if ( w < dw ) then
		diff = dw / w
		w = w * diff
		h = h * diff
	end

	if ( h < dh ) then
		diff = dh / h
		w = w * diff
		h = h * diff
	end

	self:SetTextureSize(w, h)
	self:InvalidateLayout()
end

function CLASS:TextureSizeToTexture()
	if SERVER then return end

	local mat = self.ImageData.Material

	if not mat then
		return
	end

	local tw, th = mat:Width(), mat:Height()
	self:SetTextureSize(tw, th)
	self:InvalidateLayout()
end

function CLASS:SetAlign(alignX, alignY)
	if SERVER then return end
	self.ImageData.AlignX = alignX or self.ImageData.AlignX or TEXT_ALIGN_CENTER
	self.ImageData.AlignY = alignY or self.ImageData.AlignY or TEXT_ALIGN_CENTER
end

function CLASS:GetAlign()
	if SERVER then return end
	return self.ImageData.AlignX or TEXT_ALIGN_CENTER, self.ImageData.AlignY or TEXT_ALIGN_CENTER
end

function CLASS:IsVisibleSimple()
	if CLIENT and not self.ImageData.Material then
		return false
	end

	return BASE.IsVisibleSimple(self)
end

function CLASS:IsVisible()
	if CLIENT and not self.ImageData.Material then
		return false
	end

	return BASE.IsVisible(self)
end

return true

