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

local function IsPlayerNear(ply, ent, radius)
    for _,v in pairs(ents.FindInSphere(ent:GetPos(), radius)) do
        if v == ply then return true end
    end
    return false
end

local function CreateEvent()
    local playerStart
    local maxTeleport

    local teleportActivated = false
    local teleportCount = 0

    timer.Create(timerName, ISGM13 and 30 or 100, 0, function()
        if playerStart and IsValid(playerStart) then return end

        if math.random(1, ISGM13 and 90 or 160) <= (ISGM13 and 10 or 4) then
            local spawnpoints = ents.FindByClass("info_player_start")
            local pos = spawnpoints[math.random(#spawnpoints)]:GetPos()
    
            playerStart = ents.Create("prop_dynamic")
            playerStart:SetModel("models/editor/playerstart.mdl")
            playerStart:SetPos(pos)
            playerStart:SetAngles(Angle(0,180,0))
            playerStart:SetName("Satus")
            playerStart:Spawn()

            maxTeleport = math.random(1, 10)

            hook.Add("PlayerSpawn", "gm13_playerspawn_control", function(ply)
                if !IsValid(playerStart) then
                    hook.Remove("PlayerSpawn", "gm13_playerspawn_control")
                    return
                end

                ply:SetPos(playerStart:GetPos())
                ply:SetAngles(playerStart:GetAngles())
            end)
        end
    end)

    timer.Create("gm13_playerstart_control", 1, 0, function()
        if !IsValid(playerStart) then return end

        if not teleportActivated and (CanPlayersSeeEntity(playerStart) and math.random(1, 6) == 6) then
            playerStart:Remove()
        end

        for i = 1, #player.GetHumans() do
            local ply = player.GetHumans()[1]

            if teleportActivated then
                if !ply:Alive() or !IsPlayerNear(ply, playerStart, 1200) then
                    playerStart:Remove()
                    teleportActivated = false
                end
            end

            if IsPlayerNear(ply, playerStart, 500) then
                if math.random(1, 5) == 5 then
                    teleportActivated = true
                end

                if teleportActivated then
                    if (teleportCount > maxTeleport) or (math.random(1, 10) == 10) then
                        playerStart:Remove()
                        teleportActivated = false
    
                        return
                    end
    
                    local spawnpoints = ents.FindByClass("info_player_start")
                    local pos = spawnpoints[math.random(#spawnpoints)]:GetPos()
                    local ang = (ply:GetPos() - pos):Angle()
        
                    playerStart:SetPos(pos)
                    playerStart:SetAngles(Angle(0, ang.y, 0))
    
                    teleportCount = teleportCount + 1
                else
                    playerStart:Remove()
                end
            end
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
