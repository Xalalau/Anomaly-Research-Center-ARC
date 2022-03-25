
-- Break vehicles (By Zaurzo)

-- SCars
-- https://steamcommunity.com/sharedfiles/filedetails/?id=104483020
local function BreakSCar(vehicle)
    if not vehicle or not IsValid(vehicle) or not vehicle:IsVehicle() then return end
    if not vehicle.IsScar then return end

    if vehicle.TurnOffCar then
        vehicle:TurnOffCar()
    end

    if vehicle.StartCar then 
        vehicle.StartCar = function() return end
    end

    if vehicle.TurnLeft or vehicle.TurnRight then
        vehicle.TurnLeft = function() return end
        vehicle.TurnRight = function() return end
    end

end

-- Simphys
-- https://steamcommunity.com/workshop/filedetails/?id=771487490
local function BreakSimphys(vehicle)
    if not vehicle or not IsValid(vehicle) or not vehicle:IsVehicle() then return end
    if not vehicle.IsSimfphyscar then return end

    if vehicle.StopEngine then
        vehicle:StopEngine()
    end

    if vehicle.SetValues then
        vehicle:SetValues()
    end

    if vehicle.StartEngine then 
        vehicle.StartEngine = function() return end 
    end

    if vehicle.SetActive then
        vehicle.SetActive = function() return end
    end

end

hook.Add("OnEntityCreated", "cgm13_SetSoundTable", function(e)
    if not e:IsVehicle() then return end
    local StopSoundTable = {}
    e:SetVar("SoundTable", StopSoundTable)
end)
-- Add the sound list table to stop later

hook.Add("EntityEmitSound", "cgm13_GetSCarSoundList", function(d)
    if not d.Entity or not IsValid(d.Entity) then return end
    if not d.Entity:IsVehicle() then return end
    local e = d.Entity
    local SoundList = e:GetVar("SoundTable")
    table.insert(SoundList, d.SoundName)
    e:SetVar("SoundTable", SoundList)
end)
-- Some vehicle engine sounds don't stop upon engine break
-- So we add it to a table and stop the sound when necessary

function CGM13.Vehicle:Break(vehicle, value)

    if not vehicle or not IsValid(vehicle) then return end
    if not vehicle:IsVehicle() then return end

    if vehicle.StartEngine then
        vehicle:StartEngine(false)
        vehicle:SetSequence("idle")
    end

    BreakSCar(vehicle)
    BreakSimphys(vehicle)

    if vehicle.Think then
        if not vehicle.IsScar then
            if not vehicle.IsSimfphyscar then
                vehicle.Think = function() return end
            end
        end
    end

    for _,sounds in pairs( vehicle:GetVar("SoundTable") ) do
        vehicle:StopSound(sounds)
    end

    vehicle:SetNWBool("cgm13_burned_engine", true)
    GM13.Ent:SetMute(vehicle, true)

end

function CGM13.Vehicle:IsBroken(vehicle)
    return vehicle:GetNWBool("cgm13_burned_engine")
end

local ENT = FindMetaTable("Entity")
local SetNWBool = ENT.SetNWBool
ENT.SetNWBool = function(self, value, ...)
    if CGM13.Vehicle:IsBroken(self) and value == "cgm13_burned_engine" then return end
    return SetNWBool(self, value, ...)
end

hook.Add("VehicleMove", "cgm13_vehicle_control", function(ply, vehicle)
    if CGM13.Vehicle:IsBroken(vehicle) then
        vehicle:StartEngine(false)

        BreakSimphys(vehicle)
        BreakSCar(vehicle)
    end
end)
