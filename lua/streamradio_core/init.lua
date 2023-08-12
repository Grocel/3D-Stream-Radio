-- 3D Stream Radio. Made By Grocel.

if not StreamRadioLib then return end
local LIB = StreamRadioLib

local LIBLoadSH = LIB.LoadSH
local LIBLoadCL = LIB.LoadCL
local LIBLoadSV = LIB.LoadSV

if not LIBLoadSH then return end
if not LIBLoadCL then return end
if not LIBLoadSV then return end

local g_ok = true

local function loadSH(lua, ...)
    local status, loaded = LIBLoadSH(lua, ...)

    if not status then
        g_ok = false
        return false
    end

    if not loaded then
        g_ok = false
        return false
    end

    return true
end

local function loadCL(lua, ...)
    local status, loaded = LIBLoadCL(lua, ...)

    if not status then
        g_ok = false
        return false
    end

    if CLIENT and not loaded then
        g_ok = false
        return false
    end

    return true
end

local function loadSV(lua, ...)
    local status, loaded = LIBLoadSV(lua, ...)

    if not status then
        g_ok = false
        return false
    end

    if SERVER and not loaded then
        g_ok = false
        return false
    end

    return true
end

LIB.DataDirectory = "streamradio"

local _, NetURL = LIB.LoadSH("streamradio_core/neturl.lua")
LIB.NetURL = NetURL

loadSH("streamradio_core/api.lua")
loadSH("streamradio_core/util.lua")
loadSH("streamradio_core/hook.lua")
loadSH("streamradio_core/timedpairs.lua")
loadSH("streamradio_core/convar.lua")
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
loadCL("streamradio_core/client/settings/admin.lua")
loadCL("streamradio_core/client/settings/general.lua")
loadCL("streamradio_core/client/settings/vr.lua")
loadCL("streamradio_core/client/cl_skin.lua")
loadCL("streamradio_core/client/cl_surface.lua")
loadCL("streamradio_core/client/cl_playlist_edit.lua")
loadCL("streamradio_core/client/cl_vgui.lua")
loadCL("streamradio_core/client/cl_vgui_editor.lua")

if not g_ok then
    return
end

return true

