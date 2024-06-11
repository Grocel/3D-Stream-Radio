local StreamRadioLib = StreamRadioLib

StreamRadioLib.Network = StreamRadioLib.Network or {}
StreamRadioLib.Network_Debug = StreamRadioLib.Network_Debug or {}

local LIB = StreamRadioLib.Network
table.Empty(LIB)

local LIBDebug = StreamRadioLib.Network_Debug
table.Empty(LIBDebug)

local LIBUtil = StreamRadioLib.Util

local emptyTableSafe = LIBUtil.EmptyTableSafe

local g_addonprefix = "3DStreamRadio/"
local g_maxIdentifierLen = 44

local g_networkStack = {}

local g_networkMaxStackSize = 4096
local g_networkStackBatchSize = 128

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

function LIB.SetupEntityTable(ent)
	if not IsValid(ent) then
		return
	end

	if ent._entityTableSetup then
		return
	end

	ent._entityTableSetup = true

	local entTable = ent:GetTable()

	for datatype, dtd in pairs(g_types) do
		local nwGetter = dtd.nwGetter
		local nwSetter = dtd.nwSetter

		entTable[nwGetter] = ent[nwGetter]
		entTable[nwSetter] = ent[nwSetter]
	end

	entTable.NetworkVar = ent.NetworkVar
	entTable.NWOverflowKill = ent.NWOverflowKill

	entTable.StreamRadioDT = ent.StreamRadioDT or {}
	entTable.StreamRadioNW = ent.StreamRadioNW or {}

	entTable.IsValid = ent.IsValid
	entTable.IsMarkedForDeletion = ent.IsMarkedForDeletion
end

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

local function DTNetworkVarExists(entTable, name)
	local NW = entTable.StreamRadioDT
	if not NW then return false end

	local Names = NW.Names
	if not Names then return false end

	local data = Names[name]
	if not data then return false end
	if not data.datatype then return false end

	return true
end

local function CanAddDTNetworkVar(entTable, datatype, name, ...)
	name = tostring(name or "")
	datatype = tostring(datatype or "")

	if name == "" then return false end
	if not g_types[datatype] then return false end

	local NW = entTable.StreamRadioDT
	if not NW then return false end

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

		local nwGetterFunc = function(entTable, key, defaultvalue)
			if not entTable then
				return defaultvalue
			end

			key = LIB.TransformNWIdentifier(key)

			local ent = entTable.Entity

			if not ent then
				return defaultvalue
			end

			if not entTable.IsValid(ent) then
				return defaultvalue
			end

			local getter = entTable[nwGetter]
			if not getter then
				return defaultvalue
			end

			local r = getter(ent, key, defaultvalue)
			if r == nil and defaultvalue ~= nil then
				r = defaultvalue
			end

			return r
		end

		local nwSetterFunc = function(entTable, key, value)
			if CLIENT then
				return
			end

			if not entTable then
				return
			end

			key = LIB.TransformNWIdentifier(key)
			value = convertfunc and convertfunc(value) or value

			assert(checkfunc(value), "invalid datatype of value at '" .. key .. "', '" .. datatype .. "' was expected, got '" .. type(value) .. "'")

			local ent = entTable.Entity

			if not ent then
				return
			end

			if not entTable.IsValid(ent) then
				return
			end

			if entTable.IsMarkedForDeletion(ent) then
				return
			end

			local data = {ent, entTable, entTable[nwSetter], key, value}
			table.insert(g_networkStack, data)
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

function LIB.GetNWVar(entTable, datatype, key, defaultvalue)
	key = tostring(key or "")
	datatype = tostring(datatype or "")

	assert(g_types[datatype] ~= nil, "argument #2 must be a valid datatype! Got '" .. datatype .. "'")
	assert(key ~= "", "argument #3 is an invalid name!")

	local dtd = g_types[datatype or ""]
	if not dtd then return defaultvalue end
	if not dtd.nwGetterFunc then return defaultvalue end

	local r = dtd.nwGetterFunc(entTable, key, defaultvalue)
	return r
end

function LIB.SetNWVar(entTable, datatype, key, value)
	if CLIENT then
		return
	end

	key = tostring(key or "")
	datatype = tostring(datatype or "")

	assert(g_types[datatype] ~= nil, "argument #2 must be a valid datatype! Got '" .. datatype .. "'")
	assert(key ~= "", "argument #3 is an invalid name!")

	local dtd = g_types[datatype or ""]
	if not dtd then return end
	if not dtd.nwSetterFunc then return end

	dtd.nwSetterFunc(entTable, key, value)
end

function LIB.SetupDataTables(entOrOntTable)
	local ent = nil
	local entTable = nil

	if istable(entOrOntTable) then
		ent = entOrOntTable.Entity
		entTable = entOrOntTable
	else
		ent = entOrOntTable
		entTable = entOrOntTable:GetTable()
	end

	if not entTable then return end
	LIB.SetupEntityTable(ent)

	local NW = entTable.StreamRadioDT
	if not NW then return end

	NW.Setup = true
end

