local StreamRadioLib = StreamRadioLib

StreamRadioLib.Model = StreamRadioLib.Model or {}

local LIB = StreamRadioLib.Model
table.Empty(LIB)

local Models = {}

local LuaModelDirectory = "streamradio_core/models"

local function AddCommonFunctions()
	if not RADIOMDL then return end

	RADIOMDL.DISPLAY_POS_TOP = 1;
	RADIOMDL.DISPLAY_POS_RIGHT = 2;
	RADIOMDL.DISPLAY_POS_FRONT = 3;

	function RADIOMDL:GetDisplaySize(vecTL, vecBR, displayPosMode)
		displayPosMode = displayPosMode or self.DISPLAY_POS_FRONT

		local def = vecTL - vecBR

		local x = 0
		local y = 0

		if displayPosMode == self.DISPLAY_POS_TOP then
			x = math.abs(def.y)
			y = math.abs(def.x)
		elseif displayPosMode == self.DISPLAY_POS_RIGHT then
			x = math.abs(def.x)
			y = math.abs(def.z)
		elseif displayPosMode == self.DISPLAY_POS_FRONT then
			x = math.abs(def.y)
			y = math.abs(def.z)
		end

		return x, y
	end

	function RADIOMDL:GetDisplayHeight(vecTL, vecBR, w, displayPosMode)
		local dx, dy = self:GetDisplaySize(vecTL, vecBR, displayPosMode)
		local h = w * (dy / dx)

		return h, dx / w
	end

	function RADIOMDL:GetDisplayWidth(vecTL, vecBR, h, displayPosMode)
		local dx, dy = self:GetDisplaySize(vecTL, vecBR, displayPosMode)
		local w = h * (dx / dy)

		return w, dy / h
	end

	function RADIOMDL:InitializeFonts(ent, model)
		if not CLIENT then return end
		if not self.FontSizes then return end

		self.Fonts = {}

		for name, values in pairs(self.FontSizes) do
			self.Fonts[name] = StreamRadioLib.Surface.AddFont(values[1], values[2], values[3], values[4])
		end
	end
end

local function AddModel(script)
	script = script or ""
	if script == "" then return false end

	-- Special model scripts are handled differently
	if script[1] == "_" then return false end

	local scriptfile = LuaModelDirectory .. "/" .. script

	RADIOMDL = nil
	RADIOMDL = {}

	AddCommonFunctions()

	local loaded = StreamRadioLib.LoadSH(scriptfile, true)

	local modelname = string.lower(string.Trim(RADIOMDL.model or ""))

	if modelname == "" then
		RADIOMDL = nil
		return false
	end

	Models[modelname] = RADIOMDL
	RADIOMDL = nil

	return loaded
end

local function AddMultiModels(script, modellist)
	script = script or ""
	modellist = modellist or {}

	if ( script == "" ) then return false end

	-- Special model scripts are handled here
	if ( script[1] ~= "_" ) then return false end

	local scriptfile = LuaModelDirectory .. "/" .. script

	StreamRadioLib.SaveCSLuaFile(scriptfile, true)

	RADIOMDL = nil
	for _, modelname in ipairs( modellist ) do
		modelname = string.lower( string.Trim( modelname or "" ) )

		if modelname == "" then
			RADIOMDL = nil
			continue
		end

		RADIOMDL = nil
		RADIOMDL = {}
		RADIOMDL.modelname = modelname

		local loaded = StreamRadioLib.LoadSH(scriptfile, true)

		if not loaded then
			RADIOMDL = nil
			continue
		end

		modelname = string.lower( string.Trim( RADIOMDL.modelname or "" ) )
		if modelname == "" then
			RADIOMDL = nil
			continue
		end

		Models[modelname] = RADIOMDL
		RADIOMDL = nil
	end

	return true
end

function LIB.LoadModelSettings()
	local files = file.Find( LuaModelDirectory .. "/*", "LUA" )
	Models = {}

	for _, f in ipairs( files or {} ) do
		AddModel(f)
	end

	local nm_modelpath = "models/nickmaps/speakers"
	local nm_speakers = file.Find( nm_modelpath .. "/*.mdl", "GAME" )

	for index, modelname in ipairs( nm_speakers ) do
		nm_speakers[index] = nm_modelpath .. "/" .. modelname
	end

	AddMultiModels( "_nm_speakers.lua", nm_speakers )

	for index, ent in pairs(StreamRadioLib.SpawnedRadios or {}) do
		if not IsValid(ent) then continue end
		ent:SetUpModel()
	end
end

function LIB.GetModelSettings(model, setting)
	if not model then return end
	local modeldata = Models[model] or Models["default"] or {}
	if not setting then return table.Copy(modeldata) end

	return table.Copy(modeldata[setting] or {})
end

function LIB.RegisteredModels( )
	local ToolModels = {}

	for model, setting in pairs(Models) do
		if model == "default" then continue end
		if not StreamRadioLib.Util.IsValidModelFile(model) then continue end
		if setting.HiddenInTool then continue end

		ToolModels[model] = setting.tool or {}
	end

	return ToolModels
end

LIB.LoadModelSettings( )

return true

