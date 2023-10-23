local StreamRadioLib = StreamRadioLib

StreamRadioLib.Print = StreamRadioLib.Print or {}

local LIB = StreamRadioLib.Print
table.Empty(LIB)

local LIBString = StreamRadioLib.String

function LIB.Format(format, ...)
	format = tostring(format or "")
	if format == "" then return "" end

	local empty = table.IsEmpty({...})
	if empty then
		return format
	end

	local result = string.format(format, ...)
	return result
end

function LIB.Debug(format, ...)
	if not StreamRadioLib.Util.IsDebug() then return end

	local msgstring = LIB.Format(format, ...)
	msgstring = string.Trim(msgstring)

	if msgstring == "" then return end

	msgstring = LIBString.NormalizeNewlines(msgstring, "\n")
	msgstring = LIBString.IndentTextBlock(msgstring, 1, "  ")

	msgstring = string.Trim(StreamRadioLib.AddonPrefix .. msgstring) .. "\n"

	if StreamRadioLib.VR.IsActive() then
		StreamRadioLib.VR.Debug(msgstring)
	else
		MsgN(msgstring)
	end
end

function LIB.Msg(ply, format, ...)
	local msgstring = LIB.Format(format, ...)
	msgstring = string.Trim(msgstring)

	if msgstring == "" then return end

	msgstring = LIBString.NormalizeNewlines(msgstring, "\n")
	msgstring = LIBString.IndentTextBlock(msgstring, 1, "  ")

	msgstring = string.Trim(StreamRadioLib.AddonPrefix .. msgstring) .. "\n"

	local lines = string.Explode("\n", msgstring, false)
	for i, line in ipairs(lines) do
		if IsValid(ply) then
			ply:PrintMessage(HUD_PRINTTALK, line)
		else
			MsgN(line)
		end
	end
end

function LIB.GetPlayerString(ply)
	local playerStr = ""

	if IsValid(ply) then
		playerStr = string.format("%s (%s)", ply:Name(), ply:SteamID())
	end

	return playerStr
end

local g_colorSeparator = Color(255,255,255)
local g_colorDateTime = Color(180,180,180)
local g_colorAddonName = Color(0,200,0)
local g_colorPlayer = Color(200,200,0)

function LIB.Log(ply, format, ...)
	local msgstring = LIB.Format(format, ...)
	msgstring = string.Trim(msgstring)

	if msgstring == "" then return end

	local playerStr = LIB.GetPlayerString(ply)

	local Timestamp = os.time()
	local TimeString = os.date("%Y-%m-%d %H:%M:%S" , Timestamp)

	MsgC(g_colorSeparator, "[")
	MsgC(g_colorDateTime, TimeString)
	MsgC(g_colorSeparator, "]")

	MsgC(g_colorSeparator, "[")
	MsgC(g_colorAddonName, StreamRadioLib.AddonTitle)
	MsgC(g_colorSeparator, "]")

	if playerStr ~= "" then
		MsgC(g_colorSeparator, "[")
		MsgC(g_colorPlayer, playerStr)
		MsgC(g_colorSeparator, "]")
	end

	Msg(" ")

	MsgN(msgstring)
end

return true

