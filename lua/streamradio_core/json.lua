local StreamRadioLib = StreamRadioLib

StreamRadioLib.JSON = StreamRadioLib.JSON or {}

local LIB = StreamRadioLib.JSON
table.Empty(LIB)

local catchAndErrorNoHaltWithStack = StreamRadioLib.Util.CatchAndErrorNoHaltWithStack

function LIB.Encode(data, prettyPrint)
	if not istable(data) then
		data = {data}
	end

	local status, json = catchAndErrorNoHaltWithStack(util.TableToJSON, data)
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

	json = string.gsub(json, "//.-\n" , "\n")    -- singleline comment
	json = string.gsub(json, "/%*.-%*/" , "\n")  -- multiline comment

	json = string.gsub(json, ",([%s]*)([%]%}])", "%1%2")  -- trailing comma of arrays/objects

	json = string.gsub(json, "\n[%s]*", "\n")     -- remove all spaces at the start of lines
	json = string.gsub(json, "[%s\n]*\n", "\n")   -- remove all empty lines and all spaces at the end of lines
	json = string.gsub(json, "^\n", "")           -- remove first empty new line
	json = string.gsub(json, "\n$", "")           -- remove last empty new line

	json = string.Trim(json)

	if json == "" then
		return {}
	end

	local status, data = catchAndErrorNoHaltWithStack(util.JSONToTable, json)

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

