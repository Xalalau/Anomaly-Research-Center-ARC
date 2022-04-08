local eventName = "bigDarkBreakVehicles"

GM13.Event.Memory.Dependency:SetDependent(eventName, "openThePortal", "showBigDarkRoom")

local function CreateEvent()
    local breakVehiclesBigDarkroom = ents.Create("gm13_trigger")
	breakVehiclesBigDarkroom:Setup(eventName, "breakVehiclesBigDarkroom", Vector(2542.8, 4078.5, -7081.9), Vector(-11247.8, -7663.7, -2176))

    function breakVehiclesBigDarkroom:StartTouch(ent)
        if not ent:IsVehicle() then return end

        timer.Simple(math.random(2, 6), function()
            if not ent:IsValid() then return end

            CGM13.Vehicle:Break(ent, true)

            if math.random(1, 100) <= 50 then
                local explo = ents.Create("env_explosion")
                explo:SetPos(ent:GetPos())
                explo:Spawn()
                explo:Fire("Explode")
                explo:SetKeyValue("IMagnitude", 20)

                ent:Ignite(15, 30)
            end
        end)
    end

	return true
end

GM13.Event:SetCall(eventName, CreateEvent)
