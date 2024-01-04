StreamRadioLib.Classes = StreamRadioLib.Classes or {}
table.Empty(StreamRadioLib.Classes)

local LuaClassDirectory = "streamradio_core/classes"

local function normalize_classname(name)
	name = string.lower(name or "")
	name = string.Trim(name)

	name = string.gsub(name, "[%/%\\]", "/" )
	name = string.gsub(name, "%.%.%/", "" )
	name = string.gsub(name, "%.%/", "" )
	name = string.gsub(name, "[%s]", "_" )

	name = string.gsub(name, "^[%w%s%p_%/%\\]*" .. string.PatternSafe(LuaClassDirectory) .. "[%/%\\]*", "", 1 )
	name = string.gsub(name, "%.lua$", "", 1 )

	name = string.Trim(name)

	return name
end

local g_classID = 0
local g_instanceID = 0
local g_classsystemglobal = {}

local function CreateClass( classname, baseClass )
	g_classID = g_classID + 1

	local new_class = {}
	local class_mt = {
		__index = new_class,
	}

	local metamethods = {
		"__add", -- x + y
		"__sub", -- x - y
		"__unm", -- -x
		"__mul", -- x * y
		"__div", -- x / y
		"__mod", -- x % y
		"__pow", -- x ^ y
		"__concat", -- x .. y

		"__eg", -- x == y
		"__lt", -- x < y, x >= y
		"__le", -- x <= y, x > y
		"__len", -- #x

		"__call", -- x()
		"__tostring", -- tostring(x)
		"__gc", -- garbage collection
	}

	function new_class:new(useproxy)
		local newinst = {}

		for k, v in pairs(metamethods) do
			if rawget(class_mt, v) then continue end
			class_mt[v] = self[v]
		end

		setmetatable( newinst, class_mt )

		newinst.ID = g_instanceID
		g_instanceID = g_instanceID + 1

		return newinst
	end

	if nil ~= baseClass then
		setmetatable( new_class, {
			__index = baseClass,
		} )
	end

	new_class.classname = classname
	new_class.classid = g_classID

	function new_class:GetGlobalVar(key, fallback)
		key = tostring(key or "")

		local value = g_classsystemglobal[key]
		if value == nil then
			value = fallback
		end

		return value
	end

	function new_class:SetGlobalVar(key, value)
		key = tostring(key or "")
		g_classsystemglobal[key] = value
		return g_classsystemglobal[key]
	end

	function new_class:GetID()
		return self.ID or 0
	end

	function new_class:GetClassname()
		return self.classname
	end

	function new_class:GetBaseClassname()
		if not baseClass then return end
		return baseClass:GetClassname()
	end

	function new_class:GetClassID()
		return self.classid
	end

	function new_class:GetBaseClassID()
		if not baseClass then return end
		return baseClass:GetClassID()
	end

	-- Return the class object of the instance
	function new_class:GetClass()
		return new_class
	end

	-- Return the super class object of the instance
	function new_class:GetBaseClass()
		return baseClass
	end

	-- Return true if the caller is an instance of theClass
	function new_class:isa( theClass )
		local b_isa = false

		local cur_class = self:GetClass()

		while cur_class ~= nil and not b_isa do
			if cur_class == theClass then
				b_isa = true
			else
				cur_class = cur_class:GetBaseClass()
			end
		end

		return b_isa
	end

	return new_class
end

local function AddClass(name, parentname)
	name = normalize_classname(name)
	parentname = normalize_classname(parentname)

	if name == "" then return false end
	if parentname == "" then
		parentname = "base"
	end

	if StreamRadioLib.Classes[name] then return true end

	local scriptfile = LuaClassDirectory .. "/" .. name .. ".lua"

	if name ~= parentname and not AddClass( parentname ) then
		return false
	end

	local parent = StreamRadioLib.Classes[parentname]
	CLASS = CreateClass(name, parent)

	local loaded = StreamRadioLib.LoadSH(scriptfile, true)

	if not loaded then
		CLASS = nil
		return false
	end

	if not CLASS then
		CLASS = nil
		return false
	end

	StreamRadioLib.Classes[name] = CLASS
	local loadedfunc = CLASS.OnLoaded
	CLASS = nil

	if loadedfunc then
		StreamRadioLib.Timedcall(loadedfunc)
	end

	return true
end

function StreamRadioLib.ReloadClasses()
	table.Empty(StreamRadioLib.Classes)

	AddClass("base")
	AddClass("base_listener", "base")
	AddClass("ui/panel", "base_listener")
	AddClass("ui/debug", "ui/panel")
	AddClass("ui/highlighter", "ui/panel")
	AddClass("skin_controller", "base_listener")
	AddClass("gui_controller", "ui/panel")
	AddClass("ui/round_panel", "ui/panel")
	AddClass("ui/shadow_panel", "ui/panel")
	AddClass("ui/label", "ui/panel")
	AddClass("ui/label_fade", "ui/label")
	AddClass("ui/text", "ui/panel")
	AddClass("ui/image", "ui/panel")
	AddClass("ui/button", "ui/shadow_panel")
	AddClass("ui/scrollbar", "ui/panel")
	AddClass("ui/progressbar", "ui/shadow_panel")
	AddClass("ui/textview", "ui/shadow_panel")
	AddClass("ui/tooltip", "ui/panel")
	AddClass("ui/list", "ui/panel")
	AddClass("ui/list_files", "ui/list")

	AddClass("ui/radio/list_playlists", "ui/list_files")
	AddClass("ui/radio/list_playlistview", "ui/list_files")
	AddClass("ui/radio/gui_main", "ui/shadow_panel")
	AddClass("ui/radio/gui_browser", "ui/panel")
	AddClass("ui/radio/gui_player", "ui/panel")
	AddClass("ui/radio/gui_player_controls.lua", "ui/panel")
	AddClass("ui/radio/gui_player_spectrum.lua", "ui/shadow_panel")
	AddClass("ui/radio/gui_errorbox.lua", "ui/panel")

	AddClass("rendertarget", "base_listener")
	AddClass("stream", "base_listener")
	AddClass("clientconvar", "base_listener")
end

function StreamRadioLib.CreateOBJ(name, ...)
	name = normalize_classname(name)

	local class = StreamRadioLib.Classes[name]
	assert(istable(class), "Class '" .. name .. "' does not exist!")
	assert(class.new, "Bad class table '" .. name .. "' detected!")

	local obj = class:new()
	assert(istable(obj), "Object from class '" .. name .. "' could not be created!")

	if obj.Create then
		obj:Create(...)
	end
	obj.Create = nil

	if not IsValid(obj) then
		return nil
	end

	return obj
end

StreamRadioLib.ReloadClasses()

return true

