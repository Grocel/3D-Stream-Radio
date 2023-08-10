local StreamRadioLib = StreamRadioLib

StreamRadioLib.Tool = StreamRadioLib.Tool or {}
local LIB = StreamRadioLib.Tool

local LIBNetwork = StreamRadioLib.Network
local LIBNet = StreamRadioLib.Net

function LIB.GetTool(ply)
	if not IsValid(ply) then
		if SERVER then return end
		ply = LocalPlayer()
	end

	if not IsValid(ply) then return end

	local tool = ply:GetWeapon("gmod_tool")
	if not IsValid(tool) then return end

	if not tool.GetToolObject then return end
	if not tool.GetMode then return end

	local toolobj = tool:GetToolObject()
	if not toolobj then return end
	if toolobj.Mode ~= tool:GetMode() then return end

	return toolobj, tool
end

local g_locale_specialcases = {
	["Undone_"] = true,
	["SBoxLimit_"] = true,
	["Cleanup_"] = true,
	["Cleaned_"] = true,
}

function LIB.AddLocale(toolobj, name, translation)
	if SERVER then return end
	assert(toolobj, "ToolOBJ needed #1")

	name = tostring(name or "")
	assert(name ~= "", "name needed #2")

	translation = tostring(translation or "")
	assert(translation ~= "", "translation needed #3")

	local toolmode = toolobj.Mode

	if g_locale_specialcases[name] then
		language.Add(name .. toolmode, translation)
		return
	end

	language.Add("Tool." .. toolmode .. "." .. name, translation)
end

function LIB.GetLocale(toolobj, name)
	if SERVER then return end
	assert(toolobj, "ToolOBJ needed #1")

	name = tostring(name or "")
	assert(name ~= "", "name needed #2")

	local toolmode = toolobj.Mode
	return "#Tool." .. toolmode .. "." .. name
end

function LIB.GetLocaleTranslation(toolobj, name)
	if SERVER then return end
	assert(toolobj, "ToolOBJ needed #1")

	name = tostring(name or "")
	assert(name ~= "", "name needed #2")

	local toolmode = toolobj.Mode
	return language.GetPhrase("#Tool." .. toolmode .. "." .. name)
end

function LIB.AdvWeld( ent, traceEntity, tracePhysicsBone, DOR, collision, AllowWorldWeld, freeze )
	if not SERVER then return end
	if not IsValid(ent) then return end

	if IsValid(traceEntity) then
		if traceEntity:IsNPC() then return end
		if traceEntity:IsPlayer() then return end
	end

	local IsEnt = IsValid(traceEntity) and not traceEntity:IsWorld()
	local phys = ent:GetPhysicsObject()

	if AllowWorldWeld or IsEnt then
		local const = constraint.Weld(ent, traceEntity, 0, tracePhysicsBone, 0, not collision, DOR)

		-- Don't disable collision if it's not attached to anything
		if (not collision and IsValid(const)) then
			if IsValid( phys ) then
				phys:EnableCollisions(collision)
			end

			ent.nocollide = not collision
		end

		if IsValid(phys) then
			phys:EnableMotion(not (freeze or AllowWorldWeld and not IsEnt))
		end

		return const
	else
		if IsValid(phys) then
			phys:EnableMotion(not (freeze or AllowWorldWeld))
		end

		return nil
	end
end

LIB.g_reloadpanels = LIB.g_reloadpanels or {}
local g_reloadpanels = LIB.g_reloadpanels

