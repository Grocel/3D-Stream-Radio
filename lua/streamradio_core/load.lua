if not StreamRadioLib then return end

local loadSH = StreamRadioLib.LoadSH
local loadCL = StreamRadioLib.LoadCL
local loadSV = StreamRadioLib.LoadSV

if not loadSH then return end
if not loadCL then return end
if not loadSV then return end

local collectgarbage = collectgarbage

local CL = CLIENT
local SV = SERVER
local errors = {}
local errorsdelay = {}

-- Let's check for bad overrides of GMod libraries/functions
local function CheckLib( libname, funcname, datatype )
	local obj = _G[libname]
	local datatype = datatype or "function"
	local isLib = not funcname
	local isVar = funcname

	if ( isVar ) then
		if ( istable( _G[libname] ) ) then
			obj = _G[libname][funcname]
		else
			obj = nil
		end
	end

	-- Everything fine?
	if ( istable( obj ) and isLib ) then return false end
	if ( type( obj ) == datatype and isVar ) then return false end

	-- Let's kick some bad addons' ass.
	-- You don't override GMod libraries!

	local errortext = ""
	local Addonname = StreamRadioLib.Addonname or ""
	local index = libname

	if ( isVar ) then
		index = index .. "_" .. funcname
	end

	errorsdelay[index] = 0

	if ( istable( hook ) and isfunction( hook.Add ) and isfunction( hook.Remove ) ) then
		hook.Add( "Think", "StreamRadioLib_Error_" .. index, function( )
			if ( not errorsdelay[index] ) then return end

			if ( errorsdelay[index] >= 20 ) then
				hook.Remove( "Think", "StreamRadioLib_Error_" .. index )
				local errortext = errors[index]
				if ( not errortext ) then return end
				if ( errortext == "" ) then return end
				errors[index] = nil
				errorsdelay[index] = nil

				-- Tell the user about that confict
				error( errortext )

				return
			end

			errorsdelay[index] = errorsdelay[index] + 1
		end )
	end

	StreamRadioLib.ErrorString = StreamRadioLib.ErrorString or ""

	-- Lib is a function
	if ( isfunction( obj ) and isLib ) then
		local tab = {}

		if ( istable( debug ) and isfunction( debug.getinfo ) ) then
			tab = debug.getinfo( obj ) or {}
		end

		_G[libname] = nil -- Let's fuck that bad addon up
		--We don't need those
		tab.func = nil
		tab.isvararg = nil
		tab.nups = nil
		tab.nparams = nil
		tab.namewhat = nil
		tab.currentline = nil

		if ( tab ) then
			local err = "Some addon is conflicting with the GMod's '" .. libname .. "' library!\nIts datatype is 'function'! Please report this!\n"
			errortext = Addonname .. err .. table.ToString( tab, "Function data of '" .. libname .. "'", true )
			StreamRadioLib.ErrorString = StreamRadioLib.ErrorString .. "\n" .. err
			errors[index] = errortext

			return true
		end
	end

	-- Lib is not a lib
	if ( not istable( obj ) and isLib ) then
		_G[libname] = nil -- Let's fuck that bad addon up
		local err = "Some addon is conflicting with the GMod's '" .. libname .. "' library!\nIts datatype is '" .. type( obj ) .. "'! Please report this!\n"
		errortext = Addonname .. err
		StreamRadioLib.ErrorString = StreamRadioLib.ErrorString .. "\n" .. err
	end

	-- Lib variable is not the right type
	if ( ( type( obj ) ~= datatype ) and isVar ) then
		if ( istable( _G[libname] ) ) then
			_G[libname][funcname] = nil -- Let's fuck that bad addon up
			local err = "Some addon is conflicting with the GMod's '" .. libname .. "." .. funcname .. "' function!\nIts datatype is '" .. type( obj ) .. "'! Please report this!\n"
			errortext = Addonname .. err
			StreamRadioLib.ErrorString = StreamRadioLib.ErrorString .. "\n" .. err
		else
			_G[libname] = nil -- Let's fuck that bad addon up
		end
	end

	errors[index] = errortext
	ErrorNoHalt( errortext )

	return true
end

-- Do not load when something is broken
if ( CheckLib( "sound" ) ) then
	return
end

if ( CL and CheckLib( "sound", "PlayURL" ) ) then
	return
end

if ( CL and CheckLib( "sound", "PlayFile" ) ) then
	return
end

if ( CheckLib( "net" ) ) then
	return
end

if ( CheckLib( "table" ) ) then
	return
end

if ( CheckLib( "table", "Copy" ) ) then
	return
end

if ( CheckLib( "concommand" ) ) then
	return
end

if ( CheckLib( "concommand", "Add" ) ) then
	return
end

if ( CheckLib( "hook" ) ) then
	return
end

if ( CheckLib( "hook", "Add" ) ) then
	return
end

if ( CheckLib( "hook", "Run" ) ) then
	return
end

if ( CL and CheckLib( "vgui" ) ) then
	return
end

if ( CL and CheckLib( "vgui", "Register" ) ) then
	return
end

StreamRadioLib.DataDirectory = "streamradio"

local ok = true
ok = ok and loadSH("streamradio_core/timedpairs.lua")

ok = ok and loadSH("streamradio_core/api.lua")
ok = ok and loadSH("streamradio_core/lib.lua")
ok = ok and loadSH("streamradio_core/net.lua")
ok = ok and loadSH("streamradio_core/network.lua")
ok = ok and loadSH("streamradio_core/timer.lua")
ok = ok and loadSH("streamradio_core/tool.lua")
ok = ok and loadSH("streamradio_core/skin.lua")
ok = ok and loadSH("streamradio_core/models.lua")
ok = ok and loadSH("streamradio_core/interface.lua")
ok = ok and loadSH("streamradio_core/cache.lua")
ok = ok and loadSH("streamradio_core/classes.lua")

ok = ok and loadSV("streamradio_core/server/sv_lib.lua")
ok = ok and loadSV("streamradio_core/server/sv_res.lua")
ok = ok and loadSV("streamradio_core/server/sv_playlist.lua")
ok = ok and loadSV("streamradio_core/server/sv_playlist_edit.lua")

ok = ok and loadCL("streamradio_core/client/cl_help.lua")
ok = ok and loadCL("streamradio_core/client/cl_lib.lua")
ok = ok and loadCL("streamradio_core/client/cl_presets.lua")
ok = ok and loadCL("streamradio_core/client/cl_settings.lua")
ok = ok and loadCL("streamradio_core/client/cl_skin.lua")
ok = ok and loadCL("streamradio_core/client/cl_surface.lua")
ok = ok and loadCL("streamradio_core/client/cl_rendertarget.lua")
ok = ok and loadCL("streamradio_core/client/cl_playlist_edit.lua")
ok = ok and loadCL("streamradio_core/client/cl_vgui.lua")
ok = ok and loadCL("streamradio_core/client/cl_vgui_editor.lua")

collectgarbage( "collect" )
return ok
