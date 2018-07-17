if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local BASE = CLASS:GetBaseClass()

local g_listeners = CLASS:GetGlobalVar("base_listener_listeners", {})
CLASS:SetGlobalVar("base_listener_listeners", g_listeners)

local g_super_listeners = CLASS:GetGlobalVar("base_listener_super_listeners", {})
CLASS:SetGlobalVar("base_listener_super_listeners", g_super_listeners)

local g_nw_register = CLASS:GetGlobalVar("base_listener_nw_register", {})
CLASS:SetGlobalVar("base_listener_nw_register", g_nw_register)

local g_hookname = "3dstreamradio_classsystem_listen"
local g_super_hookname = g_hookname .. "_fast"
local g_networkhookname = "3dstreamradio_classsystem_listen"
local g_listengroups = SERVER and 6 or 4
local g_lastgroup = 1
local g_hookruns = false
local g_superhooksruns = false
local g_hooktimeout = nil

for i = 1, g_listengroups do
	g_listeners[i] = g_listeners[i] or {}
end

local function listentogroup()
	for i = 0, g_listengroups do
		local found = nil

		local thisgroup = g_lastgroup + 1
		local group = g_listeners[thisgroup] or {}
		g_listeners[thisgroup] = group

		for id, listener in pairs(group) do
			if not IsValid(listener) then
				g_listeners[thisgroup][id] = nil
				continue
			end

			if listener._markedforremove then
				g_listeners[thisgroup][id] = nil
				continue
			end

			if not listener.ThinkInternal then
				g_listeners[thisgroup][id] = nil
				continue
			end

			if not listener.Created then
				continue
			end

			local listentimeout = listener._listentimeout
			if listentimeout then
				if listentimeout <= 0 then
					g_listeners[thisgroup][id] = nil
					continue
				end

				listener._listentimeout = listentimeout - 1
			end

			listener:ThinkInternal()
			found = listener
		end

		g_lastgroup = thisgroup
		g_lastgroup = g_lastgroup % g_listengroups

		if found then
			return found
		end
	end

	return nil
end

local function g_listenfunc()
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end

	local starttime = SysTime()
	local found = listentogroup()

	if found then
		found:SetGlobalVar("base_listener_thinktime", SysTime() - starttime)
	end

	// Disabled auto hook remove as it causes the addon to break sometimes
	/*
	g_hookruns = true
	g_hooktimeout = g_hooktimeout or 100

	if found then
		found:SetGlobalVar("base_listener_thinktime", SysTime() - starttime)
		g_hooktimeout = 100
	else
		g_hooktimeout = g_hooktimeout - 1
	end

	if g_hooktimeout > 0 then
		return
	end

	hook.Remove("Think", g_hookname)
	g_hookruns = false
	g_hooktimeout = nil
	*/

end

local function g_superlistenfunc()
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end

	local starttime = SysTime()

	local found = nil
	for id, listener in pairs(g_super_listeners) do
		if not IsValid(listener) then
			g_super_listeners[id] = nil
			continue
		end

		if listener._markedforremove then
			g_super_listeners[id] = nil
			continue
		end

		if not isfunction(listener.SuperThink) then
			g_super_listeners[id] = nil
			continue
		end

		if not listener.Created then continue end

		listener:SuperThink()
		found = listener
	end


	if found then
		found:SetGlobalVar("base_listener_superthinktime", SysTime() - starttime)
	end
end

if SERVER then
	util.AddNetworkString(g_networkhookname)
end

net.Receive(g_networkhookname, function(len, ply)
	if SERVER and not IsValid(ply) then return end

	local nwent = net.ReadEntity()
	local name = StreamRadioLib.Net.ReceiveStringHash()
	local id = StreamRadioLib.Net.ReceiveStringHash() or ""

	if not IsValid(nwent) then return end
	if not name then return end

	if not g_nw_register[nwent] then return end

	local this = g_nw_register[nwent][name]
	if not IsValid(this) then return end

	local thisnwent = this:GetEntity()
	if nwent ~= thisnwent then return end

	local thisname = this:GetName()
	if name ~= thisname then return end

	if id == "" then return end
	if not this._netreceivefuncs then return end

	local func = this:GetFunction(this._netreceivefuncs[id])
	if not func then return end

	func(this, id, len, ply)
end)

