local eventName = "generalTransmissionFlickerLight"

GM13.Event.Memory.Dependency:SetDependent(eventName, "ratmanReady")

local supported = {
    ["gmod_light"] = true,
    ["gmod_lamp"] = true,
}

local function Flicker(light)
    if not light or not IsValid(light) or not supported[light:GetClass()] then return end
    GM13.Light:Blink(light, 2, true)
end

local function SetupFlickerTrigger(evName, entName, veca, vecb, notDetectable, delay, main)
    local t = ents.Create("gm13_trigger")
    t:Setup(evName, entName, veca, vecb, notDetectable)
    if not t or not IsValid(t) then return end
    function t:StartTouch(ent)
        if supported[ent:GetClass()] then

            Flicker(ent)
            timer.Create("cgm13_flickertrigger_" .. tostring(ent), delay, 0, function()
                if not t or not IsValid(t) then timer.Remove("cgm13_flickertrigger_" .. tostring(ent)) return end
                if not main or not IsValid(main) then timer.Remove("cgm13_flickertrigger_" .. tostring(ent)) return end

                Flicker(ent)
            end)

        end
    end

    function t:EndTouch(ent)
        if supported[ent:GetClass()] then

            timer.Remove("cgm13_flickertrigger_" .. tostring(ent))
        end
    end
end

local function GetFlickerTrigger(name)
    local result = nil
    for _,v in pairs(ents.FindByClass("gm13_trigger")) do
        local aName = v:GetVar("entName")
        if string.EndsWith(aName, "_FlickerTrigger") and aName == name then
            result = v
        end
    end
    return result
end

local function CreateEvent() -- Lights will flicker when close to transmission holes

    for _,area in pairs(ents.FindByClass("gm13_trigger")) do
        local areaName = area:GetVar("entName")

        if string.StartWith(areaName, "radio_") then
            local pos = area:GetPos()
            local eName = tostring(area) .. "_FlickerTrigger"
            SetupFlickerTrigger(eventName, eName, pos + Vector(75,65,82), pos + Vector(-50,-62,-100), false, 2.2, area)

            area:CallOnRemove("cgm13_flickertrigger_control", function()
                local trigger = GetFlickerTrigger(eName)
                if IsValid(trigger) then 
                    GM13.Event:RemoveRenderInfoEntity(trigger)
                    trigger:Remove() 
                end
            end)
        end
    end

    return true
end

local function RemoveTimers()
    for _,area in pairs(ents.FindByClass("gm13_trigger")) do
        local areaName = area:GetVar("entName")
        if string.EndsWith(areaName, "_FlickerTrigger") then
            area:Remove()
        end
    end
end

GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetDisableCall(eventName, RemoveTimers)