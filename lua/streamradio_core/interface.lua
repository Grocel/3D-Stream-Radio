StreamRadioLib.Interface = StreamRadioLib.Interface or {}
local LIB = StreamRadioLib.Interface

local LuaInterfaceDirectory = "streamradio_core/interfaces"
local Intefaces = {}
local err_cache = {}

local function AddCommonFunctions(interface)
	if not interface then return end

	function interface:GetJSON(body)
		body = tostring(body or "")

		local json = string.gsub(body, "%<head(.-)%</head%>", "")
		json = string.gsub(json, "%<script(.-)%</script%>", "")
		json = string.gsub(json, "%<style(.-)%</style%>", "")
		json = string.gsub(json, "%<meta(.-)%>", "")
		json = string.gsub(json, "%<link(.-)%>", "")
		json = string.gsub(json, "%<%!%-%-(.-)%-%-%>", "")

		-- Remove spaces and invalid brackets from json
		json = string.Trim(json)
		json = string.Trim(json, "(")
		json = string.Trim(json, ")")
		json = string.Trim(json)

		json = util.JSONToTable(json)
		return json
	end

	function interface:ConvertFileSize(size)
		size = tostring(size or "")

		size = string.Replace(size, ",", "")
		size = string.Trim(size)

		local sizen = tonumber(size)
		if sizen then
			sizen = math.ceil(sizen)
			return sizen
		end

		local number, suffix = string.match(size, "^([%-%.%,%d]+)%s*(%a+)")
		if not number then return -1 end
		if not suffix then return -1 end

		number = string.Replace(number, ",", "")
		number = string.Trim(number)

		number = tonumber(number)
		if not number then return -1 end

		suffix = string.Trim(suffix)
		suffix = string.lower(suffix)

		local cf = 1024
		local conversion_table = {
			byte = 1,
			bytes = 1,
			b = 1,

			kb = cf,
			kbyte = cf,
			kbytes = cf,

			mb = cf ^ 2,
			mbyte = cf ^ 2,
			mbytes = cf ^ 2,

			gb = cf ^ 3,
			gbyte = cf ^ 3,
			gbytes = cf ^ 3,

			tb = cf ^ 4,
			tbyte = cf ^ 4,
			tbytes = cf ^ 4,

			pb = cf ^ 5,
			pbyte = cf ^ 5,
			pbytes = cf ^ 5,
		}

		local factor = conversion_table[suffix]
		if not suffix then return -1 end

		sizen = number * factor
		sizen = math.ceil(sizen)

		return sizen
	end

	function interface:ConvertBitrate(size)
		size = tostring(size or "")

		size = string.Replace(size, ",", "")
		size = string.Trim(size)

		local sizen = tonumber(size)
		if sizen then
			return sizen
		end

		local number, suffix = string.match(size, "^([%-%.%,%d]+)%s*(%a+)")
		if not number then return -1 end
		if not suffix then return -1 end

		number = string.Replace(number, ",", "")
		number = string.Trim(number)

		number = tonumber(number)
		if not number then return -1 end

		suffix = string.Trim(suffix)
		suffix = string.lower(suffix)

		local cf = 1000
		local conversion_table = {
			bit = 1,
			bits = 1,
			bps = 1,

			kbit = cf,
			kbits = cf,
			kbps = cf,

			mbit = cf ^ 2,
			mbits = cf ^ 2,
			mbps = cf ^ 2,

			gbit = cf ^ 3,
			gbits = cf ^ 3,
			gbps = cf ^ 3,

			tbit = cf ^ 4,
			tbits = cf ^ 4,
			tbps = cf ^ 4,

			pbit = cf ^ 5,
			pbits = cf ^ 5,
			pbps = cf ^ 5,
		}

		local factor = conversion_table[suffix]
		if not suffix then return -1 end

		sizen = number * factor
		return sizen
	end

	function interface:RequestHeader(url, callback, parameters, headers)
		callback = callback or (function() end)

		local req = self:Request(url, function(suggess, data)
			data.body = nil
			callback(suggess, data)
		end, "HEAD", parameters, headers)

		if not req then
			callback(false, nil)
			return false
		end

		return true
	end

	function interface:Request(url, callback, parameters, method, headers, body, type)
		url = url or ""
		callback = callback or (function() end)
		parameters = parameters or {}
		method = method or ""

		if method == "" then
			method = "GET"
		end

		local req = HTTP({
			url = url,
			method = method,
			parameters = parameters,
			headers = headers,
			body = body,
			type = type,

			failed = function(err)
				callback(false, {
					err = err or "",
					method = method,
					parameters = parameters,
					url = url,
					custom_data = {},
					reload = false,
				})
			end,

			success = function(code, body, headers)
				code = code or -1

				local suggess = true

				if code < 0 then
					suggess = false
				end

				if code >= 400 then
					suggess = false
				end

				callback(suggess, {
					code = code or -1,
					body = body or "",
					headers = headers or {},
					method = method,
					parameters = parameters,
					url = url,
					custom_data = {},
					reload = false,
				})
			end,
		})

		if not req then
			callback(false, nil)
			return false
		end

		return true
	end

	function interface:GetSubInterfaceStack()
		if not self.subinterfaces then return nil end

		local count = #self.subinterfaces
		if count <= 0 then return nil end

		local stack = util.Stack()
		local added = false

		for i = count, 1, -1 do
			local subinterface = self.subinterfaces[i]
			if not subinterface then continue end

			stack:Push(subinterface)
			added = true
		end

		if not added then return nil end
		return stack
	end

	function interface:GetErrorData(errorcode)
		errorcode = tonumber(errorcode or -1) or -1

		if errorcode == -1 then
			return nil
		end

		local function geterror(this)
			if not this then return nil end
			if not this.Errorcodes then return nil end

			local err = this.Errorcodes[errorcode]
			if not err then return nil end

			local nerr = {}

			nerr.interface = self

			if this != self then
				nerr.subinterface = this
			end

			nerr.code = errorcode
			nerr.desc = err.desc or ""
			nerr.text = err.text or ""
			nerr.url = err.url or ""

			if err.userdata then
				nerr.userdata = table.Copy(err.userdata)
			end

			return nerr
		end

		local err = geterror(self)
		if err then
			return err
		end

		if not self.subinterfaces then
			return nil
		end

		for i, v in ipairs(self.subinterfaces) do
			local err = geterror(v)
			if not err then continue end

			return err
		end

		return nil
	end

