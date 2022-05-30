-- Break vehicles (By Zaurzo)

-- Default HL2 based vehicles
function CGM13.Vehicle:BreakHL2Vehicle(vehicle)
    if not vehicle or not IsValid(vehicle) or not vehicle:IsVehicle() then return end

    if vehicle.StartEngine then
        vehicle:StartEngine(false)
        vehicle:SetSequence("idle")
        vehicle.StartEngine = function() return end
    end

    if vehicle.TurnOn then
        vehicle:TurnOn(false)
        vehicle.TurnOn = function() return end
    end

    if vehicle.Think then
        vehicle.Think = function() return end
    end
end

function CGM13.Vehicle:IsBroken(vehicle)
    return vehicle:GetNWBool("cgm13_burned_engine")
end

-- Break any supported vehicle
function CGM13.Vehicle:Break(vehicle, value)
    if not vehicle or not IsValid(vehicle) or not vehicle:IsVehicle() then return end

    if vehicle.IsSimfphyscar then
        CGM13.Addon:BreakSimphys(vehicle)
    elseif vehicle.IsScar then
        CGM13.Addon:BreakSCar(vehicle)    
    else
        CGM13.Vehicle:BreakHL2Vehicle(vehicle)
    end

    GM13.Ent:SetMute(vehicle, true)
    
    local soundTable = vehicle:GetVar("SoundTable") or {}

    for _, sounds in ipairs(soundTable) do
        vehicle:StopSound(sounds)
    end

    vehicle:SetNWBool("cgm13_burned_engine", true)
end

-- Some vehicle engine sounds don't stop upon engine break
-- So we add it to a table and stop the sound when necessary
hook.Add("OnEntityCreated", "cgm13_SetSoundTable", function(ent)
    if not ent:IsVehicle() then return end

    ent:SetVar("SoundTable", {})
end)

hook.Add("EntityEmitSound", "cgm13_GetSCarSoundList", function(data)
    local ent = data.Entity

    if ent:IsVehicle() then
        local soundTable = ent:GetVar("SoundTable")

        if soundTable then
            table.insert(soundTable, data.SoundName)
        end
    end
end)

-- Detour ENT.SetNWBool to block attempts to use broken vehicles
local ENT = FindMetaTable("Entity")
local SetNWBool = ENT.SetNWBool
ENT.SetNWBool = function(self, value, ...)
    if self:IsVehicle() and CGM13.Vehicle:IsBroken(self) then return end
    return SetNWBool(self, value, ...)
end

-- Keep vehicles broken
hook.Add("VehicleMove", "cgm13_vehicle_control", function(ply, vehicle)
    if not vehicle or not IsValid(vehicle) then return end

    if CGM13.Vehicle:IsBroken(vehicle) then
        if vehicle.IsSimfphyscar then
            CGM13.Addon:BreakSimphys(vehicle)
        elseif vehicle.IsScar then
            CGM13.Addon:BreakSCar(vehicle)    
        else
            CGM13.Vehicle:BreakHL2Vehicle(vehicle)
        end
    end
end)
