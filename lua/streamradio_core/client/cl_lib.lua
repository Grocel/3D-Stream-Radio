
local LIBNet = StreamRadioLib.Net

local g_camPos = nil
local g_inRenderScene = false

StreamRadioLib.Hook.Add( "RenderScene", "CamInfo", function( origin, angles, fov )
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end
	if not StreamRadioLib.HasSpawnedRadios() then return end

	if g_inRenderScene then return end
	g_inRenderScene = true

	if StreamRadioLib.VR.IsActive() then
		g_camPos = nil
		g_inRenderScene = false

		return
	end

	g_camPos = origin
	g_inRenderScene = false
end )

local g_pressed = false
local g_lastradio = nil

local function ReleaseLastRadioControl()
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end
	if not StreamRadioLib.HasSpawnedRadios() then return end

	local ply = LocalPlayer()
	if not IsValid( ply ) then return end
	if not IsValid( g_lastradio ) then return end
	if not g_lastradio.__IsRadio then return end
	if not g_lastradio.Control then return end

	local wasPressed = g_pressed
	g_pressed = false

	if not wasPressed then return end

	local trace = StreamRadioLib.Trace( ply )

	LIBNet.Start("Control")
		net.WriteBool( false )
	net.SendToServer()

	StreamRadioLib.Control( ply, trace, false )
	g_lastradio = nil
end

local function GetPressed(ply)
	if StreamRadioLib.Util.GameIsPaused() then
		return false
	end

	if StreamRadioLib.VR.IsActive(ply) then
		-- Only allow if there is no focus on any menu
		if StreamRadioLib.VR.MenuIsOpen() then
			return false
		end

		-- Check if trigger is pressed
		if StreamRadioLib.VR.GetTriggerPressed() then
			return true
		end

		-- Or check if the player's right hand touches the radio
		if StreamRadioLib.VR.GetRadioTouched() then
			return true
		end

		return false
	end

	if gui.IsGameUIVisible() then
		return false
	end

	local inVehicle = ply.InVehicle and ply:InVehicle()

	local key = StreamRadioLib.GetControlKey()

	if inVehicle then
		key = StreamRadioLib.GetControlKeyVehicle()
	end

	if not key then
		return false
	end

	local pressed = input.IsButtonDown( key )
	return pressed
end

StreamRadioLib.Hook.Add("Think", "Control", function( )
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end
	if not StreamRadioLib.HasSpawnedRadios() then return end

	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local pressed = GetPressed(ply)
	if g_pressed == pressed then return end

	if not pressed then
		ReleaseLastRadioControl()
		g_pressed = pressed
		return
	end
	g_pressed = pressed

	local trace = StreamRadioLib.Trace( ply )
	if not trace then
		ReleaseLastRadioControl()
		return
	end

	local Radio = trace.Entity
	if not IsValid( Radio ) then
		ReleaseLastRadioControl()
		return
	end

	if not Radio.__IsRadio then
		ReleaseLastRadioControl()
		return
	end

	if not Radio.Control then
		ReleaseLastRadioControl()
		return
	end

	if IsValid(g_lastradio) and Radio ~= g_lastradio then
		ReleaseLastRadioControl()
	end

	LIBNet.Start("Control")
		net.WriteBool( pressed )
	net.SendToServer()

	StreamRadioLib.Control( ply, trace, pressed )
	g_lastradio = Radio
end)

function StreamRadioLib.IsCursorEnabled()
	if StreamRadioLib.VR.IsActive() then
		return StreamRadioLib.Settings.GetConVarValue("vr_enable_cursor")
	end

	return StreamRadioLib.Settings.GetConVarValue("enable_cursor")
end

function StreamRadioLib.GetCameraViewPos(ply)
	local islocal = false

	if not IsValid(ply) then
		islocal = true
	end

	if ply == LocalPlayer() then
		islocal = true
	end

	if StreamRadioLib.VR.IsActive(ply) then
		local pos = StreamRadioLib.VR.GetCameraPos(ply)
		return pos
	end

	if not g_camPos or not islocal then
		local pos = StreamRadioLib.GetCameraPos(ply)
		return pos
	end

	return g_camPos
end

function StreamRadioLib.CalcDistanceVolume( distance, max )
	distance = distance or 0
	local threshold = 0.25
	max = math.min(max or 0, StreamRadioLib.GetMuteDistance())
	local min = (max or 0) / 3
	local fullmin = min / 4
	if min <= 0 then return 0 end
	if max <= 0 then return 0 end
	if distance > max then return 0 end
	if distance <= 0 then return 1 end
	if distance <= fullmin then return 1 end
	if distance <= min then return Lerp((distance - fullmin) / (min - fullmin), 1, threshold) end

	return Lerp((distance - min) / (max - min), threshold, 0)
end

return true

