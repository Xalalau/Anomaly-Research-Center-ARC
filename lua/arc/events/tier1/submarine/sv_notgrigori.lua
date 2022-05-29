local eventName = "submarineNotGrigori"
local debugMessage = false
local maxConeLevel = 4
local propsCanSpawn

GM13.Event.Memory.Dependency:SetDependent(eventName, "ratmanReady", "savedCitizen")
GM13.Event.Memory.Dependency:SetProvider(eventName, "coneLevel", "coneMaxLevel")

local function _PrintMessage(messageType, message)
	if debugMessage then
		PrintMessage(messageType, message)
	end
end

local function SetConeAutoHeal()
	local curseDetector = ents.FindByClass("gm13_sent_curse_detector")[1]

	if curseDetector then
		curseDetector:SetNWBool("readyheal", true)

		local currentLevel = GM13.Event.Memory:Get("coneLevel") or 1

		if currentLevel == maxConeLevel and not GM13.Event.Memory:Get("coneMaxLevel") then
			GM13.Event.Memory:Set("coneMaxLevel", true)
		end

		if not currentLevel then return end

		local areaMultiplier = currentLevel / 1.5

		GM13.Custom:CreateProximityTrigger(eventName, "Touch", curseDetector, curseDetector:GetPos(), 150, 150 * areaMultiplier, function(ent)
			if not ent:IsPlayer() and not ent:IsNPC() then return end

			if ent:IsNPC() then 
				local somePlayer

				for k, v in ipairs(player.GetHumans()) do
					somePlayer = v
					break
				end
				
				if ent:Disposition(somePlayer) < 3 then -- https://wiki.facepunch.com/gmod/Enums/D
					return
				end
			end

			if ent:Health() == ent:GetMaxHealth() then return end

			if curseDetector:GetNWBool("readyheal") then
				curseDetector:SetNWBool("readyheal", false)

				if curseDetector.light:IsValid() then
					local effectdata = EffectData()
					effectdata:SetOrigin(ent:EyePos() - Vector(0, 0, 5))
					effectdata:SetStart(curseDetector.light:GetPos())

					curseDetector.light:SetColor(Color(47, 225, 237, 255))
					curseDetector.light:SetOn(true)
					timer.Simple(0.2, function()
						if curseDetector:IsValid() then
							curseDetector.light:SetOn(false)
							curseDetector.light:SetColor(Color(255, 255, 255, 255))
						end
					end)

					util.Effect("ToolTracer", effectdata)
				end

				timer.Simple(2 / (currentLevel * 1.6), function()
					if curseDetector:IsValid() then
						curseDetector:SetNWBool("readyheal", true)
					end
				end)

				ent:SetHealth(ent:Health() + 3)
				ent:EmitSound("items/medshot4.wav")

				if ent:IsPlayer() and currentLevel >= 4 then
					ent:SetArmor(ent:Armor() + 3)
					ent:EmitSound("items/battery_pickup.wav")

					if ent:Armor() >= ent:GetMaxArmor() then
						ent:SetArmor(ent:GetMaxArmor())
					end
				end

				if ent:Health() >= ent:GetMaxHealth() then
					ent:SetHealth(ent:GetMaxHealth())
				end
			end
		end)

		curseDetector:CallOnRemove("cgm13_restore_cone_healing", function()
			timer.Simple(2, function()
				SetConeAutoHeal()
			end)
		end)
	end
end

