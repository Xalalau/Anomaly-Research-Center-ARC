local eventName = "generalHauntedProps"

local commonMaps = {
    ["gm_supermarket"] = true,
    ["rp_hometown2000"] = true
}

local function ClassInSphere(class, origin, dist)
    local foundEnts = {}

    for k, ent in ipairs(ents.FindInSphere(origin, dist)) do
        if ent:GetClass() == class and not GM13.Ent:IsPlayersProp(ent) then 
            table.insert(foundEnts, ent) 
        end
    end

    return foundEnts
end

local function CreateEvent()
    local totalProps = 0
    for k, ent in ipairs(ents.GetAll()) do
        if ent:GetClass() == "prop_physics" then
            totalProps = totalProps + 1
        end
    end

    local chance = commonMaps[game.GetMap()] and 5 or
                   totalProps > 200 and 3   or totalProps > 100 and 2   or 1
    local delay =  totalProps > 200 and 60 or totalProps > 100 and 300 or 400

    timer.Create("gm13_haunted_prop_control", delay, 0, function()
        if totalProps == 0 then 
            timer.Remove("gm13_haunted_prop_control")
            return
        end

        if math.random(1, 100) <= chance then
            for k, ply in ipairs(player.GetHumans()) do
                local props = ClassInSphere("prop_physics", ply:GetPos(), 3000)
                local mode = math.random(1, 3)

                if #props == 0 then return end

                local selectedPropIndex = math.random(#props)
                local selectedProp = props[selectedPropIndex]
                if IsValid(selectedProp) then
                    if mode == 1 then
                        -- Drop Props

                        local obj = selectedProp:GetPhysicsObject() or selectedProp

                        local originalMass = obj:GetMass()
                        local force = selectedProp:GetForward() * 800
                        force:Rotate(Angle(math.random(-35, 35), math.random(0, 360), 0))
                    
                        obj:SetMass(5)
                        obj:ApplyForceCenter(force)
                        obj:SetMass(originalMass)
                    elseif mode == 2 then
                        -- Scale Props

                        local rChance = math.random(1, 2)
                        local scale = (rChance == 1 and 1.3) or 0.70
                        GM13.Ent:Resize(selectedProp, scale)
                    elseif mode == 3 then
                        -- Swap Props

                        props[selectedPropIndex] = nil
                        local secondProp = props[math.random(#props)]
                        local secondPropPos = secondProp:GetPos()

                        secondProp:SetPos(selectedProp:GetPos())
                        selectedProp:SetPos(secondPropPos)
                    end
                end
            end
        end
    end)

    return true
end

local function RemoveEvent()
    timer.Remove("gm13_haunted_prop_control")
end

GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)
