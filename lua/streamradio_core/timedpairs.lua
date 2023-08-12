-- Timedpairs by Grocel. (Rewrite by Divran)
-- It allows you to go through long tables, but without game freezing.
-- Its like a for-pairs loop.
--
-- How to use:
-- StreamRadioLib.Timedpairs( string unique name, table, number ticks done at once, function tickcallback[, function endcallback, ...] )
--
-- tickcallback is called every tick, it ticks for each KeyValue of the table.
-- Its arguments are the current key and value.
-- Return false in the tickcallback function to break the loop.
-- tickcallback( key, value, ... )
--
-- endcallback is called after the last tickcallback has been called.
-- Its arguments are the same as the last arguments of StreamRadioLib.Timedpairs
-- endcallback( lastkey, lastvalue, ... )
if ( not StreamRadioLib ) then return end
local next = next
local pairs = pairs
local unpack = unpack
local pcall = pcall
local ErrorNoHalt = ErrorNoHalt
local functions = {}

function StreamRadioLib.TimedpairsGetTable( )
	return functions
end

function StreamRadioLib.TimedpairsStop( name )
	local data = functions[name]

	if data then
		local lookup = data.lookup or {}

		-- If we had any end callback function
		if data.endcallback then
			local kv = lookup[data.currentindex - 1] or {} -- get previous key & value
			local ok, err = pcall( data.endcallback, kv.key, kv.value, unpack( data.args ) )

			if not ok then
				ErrorNoHalt( "Error in Timedpairs '" .. name .. "' ( in end function ): " .. err .. "\n" )
			end
		end
	end

	functions[name] = nil
end

-- custom table copy function to convert to numerically indexed table
local function copy( t )
	local ret = {}

	for k, v in pairs( t ) do
		table.insert(ret, {
			key = k,
			value = v
		})
	end

	return ret
end

local function Timedpairs( )
	if not StreamRadioLib then return end
	if not StreamRadioLib.Loaded then return end

	if not next( functions ) then return end
	local toremove = {}

	-- If there are any more values..
	for name, data in pairs( functions ) do
		for i = 1, data.step do
			data.currentindex = data.currentindex + 1 -- increment index counter
			local lookup = data.lookup or {}

			if data.currentindex <= #lookup then
				local kv = lookup[data.currentindex] or {} -- Get the current key and value
				local ok, err = pcall( data.callback, kv.key, kv.value, unpack( data.args ) ) -- DO EET

				if not ok then
					ErrorNoHalt( "Error in Timedpairs '" .. name .. "': " .. err .. "\n" )
					table.insert(toremove, name)
					break
				elseif err == false then
					-- They returned false inside the function
					if data.endcallback then
						local kv = lookup[data.currentindex - 1] or {} -- get previous key & value
						local ok, err = pcall( data.endcallback, kv.key, kv.value, unpack( data.args ) )

						if not ok then
							ErrorNoHalt( "Error in Timedpairs '" .. name .. "' ( in end function ): " .. err .. "\n" )
						end
					end

					-- If we had any end callback function
					table.insert(toremove, name)
					break
				end
			else
				-- oh noes
				-- Out of keys. Entire table looped
				if data.endcallback then
					local kv = lookup[data.currentindex - 1] or {} -- get previous key & value
					local ok, err = pcall( data.endcallback, kv.key, kv.value, unpack( data.args ) )

					if not ok then
						ErrorNoHalt( "Error in Timedpairs '" .. name .. "' ( in end function ): " .. err .. "\n" )
					end
				end

				-- If we had any end callback function
				table.insert(toremove, name)
				break
			end
		end
	end

	-- Remove all that were flagged for removal
	for i = 1, #toremove do
		functions[toremove[i]] = nil
	end
end

if ( CLIENT ) then
	StreamRadioLib.Hook.Add( "PostRenderVGUI", "Timedpairs", Timedpairs ) -- Doesn't get paused in single player. Can be important for vguis.
else
	StreamRadioLib.Hook.Add( "Think", "Timedpairs", Timedpairs ) -- Servers still uses Think.
end

function StreamRadioLib.Timedpairs( name, tab, step, callback, endcallback, ... )
	functions[name] = {
		lookup = copy( tab ),
		step = step,
		currentindex = 0,
		callback = callback,
		endcallback = endcallback,
		args = {...}
	}
end

local g_dummytab = {true}
local g_id = 0

-- calls the given function like simple timer, but isn't affected by game pausing.
function StreamRadioLib.Timedcall( callback, ... )
	g_id = (g_id % 2 ^ 30) + 1

	StreamRadioLib.Timedpairs( "Timedcall_" .. g_id, g_dummytab, 1, function( k, v, ... )
		callback( ... )
	end, nil, ... )
end

return true

