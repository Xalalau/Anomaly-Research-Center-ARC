local eventName = "generalPlayerStart"
local timerName = "gm13_" .. eventName .. "_auto_start"

local function CanPlayersSeeEntity(ent)
    for i = 1, #player.GetHumans() do
        local ply = player.GetHumans()[i]

        for _,v in pairs(ents.FindAlongRay(ply:GetShootPos(), ply:GetEyeTrace().HitPos, Vector(-2000, -2000, -2000), Vector(2000, 2000, 2000))) do
            if v == ent then
                return true
            end
        end
    end
    return false
end

local function ArePlayersNear(ent, radius)
    for _,v in pairs(ents.FindInSphere(ent:GetPos(), radius)) do
        if v:IsPlayer() then return true end
    end
    return false
end

local function CreateEvent()
    local playerStart

    timer.Create(timerName, ISGM13 and 30 or 100, 0, function()
        if playerStart and IsValid(playerStart) then return end

        if math.random(1, ISGM13 and 90 or 160) <= (ISGM13 and 10 or 4) then
            local spawnpoints = ents.FindByClass("info_player_start")
            local pos = spawnpoints[math.random(#spawnpoints)]:GetPos()
    
            playerStart = ents.Create("prop_dynamic")
            playerStart:SetModel("models/editor/playerstart.mdl")
            playerStart:SetPos(pos)
            playerStart:SetAngles(Angle(0,180,0))
            playerStart:Spawn()
        end
    end)

    timer.Create("gm13_playerstart_control", 2, 0, function()
        if !IsValid(playerStart) then return end

        if CanPlayersSeeEntity(playerStart) and math.random(1, 10) == 10 then
            playerStart:Remove()
        end

        if ArePlayersNear(playerStart, 650) then
            playerStart:Remove()
        end
    end)

    return true
end

local function RemoveEvent()
    timer.Remove(timerName)
    timer.Remove("gm13_playerstart_control")
end

GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)