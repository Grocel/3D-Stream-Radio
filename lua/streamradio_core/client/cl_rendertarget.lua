if ( not istable( StreamRadioLib ) ) then return end
StreamRadioLib.Render = {}
local StreamRadioLib = StreamRadioLib

local cam = cam
local surface = surface
local draw = draw
local render = render

local math = math
local string = string
local ents = ents
local util = util
local timer = timer
local SERVER = SERVER
local CLIENT = CLIENT

local Material = Material
local Color = Color
local GetRenderTargetEx = GetRenderTargetEx
local SysTime = SysTime
local IsValid = IsValid
local GetRenderTarget = GetRenderTarget

local RenderSizeX = 1024
local RenderSizeY = 512
local RenderSizeFactor = 0.969
local MatCache = nil
local EntRenderTargets = nil

local function GetRenderTargetMaterial( name )
	if ( not MatCache ) then return end

	if ( not MatCache[name] ) then
		local protoMaterial = Material( name, "nocull" )
		local textureName = protoMaterial:GetString( "$basetexture" )
		local imageName = protoMaterial:GetName( )

		local materialParameters = {
			["$basetexture"] = textureName,
			["$vertexcolor"] = 1,
			["$vertexalpha"] = 1,
			["$nocull"] = 1
		}

		--["$nolod"] = 1,
		MatCache[name] = CreateMaterial( imageName, "UnlitGeneric", materialParameters )
	end

	return MatCache[name]
end

function StreamRadioLib.Render.SetScissorRect( x1, y1, x2, y2, func, ... )
	if ( not func ) then return false end
	render.SetScissorRect( x1 + 16, y1 + 8, x2 + 26, y2 + 18, true )
	func( ... )
	render.SetScissorRect( 0, 0, 0, 0, false )

	return true
end

function StreamRadioLib.Render.CreateRenderTarget( ent )
	if ( not EntRenderTargets ) then return false end

	if ( not IsValid( ent ) ) then
		EntRenderTargets[ent] = nil

		return false
	end

	if ( not StreamRadioLib.IsRenderTarget or not StreamRadioLib.IsRenderTarget( ) ) then
		if ( EntRenderTargets[ent] ) then
			EntRenderTargets[ent] = nil
			EntRenderTargets = {}
			collectgarbage( "collect" )
		end

		return false
	end

	if ( EntRenderTargets[ent] and EntRenderTargets[ent][1] and EntRenderTargets[ent][2] ) then return true end
	EntRenderTargets[ent] = {}
	local name = "radio_rt_" .. tostring( ent ) .. "[" .. ent:GetModel( ) .. "]"
	local tex = GetRenderTarget( name, RenderSizeX, RenderSizeY, false )
	local mat = GetRenderTargetMaterial( name )
	EntRenderTargets[ent][1] = tex
	EntRenderTargets[ent][2] = mat

	if ( not tex or not mat ) then
		EntRenderTargets[ent] = nil
		collectgarbage( "collect" )

		return false
	end

	render.PushRenderTarget( tex )
	render.Clear( 0, 0, 0, 0, true, true )
	render.ClearDepth()
	render.PopRenderTarget( )
	collectgarbage( "collect" )

	return true
end

function StreamRadioLib.Render.Flush( )
	EntRenderTargets = nil
	MatCache = nil
	collectgarbage( "collect" )
	EntRenderTargets = {}
	MatCache = {}
	collectgarbage( "collect" )
end

function StreamRadioLib.Render.ClearRenderTarget( ent )
	if ( not IsValid( ent ) ) then return end
	if ( not EntRenderTargets ) then return end
	if ( not EntRenderTargets[ent] ) then return end
	local tex = EntRenderTargets[ent][1]
	if ( not tex ) then return end
	render.PushRenderTarget( tex )
	render.Clear( 0, 0, 0, 0, true, true )
	render.ClearDepth()
	render.PopRenderTarget( )
end

function StreamRadioLib.Render.UpdateRenderTarget( ent, func, ... )
	if ( not IsValid( ent ) ) then return end
	if ( not EntRenderTargets ) then return end
	if ( not EntRenderTargets[ent] ) then return end
	if ( not func ) then return end
	local tex = EntRenderTargets[ent][1]
	if ( not tex ) then return end
	local oldW, oldH = ScrW( ), ScrH( )
	render.PushRenderTarget( tex )
	render.SetViewPort( 16, 8, 1024, 512 )
	cam.Start2D( )
	func( ent, ... )
	cam.End2D( )
	render.PopRenderTarget( )
	render.SetViewPort( 0, 0, oldW, oldH )
end

function StreamRadioLib.Render.DrawRenderTarget( ent, Pos, Ang, Scale )
	if ( not IsValid( ent ) ) then return end
	if ( not EntRenderTargets ) then return end
	if ( not EntRenderTargets[ent] ) then return end
	local tex = EntRenderTargets[ent][1]
	local mat = EntRenderTargets[ent][2]
	if ( not tex ) then return end
	if ( not mat ) then return end
	local OldTex = mat:GetTexture( "$basetexture" )
	mat:SetTexture( "$basetexture", tex )
	cam.Start3D2D( Pos, Ang, Scale )
	surface.SetDrawColor( 255, 255, 255, ent:GetColor( ).a )
	surface.SetMaterial( mat )
	surface.DrawTexturedRect( 0, 0, RenderSizeX * RenderSizeFactor, RenderSizeY * RenderSizeFactor )
	cam.End3D2D( )
	if ( not OldTex ) then return end
	mat:SetTexture( "$basetexture", OldTex )
end

StreamRadioLib.Render.Flush( )
