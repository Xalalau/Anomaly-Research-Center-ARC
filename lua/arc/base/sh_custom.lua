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