function LIB.Setup(toolobj)
	local _toolmode = toolobj.Mode

	toolobj.ToolLibLoaded = true

	function toolobj:IsValidTrace(trace)
		if not trace then return false end
		if not trace.Hit then return false end
		if not trace.HitPos then return false end

		local ent = trace.Entity
		if IsValid(ent) then
			if ent:IsPlayer() then return false end

			if SERVER then
				if not util.IsValidPhysicsObject(ent, trace.PhysicsBone) then return false end
			end
		end

		return true
	end

	function toolobj:IsValidRadio(ent)
		if not IsValid(ent) then return false end
		if not ent.__IsRadio then return false end

		local ply = self:GetOwner()
		if not IsValid(ply) then return true end

		local radioOwner = ent:GetRealRadioOwner()

		if not IsValid(radioOwner) then return true end
		if radioOwner ~= ply then return false end

		return true
	end

	function toolobj:IsValidGUIRadio(ent)
		if not self:IsValidRadio(ent) then return false end
		if not ent.HasGUI then return false end
		if not ent:HasGUI() then return false end

		return true
	end

	function toolobj:GetFallbackTrace()
		local ply = self:GetOwner()
		local trace = util.GetPlayerTrace(ply)
		trace.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )

		local result = util.TraceLine(trace)
		if not self:IsValidTrace(result) then return nil end

		return result
	end

	function toolobj:SetClientInfo( name, var )
		local ply = self:GetOwner()

		if not IsValid(ply) then
			if CLIENT then
				ply = LocalPlayer()
			end
		end

		if not IsValid(ply) then
			return
		end

		var = tostring(var)
		var = string.Replace(var, '"', "")

		ply:ConCommand(self.Mode .. "_" .. name .. ' "' .. var .. '"')
	end

	function toolobj:SetClientNumber(name, var)
		self:SetClientInfo(name, tonumber(var) or 0)
	end

	function toolobj:SetClientBool(name, var)
		self:SetClientNumber(name, tobool(var) and 1 or 0)
	end

	function toolobj:GetClientNumberMinMax(name, min, max)
		local var = self:GetClientNumber(name)
		var = math.Clamp(var, min, max)

		return var
	end

	function toolobj:GetClientBool(name)
		local var = self:GetClientNumber(name)
		return tobool(var)
	end

	if SERVER then return end

	function toolobj:AddLabel( panel, name, descbool )
		local label = vgui.Create( "DLabel" )
		panel:AddPanel( label )

		label:SetText(StreamRadioLib.Tool.GetLocale(self, name))
		label:SetDark( true )
		label:SizeToContents( )

		if descbool then
			label:SetTooltip(StreamRadioLib.Tool.GetLocale(self, name .. ".desc"))
		end

		return label
	end

	function toolobj:AddReadOnlyText( panel, name, descbool )
		local label = vgui.Create( "Streamradio_VGUI_ReadOnlyTextEntry" )
		panel:AddPanel( label )

		label:SetText(StreamRadioLib.Tool.GetLocale(self, name))

		if descbool then
			label:SetTooltip(StreamRadioLib.Tool.GetLocale(self, name .. ".desc"))
		end

		label:DockMargin(0, 0, 0, 0)
		label:DockPadding(0, 0, 0, 0)

		return label
	end

	function toolobj:AddCustomURLBlockedLabel( panel, name, descbool )
		local label = StreamRadioLib.Menu.GetCustomURLBlockedLabel(StreamRadioLib.Tool.GetLocale(self, name))
		panel:AddPanel( label )

		if descbool then
			label:SetTooltip(StreamRadioLib.Tool.GetLocale(self, name .. ".desc"))
		end

		return label
	end

	function toolobj:AddButton( panel, name, descbool )
		local button = vgui.Create( "DButton" )
		panel:AddPanel( button )
		button:SetText(StreamRadioLib.Tool.GetLocale(self, name))
		button:SetDark( true )
		button:SizeToContents( )

		if descbool then
			button:SetTooltip(StreamRadioLib.Tool.GetLocale(self, name .. ".desc"))
		end

		return button
	end

	function toolobj:AddColorMixer( panel )
		local ColorMixer = vgui.Create( "DColorMixer" )
		panel:AddPanel( ColorMixer )

		ColorMixer:SetPalette( true )
		ColorMixer:SetAlphaBar( true )
		ColorMixer:SetPaintBackground( true )

		return ColorMixer
	end


	function toolobj:AddNumSlider( panel, command, descbool )
		local numslider = vgui.Create( "DNumSlider" )
		panel:AddPanel( numslider )

		numslider:SetText(StreamRadioLib.Tool.GetLocale(self, command), self.Mode .. "_" .. command)
		numslider:SetDark(true)
		numslider:SetConVar(self.Mode .. "_" .. command)

		if descbool then
			numslider:SetTooltip(StreamRadioLib.Tool.GetLocale(self, command .. ".desc"))
		end

		return numslider
	end

	function toolobj:AddCheckbox( panel, command, descbool )
		local checkbox = panel:CheckBox(StreamRadioLib.Tool.GetLocale(self, command), self.Mode .. "_" .. command)

		if descbool then
			checkbox:SetTooltip(StreamRadioLib.Tool.GetLocale(self, command .. ".desc"))
		end

		return checkbox
	end

	function toolobj:AddComboBox( panel, command, descbool )
		local combobox, label = panel:ComboBox(StreamRadioLib.Tool.GetLocale(self, command), self.Mode .. "_" .. command)

		StreamRadioLib.Menu.PatchComboBox(combobox, label)

		if descbool then
			combobox:SetTooltip(StreamRadioLib.Tool.GetLocale(self, command .. ".desc"))
		end

		return combobox
	end

	function toolobj:AddTextEntry( panel, command, descbool )
		local textentry = panel:TextEntry(StreamRadioLib.Tool.GetLocale(self, command), self.Mode .. "_" .. command)

		if descbool then
			textentry:SetTooltip(StreamRadioLib.Tool.GetLocale(self, command .. ".desc"))
		end

		return textentry
	end

	function toolobj:AddURLTextEntry( panel, command, descbool )
		local bgpanel = vgui.Create( "DPanel" )
		bgpanel:SetPaintBackground( false )

		if descbool then
			bgpanel:SetTooltip(StreamRadioLib.Tool.GetLocale(self, command .. ".desc"))
		end

		panel:AddPanel( bgpanel )

		local label = vgui.Create( "DLabel", bgpanel )
		label:SetText(StreamRadioLib.Tool.GetLocale(self, command))
		label:SetDark( true )
		label:SizeToContents( )
		label:Dock( LEFT )

		local URLTextEntry = vgui.Create( "Streamradio_VGUI_URLTextEntry", bgpanel )
		URLTextEntry:SetConVar( self.Mode .. "_" .. command )
		URLTextEntry:Dock( FILL )
		URLTextEntry:DockMargin( 5, 2, 0, 2 )

		return URLTextEntry
	end

	function toolobj:BuildToolPanel(CPanel)
		-- override this
	end

	function toolobj.BuildCPanel(CPanel)
		g_reloadpanels[_toolmode] = CPanel

		local toplabel = vgui.Create("DLabel")
		toplabel:SetText("#Tool." .. _toolmode .. ".desc")
		toplabel:SetDark(true)
		toplabel:SizeToContents()
		CPanel:AddPanel(toplabel)

		local StreamRadioLib = StreamRadioLib or {}

		if not StreamRadioLib.Loaded then
			if StreamRadioLib.Loader_CreateErrorPanel then
				StreamRadioLib.Loader_CreateErrorPanel(CPanel, "This tool could not be loaded.")
			end

			return
		end

		StreamRadioLib.Timer.Until("ToolReload_" .. _toolmode, 0.1, function()
			local this = LIB.GetTool()
			if not this then return end
			if this.Mode ~= _toolmode then return end

			local CPanel = g_reloadpanels[_toolmode]
			if not IsValid(CPanel) then return end

			if not this.BuildToolPanel then return end

			CPanel._toolobj = this
			this.ToolPanel = CPanel

			local toolpresets = this.Presets or {}
			local Options = toolpresets.Options or StreamRadioLib.GetPresetsTable(_toolmode) or {}
			local CVars = toolpresets.CVars or {}

			if #CVars <= 0 then
				for k,v in pairs(this.ClientConVar or {}) do
					table.insert(CVars, this.Mode .. "_" .. k)
				end
			end

			if not Options.Default then
				Options.Default = {}

				for k, v in pairs(this.ClientConVar or {}) do
					Options.Default[this.Mode .. "_" .. k] = tostring(v)
				end
			end

			if #CVars > 0 then
				CPanel:AddControl("ComboBox", {
					Label = "#Presets",
					MenuButton = "1",
					Folder = this.Mode,
					Options = Options,
					CVars = CVars,
				})
			end

			this:BuildToolPanel(CPanel)

			CPanel:AddPanel(StreamRadioLib.Menu.GetSpacer(5))
			CPanel:AddPanel(StreamRadioLib.Menu.GetFAQButton())
			CPanel:AddPanel(StreamRadioLib.Menu.GetCreditsPanel())

			return true
		end)
	end

	function toolobj:GetPanel()
		return self.ToolPanel
	end

	function toolobj:ReloadPanel()
		local reloadpanel = g_reloadpanels[_toolmode]

		if not IsValid(reloadpanel) then
			reloadpanel = self:GetPanel()
		end

		if not IsValid(reloadpanel) then
			return
		end

		reloadpanel:Clear()
		self.BuildCPanel(reloadpanel)
	end

	toolobj:ReloadPanel()
end

local callback = nil

function LIB.RegisterClientToolHook(tool, toolhook)
	if SERVER then
		LIBNetwork.AddNetworkString("ClientToolHook")
		return
	end

	if callback then return end

	callback = function()
		local ply = LocalPlayer()

		local nwtoolname = net.ReadString()
		local bwhook = net.ReadString()

		local tool = ply:GetWeapon("gmod_tool")

		if not IsValid(tool) then return end
		if tool:GetMode() ~= nwtoolname then return end

		local toolobj = tool:GetToolObject()

		if not toolobj then return end
		if toolobj.Mode ~= nwtoolname then return end

		local func = toolobj[bwhook .. "Client"]
		if not func then return end

		func(toolobj)
	end

	LIBNet.Receive("ClientToolHook", callback)
end

function LIB.CallClientToolHook(tool, toolhook)
	if CLIENT then return end

	local owner = tool:GetOwner()
	local toolname = tool.Mode

	LIBNet.Start("ClientToolHook")
		net.WriteString(toolname)
		net.WriteString(toolhook)
	net.Send(owner)
end