function CLASS:PreAssignToListenGroup()
	return self:GetID()
end

function CLASS:Create()
	BASE.Create(self)

	self._profiler = {}
	self._profilertimes = {}
	self._callqueue = {}
	self._callqueueonce = {}
	self._callqueuetemp = {}
	self._netreceivefuncs = {}
	self.CanListen = true
	self.Entity = nil

	self.Network = self:CreateListener({
		Active = false,
	}, function(this, k, v)
		if v then
			self:ActivateNetworkedMode()
			self:ApplyNetworkedMode()
		else
			self:DeactivateNetworkedMode()
		end
	end)

	self:ApplyNetworkedMode()
end

function CLASS:Remove()
	self._watch = {}
	self._old = {}
	self._profile = {}
	self._callqueue = {}
	self._callqueueonce = {}
	self._events = {}

	self.Network.Active = false

	self:StopListen()
	self:StopSuperThink()

	BASE.Remove(self)
end

function CLASS:CallHook(name, ...)
	self:CallEvent(name, ...)

	local func = self:GetFunction(name)
	if not func then
		return nil
	end

	local r = func(self, ...)
	return r
end

function CLASS:CallEvent(eventname, ...)
	eventname = tostring(eventname or "")

	if not self._events then return end
	if not self._events[eventname] then return end

	for k, v in pairs(self._events[eventname]) do
		local func = self:GetFunction(v)
		if not func then continue end

		func(self, ...)
	end
end

function CLASS:SetEvent(eventname, name, func)
	eventname = tostring(eventname or "")
	name = tostring(name or "")

	self._events = self._events or {}
	self._events[eventname] = self._events[eventname] or {}
	self._events[eventname][name] = func
end

function CLASS:RemoveEvent(eventname, name)
	eventname = tostring(eventname or "")
	name = tostring(name or "")

	if not self._events then return end
	if not self._events[eventname] then return end

	self._events[eventname][name] = nil
end

function CLASS:TimerGetName(identifier)
	local name = "OBJ[" .. self:GetClassname() .. "][" .. self:GetID() .. "]_" .. tostring(identifier or "")
	return name
end

function CLASS:TimerInterval(identifier, delay, repetitions, func)
	local name = self:TimerGetName(identifier)

	StreamRadioLib.Timer.Remove(name)
	StreamRadioLib.Timer.Interval(name, delay, repetitions, function()
		if not IsValid(self) then
			StreamRadioLib.Timer.Remove(name)
			return
		end

		func = self:GetFunction(func)
		if not func then
			StreamRadioLib.Timer.Remove(name)
			return
		end

		func(self)
	end)
end

function CLASS:TimerOnce(identifier, delay, func)
	local name = self:TimerGetName(identifier)

	StreamRadioLib.Timer.Remove(name)
	StreamRadioLib.Timer.Once(name, delay, function()
		if not IsValid(self) then
			StreamRadioLib.Timer.Remove(name)
			return
		end

		func = self:GetFunction(func)
		if not func then return end

		func(self)
	end)
end

function CLASS:TimerUtil(identifier, delay, func)
	local name = self:TimerGetName(identifier)

	StreamRadioLib.Timer.Remove(name)
	StreamRadioLib.Timer.Util(name, delay, function()
		if not IsValid(self) then
			StreamRadioLib.Timer.Remove(name)
			return true
		end

		func = self:GetFunction(func)
		if not func then
			return true
		end

		return func(self)
	end)
end

function CLASS:TimerRemove(identifier)
	local name = self:TimerGetName(identifier)
	StreamRadioLib.Timer.Remove(name)
end

function CLASS:GetListengroup()
	return self.listengroupid or 0
