local StreamRadioLib = StreamRadioLib

if not istable(CLASS) then
	StreamRadioLib.ReloadClasses()
	return
end

local LIBNetwork = StreamRadioLib.Network
local LIBNet = StreamRadioLib.Net
local LIBUtil = StreamRadioLib.Util

local emptyTableSafe = LIBUtil.EmptyTableSafe

local BASE = CLASS:GetBaseClass()

local g_listeners = {}
local g_super_listeners = {}

local g_hookname = "classsystem_listen"
local g_listengroups = 8
local g_nextgroup = 1
local g_hookruns = false
local g_fasthooksruns = false

local g_minRate = 0

for i = 1, g_listengroups do
	g_listeners[i] = {}
end

StreamRadioLib.Hook.Remove("Think", g_hookname)

local function g_listentogroup()
	-- think function with load balancing between frames for registered instances of the class system

	for i = 1, g_listengroups do
		local found = nil

		local thisgroup = g_nextgroup
		local group = g_listeners[thisgroup]

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

			local listengroupid = listener.listengroupid

			if thisgroup ~= listengroupid then
				g_listeners[thisgroup][id] = nil

				if listengroupid then
					g_listeners[listengroupid][id] = listener
				end

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

		g_nextgroup = (thisgroup % g_listengroups) + 1

		-- only run the next group if this one was empty (found = nil)
		if found then
			return found
		end
	end

	return nil
end

local function g_listenfunc()
	local starttime = SysTime()

	local found = g_listentogroup()

	if found then
		found:SetGlobalVar("base_listener_thinktime", SysTime() - starttime)
		found:SetGlobalVar("base_listener_current_listeners_count", 0)
	end
end


local function g_fastlistenfunc()
	-- think function with faster rate for registered instances of the class system

	local now = RealTime()

	g_minRate = 0

	if CLIENT then
		if StreamRadioLib.IsRenderTarget() then
			g_minRate = 1 / StreamRadioLib.GetRenderTargetFPS()
			g_minRate = math.min(g_minRate, 0.1)
		end
	end

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

		if not listener.FastThink then
			g_super_listeners[id] = nil
			continue
		end

		if not listener.Created then
			continue
		end

		local nextCall = listener.fastThinkNextCall or 0

		if nextCall > now then
			found = listener
			continue
		end

		listener:FastThink()

		local fastThinkRate = math.max(listener.fastThinkRate or 0, g_minRate)
		listener.fastThinkNextCall = now + fastThinkRate

		found = listener
	end

	if found then
		found:SetGlobalVar("base_listener_fastthinktime", SysTime() - starttime)
	end
end

local function g_register_thinkfunc()
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end

	if g_hookruns then return end
	if g_fasthooksruns then return end

	StreamRadioLib.Hook.Add("Think", g_hookname, function()
		if g_hookruns then
			g_listenfunc()
		end

		if g_fasthooksruns then
			g_fastlistenfunc()
		end
	end)
end

LIBNetwork.AddNetworkString(g_hookname)

LIBNet.Receive(g_hookname, function(len, ply)
	if SERVER and not IsValid(ply) then
		return
	end

	local nwent = net.ReadEntity()
	local nwname = LIBNet.ReceiveIdentifier()
	local id = LIBNet.ReceiveIdentifier()

	if not IsValid(nwent) then return end
	if not nwname then return end
	if not id then return end

	if nwname == "" then return end
	if id == "" then return end

	local classobjs_nw_register = nwent._3dstraemradio_classobjs_nw_register
	if not classobjs_nw_register then return end

	local this = classobjs_nw_register[nwname]
	if not IsValid(this) then
		return
	end

	if not this._netreceivefuncs then
		return
	end

	local thisnwent = this:GetEntity()
	if nwent ~= thisnwent then
		return
	end

	local thisnwname = this:GetNWName()
	if nwname ~= thisnwname then
		return
	end

	local func = this:GetFunction(this._netreceivefuncs[id])
	if not func then
		return
	end

	func(this, id, len, ply)
end)

function CLASS:AssignToListenGroup()
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
	self.NWName = ''

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
	emptyTableSafe(self._watch)
	emptyTableSafe(self._old)
	emptyTableSafe(self._profile)
	emptyTableSafe(self._callqueue)
	emptyTableSafe(self._callqueueonce)
	emptyTableSafe(self._events)

	self:RemoveFromNwRegisterInternal(self.entityClassobjsNwRegister)
	self.entityClassobjsNwRegister = nil
	self._entityTableGetter = nil

	self.Network.Active = false

	self:StopListen()
	self:StopFastThink()

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
	identifier = tostring(identifier or "")

	local name = string.format("OBJ[%s][%i]_%s", self:GetClassname(), self:GetID(), identifier)
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

