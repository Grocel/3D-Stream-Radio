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

if CL then
	if not istable(sound) then
		error("Addon confict detected at: _G.sound")
	end

	if not isfunction(sound.PlayURL) then
		error("Addon confict detected at: _G.sound.PlayURL")
	end

	if not isfunction(sound.PlayFile) then
		error("Addon confict detected at: _G.sound.PlayFile")
	end
end

StreamRadioLib.DataDirectory = "streamradio"

local ok = true
ok = ok and loadSH("streamradio_core/timedpairs.lua")

ok = ok and loadSH("streamradio_core/api.lua")
ok = ok and loadSH("streamradio_core/lib.lua")
ok = ok and loadSH("streamradio_core/json.lua")
ok = ok and loadSH("streamradio_core/net.lua")
ok = ok and loadSH("streamradio_core/network.lua")
ok = ok and loadSH("streamradio_core/timer.lua")
ok = ok and loadSH("streamradio_core/tool.lua")
ok = ok and loadSH("streamradio_core/http.lua")
ok = ok and loadSH("streamradio_core/skin.lua")
ok = ok and loadSH("streamradio_core/models.lua")
ok = ok and loadSH("streamradio_core/interface.lua")
ok = ok and loadSH("streamradio_core/filesystem.lua")
ok = ok and loadSH("streamradio_core/cache.lua")
ok = ok and loadSH("streamradio_core/classes.lua")
ok = ok and loadSH("streamradio_core/vr.lua")
ok = ok and loadSH("streamradio_core/shoutcast.lua")

ok = ok and loadSV("streamradio_core/server/sv_lib.lua")
ok = ok and loadSV("streamradio_core/server/sv_res.lua")
ok = ok and loadSV("streamradio_core/server/sv_playlist_edit.lua")
ok = ok and loadSV("streamradio_core/server/sv_permaprops.lua")

ok = ok and loadCL("streamradio_core/client/cl_help.lua")
ok = ok and loadCL("streamradio_core/client/cl_lib.lua")
ok = ok and loadCL("streamradio_core/client/cl_presets.lua")
ok = ok and loadCL("streamradio_core/client/cl_menu.lua")
ok = ok and loadCL("streamradio_core/client/cl_settings.lua")
ok = ok and loadCL("streamradio_core/client/settings/general.lua")
ok = ok and loadCL("streamradio_core/client/settings/vr.lua")
ok = ok and loadCL("streamradio_core/client/cl_skin.lua")
ok = ok and loadCL("streamradio_core/client/cl_surface.lua")
ok = ok and loadCL("streamradio_core/client/cl_rendertarget.lua")
ok = ok and loadCL("streamradio_core/client/cl_playlist_edit.lua")
ok = ok and loadCL("streamradio_core/client/cl_vgui.lua")
ok = ok and loadCL("streamradio_core/client/cl_vgui_editor.lua")

collectgarbage( "collect" )
return ok
