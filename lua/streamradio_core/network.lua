StreamRadioLib.Network = {}
local LIB = StreamRadioLib.Network

local g_types = {
	["Angle"] = {
		check = function(value)
			return isangle(value)
		end,
		convert = nil,
		dtmaxcount = 32,
	},

	["Bool"] = {
		check = function(value)
			return isbool(value)
		end,
		convert = function(v)
			return tobool(v)
		end,
		dtmaxcount = 32,
		dtonly = true, -- NW2 works better for some reason
	},

	["Entity"] = {
		check = function(value)
			return IsEntity(value)
		end,
		convert = nil,
		dtmaxcount = 32,
	},

	["Float"] = {
		check = function(value)
			return isnumber(value)
		end,
		convert = nil,
		dtmaxcount = 32,
	},

	["Int"] = {
		check = function(value)
			return isnumber(value)
		end,
		convert = function(v)
			return math.floor(v)
		end,
		dtmaxcount = 32,
		dtonly = true,
	},

	["String"] = {
		check = function(value)
			return isstring(value)
		end,
		convert = nil,
		dtmaxcount = 0,
		dtonly = true,
	},

	["Vector"] = {
		check = function(value)
			return isvector(value)
		end,
		convert = nil,
		dtmaxcount = 32,
		dtonly = true,
	},
}

local _R = debug.getregistry()
local ENTITY = _R.Entity

local g_hasnw2 = isfunction(ENTITY.SetNW2Var)
local g_addonprefix = "3dstreamradio/"

local function GetDTNetworkVarInternalIndex(name)
	name = tostring(name or "")
	return "_SRNWLib_[" .. name .. "]"
end

local function DTNetworkVarExists(ent, name)
	local NW = ent.StreamRadioDT or {}

	if not NW then return false end
	if not NW.Names then return false end
	if not NW.Names[name] then return false end
	if not NW.Names[name].datatype then return false end

	if not ent["Get" .. name] then return false end
	if not ent["Set" .. name] then return false end

	return true
end

local function CanAddDTNetworkVar(ent, datatype, name, ...)
	name = tostring(name or "")
	datatype = tostring(datatype or "")

	if name == "" then return false end
	if not g_types[datatype] then return false end

	local NW = ent.StreamRadioDT or {}

	local count = NW.Count or {}
	count = count[datatype] or 0

	local maxcount = g_types[datatype].dtmaxcount or 0

	if count >= maxcount then return false end
	return true
end

local function GetDTNetworkVarInternal(ent, name, defaultvalue, ...)
	local index = GetDTNetworkVarInternalIndex(name)
	return LIB.GetDTNetworkVar(ent, index, defaultvalue, ...)
end

local function SetDTNetworkVarInternal(ent, name, value, ...)
	if CLIENT then return end
	local index = GetDTNetworkVarInternalIndex(name)
	return LIB.SetDTNetworkVar(ent, index, value, ...)
end

local function AddDTNetworkVarInternal(ent, datatype, name, ...)
	local index = GetDTNetworkVarInternalIndex(name)
	return LIB.AddDTNetworkVar(ent, datatype, index, ...)
end

local function SetDTVarCallbackInternal(ent, name, func)
	local index = GetDTNetworkVarInternalIndex(name)
	return LIB.SetDTVarCallback(ent, index, func, name)
end

for datatype, dtd in pairs(g_types) do
	local checkfunc = dtd.check
	local convertfunc = dtd.convert
	local dtonly = dtd.dtonly

	LIB["SetNW" .. datatype] = function(ent, key, value, ...)
		local prefix = g_addonprefix .. "/"
		key = prefix .. tostring(key or "")

		assert(checkfunc(value), "invalid datatype of value at '" .. key .. "', '" .. datatype .. "' was expected, got '" .. type(value) .. "'", 2)
		value = convertfunc and convertfunc(value) or value

		if not dtonly then
			if AddDTNetworkVarInternal(ent, datatype, key) then
				SetDTNetworkVarInternal(ent, key, value)
				return
			end
		end


		if CLIENT then return end

		local nw = g_hasnw2 and "SetNW2" or "SetNW"
		ent[nw .. datatype](ent, key, value, ...)
	end

	LIB["GetNW" .. datatype] = function(ent, key, defaultvalue, ...)
		local prefix = g_addonprefix .. "/"
		key = prefix .. tostring(key or "")

		if defaultvalue ~= nil then
			assert(checkfunc(defaultvalue), "invalid datatype of defaultvalue at '" .. key .. "', '" .. datatype .. "' was expected, got '" .. type(defaultvalue) .. "'", 2)
			defaultvalue = convertfunc and convertfunc(defaultvalue) or defaultvalue
		end

		if not dtonly then
			if AddDTNetworkVarInternal(ent, datatype, key) then
				return GetDTNetworkVarInternal(ent, key, defaultvalue)
			end
		end

		local nw = g_hasnw2 and "GetNW2" or "GetNW"

		local r = ent[nw .. datatype](ent, key, defaultvalue, ...)
		if r == nil then
			r = defaultvalue
		end

		return r
	end
