local StreamRadioLib = StreamRadioLib

StreamRadioLib.Editor = StreamRadioLib.Editor or {}
local LIB = StreamRadioLib.Editor

local LIBNet = StreamRadioLib.Net

local pairs = pairs
local type = type
local IsValid = IsValid
local file = file
local table = table
local string = string
local util = util
local player = player
local ents = ents
local net = net
local ListenPath = ""
local CallbackFunc = nil
local CallbackArgs = {}
local CallbackSelf = nil

function LIB.ListenToPath( path )
	ListenPath = tostring( path or "" )

	return ListenPath
end

function LIB.GetListenPath( )
	return ListenPath
end

function LIB.CreateDir( path )
	if not path then return false end
	if path == "" then return false end

	LIBNet.Start("Editor_Request_Playlist")
	net.WriteUInt( 0, 4 )
	net.WriteString( path )
	net.SendToServer( )

	return true
end

function LIB.Save( path, DataTab )
	if not path then return false end
	if path == "" then return false end

	if not DataTab then return false end
	if not DataTab["format"] then return false end
	if StreamRadioLib.Filesystem.IsFolder(DataTab["format"]) then return false end

	local ply = LocalPlayer()
	if not IsValid(ply) then return false end
	if not ply:IsAdmin() then return false end

	--Start
	LIBNet.Start("Editor_Request_Playlist")
	net.WriteUInt(1, 4)
	net.WriteString(path)
	net.SendToServer()

	StreamRadioLib.TimedpairsStop( "Editor_SaveFile_" .. path )
	StreamRadioLib.Timedpairs( "Editor_SaveFile_" .. path, DataTab, 1, function( k, v )
		if not IsValid(ply) then return false end
		if not ply:IsAdmin() then return false end
		if isstring(k) then return end

		--Body
		LIBNet.Start("Editor_Request_Playlist")
		net.WriteUInt( 2, 4 )
		StreamRadioLib.NetSendPlaylistEditor(v["url"], v["name"], path)
		net.SendToServer( )
	end, function( k, v )
		if not IsValid(ply) then return false end
		if not ply:IsAdmin() then return false end

		--Finish
		LIBNet.Start("Editor_Request_Playlist")
		net.WriteUInt(3, 4)
		net.WriteUInt(DataTab["format"], 8)
		net.WriteUInt(#DataTab, 16)
		net.WriteString(path)
		net.SendToServer()
	end )

	return true
end

function LIB.Remove(path, format)
	if not path then return false end
	if path == "" then return false end

	local ply = LocalPlayer()

	if not IsValid(ply) then return false end
	if not ply:IsAdmin() then return false end

	LIBNet.Start("Editor_Request_Playlist")
	net.WriteUInt(4, 4)
	net.WriteUInt(format, 8)
	net.WriteString(path)
	net.SendToServer()

	return true
end

function LIB.Copy(path_old, path_new)
	if not path_old then return false end
	if not path_new then return false end

	if path_old == "" then return false end
	if path_new == "" then return false end
	if path_old == path_new then return false end

	local ply = LocalPlayer()
	if not IsValid(ply) then return false end
	if not ply:IsAdmin() then return false end

	LIBNet.Start("Editor_Request_Playlist")
	net.WriteUInt(5, 4)
	net.WriteString(path_old)
	net.WriteString(path_new)
	net.SendToServer()

	return true
end

function LIB.Rename(path_old, path_new)
	if not path_old then return false end
	if not path_new then return false end

	if path_old == "" then return false end
	if path_new == "" then return false end
	if path_old == path_new then return false end

	local ply = LocalPlayer()
	if not IsValid(ply) then return false end
	if not ply:IsAdmin() then return false end

	LIBNet.Start("Editor_Request_Playlist")
	net.WriteUInt(6, 4)
	net.WriteString(path_old)
	net.WriteString(path_new)
	net.SendToServer()

	return true
end

function LIB.SetCallback(func, self, ...)
	if not isfunction(func) then
		CallbackFunc = nil
		CallbackArgs = {}
		CallbackSelf = nil

		return
	end

	CallbackFunc = func
	CallbackArgs = {...}
	CallbackSelf = self
end

LIBNet.Receive("Editor_Return_Files", function( length )
	local path, name, type, filepath = StreamRadioLib.NetReceiveFileEditor( )
	if not isfunction(CallbackFunc) then return end

	if CallbackSelf then
		CallbackFunc( CallbackSelf, "files", path, name, filepath, type, unpack( CallbackArgs or {} ) )
	else
		CallbackFunc( "files", path, name, filepath, type, unpack( CallbackArgs or {} ) )
	end
end)

LIBNet.Receive("Editor_Return_Playlist", function( length )
	local url, name, filepath = StreamRadioLib.NetReceivePlaylistEditor( )
	if not isfunction(CallbackFunc) then return end

	if CallbackSelf then
		CallbackFunc( CallbackSelf, "playlist", url, name, filepath, unpack( CallbackArgs or {} ) )
	else
		CallbackFunc( "playlist", url, name, filepath, unpack( CallbackArgs or {} ) )
	end
end)

LIBNet.Receive("Editor_Error", function( length )
	local path, code = StreamRadioLib.NetReceiveEditorError( )
	if not isfunction(CallbackFunc) then return end

	if CallbackSelf then
		CallbackFunc( CallbackSelf, "error", path, code, unpack( CallbackArgs or {} ) )
	else
		CallbackFunc( "error", path, code, unpack( CallbackArgs or {} ) )
	end
end)

local MainPanel
local EditorPanel

local function CreateMainPanel( )
	if IsValid(MainPanel) then
		MainPanel:Remove()
	end

	if IsValid(EditorPanel) then
		EditorPanel:Remove()
	end

	MainPanel = vgui.Create("DFrame") -- The main frame.
	MainPanel:SetPos(25, 25)

	local W = math.Clamp(ScrW() - 50, 750, 1200)
	local H = math.Clamp(ScrH() - 50, 400, 800)
	MainPanel:SetSize(W, H)

	MainPanel:SetMinWidth(750)
	MainPanel:SetMinHeight(400)
	MainPanel:SetSizable(true)
	MainPanel:SetDeleteOnClose(false)
	MainPanel:SetTitle("Stream Radio Playlist Editor")
	MainPanel:SetVisible(false)
	MainPanel:GetParent():SetWorldClicker(true)

	EditorPanel = vgui.Create("Streamradio_VGUI_PlaylistEditor", MainPanel)
	EditorPanel:DockMargin(5, 5, 5, 5)
	EditorPanel:Dock(FILL)
end

do
	local function ClosePanel( ply, cmd, args )
		if not IsValid(MainPanel) then
			return
		end

		StreamRadioLib.VR.CloseMenu(MainPanel)
	end

	local function OpenPanel( ply, cmd, args )
		if not IsValid(ply) then return end

		if not ply:IsAdmin() then
			StreamRadioLib.Print.Msg(ply, "You must be admin to use the playlist editor.")
			return
		end

		if not IsValid(MainPanel) then
			CreateMainPanel()
		end

		if not IsValid(MainPanel) then
			return
		end

		-- Open via VR lib regardless so we have smoother transitions without possible leftovers
		StreamRadioLib.VR.MenuOpen("StreamradioPlaylistEditor", MainPanel, true)
	end

	concommand.Add("cl_streamradio_playlisteditor", OpenPanel)
	concommand.Add("+cl_streamradio_playlisteditor", OpenPanel)
	concommand.Add("-cl_streamradio_playlisteditor", ClosePanel)
end

return true

