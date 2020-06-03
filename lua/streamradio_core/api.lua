/*
    The developer API for the use in external addons or in non-sandbox gamemodes.
    Make sure you check for StreamRadioLib.Loaded == true before using this API.

    Functions:
        bool StreamRadioLib.EditRadio( Entity Radio [, table settings] )
        -- Set the Radio settings to the given settings. Returns true on success.

        Entity StreamRadioLib.SpawnRadio( [Player player [, string model [, Vector pos [, Angle ang [, table settings]]]]] )
        -- Spawns a Radio and makes the given player to the owner for the tool and CPPI. It will have the given model and will be spawned at pos and ang.
        -- The settings table will set the radio's settings. The radio entity is returned on success.

        bool StreamRadioLib.IsValidRadioSettings( any settings )
        -- Checks settings for being a valid settings table. Returns true if it is.

    The settings table:
        This following list describes the layout of the settings table.
        Each element is optional, but have to be fed with the right datatype when they are in use.

        Index:                  Type:       Default:        Description:

        StreamUrl               String      ""              The streaming source URL.
        StreamName              String      ""              Name of the stream.

        StreamVolume            number      1               0 is muted and 1 is 100% volume
        Radius                  number      1200            Number in units of the sound range
        StreamLoop              boolean     false           True enables stream looping
        PlaylistLoop            boolean     true            True enables playlist looping
        Sound3D                 boolean     true            True enables the 3D world sound
        DisableInput            boolean     false           True disables the radio controlling. Does not affect Wiremod controlling.
        DisableDisplay          boolean     false           True disables the radio display.
        DisableAdvancedOutputs  boolean     true            True disables the Advanced Wire Outputs.
*/

// ======================================================================
// === Don't edit anything below, unless you know what you are doing. ===
// === Really, you don't need to. Report it to me if you find a bug.  ===
// ======================================================================

local ValidTypes = {
	StreamName = "string",
	StreamUrl = "string",

	StreamVolume = "number",
	Radius = "number",
	StreamLoop = "boolean",
	PlaylistLoop = "boolean",
	Sound3D = "boolean",
	DisableInput = "boolean",
	DisableDisplay = "boolean",
	DisableAdvancedOutputs = "boolean",
}

function StreamRadioLib.IsValidRadioSettings( settings )
	if ( not settings ) then return true end
	if TypeID( settings ) ~= TYPE_TABLE then return false end

	for k, v in pairs( settings ) do
		if ValidTypes[k] and type( v ) ~= ValidTypes[k] then return false end
	end

	return true
end

local function ErrorCheckArg( var, tright, argn, funcname, level )
	if ( var == nil ) then return true end
	local t = type( var )

	if t ~= tright then
		error( string.format( "bad argument #%i to '%s' (%s or nil expected, got %s)", argn, funcname, tright, t ), level or 3 )

		return false
	end

	return true
end

local function ErrorCheckRadioSettings( settings, argn, funcname, level )
	level = level or 3
	if not ErrorCheckArg( settings, "table", argn, funcname, level + 1 ) then return false end

	for k, v in pairs( settings ) do
		local t = type( v )
		local tright = ValidTypes[k]
		if not tright or t == tright then continue end
		error( string.format( "bad datatype at index '%s' of argument #%i at '%s' (%s or nil expected, got %s)", k, argn, funcname, tright, t ), level )

		return false
	end

	return true
end

function StreamRadioLib.EditRadio( ent, settings )
	if not StreamRadioLib.Loaded then return false end

	if not SERVER then return false end
	if not ErrorCheckArg( ent, "Entity", 1, "EditRadio", 3 ) then return false end
	if not IsValid( ent ) then return false end
	if not ent.__IsRadio then return false end

	settings = settings or {}
	if not ErrorCheckRadioSettings( settings, 2, "EditRadio", 3 ) then return false end

	local StreamName = settings.StreamName or ""
	local StreamUrl = settings.StreamUrl or ""

	if StreamName == "" then
		StreamName = StreamUrl
	end

	if StreamUrl == "" then
		StreamUrl = StreamName
	end

	settings.Sound3D = settings.Sound3D

	if ent.SetSettings then
		ent:SetSettings(settings)
	end

	return true
end

local Ang_Zero = Angle( )
local Vec_Zero = Vector( )

function StreamRadioLib.SpawnRadio( ply, model, pos, ang, settings )
	if not SERVER then return end

	if not StreamRadioLib.Loaded then
		local Addonname = StreamRadioLib.Addonname or ""
		local ErrorString = StreamRadioLib.ErrorString or ""
		local Prefix = ( Addonname .. ErrorString )

		if ErrorString ~= "" then
			Prefix = Prefix .. "\n\n"
		end

		local err = Prefix .. "The Entity 'sent_streamradio' could not be spawned."

		if StreamRadioLib.Msg then
			StreamRadioLib.Msg( ply, err )
		else
			error( err, 2 )
		end

		return
	end

	local ent = ents.Create( "sent_streamradio" )
	if not IsValid(ent) then return end

	if not IsValid(ply) or ply:IsWorld() then
		ply = nil
	end

	if not ErrorCheckArg(ply, "Player", 1, "SpawnRadio", 3) then return end

	if not ErrorCheckArg(model, "string", 2, "SpawnRadio", 3) then return end
	if not ErrorCheckArg(pos, "Vector", 3, "SpawnRadio", 3) then return end
	if not ErrorCheckArg(ang, "Angle", 4, "SpawnRadio", 3) then return end

	settings = settings or {}
	if not ErrorCheckRadioSettings(settings, 5, "SpawnRadio", 3) then return end

	ent:SetPos(pos or Vec_Zero)
	ent:SetAngles(ang or Ang_Zero)
	ent.ModelVar = model
	ent:Spawn()
	ent:Activate()

	local data = {}
	data.pl = ply
	data.Owner = ply

	if isfunction(ent.CPPISetOwner) then
		ent:CPPISetOwner(ply)
	end

	for k, v in pairs(data) do
		ent[k] = v
	end

	if not StreamRadioLib.EditRadio(ent, settings) then return end
	ent:PhysWake()

	timer.Simple(0.05, function()
		if not IsValid(ent) then return end
		if not ent._3dstreamradio_classobjs_data then return end
		if not ent.PostClasssystemPaste then return end

		ent:PostClasssystemPaste()
	end)

	return ent
end