local function CreateKit(kitPos)
	local kit = ents.Create("prop_physics")

	kit:SetNWBool("upgradekit", true)
	kit:SetName("upgradekit")
	kit:SetModel("models/weapons/w_package.mdl")
	kit:SetPos(kitPos + Vector(0, 0, 10))
	kit:Spawn()
	GM13.Ent:SetCursed(kit, true)

	local timerName = "cgm13_upgradekit_check_" .. tostring(kit)

	timer.Create(timerName, 1, 0, function()
		if not IsValid(kit) then
			timer.Remove(timerName)	
			return
		end

		for _, ent in pairs(ents.FindInSphere(kit:LocalToWorld(Vector(0, 0, 10)), 20)) do
			if ent:GetClass() == "gm13_sent_curse_detector" then
				if GM13.Event.Memory:Get("coneLevel") == maxConeLevel then
					GM13.Ent:FadeOut(kit, 0.5, function() kit:Remove() 
						GM13.Ent:Dissolve(ent, 3) 
					end)

					return
				end
					
				kit:EmitSound("items/suitchargeok1.wav")
				
				local oldLevel = GM13.Event.Memory:Get("coneLevel") or 1
				local newLevel = oldLevel + 1

				GM13.Event.Memory:Set("coneLevel", newLevel)

				_PrintMessage(HUD_PRINTCENTER, "The Curse Detector has been upgraded to Level " .. newLevel)
				_PrintMessage(HUD_PRINTTALK,"The Curse Detector has been upgraded to Level " .. newLevel)

				if newLevel == 2 then
					_PrintMessage(HUD_PRINTTALK, "Level 2 Curse Detector: Heals players while any player is near it. Every level after 2 gains faster healing.")
				end

				if newLevel == 3 then
					_PrintMessage(HUD_PRINTTALK, "Level 3 Curse Detector: Each time a player gets healed, the player gains armor of the same amount. Every level after 3 increases healing area.")
				end

				SetConeAutoHeal()

				kit:Remove()
				break
			end
		end
	end)
end

local function CheckGrigoriHealth(target, dmginfo)
	if not target.cgm13_crazy_grigori then return end

	local damagetaken = dmginfo:GetDamage()
	local grigori = target

	grigori:SetNWFloat("CustomHealth", target:GetNWFloat("CustomHealth") - damagetaken)

	if grigori:GetNWFloat("CustomHealth") > 0 or grigori:GetNWBool("isdead") then return true end

	_PrintMessage(HUD_PRINTCENTER, "Father Grigori has dropped an Upgrade Kit.")
	_PrintMessage(HUD_PRINTTALK, "Father Grigori has dropped an Upgrade Kit.")

	grigori:SetNWBool("isdead", true)
	grigori:EmitSound("vo/ravenholm/monk_death07.wav")

	CreateKit(grigori:GetPos())

	GM13.Ent:Dissolve(grigori, 1)
	
	propsCanSpawn = true

	return true
end

local function DestroyProps()
	for _, prop in ipairs(ents.FindByName("gm13_not_grigori_converted_prop")) do
		GM13.Ent:Dissolve(prop, 2)
	end

	for _, prop in ipairs(ents.FindByName("gm13_not_grigori_prop")) do
		GM13.Ent:Dissolve(prop, 2)
	end
end

local function SetGregoriLv2Power(notMonk)
	timer.Create("gm13_notgrigori_lvl_2", 0.6, 0, function()
		if not notMonk:IsValid() then
			timer.Remove("gm13_notgrigori_lvl_2")
			return
		end

		local manhack = ents.Create("npc_manhack")
		manhack:SetPos(notMonk:GetPos() + notMonk:GetForward() * 35)
		manhack:SetRenderFX(kRenderFxHologram)
		manhack:Spawn()
		manhack:Activate()
		manhack:AddEntityRelationship(notMonk, D_LI, 99)
		notMonk:AddEntityRelationship(manhack, D_LI, 99)
	end)
end

