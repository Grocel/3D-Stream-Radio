local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

function CLASS:Create()
	BASE.Create(self)

	self.Scollposes = StreamRadioLib.Util.CreateCacheArray(128)

	self.Path = self:CreateListener({
		Value = nil,
	}, function(this, k, v_new, v_old)
		if k ~= "Value" then return end

		local v = tostring(v_new or "")
		v = string.gsub(v, "[\\/]+", "/")
		v = string.TrimRight(v, "/")

		v_old = tostring(v_old or "")
		v_old = string.gsub(v_old, "[\\/]+", "/")
		v_old = string.TrimRight(v_old, "/")

		if v_old ~= v then
			self:SaveScrollPos(v_old)
		end

		if v_new ~= v then
			self.Path.Value = v
			return
		end

		self:SetNWString("Path", v)

		self:BuildList()
		self:CallHook("OnPathChange")
	end)

	self:SetEvent("OnClose", "SaveScrollPos", "SaveScrollPos")
	self:BuildList()
end

function CLASS:SetIDIcon(ID, icon)
	-- Dummy
end

function CLASS:GetIDIcon(ID)
	return StreamRadioLib.Filesystem.GetIcon(ID)
end

function CLASS:OnItemClickInternal(button, value, buttonindex, ListX, ListY, i)
	if CLIENT and self.Network.Active then return end

	if value.isfolder then
		local shouldswitch = self:CallHook("OnFolderClick", value)
		if shouldswitch == false then
			return
		end

		self.Path.Value = value.path
		return
	end

	self:CallHook("OnFileClick", value)
end

function CLASS:BuildList()
	if CLIENT and self.Network.Active then return end
	self:QueueCall("BuildListInternal")
end

function CLASS:BuildListInternal()
	-- override me
end

function CLASS:GetUpPath()
	return string.GetPathFromFilename(self.Path.Value or "") or ""
end

function CLASS:GoUpPath()
	if CLIENT and self.Network.Active then return end
	self:SetPath(self:GetUpPath())
end

function CLASS:GetPath()
	return self.Path.Value or ""
end

function CLASS:SetPath(path)
	if CLIENT and self.Network.Active then return end
	self.Path.Value = path or ""
end

function CLASS:Refresh()
	self:SaveScrollPos()

	self:ClearData()
	self:BuildList()

	self:CallHook("OnRefresh")
end

function CLASS:SaveScrollPos(path)
	if CLIENT and self.Network.Active then return end
	if not IsValid(self.ScrollBar) then return end

	local dd = self.ScrollBar.DupeData or {}
	local dupescroll = dd.Scroll or 0

	path = path or self:GetPath()
	self.Scollposes:Set(path, self.ScrollBar.Scroll.Pos or dupescroll)
end

function CLASS:RestoreScrollPos()
	if CLIENT and self.Network.Active then return end
	if not IsValid(self.ScrollBar) then return end

	local dd = self.ScrollBar.DupeData or {}
	local dupescroll = dd.Scroll or 0

	local path = self:GetPath()
	self.ScrollBar.Scroll.Pos = self.Scollposes:Get(path) or dupescroll
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)
	if SERVER then
		self:SetNWString("Path", self.Path.Value or "")
		self:BuildList()
		return
	end

	self:SetNWVarCallback("Path", "String", function(this, nwkey, oldvar, newvar)
		self.Path.Value = newvar
	end)

	self.Path.Value = self:GetNWString("Path", "")
end

function CLASS:PreDupe()
	local data = {}

	data.Path = self:GetPath()

	return data
end

function CLASS:PostDupe(data)
	self:SetPath(data.Path)
end

return true