end

local function CopyValue(value)
	local t = type(value)

	if IsColor(value) then
		return Color(value.r, value.g, value.b, value.a)
	end

	if t == "Vector" then
		return Vector(value.x, value.y, value.z)
	end

	if t == "Angle" then
		return Angle(value.p, value.y, value.r)
	end

	if t == "table" then
		return table.Copy( value )
	end

	return value
end

function CLASS:CreateListener(val, func)
	local listener = {
		values = {},
		callbacks = {},
	}

	local mt = {}
	mt.__index = listener.values

	mt.__newindex = function(t, k, v)
		local values = rawget(t, "values")
		local callbacks = rawget(t, "callbacks")

		if not values then
			return
		end

		local oldv = rawget(values, k)

		if not istable(v) and not istable(oldv) and v == oldv then
			return
		end

		rawset(values, k, CopyValue(v))

		if not IsValid(self) then
			return
		end

		for i, callback in ipairs(callbacks) do
			callback = self:GetFunction(callback)

			if not callback then
				continue
			end

			callback(self, k, v, oldv)
		end
	end

	mt.__add = function(t, callback)
		if not callback then
			return t
		end

		local callbacks = rawget(t, "callbacks")
		table.insert(callbacks, callback)

		return t
	end
	mt.__concat = mt.__add

	mt.__sub = function(t, callback)
		if not callback then
			return t
		end

		local callbacks = rawget(t, "callbacks")
		table.RemoveByValue(callbacks, callback)
		return t
	end

	mt.__len = function(t, callback)
		local callbacks = rawget(t, "callbacks")
		return #callbacks
	end

	setmetatable( listener, mt )

	listener = listener + func

	for k, v in pairs(val or {}) do
		local values = rawget(listener, "values")
		if not values then break end

		rawset(values, k, CopyValue(v))
	end

	return listener
end

function CLASS:ThinkInternal()
	self:CallHook("Think")

	local hasqueue = false

	for k, data in pairs(self._callqueuetemp or {}) do
		local func = data.func
		local args = data.args

		if not func then
			continue
		end

		func(self, unpack(args))
		hasqueue = true
	end

	self._callqueuetemp = {}
	for k, data in ipairs(self._callqueue or {}) do
		self._callqueue[k] = nil

		local func = data.func

		if isstring(func) then
			self._callqueueonce[func] = nil
		end

		func = self:GetFunction(func)
		if not func then
			continue
		end

		self._callqueueonce[func] = nil
		self._callqueuetemp[k] = {
			func = func,
			args = data.args,
		}

		hasqueue = true
	end

	if not self.CanListen then
		self:StopListen()
	end

	if not self.Think and not hasqueue then
		self:StopListen()
	end
end

function CLASS:StartListen()
	if not self.CanListen then
		return
	end

	local id = self:GetID()

	if not self.listengroupid then
		self.listengroupid = self:CallHook("PreAssignToListenGroup")
		self.listengroupid = tonumber(self.listengroupid)

		if not self.listengroupid then
			return
		end

		self.listengroupid = self.listengroupid % g_listengroups + 1
	end

	local listengroupid = self.listengroupid

	self._listentimeout = nil

	g_listeners[listengroupid] = g_listeners[listengroupid] or {}
	g_listeners[listengroupid][id] = self

	g_hooktimeout = nil

	if g_hookruns then return end

	hook.Add("Think", g_hookname, g_listenfunc)
	g_hookruns = true
end

function CLASS:StopListen()
	if self._listentimeout then
		return
	end

	self._listentimeout = 5
end

function CLASS:StartSuperThink()
	self:QueueCall("_StartSuperThink")
end

function CLASS:_StartSuperThink()
	self:StopSuperThink()

	local id = self:GetID()
	g_super_listeners[id] = self

	if not g_superhooksruns then
		hook.Add("Think", g_super_hookname, g_superlistenfunc)
		g_superhooksruns = true
	end
end

