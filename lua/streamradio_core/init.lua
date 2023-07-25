-- 3D Stream Radio. Made By Grocel.

if not StreamRadioLib then return end

local loadSH = StreamRadioLib.LoadSH
local loadCL = StreamRadioLib.LoadCL
local loadSV = StreamRadioLib.LoadSV

if not loadSH then return end
if not loadCL then return end
if not loadSV then return end

StreamRadioLib.DataDirectory = "streamradio"

local _, NetURL = StreamRadioLib.LoadSH("streamradio_core/neturl.lua")
StreamRadioLib.NetURL = NetURL

loadSH("streamradio_core/api.lua")
loadSH("streamradio_core/util.lua")
loadSH("streamradio_core/convar.lua")
loadSH("streamradio_core/hook.lua")
loadSH("streamradio_core/timedpairs.lua")
loadSH("streamradio_core/language.lua")
loadSH("streamradio_core/bass3.lua")
loadSH("streamradio_core/lib.lua")
loadSH("streamradio_core/enum.lua")
loadSH("streamradio_core/error.lua")
loadSH("streamradio_core/json.lua")
loadSH("streamradio_core/network.lua")
loadSH("streamradio_core/net.lua")
loadSH("streamradio_core/timer.lua")
loadSH("streamradio_core/tool.lua")
loadSH("streamradio_core/http.lua")
loadSH("streamradio_core/skin.lua")
loadSH("streamradio_core/models.lua")
loadSH("streamradio_core/interface.lua")
loadSH("streamradio_core/filesystem.lua")
loadSH("streamradio_core/cache.lua")
loadSH("streamradio_core/classes.lua")
loadSH("streamradio_core/properties.lua")
loadSH("streamradio_core/print.lua")
loadSH("streamradio_core/vr.lua")
loadSH("streamradio_core/wire.lua")
loadSH("streamradio_core/shoutcast.lua")

loadSV("streamradio_core/server/sv_lib.lua")
loadSV("streamradio_core/server/sv_res.lua")
loadSV("streamradio_core/server/sv_playlist_edit.lua")
loadSV("streamradio_core/server/sv_permaprops.lua")

loadCL("streamradio_core/client/cl_help.lua")
loadCL("streamradio_core/client/cl_lib.lua")
loadCL("streamradio_core/client/cl_presets.lua")
loadCL("streamradio_core/client/cl_menu.lua")
loadCL("streamradio_core/client/cl_settings.lua")
loadCL("streamradio_core/client/settings/general.lua")
loadCL("streamradio_core/client/settings/vr.lua")
loadCL("streamradio_core/client/cl_skin.lua")
loadCL("streamradio_core/client/cl_surface.lua")
loadCL("streamradio_core/client/cl_playlist_edit.lua")
loadCL("streamradio_core/client/cl_vgui.lua")
loadCL("streamradio_core/client/cl_vgui_editor.lua")

return true
