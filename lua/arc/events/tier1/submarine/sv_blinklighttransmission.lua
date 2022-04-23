local eventName = "generalTransmissionFlickerLight"

GM13.Event.Memory.Dependency:SetDependent(eventName, "ratmanReady")

local function CreateEvent()
    timer.Simple(5, function()
        for _, sprite in ipairs(ents.FindByClass("gm13_func_sprite")) do
            if string.find(sprite:GetName(), "wallHole_") then
                local visiblePoint = sprite:GetRight() * 50
                visiblePoint = sprite:GetVar("vecCenter") + visiblePoint

                local timerName = "gm13_wall_hole_light_flicker" .. tostring(sprite)

                timer.Create(timerName, 30, 0, function()
                    if not sprite:IsValid() then
                        timer.Remove(timerName)
                        return
                    end

                    for __, ent in ipairs(ents.FindInSphere(sprite:GetPos(), 1000)) do
                        local supported = {
                            ["env_projectedtexture"] = true,
                            ["gmod_light"] = true,
                            ["gmod_lamp"] = true,
                            ["light_spot"] = true,
                            ["light"] = true,
                            ["classiclight"] = true
                        }

                        if ent:GetClass() and supported[ent:GetClass()] and ent:VisibleVec(visiblePoint) then
                            if math.random(1, 100) <= 15 then
                                local initialState = GM13.Light:IsOn(ent)
                                GM13.Light:Blink(ent, math.random(1, 2), initialState)
                            end
                        end
                    end 
                end)
            end
        end
    end)

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)