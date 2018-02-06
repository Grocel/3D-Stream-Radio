if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

local function g_encode(value)
	value = {value or {}}
	value = util.TableToJSON(value, false) or ""
	value = util.Compress(value) or ""

	return value
end

local function g_decode(value)
	value = value or ""
	value = util.Decompress(value) or ""
	value = util.JSONToTable(value) or {}
	value = value[1] or {}

	return value
end

function CLASS:PreAssignToListenGroup()
	local group = tonumber(self:GetGlobalVar("gui_controller_listengroup")) or self:GetID()
	return group
end

function CLASS:Create()
	BASE.Create(self)

	self.Skin = {}

	self.Hash = self:CreateListener({
		hex = "",
		crc = 0,
		raw = {},
	}, function(this, k, v, oldv)
		if CLIENT then
			self:NetworkSkin()
		else
			self:UpdateSkin()
			self:SetNWHash("Hash", self.Hash)
		end
	end)

	if CLIENT then
		self:NetReceive("skin", function(this, id, len, ply)
			local skinlen = net.ReadUInt(16)
			local skinencoded = net.ReadData(skinlen)
			local skin = g_decode(skinencoded)

			self:SetSkin(skin)
		end)
	else
		self:NetReceive("skinrequest", function(this, id, len, ply)
			self.NetworkPlayerList = self.NetworkPlayerList or {}
			self.NetworkPlayerList[ply] = true

			self:NetworkSkin()
		end)

		self:NetReceive("skintoserver", function(this, id, len, ply)
			self.NetworkPlayerList = self.NetworkPlayerList or {}

			local players = player.GetHumans()

			for i, ply in ipairs(players) do
				self.NetworkPlayerList[ply] = true
			end

			local skinlen = net.ReadUInt(16)
			local skinencoded = net.ReadData(skinlen)
			local skin = g_decode(skinencoded)

			self:SetSkin(skin)
		end)
	end
end

function CLASS:Remove()
	BASE.Remove(self)
end

function CLASS:NetworkSkin()
	self:QueueCall("NetworkSkinInternal")
end

function CLASS:UpdateSkin()
	self:QueueCall("UpdateSkinInternal")
end

function CLASS:NetworkSkinInternal()
	if CLIENT then
		self:NetSend("skinrequest")
		return
	end

	local playerlist = table.GetKeys(self.NetworkPlayerList or {})
	local data = self.Data or {}

	self.NetworkPlayerList = nil
	if #playerlist <= 0 then return end

	self:NetSend("skin", function()
		local skinencoded = self:GetSkinEncoded()
		local skinlen = #skinencoded

		net.WriteUInt(skinlen, 16)
		net.WriteData(skinencoded, skinlen)
	end, "Send", playerlist)
end

function CLASS:UpdateSkinInternal()
	self:CallHook("OnUpdateSkin", self:GetSkin())
end

function CLASS:SetSkin(skin)
	skin = skin or {}
	self.Skin = skin

	self:DelCacheValue("SkinEncoded")

	if SERVER then
		self:QueueCall("CalcHash")
		self:NetworkSkin()
	else
		self:UpdateSkin()
	end
end

function CLASS:_SendSkinToServer()
	if SERVER then return end
	if not self.Network.Active then return end
	if not self._skintoserver then return end

	self:NetSend("skintoserver", function()
		local skinencoded = g_encode(self._skintoserver)
		local skinlen = #skinencoded

		net.WriteUInt(skinlen, 16)
		net.WriteData(skinencoded, skinlen)
	end, "SendToServer")
end

function CLASS:SetSkinOnServer(skin)
	if SERVER then
		self:SetSkin(skin)
		return
	end

	self._skintoserver = skin
	self:QueueCall("_SendSkinToServer")
end

function CLASS:GetSkinEncoded()
	local chskinencoded = self:GetCacheValue("SkinEncoded")
	if chskinencoded then return chskinencoded end

	local skinencoded = g_encode(self:GetSkin())
	return self:SetCacheValue("SkinEncoded", skinencoded)
end

function CLASS:GetSkin()
	return self.Skin or {}
end

function CLASS:SetProperty(hierarchy, property, value)
	local skin = self:GetSkin()
	skin = StreamRadioLib.SetSkinTableProperty(skin, hierarchy, property, value)
	self:SetSkin(skin)
end

function CLASS:SetPropertyOnServer(hierarchy, property, value)
	if SERVER then
		self:SetProperty(hierarchy, property, value)
		return
	end

	local skin = self._skintoserver or {}
	skin = StreamRadioLib.SetSkinTableProperty(skin, hierarchy, property, value)
	self:SetSkinOnServer(skin)
end

function CLASS:CalcHash()
	if CLIENT then return end
	if not self.Network.Active then return end

	local hash = StreamRadioLib.Hash(self:GetSkinEncoded())
	self.Hash.raw = hash.raw or {}
	self.Hash.hex = hash.hex or ""
	self.Hash.crc = hash.crc or 0
end

function CLASS:GetHash()
	local curhash = self.Hash

	if CLIENT and self.Network.Active then
		curhash = self:GetNWHash("Hash", {})
	end

	local hash = {
		raw = curhash.raw or {},
		hex = curhash.hex or "",
		crc = curhash.crc or 0,
	}

	return hash
end

function CLASS:GetHashID(hash)
	hash = hash or self:GetHash() or {}

	local hex = hash.hex or ""
	local crc = hash.crc or 0

	if hex == "" then return "" end
	if crc == 0 then return "" end

	return "[" .. hex .. "]_[" .. crc .. "]"
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)

	if SERVER then
		self:CalcHash()
		return
	end

	local hash = self:GetNWHash("Hash", {})
	self.Hash.raw = hash.raw or {}
	self.Hash.hex = hash.hex or ""
	self.Hash.crc = hash.crc or 0

	self:SetNWHashProxy("Hash", function(this, nwkey, oldvar, newvar)
		self.Hash.raw = newvar.raw or {}
		self.Hash.hex = newvar.hex or ""
		self.Hash.crc = newvar.crc or 0
	end)

	self:NetworkSkin()
	self:UpdateSkin()
end

function CLASS:PreDupe(ent)
	local data = {}

	data.skin = self:GetSkin()

	return data
end

function CLASS:PostDupe(ent, data)
	self:SetSkin(data.skin)
end
