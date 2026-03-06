local StreamRadioLib = StreamRadioLib
local LIB = StreamRadioLib:NewLib("File")

local g_dataDirectory = StreamRadioLib.DataDirectory
local g_dataStaticDirectory = "data_static/" .. g_dataDirectory

local g_dataRealm = "DATA"
local g_dataStaticRealm = "GAME"

LIB.ENUM_DATA = false
LIB.ENUM_DATA_STATIC = true

local function sanitizePath(path, dontSanitizeChars)
	path = string.lower(path)
	path = string.Trim(path)

	-- Prevent navigation (../)
	path = string.gsub(path, "%.%.%/" , "")
	path = string.gsub(path, "%.%/" , "")

	-- Keep the Path clean from any weird chars
	path = string.gsub(path, "%s+" , "_")
	path = string.gsub(path, "%c+" , "")

	if not dontSanitizeChars then
		path = string.gsub(path, "[^%w_%-%.%/]" , "-")
	end

	return path
end

local function joinAndNormalizePathsArray(paths)
	local tmp = {}

	for _, path in ipairs(paths) do
		path = tostring(path or "")

		if path == "" then
			continue
		end

		if path == "." then
			continue
		end

		if path == ".." then
			continue
		end

		local subpaths = string.Explode("[%/%\\]+", path, true)

		for _, subpath in ipairs(subpaths) do
			subpath = tostring(subpath or "")

			if subpath == "" then
				continue
			end

			if path == "." then
				continue
			end

			if path == ".." then
				continue
			end

			table.insert(tmp, subpath)
		end
	end

	local path = table.concat(tmp, "/")
	return path
end

local function joinAndNormalizePaths(...)
	return joinAndNormalizePathsArray({...})
end

function LIB.GetAbsolutePath(fileName, isStatic, dontSanitizeChars)
	fileName = tostring(fileName or "")

	if fileName == "" then
		error("missing fileName")
		return
	end

	isStatic = isStatic or LIB.ENUM_DATA

	local path = nil
	local realm = nil

	if isStatic then
		path, realm = joinAndNormalizePaths(g_dataStaticDirectory, fileName), g_dataStaticRealm
	else
		path, realm = joinAndNormalizePaths(g_dataDirectory, fileName), g_dataRealm
	end

	path = sanitizePath(path, dontSanitizeChars)
	return path, realm
end

function LIB.Exists(fileName, isStatic)
	local fileName, realm = LIB.GetAbsolutePath(fileName, isStatic)
	return file.Exists(fileName, realm)
end

function LIB.IsDir(path, isStatic)
	local path, realm = LIB.GetAbsolutePath(path, isStatic)
	return file.IsDir(path, realm)
end

function LIB.CreateDir(path)
	path = LIB.GetAbsolutePath(path)

	if not file.IsDir(path, g_dataRealm) then
		file.CreateDir(path, g_dataRealm)

		if not file.IsDir(path, g_dataRealm) then
			return false
		end
	end

	return true
end

function LIB.Open(fileName, fileMode, isStatic)
	local fileName, realm = LIB.GetAbsolutePath(fileName, isStatic)
	return file.Open(fileName, fileMode, realm)
end

function LIB.Read(fileName, isStatic)
	local fileName, realm = LIB.GetAbsolutePath(fileName, isStatic)

	if not file.Exists(fileName, realm) then
		return nil
	end

	return file.Read(fileName, realm)
end

function LIB.AsyncRead(fileName, isStatic, callback)
	local fileName, realm = LIB.GetAbsolutePath(fileName, isStatic)

	return file.AsyncRead(fileName, realm, callback)
end

function LIB.Write(fileName, fileContent)
	fileContent = tostring(fileContent or "")
	fileName = LIB.GetAbsolutePath(fileName)

	if file.Exists(fileName, g_dataRealm) then
		file.Delete(fileName)

		if file.Exists(fileName, g_dataRealm) then
			return false
		end
	else
		local path = string.GetPathFromFilename(fileName)

		if not file.IsDir(path, g_dataRealm) then
			file.CreateDir(path, g_dataRealm)

			if not file.IsDir(path, g_dataRealm) then
				return false
			end
		end
	end

	file.Write(fileName, fileContent)

	if not file.Exists(fileName, g_dataRealm) then
		return false
	end

	return true
end

function LIB.Delete(fileName)
	fileName = LIB.GetAbsolutePath(fileName)

	if file.Exists(fileName, g_dataRealm) then
		file.Delete(fileName)

		if file.Exists(fileName, g_dataRealm) then
			return false
		end
	end

	return true
end

function LIB.Find(pathName, isStatic, sorting)
	local pathName, realm = LIB.GetAbsolutePath(pathName, isStatic, true)
	return file.Find(pathName .. "*", realm, sorting)
end

return true

