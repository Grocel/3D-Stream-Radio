local StreamRadioLib = StreamRadioLib

StreamRadioLib.Wire = StreamRadioLib.Wire or {}

local LIB = StreamRadioLib.Wire
table.Empty(LIB)

local LIBUtil = StreamRadioLib.Util

local emptyTableSafe = LIBUtil.EmptyTableSafe

local g_HasWiremod = nil

function LIB.HasWiremod()
	if g_HasWiremod ~= nil then
		return g_HasWiremod
	end

	g_HasWiremod = false

	local wmod = _G.WireAddon or _G.WIRE_CLIENT_INSTALLED
	if not wmod then return false end
	if not _G.WireLib then return false end

	g_HasWiremod = true
	return true
end

local function findCallingWireUserEntityFunction()
	for i = 1, 100 do
		local data = debug.getinfo(i, "fS")
		if not data then
			break
		end

		local func = data.func
		if not func then
			break
		end

		local short_src = data.short_src
		if not short_src then
			break
		end

		short_src = string.lower(short_src)

		if not string.find(short_src, "entities/gmod_wire_user.lua", 1, true) then
			continue
		end

		data.index = i
		return data
	end

	return nil
end

local function findCallingWireUserEntityLocals(data)
	if not data then
		return nil
	end

	local locals = {}

	local i = 1

	while true do
		local name, value = debug.getlocal(data.index, i)
		if not name then
			break
		end

		locals[name] = value
		i = i + 1
	end

	return locals
end

function LIB.FindCallingWireUserEntityData()
	if not LIB.HasWiremod() then
		return nil
	end

	local data = findCallingWireUserEntityFunction()
	local locals = findCallingWireUserEntityLocals(data)
	if not locals then
		return nil
	end

	local userEntity = locals["self"]
	if not LIB.IsWireUser(userEntity) then
		return nil
	end

	local trace = locals["trace"]
	if not trace then
		return nil
	end

	local ent = trace.Entity
	if not IsValid( ent ) then
		return nil
	end

	if not ent.__IsRadio then
		return nil
	end

	local result = {
		userEntity = userEntity,
		trace = table.Copy(trace),
	}

	return result
end

function LIB.IsWireUser(ent)
	if not LIB.HasWiremod() then
		return false
	end

	if not IsValid(ent) then
		return false
	end

	if not ent.IsWire then
		return false
	end

	if ent:GetClass() ~= "gmod_wire_user" then
		return false
	end

	return true
end

function LIB.GetUserPos(ent)
	if not LIB.IsWireUser(ent) then
		return nil
	end

	local pos = ent:GetPos()

	return pos
end

function LIB.GetUserPosDir(ent)
	if not LIB.IsWireUser(ent) then
		return nil, nil
	end

	local pos = ent:GetPos()
	local dir = ent:GetUp()

	return pos, dir
end

local g_WireUserTraceCache = {}
local g_WireUserTraceCacheCount = 0
local g_WireUserTrace = {}

function LIB.WireUserTrace(ent)
	if not LIB.IsWireUser(ent) then
		return nil
	end

	local cacheID = tostring(ent or "")
	local cacheItem = g_WireUserTraceCache[cacheID]

	if cacheItem and StreamRadioLib.Util.IsSameFrame("StreamRadioLib.Wire.WireUserTrace_" .. cacheID) then
		return cacheItem
	end

	g_WireUserTraceCache[cacheID] = nil

	local pos, dir = LIB.GetUserPosDir(ent)

	if not pos then
		return nil
	end

	if not dir then
		return nil
	end

	local len = ent:GetBeamLength()
	if not len then
		return nil
	end

	local start_pos = pos
	local end_pos = pos + dir * len

	g_WireUserTrace.start = start_pos
	g_WireUserTrace.endpos = end_pos
	g_WireUserTrace.filter = ent

	local trace = util.TraceLine(g_WireUserTrace)

	-- prevent the cache from overflowing
	if g_WireUserTraceCacheCount > 1024 then
		emptyTableSafe(g_WireUserTraceCache)
		g_WireUserTraceCacheCount = 0
	end

	g_WireUserTraceCache[cacheID] = trace

	if not cacheItem then
		g_WireUserTraceCacheCount = g_WireUserTraceCacheCount + 1
	end

	return g_WireUserTraceCache[cacheID]
end

return true

