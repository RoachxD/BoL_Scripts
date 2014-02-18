--[[


			d8888b.  .d8b.  d8b   db d888888b db   db d88888b  .d88b.  d8b   db 
			88  `8D d8' `8b 888o  88 `~~88~~' 88   88 88'     .8P  Y8. 888o  88 
			88oodD' 88ooo88 88V8o 88    88    88ooo88 88ooooo 88    88 88V8o 88 
			88~~~   88~~~88 88 V8o88    88    88~~~88 88~~~~~ 88    88 88 V8o88 
			88      88   88 88  V888    88    88   88 88.     `8b  d8' 88  V888 
			88      YP   YP VP   V8P    YP    YP   YP Y88888P  `Y88P'  VP   V8P


		Script - Pantheon - The Artisan of War 3.0.1 by Roach

		Dependency / Requirements: 
			- AoE Skillshot Position

		Changelog:
			3.0.1
				- Fixed Ult Spamming Errors
				- Added new Ultimate Logics
				- Added Ultimate Delay for AoE Skillshot Position
				- Added Tiamat / Hydra usage in the Clearing Option
				- Removed some useless stuff
			3.0
				- Added MEC for Ultimate
				- Removed Escape Artist
				- Added permaShow to 'mecUlt'
				- Changed TargetSelector mode to 'TARGET_LESS_CAST_PRIORITY'
				- Fixed Ultimate Canceling Bug
				- Fixed Consumables
				- Added Tiamat and Hydra on the Items List
				- Addded two harass modes: Q & W+E
				- Fixed spamming errors
				- Improved Combo Combination
				- No longer AutoCarry Script
				- Rewrote everything
				- Combo Reworked: Should be a lot smoother now
				- Harass Reworked: Should work better
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
			2.3
				Fixed Auto-Pots Problem
				Hopefully fixed AutoE Bug
				
			2.2
				Improved combo function
				Fixed Harass Function
				Rewrote Low Checks Functions
				Added a new Check for Mana Potions
					- One for Harass/Farm
					- One for Potions
				Deleted Wooglets Support as an Usable Item
				
			2.1
				Fixed Auto Potions
				Changed Min Mana Display in Menu
				Removed Auto Spell Leveler from Menu as it's not done yet
			
			2.0
				Added a Toggle for for Core Combo
				Added an Extra Menu
				Added Customizable Chase Combo
				Added Farm with Q
				Added Lane Clear with E
				Added Auto Pots/Items
				Added Minimum Mana to Harass/Farm - Check
				Modified Menu - More customizable
				Modified KS only with Q
				Modified Harass - Working with Mixed Mode
				Optimised Chase Combo
				Rewrited some Functions
				-- Fully Optimised the Script
				
			1.6
				Added Chase Combo
				Fixed a bug where E was not casting
				Changed Plugin Menu
				Added a Mini-Menu
				Fixed "Draw Crit Text"
		
			1.5
				Auto combo after Ultimate. (With a check!)
				Toggle for Auto Q Harass when in enemy range , with a mana check. (You will harass them until you'll have Mana for one last Combo)
		
			1.4
				Optimised Escape Artist
				Optimised Killsteal(You can KS with Q+W)
				Fixed Ultimate Bugsplat(TESTED)
				Fixed Mixed Mode Harass
				Re-wrote majority of the Functions
				Hopefully fixed DCT(Draw Critical Text)
				Changed Circle's Color(Range Circle)
				Speeded-Up the Script(Some FPS Drops on Escape Artist and Ultimate)
				
			1.3
				Fixed Escape Artist
				Fixed a problem with Flash, it was flashing before Stunning the enemy
				Optimised Escape Artist
				Fully removed Auto-Ignite
				Fixed all the Bugsplats (TESTED)
				Hopefully fixed Mixed Mode Harass
				
			1.2
				Real fix for E.
				Fixed Killsteal.
				Hopefully fixed OnTick bugsplat.
				Removed Auto-Ignite, because it exists in SAC too.
			
			1.1
				Temporarily fix for E.
				Fixed some bugsplats on draw.
			
			1.0
				First release
			
--]]

-- / Hero Name Check / --
if myHero.charName ~= "Pantheon" then return end
-- / Hero Name Check / --

-- / Loading Function / --
function OnLoad()
	--->
		require "AoE_Skillshot_Position"
		
		Variables()
		PanthMenu()
		PrintChat("<font color='#FF0000'> >> Pantheon - The Artisan of War 3.0.1 Loaded <<</font>")
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
			if PanthMenu.harass.qharass and not isChanneling("Spell3") then CastQ(Target) end
			if PanthMenu.killsteal.Ignite then AutoIgnite(Target) end
		end
	---<
	-- Menu Variables --
	--->
		ComboKey =     PanthMenu.combo.comboKey
		FarmingKey =   PanthMenu.farming.farmKey
		HarassKey =    PanthMenu.harass.harassKey
		ClearKey =     PanthMenu.clear.clearKey
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
		if PanthMenu.killsteal.smartKS then KillSteal() end
	---<
end
-- / Tick Function / --

-- / Variables Function / --
function Variables()
	--- Skills Vars --
	--->
		SkillQ = {range = 600,		name = "Spear Shot",			ready = false, color = ARGB(255,178, 0 , 0 )				}
		SkillW = {range = 600,		name = "Aegis of Zeonia",		ready = false, color = ARGB(255, 32,178,170)				}
		SkillE = {range = 300,		name = "Heartseeker Strike",	ready = false, color = ARGB(255,128, 0 ,128)				}
		SkillR = {range = 5500,		name = "Grand Skyfall",			ready = false								, MecPos = nil	}
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
		TextList = {"Harass him", "Q = Kill", "W = Kill!", "W+E = Kill", "Q+W+E = Kill", "Q+W+E+Itm = Kill", "Need CDs"}
		KillText = {}
		colorText = ARGB(255,255,204,0)
	---<
	--- Drawing Vars ---
	--- Misc Vars ---
	--->
		Items.HealthPot.inUse = false
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
function PanthMenu()
	--- Main Menu ---
	--->
		PanthMenu = scriptConfig("Pantheon - The Artisan of War", "Pantheon")
		---> Combo Menu
		PanthMenu:addSubMenu("["..myHero.charName.." - Combo Settings]", "combo")
			PanthMenu.combo:addParam("comboKey", "Full Combo Key (X)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
			PanthMenu.combo:addParam("mecUlt", "Use MEC for "..SkillR.name.." (R)", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.combo:addParam("amecUlt", "MEC Amount with "..SkillR.name.." (R)",SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
			PanthMenu.combo:addParam("comboItems", "Use Items with Burst", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.combo:addParam("comboOrbwalk", "Orbwalk in Combo", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.combo:permaShow("comboKey")
			PanthMenu.combo:permaShow("mecUlt")
		---<
		---> Harass Menu
		PanthMenu:addSubMenu("["..myHero.charName.." - Harass Settings]", "harass")
			PanthMenu.harass:addParam("hMode", "Harass Mode",SCRIPT_PARAM_SLICE, 1, 1, 2, 0)
			PanthMenu.harass:addParam("harassKey", "Harass Hotkey (T)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
			PanthMenu.harass:addParam("qharass", "Always "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.harass:addParam("mTmH", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.harass:permaShow("harassKey")
		---<
		---> Farming Menu
		PanthMenu:addSubMenu("["..myHero.charName.." - Farming Settings]", "farming")
			PanthMenu.farming:addParam("farmKey", "Farming ON/Off (Z)", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey("Z"))
			PanthMenu.farming:addParam("qFarm", "Farm with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.farming:addParam("wFarm", "Farm with "..SkillE.name.." (W)", SCRIPT_PARAM_ONOFF, false)
			PanthMenu.farming:permaShow("farmKey")
		---<
		---> Clear Menu		
		PanthMenu:addSubMenu("["..myHero.charName.." - Clear Settings]", "clear")
			PanthMenu.clear:addParam("clearKey", "Jungle/Lane Clear Key (V)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
			PanthMenu.clear:addParam("JungleFarm", "Use Skills to Farm Jungle", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.clear:addParam("ClearLane", "Use Skills to Clear Lane", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.clear:addParam("clearQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.clear:addParam("clearW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.clear:addParam("clearE", "Clear with "..SkillE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.clear:addParam("clearOrbM", "OrbWalk Minions", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.clear:addParam("clearOrbJ", "OrbWalk Jungle", SCRIPT_PARAM_ONOFF, true)
		---<
		---> KillSteal Menu
		PanthMenu:addSubMenu("["..myHero.charName.." - KillSteal Settings]", "killsteal")
			PanthMenu.killsteal:addParam("smartKS", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.killsteal:addParam("itemsKS", "Use Items to KS", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.killsteal:addParam("Ignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.killsteal:permaShow("smartKS")
		---<
		---> Drawing Menu			
		PanthMenu:addSubMenu("["..myHero.charName.." - Drawing Settings]", "drawing")
			if VIP_USER then
				PanthMenu.drawing:addSubMenu("["..myHero.charName.." - LFC Settings]", "lfc")
					PanthMenu.drawing.lfc:addParam("LagFree", "Activate Lag Free Circles", SCRIPT_PARAM_ONOFF, false)
					PanthMenu.drawing.lfc:addParam("CL", "Length before Snapping", SCRIPT_PARAM_SLICE, 300, 75, 2000, 0)
					PanthMenu.drawing.lfc:addParam("CLinfo", "Higher length = Lower FPS Drops", SCRIPT_PARAM_INFO, "")
			end
			PanthMenu.drawing:addParam("disableAll", "Disable All Ranges Drawing", SCRIPT_PARAM_ONOFF, false)
			PanthMenu.drawing:addParam("drawText", "Draw Enemy Text", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.drawing:addParam("drawTargetText", "Draw Who I'm Targetting", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.drawing:addParam("drawQ", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.drawing:addParam("drawW", "Draw "..SkillW.name.." (W) Range", SCRIPT_PARAM_ONOFF, false)
			PanthMenu.drawing:addParam("drawE", "Draw "..SkillE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		---<
		---> Misc Menu	
		PanthMenu:addSubMenu("["..myHero.charName.." - Misc Settings]", "misc")
			PanthMenu.misc:addParam("ZWItems", "Auto Zhonyas/Wooglets", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.misc:addParam("ZWHealth", "Min Health % for Zhonyas/Wooglets", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)
			PanthMenu.misc:addParam("aHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.misc:addParam("pHealth", "Min % for Health Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
			PanthMenu.misc:addParam("aMP", "Auto Mana Pots", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.misc:addParam("pMana", "Min % for Mana Pots", SCRIPT_PARAM_SLICE, 35, 0, 100, -1)
			PanthMenu.misc:addParam("uTM", "Use Tick Manager/FPS Improver (Requires Reload)",SCRIPT_PARAM_ONOFF, false)
		---<
		---> Target Selector		
			TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, SkillR.range, DAMAGE_PHYSICAL)
			TargetSelector.name = "Pantheon"
			PanthMenu:addTS(TargetSelector)
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
		if not isChanneling("Spell3") and (not isChanneling("Ult_A") and not isChanneling("Ult_B") and not isChanneling("Ult_C") and not isChanneling("Ult_D") and not isChanneling("Ult_E")) then
			if Target then
				if PanthMenu.combo.comboOrbwalk then
					OrbWalking(Target)
				end
				if PanthMenu.combo.comboItems then
					UseItems(Target)
				end
			
				CastQ(Target)
				CastW(Target)
				if not Target.canMove or GetDistance(Target) < 175 then
					CastE(Target)
				end
				if PanthMenu.combo.mecUlt then
					if SkillR.MecPos ~= nil and CountEnemyHeroInRange(SkillR.MecPos, myHero) >= PanthMenu.combo.amecUlt then
						CastSpell(_R, SkillR.MecPos.x, SkillR.MecPos.z)
					end
				end
			else
				if PanthMenu.combo.comboOrbwalk then
					moveToCursor()
				end
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
		if PanthMenu.harass.mTmH then
			moveToCursor()
		end
		if Target then
			--- Harass Mode 1 Q ---
			if PanthMenu.harass.hMode == 1 then
				if PanthMenu.harass.wEscape then
					if SkillQ.ready then
						CastQ(Target)
					end
				end
			end
			--- Harass Mode 1 ---
			--- Harass Mode 2 W+E ---
			if PanthMenu.harass.hMode == 2 then
				if PanthMenu.harass.wEscape then
					if SkillW.ready then
						CastW(Target)
						if not SkillW.ready then CastE(Target) end
					end
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
			local eMinionDmg	= getDmg("W",  minion, myHero)
			local aaMinionDmg	= getDmg("AD", minion, myHero)
			--- Minion Damages ---
			--- Minion Keys ---
			local qFarmKey = PanthMenu.farming.qFarm
			local WFarmKey = PanthMenu.farming.wFarm
			--- Minion Keys ---
			--- Farming Minions ---
			if ValidTarget(minion) then
				if GetDistance(minion) <= SkillQ.range then
					if qFarmKey and wFarmKey then
						if SkillQ.ready and SkillW.ready then
							if minion.health <= (wMinionDmg + qMinionDmg) and minion.health > qMinionDmg then
								CastW(minion)
								CastQ(minion)
							end
						elseif SkillW.ready and not SkillQ.ready then
							if minion.health <= (wMinionDmg) then
								CastW(minion)
							end
						elseif SkillQ.ready and not SkillW.ready then
							if minion.health <= (qMinionDmg) then
								CastQ(minion)
							end
						elseif GetDistance(minion) <= myHero.range and not SkillQ.ready and not SkillW.ready then
							if minion.health <= aaMinionDmg then
								myHero:Attack(minion)
							end
						end
					elseif qFarmKey and not wFarmKey then
						if SkillQ.ready then
							if minion.health <= (qMinionDmg) then
								CastQ(minion)
							end
						elseif GetDistance(minion) <= myHero.range and not SkillQ.ready then
							if minion.health <= aaMinionDmg then
								myHero:Attack(minion)
							end
						end
					end
				elseif (GetDistance(minion) > SkillQ.range) and (GetDistance(minion) <= SkillW.range) then
					if wFarmKey then
						if minion.health <= wMinionDmg then
							CastW(minion)
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
	--- Jungle Clear ---
	--->
		if PanthMenu.clear.JungleFarm then
			local JungleMob = GetJungleMob()
			if JungleMob ~= nil then
				if PanthMenu.clear.clearOrbJ then
					OrbWalking(JungleMob)
				end
				if PanthMenu.clear.clearQ and SkillQ.ready and GetDistance(JungleMob) <= SkillQ.range then
					CastQ(JungleMob)
				end
				if PanthMenu.clear.clearW and SkillW.ready and GetDistance(JungleMob) <= SkillW.range then
					CastW(JungleMob)
				end
				if PanthMenu.clear.clearE and SkillE.ready and GetDistance(JungleMob) <= SkillE.range then
					CastE(JungleMob)
				end
				if tmtReady and GetDistance(JungleMob) <= 185 then CastSpell(tmtSlot) end
				if hdrReady and GetDistance(JungleMob) <= 185 then CastSpell(hdrSlot) end
			else
				if PanthMenu.clear.clearOrbJ then
					moveToCursor()
				end
			end
		end
	---<
	--- Jungle Clear ---
	--- Lane Clear ---
	--->
		if PanthMenu.clear.ClearLane then
			for _, minion in pairs(enemyMinions.objects) do
				if  ValidTarget(minion) then
					if PanthMenu.clear.clearOrbM then
						OrbWalking(minion)
					end
					if PanthMenu.clear.clearQ and SkillQ.ready and GetDistance(minion) <= SkillQ.range then
						CastQ(minion)
					end
					if PanthMenu.clear.clearW and SkillW.ready and GetDistance(minion) <= SkillW.range then
						CastW(minion)
					end
					if PanthMenu.clear.clearE and SkillE.ready and GetDistance(minion) <= SkillE.range then 
						CastE(minion)
					end
					if tmtReady and GetDistance(minion) <= 185 then CastSpell(tmtSlot) end
					if hdrReady and GetDistance(minion) <= 185 then CastSpell(hdrSlot) end
				else
					if PanthMenu.clear.clearOrbM then
						moveToCursor()
					end
				end
			end
		end
	---<
	--- Lane Clear ---
end
-- / Clear Function / --

-- / Casting Q Function / --
function CastQ(enemy)
	--- Dynamic Q Cast ---
	--->
		if not SkillQ.ready or GetDistance(enemy) > SkillQ.range then
			return false
		end
		if ValidTarget(enemy) then 
			if VIP_USER then
				Packet("S_CAST", {spellId = _Q, targetNetworkId = enemy.networkID}):send()
				return true
			else
				CastSpell(_Q, enemy)
				return true
			end
		end
		return false
	---<
	--- Dynamic Q Cast ---
end
-- / Casting Q Function / --

-- / Casting W Function / --
function CastW(enemy)
	--- Dynamic W Cast ---
	--->
		if not SkillW.ready or (GetDistance(enemy) > SkillW.range) then
			return
		end
		if ValidTarget(enemy) then 
			if VIP_USER then
				Packet("S_CAST", {spellId = _W, targetNetworkId = enemy.networkID}):send()
				return true
			else
				CastSpell(_W, enemy)
				return true
			end
		end
		return false
	---<
	--- Dynamic W Cast ---
end
-- / Casting W Function / --

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
		if PanthMenu.misc.ZWItems and isLow('Wooglets') and Target and (znaReady or wgtReady) then
			CastSpell((wgtSlot or znaSlot))
		end
	---<
	--- Check if Zhonya/Wooglets Needed --
	--- Check if HP Potions Needed --
	--->
		if PanthMenu.misc.aHP and isLow('Health') and not Items.HealthPot.inUse and (Items.HealthPot.ready or Items.FlaskPot.ready) then
			CastSpell((Items.HealthPot.slot or Items.FlaskPot.slot))
		end
	---<
	--- Check if HP Potions Needed --
	--- Check if MP Potions Needed --
	--->
		if PanthMenu.misc.aMP and isLow('Mana') and not Items.ManaPot.inUse and (Items.ManaPot.ready or Items.FlaskPot.ready) then
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
				dfgDmg, bftDmg, hxgDmg, bwcDmg, tmtDmg, hdrDmg, iDmg = 0, 0, 0, 0, 0, 0, 0
				qDmg =		(SkillQ.ready and	getDmg("Q",			enemy, myHero)		or 0)
				wDmg =		(SkillW.ready and	getDmg("W",			enemy, myHero)		or 0)
				eDmg =		(SkillE.ready and	getDmg("E",			enemy, myHero, 3)	or 0)
            	rDmg =		(SkillR.ready and	getDmg("R",			enemy, myHero)		or 0)
				dfgDmg =	(dfgSlot and		getDmg("DFG",		enemy, myHero)		or 0)
				bftdmg =	(bftSlot and		getDmg("BLACKFIRE",	enemy, myHero)		or 0)
        	    hxgDmg =	(hxgSlot and		getDmg("HXG",		enemy, myHero)		or 0)
            	bwcDmg =	(bwcSlot and		getDmg("BWC",		enemy, myHero)		or 0)
				tmtDmg =	(tmtSlot and		getDmg("TIAMAT",	enemy, myHero)		or 0)
				hdrDmg =	(tmtSlot and		getDmg("HYDRA",		enemy, myHero)		or 0)
            	iDmg =		(ignite and			getDmg("IGNITE",	enemy, myHero)		or 0)
				
            	onspellDmg = bftDmg
            	itemsDmg = dfgDmg + hxgDmg + bwcDmg + tmtDmg + hdrDmg + iDmg + onspellDmg
    ---<
    --- Calculate our Damage On Enemies ---
    --- Setting KillText Color & Text ---
    --->
    			if enemy.health > (qDmg + eDmg + wDmg + itemsDmg) then
    				KillText[i] = 1
				elseif enemy.health <= qDmg then
					if SkillQ.ready then
						KillText[i] = 2
					else
						KillText[i] = 7
					end
				elseif enemy.health <= wDmg then
					if SkillW.ready then
						KillText[i] = 3
					else
						KillText[i] = 7
					end
				elseif enemy.health <= (wDmg + eDmg) and SkillW.ready and SkillE.ready then
					if SkillW.ready and SkillE.ready then
						KillText[i] = 4
					else
						KillText[i] = 7
					end
				elseif enemy.health <= (qDmg + wDmg + eDmg) and SkillQ.ready and SkillW.ready and SkillE.ready then
					if SkillQ.ready and SkillW.ready and SkillE.ready then
						KillText[i] = 5
					else
						KillText[i] = 7
					end
				elseif (enemy.health <= (qDmg + wDmg + eDmg + itemsDmg) or enemy.health <= (qDmg + wDmg + eDmg + itemsDmg)) and SkillQ.ready and SkillW.ready and SkillE.ready then
					if SkillQ.ready and SkillW.ready and SkillE.ready then
						KillText[i] = 6
					else
						KillText[i] = 7
					end
				end
			end
		end
	---<
	--- Setting KillText Color & Text ---
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
			elseif health <= wDmg and SkillW.ready and (distance < SkillW.range) then
				CastW(Target)
			elseif health <= (qDmg + wDmg) and SkillQ.ready and SkillW.ready and (distance < SkillW.range) then
				CastQ(Target)
				CastW(Target)
			elseif PanthMenu.killsteal.itemsKS then
				if health <= (qDmg + wDmg + itemsDmg) and health > (qDmg + wDmg) then
					if SkillQ.ready and SkillW.ready then
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
    	if unit.isMe and lastAnimation ~= animationName then 
			lastAnimation = animationName
		end
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

-- / On Send Packet Function / --
function OnSendPacket(packet)
	-- Block Packets if Channeling --
	--->
		for _, enemy in pairs(enemyHeroes) do
			if isChanneling("Spell3") then
				local packet = Packet(packet)
				if packet:get('name') == 'S_MOVE' or packet:get('name') == 'S_CAST' and packet:get('sourceNetworkId') == myHero.networkID then
					if enemy and GetDistance(enemy) < SkillE.range then
						packet:block()
					end
				end
			end
		end
	---<
	--- Block Packets if Channeling --
end
-- / On Send Packet Function / --

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
		if not TManager.onDraw:isReady() and PanthMenu.misc.uTM then return end
	---<
	--->
	--- Drawing Our Ranges ---
	--->
		if not myHero.dead then
			if not PanthMenu.drawing.disableAll then
				if SkillQ.ready and PanthMenu.drawing.drawQ then 
					DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, SkillQ.color)
				end
				if SkillW.ready and PanthMenu.drawing.drawW then
					DrawCircle(myHero.x, myHero.y, myHero.z, SkillW.range, SkillW.color)
				end
				if SkillE.ready and PanthMenu.drawing.drawE then
					DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, SkillE.color)
				end
			end
		end
	---<
	--- Drawing Our Ranges ---
	--- Draw Enemy Target ---
	--->
		if Target then
			if PanthMenu.drawing.drawTargetText and GetDistance(Target) <= SkillQ.range then
				DrawText("Targeting: " .. Target.charName, 12, 100, 100, colorText)
			end
		end
	---<
	--- Draw Enemy Target ---
		if PanthMenu.drawing.drawText then
			for i = 1, heroManager.iCount do
        		local enemy = heroManager:GetHero(i)
        		if ValidTarget(enemy) then
        			local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z)) --(Credit to Zikkah)
					local PosX = barPos.x - 35
					local PosY = barPos.y - 10
					
					DrawText(TextList[KillText[i]], 16, PosX, PosY, colorText)
				end
			end
		end
end
-- / Plugin On Draw / --

-- / OrbWalking Functions / --
--- Orbwalking Target ---
--->
	function OrbWalking(Target)
		if not isChanneling("Spell3") then
			if TimeToAttack() and GetDistance(Target) <= myHero.range + GetDistance(myHero.minBBox) then
				myHero:Attack(Target)
			elseif heroCanMove() then
				moveToCursor()
			end
		else
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
		if GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
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
			if not TManager.onSpell:isReady() and PanthMenu.misc.uTM then return end
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
				DrawCircleNextLvl(x, y, z, radius, 1, color, PanthMenu.drawing.lfc.CL) 
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
		if not TManager.onTick:isReady() and PanthMenu.misc.uTM then return end
	---<
	--- Tick Manager Check ---
	if VIP_USER then
		--- LFC Checks ---
		--->
			if not PanthMenu.drawing.lfc.LagFree then 
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
		if tsTarget and tsTarget.type == "obj_AI_Hero" and GetDistance(tsTarget) <= SkillQ.range then
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
	--- Setting Spells ---
	--->
		if SkillR.ready and Target then
			SkillR.MecPos = GetAoESpellPosition(700, tsTarget, 350)
		else
			SkillR.MecPos = nil
		end
	---<
	--- Setting Spells ---
end
-- / Checks Function / --

-- / isLow Function / --
function isLow(Name)
	--- Check Zhonya/Wooglets HP ---
	--->
		if Name == 'Zhonya' or Name == 'Wooglets' then
			if (myHero.health / myHero.maxHealth) <= (PanthMenu.misc.ZWHealth / 100) then
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
			if (myHero.health / myHero.maxHealth) <= (PanthMenu.misc.pHealth / 100) then
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
			if (myHero.mana / myHero.maxMana) <= (PanthMenu.misc.pMana / 100) then
				return true
			else
				return false
			end
		end
	---<
	--- Check Potions MP ---
end
-- / isLow Function / --
