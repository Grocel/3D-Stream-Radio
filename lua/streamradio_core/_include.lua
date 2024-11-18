-- 3D Stream Radio. Made By Grocel.

if not StreamRadioLib then return end
local LIB = StreamRadioLib

local loadSH = LIB.LoadSH
local loadCL = LIB.LoadCL
local loadSV = LIB.LoadSV

if not loadSH then return end
if not loadCL then return end
if not loadSV then return end

LIB.DataDirectory = "streamradio"

do
    local status, lib = loadSH("streamradio_core/external/neturl.lua")

    LIB.NetURL = nil

    if status then
        LIB.NetURL = lib
    end
end

loadSH("streamradio_core/api.lua")
loadSH("streamradio_core/string.lua")
loadSH("streamradio_core/string_accents.lua")
loadSH("streamradio_core/util.lua")
loadSH("streamradio_core/url.lua")
loadSH("streamradio_core/hook.lua")
loadSH("streamradio_core/timedpairs.lua")
loadSH("streamradio_core/convar.lua")
loadSH("streamradio_core/language.lua")
loadSH("streamradio_core/bass3.lua")
loadSH("streamradio_core/lib.lua")
loadSH("streamradio_core/enum.lua")
loadSH("streamradio_core/error.lua")
loadSH("streamradio_core/stream.lua")
loadSH("streamradio_core/json.lua")
loadSH("streamradio_core/network.lua")
loadSH("streamradio_core/net.lua")
loadSH("streamradio_core/timer.lua")
loadSH("streamradio_core/tool.lua")
loadSH("streamradio_core/http.lua")
loadSH("streamradio_core/shoutcast.lua")
loadSH("streamradio_core/skin.lua")
loadSH("streamradio_core/models.lua")
loadSH("streamradio_core/interface.lua")
loadSH("streamradio_core/filesystem.lua")
loadSH("streamradio_core/cache.lua")
loadSH("streamradio_core/classes.lua")
loadSH("streamradio_core/properties.lua")
loadSH("streamradio_core/print.lua")
loadSH("streamradio_core/cfchttp.lua")
loadSH("streamradio_core/vr.lua")
loadSH("streamradio_core/wire.lua")

loadSV("streamradio_core/server/sv_lib.lua")
loadSV("streamradio_core/server/sv_resource.lua")
loadSV("streamradio_core/server/sv_playlist_edit.lua")
loadSV("streamradio_core/server/sv_permaprops.lua")
loadSV("streamradio_core/server/sv_whitelist.lua")

loadCL("streamradio_core/client/cl_help.lua")
loadCL("streamradio_core/client/cl_lib.lua")
loadCL("streamradio_core/client/cl_presets.lua")
loadCL("streamradio_core/client/cl_menu.lua")
loadCL("streamradio_core/client/cl_settings.lua")
loadCL("streamradio_core/client/settings/admin.lua")
loadCL("streamradio_core/client/settings/general.lua")
loadCL("streamradio_core/client/settings/vr.lua")
loadCL("streamradio_core/client/cl_skin.lua")
loadCL("streamradio_core/client/cl_surface.lua")
loadCL("streamradio_core/client/cl_playlist_edit.lua")
loadCL("streamradio_core/client/cl_vgui.lua")
loadCL("streamradio_core/client/cl_vgui_editor.lua")
loadCL("streamradio_core/client/cl_whitelist.lua")

StreamRadioLib.Url.Load()
StreamRadioLib.Interface.Load()
StreamRadioLib.Filesystem.Load()

StreamRadioLib.Whitelist.Load()

StreamRadioLib.Cfchttp.Load()
StreamRadioLib.Cache.Load()

return true

