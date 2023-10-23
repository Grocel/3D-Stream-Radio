local StreamRadioLib = StreamRadioLib

StreamRadioLib.Timer = StreamRadioLib.Timer or {}

local LIB = StreamRadioLib.Timer
table.Empty(LIB)

local g_nameprefix = "3DStreamRadio_Timer_"

function LIB.GetName(identifier)
	identifier = g_nameprefix .. tostring(identifier or "")
	return identifier
end

function LIB.Interval(identifier, delay, repetitions, func)
	if not isfunction(func) then return end
	local name = LIB.GetName(identifier)

	timer.Remove(name)
	timer.Create(name, delay, repetitions, func)
end

function LIB.Once(identifier, delay, func)
	if not isfunction(func) then return end
	local name = LIB.GetName(identifier)

	timer.Remove(name)
	timer.Create(name, delay, 1, function()
		timer.Remove(name)
		func()
	end)
end

function LIB.Until(identifier, delay, func)
	if not isfunction(func) then return end
	local name = LIB.GetName(identifier)

	timer.Remove(name)
	timer.Create(name, delay, 0, function()
		local endtimer = func()
		if not endtimer then return end

		timer.Remove(name)
	end)
end

function LIB.NextFrame(identifier, func)
	LIB.Once(identifier, 0.001, func)
end

function LIB.Remove(identifier)
	local name = LIB.GetName(identifier)
	timer.Remove(name)
end

return true

