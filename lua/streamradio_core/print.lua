local StreamRadioLib = StreamRadioLib
local LIB = StreamRadioLib:NewLib("Print")

local LIBString = StreamRadioLib.String

function LIB.Format(format, ...)
	format = tostring(format or "")

	if format == "" then
		return ""
	end

	if select("#", ...) <= 0 then
		return format
	end

	if not string.find(format, "%%%w") then
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

	msgstring = string.Trim(StreamRadioLib.AddonPrefix .. "\n" .. msgstring) .. "\n"

	local hasVr = StreamRadioLib.VR.IsActive()

	local lines = string.Explode("\n", msgstring, false)
	for i, line in ipairs(lines) do
		if hasVr then
			StreamRadioLib.VR.Debug(line)
		else
			MsgN(line)
		end
	end
end

local g_buffer = nil
local g_bufferLastPlayer = nil

local function printMessageInternal(ply, ...)
	if ply then
		ply:PrintMessage(HUD_PRINTTALK, ...)
	else
		MsgN(...)
	end
end

function LIB.MsgStartBuffer()
	LIB.MsgDumpBuffer()
	g_buffer = {}
end

function LIB.MsgDumpBuffer()
	if not g_buffer then
		return
	end

	local ply = IsValid(ply) and g_bufferLastPlayer or nil

	printMessageInternal(ply, StreamRadioLib.AddonPrefix)

	for i, line in ipairs(g_buffer) do
		printMessageInternal(ply, line)
	end

	g_buffer = nil
	g_bufferLastPlayer = nil
end

function LIB.Msg(ply, format, ...)
	local msgstring = LIB.Format(format, ...)
	msgstring = string.Trim(msgstring)

	if msgstring == "" then return end

	msgstring = LIBString.NormalizeNewlines(msgstring, "\n")
	msgstring = LIBString.IndentTextBlock(msgstring, 1, "  ")

	ply = IsValid(ply) and ply or nil

	if g_buffer then
		g_bufferLastPlayer = ply
	else
		g_bufferLastPlayer = nil
		printMessageInternal(ply, StreamRadioLib.AddonPrefix)
	end

	local lines = string.Explode("\n", msgstring, false)
	for i, line in ipairs(lines) do
		if g_buffer then
			table.insert(g_buffer, line)
		else
			printMessageInternal(ply, line)
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

function LIB.GetRadioEntityString(ent)
	if not IsValid(ent) then
		return tostring(ent or NULL)
	end

	if not ent.__IsRadio then
		return tostring(ent)
	end

	local radioName = string.format(
		"%s [%s]",
		ent.PrintName,
		ent:EntIndex()
	)

	return radioName
end

local g_colorSeparator = Color(255, 255, 255)
local g_colorDateTime = Color(180, 180, 180)
local g_colorAddonName = Color(0, 200, 0)
local g_colorPlayer = Color(200, 200, 0)

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

local g_oldfloat = 0

function LIB.PrintFloatBar( float, len, ... )
	local float = math.Clamp( float, 0, 1 )
	local str = ""

	if float >= g_oldfloat then
		g_oldfloat = float
	end

	local bar = math.Round(float * len)
	local space = len - math.Round(float * len)
	local space1 = math.Round((g_oldfloat - float) * len)

	local space2 = space - space1 - 1
	str = string.rep("#", bar) .. string.rep(" ", space1) .. (math.Round(g_oldfloat * len) < len and "|" or "") .. string.rep(" ", space2)
	MsgC(Color(510 * float, 510 * (1 - float), 0, 255), str, " ", string.format("% 7.2f%%\t", float * 100), ..., "\n")

	if float < g_oldfloat then
		g_oldfloat = g_oldfloat - 0.5 * RealFrameTime()
	end

	return str
end

return true

