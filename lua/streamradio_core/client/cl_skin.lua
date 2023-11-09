local StreamRadioLib = StreamRadioLib

StreamRadioLib.Skin = StreamRadioLib.Skin or {}

local LIB = StreamRadioLib.Skin

local LIBUtil = StreamRadioLib.Util

local g_mainPath = LIBUtil.GetMainDirectory("skin")

local function IsValidFile(filename)
	return not file.IsDir(filename, "DATA") and file.Exists(filename, "DATA")
end

function LIB.SanitizeName(name)
	name = tostring(name or "")
	name = string.lower(name or "")
	name = string.Trim(name)

	name = string.gsub(name, "[%.%\"%'%:%?%/%\\%*%<%>%|]", "_" )
	name = string.gsub(name, "[%s]", "_" )

	name = string.Trim(name)
	return name
end

function LIB.GetPath(name)
	name = tostring(name or "")

	if name == "" then
		return g_mainPath .. "/"
	end

	local filepath = g_mainPath .. "/" .. name .. ".txt"
	return filepath
end

function LIB.IsValidSkinFile(name)
	local filepath = LIB.GetPath(name)

	if name == "default" then
		return true
	end

	return IsValidFile(filepath)
end

function LIB.Open(name)
	name = LIB.SanitizeName(name)
	if name == "" then
		name = "default"
	end

	if name == "default" then
		local skindata = LIB.GetDefaultSkin()
		if not skindata then return end

		skindata.name = name
		return skindata
	end

	local filepath = LIB.GetPath(name)
	if not IsValidFile(filepath) then
		return nil
	end

	local skinjson = file.Read(filepath, "DATA") or ""
	if skinjson == "" then return end

	local skindata = StreamRadioLib.JSON.Decode(skinjson)
	if not skindata then return end

	skindata.name = name
	return skindata
end

function LIB.Save(name, skindata)
	name = LIB.SanitizeName(name)
	if name == "" then
		name = "default"
	end

	if name == "default" then
		return false
	end

	skindata = skindata or {}
	skindata.name = nil

	local skinjson = StreamRadioLib.JSON.Encode(skindata, true) or ""
	local filepath = LIB.GetPath(name)

	if not LIBUtil.CreateDirectoryForFile(filepath) then return false end
	file.Write(filepath, skinjson)

	return IsValidFile(filepath)
end

function LIB.Delete(name)
	name = LIB.SanitizeName(name)
	if name == "" then
		name = "default"
	end

	if name == "default" then
		return false
	end

	local filepath = LIB.GetPath(name)

	file.Delete(filepath)
	return not IsValidFile(filepath)
end

function LIB.GetList()
	local files = file.Find(g_mainPath .. "/*.txt", "DATA", "nameasc")

	table.insert(files, 1, "default.txt")

	local found = {}
	local nodouble = {}

	for i, v in ipairs(files or {}) do
		local name = string.StripExtension(v)
		name = LIB.SanitizeName(name)

		if not LIB.IsValidSkinFile(name) then
			continue
		end

		if nodouble[name] then
			continue
		end

		nodouble[name] = true
		table.insert(found, name)
	end

	return found
end

return true

