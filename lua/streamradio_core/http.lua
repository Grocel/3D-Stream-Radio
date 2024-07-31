local StreamRadioLib = StreamRadioLib

StreamRadioLib.Http = StreamRadioLib.Http or {}

local LIB = StreamRadioLib.Http
table.Empty(LIB)

local g_emptyFunction = function() end
local g_request_quene = {}

local function callcallbacks(rq, ...)
	if not rq then return end

	if not rq.quene then return end
	if not rq.started then return end

	local tmp = rq.quene

	rq.quene = nil
	rq.started = nil

	for i, func in ipairs(tmp) do
		if not isfunction(func) then continue end
		func(...)
	end
end

local function cleanDoneQuene()
	for k, rq in pairs(g_request_quene) do
		if not rq.quene then
			g_request_quene[k] = nil
			continue
		end

		if not rq.started then
			g_request_quene[k] = nil
			continue
		end
	end
end

local function request(url, callback, parameters, method, headers, body, type)
	url = url or ""
	url = StreamRadioLib.Url.SanitizeUrl(url)

	callback = callback or g_emptyFunction
	parameters = parameters or {}
	method = method or ""

	if method == "" then
		method = "GET"
	end

	local requestdata = {
		url = url,
		method = method,
		parameters = parameters,
		headers = headers,
		body = body,
		type = type,
	}

	local requestname = StreamRadioLib.JSON.Encode(requestdata)
	requestname = StreamRadioLib.Util.Hash(requestdata)

	local rq = g_request_quene[requestname] or {}
	g_request_quene[requestname] = rq

	rq.quene = rq.quene or {}
	table.insert(rq.quene, callback)

	if rq.started then
		return
	end

	local failed = false

	requestdata.failed = function(err)
		callcallbacks(rq, false, {
			err = err or "",
			code = -1,
			body = "",
			len = 0,
			headers = {},

			requestdata = {
				url = requestdata.url,
				method = requestdata.method,
				parameters = requestdata.parameters,
				headers = requestdata.headers,
				body = requestdata.body,
				type = requestdata.type,
			},
		})

		cleanDoneQuene()
		failed = true
	end

	requestdata.success = function(code, body, headers)
		code = code or -1
		body = body or ""

		local success = true

		if code < 0 then
			success = false
		end

		if code >= 400 then
			success = false
		end

		callcallbacks(rq, success, {
			code = code or -1,
			body = body,
			len = #body,
			headers = headers or {},

			requestdata = {
				url = requestdata.url,
				method = requestdata.method,
				parameters = requestdata.parameters,
				headers = requestdata.headers,
				body = requestdata.body,
				type = requestdata.type,
			},
		})

		cleanDoneQuene()
		failed = false
	end

	rq.started = true

	local success = HTTP(requestdata)

	if not success and not failed then
		requestdata.failed("HTTP failed")
	end
end

function LIB.RequestRaw(url, callback, body, method, headers, type)
	type = type or ""

	if type == "" then
		type = "text/plain; charset=utf-8"
	end

	request(url, callback, nil, method, headers, body, type)
end

function LIB.Request(url, callback, parameters, method, headers)
	request(url, callback, parameters, method, headers)
end

function LIB.RequestRawHeader(url, callback, body, headers, type)
	callback = callback or g_emptyFunction

	LIB.RequestRaw(url, function(success, data)
		data.body = nil
		callback(success, data)
	end, "HEAD", body, headers, type)
end

function LIB.RequestHeader(url, callback, parameters, headers)
	callback = callback or g_emptyFunction

	LIB.Request(url, function(success, data)
		data.body = nil
		callback(success, data)
	end, "HEAD", parameters, headers)
end

return true