local function pollNWVarsLoopThis(NW, entTable, name, data)
	if not data.callback then return end
	if not data.datatype then return end

	local oldvalue = data.oldvalue
	local newvalue = LIB.GetNWVar(entTable, data.datatype, name)

	if oldvalue == newvalue then return end

	local ent = entTable.Entity

	data.callback(ent, name, oldvalue, newvalue)

	data.oldvalue = newvalue
end

local function pollNWVars(entTable)
	local NW = entTable.StreamRadioNW
	if not NW then return end

	local Names = NW.Names
	if not Names then return end

	for name, data in pairs(Names) do
		pollNWVarsLoopThis(NW, entTable, name, data)
	end
end

local function pollDTVarsLoopThis(NW, entTable, name, data)
	if not data.callback then return end
	if not data.datatype then return end
	if not DTNetworkVarExists(entTable, name) then return end

	local oldvalue = data.oldvalue
	local newvalue = LIB.GetDTNetworkVar(entTable, name)

	if oldvalue == newvalue then return end

	local ent = entTable.Entity

	data.callback(ent, name, oldvalue, newvalue)

	data.oldvalue = newvalue
end

local function pollDTVars(entTable)
	local NW = entTable.StreamRadioDT
	if not NW then return end
	if not NW.Setup then return end

	local Names = NW.Names
	if not Names then return end

	for name, data in pairs(Names) do
		pollDTVarsLoopThis(NW, entTable, name, data)
	end
end

local function pollNwStackKillThis(stackItem)
	local entTable = stackItem[1]
	if not entTable then return end

	local ent = entTable.Entity

	if not entTable.IsValid(ent) then return end
	if entTable._NWOverflowKilled then return end

	entTable.NWOverflowKill(ent)
	entTable._NWOverflowKilled = true
end

local function pollNwStackLoopThis(stackItem)
	local ent = stackItem[1]
	local entTable = stackItem[2]
	local setter = stackItem[3]
	local key = stackItem[4]
	local value = stackItem[5]

	if not ent then return end
	if not setter then return end

	if not entTable then return end
	if not entTable.IsValid(ent) then return end
	if entTable.IsMarkedForDeletion(ent) then return end

	setter(ent, key, value)
end

function LIB.PollNwStack()
	if CLIENT then
		return
	end

	if not StreamRadioLib.HasSpawnedRadios() then
		-- clean up any left overs, just in case
		emptyTableSafe(g_networkStack)
		return
	end

	local count = 0

	for pointer, stackItem in pairs(g_networkStack) do
		g_networkStack[pointer] = nil

		if stackItem then
			-- network entity data chunk wise
			pollNwStackLoopThis(stackItem)

			count = count + 1
			if count >= g_networkStackBatchSize then
				break
			end
		end
	end

	if #g_networkStack > g_networkMaxStackSize then
		-- we have a very high counter

		local count = table.Count(g_networkStack)
		-- actually count them, they can mismatch

		if count > g_networkMaxStackSize then
			-- still too high, kill the overflow by removing affected entities.

			for pointer, stackItem in pairs(g_networkStack) do
				g_networkStack[pointer] = nil

				if count > g_networkMaxStackSize then
					if stackItem then
						pollNwStackKillThis(stackItem)
					end
				end

				count = math.max(count - 1, 0)
			end
		end
	end
end

function LIB.Poll(entTable)
	pollNWVars(entTable)
	pollDTVars(entTable)
end

function LIB.AddDTNetworkVar(entTable, datatype, name, ...)
	name = tostring(name or "")
	datatype = tostring(datatype or "")

	assert(g_types[datatype], "argument #1 is an invalid datatype!")
	assert(name ~= "", "argument #2 is an invalid name!")

	if DTNetworkVarExists(entTable, name) then return true end
	if not CanAddDTNetworkVar(entTable, datatype, name) then return false end

	local NW = entTable.StreamRadioDT
	if not NW then return false end

	local Setup = NW.Setup or false

	NW.Count = NW.Count or {}
	local Count = NW.Count

	local index = (Count[datatype] or 0) + 1

	NW.Names = NW.Names or {}
	local Names = NW.Names

	Names[name] = Names[name] or {}
	local data = Names[name]

	data.datatype = datatype
	data.args = {...}
	data.index = data.index or index

	index = data.index
	Count[datatype] = index

	local ent = entTable.Entity

	if Setup then
		entTable.NetworkVar(ent, datatype, index - 1, name, ...)

		if data.value ~= nil then
			LIB.SetDTNetworkVar(entTable, name, data.value)
			data.value = nil
		end
	end

	return true
end

function LIB.GetDTNetworkVar(entTable, name, defaultvalue)
	if not DTNetworkVarExists(entTable, name) then
		return defaultvalue
	end

	local ent = entTable.Entity

	local getter = entTable["Get" .. name]
	if not getter then return defaultvalue end

	local value = getter(ent, defaultvalue)
	if value == nil then
		value = defaultvalue
	end

	return value
end

function LIB.SetDTNetworkVar(entTable, name, value)
	if CLIENT then return end

	local ent = entTable.Entity

	if not DTNetworkVarExists(entTable, name) then
		return
	end

	local oldvalue = LIB.GetDTNetworkVar(entTable, name)
	if oldvalue == value then return end

	local setter = entTable["Set" .. name]
	if not setter then return end

	setter(ent, value)
