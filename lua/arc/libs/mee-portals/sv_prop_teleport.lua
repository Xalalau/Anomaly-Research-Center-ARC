-- this is the code that teleports entities like props
-- it only works for things with physics since I dont want to add support to other wacked entities that dont have physics

local allEnts
local portals

timer.Create("cgm13_portals_ent_update", 1, 0, function()
    portals = ents.FindByClass("cgm13_portal")
    allEnts = ents.GetAll()

    for i = #allEnts, 1, -1 do 
        local prop = allEnts[i]
        local removeEnt = false

        if not prop:IsValid() or
           not prop:GetPhysicsObject():IsValid() or
           prop:GetVelocity() == Vector(0, 0, 0) or 
           prop:IsPlayer() or
           prop:GetClass() == "cgm13_portal"
            then

            table.remove(allEnts, i)
        else
            local realPos = prop:GetPos()
            local closestPortalDist = 0
            local closestPortal = nil

            for k, portal in ipairs(portals) do
                if portal:IsValid() then
                    local dist = realPos:DistToSqr(portal:GetPos())

                    if (dist < closestPortalDist or k == 1) and portal:ExitPortal() and portal:ExitPortal():IsValid() then
                        closestPortalDist = dist
                        closestPortal = portal
                    end
                end
            end

            if not closestPortal or
               closestPortalDist > 10000 * closestPortal:GetExitSize()[3] or --over 100 units away from the portal, dont bother checking
               (closestPortal:GetPos() - realPos):Dot(closestPortal:GetUp()) > 0 --behind the portal, dont bother checking
                then

                table.remove(allEnts, i)
            end
        end
    end
end)

local function seamless_check(e)
    return e:GetClass() == "cgm13_portal" -- for traces
end

hook.Add("Tick", "cgm13_portal_teleport", function()
    if not CGM13.Portals or CGM13.Portals.portalIndex < 1 or not allEnts then return end

    for k, prop in ipairs(allEnts) do
        if not prop:IsValid() then
            table.remove(allEnts, k)
        else
            local realPos = prop:GetPos()

            -- can it go through the portal?
            local tr = CGM13.Portals.TraceLine({
                start = realPos - prop:GetVelocity() * 0.02, 
                endpos = realPos + prop:GetVelocity() * 0.02, 
                filter = seamless_check,
            })

            if tr.Hit then
                local hitPortal = tr.Entity

                if hitPortal:GetClass() == "cgm13_portal" and
                   hitPortal:ExitPortal() and
                   hitPortal:ExitPortal():IsValid() and
                   prop:GetVelocity():Dot(hitPortal:GetUp()) < 0 then
                    --local propsToTeleport = prop.Constraints
                    --table.insert(propsToTeleport, prop)

                    --for _, constraintedProp in ipairs(propsToTeleport) do
                        -- rotate velocity, position, and angles
                        local editedPos, editedAng = CGM13.Portals.TransformPortal(hitPortal, hitPortal:ExitPortal(), tr.HitPos, prop:GetVelocity():Angle())

                        --extra angle rotate
                        local newPropAng = prop:GetAngles()
                        newPropAng:RotateAroundAxis(hitPortal:GetForward(), 180)
                        local editedPropAng = hitPortal:ExitPortal():LocalToWorldAngles(hitPortal:WorldToLocalAngles(newPropAng))
                        local max = math.Max(prop:GetVelocity():Length(), hitPortal:ExitPortal():GetUp():Dot(-physenv.GetGravity() / 3))

                        prop:ForcePlayerDrop()
                        if prop:GetPhysicsObject():IsValid() then 
                            prop:GetPhysicsObject():SetVelocity(editedAng:Forward() * max) 
                        end
                        prop:SetAngles(editedPropAng)
                        prop:SetPos(editedPos)
                    --end
                end
            end
        end
    end
end)