function CLASS:StopSuperThink()
	local id = self:GetID()
	g_super_listeners[id] = nil
end

function CLASS:IsListening()
	local id = self:GetID()
	local listengroupid = self.listengroupid

	if not listengroupid then
		return false
	end

	if not g_hookruns then
		return false
	end

	if not g_listeners[listengroupid] then
		return false
	end

	if not g_listeners[listengroupid][id] then
		return false
	end

	return false
end

function CLASS:ProfilerStart(name)
	name = tostring(name or "")

	if self._profiler[name] then
		return false
	end

	local past = SysTime()
	self._profiler[name] = past
	self._profilertimes[name] = nil

	return true
end

function CLASS:ProfilerEnd(name)
	name = tostring(name or "")
	local past = self._profiler[name]

	if not past then
		return -1
	end

	self._profiler[name] = nil

	local now = SysTime()
	local time = now - past

	self._profilertimes[name] = time
	return time
end

function CLASS:ProfilerTime(name)
	name = tostring(name or "")

	if self._profiler[name] then
		return self:ProfilerEnd(name)
	end

	return self._profilertimes[name] or -1
end

function CLASS:QueueCall(func, ...)
	if not func then return end

	if self._callqueueonce[func] then
		return
	end

	local data = {
		func = func,
		args = {...}
	}

	self:StartListen()
	self._callqueueonce[func] = true
	table.insert(self._callqueue, data)
end

function CLASS:RegisterForDupe()
	if not SERVER then return end

	local ent = self:GetEntity()
	local name = self:GetName()

	if not IsValid(ent) then return end
	if name == "" then return end

	ent._3dstreamradio_classobjs = ent._3dstreamradio_classobjs or {}
	ent._3dstreamradio_classobjs[name] = self

	self:LoadFromDupeInternal()
end

function CLASS:LoadFromDupeInternal()
	if not SERVER then return end

	local ent = self:GetEntity()
	local name = self:GetName()

	if not IsValid(ent) then return end
	if name == "" then return end

	if not ent._3dstreamradio_classobjs_data then return end

	local data = ent._3dstreamradio_classobjs_data[name]
	if not data then return end

	self:QueueCall("PostDupeInternal", ent, name, data)
end

function CLASS:LoadFromDupe()
	self:LoadFromDupeInternal()
end

function CLASS:SetName(name)
	name = tostring(name or "")
	name = string.gsub(name, "[%/%\\%s]", "_")

	local ent = self:GetEntity()
	local oldname = self:GetName()

	if IsValid(ent) and ent._3dstreamradio_classobjs then
		ent._3dstreamradio_classobjs[oldname] = nil
	end

	self.Name = name
	self:RegisterForDupe()
	self:ApplyNetworkedMode()
end

function CLASS:SetEntity(ent)
	local oldent = self:GetEntity()
	local name = self:GetName()

	if IsValid(oldent) and oldent._3dstreamradio_classobjs then
		oldent._3dstreamradio_classobjs[name] = nil
	end

	self.Entity = ent
	self:RegisterForDupe()
	self:ApplyNetworkedMode()
end

function CLASS:GetEntity()
	return self.Entity
end

for k, v in pairs(StreamRadioLib.Network) do
	if not string.find(k, "^[G|S]etNW") then continue end

	if not v then continue end
	if k == "SetNWVarProxy" then continue end
	if k == "SetNWHashProxy" then continue end

	CLASS[k] = function(this, key, value, ...)
		if not this.Valid then return value end
		local ent = this:GetEntity()
		if not IsValid(ent) then return value end

		local prefix = this:GetName()  .. "/"
		key = prefix .. tostring(key or "")

		local r = v(ent, key, value, ...)

		if r == nil then
			r = value
		end

		return r
	end
end

