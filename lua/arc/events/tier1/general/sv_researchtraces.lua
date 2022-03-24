local eventName = "generalTraces"

local function CreateProp(class, model, pos, ang, data)
    if not isstring(model) or not isstring(class) then return nil end
    if not isvector(pos) or not isangle(ang) then return nil end

    local p = ents.Create(class)

    p:SetModel(model)
    p:SetPos(pos)
    p:SetAngles(ang)
    p:Spawn()
    
    local phys = p:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
    
    if data and isfunction(data) then
        data(p)
    end
end

local function MainEvent()

    local function ArePlayersNear(origin)
        for _,v in pairs(ents.FindInSphere(origin, 2500)) do
            if v:IsPlayer() then
                return true
            end
        end
        return false
    end

    local rJunk = {
        "models/props_junk/garbage_glassbottle002a.mdl",
        "models/props/food_can/food_can_open.mdl",
        "models/props_junk/garbage_plasticbottle001a.mdl",
        "models/props_gameplay/bottle001.mdl",
        "models/props_junk/popcan01a.mdl",
        "models/props_junk/metalbucket01a.mdl",
        "models/props_lab/clipboard.mdl",
    }

    local tr = table.Random

    local espawn = false
    local tspawn = false
    local bcspawn = false
    local topspawn = false
    local garage = false
    local mirror = false

    local function Entrance1()

        if espawn == true then return end

        local posTab = {
            Vector( -5507.6, -3911.9, 262.4 ),
            Vector( -5502.3, -3871.7, 262.9 ),
            Vector( -5472.4, -3893.4, 263.3),
            Vector( -5469.7, -3866.9, 262.9 ),
            Vector( -5443.9, -3891.1, 262.7),
        }

        if ArePlayersNear(Vector( -5507.6, -3911.9, 262.4 )) then return end

        local function DataP(self) 
            timer.Simple(90, function()
                if not self or not IsValid(self) then return end
                GM13.Ent:FadeOut(self, 1.5, function() self:Remove()
                    espawn = false
                end)
            end)
        end

        local function BoxPropData(self) 
            GM13.Ent:SetInvulnerable(self, true)
            self:Ignite(math.huge) 
            timer.Simple(90, function()
                if not self or not IsValid(self) then return end
                GM13.Ent:FadeOut(self, 1.5, function() self:Remove()
                    espawn = false
                end)
            end)
        end

        local propTable = {
            ["p1"] = {Model = tr(rJunk), Pos = posTab[1], Ang = Angle(0,0,0), PData = DataP},
            ["p2"] = {Model = tr(rJunk), Pos = posTab[2], Ang = Angle(0,0,0), PData = DataP},
            ["p3"] = {Model = tr(rJunk), Pos = posTab[4], Ang = Angle(0,0,0), PData = DataP},
            ["p4"] = {Model = tr(rJunk), Pos = posTab[5], Ang = Angle(0,0,0), PData = DataP},
            ["p5"] = {Model = "models/props_junk/cardboard_box004a.mdl", Pos = posTab[3], Ang = Angle(0,0,0), PData = BoxPropData},
        }

        for id, prop in pairs(propTable) do
            CreateProp("prop_physics", prop.Model, prop.Pos, prop.Ang, prop.PData)
            espawn = true
        end

    end

    local function Transmission1()

        if tspawn == true then return end

        local posTab = {
            Vector( 2002.476563, 5689.349609, -145.968750 ),
            Vector( 2033.012573, 5694.620605, -145.968750 ),
            Vector( 2034.347046, 5669.501465, -145.968750 ),
            Vector( 2010.280762, 5648.973633, -145.968750 ),
            Vector( 2000.031250, 5703.968750, -145.968750 ),
        }

        if ArePlayersNear(Vector( 2002.476563, 5689.349609, -145.968750 )) then return end

        local function DataP(self) 
            timer.Simple(90, function()
                if not self or not IsValid(self) then return end
                GM13.Ent:FadeOut(self, 1.5, function() self:Remove()
                    tspawn = false
                end)
            end)
        end

        local propTable = {
            ["p1"] = {Model = tr(rJunk), Pos = posTab[1], Ang = Angle(0,0,0), PData = DataP},
            ["p2"] = {Model = tr(rJunk), Pos = posTab[2], Ang = Angle(0,0,0), PData = DataP},
            ["p3"] = {Model = tr(rJunk), Pos = posTab[3], Ang = Angle(0,0,0), PData = DataP},
            ["p4"] = {Model = tr(rJunk), Pos = posTab[4], Ang = Angle(0,0,0), PData = DataP},
            ["p5"] = {Model = tr(rJunk), Pos = posTab[5], Ang = Angle(0,0,0), PData = DataP},
        }

        for id, prop in pairs(propTable) do
            CreateProp("prop_physics", prop.Model, prop.Pos, prop.Ang, prop.PData)
            tspawn = false
        end
    end

    local function BuildingC1()
        if bcspawn == true then return end

        local posTab = {
            Vector( -4256.031250, 5939.968750, -82.968750 ),
            Vector( -4269.342285, 5890.105469, -82.968750 ),
            Vector( -4302.913086, 5933.411621, -82.968750 ),
            Vector( -4321.233398, 5885.958984, -82.968750 ),   
        }

        if ArePlayersNear(Vector( -4256.031250, 5939.968750, -82.968750 )) then return end

        local function DataP(self) 
            timer.Simple(90, function()
                if not self or not IsValid(self) then return end
                GM13.Ent:FadeOut(self, 1.5, function() self:Remove()
                    bcspawn = false
                end)
            end)
        end

        local propTable = {
            ["p1"] = {Model = tr(rJunk), Pos = posTab[1], Ang = Angle(0,0,0), PData = DataP},
            ["p2"] = {Model = tr(rJunk), Pos = posTab[2], Ang = Angle(0,0,0), PData = DataP},
            ["p3"] = {Model = tr(rJunk), Pos = posTab[3], Ang = Angle(0,0,0), PData = DataP},
            ["p4"] = {Model = tr(rJunk), Pos = posTab[4], Ang = Angle(0,0,0), PData = DataP},
        }

        for id, prop in pairs(propTable) do
            CreateProp("prop_physics", prop.Model, prop.Pos, prop.Ang, prop.PData)
            bcspawn = true
        end
    end

    local function BuildingTopRoom()
        if topspawn == true then return end

        local posTab = {
            Vector( 1831.968750, -2150.685059, 1145.031250 ),
            Vector( 1799.658447, -2122.038086, 1145.031250 ),
            Vector( 1818.877197, -2081.783691, 1145.031250 ),
            Vector( 1749.920410, -2136.605957, 1145.031250 ),         
        }

        if ArePlayersNear(Vector( 1831.968750, -2150.685059, 1145.031250 )) then return end

        local function DataP(self) 
            timer.Simple(90, function()
                if not self or not IsValid(self) then return end
                GM13.Ent:FadeOut(self, 1.5, function() self:Remove()
                    topspawn = false
                end)
            end)
        end

        local propTable = {
            ["p1"] = {Model = tr(rJunk), Pos = posTab[1], Ang = Angle(0,0,0), PData = DataP},
            ["p2"] = {Model = tr(rJunk), Pos = posTab[2], Ang = Angle(0,0,0), PData = DataP},
            ["p3"] = {Model = tr(rJunk), Pos = posTab[3], Ang = Angle(0,0,0), PData = DataP},
            ["p4"] = {Model = tr(rJunk), Pos = posTab[4], Ang = Angle(0,0,0), PData = DataP},
        }

        for id, prop in pairs(propTable) do
            CreateProp("prop_physics", prop.Model, prop.Pos, prop.Ang, prop.PData)
            topspawn = true
        end
    end

    local function Garage()
        if garage == true then return end

        local posTab = {
            Vector( -3215.989990, -1903.998779, 55.031250 ),
            Vector( -3215.968750, -1829.901611, 55.031250 ),
            Vector( -3158.192871, -1847.123779, 55.031250 ),
            Vector( -3143.700684, -1903.998779, 55.031250 ),
            Vector(-3191.642822, -1881.062134, 55.031250),
        }

        if ArePlayersNear(Vector( -3215.989990, -1903.998779, 55.031250 )) then return end

        local function DataP(self) 
            timer.Simple(90, function()
                if not self or not IsValid(self) then return end
                GM13.Ent:FadeOut(self, 1.5, function() self:Remove()
                    garage = false
                end)
            end)
        end

        local function BoxPropData(self) 
            GM13.Ent:SetInvulnerable(self, true)
            self:Ignite(math.huge) 
            timer.Simple(90, function()
                if not self or not IsValid(self) then return end
                GM13.Ent:FadeOut(self, 1.5, function() self:Remove()
                    garage = false
                end)
            end)
        end

        local propTable = {
            ["p1"] = {Model = tr(rJunk), Pos = posTab[1], Ang = Angle(0,0,0), PData = DataP},
            ["p2"] = {Model = tr(rJunk), Pos = posTab[2], Ang = Angle(0,0,0), PData = DataP},
            ["p3"] = {Model = tr(rJunk), Pos = posTab[3], Ang = Angle(0,0,0), PData = DataP},
            ["p4"] = {Model = tr(rJunk), Pos = posTab[4], Ang = Angle(0,0,0), PData = DataP},
            ["p5"] = {Model = "models/props_junk/cardboard_box004a.mdl", Pos = posTab[5], Ang = Angle(0,0,0), PData = BoxPropData},
        }

        for id, prop in pairs(propTable) do
            CreateProp("prop_physics", prop.Model, prop.Pos, prop.Ang, prop.PData)
            garage = true
        end
    end

    local function MirrorRoom()

        if mirror == true then return end

        local posTab = {
            Vector( -995.936340, 1230.894897, -527.968750 ),
            Vector( -972.057312, 1175.997192, -527.968750 ),
            Vector( -938.189880, 1180.032715, -527.968750 ),
            Vector( -1037.165161, 1178.285767, -527.968750 ),
            Vector( -1009.298950, 1120.444702, -527.968750 ),
            
        }

        --if ArePlayersNear(Vector( -995.936340, 1230.894897, -527.968750 )) then return end

        local function DataP(self) 
            timer.Simple(90, function()
                if not self or not IsValid(self) then return end
                GM13.Ent:FadeOut(self, 1.5, function() self:Remove()
                    mirror = false
                end)
            end)
        end

        local propTable = {
            ["p1"] = {Model = tr(rJunk), Pos = posTab[1], Ang = Angle(0,0,0), PData = DataP},
            ["p2"] = {Model = tr(rJunk), Pos = posTab[2], Ang = Angle(0,0,0), PData = DataP},
            ["p3"] = {Model = tr(rJunk), Pos = posTab[3], Ang = Angle(0,0,0), PData = DataP},
            ["p4"] = {Model = tr(rJunk), Pos = posTab[4], Ang = Angle(0,0,0), PData = DataP},
            ["p5"] = {Model = tr(rJunk), Pos = posTab[5], Ang = Angle(0,0,0), PData = DataP},
        }

        for id, prop in pairs(propTable) do
            CreateProp("prop_physics", prop.Model, prop.Pos, prop.Ang, prop.PData)
            mirror = true
        end
    end

    local r = math.random(120,200)

    local function RandomEvent()
        local re = math.random(1,6)
        if re == 1 then BuildingC1()
        elseif re == 2 then Transmission1() 
        elseif re == 3 then Entrance1() 
        elseif re == 4 then BuildingTopRoom() 
        elseif re == 5 then Garage() 
        elseif re == 6 then MirrorRoom() end
    end

    timer.Create("cgm13_researcherTraces_control", r, 0, function()
        RandomEvent()
    end)
    return true
end

local function RemoveEvent()
    timer.Remove("cgm13_researcherTraces_control")
end

GM13.Event:SetCall(eventName, MainEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)