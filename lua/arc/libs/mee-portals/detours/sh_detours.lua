-- detours so stuff go through portals

-- bullet detour
hook.Add("EntityFireBullets", "cgm13_portal_detour_bullet", function(entity, data)
    if not CGM13.Portals or CGM13.Portals.portalIndex < 1 then return end

	local tr = CGM13.Portals.TraceLine({start = data.Src, endpos = data.Src + data.Dir * data.Distance, filter = entity})
	local hitPortal = tr.Entity

	if not hitPortal:IsValid() then return end

	if hitPortal:GetClass() == "cgm13_portal" and hitPortal:ExitPortal() then
		if (tr.HitPos - hitPortal:GetPos()):Dot(hitPortal:GetUp()) > 0 then
			local newPos, newAng = CGM13.Portals.TransformPortal(hitPortal, hitPortal:ExitPortal(), tr.HitPos, data.Dir:Angle())

			--ignoreentity doesnt seem to work for some reason
			data.IgnoreEntity = hitPortal:ExitPortal()
			data.Src = newPos
			data.Dir = newAng:Forward()

			return true
		end
	end
end)

-- effect detour (Thanks to WasabiThumb)
local oldUtilEffect = util.Effect
local function effect(name, b, c, d)
     if CGM13.Portals.portalIndex > 0 and (name == "phys_freeze" or name == "phys_unfreeze") then return end
     oldUtilEffect(name, b, c, d)
end
util.Effect = effect

-- super simple traceline detour
CGM13.Portals.TraceLine = CGM13.Portals.TraceLine or util.TraceLine
local function editedTraceLine(data)
	local tr = CGM13.Portals.TraceLine(data)

	if tr.Entity:IsValid() and tr.Entity:GetClass() == "cgm13_portal" and tr.Entity:ExitPortal() and tr.Entity:ExitPortal():IsValid() then
		local hitPortal = tr.Entity

		if tr.HitNormal:Dot(hitPortal:GetUp()) > 0 then
			local editeddata = table.Copy(data)

			editeddata.start = CGM13.Portals.TransformPortal(hitPortal, hitPortal:ExitPortal(), tr.HitPos)
			editeddata.endpos = CGM13.Portals.TransformPortal(hitPortal, hitPortal:ExitPortal(), data.endpos)
			-- filter the exit portal from being hit by the ray

			if IsEntity(data.filter) then
				editeddata.filter = {data.filter, hitPortal:ExitPortal()}
			else
				editeddata.filter = data.filter or {}
				table.insert(editeddata.filter, hitPortal:ExitPortal())
			end

			return CGM13.Portals.TraceLine(editeddata)
		end
	end
	return tr
end

-- use original traceline if there are no portals
timer.Create("cgm13_portals_traceline", 1, 0, function()
	if CGM13.Portals.portalIndex > 0 then
		util.TraceLine = editedTraceLine
	else
		util.TraceLine = CGM13.Portals.TraceLine	-- THE ORIGINAL TRACELINE
	end
end)