end

function LIB.SetDTVarCallback(entTable, name, func)
	name = tostring(name or "")

	assert(name ~= "", "argument #2 is an invalid name!")
	assert(isfunction(func), "argument #3 must be a function!")

	local NW = entTable.StreamRadioDT
	if not NW then return end

	NW.Names = NW.Names or {}
	local Names = NW.Names

	Names[name] = Names[name] or {}
	local data = Names[name]

	data.callback = func
	data.oldvalue = nil
end

function LIB.SetNWVarCallback(entTable, datatype, name, func)
	datatype = tostring(datatype or "")
	name = tostring(name or "")

	assert(g_types[datatype] ~= nil, "argument #2 must be a valid datatype! Got '" .. datatype .. "'")
	assert(name ~= "", "argument #3 is an invalid name!")
	assert(isfunction(func), "argument #4 must be a function!")

	local NW = entTable.StreamRadioNW
	if not NW then return end

	NW.Names = NW.Names or {}
	local Names = NW.Names

	Names[name] = Names[name] or {}
	local data = Names[name]

	data.callback = func
	data.datatype = datatype
	data.oldvalue = nil
end

local function hashToBin(str)
	str = string.gsub(str, "..", function(cc)
		local c = tonumber(cc, 16)

		if c == 0 then
			-- avoid zero termination
			return "\\0"
		end

		return string.char(c)
	end)

	return str
end

function LIB.Hash(str)
	local hash = StreamRadioLib.Util.Hash(str)
	hash = hashToBin(hash)

	return hash
end

StreamRadioLib.Hook.Add("Tick", "Entity_Network_Tick", function()
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end
	if not StreamRadioLib.SpawnedRadios then return end

	LIB.PollNwStack()

	for index, ent in pairs(StreamRadioLib.SpawnedRadios) do
		if not ent then
			continue
		end

		local entTable = ent:GetTable()
		if not entTable then
			continue
		end

		if not entTable.IsValid(ent) then
			continue
		end

		LIB.Poll(entTable)
	end
end)

function LIBDebug.DumpDTNetworkStats(ent)
	local entTable = ent:GetTable()
	if not entTable then
		return
	end

	local NW = entTable.StreamRadioDT or {}
	local Count = NW.Count or {}

	MsgN("DumpDTNetworkStats of: " .. tostring(ent))
	MsgN("======================")

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

		MsgN(datatype, c .. " / " .. maxc, per .. " %")
	end

	MsgN("======================")
end

function LIBDebug.DumpDTNetworkVars(ent)
	local entTable = ent:GetTable()
	if not entTable then
		return
	end

	local NW = entTable.StreamRadioDT or {}

	MsgN("DumpDTNetworkVars of: " .. tostring(ent))
	MsgN("======================")

	for name, data in pairs(NW.Names) do
		local line = string.format("%s (%s) [%i] | %s", name, data.datatype, data.index, LIB.GetDTNetworkVar(entTable, name))
		MsgN(line)
	end

	MsgN("======================")
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

function LIBDebug.DumpDTNetworkStringTable()
	MsgN("DumpDTNetworkStringTable")
	MsgN("======================")

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

		MsgN(index, "\t", name)
	end

	local fractionMax = countAddon / max
	local fractionAssigned = countAddon / countAssigned

	MsgN("======================")
	MsgN(countAddon .. " of " .. max .. " slots total, " .. (math.Round(fractionMax, 3) * 100) .. '%')
	MsgN(countAddon .. " of " .. countAssigned .. " slots assigned, " .. (math.Round(fractionAssigned, 3) * 100) .. '%')
	MsgN("======================")
end

function LIBDebug.DumpDTNetworkStringTableCode()
	MsgN("DumpDTNetworkStringTableCode")
	MsgN("======================")

	MsgN("")
	MsgN("local LIBNetwork = StreamRadioLib.Network")
	MsgN("")
	MsgN("do")
	MsgN("    -- Automaticly generated network string table map")
	MsgN("")

	local stringTable = getAddonStringTable()

	for i, value in ipairs(stringTable) do
		local name = LIB.UntransformNWIdentifier(value.name)

		local code = string.format("    LIBNetwork.AddNetworkString(\"%s\")", name)
		MsgN(code)
	end

	MsgN("end")
	MsgN("")
	MsgN("======================")
end

do
	local concommandFlags = FCVAR_NONE

	if CLIENT then
		concommandFlags = FCVAR_CHEAT
	end

	concommand.Add("debug_streamradio_dump_nwstringtable", function(ply)
		if not StreamRadioLib.Util.IsAdminForCMD(ply) then
			return
		end

		LIBDebug.DumpDTNetworkStringTable()
	end, nil, nil, concommandFlags)

	concommand.Add("debug_streamradio_dump_nwstringtable_code", function(ply)
		if not StreamRadioLib.Util.IsAdminForCMD(ply) then
			return
		end

		LIBDebug.DumpDTNetworkStringTableCode()
	end, nil, nil, concommandFlags)
end

return true

