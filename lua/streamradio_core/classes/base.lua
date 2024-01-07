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

return true

