StreamRadioLib.Network = {}
StreamRadioLib.Network.Debug = {}
local LIB = StreamRadioLib.Network

local StreamRadioLib = StreamRadioLib

local g_addonprefix = "3DStreamRadio/"
local g_maxIdentifierLen = 44

local g_types = {
	["Angle"] = {
		check = function(value)
			return isangle(value)
		end,
		convert = nil,
		dtmaxcount = 32,
		nwGetter = "GetNW2Angle",
		nwSetter = "SetNW2Angle",
	},

	["Bool"] = {
		check = function(value)
			return isbool(value)
		end,
		convert = function(v)
			return tobool(v)
		end,
		dtmaxcount = 32,
		nwGetter = "GetNW2Bool",
		nwSetter = "SetNW2Bool",
	},

	["Entity"] = {
		check = function(value)
			return IsEntity(value)
		end,
		convert = nil,
		dtmaxcount = 32,
		nwGetter = "GetNW2Entity",
		nwSetter = "SetNW2Entity",
	},

	["Float"] = {
		check = function(value)
			return isnumber(value)
		end,
		convert = nil,
		dtmaxcount = 32,
		nwGetter = "GetNW2Float",
		nwSetter = "SetNW2Float",
	},

	["Int"] = {
		check = function(value)
			return isnumber(value)
		end,
		convert = function(v)
			return math.floor(v)
		end,
		dtmaxcount = 32,
		nwGetter = "GetNW2Int",
		nwSetter = "SetNW2Int",
	},

	["String"] = {
		check = function(value)
			return isstring(value)
		end,
		convert = nil,
		dtmaxcount = 0,
		nwGetter = "GetNW2String",
		nwSetter = "SetNW2String",
	},

	["Vector"] = {
		check = function(value)
			return isvector(value)
		end,
		convert = nil,
		dtmaxcount = 32,
		nwGetter = "GetNW2Vector",
		nwSetter = "SetNW2Vector",
	},
}

function LIB.TransformNWIdentifier(str)
	str = tostring(str or "")
	assert(str ~= "", "identifier is empty")

	str = g_addonprefix .. str

	local strLen = #str
	assert(strLen < g_maxIdentifierLen, "identifier '" .. str .. "' must shorter than " .. g_maxIdentifierLen .. " chars, got " .. strLen .. " chars")

	return str
end

function LIB.UntransformNWIdentifier(str)
	str = tostring(str or "")
	assert(str ~= "", "identifier is empty")

	local strLen = #str
	assert(strLen < g_maxIdentifierLen, "identifier '" .. str .. "' must shorter than " .. g_maxIdentifierLen .. " chars, got " .. strLen .. " chars")

	str = string.gsub(str, "^" .. string.PatternSafe(g_addonprefix), "", 1)
	return str
end

function LIB.AddNetworkStringRaw(str)
	str = tostring(str or "")
	assert(str ~= "", "identifier is empty")

	local strLen = #str
	assert(strLen < g_maxIdentifierLen, "identifier '" .. str .. "' must shorter than " .. g_maxIdentifierLen .. " chars, got " .. strLen .. " chars")

	local currentId = util.NetworkStringToID(str) or 0

	if CLIENT then
		return currentId
	end

	if currentId ~= 0 then
		return currentId
	end

	util.AddNetworkString(str)

	local newId = util.NetworkStringToID(str) or 0
	assert(newId ~= 0, "Could not add network string for '" .. str .. "'! Is network string table is full?")
	assert(util.NetworkIDToString(newId) == str, "Could not add network string at ID '" .. newId .. "' for '" .. newId .. "'! Is network string table is full?")

	return newId
end

function LIB.AddNetworkString(str)
	str = LIB.TransformNWIdentifier(str)

	local id = LIB.AddNetworkStringRaw(str)
	return id
end

function LIB.NetworkStringToID(str)
	str = LIB.TransformNWIdentifier(str)

	local id = util.NetworkStringToID(str) or 0
	return id
end

function LIB.NetworkIDToString(id)
	id = tonumber(id or 0) or 0
	if id == 0 then
		return nil
	end

	local str = util.NetworkIDToString(id)
	if not str then
		return nil
	end

	str = LIB.UntransformNWIdentifier(str)
	return str
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

