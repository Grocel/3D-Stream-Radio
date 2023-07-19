StreamRadioLib.Print = StreamRadioLib.Print or {}
local LIB = StreamRadioLib.Print

local function getTextWithoutColor(text)
	text = tostring(text or "")
	text = string.gsub(text, "%[color%:[ ]?%d+[ %,][ ]?%d+[ %,][ ]?%d+%]", "")

	return text
end

local function printColored(text)
	text = tostring(text or "")

	local default = "[color:255,255,255]"
	local lastcolor = default
	local curcolor = Color(255, 255, 255, 255)

	text = default .. text .. default

	for data, color in string.gmatch(text, "(.-)(%[color%:[ ]?%d+[ %,][ ]?%d+[ %,][ ]?%d+%])") do
		data = data or ""
		color = color or ""

		if color ~= "" then
			local r, g, b = string.match(lastcolor, "%[color%:[ ]?(%d+)[ %,][ ]?(%d+)[ %,][ ]?(%d+)%]")

			if r and g and b then
				r = math.Clamp(tonumber(r) or 0, 0, 255)
				g = math.Clamp(tonumber(g) or 0, 0, 255)
				b = math.Clamp(tonumber(b) or 0, 0, 255)

				curcolor.r = r
				curcolor.g = g
				curcolor.b = b
			end
		end

		if data ~= "" then
			MsgC(curcolor, data)
		end

		lastcolor = color
	end
end

function LIB.IndentText(text, spaces)
	text = tostring(text or "")
	spaces = tonumber(spaces or 2) or 2

	spaces = string.rep(" ", spaces)
	text = string.gsub(spaces .. text, "\n", "\n" .. spaces)

	return text
end

function LIB.Wrapped(texts, ...)
	if not istable(texts) then
		texts = {texts}
	end

	texts = table.Add(texts, {...})

	local textlines = {}

	local longestline = 0

	for k, v in pairs(texts) do
		v = tostring(v or "")

		local lines = string.Explode("\n", v, false)
		textlines[#textlines + 1] = lines

		for i, u in ipairs(lines) do
			local collessu = getTextWithoutColor(u)
			local len = #collessu

			if len <= longestline then
				continue
			end

			longestline = len
		end
	end

	local border_color = SERVER and "[color:137,222,255]" or "[color:255,222,102]"
	local text_color = "[color:255,255,255]"

	local borderside_l = "=== "
	local borderside_r = " ==="

	local border = border_color .. string.rep("=", longestline + #borderside_l + #borderside_r)
	local border_inner = border_color .. string.rep("-", longestline)

	borderside_l = border_color .. "=== "
	borderside_r = border_color .. " ==="

	local function group(lines, addborder)
		if addborder then
			printColored(borderside_l .. border_inner .. borderside_r .. "\n")
		end

		for i, v in ipairs(lines) do
			local collessv = getTextWithoutColor(v)
			local len = #collessv
			local slen = math.Clamp(longestline - len, 0, longestline)
			local spaces = string.rep(" ", slen)

			local line = v .. spaces
			printColored(borderside_l .. text_color .. line .. borderside_r .. "\n")
		end
	end

	printColored(border .. "\n")

	for i, v in ipairs(textlines) do
		group(v, i > 1)
	end

	printColored(border .. "\n")
end

function LIB.Debug(format, ...)
	if not StreamRadioLib.IsDebug() then return end

	format = tostring(format or "")
	if format == "" then return end

	local msgstring = string.format(format, ...)
	msgstring = string.Trim(msgstring)

	if msgstring == "" then return end

	local tmp = string.Explode("\n", msgstring, false)
	for i, v in ipairs(tmp) do
		tmp[i] = "  " .. v .. "\n"
	end

	msgstring = table.concat(tmp)
	msgstring = string.Trim(StreamRadioLib.AddonPrefix .. msgstring) .. "\n"

	if StreamRadioLib.VR.IsActive() then
		StreamRadioLib.VR.Debug(msgstring)
	else
		MsgN(msgstring)
	end
end

function LIB.Msg(ply, msgstring)
	msgstring = tostring(msgstring or "")
	if msgstring == "" then return end

	if IsValid(ply) then
		ply:PrintMessage(HUD_PRINTTALK, msgstring)
	else
		MsgN(msgstring)
	end
end

local g_colorSeparator = Color(255,255,255)
local g_colorDateTime = Color(180,180,180)
local g_colorAddonName = Color(0,200,0)
local g_colorPlayer = Color(200,200,0)

function LIB.Log(ply, msgstring)
	msgstring = tostring(msgstring or "")
	if msgstring == "" then return end

	local playerStr = ""

	if IsValid(ply) then
		playerStr = string.format("%s - %s", tostring(ply), ply:SteamID())
	end

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
