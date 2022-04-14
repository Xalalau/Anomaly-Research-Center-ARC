local eventName = "generalHauntedProps"

local commonMaps = {
    ["gm_supermarket"] = true
}

local function ClassInSphere(class, origin, dist)
    local foundEnts = {}

    for k,v in pairs(ents.FindInSphere(origin, dist)) do
        if v:GetClass() == class and not v.gm13_player_prop then 
            table.insert(foundEnts, v) 
        end
    end

    return foundEnts
end

local function IsValidPhysicsObject(physobj)
    return TypeID(physobj) == TYPE_PHYSOBJ and physobj:IsValid()
end

local function ResizePhysics(ent, scale)
    ent:PhysicsInit(SOLID_VPHYSICS)

    local physObj = ent:GetPhysicsObject()

    if not IsValidPhysicsObject(physObj) then return false end

    local physMesh = physObj:GetMeshConvexes()

    if not istable(physMesh) or #physMesh < 1 then return false end

    for convexKey, convex in pairs(physMesh) do
        for posKey, posTab in pairs(convex) do
            convex[posKey] = posTab.pos * scale
        end
    end

    ent:PhysicsInitMultiConvex(physMesh)
    ent:EnableCustomCollisions(true)

    return IsValidPhysicsObject(ent:GetPhysicsObject())
end

local function ScaleProp(prop, scale)
    for i=0, prop:GetBoneCount() do
        prop:ManipulateBoneScale(i, Vector(1,1,1) * scale)
    end
    ResizePhysics(prop, scale)
    prop:GetPhysicsObject():SetVelocity(Vector(0,0,0))
end

local function CreateEvent()

    local totalProps = 0
    for k, ent in ipairs(ents.GetAll()) do
        if ent:GetClass() == "prop_physics" then
            totalProps = totalProps + 1
        end
    end
    
    local delay = totalProps > 200 and 200 or totalProps > 100 and 300 or 400
    local chance = (commonMaps[game.GetMap()] or ISGM13) and 6 or 3
    
    timer.Create("gm13_haunted_prop_control", delay, 0, function()
        if totalProps == 0 or ( math.random(1, 100) > chance ) then return end

        for i = 1, #player.GetHumans() do
            local ply = player.GetHumans()[i]
            local props = ClassInSphere("prop_physics", ply:GetPos(), 250)
            local mode = math.random(1, 2)

            local rProp = props[math.random(#props)]
            if IsValid(rProp) then
                if mode == 1 then
                    -- Drop Props

                    local obj = rProp:GetPhysicsObject() or rProp

                    local originalMass = obj:GetMass()
                    local force = rProp:GetForward() * 500
                    force:Rotate(Angle(math.random(-35, 35), math.random(0, 360), 0))
                
                    obj:SetMass(5)
                    obj:ApplyForceCenter(force)
                    obj:SetMass(originalMass)
                elseif mode == 2 then
                    -- Scale Props

                    local rChance = math.random(1, 2)
                    local scale = ( rChance == 1 and 1.15 ) or 0.85
                    ScaleProp(rProp, scale)
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