function CLASS:TimerUntil(identifier, delay, func)
	local name = self:TimerGetName(identifier)

	StreamRadioLib.Timer.Remove(name)
	StreamRadioLib.Timer.Until(name, delay, function()
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
	return self.listengroupid
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
	if not self.CanListen then
		self:StopListen()
		return
	end

	local needThink = false

	if self.Think then
		local now = RealTime()
		local nextCall = self.thinkNextCall or 0

		if nextCall < now then
			self:Think()

			local thinkRate = math.max(self.thinkRate or 0.05, g_minRate)
			self.thinkNextCall = now + thinkRate
		end

		needThink = true
	end

	local callqueuetemp = self._callqueuetemp
	local callqueue = self._callqueue
	local callqueueonce = self._callqueueonce

	if callqueuetemp then
		for k, data in pairs(callqueuetemp) do
			local func = data.func
			local args = data.args

			if not func then
				continue
			end

			func(self, unpack(args))
			needThink = true
		end
	end

	emptyTableSafe(callqueuetemp)

	if callqueue then
		for k, data in ipairs(callqueue) do
			local func = data.func

			func = self:GetFunction(func)
			if not func then
				continue
			end

			callqueuetemp[k] = {
				func = func,
				args = data.args,
			}

			needThink = true
		end
	end

	emptyTableSafe(callqueue)
	emptyTableSafe(callqueueonce)

	if not needThink then
		self:StopListen()
	end
end

function CLASS:AssignToListenGroupInternal()
	if not self.AssignToListenGroup then
		return
	end

	local listengroupid = self:AssignToListenGroup()
	listengroupid = tonumber(listengroupid)

	if not listengroupid then
		return
	end

	listengroupid = (listengroupid % g_listengroups) + 1

	self.listengroupid = listengroupid
end

function CLASS:AssignListenGroup()
	if not self.CanListen then
		return
	end

	if not self.listengroupid then
		self:AssignToListenGroupInternal()
		return
	end

	local listengroupid = self.listengroupid
	if not listengroupid then
		return
	end

	local id = self:GetID()

	g_listeners[listengroupid][id] = self
end

function CLASS:StartListen()
	if not self.CanListen then
		return
	end

	self._listentimeout = nil

	StreamRadioLib.Timedcall(function()
		if not IsValid(self) then return end
		self:AssignListenGroup()
	end)

	if g_hookruns then return end

	g_register_thinkfunc()
	g_hookruns = true
end

function CLASS:StopListen()
	if self._listentimeout then
		return
	end

	self._listentimeout = 5
end

function CLASS:StartFastThink()
	self:QueueCall("_StartFastThink")
end

function CLASS:_StartFastThink()
	self:StopFastThink()

	local id = self:GetID()
	g_super_listeners[id] = self

	if not g_fasthooksruns then
		g_register_thinkfunc()
		g_fasthooksruns = true
	end
end

function CLASS:StopFastThink()
	local id = self:GetID()
	g_super_listeners[id] = nil
end

function CLASS:SetThinkRate(rate)
	self.thinkRate = tonumber(rate or 0) or 0
end

function CLASS:GetThinkRate()
	return self.thinkRate or 0
end

function CLASS:GetThinkNextCall()
	return self.thinkNextCall or 0
end

function CLASS:SetFastThinkRate(rate)
	self.fastThinkRate = tonumber(rate or 0) or 0
end

function CLASS:GetFastThinkRate()
	return self.fastThinkRate or 0
end

function CLASS:GetFastThinkNextCall()
	return self.fastThinkNextCall or 0
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

	self._callqueueonce[func] = true
	table.insert(self._callqueue, data)

	self:StartListen()
end

function CLASS:LoadToDupeInternal(dupeTable)
	if not SERVER then return end
	if not istable(dupeTable) then return end

	local name = self:GetName()
	if name == "" then return end

	dupeTable[name] = self:CallHook("PreDupe")
end

function CLASS:LoadToDupe(dupeTable)
	if not SERVER then return end
	if not istable(dupeTable) then return end

	self:LoadToDupeInternal(dupeTable)
end

function CLASS:LoadFromDupeInternal(dupeTable)
	if not SERVER then return end
	if not istable(dupeTable) then return end

	local name = self:GetName()
	if name == "" then return end

	local data = dupeTable[name]
	if data == nil then return end

	self:CallHook("PostDupe", data)
end

function CLASS:LoadFromDupe(dupeTable)
	if not SERVER then return end
	if not istable(dupeTable) then return end

	self:LoadFromDupeInternal(dupeTable)
end

function CLASS:SetName(name)
	name = tostring(name or "")
	name = string.gsub(name, "[%/%\\%s]", "_")

	self.Name = name
end

function CLASS:GetReferenceClassobjsNWRegister()
	return self.entityClassobjsNwRegister
end

function CLASS:SetReferenceClassobjsNWRegister(nwRegister)
	if not istable(nwRegister) then
		return
	end

	self.entityClassobjsNwRegister = nwRegister
end

function CLASS:AddToNwRegisterInternal(nwRegister)
	if not istable(nwRegister) then
		return
	end

	local nwname = self:GetNWName()
	if not nwname then
		return
	end

	if nwname == "" then
		return
	end

	nwRegister[nwname] = self
	self:SetReferenceClassobjsNWRegister(nwRegister)
end

function CLASS:RemoveFromNwRegisterInternal(nwRegister)
	if not istable(nwRegister) then
		return
	end

	local nwname = self:GetNWName()
	if not nwname then
		return
	end

	if nwname == "" then
		return
	end

	nwRegister[nwname] = nil
	self:SetReferenceClassobjsNWRegister(nwRegister)
end

function CLASS:AddToNwRegister(nwRegister)
	self:AddToNwRegisterInternal(nwRegister)
end

function CLASS:RemoveFromNwRegister(nwRegister)
	self:RemoveFromNwRegisterInternal(nwRegister)
end

function CLASS:GetEntity()
	return self.Entity
end

function CLASS:GetEntityTable()
	if not self._entityTableGetter then
		return nil
	end

	return self._entityTableGetter()
end

function CLASS:SetEntity(ent)
	if not IsValid(ent) then
		self.Entity = nil
		self._entityTableGetter = nil

		self:RemoveFromNwRegister(self.entityClassobjsNwRegister)

		self:ApplyNetworkedMode()
		return
	end

	self.Entity = ent
	local entTable = ent:GetTable()

	self._entityTableGetter = function()
		-- avoid storing the entity table directly, so we dont leak memory
		return entTable
	end

	self:SetReferenceClassobjsNWRegister(entTable._3dstraemradio_classobjs_nw_register)

	self:ApplyNetworkedMode()
end

function CLASS:SetNWName(nwname)
	nwname = tostring(nwname or "")
	nwname = string.gsub(nwname, "[%/%\\%s]", "_")

	self.NWName = nwname
	self:ApplyNetworkedMode()
end

function CLASS:GetNWName(name)
	return self.NWName or ""
end

do
	local loopThis = function(funcName, func)
		if not isfunction(func) then return end

		if funcName == "SetNWVarCallback" then return end
		if not string.find(funcName, "^[G|S]etNW") then return end

		CLASS[funcName] = function(this, key, value, ...)
			if not this.Valid then return value end

			local entTable = this:GetEntityTable()
			if not entTable then return value end

			local prefix = this:GetNWName()  .. "/"
			key = prefix .. tostring(key or "")

			local r = func(entTable, key, value, ...)

			if r == nil then
				r = value
			end

			return r
		end
	end

	for funcName, func in pairs(LIBNetwork) do
		loopThis(funcName, func)
	end
end

function CLASS:SetNWVarCallback(key, datatype, func, ...)
	if not self.Valid then return end

	local entTable = self:GetEntityTable()
	if not entTable then return end

	func = self:GetFunction(func)
	assert(func, "argument #2 must be a function!")

	local prefix = self:GetNWName() .. "/"
	key = prefix .. tostring(key or "")

	local prefixReg = "^" .. string.PatternSafe(prefix)

	local proxyfunc = function(this, nwkey, ...)
		if not IsValid(self) then return end
		if not self.Network.Active then return end

		nwkey = string.gsub(nwkey, prefixReg, "", 1 )

		self._nw_proxycall = true
		local ret = {func(self, nwkey, ...)}
		self._nw_proxycall = nil

		return unpack(ret)
	end

	return LIBNetwork.SetNWVarCallback(entTable, datatype, key, proxyfunc, ...)
end

function CLASS:NetReceive(id, func)
	id = tostring(id or "")
	if id == "" then return end

	local nwname = self:GetNWName()

	if nwname and nwname ~= "" then
		LIBNetwork.AddNetworkString(nwname)
	end

	LIBNetwork.AddNetworkString(id)
	self._netreceivefuncs[id] = func
end

function CLASS:NetSend(id, func, sendfunc, ...)
	if not self.Network.Active then return end

	id = tostring(id or "")
	if id == "" then return end

	local ent = self:GetEntity()
	local nwname = self:GetNWName()

	if not IsValid(ent) then return end
	if not nwname then return end
	if nwname == "" then return end

	LIBNetwork.AddNetworkString(nwname)
	LIBNetwork.AddNetworkString(id)

	LIBNet.Start(g_hookname, false)

	net.WriteEntity(ent)
	LIBNet.SendIdentifier(nwname)
	LIBNet.SendIdentifier(id)

	func = self:GetFunction(func)
	if func then
		func(self)
	end

	if CLIENT then
		net.SendToServer()
		return
	end

	if not sendfunc then
		net.Broadcast()
		return
	end

	sendfunc(...)
end

function CLASS:NetSendToPlayers(id, func, playerlist)
	if CLIENT then
		return
	end

	local playerlist = table.ClearKeys(playerlist or {})
	if #playerlist <= 0 then return end

	self:NetSend(id, func, net.Send, playerlist)
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
	-- override me
end

function CLASS:ActivateNetworkedMode()
	self.Network.Active = true

	if CLIENT then
		self._nw_applycall = true
		self:ApplyNetworkVarsInternal()
		self._nw_applycall = nil
	end

	local nwname = self:GetNWName()
	LIBNetwork.AddNetworkString(nwname)

	self:AddToNwRegister(self:GetReferenceClassobjsNWRegister())
end

function CLASS:DeactivateNetworkedMode()
	self.Network.Active = false
end

function CLASS:PreDupe()
	return nil
end

function CLASS:PostDupe(data)
end

return true