end

local function AddSubInterfaces(interface)
	if not interface then return false end
	if not interface.subinterfaces then return false end

	local name = interface.name or ""
	local subinterfaces_folder = interface.subinterfaces_folder or ""
	local scriptpath = interface.scriptpath or ""

	if name == "" then return false end
	if subinterfaces_folder == "" then return false end
	if scriptpath == "" then return false end

	local scriptpath = scriptpath .. subinterfaces_folder .. "/"
	local files = file.Find(scriptpath .. "*", "LUA" )

	for _, f in pairs( files or {} ) do
		local scriptfile = scriptpath .. f
		if not file.Exists(scriptfile, "LUA") then continue end

		RADIOIFACE = nil
		RADIOIFACE = {}

		RADIOIFACE.scriptpath = scriptpath
		RADIOIFACE.scriptfile = scriptfile
		RADIOIFACE.parent = interface

		RADIOIFACE.errorspace = interface.errorspace + (#interface.subinterfaces + 1) * 100
		RADIOIFACE.Errorcodes = {}

		AddCommonFunctions(RADIOIFACE)

		StreamRadioLib.LoadSH(scriptfile, true)
		local name = string.Trim(RADIOIFACE.name or "")
		RADIOIFACE.priority = tonumber(RADIOIFACE.priority or 0) or 0

		if name == "" then
			RADIOIFACE = nil
			continue
		end

		if RADIOIFACE.disabled then
			RADIOIFACE = nil
			continue
		end

		interface.subinterfaces[#interface.subinterfaces + 1] = RADIOIFACE
		RADIOIFACE = nil
	end

	table.SortByMember(interface.subinterfaces, "priority", false)
	return true
end

local function AddInterface(script)
	script = script or ""
	if script == "" then return false end

	local scriptpath = LuaInterfaceDirectory .. "/"
	local scriptfile = scriptpath .. script

	if not file.Exists(scriptfile, "LUA") then return false end

	RADIOIFACE = nil
	RADIOIFACE = {}

	RADIOIFACE.scriptpath = scriptpath
	RADIOIFACE.scriptfile = scriptfile

	RADIOIFACE.errorspace = (#Intefaces + 1) * 1000 + 10000
	RADIOIFACE.Errorcodes = {}
	RADIOIFACE.subinterfaces = {}

	AddCommonFunctions(RADIOIFACE)

	StreamRadioLib.LoadSH(scriptfile, true)

	local name = string.Trim(RADIOIFACE.name or "")
	RADIOIFACE.priority = tonumber(RADIOIFACE.priority or 0) or 0

	if name == "" then
		RADIOIFACE = nil
		return false
	end

	if RADIOIFACE.disabled then
		RADIOIFACE = nil
		return false
	end

	local iface = RADIOIFACE

	Intefaces[#Intefaces + 1] = iface
	RADIOIFACE = nil

	AddSubInterfaces(iface)

	err_cache = {}
	return true
end

local function GetInterfaceFromURL(url)
	if not url then return nil end

	for i, v in ipairs(Intefaces) do
		if not v then continue end

		if not v.CheckURL then continue end
		if not v:CheckURL(url) then continue end

		return v
	end

	return nil
end

function LIB.GetErrorData(errorcode)
	errorcode = tonumber(errorcode or -1) or -1

	if errorcode == -1 then
		return nil
	end

	if err_cache[errorcode] then
		return err_cache[errorcode]
	end

	for i, v in ipairs(Intefaces) do
		if not v then continue end
		if not v.GetErrorData then continue end

		local err = v:GetErrorData(errorcode)
		if not err then continue end

		err_cache[errorcode] = err
		return err
	end

	return nil
end

function LIB.Load()
	local files = file.Find(LuaInterfaceDirectory .. "/*", "LUA")
	Intefaces = {}

	for _, f in pairs(files or {}) do
		AddInterface(f)
	end

	table.SortByMember(Intefaces, "priority", false)
	collectgarbage("collect")
end

function LIB.Convert(url, callback)
	url = url or ""
	callback = callback or (function() end)

	if url == "" then
		callback(false, nil, nil)
		return false
	end

	local I = GetInterfaceFromURL(url)
	if not I then
		callback(false, nil, nil)
		return false
	end

	if not I.Convert then
		callback(false, nil, nil)
		return false
	end

	local R = I:Convert(url, function(this, success, convered_url, errorcode, data)
		errorcode = tonumber(errorcode or -1) or -1
		callback(this, success, convered_url, errorcode, data)
	end)

	return R
end

LIB.Load()