-- Thanks, Meteor Shower
-- https://steamcommunity.com/sharedfiles/filedetails/?id=138376105
local function SetGregoriLv3Power(notMonk)
	timer.Simple(280, function()
		if notMonk:IsValid() then
			notMonk:Remove()
		end
	end)

	timer.Create("gm13_notgrigori_lvl_3_pos", 20, 0, function()
		if not notMonk:IsValid() then
			timer.Remove("gm13_notgrigori_lvl_3_pos")
			return
		end

        local validPlyPosEnts = {}

        for k, posEnt in ipairs(ents.FindByName("positionMesh")) do
            table.insert(validPlyPosEnts, posEnt:GetPos())
        end

		notMonk:SetPos(validPlyPosEnts[math.random(#validPlyPosEnts)] + Vector(0, 0, 75))
	end)

	timer.Create("gm13_notgrigori_lvl_3", 0.33, 0, function()
		if not notMonk:IsValid() then
			timer.Remove("gm13_notgrigori_lvl_3")
			return
		end

		local damage = 5
		local magnitude = 200
		local force = notMonk:GetForward() * 60000
		local ang = Angle(math.random(-15, -55), math.random(0, 360), 0)
		force:Rotate(ang)

		local missile = ents.Create("prop_physics")
		missile:SetModel("models/props_phx/mk-82.mdl")
		missile:SetAngles(ang)
		missile:PhysicsInit(SOLID_VPHYSICS)
		missile:SetMoveType(MOVETYPE_VPHYSICS)
		missile:SetSolid(SOLID_VPHYSICS)
		missile:SetPos(notMonk:GetPos() + Vector(0, 0, 75))
		missile:Spawn()
		missile:Activate()

		local phys = missile:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()

			phys:SetMass(15)
			phys:ApplyForceCenter(force)
		end

		local trail = ents.Create("env_fire_trail")
		trail:SetPos(missile:GetPos())
		trail:SetParent(missile)
		trail:Spawn()
		trail:Activate()
		
		missile:AddCallback("PhysicsCollide", function()
			local pos = missile:GetPos()
			local scale = magnitude / 100.0
			local effectData = EffectData()
			effectData:SetStart(pos)
			effectData:SetOrigin(pos)
			effectData:SetScale(scale)
			util.Effect("missile_explosion", effectData) 
			util.BlastDamage(missile, missile, pos, magnitude, damage)
			missile:EmitSound("ambient/explosions/explode_4.wav", 90 * scale, 100)
		end)
	end)
end

local function CreateNotGrigori(ratmansTable, pos)
	ratmansTable:EmitSound("vo/ravenholm/madlaugh0" .. math.random(1, 4) .. ".wav")

	local notMonkTaunts = {
		"vo/ravenholm/engage04.wav",
		"vo/ravenholm/engage05.wav",
		"vo/ravenholm/firetrap_welldone.wav",
		"vo/ravenholm/monk_kill03.wav",
		"vo/ravenholm/monk_kill07.wav",
		"vo/ravenholm/monk_kill10.wav",
		"vo/ravenholm/monk_kill11.wav",
		"vo/ravenholm/pyre_anotherlife.wav",
		"vo/ravenholm/monk_mourn05.wav",
		"vo/ravenholm/monk_mourn07.wav"
	}

	timer.Simple(5, function()
		if ratmansTable:IsValid() then
			ratmansTable:EmitSound(notMonkTaunts[math.random(1, #notMonkTaunts)])
		end
	end)

	timer.Simple(7, function()
		if ratmansTable:IsValid() then
			local notMonk = ents.Create("npc_monk")

			notMonk.cgm13_crazy_grigori = true
			notMonk:SetColor(color_black)
			notMonk:SetPos(pos)
			notMonk:SetAngles(Angle(0, 190, 0))
			notMonk:Spawn()
			notMonk:SetNWBool("isdead", false)
			notMonk:Give("weapon_annabelle")

			GM13.Ent:SetInvulnerable(notMonk, true)
			GM13.Ent:BlockPhysgun(notMonk, true)
			GM13.Ent:BlockToolgun(notMonk, true)
			GM13.Ent:BlockContextMenu(notMonk, true)
			GM13.NPC:AttackClosestPlayer(notMonk)
			GM13.Ent:SetDamageCallback(notMonk, CheckGrigoriHealth)
			GM13.Ent:SetCursed(notMonk, true)

			for _, ply in ipairs(player.GetHumans()) do
				ply:GodDisable()
			end

			for k, ent in ipairs(ents.GetAll()) do
				if ent:IsNPC() or ent:IsNextBot() then
					notMonk:AddEntityRelationship(ent, D_HT, 99)
					ent:AddEntityRelationship(notMonk, D_HT, 99)
				end

				if ent:GetName() == "ratman" then
					GM13.Ent:Dissolve(ent, 1)
					ent:EmitSound("npc/stalker/go_alert2.wav")
				end
			end

			notMonk:GetActiveWeapon():SetClip1(50000)

			local coneLevel = GM13.Event.Memory:Get("coneLevel") or 1

			if coneLevel == 2 then
				notMonk:SetNWFloat("CustomHealth", 1000)
				notMonk:SetHealth(1000)
				notMonk:SetMaxHealth(1000)

				SetGregoriLv2Power(notMonk)
			end

			if coneLevel == 3 then		
				notMonk:SetNWFloat("CustomHealth", 25000)
				notMonk:SetHealth(30000)
				notMonk:SetMaxHealth(30000)

				timer.Simple(1.5, function()
					if notMonk:IsValid() then
						SetGregoriLv3Power(notMonk)

						notMonk:SetPos(Vector(-1406.98, 453.33, -100))
					end
				end)
			end

			ratmansTable:TakeDamage(100, notMonk)
		end
	end)

	timer.Simple(1, function()
		if ratmansTable:IsValid() then
			GM13.Ent:BlockPhysgun(ratmansTable, false)
			GM13.Ent:BlockToolgun(ratmansTable, false)
			GM13.Ent:BlockContextMenu(ratmansTable, false)
		end
	end)
end

local function ConvertProp(prop, propTab)
	prop:SetColor(Color(255,0,0))
	
	GM13.Ent:FadeOut(prop, 1.5, function()
		local convertedProp = ents.Create("prop_physics")
		convertedProp:SetName("gm13_not_grigori_converted_prop")
		convertedProp:SetNWBool("ritualprop", true)
		convertedProp:SetModel(propTab.conversion.model)
		convertedProp:SetPos(prop:GetPos() + Vector(0,0,10))
		convertedProp:SetAngles(Angle(0,0,0))
		convertedProp.gm13_final_pos = propTab.conversion.finalPos
		convertedProp:Spawn()

		convertedProp:PhysicsInit(SOLID_VPHYSICS)
		convertedProp:SetMoveType(MOVETYPE_VPHYSICS)
		convertedProp:SetSolid(SOLID_VPHYSICS)

		local physObj = convertedProp:GetPhysicsObject()
		
		if IsValid(physObj) then
			physObj:Wake()
		end
		
		GM13.Ent:SetInvulnerable(convertedProp, true)
		GM13.Ent:BlockToolgun(convertedProp, true)
		GM13.Ent:BlockContextMenu(convertedProp, true)
		GM13.Ent:FadeIn(convertedProp, 1)
		GM13.Ent:SetCursed(convertedProp, true)
		
		convertedProp:EmitSound("ambient/levels/canals/toxic_slime_gurgle".. math.random(2, 8) .. ".wav", 90)

		if prop:IsValid() then
			GM13.Ent:Dissolve(prop, 3) 
		end
	end)
end

local function SpawnProps(propsTab)
	for k, propTab in pairs(propsTab) do
		local pos = propTab.pos[math.random(1, #propTab.pos)]		
		local ang = propTab.ang[math.random(1, #propTab.ang)]
		
		local propMarker = ents.Create("gm13_marker")
		propMarker:Setup(eventName, "propMarker_" .. k, pos + Vector(10, 10, 20), pos + Vector(-10, -10, 0))

		local prop = ents.Create("prop_physics")
		prop:SetModel(propTab.model)
		prop:SetPos(pos + Vector(0,0,20))
		prop:SetAngles(ang)
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetMoveType(MOVETYPE_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetMaxHealth(1)
		prop:SetHealth(1)
		prop:SetName("gm13_not_grigori_prop")
		prop:SetVar("ready_for_hit_zprop", true)
		prop:SetRenderFX(kRenderFxPulseFastWider)
		
		GM13.Ent:SetCursed(prop, true)

		local physObj = prop:GetPhysicsObject()
		
		if IsValid(physObj) then
			physObj:Wake()
		end
		
		prop:Spawn()

		GM13.Ent:SetDamageCallback(prop, function()
			if prop:GetVar("ready_for_hit_zprop") then
				prop:SetVar("ready_for_hit_zprop", false)
				ConvertProp(prop, propTab)
			end
		end)
	end
end

local function CreateEvent()
	propsCanSpawn = true
	
	if GM13.Event.Memory:Get("coneLevel") then
		timer.Simple(2, function()
			SetConeAutoHeal()
		end)
	end

	if GM13.Event.Memory:Get("coneMaxLevel") then return end

	local propsTab = {
		{
			model = "models/props_combine/breenglobe.mdl",
			ang = {
				Angle(0,190,0),
				Angle(0,-190,0),
				Angle(0,0,0)
			},
			pos = {
				-- Vector(2009.48, 3949.19, -167.97) -- For tests
				Vector(738.694275, -1828.850708, 1360.031250),
				Vector(754.604919, -1361.564331, 1360.031250),
				Vector(-2856.869141, -2388.120361, 284.031250),
				Vector(-2901.221924, -1473.495483, -79.968750),
				Vector(736.031250, -1824.031250, -79.968750),
				Vector(736.031250, -1375.968750, -79.968750),
				Vector(-4733.438965, 5582.304688, 2273.031250),
				Vector(2991.968750, 5703.968750, -103.968750)
			},
			conversion = { 
				model = "models/props_c17/doll01.mdl",
				finalPos = Vector(2284.38, 3557.02, -120.69)
			}
		},
		{
			model = "models/props_combine/breenglobe.mdl",
			ang = { Angle(0,190,0) },
			pos = { 
				-- Vector(2011.41, 3869.93, -167.97) -- For tests
				Vector(-4754.571289, 4893.835449, 2688.031250)
			},
			conversion = { 
				model = "models/props_c17/doll01.mdl",
				finalPos = Vector(2284.38, 3547.02, -120.69)
			}
		},
		{
			model = "models/props_trainstation/trashcan_indoor001a.mdl",
			ang = { Angle(0,190,0) },
			pos = {
				-- Vector(2025.86, 4011.33, -167.97) -- For tests
				Vector(-2929.99, -1234.92, -142.97),
				Vector(-2923.32, -1334.41, -142.97),
				Vector(-2993.5, -1390.25, -142.97),
				Vector(-3059.49, -1368.22, -142.97)
			},
			conversion = { 
				model = "models/Gibs/HGIBS.mdl",
				finalPos = Vector(2284.38, 3557.02, -100.69)
			}
		},
		{
			model = "models/props_interiors/Furniture_shelf01a.mdl",
			ang = { Angle(0,90,0) },
			pos = {
				-- Vector(2017.78, 3809.61, -167.97) -- For tests
				Vector(2352.191162, 3370.543945, -127.052246)
			},
			conversion = { 
				model = "models/maxofs2d/companion_doll.mdl",
				finalPos = Vector(2284.38, 3557.02, -85.69)
			}
		},
		{
			model = "models/props_combine/breenglobe.mdl",
			ang = { Angle(0,190,0) },
			pos = {
				-- Vector(2022.28, 3743.76, -167.97) -- For tests
				Vector(778.120178, -2107.381836, 688.031250)
			},
			conversion = { 
				model = "models/props_c17/doll01.mdl",
				finalPos = Vector(2284.38, 3537.02, -120.69)
			}
		},
		{
			model = "models/props_interiors/Furniture_Lamp01a.mdl",
			ang = { Angle(0,0,0) },
			pos = {
				-- Vector(2027.11, 3683.95, -167.97) -- For tests
				Vector(2000.031250, 3534.645508, -150.968750)
			},
			conversion = { 
				model = "models/props_c17/doll01.mdl",
				finalPos = Vector(2284.38, 3567.02, -120.69)
			}
		},
		{
			model = "models/props_combine/breenglobe.mdl",
			ang = { Angle(0,0,0) },
			pos = {
				-- Vector(2031.2, 3633.69, -167.97) -- For tests
				Vector(-2903.97, 448.03, -303.97)
			},
			conversion = { 
				model = "models/props_c17/doll01.mdl",
				finalPos = Vector(2284.38, 3577.02, -120.69)
			}
		}
	}

	local notGrigoriPos = Vector(2540.65, 3558.35, -167.97)

	local notGrigoriMaker = ents.Create("gm13_marker_npc")
    notGrigoriMaker:Setup(eventName, "notGrigoriMaker", notGrigoriPos, notGrigoriPos + Vector(-10, -10, -10))

	for _, propTab in ipairs(propsTab) do
        for k, pos in ipairs(propTab.pos) do
            local propMarker = ents.Create("gm13_marker_prop")
            propMarker:Setup(eventName, eventName .. "PropMarker" .. k .. "_" .. tostring(propTab), pos)
        end
    end

	local ratmansTable

	timer.Create("gm13_cone_level_event", 60, 0, function()
		if GM13.Event.Memory:Get("coneLevel") == maxConeLevel then
			timer.Remove("gm13_cone_level_event")	
			return
		end
			
		if not propsCanSpawn then return end

		if math.random(1, 100) <= 25 then
			ratmansTable = ents.FindByName("ratman_table")[1]

			if ratmansTable then
				local isTableStanding = ratmansTable:GetUp().z >= 0.99
				local isOnGround = util.QuickTrace(ratmansTable:GetPos(), ratmansTable:GetUp() * -20).HitWorld

				if isTableStanding and isOnGround then 
					SpawnProps(propsTab)
					propsCanSpawn = false

					ratmansTable:SetMoveType(MOVETYPE_NONE)
					ratmansTable:SetNotSolid(true)
					GM13.Ent:BlockPhysgun(ratmansTable, true)
					GM13.Ent:BlockToolgun(ratmansTable, true)
					GM13.Ent:BlockContextMenu(ratmansTable, true)
					GM13.Prop:CallOnBreak(ratmansTable, "ratman_table", function()
						DestroyProps()
					end)
				end
			end
		end
	end)

    local itemCheckTrigger = ents.Create("gm13_trigger")
    itemCheckTrigger:Setup(eventName, "itemCheckTrigger", Vector(2388.6, 3654.7, -79), Vector(2188.6, 3454.7, -167.9))

	local itemsOnTable = 0
	function itemCheckTrigger:StartTouch(ent)
		if not ent:GetNWBool("ritualprop") then return end
		if GM13.Event.Memory:Get("coneLevel") == maxConeLevel then return end

		ent:SetAngles(Angle(0,0,0))
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetNotSolid(true)
		ent:SetPos(ent.gm13_final_pos)

		GM13.Ent:BlockPhysgun(ent, true)

		itemsOnTable = itemsOnTable + 1
		ent:EmitSound("physics/metal/metal_solid_impact_hard4.wav")

		if ratmansTable and ratmansTable:IsValid() and itemsOnTable >= 7 then
			itemsOnTable = 0
			CreateNotGrigori(ratmansTable, notGrigoriPos)
		end
	end

	return true
end

local function RemoveEvent()
	timer.Remove("gm13_cone_level_event")
end

GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)
