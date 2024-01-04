local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()
local g_mat_sound = StreamRadioLib.GetPNGIcon("sound")

function CLASS:Create()
	BASE.Create(self)

	self.Path.Type = StreamRadioLib.TYPE_FOLDER
	self.Path = self.Path + function(this, k, v_new, v_old)
		if k ~= "Type" then return end

		local v = v_new or StreamRadioLib.TYPE_FOLDER
		v_old = v_old or StreamRadioLib.TYPE_FOLDER

		if v_new ~= v then
			self.Path.Type = v
			return
		end

		self:SetNWInt("PathType", v)
		self:BuildList()
	end

	self.State = self:CreateListener({
		Error = false,
	}, function(this, k, v)
		self:SetNWBool("Error", v)
		self:QueueCall("CallErrorState")
	end)

	self:SetIDIcon(0, g_mat_sound)
end

function CLASS:SetIDIcon(ID, icon)
	ID = ID or -1
	if ID < 0 then return end

	self.IconIDs[ID] = icon or ID
	self:UpdateButtons()
end

function CLASS:GetIDIcon(ID)
	ID = ID or -1
	if ID < 0 then return end

	return self.IconIDs[ID]
end

function CLASS:OnItemClickInternal(button, value, buttonindex, ListX, ListY, i)
	if CLIENT and self.Network.Active then return end
	self:PlayItem(value)
end

function CLASS:PlayItem(value)
	if CLIENT then return end
	if not self.Network.Active then return end
	if not value then return end

	self:CallHook("OnPlayItem", value)
end

function CLASS:CallErrorState()
	if self.State.Error then
		self:CallHook("OnError", self.Path.Value, self.Path.Type)
	else
		self:CallHook("OnErrorRelease", self.Path.Value, self.Path.Type)
	end
end

function CLASS:UpdateErrorState()
	if CLIENT then return end
	self.State.Error = self.tmperror or false
end

function CLASS:HasError()
	return self.State.Error
end

function CLASS:ClearData()
	if SERVER then
		self.State.Error = false
		self.tmperror = nil
	end

	BASE.ClearData(self)
end

function CLASS:BuildListInternal()
	if CLIENT then return end
	if not self.Network.Active then return end

	self:CallHook("OnPlaylistStartBuild")

	self:ClearData()

	if not self:IsVisible() then
		self:UpdateButtons()
		self:RestoreScrollPos()

		self:CallHook("OnPlaylistEndBuild")
		return
	end

	self.PathUid = StreamRadioLib.Util.Uid()

	if self.Path.Value == "" then
		self:UpdateButtons()
		self:RestoreScrollPos()

		self:CallHook("OnPlaylistEndBuild")
		return
	end

	local uid = self.PathUid

	StreamRadioLib.Filesystem.Read(self.Path.Value, self.Path.Type, function(success, playlist)
		if uid ~= self.PathUid then
			return
		end

		if not success then
			self.tmperror = true
			self:QueueCall("UpdateErrorState")
			self:CallHook("OnPlaylistEndBuild")
			return
		end

		self:QueueCall("_BuildListInternalAsyc", uid, playlist or {})
	end)
end

function CLASS:_BuildListInternalAsyc(uid, playlist)
	if uid ~= self.PathUid then
		return
	end

	local playlistItems = {}

	local len = #playlist
	if len <= 0 then
		self.tmperror = true
		self:QueueCall("UpdateErrorState")
		self:CallHook("OnPlaylistEndBuild", playlistItems)
		return
	end

	for i, v in ipairs(playlist) do
		local entry = {
			name = v.name,
			url = v.url,
			index = i,
		}

		playlistItems[i] = entry

		local data = {}
		data.value = entry
		data.text = entry.name
		data.icon = 0

		self:AddData(data, true)
	end

	if len == 1 then
		self:PlayItem(playlistItems[1])
	end

	self:UpdateButtons()
	self:QueueCall("RestoreScrollPos")

	self:CallHook("OnPlaylistEndBuild", playlistItems)
end

function CLASS:GetFile()
	return self.Path.Value or "", self.Path.Type or StreamRadioLib.TYPE_FOLDER
end

function CLASS:SetFile(path, ty)
	if CLIENT and self.Network.Active then return end

	self.Path.Value = path or ""
	self.Path.Type = ty or StreamRadioLib.TYPE_FOLDER
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)

	if SERVER then
		self:SetNWInt("PathType", self.Path.Type)
		self:SetNWBool("Error", self.State.Error)
		return
	end

	self:SetNWVarCallback("PathType", "Int", function(this, nwkey, oldvar, newvar)
		self.Path.Type = newvar
	end)

	self:SetNWVarCallback("Error", "Bool", function(this, nwkey, oldvar, newvar)
		self.State.Error = newvar
	end)

	self.Path.Type = self:GetNWInt("PathType", StreamRadioLib.TYPE_FOLDER)
	self.State.Error = self:GetNWBool("Error", false)
end

function CLASS:PreDupe()
	local data = {}
	local path, ty = self:GetFile()

	data.Path = path
	data.PathType = ty

	return data
end

function CLASS:ApplyLegacyDataFromDupe(dupedata)
	if not dupedata then return end

	local data = dupedata.Playlist
	local pos = dupedata.EntryOpen or 1

	if not data then return end
	if #data <= 1 then return end

	local ent = self:GetEntity()
	if not IsValid(ent) then return end
	if not ent.DupeDataApply then return end

	-- Legacy support:
	--  Old dupes still have the playlist data in this UI element.
	--  We moved the playlist to the entity, so move the legacy playlist data as well.

	ent:DupeDataApply("PlaylistData", {
		data = data,
		pos = pos,
	})
end

function CLASS:PostDupe(dupedata)
	local path = dupedata.Path
	local type = dupedata.PathType

	self.PathUid = StreamRadioLib.Util.Uid()
	local uid = self.PathUid

	StreamRadioLib.Filesystem.Read(path, type, function(success, data)
		if uid ~= self.PathUid then
			return
		end

		if not success or #data <= 0 then
			self:SetFile("", type)
			self:ApplyLegacyDataFromDupe(dupedata)

			self:CallHook("OnInvalidDupeFilepath")
			return
		end

		self:SetFile(path, type)
		self:ApplyLegacyDataFromDupe(dupedata)
	end)
end

return true