end

function LIB.SetNWHash(ent, key, h)
	if CLIENT then return end

	local setvector = LIB.SetNWVector
	if not setvector then return end

	h = h or {}

	local hash = {}
	hash.raw = h.raw or h

	for i = 1, 6 do
		hash.raw[i] = hash.raw[i] or 0
	end

	hash.hex, hash.crc = StreamRadioLib.HashToHex( hash )

	local crc = hash.crc
	local raw = hash.raw

	local v1 = Vector(crc   , raw[1], raw[4])
	local v2 = Vector(raw[2], crc   , raw[5])
	local v3 = Vector(raw[3], raw[6], crc   )

	setvector(ent, key .. "-hashv1", v1)
	setvector(ent, key .. "-hashv2", v2)
	setvector(ent, key .. "-hashv3", v3)

	local test = LIB.GetNWHash(ent, key)
end

function LIB.GetNWHash(ent, key)
	local getvector = LIB.GetNWVector
	if not getvector then return {} end

	ent.StreamRadioNWHashes = ent.StreamRadioNWHashes or {}
	ent.StreamRadioNWHashes[key] = ent.StreamRadioNWHashes[key] or {}

	local hash = {}
	hash.raw = {}
	hash.crc = {}

	local v1 = getvector(ent, key .. "-hashv1")
	local v2 = getvector(ent, key .. "-hashv2")
	local v3 = getvector(ent, key .. "-hashv3")

	hash.raw[1] = v1.y
	hash.raw[2] = v2.x
	hash.raw[3] = v3.x
	hash.raw[4] = v1.z
	hash.raw[5] = v2.z
	hash.raw[6] = v3.y

	local crc1 = v1.x
	local crc2 = v2.y
	local crc3 = v3.z

	hash.hex, hash.crc = StreamRadioLib.HashToHex( hash )

	if hash.crc ~= crc1 then
		return ent.StreamRadioNWHashes[key]
	end

	if hash.crc ~= crc2 then
		return ent.StreamRadioNWHashes[key]
	end

	if hash.crc ~= crc3 then
		return ent.StreamRadioNWHashes[key]
	end

	ent.StreamRadioNWHashes[key] = hash
	return ent.StreamRadioNWHashes[key]
end

function LIB.SetNWHashProxy(ent, key, func, ...)
	assert(isfunction(func), "argument #3 must be a function!")

	key = tostring(key or "")
	ent.StreamRadioNWHashes = ent.StreamRadioNWHashes or {}

	for i = 1, 3 do
		local postfix = "-hashv" .. i

		local proxyfunc = function(this, nwkey, ov, nv, ...)
			if ov == nv then return end

			nwkey = string.gsub(nwkey, string.PatternSafe(postfix) .. "$", "", 1 )

			local oldvar = this.StreamRadioNWHashes[nwkey] or {}
			local newvar = LIB.GetNWHash(this, nwkey)

			if not newvar.hex then return end
			if oldvar.hex == newvar.hex then return end

			return func(this, nwkey, oldvar, newvar, ...)
		end

		LIB.SetNWVarProxy(ent, key .. postfix, proxyfunc, ...)
	end
end

function LIB.SetNWVarProxy(ent, key, func, ...)
	assert(isfunction(func), "argument #3 must be a function!")
	local prefix = g_addonprefix .. "/"
	key = prefix .. tostring(key or "")

	local proxyfunc = function(this, nwkey, ov, nv, ...)
		if ov == nv then return end

		nwkey = string.gsub(nwkey, "^" .. string.PatternSafe(prefix), "", 1 )
		return func(this, nwkey, ov, nv, ...)
	end

	SetDTVarCallbackInternal(ent, key, proxyfunc)
	ent:SetNWVarProxy(key, proxyfunc, ...)