do
	local loopThis = function(datatype, dtd)
		local checkfunc = dtd.check
		local convertfunc = dtd.convert
		local nwGetter = dtd.nwGetter
		local nwSetter = dtd.nwSetter

		local nwGetterFunc = function(ent, key, defaultvalue, ...)
			key = LIB.TransformNWIdentifier(key)

			if defaultvalue ~= nil then
				assert(checkfunc(defaultvalue), "invalid datatype of defaultvalue at '" .. key .. "', '" .. datatype .. "' was expected, got '" .. type(defaultvalue) .. "'")
				defaultvalue = convertfunc and convertfunc(defaultvalue) or defaultvalue
			end

			local r = ent[nwGetter](ent, key, defaultvalue, ...)
			if r == nil and defaultvalue ~= nil then
				r = defaultvalue
			end

			return r
		end

		local nwSetterFunc = function(ent, key, value, ...)
			if CLIENT then
				return nil
			end

			key = LIB.TransformNWIdentifier(key)
			value = convertfunc and convertfunc(value) or value

			assert(checkfunc(value), "invalid datatype of value at '" .. key .. "', '" .. datatype .. "' was expected, got '" .. type(value) .. "'")

			return ent[nwSetter](ent, key, value, ...)
		end

		LIB["GetNW" .. datatype] = nwGetterFunc
		LIB["SetNW" .. datatype] = nwSetterFunc

		dtd.nwSetterFunc = nwSetterFunc
		dtd.nwGetterFunc = nwGetterFunc
	end

	for datatype, dtd in pairs(g_types) do
		loopThis(datatype, dtd)
	end
end

function LIB.GetNWVar(ent, datatype, key, defaultvalue)
	key = tostring(key or "")
	datatype = tostring(datatype or "")

	assert(g_types[datatype] ~= nil, "argument #2 must be a valid datatype! Got '" .. datatype .. "'")
	assert(key ~= "", "argument #3 is an invalid name!")

	local dtd = g_types[datatype or ""]
	if not dtd then return defaultvalue end
	if not dtd.nwGetterFunc then return defaultvalue end

	local r = dtd.nwGetterFunc(ent, key, defaultvalue)
	return r
end

function LIB.SetNWVar(ent, datatype, key, value)
	key = tostring(key or "")
	datatype = tostring(datatype or "")

	assert(g_types[datatype] ~= nil, "argument #2 must be a valid datatype! Got '" .. datatype .. "'")
	assert(key ~= "", "argument #3 is an invalid name!")

	local dtd = g_types[datatype or ""]
	if not dtd then return end
	if not dtd.nwSetterFunc then return end

	dtd.nwSetterFunc(ent, key, value)
end

function LIB.SetupDataTables(ent)
	ent.StreamRadioDT = ent.StreamRadioDT or {}
	local NW = ent.StreamRadioDT

	NW.Setup = true
	NW.Names = NW.Names or {}

	local loopThis = function(name, data)
		if not data.datatype then return end

		LIB.AddDTNetworkVar(ent, data.datatype, name, unpack(data.args or {}))
	end

	for name, data in pairs(NW.Names) do
		loopThis(name, data)
	end
end

local function pullNWVars(ent)
	local NW = ent.StreamRadioNW
	if not NW then return end
	if not NW.Names then return end

	local loopThis = function(name, data)
		if not data.callback then return end
		if not data.datatype then return end

		local oldvalue = data.oldvalue
		local newvalue = LIB.GetNWVar(ent, data.datatype, name)

		if oldvalue == newvalue then return end
		StreamRadioLib.CatchAndErrorNoHaltWithStack(data.callback, ent, name, oldvalue, newvalue)

		NW.Names[name].oldvalue = newvalue
	end

	for name, data in pairs(NW.Names) do
		loopThis(name, data)
	end
end

local function pullDTVars(ent)
	local NW = ent.StreamRadioDT
	if not NW then return end
	if not NW.Names then return end
	if not NW.Setup then return end

	local loopThis = function(name, data)
		if not data.callback then return end
		if not data.datatype then return end
		if not DTNetworkVarExists(ent, name) then return end

		local oldvalue = data.oldvalue
		local newvalue = LIB.GetDTNetworkVar(ent, name)

		if oldvalue == newvalue then return end
		StreamRadioLib.CatchAndErrorNoHaltWithStack(data.callback, ent, name, oldvalue, newvalue)

		NW.Names[name].oldvalue = newvalue
	end

	for name, data in pairs(NW.Names) do
		loopThis(name, data)
	end
