local eventName = "garageBreakVehicles"

local function CreateEvent()
    local function StartTouch(ent, chance)
		if not ent:IsVehicle() or CGM13.Vehicle:IsBroken(ent) then return end

		if math.random(1, 100) <= chance then
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
    end

    local breakVehiclesGarage = ents.Create("gm13_trigger")
	breakVehiclesGarage:Setup(eventName, "breakVehiclesGarage", Vector(-2809.4, -1064.7, 207.9), Vector(-1056.9, -1919, -143.9))

    local breakVehiclesDarkroom = ents.Create("gm13_trigger")
	breakVehiclesDarkroom:Setup(eventName, "breakVehiclesDarkroom", Vector(-5252.1, -2571.6, 138.1), Vector(-3263.6, -1071.8, -102.9))

    function breakVehiclesGarage:StartTouch(ent)
        StartTouch(ent, 40)
	end

    function breakVehiclesDarkroom:StartTouch(ent)
        StartTouch(ent, 75)
	end

	return true
end

GM13.Event:SetCall(eventName, CreateEvent)
