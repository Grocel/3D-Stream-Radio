local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local LIBNet = StreamRadioLib.Net
local LIBNetwork = StreamRadioLib.Network
local LIBUtil = StreamRadioLib.Util

local emptyTableSafe = LIBUtil.EmptyTableSafe

local BASE = CLASS:GetBaseClass()

local g_skincache = StreamRadioLib.Util.CreateCacheArray(128)

StreamRadioLib.Hook.Add("PostCleanupMap", "reset_cache_skin_controller", function()
	g_skincache:Empty()
end)

local function g_encode(value)
	value = {value or {}}
	value = StreamRadioLib.JSON.Encode(value, false) or ""
	value = util.Compress(value) or ""

	return value
end

local function g_decode(value)
	value = value or ""
	value = util.Decompress(value) or ""
	value = StreamRadioLib.JSON.Decode(value) or {}
	value = value[1] or {}

	return value
end

function CLASS:Create()
	BASE.Create(self)

	self.Skin = {}
	self.NetworkPlayerList = {}

	self.Hash = self:CreateListener({
		value = "",
	}, function(this, k, v, oldv)
		if CLIENT then
			self:NetworkSkin()
		else
			self:UpdateSkin()
			self:SetNWString("Hash", v)
		end
	end)

	if CLIENT then
		self:NetReceive("skin", function(this, id, len, ply)
			local skinlen = net.ReadUInt(16)
			local skinencoded = net.ReadData(skinlen)
			local newskindata = g_decode(skinencoded)
			local newhash = LIBNet.ReceiveHash()

			-- Store the result of our request for later use
			g_skincache:Set(newhash, newskindata)
			self:SetSkin(newskindata)
		end)
	else
		LIBNetwork.AddNetworkString("skin")
		LIBNetwork.AddNetworkString("skinrequest")
		LIBNetwork.AddNetworkString("skintoserver")

		self:NetReceive("skinrequest", function(this, id, len, ply)
			self.NetworkPlayerList[ply] = ply

			self:NetworkSkin()
		end)

		self:NetReceive("skintoserver", function(this, id, len, ply)
			self.NetworkPlayerList[ply] = ply

			local players = player.GetHumans()

			for i, thisply in ipairs(players) do
				self.NetworkPlayerList[thisply] = thisply
			end

			local skinlen = net.ReadUInt(16)
			local skinencoded = net.ReadData(skinlen)
			local skindata = g_decode(skinencoded)

			self:SetSkinOnServer(skindata, true)
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
		local hash = self:GetHash()

		if hash ~= "" then
			local cache = g_skincache:Get(hash)

			if cache then
				self:SetSkin(cache)
				return
			end
		end

		self:NetSend("skinrequest")
		return
	end

	self:NetSendToPlayers("skin", function()
		local skinencoded = self:GetSkinEncoded()
		local skinlen = #skinencoded

		net.WriteUInt(skinlen, 16)
		net.WriteData(skinencoded, skinlen)

		LIBNet.SendHash(self:GetHashFromSkin(skinencoded))
	end, self.NetworkPlayerList)

	emptyTableSafe(self.NetworkPlayerList)
end

function CLASS:UpdateSkinInternal()
	self:CallHook("OnUpdateSkin", self:GetSkin())
end

function CLASS:SetSkin(skindata)
	skindata = skindata or {}
	self.Skin = skindata

	self:DelCacheValue("SkinEncoded")

	if SERVER then
		self:CalcHash()
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
	end)

	self._skintoserver = nil
end

function CLASS:SetSkinOnServer(skindata, merge)
	skindata = skindata or {}

	if CLIENT then
		if merge then
			local oldskindata = self._skintoserver or {}
			local newskindata = table.Merge(oldskindata, skindata)

			self._skintoserver = newskindata
		else
			self._skintoserver = skindata
		end

		self:QueueCall("_SendSkinToServer")
		return
	end

	if merge then
		local oldskindata = self:GetSkin()
		local newskindata = table.Merge(oldskindata, skindata)

		self:SetSkin(newskindata)
	else
		self:SetSkin(skindata)
	end
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
	local skindata = self:GetSkin()

	skindata = StreamRadioLib.SetSkinTableProperty(skindata, hierarchy, property, value)

	self:SetSkin(skindata)
end

function CLASS:SetPropertyOnServer(hierarchy, property, value)
	if SERVER then
		self:SetProperty(hierarchy, property, value)
		return
	end

	local skindata = self._skintoserver or {}
	skindata = StreamRadioLib.SetSkinTableProperty(skindata, hierarchy, property, value)
	self:SetSkinOnServer(skindata, false)
end

function CLASS:GetHashFromSkin(skinEncoded)
	local hash = LIBNetwork.Hash(skinEncoded)
	return hash
end

function CLASS:CalcHash()
	if CLIENT then return end
	if not self.Network.Active then return end

	self:DelCacheValue("SkinEncoded")

	local hash = self:GetHashFromSkin(self:GetSkinEncoded())
	self.Hash.value = hash or ""
end

function CLASS:GetHash()
	local curhash = self.Hash.value or ""

	if CLIENT and self.Network.Active then
		curhash = self:GetNWString("Hash", "")
	end

	return curhash
end

function CLASS:ActivateNetworkedMode()
	BASE.ActivateNetworkedMode(self)

	if SERVER then
		self:CalcHash()
		return
	end

	local hash = self:GetNWString("Hash", "")
	self.Hash.value = hash

	self:SetNWVarCallback("Hash", "String", function(this, nwkey, oldvar, newvar)
		self.Hash.value = newvar or ""
	end)

	self:NetworkSkin()
	self:UpdateSkin()
end

function CLASS:PreDupe()
	local data = {}

	data.skin = self:GetSkin()

	return data
end

function CLASS:PostDupe(data)
	self:SetSkin(data.skin)
end

return true

