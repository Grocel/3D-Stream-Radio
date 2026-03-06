local StreamRadioLib = StreamRadioLib
local LIB = StreamRadioLib:NewLib("String")

local table = table
local table_insert = table.insert

function LIB.NormalizeNewlines(text, nl)
	nl = tostring(nl or "")
	text = tostring(text or "")

	local replacemap = {
		["\r\n"] = true,
		["\r"] = true,
		["\n"] = true,
	}

	if not replacemap[nl] then
		nl = "\n"
	end

	replacemap[nl] = nil

	for k, v in pairs(replacemap) do
		replacemap[k] = nl
	end

	text = string.gsub(text, "([\r]?[\n]?)", replacemap)

	return text
end

function LIB.IndentTextBlock(text, count, tab)
	text = tostring(text or "")
	tab = tostring(tab or "")
	count = count or 0

	if text == "" then
		return ""
	end

	if tab == "" then
		tab = "    "
	end

	if count <= 0 then
		tab = ""
	else
		tab = string.rep(tab, count)
	end

	local lines = string.Explode("\n", text, false)
	local tmp = {}

	for _, line in ipairs(lines) do
		table_insert(tmp, tab)
		table_insert(tmp, line)
		table_insert(tmp, "\n")
	end

	-- don't add leading newline
	tmp[#tmp] = nil

	text = table.concat(tmp)

	return text
end

function LIB.IsMultiline(text)
	local match = string.match(text, "[\r\n]")

	if not match then
		return false
	end

	return true
end

function LIB.IsVirtualPath(vpath)
	vpath = vpath or ""

	if vpath == "" then
		return false
	end

	if not string.match(vpath, "^%:") then
		return false
	end

	return true
end

local g_sanitized_filenames_cache = {}
local g_sanitized_filepaths_cache = {}

function LIB.SanitizeFilename(filenameInput)
	filenameInput = tostring(filenameInput or "")

	if filenameInput == "" then
		return ""
	end

	if g_sanitized_filenames_cache[filenameInput] then
		return g_sanitized_filenames_cache[filenameInput]
	end

	g_sanitized_filenames_cache[filenameInput] = nil

	local filename = LIB.NormalizeSlashes(filenameInput)

	filename = string.gsub(filename, "%:", '-')
	filename = string.gsub(filename, "%/", '-')

	filename = LIB.SanitizeFilepath(filename)

	g_sanitized_filenames_cache[filenameInput] = filename
	g_sanitized_filenames_cache[filename] = filename

	return filename
end

local g_invalidReplaceMap = {
	["*"] = "-",
	[":"] = "-",
	["?"] = "-",
	[">"] = "-",
	["<"] = "-",
	["|"] = "-",
	["´"] = "-",
	["`"] = "-",
	["~"] = "-",
	["'"] = "-",
	['"'] = "-",
	['#'] = "-",
}

function LIB.SanitizeFilepath(filepathInput)
	filepathInput = tostring(filepathInput or "")

	if filepathInput == "" then
		return ""
	end

	if g_sanitized_filepaths_cache[filepathInput] then
		return g_sanitized_filepaths_cache[filepathInput]
	end

	g_sanitized_filepaths_cache[filepathInput] = nil

	local filepath = LIB.NormalizeSlashes(filepathInput)

	if LIB.IsVirtualPath(filepath) then
		g_sanitized_filepaths_cache[filepathInput] = filepath
		g_sanitized_filepaths_cache[filepath] = filepath

		return filepath
	end

	filepath = string.Trim(filepath)

	filepath = LIB.StripAccents(filepath, true)

	filepath = string.gsub(filepath, ".", g_invalidReplaceMap)

	filepath = string.gsub(filepath, "[^%g%s]", '')
	filepath = string.Trim(filepath)

	filepath = string.gsub(filepath, "%s+", '_')
	filepath = string.lower(filepath)

	g_sanitized_filepaths_cache[filepathInput] = filepath
	g_sanitized_filepaths_cache[filepath] = filepath

	return filepath
end

function LIB.NormalizeSlashes(filepath)
	filepath = tostring(filepath or "")

	if filepath == "" then
		return ""
	end

	filepath = string.gsub(filepath, "[%/%\\]+", '/')
	filepath = string.gsub(filepath, "%.%.%/", '/')
	filepath = string.gsub(filepath, "%.%/", '/')
	filepath = string.gsub(filepath, "%/+", '/')

	return filepath
end

function LIB.IsValidFilepath(filepath)
	filepath = tostring(filepath or "")
	filepath = LIB.NormalizeSlashes(filepath)
	filepath = string.lower(filepath)
	filepath = string.Trim(filepath)

	local sanitizeFilepath = LIB.SanitizeFilepath(filepath)
	if sanitizeFilepath ~= filepath then
		return false
	end

	return true
end

function LIB.IsValidFilename(filename)
	filename = tostring(filename or "")
	filename = string.lower(filename)
	filename = string.Trim(filename)

	local sanitizeFilename = LIB.SanitizeFilename(filename)
	if sanitizeFilename ~= filename then
		return false
	end

	if string.Trim(string.StripExtension(" " .. filename) or "") == "" then
		return false
	end

	return true
end

function LIB.StreamMetaStringToTable(meta)
	meta = tostring(meta or "")
	meta = string.Trim(meta or "")

	local result = {}

	for k, v in string.gmatch(meta, "([%w_]+)%s*=%s*([^;]*)[;]?") do
		k = string.lower(k)
		if k == "" then
			continue
		end

		v = string.gsub(v, "^'(.*)'$", "%1")
		v = string.Trim(v or "")

		result[k] = v
	end

	return result
end

function LIB.EscapeSlashes(str)
	str = string.gsub(str, "(['\"\\])", "\\%1")
	return str
end

local g_newLinesReplacemap = {
	["\r\n"] = "\\r\\n",
	["\r"] = "\\r",
	["\n"] = "\\n",
}

function LIB.EscapeNewlines(str)
	str = string.gsub(str, "([\r]?[\n]?)", g_newLinesReplacemap)
	return str
end

function LIB.UnescapeSlashes(str)
	str = string.gsub(str, "\\\\", "\x01")
	str = string.gsub(str, "(\\(['\"\\]))", "%2")
	str = string.gsub(str, "%\x01", "\\\\")

	return str
end

local g_newLinesReverseReplacemap = {
	["\\r\\n"] = "\r\n",
	["\\r"] = "\r",
	["\\n"] = "\n",
}

function LIB.UnescapeNewlines(str)
	str = string.gsub(str, "([\\r]?[\\n]?)", g_newLinesReverseReplacemap)
	return str
end

local g_lazyStringMeta = {
	ToString = function(self)
		local callback = self.callback

		if not isfunction(callback) then
			return ""
		end

		return callback(self, self.data)
	end,
}

g_lazyStringMeta.__index = g_lazyStringMeta
g_lazyStringMeta.__tostring = g_lazyStringMeta.ToString

function LIB.CreateLazyString(callback, data)
	local lazyString = {}

	lazyString.isLazy = true
	lazyString.callback = callback
	lazyString.data = data

	setmetatable(lazyString, g_lazyStringMeta)

	return lazyString
end

return true

