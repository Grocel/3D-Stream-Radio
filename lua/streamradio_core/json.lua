local StreamRadioLib = StreamRadioLib
local LIB = StreamRadioLib:NewLib("JSON")

local catchAndErrorNoHaltWithStack = StreamRadioLib.Util.CatchAndErrorNoHaltWithStack

function LIB.Encode(data, prettyPrint)
	if not istable(data) then
		data = {data}
	end

	local status, json = catchAndErrorNoHaltWithStack(util.TableToJSON, data, true)
	if not status then
		return nil
	end

	if not json then
		return nil
	end

	json = StreamRadioLib.String.NormalizeNewlines(json, "\n")
	return json
end

function LIB.Decode(json)
	json = tostring(json or "")
	json = StreamRadioLib.String.NormalizeNewlines(json, "\n")

	json = string.Trim(json)

	if json == "" then
		return {}
	end

	local status, data = catchAndErrorNoHaltWithStack(util.JSONToTable, json, false, false)

	if not status then
		return nil
	end

	if not data then
		return nil
	end

	if not istable(data) then
		data = {data}
	end

	return data
end

return true

