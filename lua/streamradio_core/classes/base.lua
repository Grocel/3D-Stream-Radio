local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local LIBUtil = StreamRadioLib.Util

local emptyTableSafe = LIBUtil.EmptyTableSafe

function CLASS:Create()
	self.Valid = true
	self._cache = {}
	self.Name = ""

	StreamRadioLib.Timedcall(function()
		if not self.Valid then return end
		if self._markedforremove then return end

		self.Created = true

		if self.Initialize then
			self:Initialize()
		end
	end)
end

function CLASS:Initialize()
	-- override me
end

function CLASS:Remove()
	self._markedforremove = true
	self:CallHook("OnRemove")

	StreamRadioLib.Timedcall(function()
		if not self then
			return
		end

		self.Valid = false
		self.Created = false

		emptyTableSafe(self._cache)
	end)
end

function CLASS:IsValid()
	return self.Valid or false
end

function CLASS:GetName()
	return self.Name or ""
end

function CLASS:SetName(name)
	name = tostring(name or "")
	name = string.gsub(name, "[%/%s]", "_")

	self.Name = name
end

function CLASS:GetCacheValue(key)
	return self._cache[tostring(key or "")]
end

function CLASS:GetCacheValues(key)
	local value = self:GetCacheValue(key)
	if not value then return nil end
	return unpack(value)
end

function CLASS:SetCacheValue(key, value)
	self._cache[tostring(key or "")] = value
	return value
end

function CLASS:SetCacheValues(key, ...)
	local args = {...}
	self:SetCacheValue(key, args)
	return unpack(args)
end

function CLASS:DelCacheValue(key)
	self._cache[tostring(key or "")] = nil
end

function CLASS:GetFunction(name)
	if isfunction(name) then
		return name
	end

	name = tostring(name or "")

	local func = self[name]
	if not isfunction(func) then
		return nil
	end

	return func
end

function CLASS:CallHook(name, ...)
	local func = self:GetFunction(name)
	if not func then
		return nil
	end

	return func(self, ...)
end

local function getTrace(level, maxcount)
	level = level or 2
	maxcount = maxcount or 0

	local trace = {}

	if level == 0 then
		return trace
	end

	while true do
		local index = #trace
		if maxcount > 0 and index > maxcount then break end

		local info = debug.getinfo( level, "Sln" )
		if not info then break end

		local data = {}
		data.what = info.what
		data.name = info.name
		data.isC = info.what == "C"

		if not data.isC then
			data.line = info.currentline
			data.file = info.short_src
		end

		trace[index + 1] = data
		level = level + 1
	end

	return trace
end

local color1 = Color(60, 200, 60);
local color2 = Color(120,200,120);
local color3 = Color(240,120,60);

function CLASS:Print(...)
	local trace = getTrace(3)
	local args = {...}

	MsgC(color1, tostring(self), ":\n")

	for k, info in pairs(trace) do
		local name = info.name and "\"" .. info.name .. "\"" or "(unknown)"

		if info.isC then
			MsgC(color2, string.format( " %2.0f: C function %-30s\n", k, name ) )
		else
			MsgC(color2, string.format( " %2.0f: %-30s %s:%i\n", k, name, info.file, info.line ) )
		end
	end

	Msg("\n")

	if #args == 1 and istable(args[1]) then
		args = args[1]
		local i = 1

		for k, v in pairs(args) do
			MsgC(color3, string.format( "#%02.0f:\n", i) )
			MsgC(color3, string.format( "  key   -> %10s:\t", i, type(k) ) )
			Msg(tostring(k), "\n")

			MsgC(color3, string.format( "  value -> %10s:\t", i, type(k) ) )
			Msg(tostring(v), "\n")
			Msg("\n")

			i = i + 1
		end

		return
	end

	for k, v in pairs(args) do
		MsgC(color3, string.format( "#%02.0f -> %10s:\t", k, type(v) ) )
		Msg(tostring(v), "\n")
	end

	Msg("\n\n")
end

CLASS.print = CLASS.Print

local g_string_format = string.format

function CLASS:_ToStringFailback()
	local classname = self.classname
	if not classname then
		classname = "!unknown_class!"
	end

	if not self.Valid then
		return g_string_format("[%s][removed]", classname)
	end

	local id = self.ID
	if not id then
		return g_string_format("[%s][unknown_id]", classname)
	end

	local name = self.Name or ""
	if name == "" then
		return g_string_format("[%s][%i]", classname, id)
	end

	return g_string_format("[%s][%i][%s]", classname, id, name)
end

function CLASS:ToString()
	return self:_ToStringFailback()
end

function CLASS:__tostring()
	local called = self._tostringcall
	if called then
		return self:_ToStringFailback()
	end

	self._tostringcall = true
	local _, result = pcall(self.ToString, self)
	self._tostringcall = nil

	local r = result or self:_ToStringFailback()
	return r
end

function CLASS:__gc()
	if not self.Valid then return end
	self:Remove()
end

function CLASS:__eg(other)
	if not other then return false end
	return self:GetID() ~= other:GetID()
end
