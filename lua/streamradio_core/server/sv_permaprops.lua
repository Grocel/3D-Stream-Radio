local function GenericLoad(ent, data)
	local DupeData = data.DupeData or {}

	timer.Simple(0.01, function()
		if not IsValid(ent) then
			return
		end

		if ent.RestoreNetworkVars then
			ent:RestoreNetworkVars(DupeData.DT)
		end

		if ent.OnDuplicated then
			ent:OnDuplicated(DupeData)
		end

		ent.BoneMods  = table.Copy(DupeData.BoneMods)
		ent.EntityMods = table.Copy(DupeData.EntityMods)
		ent.PhysicsObjects = table.Copy(DupeData.PhysicsObjects)

		duplicator.ApplyEntityModifiers(nil, ent)
		duplicator.ApplyBoneModifiers(nil, ent)

		if ent.PostEntityPaste then
			ent:PostEntityPaste(nil, ent, {})
		end
	end)

	return true
end

local function GenericSave(ent)
	return {
		DupeData = duplicator.CopyEntTable(ent)
	}
end

local function AddPermaPropsSupport()
	if not PermaProps then
		return
	end

	if not PermaProps.SpecialENTSSpawn then
		return
	end

	if not PermaProps.SpecialENTSSave then
		return
	end

	PermaProps.SpecialENTSSpawn["sent_streamradio"] = function(ent, data, ...)
		data = data or {}

		if not GenericLoad(ent, data) then
			return false
		end

		return ent:PermaPropLoad(data, ...)
	end

	PermaProps.SpecialENTSSave["sent_streamradio"] = function(ent, ...)
		local dataA = GenericSave(ent) or {}
		local dataB = ent:PermaPropSave(...) or {}

		return {Other = table.Merge(dataA, dataB)}
	end

end

StreamRadioLib.Timer.NextFrame("AddPermaPropsSupport", AddPermaPropsSupport)

return true

