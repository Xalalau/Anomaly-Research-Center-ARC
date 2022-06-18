local eventName = "generalResearchTraces"

local function CreateProp(model, pos, ang)
    local prop = ents.Create("prop_physics")

    prop:SetModel(model)
    prop:SetPos(pos)
    prop:SetAngles(ang)
    prop:Spawn()
    
    GM13.Event:SetGameEntity(eventName, prop)

    local phys = prop:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    return prop
end

local function MainEvent()
    local propTab = {
        { -- tunnels entrace near building b
            { pos = Vector(-5507.6, -3911.9, 262.4) },
            { pos = Vector(-5502.3, -3871.7, 262.9) },
            { pos = Vector(-5472.4, -3893.4, 263.3) },
            { pos = Vector(-5469.7, -3866.9, 262.9) },
            { pos = Vector(-5443.9, -3891.1, 262.7), isBox = true }
        },
        { -- submarine room
            { pos = Vector(2002.47, 5689.34, -145.96) },
            { pos = Vector(2033.01, 5694.62, -145.96) },
            { pos = Vector(2034.34, 5669.50, -145.96) },
            { pos = Vector(2010.28, 5648.97, -145.96) },
            { pos = Vector(2000.03, 5703.96, -145.96) }
        },
        { -- building c
            { pos = Vector(-4256.03, 5939.96, -82.96) },
            { pos = Vector(-4269.34, 5890.10, -82.96) },
            { pos = Vector(-4302.91, 5933.41, -82.96) },
            { pos = Vector(-4321.23, 5885.95, -82.96) }
        },
        { -- building a
            { pos = Vector(1831.96, -2150.68, 1145.03) },
            { pos = Vector(1799.65, -2122.03, 1145.03) },
            { pos = Vector(1818.87, -2081.78, 1145.03) },
            { pos = Vector(1749.92, -2136.60, 1145.03) }
        },
        { -- garage
            { pos = Vector(-3215.98, -1903.99, 55.03) },
            { pos = Vector(-3215.96, -1829.90, 55.03) },
            { pos = Vector(-3158.19, -1847.12, 55.03) },
            { pos = Vector(-3143.70, -1903.99, 55.03) },
            { pos = Vector(-3191.64, -1881.06, 55.03), isBox = true }
        },
        { -- bunker
            { pos = Vector(-995.93, 1230.89, -527.97) },
            { pos = Vector(-972.05, 1175.99, -527.97) },
            { pos = Vector(-938.18, 1180.03, -527.97) },
            { pos = Vector(-1037.16, 1178.28, -527.97) },
            { pos = Vector(-1009.29, 1120.44, -527.97) }
        }
    }
    
    for _, propGroup in ipairs(propTab) do
        for k, propInfo in ipairs(propGroup) do
            local propMarker = ents.Create("gm13_marker_prop")
            propMarker:Setup(eventName, eventName .. "PropMarker" .. k .. "_".. tostring(propInfo), propInfo.pos)
        end
    end

    local junkModels = {
        "models/props_junk/garbage_glassbottle002a.mdl",
        "models/props_junk/garbage_metalcan002a.mdl",
        "models/props_junk/garbage_plasticbottle001a.mdl",
        "models/props_junk/garbage_glassbottle001a.mdl",
        "models/props_junk/popcan01a.mdl",
        "models/props_junk/metalbucket01a.mdl",
        "models/props_lab/clipboard.mdl",
        "models/props_junk/CinderBlock01a.mdl",
        "models/props_wasteland/controlroom_chair001a.mdl",
        "models/props_junk/sawblade001a.mdl",
        "models/props_lab/kennel_physics.mdl",
        "models/Gibs/wood_gib01e.mdl",
        "models/Gibs/wood_gib01d.mdl",
        "models/props_c17/tools_wrench01a.mdl",
        "models/props_interiors/pot02a.mdl",
        "models/props_junk/garbage_bag001a.mdl",
        "models/props_junk/garbage_newspaper001a.mdl",
        "models/props_junk/Shovel01a.mdl",
        "models/props_junk/plasticbucket001a.mdl",
        "models/props_junk/garbage_takeoutcarton001a.mdl",
        "models/props_junk/PlasticCrate01a.mdl",
        "models/props_junk/MetalBucket02a.mdl",
        "models/maxofs2d/camera.mdl"
    }
    
    local delay = math.random(90, 160)
    local propsFadeTime = 1.5
    local propsMaxTime = delay - propsFadeTime - 1

    timer.Create("cgm13_researcher_traces_control", delay, 1, function()
		if math.random(1, 100) <= 37 then
            local isVisible = false
            local propGroup = propTab[math.random(#propTab)]

            for _, ply in ipairs(player.GetHumans()) do
                for __, propInfo in ipairs(propGroup) do
                    if ply:VisibleVec(propInfo.pos) then
                        isVisible = true
                        break
                    end
                end
            end

            if not isVisible then
                for k, propGroup in ipairs(propGroup) do
                    local model = propGroup.isBox and "models/props_junk/cardboard_box004a.mdl" or junkModels[math.random(#junkModels)]
                    local pos = propGroup.pos
                    local ang = Angle(0, math.random(0, 180), 0)

                    local prop = CreateProp(model, pos, ang)

                    if propGroup.isBox then
                        GM13.Ent:SetInvulnerable(prop, true)
                        prop:Ignite(propsMaxTime) 
                    end

                    timer.Simple(propsMaxTime, function()
                        if not prop:IsValid() then return end

                        GM13.Ent:FadeOut(prop, propsFadeTime, function()
                            prop:Remove()
                        end)
                    end)
                end
            end
        end
    end)

    return true
end

local function RemoveEvent()
    timer.Remove("cgm13_researcher_traces_control")
end

GM13.Event:SetCall(eventName, MainEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)
