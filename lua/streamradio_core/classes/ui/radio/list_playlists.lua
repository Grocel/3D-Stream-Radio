if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

function CLASS:Create()
	BASE.Create(self)
end

function CLASS:BuildListInternal()
	if CLIENT then return end
	if not self.Network.Active then return end

	self:ClearData()

	if not self:IsVisible() then
		self:UpdateButtons()
		self:RestoreScrollPos()
		return
	end

	local files = StreamRadioLib.Filesystem.Find(self.Path.Value)
	if not files then
		self:UpdateButtons()
		self:RestoreScrollPos()
		return
	end

	for i, v in ipairs(files) do
		local data = {}

		data.value = v
		data.text = v.file
		data.icon = v.type

		self:AddData(data, true)
	end

	self:UpdateButtons()
	self:QueueCall("RestoreScrollPos")
end

function CLASS:PostDupe(ent, data)
	if StreamRadioLib.Playlist.IsValidFolder(data.Path) then
		self:SetPath(data.Path)
	else
		self:SetPath("")
		self:CallHook("OnInvalidDupeFilepath")
	end
end
