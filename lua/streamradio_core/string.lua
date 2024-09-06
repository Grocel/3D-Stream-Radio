local StreamRadioLib = StreamRadioLib

StreamRadioLib.String = StreamRadioLib.String or {}
local LIB = StreamRadioLib.String

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

	for i, v in ipairs(lines) do
		table_insert(tmp, tab)
		table_insert(tmp, v)
		table_insert(tmp, "\n")
	end

	text = table.concat(tmp)

	return text
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

return true

