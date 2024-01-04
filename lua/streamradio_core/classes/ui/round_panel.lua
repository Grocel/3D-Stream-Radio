local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

function CLASS:Create()
	BASE.Create(self)

	self.Layout.CornerSize = 16
	self.Layout.Padding = 5

	self.SkinAble = true
end

function CLASS:Render()
	local x, y = self:GetRenderPos()
	local w, h = self:GetSize()

	draw.RoundedBox( self.Layout.CornerSize, x, y, w, h, self.Colors.Main )

	BASE.Render(self)
end

function CLASS:GetCornerSize()
	return self.Layout.CornerSize or 0
end

function CLASS:SetCornerSize(size)
	self.Layout.CornerSize = size or 0
end

function CLASS:OnModelSetup(setup)
	BASE.OnModelSetup(self, setup)

	if setup.cornersize then
		self:SetCornerSize(setup.cornersize)
	end
end

return true