end

function LIB.SetupDataTables(ent)
	ent.StreamRadioDT = ent.StreamRadioDT or {}
	local NW = ent.StreamRadioDT

	NW.Setup = true
	NW.Names = NW.Names or {}

	for name, data in pairs(NW.Names) do
		if not data.datatype then continue end
		LIB.AddDTNetworkVar(ent, data.datatype, name, unpack(data.args or {}))
	end
end

function LIB.Pull(ent)
	local NW = ent.StreamRadioDT
	if not NW then return end
	if not NW.Names then return end
	if not NW.Setup then return end

	for name, data in pairs(NW.Names) do
		if not data.callback then continue end
		if not data.callbackname then continue end
		if not data.datatype then continue end
		if not DTNetworkVarExists(ent, name) then continue end

		local oldvalue = data.oldvalue
		local newvalue = LIB.GetDTNetworkVar(ent, name)

		if oldvalue == newvalue then continue end
		data.callback(ent, data.callbackname, oldvalue, newvalue)

		NW.Names[name].oldvalue = newvalue
	end
end

function LIB.AddDTNetworkVar(ent, datatype, name, ...)
	name = tostring(name or "")
	datatype = tostring(datatype or "")

	assert(g_types[datatype], "argument #1 is an invalid datatype!")
	assert(name ~= "", "argument #2 is an invalid name!")

	if DTNetworkVarExists(ent, name) then return true end
	if not CanAddDTNetworkVar(ent, datatype, name) then return false end

	ent.StreamRadioDT = ent.StreamRadioDT or {}
	local NW = ent.StreamRadioDT
	local Setup = NW.Setup or false

	NW.Count = NW.Count or {}
	local index = (NW.Count[datatype] or 0) + 1

	NW.Names = NW.Names or {}
	NW.Names[name] = NW.Names[name] or {}
	local data = NW.Names[name]

	data.datatype = datatype
	data.args = {...}
	data.index = data.index or index

	index = data.index
	NW.Count[datatype] = index

	if Setup then
		ent:NetworkVar(datatype, index - 1, name, ...)

		if data.value ~= nil then
			LIB.SetDTNetworkVar(ent, name, data.value)
			data.value = nil
		end
	end

	return true
end

function LIB.GetDTNetworkVar(ent, name, defaultvalue)
	if not DTNetworkVarExists(ent, name) then
		return defaultvalue
	end

	local func = ent["Get" .. name]
	if not func then return defaultvalue end

	local value = func(ent, defaultvalue)
	if value == nil then
		value = defaultvalue
	end

	return value
end

function LIB.SetDTNetworkVar(ent, name, value)
	if CLIENT then return end

	if not DTNetworkVarExists(ent, name) then
		local NW = ent.StreamRadioDT
		ent.StreamRadioDT = ent.StreamRadioDT or {}

		NW.Names = NW.Names or {}
		NW.Names[name] = NW.Names[name] or {}
		NW.Names[name].value = value

		return
	end

	local oldvalue = LIB.GetDTNetworkVar(ent, name)
	if oldvalue == value then return end

	local func = ent["Set" .. name]
	if not func then return end

	func(ent, value)
end

function LIB.SetDTVarCallback(ent, name, func, callbackname)
	ent.StreamRadioDT = ent.StreamRadioDT or {}
	local NW = ent.StreamRadioDT

	NW.Names = NW.Names or {}
	NW.Names[name] = NW.Names[name] or {}
	local data = NW.Names[name]

	data.callback = func
	data.callbackname = callbackname or name
	data.oldvalue = nil
end

function LIB.DumpDTNetworkStats(ent)
	local NW = ent.StreamRadioDT or {}
	local Count = NW.Count or {}

	print("DumpDTNetworkStats of: " .. tostring(ent))
	print("======================")

	for datatype, dtd in pairs(g_types) do
		local c = Count[datatype] or 0
		local maxc = dtd.dtmaxcount or 0

		local per = 1

		if maxc <= 0 then
			maxc = 0
		else
			per = math.Round(c / maxc, 3)
		end

		per = per * 100

		print(datatype, c .. " / " .. maxc, per .. " %")
	end

	print("======================")
end