function CLASS:SetNWVarProxy(key, func, ...)
	if not self.Valid then return end
	local ent = self:GetEntity()
	if not IsValid(ent) then return end

	func = self:GetFunction(func)
	assert(func, "argument #2 must be a function!")

	local prefix = self:GetName()  .. "/"
	key = prefix .. tostring(key or "")

	local proxyfunc = function(this, nwkey, ...)
		if not IsValid(self) then return end
		if not self.Network.Active then return end

		nwkey = string.gsub(nwkey, "^" .. string.PatternSafe(prefix), "", 1 )

		self._nw_proxycall = true
		local ret = {func(self, nwkey, ...)}
		self._nw_proxycall = nil

		return unpack(ret)
	end

	return StreamRadioLib.Network.SetNWVarProxy(ent, key, proxyfunc, ...)
end

function CLASS:SetNWHashProxy(key, func, ...)
	if not self.Valid then return end
	local ent = self:GetEntity()
	if not IsValid(ent) then return end

	func = self:GetFunction(func)
	assert(func, "argument #2 must be a function!")

	local prefix = self:GetName()  .. "/"
	key = prefix .. tostring(key or "")

	local proxyfunc = function(this, nwkey, ...)
		if not IsValid(self) then return end
		if not self.Network.Active then return end

		nwkey = string.gsub(nwkey, "^" .. string.PatternSafe(prefix), "", 1 )
		return func(self, nwkey, ...)
	end

	return StreamRadioLib.Network.SetNWHashProxy(ent, key, proxyfunc, ...)
end

function CLASS:NetReceive(id, func)
	id = tostring(id or "")
	if id == "" then return end

	StreamRadioLib.Net.ToHash(id)
	self._netreceivefuncs[id] = func
end

function CLASS:NetSend(id, func, send, ...)
	if not self.Network.Active then return end

	id = tostring(id or "")
	if id == "" then return end

	local ent = self:GetEntity()
	local name = self:GetName()

	if not IsValid(ent) then return end
	if not name then return end

	id = tostring(id or "")

	net.Start(g_networkhookname, false)

	net.WriteEntity(ent)
	StreamRadioLib.Net.SendStringHash(name)
	StreamRadioLib.Net.SendStringHash(id)

	func = self:GetFunction(func)
	if func then
		func(self)
	end

	if CLIENT then
		net.SendToServer()
		return
	end

	send = send or "Broadcast"

	local sendfunc = net[send] or net.Broadcast
	sendfunc(...)
end

function CLASS:ApplyNetworkedMode()
	if not self.Network.Active then return end
	self:QueueCall("ActivateNetworkedMode")
end

function CLASS:ApplyNetworkVars()
	if not CLIENT then return end
	if not self.Network.Active then return end
	if self._nw_proxycall then return end
	if self._nw_applycall then return end

	self._nw_applycall = true
	self:ApplyNetworkVarsInternal()
	self._nw_applycall = nil
end

function CLASS:ApplyNetworkVarsInternal()
	-- Override me
end

function CLASS:ActivateNetworkedMode()
	self.Network.Active = true

	if CLIENT then
		self._nw_applycall = true
		self:ApplyNetworkVarsInternal()
		self._nw_applycall = nil
	end

	local name = self:GetName()
	local ent = self:GetEntity()
	StreamRadioLib.Net.ToHash(name)

	if not IsValid(ent) then return end
	g_nw_register[ent] = g_nw_register[ent] or {}
	g_nw_register[ent][name] = self
end

function CLASS:DeactivateNetworkedMode()
	self.Network.Active = false

	local name = self:GetName()
	local ent = self:GetEntity()
	StreamRadioLib.Net.ToHash(name)

	if not IsValid(ent) then return end
	g_nw_register[ent] = g_nw_register[ent] or {}
	g_nw_register[ent][name] = nil
end

function CLASS:PostDupeInternal(ent, name, data)
	if not IsValid(ent) then return end
	if not name then return end
	if not ent._3dstraemradio_classobjs_data then return end

	ent._3dstreamradio_classobjs_data[name] = nil
	self:CallHook("PostDupe", ent, data)
end

function CLASS:PreDupe(ent)
	return nil
end

function CLASS:PostDupe(ent, data)
end