end

function LIB.Pull(ent)
	pullNWVars(ent)
	pullDTVars(ent)
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

function LIB.SetDTVarCallback(ent, name, func)
	name = tostring(name or "")

	assert(name ~= "", "argument #2 is an invalid name!")
	assert(isfunction(func), "argument #3 must be a function!")

	ent.StreamRadioDT = ent.StreamRadioDT or {}
	local NW = ent.StreamRadioDT

	NW.Names = NW.Names or {}
	NW.Names[name] = NW.Names[name] or {}
	local data = NW.Names[name]

	data.callback = func
	data.oldvalue = nil
end

function LIB.SetNWVarCallback(ent, datatype, name, func)
	datatype = tostring(datatype or "")
	name = tostring(name or "")

	assert(g_types[datatype] ~= nil, "argument #2 must be a valid datatype! Got '" .. datatype .. "'")
	assert(name ~= "", "argument #3 is an invalid name!")
	assert(isfunction(func), "argument #4 must be a function!")

	ent.StreamRadioNW = ent.StreamRadioNW or {}
	local NW = ent.StreamRadioNW

	NW.Names = NW.Names or {}
	NW.Names[name] = NW.Names[name] or {}
	local data = NW.Names[name]

	data.callback = func
	data.datatype = datatype
	data.oldvalue = nil
end

function LIB.Debug.DumpDTNetworkStats(ent)
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

function LIB.Debug.DumpDTNetworkVars(ent)
	local NW = ent.StreamRadioDT or {}

	print("DumpDTNetworkVars of: " .. tostring(ent))
	print("======================")

	for name, data in pairs(NW.Names) do
		local line = string.format("%s (%s) [%i] | %s", name, data.datatype, data.index, LIB.GetDTNetworkVar(ent, name))
		print(line)
	end

	print("======================")
end

local function getAddonStringTable()
	local max = 4096
	local result = {}

	for k = 1, max do
		local name = util.NetworkIDToString(k)

		if not name then
			break
		end

		if not string.find(name, "^" .. string.PatternSafe(g_addonprefix)) then
			continue
		end

		result[#result + 1] = {
			index = k,
			name = name,
		}
	end

	return result
end

function LIB.Debug.DumpDTNetworkStringTable()
	print("DumpDTNetworkStringTable")
	print("======================")

	local max = 4096
	local stringTable = getAddonStringTable()
	local countAssigned = 0
	local countAddon = #stringTable

	for k = 1, max do
		local name = util.NetworkIDToString(k)

		if not name then
			break
		end

		countAssigned = countAssigned + 1
	end

	for i, value in ipairs(stringTable) do
		local index = value.index
		local name = value.name

		print(index, name)
	end

	local fractionMax = countAddon / max
	local fractionAssigned = countAddon / countAssigned

	print("======================")
	print(countAddon .. " of " .. max .. " slots total, " .. (math.Round(fractionMax, 3) * 100) .. '%')
	print(countAddon .. " of " .. countAssigned .. " slots assigned, " .. (math.Round(fractionAssigned, 3) * 100) .. '%')
	print("======================")
end

function LIB.Debug.DumpDTNetworkStringTableCode()
	print("DumpDTNetworkStringTableCode")
	print("======================")

	print("")
	print("local LIBNetwork = StreamRadioLib.Network")
	print("")
	print("do")
	print("    -- Automaticly generated network string table map")
	print("")

	local stringTable = getAddonStringTable()

	for i, value in ipairs(stringTable) do
		local name = LIB.UntransformNWIdentifier(value.name)

		local code = string.format("    LIBNetwork.AddNetworkString(\"%s\")", name)
		print(code)
	end

	print("end")
	print("")
	print("======================")
end

do
	local concommandFlags = FCVAR_NONE

	if CLIENT then
		concommandFlags = FCVAR_CHEAT
	end

	concommand.Add("debug_streamradio_dump_nwstringtable", function(ply)
		if IsValid(ply) and not ply:IsAdmin() then
			return
		end

		LIB.Debug.DumpDTNetworkStringTable()
	end, nil, nil, concommandFlags)

	concommand.Add("debug_streamradio_dump_nwstringtable_code", function(ply)
		if IsValid(ply) and not ply:IsAdmin() then
			return
		end

		LIB.Debug.DumpDTNetworkStringTableCode()
	end, nil, nil, concommandFlags)
end