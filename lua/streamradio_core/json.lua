StreamRadioLib.JSON = {}
local LIB = StreamRadioLib.JSON

function LIB.Encode(data, prettyPrint)
	if not istable(data) then
		data = {data}
	end

	local data = util.TableToJSON(data, prettyPrint)
	data = StreamRadioLib.NormalizeNewlines(data, "\n")

	return data
end

function LIB.Decode(data)
	data = tostring(data or "")
	data = StreamRadioLib.NormalizeNewlines(data, "\n")

	data = string.gsub(data, "//.-\n" , "\n")    -- singleline comment
	data = string.gsub(data, "/%*.-%*/" , "\n")  -- multiline comment

	data = string.gsub(data, ",([%s]*)([%]%}])","%1%2")  -- trailing comma of arrays/objects

	data = string.gsub(data, "\n[%s]*","\n")     -- remove all spaces at the start of lines
	data = string.gsub(data, "[%s\n]*\n","\n")   -- remove all empty lines and all spaces at the end of lines
	data = string.gsub(data, "^\n","")           -- remove first empty new line
	data = string.gsub(data, "\n$","")           -- remove last empty new line

	data = string.Trim(data)

	if data == "" then
		return {}
	end

	data = util.JSONToTable(data)

	if not data then
		return nil
	end

	if not istable(data) then
		data = {data}
	end

	return data
end


return LIB
