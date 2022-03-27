-- Proximity trigger
function CGM13.Custom:ProximityTrigger(eventName, touchType, ent, pos, height, size, callback, ...)
    if not isfunction(callback) then return end

    if ent.proximityTrigger then
        GM13.Event:RemoveRenderInfoEntity(ent.proximityTrigger)
        ent.proximityTrigger:Remove()
    end

    local args = { ... }

    local function SetVeryNearTriggerPos(proximityTrigger)
        proximityTrigger:Setup(eventName, "proximityTrigger" .. tostring(ent), pos + Vector(size, size, height), pos + Vector(-size, -size, 0))
    end

    local proximityTrigger = ents.Create("gm13_trigger")
    SetVeryNearTriggerPos(proximityTrigger)
    proximityTrigger:SetParent(ent)
    ent.proximityTrigger = proximityTrigger

    proximityTrigger[touchType] = function (self, ent)
        callback(ent, unpack(args))
    end

    local timerName = "cgm13_proximity_trigger_" .. tostring(ent)
    local lastPos
    timer.Create(timerName, 0.2, 0, function()
        if not ent:IsValid() or not proximityTrigger:IsValid() then
            if proximityTrigger:IsValid() then
                GM13.Event:RemoveRenderInfoEntity(proximityTrigger)
                proximityTrigger:Remove()
            end

            timer.Remove(timerName)
            return
        end

        if lastPos ~= pos then
            lastPos = pos
            SetVeryNearTriggerPos(proximityTrigger)
        end
    end)
end

-- Creates portal areas to redirect the player
function CGM13.Custom:CreatePortalSwap(eventName, portalInfo, startTriggersInfo, endTriggersInfo)
    local portals = {}
    local plysInMaxArea = {}
    
    for k, startTriggerInfo in ipairs(startTriggersInfo) do
        local garageSwapTrigger = ents.Create("gm13_trigger")
        garageSwapTrigger:Setup(eventName, eventName .. "SwapTrigger" .. k, startTriggerInfo.vecA, startTriggerInfo.vecB)

        function garageSwapTrigger:StartTouch(ent)
            if table.Count(plysInMaxArea) > 0 then return end
            if #portals > 0 then return end
            if not ent:IsPlayer() then return end

            if math.random(1, 100) <= startTriggerInfo.probability then
                for k, portalPair in ipairs(portalInfo) do
                    local portal1 = ents.Create("cgm13_portal")
                    portal1:SetPos(portalPair[1].pos)
                    portal1:Spawn()
                    portal1:SetAngles(portalPair[1].ang)
                    portal1:SetExitSize(Vector(portalPair[1].sizeX, portalPair[1].sizeY, portalPair[1].sizeZ))
                    --GM13.Ent:BlockPhysgun(portal1, true)
                    table.insert(portals, portal1)
            
                    local portal2 = ents.Create("cgm13_portal")
                    portal2:SetPos(portalPair[1].pos)
                    timer.Simple(1, function()
                        if portal2:IsValid() then
                            portal2:SetPos(portalPair[2].pos) -- Force the portals to connect
                        end
                    end)
                    portal2:Spawn()
                    portal2:SetAngles(portalPair[2].ang)
                    portal2:SetExitSize(Vector(portalPair[2].sizeX, portalPair[2].sizeY, portalPair[2].sizeZ))
                    --GM13.Ent:BlockPhysgun(portal2, true)
                    table.insert(portals, portal2)
            
                    portal1:LinkPortal(portal2)
                    portal1.PORTAL_REMOVE_EXIT = true
                    portal2.PORTAL_REMOVE_EXIT = true
                end
            end
        end
    end

    for k, endTriggerInfo in ipairs(endTriggersInfo) do
        local garageSwapTriggerMaxArea = ents.Create("gm13_trigger")
        garageSwapTriggerMaxArea:Setup(eventName, eventName .. "SwapTriggerMaxArea" .. k, endTriggerInfo.vecA, endTriggerInfo.vecB)

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
    end
end
