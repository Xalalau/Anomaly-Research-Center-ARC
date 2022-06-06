local eventName = "generalPlayerStart"
local timerName = "gm13_" .. eventName .. "_auto_start"

function GM13:IsAddonInstalled(addonID)
    for __, addon in pairs(engine.GetAddons()) do
        if addon.wsid == tostring(addonID) then return true end
    end

    return false
end

local function ArePlayersNear(ent, radius)
    for _,v in pairs(ents.FindInSphere(ent:GetPos(), radius)) do
        if v:IsPlayer() then return true, v end
    end

    return false
end

local function SafeRemoveTrigger(trigger)
    if !IsValid(trigger) then return end
    GM13.Event:RemoveRenderInfoEntity(trigger)
    trigger:Remove()
end

local validProps = {
    ["prop_physics"] = true,
    ["prop_dynamic"] = true,
}

local function DuplicateProp(prop)
    if !validProps[prop:GetClass()] or prop.GM13_duped then return end
    
    local dupe = ents.Create(prop:GetClass())
    dupe:SetPos(prop:GetPos())
    dupe:SetAngles(prop:GetAngles())
    dupe:SetModel(prop:GetModel())
    dupe:Spawn()
    dupe:Activate()

    dupe.GM13_duped = true
    prop.GM13_duped = true
    return dupe
end

local function CreateEvent()
    local playerStart
    local maxNPCS = math.random(1,4)
    local teleport = false

    --ISGM13 and 30 or 100
    timer.Create(timerName, ISGM13 and 30 or 100, 0, function()
        if playerStart and IsValid(playerStart) then return end

        if math.random(1, ISGM13 and 90 or 160) <= (ISGM13 and 10 or 4) then
            local spawnpoints = ents.FindByClass("info_player_start")
            if !spawnpoints or #spawnpoints <= 0 then return end

            local pos = spawnpoints[math.random(#spawnpoints)]:GetPos()
    
            playerStart = ents.Create("prop_dynamic")
            playerStart:SetModel("models/editor/playerstart.mdl")
            playerStart:SetPos(pos)
            playerStart:SetAngles(Angle(0,180,0))
            playerStart:Spawn()
            playerStart.TeleportPower = 0
            playerStart.NPCS = 0

            GM13.Event:SetGameEntity(eventName, playerStart)

            local trigger = ents.Create("gm13_trigger")
            trigger:Setup(eventName, "playerStart", pos + Vector(15,15,75), pos + Vector(-15,-15,-75))
            trigger:SetVar("color", Color(0,255,0))

            function trigger:StartTouch(ent)
                if !validProps[ent:GetClass()] or ent.GM13_duped then return end

                if math.random(1,4) == 2 then
                    DuplicateProp(ent)
                end
            end

            playerStart:CallOnRemove("removeRenderInfo", function()
                SafeRemoveTrigger(trigger)
            end)

            timer.Simple(math.random(15,60), function()
                if !IsValid(playerStart) then return end
                playerStart:Remove()
            end)

            timer.Create("gm13_playerstart_time", 0.2, 0, function()
                if !IsValid(playerStart) then 
                    timer.Remove("gm13_playerstart_time")
                    teleport = false

                    return
                end

                if teleport then
                    if playerStart.FoundPlayer and (!playerStart.FoundPlayer:Alive()) then
                        playerStart:Remove() return
                    end

                    if !ArePlayersNear(playerStart, 1500) then
                        playerStart:Remove() return
                    end
                else
                    if GM13:IsAddonInstalled(2773405248) and scripted_ents.GetList()["npc_zetaplayer"] and (math.random(1, 750) <= 10 and playerStart.NPCS < maxNPCS) then
                        -- If Zeta Players addon is installed then spawn a Zeta on PlayerStart

                        local zeta = ents.Create("npc_zetaplayer")
                        if IsValid(zeta) then
                            zeta:SetPos(pos)
                            zeta:SetAngles(playerStart:GetAngles())
                            zeta:Spawn()
        
                            playerStart.NPCS = playerStart.NPCS + 1
                        end
                    end
                end

                local playersNear, ply = ArePlayersNear(playerStart, 100)
                if playersNear then
                    if math.random(1, 3) == 3 and !teleport then
                        teleport = true
                        SafeRemoveTrigger(trigger)
                    else
                        if teleport and (playerStart.TeleportPower <= math.random(4,6)) then
                            playerStart.FoundPlayer = ply

                            pos = spawnpoints[math.random(#spawnpoints)]:GetPos()
                            playerStart:SetPos(pos)

                            local ang = (ply:GetPos() - pos):Angle()
                            playerStart:SetAngles(Angle(0,ang.y,0))

                            playerStart.TeleportPower = playerStart.TeleportPower + 1
                        else
                            playerStart:Remove()
                        end
                    end
                end
            end)
        end
    end)

    hook.Add("PlayerSpawn", "gm13_playerstart_spawn_control", function(ply)
        if !isentity(playerStart) or !IsValid(playerStart) then return end

        ply:SetPos(playerStart:GetPos())
        ply:SetAngles(playerStart:GetAngles())
    end)

    return true
end

local function RemoveEvent()
    timer.Remove(timerName)
    timer.Remove("gm13_playerstart_time")
end

GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)
