local eventName = "garageCorridorSwap"

local function CreateEvent()
    local portalInfo = {
        {
            {
                pos = Vector(-1626.14, -2488.33, -193.05),
                ang = Angle(90, 0, 180),
                sizeX = 1.32,
                sizeY = 1.5,
                sizeZ = 1
            },
            {
                pos = Vector(-2514.47, -2488.33, -193.031),
                ang = Angle(90, 0, 180),
                sizeX = 1.32,
                sizeY = 1.5,
                sizeZ = 1
            },
        },
        {
            {
                pos = Vector(-2509.44, -2488.33, -193.031),
                ang = Angle(90, 180, 180),
                sizeX = 1.32,
                sizeY = 1.5,
                sizeZ = 1
            },
            {
                pos = Vector(-1607.45, -2488.33, -193.031),
                ang = Angle(90, 180, 180),
                sizeX = 1.32,
                sizeY = 1.5,
                sizeZ = 1
            },
        }
    }

    local portals = {}
    local plysInMaxArea = {}
    
    local garageSwapTrigger = ents.Create("gm13_trigger")
	garageSwapTrigger:Setup(eventName, "garageSwapTrigger", Vector(-2135.97, -2104.07, -42.68), Vector(-1992.38, -2123.54, -143.97))

    function garageSwapTrigger:StartTouch(ent)
        if table.Count(plysInMaxArea) > 0 then return end
        if #portals > 0 then return end
        if not ent:IsPlayer() then return end

        for k, portalPair in ipairs(portalInfo) do
            local portal1 = ents.Create("cgm13_portal")
            portal1:SetPos(portalPair[1].pos)
            portal1:Spawn()
            portal1:SetAngles(portalPair[1].ang)
            portal1:SetExitSize(Vector(portalPair[1].sizeX, portalPair[1].sizeY, portalPair[1].sizeZ))
            GM13.Ent:BlockPhysgun(portal1, true)
            table.insert(portals, portal1)
    
            local portal2 = ents.Create("cgm13_portal")
            portal2:SetPos(portalPair[2].pos)
            portal2:Spawn()
            portal2:SetAngles(portalPair[2].ang)
            portal2:SetExitSize(Vector(portalPair[2].sizeX, portalPair[2].sizeY, portalPair[2].sizeZ))
            GM13.Ent:BlockPhysgun(portal2, true)
            table.insert(portals, portal2)
    
            portal1:LinkPortal(portal2)
            portal1.PORTAL_REMOVE_EXIT = true
            portal2.PORTAL_REMOVE_EXIT = true
        end
	end

    local garageSwapTriggerMaxArea = ents.Create("gm13_trigger")
	garageSwapTriggerMaxArea:Setup(eventName, "garageSwapTriggerMaxArea", Vector(-2521.72, -2558.23, -255.97), Vector(-1606.66, -2133.27, -34.27))

    function garageSwapTriggerMaxArea:SartTouch()
        if ent:IsPlayer() then
            plysInMaxArea[ent] = nil
        end
    end

    function garageSwapTriggerMaxArea:EndTouch(ent)
        if not ent:IsPlayer() then return end

        plysInMaxArea[ent] = nil

        if table.Count(plysInMaxArea) == 0 and #portals > 0 then
            for k, portal in ipairs(portals) do
                if portal:IsValid() then
                    portal:Remove()
                end
            end

            portals = {}
        end
	end

	return true
end

GM13.Event:SetCall(eventName, CreateEvent)
