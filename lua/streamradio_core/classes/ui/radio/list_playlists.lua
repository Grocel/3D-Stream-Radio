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

	self._fs_files = nil
	self._fs_curpath = self.Path.Value

	StreamRadioLib.Filesystem.Find(self.Path.Value, function(success, files)
		if self._fs_curpath ~= self.Path.Value then
			return
		end

		self._fs_files = files or {}
		self:QueueCall("_BuildListInternalAsyc")
	end)
end

function CLASS:_BuildListInternalAsyc()
	if not self._fs_files then
		return
	end

	if self._fs_curpath ~= self.Path.Value then
		return
	end

	self:ClearData()

	for i, v in ipairs(self._fs_files) do
		local data = {}

		data.value = v
		data.text = v.file
		data.icon = v.type

		self:AddData(data, true)
	end

	self._fs_files = nil

	self:UpdateButtons()
	self:QueueCall("RestoreScrollPos")
end

function CLASS:PostDupe(ent, data)
	if StreamRadioLib.Filesystem.Exists(data.Path, StreamRadioLib.TYPE_FOLDER) then
		self:SetPath(data.Path)
	else
		self:SetPath("")
		self:CallHook("OnInvalidDupeFilepath")
	end
end
