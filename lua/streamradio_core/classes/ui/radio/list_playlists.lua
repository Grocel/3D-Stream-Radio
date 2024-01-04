local StreamRadioLib = StreamRadioLib

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

	self.PathUid = StreamRadioLib.Util.Uid()
	local uid = self.PathUid

	StreamRadioLib.Filesystem.Find(self.Path.Value, function(success, files)
		if uid ~= self.PathUid then
			return
		end

		self:QueueCall("_BuildListInternalAsyc", uid, files or {})
	end)
end

function CLASS:_BuildListInternalAsyc(uid, files)
	if uid ~= self.PathUid then
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

function CLASS:PostDupe(data)
	if StreamRadioLib.Filesystem.Exists(data.Path, StreamRadioLib.TYPE_FOLDER) then
		self:SetPath(data.Path)
	else
		self:SetPath("")
		self:CallHook("OnInvalidDupeFilepath")
	end
end

return true

