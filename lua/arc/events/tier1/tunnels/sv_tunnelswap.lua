local eventName = "tunnelsSwap"

local function CreatePortalNearSpawn()
    local portalInfo = {
        {
            {
                pos = Vector(-3378.70, 1287.51, -240.57),
                ang = Angle(90, -90, 180),
                sizeX = 1.33,
                sizeY = 2,
                sizeZ = 1
            },
            {
                pos = Vector(2530.08, 1376.69, -79.84),
                ang = Angle(90, 0, 180),
                sizeX = 1.33,
                sizeY = 2,
                sizeZ = 1
            }
        }
    }
    
    local startTriggersInfo = {
        {
            vecA = Vector(1791.97, 1094.32, -303.45),
            vecB = Vector(1600.03, 1123.72, -179.98),
            probability = 15
        }
    }

    local endTriggersInfo = {
        {
            vecA = Vector(1777.39, 1280.09, -176.03),
            vecB = Vector(1790.19, 1470.53, -303.97)
        },
        {
            vecA = Vector(-5283.03, 1731.22, -303.97),
            vecB = Vector(-5471.97, 1751.12, -177.12)
        },
        {
            vecA = Vector(-5283.34, 1003.73, -303.97),
            vecB = Vector(-5471.97, 1027.61, -180.03)
        }
    }

    CGM13.Custom:CreatePortalSwap(eventName, portalInfo, startTriggersInfo, endTriggersInfo)    
end

local function CreatePortalNearBuildingCExit()
    local portalInfo = {
        {
            {
                pos = Vector(-5279.35, 4780.00, -241.45),
                ang = Angle(90, 0, -180),
                sizeX = 1.33,
                sizeY = 2,
                sizeZ = 1
            },
            {
                pos = Vector(-5375.88, -286.09, -240.17),
                ang = Angle(90, 90, 180),
                sizeX = 1.37,
                sizeY = 1.67,
                sizeZ = 1
            }
        }
    }

    local startTriggersInfo = {
        {
            vecA = Vector(-5281.67, 1494.35, -303.97),
            vecB = Vector(-5294.57, 1256.03, -176.79),
            probability = 15
        }
    }

    local endTriggersInfo = {
        {
            vecA = Vector(-5297.17, -297.28, -281.77),
            vecB = Vector(-5455.97, -320.94, -156.4)
        },
        {
            vecA = Vector(-5281.21, 1006.33, -303.97),
            vecB = Vector(-5471.97, 1049.83, -179)
        }
    }

    CGM13.Custom:CreatePortalSwap(eventName, portalInfo, startTriggersInfo, endTriggersInfo)    
end

local function CreateEvent()
    CreatePortalNearSpawn()
    CreatePortalNearBuildingCExit()

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
