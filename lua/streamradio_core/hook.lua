local StreamRadioLib = StreamRadioLib

StreamRadioLib.Hook = StreamRadioLib.Hook or {}

local LIB = StreamRadioLib.Hook
table.Empty(LIB)

local g_nameprefix = "3DStreamRadio_mainHook_"
local g_hooks = {}
local g_orderCounter = 0

function LIB.GetMainHookIdentifier(eventName)
	local identifier = g_nameprefix .. tostring(eventName or "")
	return identifier
end

local function CallHooks(hookData, ...)
	-- Called by all hooks the addon adds the game, including think and tick.
	-- It is a proxy that distribute calls to all internal addon hooks.
	-- This reduces overhead from the native hook library.

	-- Prevent error spams when the addon is not completely loaded
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end

	local byOrder = hookData.byOrder
	if not byOrder then
		return nil
	end

	local benchmarkStart = SysTime()
	local benchmarkEnd = 0
	local benchmark = 0
	local benchmarkAvg = 0

	local lastBenchmarkAvg = hookData.benchmarkAvg or 0

	local r1, r2, r3, r4, r5, r6, r7, r8

	for i, hookItem in ipairs(byOrder) do
		local a, b, c, d, e, f, g, h = hookItem.func(...)

		if a == nil then
			continue
		end

		r1, r2, r3, r4, r5, r6, r7, r8 = a, b, c, d, e, f, g, h
		break
	end

	benchmarkEnd = SysTime()
	benchmark = benchmarkEnd - benchmarkStart
	benchmarkAvg = (lastBenchmarkAvg + benchmark) / 2

	hookData.benchmark = benchmark
	hookData.benchmarkAvg = benchmarkAvg

	if r1 == nil then
		return nil
	end

	return r1, r2, r3, r4, r5, r6, r7, r8
end

local function BuildOrder(hookData)
	hookData.byOrder = nil

	local byName = hookData.byName
	if not byName then
		return
	end

	if table.IsEmpty(byName) then
		return
	end

	local byOrder = table.ClearKeys(byName)

	table.SortByMember(byOrder, "order", true)

	hookData.byOrder = byOrder
end

function LIB.Add(eventName, identifier, func, order)
	if not isfunction(func) then return end

	identifier = tostring(identifier or "")
	eventName = tostring(eventName or "")
	order = tonumber(order or 0) or 0

	if order == 0 then
		order = 1000000 + g_orderCounter * 1000
		g_orderCounter = (g_orderCounter % 1000000) + 1
	end

	LIB.Remove(eventName, identifier)

	g_hooks[eventName] = g_hooks[eventName] or {}
	local hookData = g_hooks[eventName]

	hookData.byName = hookData.byName or {}
	local byName = hookData.byName

	byName[identifier] = {
		order = order,
		func = func,
		identifier = identifier,
	}

	hookData.benchmark = hookData.benchmark or 0
	hookData.benchmarkAvg = hookData.benchmark or 0

	BuildOrder(hookData)

	if not hookData.hasHook then
		local hookIdentifier = LIB.GetMainHookIdentifier(eventName)

		hook.Remove(eventName, hookIdentifier)
		hook.Add(eventName, hookIdentifier, function(...)
			return CallHooks(hookData, ...)
		end)

		hookData.hasHook = true
	end
end

function LIB.Remove(eventName, identifier)
	identifier = tostring(identifier or "")
	eventName = tostring(eventName or "")

	local hookData = g_hooks[eventName]
	if not hookData then
		return
	end

	local byName = hookData.byName
	if not byName then
		return
	end

	byName[identifier] = nil

	BuildOrder(hookData)

	if table.IsEmpty(byName) then
		local hookIdentifier = LIB.GetMainHookIdentifier(eventName)

		hook.Remove(eventName, hookIdentifier)
		hookData.hasHook = nil
	end
end

function LIB.GetBenchmark(eventName)
	eventName = tostring(eventName or "")

	local hookData = g_hooks[eventName]
	if not hookData then
		return 0, 0
	end

	local benchmark = hookData.benchmark or 0
	local benchmarkAvg = hookData.benchmarkAvg or 0

	return benchmark, benchmarkAvg
end

return true

