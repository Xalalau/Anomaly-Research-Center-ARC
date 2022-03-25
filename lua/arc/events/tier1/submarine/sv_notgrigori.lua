local eventName = "submarineNotGrigori"
local debugMessage = true
local maxConeLevel = 10
local propsCanSpawn

GM13.Event.Memory.Dependency:SetDependent(eventName, "ratmanReady")
GM13.Event.Memory.Dependency:SetProvider(eventName, "coneLevel")

local function _PrintMessage(messageType, message)
	if debugMessage then
		PrintMessage(messageType, message)
	end
end

local function SetConeAutoHeal()
	local curseDetector = ents.FindByClass("gm13_sent_curse_detector")[1]

	if curseDetector then
		curseDetector:SetNWBool("readyheal", true)

		local currentLevel = GM13.Event.Memory:Get("coneLevel")

		if not currentLevel then return end

		local areaMultiplier = currentLevel / 2 

		CGM13.Custom:ProximityTrigger(eventName, "Touch", curseDetector, curseDetector:GetPos(), 150, 75 * areaMultiplier, function(ent)
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

				local effectdata = EffectData()
				effectdata:SetOrigin(ent:EyePos() - Vector(0, 0, 20))
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

				timer.Simple(2 / currentLevel, function()
					if curseDetector:IsValid() then
						curseDetector:SetNWBool("readyheal", true)
					end
				end)

				ent:SetHealth(ent:Health() + 3)
				ent:EmitSound("items/medshot4.wav")

				if ent:IsPlayer() and currentLevel >= 3 then
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

	local timerName = "cgm13_upgradekit_check_" .. tostring(kit)

	timer.Create(timerName, 1, 0, function()
		if not IsValid(kit) then
			timer.Remove(timerName)	
			return
		end

		for _, ent in pairs(ents.FindInSphere(kit:LocalToWorld(Vector(0, 0, 10)), 20)) do
			if ent:GetClass() == "gm13_sent_curse_detector" then
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

local function DestroyProps(tablePos)
	for _, ent in pairs(ents.FindInBox(tablePos + Vector(250, 250, 250), tablePos + Vector(-250, -250, -250))) do
		if ent:GetNWBool("ritualprop") then
			GM13.Ent:Dissolve(ent, 2)
		end
	end
end

local function CreateNotGrigori(theTable)
	theTable:EmitSound("vo/ravenholm/madlaugh0" .. math.random(1, 4) .. ".wav")

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
		if theTable:IsValid() then
			theTable:EmitSound(notMonkTaunts[math.random(1, #notMonkTaunts)])
		end
	end)

	timer.Simple(7, function()
		if theTable:IsValid() then
			local notMonk = ents.Create("npc_monk")

			notMonk.cgm13_crazy_grigori = true
			notMonk:SetColor(color_black)
			notMonk:SetPos(Vector(2540.65, 3558.35, -167.97))
			notMonk:SetAngles(Angle(0, 190, 0))
			notMonk:Spawn()
			notMonk:SetNWFloat("CustomHealth", 1000)
			notMonk:SetHealth(1000)
			notMonk:SetMaxHealth(1000)
			notMonk:SetNWBool("isdead", false)
			notMonk:Give("weapon_annabelle")

			GM13.Ent:SetInvulnerable(notMonk, true)
			GM13.Ent:BlockPhysgun(notMonk, true)
			GM13.Ent:BlockToolgun(notMonk, true)
			GM13.Ent:BlockContextMenu(notMonk, true)
			GM13.NPC:AttackClosestPlayer(notMonk)
			GM13.Ent:SetDamageCallback(notMonk, CheckGrigoriHealth)

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
		end
	end)

	local tablePos = theTable:GetPos()

	timer.Simple(1, function()
		DestroyProps(tablePos)

		if theTable:IsValid() then
			GM13.Ent:BlockPhysgun(theTable, false)
			GM13.Ent:BlockToolgun(theTable, false)
			GM13.Ent:BlockContextMenu(theTable, false)
		end
	end)
end

local function ConvertProp(prop, propTab)
	prop:SetColor(Color(255,0,0))
	
	GM13.Ent:FadeOut(prop, 1.5, function()
		local convertedProp = ents.Create("prop_physics")
		convertedProp:SetName("converted_prop_gm13_" .. propTab.conversion.model)
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
		prop:SetName("zprop_GM13" .. k)
		prop:SetVar("ready_for_hit_zprop", true)
		
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

	if GM13.Event.Memory:Get("coneLevel") == maxConeLevel then return end

	local propsTab = {
		{
			model = "models/props_combine/breenglobe.mdl",
			ang = {
				Angle(0,190,0),
				Angle(0,-190,0),
				Angle(0,0,0)
			},
			pos = {
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
			pos = { Vector(-4754.571289, 4893.835449, 2688.031250) },
			conversion = { 
				model = "models/props_c17/doll01.mdl",
				finalPos = Vector(2284.38, 3547.02, -120.69)
			}
		},
		{
			model = "models/props_trainstation/trashcan_indoor001a.mdl",
			ang = { Angle(0,190,0) },
			pos = { Vector(-3080.348389, -1089.743774, -31.968750) },
			conversion = { 
				model = "models/Gibs/HGIBS.mdl",
				finalPos = Vector(2284.38, 3557.02, -100.69)
			}
		},
		{
			model = "models/props_interiors/Furniture_shelf01a.mdl",
			ang = { Angle(0,90,0) },
			pos = { Vector(2352.191162, 3370.543945, -127.052246) },
			conversion = { 
				model = "models/maxofs2d/companion_doll.mdl",
				finalPos = Vector(2284.38, 3557.02, -85.69)
			}
		},
		{
			model = "models/props_combine/breenglobe.mdl",
			ang = { Angle(0,190,0) },
			pos = { Vector(778.120178, -2107.381836, 688.031250) },
			conversion = { 
				model = "models/props_c17/doll01.mdl",
				finalPos = Vector(2284.38, 3537.02, -120.69)
			}
		},
		{
			model = "models/props_interiors/Furniture_Lamp01a.mdl",
			ang = { Angle(0,0,0) },
			pos = { Vector(2000.031250, 3534.645508, -150.968750) },
			conversion = { 
				model = "models/props_c17/doll01.mdl",
				finalPos = Vector(2284.38, 3567.02, -120.69)
			}
		},
		{
			model = "models/props_combine/breenglobe.mdl",
			ang = { Angle(0,0,0) },
			pos = { Vector(-2903.97, 448.03, -303.97) },
			conversion = { 
				model = "models/props_c17/doll01.mdl",
				finalPos = Vector(2284.38, 3577.02, -120.69)
			}
		}
	}

	timer.Create("gm13_cone_level_event", 60, 0, function()
		if GM13.Event.Memory:Get("coneLevel") == maxConeLevel then
			timer.Remove("gm13_cone_level_event")	
			return
		end
			
		if not propsCanSpawn then return end

		if math.random(1, 100) <= 25 then
			SpawnProps(propsTab)
		        propsCanSpawn = false
		end
	end)

    local itemCheckTrigger = ents.Create("gm13_trigger")
    itemCheckTrigger:Setup(eventName, "itemCheckTrigger", Vector(2388.6, 3654.7, -79), Vector(2188.6, 3454.7, -167.9))

	local tablePos
	local itemsOnTable = 0
	local theTable
	function itemCheckTrigger:StartTouch(ent)
		if not ent:GetNWBool("ritualprop") then return end
		if GM13.Event.Memory:Get("coneLevel") == maxConeLevel then return end

		if not theTable or not theTable:IsValid() then
			theTable = ents.FindByName("ratman_table")[1]
		end

		if theTable and not tablePos then
			dollPosTabCopy = table.Copy(dollPosTab)
			tablePos = theTable:GetPos()
			theTable:SetMoveType(MOVETYPE_NONE)
			theTable:SetNotSolid(true)
			GM13.Ent:BlockPhysgun(theTable, true)
			GM13.Ent:BlockToolgun(theTable, true)
			GM13.Ent:BlockContextMenu(theTable, true)
			GM13.Prop:CallOnBreak(theTable, "ratman_table", function()
				DestroyProps(tablePos)
				tablePos = nil
			end)
		end

		ent:SetAngles(Angle(0,0,0))
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetNotSolid(true)
		ent:SetPos(ent.gm13_final_pos)

		GM13.Ent:BlockPhysgun(ent, true)

		itemsOnTable = itemsOnTable + 1
		ent:EmitSound("physics/metal/metal_solid_impact_hard4.wav")

		if theTable and itemsOnTable >= 7 then
			itemsOnTable = 0
			CreateNotGrigori(theTable)
		end
	end

	return true
end

local function RemoveEvent()
	timer.Remove("gm13_cone_level_event")
end

GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)
