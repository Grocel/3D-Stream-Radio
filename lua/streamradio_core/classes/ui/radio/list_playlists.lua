if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

function CLASS:Create()
	BASE.Create(self)

	self:SetIDIcon(StreamRadioLib.TYPE_PLS, StreamRadioLib.GetPNGIcon("format_pls", true))
	self:SetIDIcon(StreamRadioLib.TYPE_M3U, StreamRadioLib.GetPNGIcon("page"))
	self:SetIDIcon(StreamRadioLib.TYPE_JSON, StreamRadioLib.GetPNGIcon("table"))
	self:SetIDIcon(StreamRadioLib.TYPE_VDF, StreamRadioLib.GetPNGIcon("table"))
	self:SetIDIcon(StreamRadioLib.TYPE_MXRADIO, StreamRadioLib.GetPNGIcon("format_radio", true))
	self:SetIDIcon(StreamRadioLib.TYPE_WEBRADIO, StreamRadioLib.GetPNGIcon("format_radio", true))
	self:SetIDIcon(StreamRadioLib.TYPE_PPLAY, StreamRadioLib.GetPNGIcon("format_pplay", true))
	self:SetIDIcon(StreamRadioLib.TYPE_SCARSRADIO, StreamRadioLib.GetPNGIcon("format_radio", true))
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

	StreamRadioLib.Playlist.Find(self, function( fullpath, path, filename, filetype, k, len )
		if not IsValid(self) then return false end
		if not self.Network.Active then return false end
		if not self:IsVisible() then return false end

		local data = {}

		data.value = {
			fullpath = fullpath,
			path = path,
			filename = filename,
			filetype = filetype,
		}

		if not self:GetIDIcon(filetype) then
			filetype = StreamRadioLib.TYPE_GENERIC_FILE
		end

		data.text = filename
		data.icon = filetype

		self:AddData(data, true)
	end, self.Path.Value, function( )
		if not IsValid(self) then return false end
		if not self.Network.Active then return false end
		if not self:IsVisible() then return false end

		self:UpdateButtons()
		self:QueueCall("RestoreScrollPos")
	end, true )
end

function CLASS:PostDupe(ent, data)
	if StreamRadioLib.Playlist.IsValidFolder(data.Path) then
		self:SetPath(data.Path)
	else
		self:SetPath("")
		self:CallHook("OnInvalidDupeFilepath")
	end
end
