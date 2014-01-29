--[[


			db   d8b   db db    db db   dD  .d88b.  d8b   db  d888b  
			88   I8I   88 88    88 88 ,8P' .8P  Y8. 888o  88 88' Y8b 
			88   I8I   88 88    88 88,8P   88    88 88V8o 88 88      
			Y8   I8I   88 88    88 88`8b   88    88 88 V8o88 88  ooo 
			`8b d8'8b d8' 88b  d88 88 `88. `8b  d8' 88  V888 88. ~8~ 
			 `8b8' `8d8'  ~Y8888P' YP   YD  `Y88P'  VP   V8P  Y888P


		Script - Wukong - The Monkey King 2.0.2 by Roach

		Dependency: 
			- Nothing

		Changelog:
			2.0.2
				- Fixed Consumables
				- Fixed some typo from the Autocarry Version
				- Added Tiamat and Hydra on the Items List
				- Removed Orbwalker from Lane Clear
				- Fixed Jungle Clear
			2.0.1
				- Fixed Orbwalking in Lane Clear/Jungle Clear
				- Improved Combo Combination
				- Removed R from KillSteal Option
			2.0
				- No longer AutoCarry Script
				- Rewrote everything
				- Combo Reworked: Should be a lot smoother now
				- Harass Reworked: Should work better and use Decoy properly
				- Farm reworked / Uses mixed skill damages to maximize farm
				- Lane Clear & Jungle Clear Improved / Uses new jungle table with all mobs in 5v5 / 3v3
				- New Option to KS with Items
				- Added Priority Arranger to Target Selector
				- New Option to Draw 'Who is being targeted'
				- Added TickManager/FPS Drops Improver - It will lower your FPS Drops
				- Now Lag Free Circles is implemented:
					- Credits to:
						- barasia283
						- vadash
						- ViceVersa
						- Trees
						- Any more I don't know of
					- Features:
						- Globally reduces the FPS drop from circles.
					- Requirements:
						- VIP
				- Using ARGB Function for the Draw Ranges
			1.0.3
				- Added a new Check for using Q in Harass Mode
				- Fixed Harass Function(Many thanks to Sida for his ideea with the DelayedAction)
				- Rewrote Low Checks Functions
				- Added a new Check for Mana Potions
					- One for Harass/Farm
					- One for Potions
				- Deleted Wooglets Support as an Usable Item
			1.0.2
				- Fixed Harass Option
				- Changed the way to check if mana is low
				- Added Animation Check
			1.0.1
				- First release
			
--]]
-- / Hero Name Check / --
if myHero.charName ~= "MonkeyKing" then return end
-- / Hero Name Check / --

-- / Loading Function / --
function OnLoad()
	--->
		Variables()
		WukongMenu()
		PrintChat("<font color='#FF0000'> >> Wukong - The Monkey King 2.0.2 Loaded <<</font>")
	---<
end
-- / Loading Function / --

-- / Tick Function / --
function OnTick()
	--->
		Checks()
		DamageCalculation()
		UseConsumables()

		if Target then
			if WukongMenu.harass.qharass and not castingUlt then CastQ(Target) end
			if WukongMenu.killsteal.Ignite then AutoIgnite(Target) end
		end
	---<
	-- Menu Variables --
	--->
		ComboKey =     WukongMenu.combo.comboKey
		FarmingKey =   WukongMenu.farming.farmKey
		HarassKey =    WukongMenu.harass.harassKey
		ClearKey =     WukongMenu.clear.clearKey
		escapeArtistKey =  WukongMenu.misc.escapeArtistKey
	---<
	-- Menu Variables --
	--->
		if ComboKey then
			FullCombo()
		end
		if HarassKey then
			HarassCombo()
		end
		if FarmingKey and not ComboKey then
			Farm()
		end
		if ClearKey then
			MixedClear()
		end	
		if WukongMenu.killsteal.smartKS then KillSteal() end
	---<
end
-- / Tick Function / --

-- / Variables Function / --
function Variables()
	--- Skills Vars --
	--->
		SkillQ = {range = 300,		name = "Crushing Blow",	ready = false, color = ARGB(255,178, 0 , 0 ), mana = myHero:GetSpellData(_Q).mana}
		SkillW = {range = 125,		name = "Decoy",			ready = false, color = ARGB(255, 32,178,170)									 }
		SkillE = {range = 625,		name = "Nimbus Strike",	ready = false, color = ARGB(255,128, 0 ,128), mana = myHero:GetSpellData(_E).mana}
		SkillR = {range = 162.5,	name = "Cyclone",		ready = false								, mana = myHero:GetSpellData(_R).mana}
	---<
	--- Skills Vars ---
	--- Items Vars ---
	--->
		Items =
		{
					HealthPot		= {slot = nil, ready = false, inUse = false},
					ManaPot			= {slot = nil, ready = false, inUse = false},
					FlaskPot		= {slot = nil, ready = false			   }
		}
	---<
	--- Items Vars ---
	--- Orbwalking Vars ---
	--->
		lastAnimation = nil
		lastAttack = 0
		lastAttackCD = 0
		lastWindUpTime = 0
	---<
	--- Orbwalking Vars ---
	--- TickManager Vars ---
	--->
		TManager =
		{
			onTick	= TickManager(20),
			onDraw	= TickManager(80),
			onSpell	= TickManager(15)
		}
	---<
	--- TickManager Vars ---
	if VIP_USER then
		--- LFC Vars ---
		--->
			_G.oldDrawCircle = rawget(_G, 'DrawCircle')
			_G.DrawCircle = DrawCircle2
		---<
		--- LFC Vars ---
	end
	--- Drawing Vars ---
	--->
		--TextList = {"Harass him", "Q = Kill", "E = Kill!", "E+Q = Kill", "E+Q+R: ", "Need CDs"}
		KillText = {}
		colorText = ARGB(255,255,204,0)
	---<
	--- Drawing Vars ---
	--- Misc Vars ---
	--->
		Items.HealthPot.inUse = false
		castDelay, castingUlt = 0, false
		gameState = GetGame()
		if gameState.map.shortName == "twistedTreeline" then
			TTMAP = true
		else
			TTMAP = false
		end
	---<
	--- Misc Vars ---
	--- Tables ---
	--->
		enemycombo = {}
		allyHeroes = GetAllyHeroes()
		enemyHeroes = GetEnemyHeroes()
		enemyTable = {}
		enemysInTable = 0
		enemyMinions = minionManager(MINION_ENEMY, 1000, player, MINION_SORT_HEALTH_ASC)
		JungleMobs = {}
		JungleFocusMobs = {}
		priorityTable = {
	    	AP = {
	        	"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
	        	"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
	        	"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra",
	        },
	    	Support = {
	        	"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean",
	        },
	    	Tank = {
	        	"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
	        	"Warwick", "Yorick", "Zac",
	        },
	    	AD_Carry = {
	        	"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
	        	"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo","Zed", 
	        },
	    	Bruiser = {
	        	"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
	        	"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao",
	        },
        }
		if TTMAP then --
			FocusJungleNames = {
				["TT_NWraith1.1.1"] = true,
				["TT_NGolem2.1.1"] = true,
				["TT_NWolf3.1.1"] = true,
				["TT_NWraith4.1.1"] = true,
				["TT_NGolem5.1.1"] = true,
				["TT_NWolf6.1.1"] = true,
				["TT_Spiderboss8.1.1"] = true,
			}		
			JungleMobNames = {
				["TT_NWraith21.1.2"] = true,
				["TT_NWraith21.1.3"] = true,
				["TT_NGolem22.1.2"] = true,
				["TT_NWolf23.1.2"] = true,
				["TT_NWolf23.1.3"] = true,
				["TT_NWraith24.1.2"] = true,
				["TT_NWraith24.1.3"] = true,
				["TT_NGolem25.1.1"] = true,
				["TT_NWolf26.1.2"] = true,
				["TT_NWolf26.1.3"] = true,
			}
		else 
			JungleMobNames = { 
				["Wolf8.1.2"] = true,
				["Wolf8.1.3"] = true,
				["YoungLizard7.1.2"] = true,
				["YoungLizard7.1.3"] = true,
				["LesserWraith9.1.3"] = true,
				["LesserWraith9.1.2"] = true,
				["LesserWraith9.1.4"] = true,
				["YoungLizard10.1.2"] = true,
				["YoungLizard10.1.3"] = true,
				["SmallGolem11.1.1"] = true,
				["Wolf2.1.2"] = true,
				["Wolf2.1.3"] = true,
				["YoungLizard1.1.2"] = true,
				["YoungLizard1.1.3"] = true,
				["LesserWraith3.1.3"] = true,
				["LesserWraith3.1.2"] = true,
				["LesserWraith3.1.4"] = true,
				["YoungLizard4.1.2"] = true,
				["YoungLizard4.1.3"] = true,
				["SmallGolem5.1.1"] = true,
			}
			FocusJungleNames = {
				["Dragon6.1.1"] = true,
				["Worm12.1.1"] = true,
				["GiantWolf8.1.1"] = true,
				["AncientGolem7.1.1"] = true,
				["Wraith9.1.1"] = true,
				["LizardElder10.1.1"] = true,
				["Golem11.1.2"] = true,
				["GiantWolf2.1.1"] = true,
				["AncientGolem1.1.1"] = true,
 				["Wraith3.1.1"] = true,
				["LizardElder4.1.1"] = true,
				["Golem5.1.2"] = true,
				["GreatWraith13.1.1"] = true,
				["GreatWraith14.1.1"] = true,
			}
		end
		for i = 0, objManager.maxObjects do
			local object = objManager:getObject(i)
			if object ~= nil then
				if FocusJungleNames[object.name] then
					table.insert(JungleFocusMobs, object)
				elseif JungleMobNames[object.name] then
					table.insert(JungleMobs, object)
				end
			end
		end
		for i = 1, heroManager.iCount do enemycombo[i] = 0 end
	---<
	--- Tables ---
end
-- / Variables Function / --

-- / Menu Function / --
function WukongMenu()
	--- Main Menu ---
	--->
		WukongMenu = scriptConfig("Wukong - The Monkey King", "Wukong")
		---> Combo Menu
		WukongMenu:addSubMenu("["..myHero.charName.." - Combo Settings]", "combo")
			WukongMenu.combo:addParam("comboKey", "Full Combo Key (X)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
			WukongMenu.combo:addParam("stopUlt", "Stop "..SkillR.name.." (R) If Target Can Die", SCRIPT_PARAM_ONOFF, false)
			WukongMenu.combo:addParam("comboItems", "Use Items with Burst", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.combo:addParam("comboOrbwalk", "Orbwalk in Combo", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.combo:permaShow("comboKey")
		---<
		---> Harass Menu
		WukongMenu:addSubMenu("["..myHero.charName.." - Harass Settings]", "harass")
			WukongMenu.harass:addParam("hMode", "Harass Mode",SCRIPT_PARAM_SLICE, 1, 1, 2, 0)
			WukongMenu.harass:addParam("harassKey", "Harass Hotkey (T)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
			WukongMenu.harass:addParam("qharass", "Always "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.harass:addParam("mTmH", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.harass:permaShow("harassKey")
		---<
		---> Farming Menu
		WukongMenu:addSubMenu("["..myHero.charName.." - Farming Settings]", "farming")
			WukongMenu.farming:addParam("farmKey", "Farming ON/Off (Z)", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey("Z"))
			WukongMenu.farming:addParam("qFarm", "Farm with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.farming:addParam("eFarm", "Farm with "..SkillE.name.." (E)", SCRIPT_PARAM_ONOFF, false)
			WukongMenu.farming:permaShow("farmKey")
		---<
		---> Clear Menu		
		WukongMenu:addSubMenu("["..myHero.charName.." - Clear Settings]", "clear")
			WukongMenu.clear:addParam("clearKey", "Jungle/Lane Clear Key (V)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
			WukongMenu.clear:addParam("JungleFarm", "Use Skills to Farm Jungle", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.clear:addParam("ClearLane", "Use Skills to Clear Lane", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.clear:addParam("clearQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.clear:addParam("clearE", "Clear with "..SkillE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.clear:addParam("clearOrbJ", "OrbWalk Jungle", SCRIPT_PARAM_ONOFF, true)
		---<
		---> KillSteal Menu
		WukongMenu:addSubMenu("["..myHero.charName.." - KillSteal Settings]", "killsteal")
			WukongMenu.killsteal:addParam("smartKS", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.killsteal:addParam("ultKS", "Use "..SkillR.name.." (R) to KS", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.killsteal:addParam("itemsKS", "Use Items to KS", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.killsteal:addParam("Ignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.killsteal:permaShow("smartKS")
		---<
		---> Drawing Menu			
		WukongMenu:addSubMenu("["..myHero.charName.." - Drawing Settings]", "drawing")
			if VIP_USER then
				WukongMenu.drawing:addSubMenu("["..myHero.charName.." - LFC Settings]", "lfc")
					WukongMenu.drawing.lfc:addParam("LagFree", "Activate Lag Free Circles", SCRIPT_PARAM_ONOFF, false)
					WukongMenu.drawing.lfc:addParam("CL", "Length before Snapping", SCRIPT_PARAM_SLICE, 300, 75, 2000, 0)
					WukongMenu.drawing.lfc:addParam("CLinfo", "Higher length = Lower FPS Drops", SCRIPT_PARAM_INFO, "")
			end
			WukongMenu.drawing:addParam("disableAll", "Disable All Ranges Drawing", SCRIPT_PARAM_ONOFF, false)
			WukongMenu.drawing:addParam("drawText", "Draw Enemy Text", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.drawing:addParam("drawTargetText", "Draw Who I'm Targetting", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.drawing:addParam("drawQ", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.drawing:addParam("drawW", "Draw "..SkillW.name.." (W) Range", SCRIPT_PARAM_ONOFF, false)
			WukongMenu.drawing:addParam("drawE", "Draw "..SkillE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		---<
		---> Misc Menu	
		WukongMenu:addSubMenu("["..myHero.charName.." - Misc Settings]", "misc")
			WukongMenu.misc:addParam("escapeArtistKey", "Escape Artist Hotkey (G)", SCRIPT_PARAM_ONKEYDOWN, false, 71)
			WukongMenu.misc:addParam("ZWItems", "Auto Zhonyas/Wooglets", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.misc:addParam("ZWHealth", "Min Health % for Zhonyas/Wooglets", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)
			WukongMenu.misc:addParam("aHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.misc:addParam("pHealth", "Min % for Health Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
			WukongMenu.misc:addParam("aMP", "Auto Mana Pots", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.misc:addParam("pMana", "Min % for Mana Pots", SCRIPT_PARAM_SLICE, 35, 0, 100, -1)
			WukongMenu.misc:addParam("uTM", "Use Tick Manager/FPS Improver (Requires Reload)",SCRIPT_PARAM_ONOFF, false)
			WukongMenu.misc:permaShow("escapeArtistKey")
		---<
		---> Target Selector		
			TargetSelector = TargetSelector(TARGET_LESS_CAST, SkillE.range, DAMAGE_MAGIC)
			TargetSelector.name = "MonkeyKing"
			WukongMenu:addTS(TargetSelector)
		---<
		---> Arrange Priorities
			if heroManager.iCount < 10 then -- borrowed from Sidas Auto Carry, modified to 3v3
       			PrintChat(" >> Too few champions to arrange priority")
			elseif heroManager.iCount == 6 and TTMAP then
				ArrangeTTPriorities()
    		else
        		ArrangePriorities()
    		end
    	---<
	---<
	--- Main Menu ---
end
-- / Menu Function / --

-- / Full Combo Function / --
function FullCombo()
	--- Combo While Not Channeling --
	--->
		if castDelay == 0 then
			castingUlt = false
		end
		
		if Target then
			if WukongMenu.combo.comboOrbwalk then
				OrbWalking(Target)
			end
			if WukongMenu.combo.comboItems then
				UseItems(Target)
			end
			if not castingUlt then
				CastE(Target)
				if not SkillE.ready then
					CastQ(Target)
				end
				if Target.health < rDmg then
					CastR(Target)
				end
			end
		else
			if WukongMenu.combo.comboOrbwalk then
				moveToCursor()
			end
		end
	---<
	--- Combo While Not Channeling --
end
-- / Full Combo Function / --

-- / Harass Combo Function / --
function HarassCombo()
	--- Smart Harass --
	--->
		if WukongMenu.harass.mTmH then
			moveToCursor()
		end
		if Target then
			--- Harass Mode 1 E+Q+W ---
			if WukongMenu.harass.hMode == 1 then
				CastE(Target)
				if SkillW.ready then
					if not SkillE.ready then CastQ(Target) end
					if not SkillQ.ready and not SkillE.ready then CastSpell(_W) end
				end
			end
			--- Harass Mode 1 ---
			--- Harass Mode 2 E+W ---
			if WukongMenu.harass.hMode == 2 then
				if SkillW.ready then
					CastE(Target)
					if not SkillE.ready then CastSpell(_W) end
				end
			end
			--- Harass Mode 2 ---
		end
	---<
	--- Smart Harass ---
end
-- / Harass Combo Function / --

-- / Farm Function / --
function Farm()
	--->
		for _, minion in pairs(enemyMinions.objects) do
			--- Minion Damages ---
			local qMinionDmg 	= getDmg("Q",  minion, myHero)
			local eMinionDmg	= getDmg("E",  minion, myHero)
			local aaMinionDmg	= getDmg("AD", minion, myHero)
			--- Minion Damages ---
			--- Minion Keys ---
			local qFarmKey = WukongMenu.farming.qFarm
			local eFarmKey = WukongMenu.farming.eFarm
			--- Minion Keys ---
			--- Farming Minions ---
			if ValidTarget(minion) then
				if GetDistance(minion) <= SkillQ.range then
					if qFarmKey and wFarmKey then
						if SkillQ.ready and SkillE.ready then
							if minion.health <= (eMinionDmg + qMinionDmg) and minion.health > qMinionDmg then
								CastE(minion)
								CastQ(minion)
							end
						elseif SkillE.ready and not SkillQ.ready then
							if minion.health <= (eMinionDmg) then
								CastE(minion)
							end
						elseif SkillQ.ready and not SkillE.ready then
							if minion.health <= (qMinionDmg) then
								CastQ(minion)
							end
						elseif GetDistance(minion) <= myHero.range and not SkillQ.ready and not SkillE.ready then
							if minion.health <= aaMinionDmg then
								myHero:Attack(minion)
							end
						end
					elseif qFarmKey and not eFarmKey then
						if SkillQ.ready then
							if minion.health <= (eMinionDmg) then
								CastQ(minion)
							end
						elseif GetDistance(minion) <= myHero.range and not SkillQ.ready then
							if minion.health <= aaMinionDmg then
								myHero:Attack(minion)
							end
						end
					end
				elseif (GetDistance(minion) > SkillQ.range) and (GetDistance(minion) <= SkillE.range) then
					if eFarmKey then
						if minion.health <= eMinionDmg then
							CastE(minion)
						end
					end
				end
			end
			break									
		end
		--- Farming Minions ---
	---<
end
-- / Farm Function / --

-- / Clear Function / --
function MixedClear()
	--- Lane Clear ---
	--->
		if WukongMenu.clear.ClearLane then
			for _, minion in pairs(enemyMinions.objects) do
				if ValidTarget(minion) and GetDistance(minion) < SkillE.range then
						if TimeToAttack() then myHero:Attack(minion) end
					if WukongMenu.clear.clearQ and SkillQ.ready and GetDistance(minion) <= SkillQ.range then
						CastQ(minion)
					end
					if WukongMenu.clear.clearE and SkillE.ready and GetDistance(minion) <= SkillE.range then
						CastE(minion)
					end
				end
			end
		end
	---<
	--- Lane Clear ---
	--- Jungle Clear ---
	--->
		if WukongMenu.clear.JungleFarm then
			JungleMob = GetJungleMob()
			if JungleMob then
				if WukongMenu.clear.clearOrbJ then
					if TimeToAttack() then myHero:Attack(JungleMob) end
				end
				if WukongMenu.clear.clearQ and SkillQ.ready and GetDistance(JungleMob) <= SkillQ.range then
					CastQ(JungleMob)
				end
				if WukongMenu.clear.clearE and SkillE.ready and GetDistance(JungleMob) <= SkillE.range then
					CastE(JungleMob) 
				end
			else
				for _, minion in pairs(enemyMinions.objects) do
					if not ValidTarget(minion) and GetDistance(minion) > SkillE.range then
						moveToCursor()
					end
				end
			end
		end
	---<
	--- Jungle Clear ---
end
-- / Clear Function / --

-- / Casting Q Function / --
function CastQ(enemy)
	--- Dynamic Q Cast ---
	--->
		if not SkillQ.ready or (GetDistance(enemy) > SkillQ.range) then
			return false
		end
		if ValidTarget(enemy) then 
			CastSpell(_Q)
			myHero:Attack(enemy)
			
			return true
		end
		return false
	---<
	--- Dynamic Q Cast ---
end
-- / Casting Q Function / --

-- / Casting E Function / --
function CastE(enemy)
	--- Dynamic E Cast ---
	--->
		if not SkillE.ready or (GetDistance(enemy) > SkillE.range) then
			return false
		end
		if ValidTarget(enemy) then 
			if VIP_USER then
				Packet("S_CAST", {spellId = _E, targetNetworkId = enemy.networkID}):send()
				return true
			else
				CastSpell(_E, enemy)
				return true
			end
		end
		return false
	---<
	--- Dynamic E Cast ---
end
-- / Casting E Function / --

-- / Casting R Function / --
function CastR(enemy)
	--- Dynamic R Cast ---
	--->
		if (SkillQ.ready or SkillE.ready or (GetDistance(enemy) > SkillR.range)) or not SkillR.ready then
			return false
		end
		if ValidTarget(enemy) then
			CastSpell(_R) 
			castDelay = GetTickCount()+400
			castingUlt = true
		end
	---<
	--- Dymanic R Cast --
end
-- / Casting R Function / --

-- / Use Items Function / --
function UseItems(enemy)
	--- Use Items ---
	--->
		if not enemy then
			enemy = Target
		end
		if ValidTarget(enemy) then
			if dfgReady and GetDistance(enemy) <= 600 then CastSpell(dfgSlot, enemy) end
			if hxgReady and GetDistance(enemy) <= 600 then CastSpell(hxgSlot, enemy) end
			if bwcReady and GetDistance(enemy) <= 450 then CastSpell(bwcSlot, enemy) end
			if brkReady and GetDistance(enemy) <= 450 then CastSpell(brkSlot, enemy) end
			if tmtReady and GetDistance(enemy) <= 185 then CastSpell(tmtSlot) end
			if hdrReady and GetDistance(enemy) <= 185 then CastSpell(hdrSlot) end
		end
	---<
	--- Use Items ---
end
-- / Use Items Function / --

function UseConsumables()
	--- Check if Zhonya/Wooglets Needed --
	--->
		if WukongMenu.misc.ZWItems and isLow('Wooglets') and Target and (znaReady or wgtReady) then
			CastSpell((wgtSlot or znaSlot))
		end
	---<
	--- Check if Zhonya/Wooglets Needed --
	--- Check if HP Potions Needed --
	--->
		if WukongMenu.misc.aHP and isLow('Health') and not Items.HealthPot.inUse and (Items.HealthPot.ready or Items.FlaskPot.ready) then
			CastSpell((Items.HealthPot.slot or Items.FlaskPot.slot))
		end
	---<
	--- Check if HP Potions Needed --
	--- Check if MP Potions Needed --
	--->
		if WukongMenu.misc.aMP and isLow('Mana') and not Items.ManaPot.inUse and (Items.ManaPot.ready or Items.FlaskPot.ready) then
			CastSpell((Items.ManaPot.slot or Items.FlaskPot.slot))
		end
	---<
	--- Check if MP Potions Needed --
end	

-- / Auto Ignite Function / --
function AutoIgnite(enemy)
	--- Simple Auto Ignite ---
	--->
		if enemy.health <= iDmg and GetDistance(enemy) <= 600 then
			if iReady then CastSpell(ignite, enemy) end
		end
	---<
	--- Simple Auto Ignite ---
end
-- / Auto Ignite Function / --

-- / Damage Calculation Function / --
function DamageCalculation()
	--- Calculate our Damage On Enemies ---
	--->
 		for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) then
				dfgDmg, hxgDmg, bwcDmg, iDmg, bftDmg = 0, 0, 0, 0, 0
				qDmg = (SkillQ.ready and getDmg("Q",enemy,myHero) or 0)
				eDmg = (SkillE.ready and getDmg("E",enemy,myHero) or 0)
            	rDmg = getDmg("R",enemy,myHero)*4
				if dfgReady then dfgDmg = (dfgSlot and getDmg("DFG",enemy,myHero) or 0)	end
				if bftReady then bftdmg = (bftSlot and getDmg("BLACKFIRE",enemy,myHero) or 0) end
        	    if hxgReady then hxgDmg = (hxgSlot and getDmg("HXG",enemy,myHero) or 0) end
            	if bwcReady then bwcDmg = (bwcSlot and getDmg("BWC",enemy,myHero) or 0) end
				if tmtReady then tmtDmg = (tmtSlot and getDmg("TMT",enemy,myHero) or 0) end
				if hdrReady then hdrDmg = (hdrSlot and getDmg("RSH",enemy,myHero) or 0) end
            	if iReady then iDmg = (ignite and getDmg("IGNITE",enemy,myHero) or 0) end
            	onspellDmg = (liandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(blackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
            	itemsDmg = dfgDmg + bftDmg + hxgDmg + bwcDmg + tmtDmg + hdrDmg + iDmg + onspellDmg
			end
		end
    ---<
    --- Calculate our Damage On Enemies ---
end
-- / Damage Calculation Function / --

-- / KillSteal Function / --
function KillSteal()
	--- KillSteal ---
	--->
		if Target then
			local distance = GetDistance(Target)
			local health = Target.health
			if health <= qDmg and SkillQ.ready and (distance < SkillQ.range) then
				CastQ(Target)
			elseif health <= eDmg and SkillE.ready and (distance < SkillE.range) then
				CastE(Target)
			elseif health <= (qDmg + eDmg) and SkillQ.ready and SkillE.ready and (distance < SkillE.range) then
				CastE(Target)
			elseif WukongMenu.killsteal.itemsKS then
				if health <= (qDmg + eDmg + itemsDmg) and health > (qDmg + eDmg) then
					if SkillQ.ready and SkillE.ready then
						UseItems(Target)
					end
				end
			end
		end
	---<
	--- KillSteal ---
end
-- / KillSteal Function / --

-- / Misc Functions / --
--- On Animation (Setting our last Animation) ---
--->
	function OnAnimation(unit, animationName)
    	if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
	end
---<
--- On Animation (Setting our last Animation) ---
--- isChanneling Function (Checks if Animation is Channeling) ---
--->
	function isChanneling(animationName)
    	if lastAnimation == animationName then
        	return true
    	else
        	return false
    	end
	end
---<
--- isChanneling Function (Checks if Animation is Channeling) ---
--- Checking if Hero in Danger ---
--->
	function isInDanger(hero)
		nEnemiesClose, nEnemiesFar = 0, 0
		hpPercent = hero.health / hero.maxHealth
		for _, enemy in pairs(enemies) do
			if not enemy.dead and hero:GetDistance(enemy) <= 500 then 
				nEnemiesClose = nEnemiesClose + 1 
				if hpPercent < 0.5 and hpPercent < enemy.health / enemy.maxHealth then return true end
			elseif not enemy.dead and hero:GetDistance(enemy) <= 1000 then
				nEnemiesFar = nEnemiesFar + 1 
			end
		end
		if nEnemiesClose > 1 then return true end
		if nEnemiesClose == 1 and nEnemiesFar > 1 then return true end
		return false
	end
---<
--- Checking if Hero in Danger ---
--- Get Jungle Mob Function by Apple ---
--->
	function GetJungleMob()
		for _, Mob in pairs(JungleFocusMobs) do
			if ValidTarget(Mob, q1Range) then return Mob end
		end
		for _, Mob in pairs(JungleMobs) do
			if ValidTarget(Mob, q1Range) then return Mob end
		end
	end
---<
--- Get Jungle Mob Function by Apple ---
--- Arrange Priorities 5v5 ---
--->
	function ArrangePriorities()
    	for i, enemy in pairs(enemyHeroes) do
        	SetPriority(priorityTable.AD_Carry, enemy, 1)
        	SetPriority(priorityTable.AP, enemy, 2)
        	SetPriority(priorityTable.Support, enemy, 3)
        	SetPriority(priorityTable.Bruiser, enemy, 4)
        	SetPriority(priorityTable.Tank, enemy, 5)
    	end
	end
---<
--- Arrange Priorities 5v5 ---
--- Arrange Priorities 3v3 ---
--->
	function ArrangeTTPriorities()
		for i, enemy in pairs(enemyHeroes) do
			SetPriority(priorityTable.AD_Carry, enemy, 1)
        	SetPriority(priorityTable.AP, enemy, 1)
        	SetPriority(priorityTable.Support, enemy, 2)
        	SetPriority(priorityTable.Bruiser, enemy, 2)
        	SetPriority(priorityTable.Tank, enemy, 3)
		end
	end
---<
--- Arrange Priorities 3v3 ---
--- Set Priorities ---
--->
	function SetPriority(table, hero, priority)
    	for i=1, #table, 1 do
        	if hero.charName:find(table[i]) ~= nil then
            	TS_SetHeroPriority(priority, hero.charName)
        	end
    	end
	end
---<
--- Set Priorities ---
-- / Misc Functions / --

-- / On Create Obj Function / --
function OnCreateObj(obj)
	--- All of Our Objects (CREATE) --
	-->
		if obj ~= nil then
			if obj.name:find("Global_Item_HealthPotion.troy") then
				if GetDistance(obj, myHero) <= 70 then
					Items.HealthPot.inUse = true
				end
			end
			if obj.name:find("Global_Item_ManaPotion.troy") then
				if GetDistance(obj, myHero) <= 70 then
					Items.ManaPot.inUse = true
				end
			end
			if FocusJungleNames[obj.name] then
				table.insert(JungleFocusMobs, obj)
			elseif JungleMobNames[obj.name] then
        		table.insert(JungleMobs, obj)
			end
		end
	---<
	--- All of Our Objects (CREATE) --
end
-- / On Create Obj Function / --

-- / On Delete Obj Function / --
function OnDeleteObj(obj)
	--- All of Our Objects (CLEAR) --
	--->
		if obj ~= nil then
			if obj.name:find("Global_Item_HealthPotion.troy") then
				Items.HealthPot.inUse = false
			end
			if obj.name:find("Global_Item_ManaPotion.troy") then
				Items.ManaPot.inUse = false
			end
			for i, Mob in pairs(JungleMobs) do
				if obj.name == Mob.name then
					table.remove(JungleMobs, i)
				end
			end
			for i, Mob in pairs(JungleFocusMobs) do
				if obj.name == Mob.name then
					table.remove(JungleFocusMobs, i)
				end
			end
		end
	--- All of Our Objects (CLEAR) --
	---<
end
--- All The Objects in The World Literally ---
-- / On Delete Obj Function / --

-- / Plugin On Draw / --
function OnDraw()
	--- Tick Manager Check ---
	--->
		if not TManager.onDraw:isReady() and WukongMenu.misc.uTM then return end
	---<
	--->
	--- Drawing Our Ranges ---
	--->
		if not myHero.dead then
			if not WukongMenu.drawing.disableAll then
				if SkillQ.ready and WukongMenu.drawing.drawQ then 
					DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, SkillQ.color)
				end
				if SkillW.ready and WukongMenu.drawing.drawW then
					DrawCircle(myHero.x, myHero.y, myHero.z, SkillW.range, SkillW.color)
				end
				if SkillE.ready and WukongMenu.drawing.drawE then
					DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, SkillE.color)
				end
			end
		end
	---<
	--- Drawing Our Ranges ---
	--- Draw Enemy Damage Text ---
	--->
		if WukongMenu.drawing.drawText then
			for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) then
				local enemypPos = WorldToScreen(D3DXVECTOR3(enemy.x+150,enemy.maxBBox.y,enemy.z+80))
				if OnScreen(enemypPos.x, enemypPos.y) then
					local enemyred = enemycombo[i]<100 and math.floor(enemycombo[i]/100*255) or 255
					local enemygreen = enemycombo[i]<100 and math.floor(255 - enemycombo[i]/100*255) or 0
					DrawText("D:"..enemycombo[i].."%", 20, enemypPos.x, enemypPos.y, RGBA(enemyred,enemygreen,0,255))
				end
			end
	end
		end
	---<
	--- Draw Enemy Damage Text ---
	--- Draw Enemy Target ---
	--->
		if Target then
			if WukongMenu.drawing.drawTargetText then
				DrawText("Targeting: " .. Target.charName, 12, 100, 100, colorText)
			end
		end
	---<
	--- Draw Enemy Target ---
end
-- / Plugin On Draw / --

-- / OrbWalking Functions / --
--- Orbwalking Target ---
--->
	function OrbWalking(Target)
		if TimeToAttack() and GetDistance(Target) <= myHero.range + GetDistance(myHero.minBBox) then
			myHero:Attack(Target)
    	elseif heroCanMove() then
        	moveToCursor()
    	end
	end
---<
--- Orbwalking Target ---
--- Check When Its Time To Attack ---
--->
	function TimeToAttack()
    	return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
	end
---<
--- Check When Its Time To Attack ---
--- Prevent AA Canceling ---
--->
	function heroCanMove()
		return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
	end
---<
--- Prevent AA Canceling ---
--- Move to Mouse ---
--->
	function moveToCursor()
		if GetDistance(mousePos) then
			local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
			myHero:MoveTo(moveToPos.x, moveToPos.z)
    	end        
	end
---<
--- Move to Mouse ---
--- On Process Spell ---
--->
	function OnProcessSpell(unit,spell)
		--- Tick Manager Check ---
		--->
			if not TManager.onSpell:isReady() and WukongMenu.misc.uTM then return end
		---<
		--->
			if unit.isMe then
				if spell.name:find("Attack") then
					lastAttack = GetTickCount() - GetLatency()/2
					lastWindUpTime = spell.windUpTime*1000
					lastAttackCD = spell.animationTime*1000
				end
			end
		---<
	end
---<
--- On Process Spell ---
-- / OrbWalking Functions / --

-- / FPS Manager Functions / --
class 'TickManager'
--- TM Init Function ---
--->
	function TickManager:__init(ticksPerSecond)
		self.TPS = ticksPerSecond
		self.lastClock = 0
		self.currentClock = 0
	end
---<
--- TM Init Function ---
--- TM Type Function ---
--->
	function TickManager:__type()
		return "TickManager"
	end
---<
--- TM Init Function ---
--- Set TPS Function ---
--->
	function TickManager:setTPS(ticksPerSecond)
		self.TPS = ticksPerSecond
	end
---<
--- Set TPS Function ---
--- Get TPS Function ---
--->
	function TickManager:getTPS(ticksPerSecond)
		return self.TPS
	end
---<
--- Get TPS Function ---
--- TM Ready Function ---
--->
	function TickManager:isReady()
		self.currentClock = os.clock()
		if self.currentClock < self.lastClock + (1 / self.TPS) then return false end
		self.lastClock = self.currentClock
		return true
	end
---<
--- TM Ready Function ---
-- / FPS Manager Functions / --
if VIP_USER then
	-- / Lag Free Circles Functions / --
	--- Draw Cicle Next Level Function ---
	--->
		function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
			radius = radius or 300
			quality = math.max(8, round(180 / math.deg((math.asin((chordlength / (2 * radius)))))))
			quality = 2 * math.pi / quality
			radius = radius * .92
			local points = {}
			
			for theta = 0, 2 * math.pi + quality, quality do
				local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
				points[#points + 1] = D3DXVECTOR2(c.x, c.y)
			end
			
			DrawLines2(points, width or 1, color or 4294967295)
		end
	---<
	--- Draw Cicle Next Level Function ---
	--- Round Function ---
	--->
		function round(num) 
			if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
		end
	---<
	--- Round Function ---
	--- Draw Cicle 2 Function ---
	--->
		function DrawCircle2(x, y, z, radius, color)
			local vPos1 = Vector(x, y, z)
			local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
			local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
			local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
			
			if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
				DrawCircleNextLvl(x, y, z, radius, 1, color, WukongMenu.drawing.lfc.CL) 
			end
		end
	---<
	--- Draw Cicle 2 Function ---
	-- / Lag Free Circles Functions / --
end

-- / Checks Function / --
function Checks()
	--- Tick Manager Check ---
	--->
		if not TManager.onTick:isReady() and WukongMenu.misc.uTM then return end
	---<
	--- Tick Manager Check ---
	if VIP_USER then
		--- LFC Checks ---
		--->
			if not WukongMenu.drawing.lfc.LagFree then 
				_G.DrawCircle = _G.oldDrawCircle 
			else
				_G.DrawCircle = DrawCircle2
			end
		---<
		--- LFC Checks ---
	end
	--- Updates & Checks if Target is Valid ---
	--->
		TargetSelector:update()
		tsTarget = TargetSelector.target
		if tsTarget and tsTarget.type == "obj_AI_Hero" then
			Target = tsTarget
		else
			Target = nil
		end
	---<
	--- Updates & Checks if Target is Valid ---	
	--- Checks and finds Ignite ---
	--->
		if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
			ignite = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
			ignite = SUMMONER_2
		end
	---<
	--- Checks and finds Ignite ---
	--- Slots for Items ---
	--->
		rstSlot, ssSlot, swSlot, vwSlot =								GetInventorySlotItem(2045),
																		GetInventorySlotItem(2049),
																		GetInventorySlotItem(2044),
																		GetInventorySlotItem(2043)
		dfgSlot, hxgSlot, bwcSlot, brkSlot =							GetInventorySlotItem(3128),
																		GetInventorySlotItem(3146),
																		GetInventorySlotItem(3144),
																		GetInventorySlotItem(3153)
		Items.HealthPot.slot, Items.ManaPot.slot, Items.FlaskPot.slot =	GetInventorySlotItem(2003),
																		GetInventorySlotItem(2004),
																		GetInventorySlotItem(2041)
		znaSlot, wgtSlot, bftSlot =										GetInventorySlotItem(3157),
																		GetInventorySlotItem(3090),
																		GetInventorySlotItem(3188)
		tmtSlot, hdrSlot =												GetInventorySlotItem(3077),
																		GetInventorySlotItem(3074)
	---<
	--- Slots for Items ---
	--- Checks if Spells are Ready ---
	--->
		SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
		SkillW.ready = (myHero:CanUseSpell(_W) == READY)
		SkillE.ready = (myHero:CanUseSpell(_E) == READY)
		SkillR.ready = (myHero:CanUseSpell(_R) == READY)
		iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	---<
	--- Checks if Active Items are Ready ---
	--->
		dfgReady = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
		hxgReady = (hxgSlot ~= nil and myHero:CanUseSpell(hxgSlot) == READY)
		bwcReady = (bwcSlot ~= nil and myHero:CanUseSpell(bwcSlot) == READY)
		brkReady = (brkSlot ~= nil and myHero:CanUseSpell(brkSlot) == READY)
		znaReady = (znaSlot ~= nil and myHero:CanUseSpell(znaSlot) == READY)
		wgtReady = (wgtSlot ~= nil and myHero:CanUseSpell(wgtSlot) == READY)
		bftReady = (bftSlot ~= nil and myHero:CanUseSpell(bftSlot) == READY)
		tmtReady = (tmtSlot ~= nil and myHero:CanUseSpell(tmtSlot) == READY)
		hdrReady = (hdrSlot ~= nil and myHero:CanUseSpell(hdrSlot) == READY)
	---<
	--- Checks if Items are Ready ---
	--- Checks if Health Pots / Mana Pots are Ready ---
	--->
		Items.HealthPot.ready	= (Items.HealthPot.slot	~= nil and myHero:CanUseSpell(Items.HealthPot.slot)	== READY)
		Items.ManaPot.ready		= (Items.ManaPot.slot	~= nil and myHero:CanUseSpell(Items.ManaPot.slot)	== READY)
		Items.FlaskPot.ready	= (Items.FlaskPot.slot	~= nil and myHero:CanUseSpell(Items.FlaskPot.slot)	== READY)
	---<
	--- Checks if Health Pots / Mana Pots are Ready ---	
	--- Updates Minions ---
	--->
		enemyMinions:update()
	---<
	--- Updates Minions ---
	--- Setting Cast of Ult ---
	--->
		if GetTickCount() <= castDelay then castingUlt = true end
		if SkillQ.ready and SkillW.ready and SkillE.ready and not Target then castingUlt = false end
	---<
	--- Setting Cast of Ult ---
end
-- / Checks Function / --

-- / isLow Function / --
function isLow(Name)
	--- Check Zhonya/Wooglets HP ---
	--->
		if Name == 'Zhonya' or Name == 'Wooglets' then
			if (myHero.health / myHero.maxHealth) <= (WukongMenu.misc.ZWHealth / 100) then
				return true
			else
				return false
			end
		end
	---<
	--- Check Zhonya/Wooglets HP ---
	--- Check Potions HP ---
	--->
		if Name == 'Health' then
			if (myHero.health / myHero.maxHealth) <= (WukongMenu.misc.pHealth / 100) then
				return true
			else
				return false
			end
		end
	---<
	--- Check Potions HP ---
	--- Check Potions MP ---
	--->
		if Name == 'Mana' then
			if (myHero.mana / myHero.maxMana) <= (WukongMenu.misc.pMana / 100) then
				return true
			else
				return false
			end
		end
	---<
	--- Check Potions MP ---
end
-- / isLow Function / --
