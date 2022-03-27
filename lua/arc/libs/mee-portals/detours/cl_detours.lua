-- detours so stuff go through portals

-- sound detour
hook.Add("EntityEmitSound", "cgm13_portals_detour_sound", function(t)
    if not CGM13.Portals or CGM13.Portals.portalIndex < 1 then return end

	for k, v in ipairs(ents.FindByClass("cgm13_portal")) do
        if v.ExitPortal and
		   v:ExitPortal() and
		   v:ExitPortal():IsValid() and
           t.Pos and
		   t.Entity and
		   t.Entity:IsValid()
			then

			if t.Pos:DistToSqr(v:GetPos()) < 50000 * v:ExitPortal():GetExitSize()[1] and (t.Pos - v:GetPos()):Dot(v:GetUp()) > 0 then
				local newPos, _ = CGM13.Portals.TransformPortal(v, v:ExitPortal(), t.Pos, Angle())
				local oldPos = t.Entity:GetPos() or Vector()

				t.Entity:SetPos(newPos)
				EmitSound(t.SoundName, newPos, t.Entity:EntIndex(), t.Channel, t.Volume, t.SoundLevel, t.Flags, t.Pitch, t.DSP)
				t.Entity:SetPos(oldPos)
			end
		end
	end
end)
