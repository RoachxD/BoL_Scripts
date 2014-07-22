local version = "4.133"
--[[


			d8888b.  .d8b.  d8b   db d888888b db   db d88888b  .d88b.  d8b   db 
			88  `8D d8' `8b 888o  88 `~~88~~' 88   88 88'     .8P  Y8. 888o  88 
			88oodD' 88ooo88 88V8o 88    88    88ooo88 88ooooo 88    88 88V8o 88 
			88~~~   88~~~88 88 V8o88    88    88~~~88 88~~~~~ 88    88 88 V8o88 
			88      88   88 88  V888    88    88   88 88.     `8b  d8' 88  V888 
			88      YP   YP VP   V8P    YP    YP   YP Y88888P  `Y88P'  VP   V8P


		Script - Pantheon - The Artisan of War 4.1 by Roach

		Dependency / Requirements: 
			- Nothing

		Changelog:
			4.1
				- Fixed Items interrupting E and Ult
				- Improved Performance
				- Fixed Jungle Clear

			4.0
				- Re-wrote the whole Script
				- Added a lot of features
				- Removed Auto-Pots
				- Added SOW as main Orbwalker
				- Added Auto-Q Harass
				- Added an option to not to Auto-Q in Enemy Turret Range
				- Fixed Turret Range Function
				- Fixed E before W Bug
				- Added AA Range on Draw
				- Fixed 'InTurretRange' Function
				- Fixed Spamming Errors
				- Fixed Spamming Errors (after re-load)
				- Added a check to Enable/Disable myHero.range in the Draw Menu
				- Added an Option to see who are you Targeting

			3.3
				- Added Support for SAC Target Selector
				- Fixed MMA Breaking E / Ult Channeling
				- Added Summoner Spells as an Exception at Blocking Packets while Panth is Channeling E / Ult (VIP USERS)
				- Changed Harass Menu
				- Indented better the Script
				- Improved Orbwalker
			3.2
				- Removed MEC Ult (because many people cast Ult Manually and it was causing me some problems)
				- Added new logics for Packets and Orbwalker regarding Ult
				- Fixed Harass Combo
				- Added Mana Check for Farming
				- Added Mana Check for Mixed Clear
				- Added Last Hitter
				- Added Orbwalker to Harass
				- Added Auto-Updater
				- Added Anti-E / Anti-Ult Breaking for MMA / SAC
				- Fixed Auto-Updater
				- Fixed MMA Blocking Issues for Free Users
				- Added Support for MMA Target Selector
			3.1
				- Fixed Ult Spamming Errors
				- Added new Ultimate Logics
				- Added Ultimate Delay for AoE Skillshot Position
				- Added Tiamat / Hydra usage in the Clearing Option
				- Removed some useless stuff
				- Removed MEC Ult (because many people cast Ult Manually and it was causing me some problems)
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
				- Fixed Auto-Pots Problem
				- Hopefully fixed AutoE Bug
				
			2.2
				- Improved combo function
				- Fixed Harass Function
				- Rewrote Low Checks Functions
				- Added a new Check for Mana Potions
					- One for Harass/Farm
					- One for Potions
				- Deleted Wooglets Support as an Usable Item
				
			2.1
				- Fixed Auto Potions
				- Changed Min Mana Display in Menu
				- Removed Auto Spell Leveler from Menu as it's not done yet
			
			2.0
				- Added a Toggle for for Core Combo
				- Added an Extra Menu
				- Added Customizable Chase Combo
				- Added Farm with Q
				- Added Lane Clear with E
				- Added Auto Pots/Items
				- Added Minimum Mana to Harass/Farm - Check
				- Modified Menu - More customizable
				- Modified KS only with Q
				- Modified Harass - Working with Mixed Mode
				- Optimised Chase Combo
				- Rewrited some Functions
				-- Fully Optimised the Script
				
			1.6
				- Added Chase Combo
				- Fixed a bug where E was not casting
				- Changed Plugin Menu
				- Added a Mini-Menu
				- Fixed "Draw Crit Text"
		
			1.5
				- Auto combo after Ultimate. (With a check!)
				- Toggle for Auto Q Harass when in enemy range , with a mana check. (You will harass them until you'll have Mana for one last Combo)
		
			1.4
				- Optimised Escape Artist
				- Optimised Killsteal(You can KS with Q+W)
				- Fixed Ultimate Bugsplat(TESTED)
				- Fixed Mixed Mode Harass
				- Re-wrote majority of the Functions
				- Hopefully fixed DCT(Draw Critical Text)
				- Changed Circle's Color(Range Circle)
				- Speeded-Up the Script(Some FPS Drops on Escape Artist and Ultimate)
				
			1.3
				- Fixed Escape Artist
				- Fixed a problem with Flash, it was flashing before Stunning the enemy
				- Optimised Escape Artist
				- Fully removed Auto-Ignite
				- Fixed all the Bugsplats (TESTED)
				- Hopefully fixed Mixed Mode Harass
				
			1.2
				- Real fix for E.
				- Fixed Killsteal.
				- Hopefully fixed OnTick bugsplat.
				- Removed Auto-Ignite, because it exists in SAC too.
			
			1.1
				- Temporarily fix for E.
				- Fixed some bugsplats on draw.
			
			1.0
				- First release
			
--]]

if myHero.charName ~= "Pantheon" then return end

_G.Panth_Autoupdate = true

local REQUIRED_LIBS = {
	["SOW"]			= "https://raw.githubusercontent.com/honda7/BoL/master/Common/SOW.lua",
	["VPrediction"] = "https://raw.githubusercontent.com/honda7/BoL/master/Common/VPrediction.lua"
}

local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<font color=\"#FF0000\">Pantheon - The Artisan of War:</font> <font color=\"#FFFFFF\">Required libraries downloaded successfully, please reload (double F9).</font>")
	end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

if DOWNLOADING_LIBS then return end

local UPDATE_NAME = "Pantheon - The Artisan of War"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/RoachxD/BoL_Scripts/master/Pantheon%20-%20The%20Artisan%20of%20War.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..UPDATE_NAME..".lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#FF0000\">"..UPDATE_NAME..":</font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.Panth_Autoupdate then
	local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
	if ServerData then
		local ServerVersion = string.match(ServerData, "local version = \"%d+.%d+\"")
		ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
		if ServerVersion then
			ServerVersion = tonumber(ServerVersion)
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end)	 
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

function OnLoad()
	Variables()
	Menu()

	HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
	UpdateWeb(true, 5)

	if heroManager.iCount < 10 then -- borrowed from Sidas Auto Carry, modified to 3v3
			AutoupdaterMsg("Too few champions to arrange priorities")
	elseif heroManager.iCount == 6 and TTMAP then
		ArrangeTTPriorities()
	else
		ArrangePriorities()
	end
end

function OnUnload()
	UpdateWeb(false, 5)
end

function OnTick()
	ComboKey		= PanthMenu.combo.comboKey
	HarassKey		= PanthMenu.harass.harassKey
	FarmKey			= PanthMenu.farming.farmKey
	JungleClearKey	= PanthMenu.jungle.jungleKey

	if ComboKey then
		Combo(Target)
	end
	if HarassKey then
		Harass(Target)
	end
	if FarmKey then
		Farm()
	end
	if JungleClearKey then
		JungleClear()
	end

	if PanthMenu.harass.autoQ then
		if (PanthMenu.harass.aQT and not InEnemyTurretRange(myHero)) or not PanthMenu.harass.aQT then
			CastQ(Target)
		end
	end

	if PanthMenu.ks.killSteal then
		KillSteal()
	end
	
	if PanthMenu.misc.ultAlert.Enable then
		GetKillable()
	end

	TickChecks()
end

function Variables()
	if GetGame().map.shortName == "twistedTreeline" then
		TTMAP = true
	else
		TTMAP = false
	end

	SpellQ = {name = "Spear Shot",			range =  600, ready = false, dmg = 0, manaUsage = 0				   }
	SpellW = {name = "Aegis of Zeonia",		range =  600, ready = false, dmg = 0, manaUsage = 0				   }
	SpellE = {name = "Heartseeker Strike",	range =  700, ready = false, dmg = 0, manaUsage = 0				   }
	SpellR = {name = "Grand Skyfall",		range = 5500, ready = false, dmg = 0, manaUsage = 0				   }

	SpellI = {name = "SummonerDot",			range =  600, ready = false, dmg = 0,				variable = nil }

	vPred = VPrediction()

	pSOW = SOW(vPred)

	enemyMinions	= minionManager(MINION_ENEMY,	SpellQ.range, myHero.visionPos, MINION_SORT_HEALTH_ASC)

	JungleMobs = {}
	JungleFocusMobs = {}

	priorityTable = {
			AP = {
				"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
				"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
				"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra"
			},
			Support = {
				"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean"
			},
			Tank = {
				"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
				"Warwick", "Yorick", "Zac"
			},
			AD_Carry = {
				"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
				"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo","Zed"
			},
			Bruiser = {
				"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
				"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
			}
		}

	InterruptingSpells = {
		["AbsoluteZero"]				= true,
		["AlZaharNetherGrasp"]			= true,
		["CaitlynAceintheHole"]			= true,
		["Crowstorm"]					= true,
		["DrainChannel"]				= true,
		["FallenOne"]					= true,
		["GalioIdolOfDurand"]			= true,
		["InfiniteDuress"]				= true,
		["KatarinaR"]					= true,
		["MissFortuneBulletTime"]		= true,
		["Teleport"]					= true,
		["Pantheon_GrandSkyfall_Jump"]	= true,
		["ShenStandUnited"]				= true,
		["UrgotSwap2"]					= true
	}
	AnimationList = {
		["Spell3"]	= true,
		["Ult_A"]	= true,
		["Ult_B"]	= true,
		["Ult_C"]	= true,
		["Ult_D"]	= true,
		["Ult_E"]	= true
	}

	Items = {
		["BLACKFIRE"]	= { id = 3188, range = 750 },
		["BRK"]			= { id = 3153, range = 500 },
		["BWC"]			= { id = 3144, range = 450 },
		["DFG"]			= { id = 3128, range = 750 },
		["HXG"]			= { id = 3146, range = 700 },
		["ODYNVEIL"]	= { id = 3180, range = 525 },
		["DVN"]			= { id = 3131, range = 200 },
		["ENT"]			= { id = 3184, range = 350 },
		["HYDRA"]		= { id = 3074, range = 350 },
		["TIAMAT"]		= { id = 3077, range = 350 },
		["YGB"]			= { id = 3142, range = 350 }
	}

	if TTMAP then --
		FocusJungleNames = {
			["TT_NWraith1.1.1"]		= true,
			["TT_NGolem2.1.1"]		= true,
			["TT_NWolf3.1.1"]		= true,
			["TT_NWraith4.1.1"]		= true,
			["TT_NGolem5.1.1"]		= true,
			["TT_NWolf6.1.1"]		= true,
			["TT_Spiderboss8.1.1"]	= true
		}		
		JungleMobNames = {
			["TT_NWraith21.1.2"]	= true,
			["TT_NWraith21.1.3"]	= true,
			["TT_NGolem22.1.2"]		= true,
			["TT_NWolf23.1.2"]		= true,
			["TT_NWolf23.1.3"]		= true,
			["TT_NWraith24.1.2"]	= true,
			["TT_NWraith24.1.3"]	= true,
			["TT_NGolem25.1.1"]		= true,
			["TT_NWolf26.1.2"]		= true,
			["TT_NWolf26.1.3"]		= true
		}
	else 
		JungleMobNames = { 
			["Wolf8.1.2"]			= true,
			["Wolf8.1.3"]			= true,
			["YoungLizard7.1.2"]	= true,
			["YoungLizard7.1.3"]	= true,
			["LesserWraith9.1.3"]	= true,
			["LesserWraith9.1.2"]	= true,
			["LesserWraith9.1.4"]	= true,
			["YoungLizard10.1.2"]	= true,
			["YoungLizard10.1.3"]	= true,
			["SmallGolem11.1.1"]	= true,
			["Wolf2.1.2"]			= true,
			["Wolf2.1.3"]			= true,
			["YoungLizard1.1.2"]	= true,
			["YoungLizard1.1.3"]	= true,
			["LesserWraith3.1.3"]	= true,
			["LesserWraith3.1.2"]	= true,
			["LesserWraith3.1.4"]	= true,
			["YoungLizard4.1.2"]	= true,
			["YoungLizard4.1.3"]	= true,
			["SmallGolem5.1.1"]		= true
		}
		FocusJungleNames = {
			["Dragon6.1.1"]			= true,
			["Worm12.1.1"]			= true,
			["GiantWolf8.1.1"]		= true,
			["AncientGolem7.1.1"]	= true,
			["Wraith9.1.1"]			= true,
			["LizardElder10.1.1"]	= true,
			["Golem11.1.2"]			= true,
			["GiantWolf2.1.1"]		= true,
			["AncientGolem1.1.1"]	= true,
			["Wraith3.1.1"]			= true,
			["LizardElder4.1.1"]	= true,
			["Golem5.1.2"]			= true,
			["GreatWraith13.1.1"]	= true,
			["GreatWraith14.1.1"]	= true
		}
	end

	enemyCount = 0
	enemyTable = {}

	for i = 1, heroManager.iCount do
		local champ = heroManager:GetHero(i)
        
		if champ.team ~= player.team then
			enemyCount = enemyCount + 1
			enemyTable[enemyCount] = { player = champ, indicatorText = "", damageGettingText = "", ultAlert = false, ready = true}
		end
    end

    for i = 0, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object and object.valid and not object.dead then
			if FocusJungleNames[object.name] then
				JungleFocusMobs[#JungleFocusMobs+1] = object
			elseif JungleMobNames[object.name] then
				JungleMobs[#JungleMobs+1] = object
			end
		end
	end
end

function Menu()
	PanthMenu = scriptConfig("Pantheon - The Artisan of War", "Panth")
	
	PanthMenu:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		PanthMenu.combo:addParam("comboKey", "Full Combo Key (SBTW)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		PanthMenu.combo:addParam("comboItems", "Use Items with Burst", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.combo:permaShow("comboKey")
	
	PanthMenu:addSubMenu("["..myHero.charName.."] - Harass Settings", "harass")
		PanthMenu.harass:addParam("harassKey", "Harass key (C)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		PanthMenu.harass:addParam("hMode", "Harass Mode", SCRIPT_PARAM_LIST, 1, { "Q", "W+E" })
		PanthMenu.harass:addParam("autoQ", "Auto-Q when Target in Range", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey('Z'))
		PanthMenu.harass:addParam("aQT", "Don't Auto-Q if in enemy Turret Range", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.harass:addParam("harassMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		PanthMenu.harass:permaShow("harassKey")
		
	
	PanthMenu:addSubMenu("["..myHero.charName.."] - Farm Settings", "farming")
		PanthMenu.farming:addParam("farmKey", "Farming Key (X)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
		PanthMenu.farming:addParam("qFarm", "Farm with "..SpellQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.farming:addParam("wFarm", "Farm with "..SpellW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.farming:addParam("FarmMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		PanthMenu.farming:permaShow("farmKey")
		
	PanthMenu:addSubMenu("["..myHero.charName.."] - Jungle Clear Settings", "jungle")
		PanthMenu.jungle:addParam("jungleKey", "Jungle Clear Key (V)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
		PanthMenu.jungle:addParam("jungleQ", "Clear with "..SpellQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.jungle:addParam("jungleW", "Clear with "..SpellW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.jungle:addParam("jungleE", "Clear with "..SpellE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
		
		
	PanthMenu:addSubMenu("["..myHero.charName.."] - KillSteal Settings", "ks")
		PanthMenu.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.ks:permaShow("killSteal")
			
	PanthMenu:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")	
		PanthMenu.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		PanthMenu.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.drawing:addParam("cDraw", "Draw Damage Text", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.drawing:addParam("myHero", "Draw My Hero's Range", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.drawing:addParam("qDraw", "Draw "..SpellQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.drawing:addParam("wDraw", "Draw "..SpellW.name.." (W) Range", SCRIPT_PARAM_ONOFF, false)
		PanthMenu.drawing:addParam("eDraw", "Draw "..SpellE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.drawing:addParam("rDraw", "Draw "..SpellR.name.." (R) Range on the Minimap", SCRIPT_PARAM_ONOFF, true)
	
	PanthMenu:addSubMenu("["..myHero.charName.."] - Misc Settings", "misc")
		PanthMenu.misc:addSubMenu("Spells - Misc Settings", "smisc")
			PanthMenu.misc.smisc:addParam("stopChannel", "Interrupt Channeling Spells", SCRIPT_PARAM_ONOFF, true)
		if VIP_USER then
			PanthMenu.misc:addSubMenu("Spells - Cast Settings", "cast")
				PanthMenu.misc.cast:addParam("usePackets", "Use Packets to Cast Spells", SCRIPT_PARAM_ONOFF, false)
		end
		PanthMenu.misc:addSubMenu("Info - Ultimate Alert", "ultAlert")
			PanthMenu.misc.ultAlert:addParam("Enable", "Enable Ultimate Alert", SCRIPT_PARAM_ONOFF, true)
			PanthMenu.misc.ultAlert:addParam("alertTime", "Time to be shown: ", SCRIPT_PARAM_SLICE, 3, 1, 10, 0)
			if VIP_USER then
				PanthMenu.misc.ultAlert:addParam("Pings", "Use Client-Side Pings to Alert", SCRIPT_PARAM_ONOFF, false)
			end
			PanthMenu.misc.ultAlert:addParam("alertInfo", "It will print a text in the middle of the screen if an Enemy is Killable", SCRIPT_PARAM_INFO, "")

		PanthMenu:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
			pSOW:LoadToMenu(PanthMenu.Orbwalking)

	TargetSelector = TargetSelector(TARGET_LESS_CAST, SpellQ.range, DAMAGE_PHYSICAL)
	TargetSelector.name = "Pantheon"
	PanthMenu:addTS(TargetSelector)

	PanthMenu:addParam("panthVer", "Version: ", SCRIPT_PARAM_INFO, version)
end

function OnProcessSpell(unit, spell)
	if PanthMenu.misc.smisc.stopChannel then
		if GetDistanceSqr(unit) <= SpellW.range * SpellW.range then
			if InterruptingSpells[spell.name] then
				CastW(unit)
			end
		end
	end
end

function OnAnimation(unit, animationName)
	if unit.isMe then 
		if AnimationList[animationName] then
			pSOW:DisableAttacks()
			pSOW.Move = false
		else
			pSOW:EnableAttacks()
			pSOW.Move = true
		end
	end
end

function OnCreateObj(obj)
	if FocusJungleNames[obj.name] then
		JungleFocusMobs[#JungleFocusMobs+1] = obj
	elseif JungleMobNames[obj.name] then
		JungleMobs[#JungleMobs+1] = obj
	end
end

function OnDeleteObj(obj)
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

function OnDraw()
	if PanthMenu.drawing.myHero then
		pSOW:DrawAARange(1, ARGB(255, 0, 189, 22))
	end
	if not myHero.dead then
		if not PanthMenu.drawing.mDraw then
			if PanthMenu.drawing.qDraw and SpellQ.ready then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.range, ARGB(255,178, 0 , 0 ))
			end
			if PanthMenu.drawing.wDraw and SpellW.ready then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellW.range, ARGB(255, 32,178,170))
			end
			if PanthMenu.drawing.eDraw and SpellE.ready then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.range, ARGB(255,128, 0 ,128))
			end
			if PanthMenu.drawing.rDraw and SpellR.ready then
				DrawCircleMinimap(myHero.x, myHero.y, myHero.z, SpellR.range)
			end
		end
		if PanthMenu.drawing.Target then
			if Target ~= nil then
				DrawCircle3D(Target.x, Target.y, Target.z, 70, 1, ARGB(255, 255, 0, 0))
			end
		end
		if PanthMenu.drawing.cDraw then
			for i = 1, enemyCount do
				local enemy = enemyTable[i].player

				if ValidTarget(enemy) and enemy.visible then
					local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
					local pos = { X = barPos.x - 35, Y = barPos.y - 50 }

					DrawText(enemyTable[i].indicatorText, 15, pos.X, pos.Y, (enemyTable[i].ready and ARGB(255, 0, 255, 0)) or ARGB(255, 255, 220, 0))
					DrawText(enemyTable[i].damageGettingText, 15, pos.X, pos.Y + 15, ARGB(255, 255, 0, 0))
				end
			end
		end
	end
end

function OnBugsplat()
	UpdateWeb(false, 5)
end

function TickChecks()
	-- Checks if Spells Ready
	SpellQ.ready = (myHero:CanUseSpell(_Q) == READY)
	SpellW.ready = (myHero:CanUseSpell(_W) == READY)
	SpellE.ready = (myHero:CanUseSpell(_E) == READY)
	SpellR.ready = (myHero:CanUseSpell(_R) == READY)

	SpellQ.manaUsage = myHero:GetSpellData(_Q).mana
	SpellW.manaUsage = myHero:GetSpellData(_W).mana
	SpellE.manaUsage = myHero:GetSpellData(_E).mana
	SpellR.manaUsage = myHero:GetSpellData(_R).mana

	if myHero:GetSpellData(SUMMONER_1).name:find(SpellI.name) then
		SpellI.variable = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find(SpellI.name) then
		SpellI.variable = SUMMONER_2
	end
	SpellI.ready = (SpellI.variable ~= nil and myHero:CanUseSpell(SpellI.variable) == READY)

	Target = GetCustomTarget()
	pSOW:ForceTarget(Target)

	DmgCalc()

	if GetGame().isOver then
		UpdateWeb(false, 5)
	end
end

function GetCustomTarget()
	TargetSelector:update()
	if _G.MMA_Target and _G.MMA_Target.type == myHero.type then
		return _G.MMA_Target
		elseif _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair then
			return _G.AutoCarry.Attack_Crosshair.target
		elseif TargetSelector.target and not TargetSelector.target.dead and TargetSelector.target.type == myHero.type then
		return TargetSelector.target
	else
		return nil
	end
end

function UseItems(unit)
	if pSOW.Move then
		for i, Item in pairs(Items) do
			local Item = Items[i]
			if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range*Item.range then
				CastItem(Item.id, unit)
			end
		end
	end
end

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil then
		if PanthMenu.combo.comboItems then
			UseItems(unit)
		end
		CastQ(unit)
		CastW(unit)
		if not SpellW.ready then
			CastE(unit)
		end
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil then
		if not isLow('Mana', myHero, PanthMenu.harass.harassMana) then
			--- Harass Mode 1 Q ---
			if PanthMenu.harass.hMode == 1 then
				CastQ(Target)
			end

			--- Harass Mode 2 W+E ---
			if PanthMenu.harass.hMode == 2 then
				CastW(Target)
				if not SkillW.ready then CastE(Target) end
			end
		end
	end
end

function Farm()
	enemyMinions:update()
	for i, minion in pairs(enemyMinions.objects) do
		if ValidTarget(minion) and minion ~= nil then
			if minion.health <= SpellQ.dmg and (GetDistanceSqr(minion) > myHero.range*myHero.range or not pSOW:CanAttack()) and PanthMenu.farming.qFarm and not isLow('Mana', myHero, PanthMenu.farming.FarmMana) then
				CastQ(minion)
			elseif minion.health <= SpellW.dmg and (GetDistanceSqr(minion) > myHero.range * myHero.range or not pSOW:CanAttack()) and PanthMenu.farming.wFarm and not isLow('Mana', myHero, PanthMenu.farming.FarmMana) then
				CastW(minion)
			end
		end		 
	end
end

function JungleClear()
	if PanthMenu.jungle.jungleKey then
		local JungleMob = GetJungleMob()
		if JungleMob ~= nil then
			if PanthMenu.jungle.jungleQ and GetDistanceSqr(JungleMob) <= SpellQ.range * SpellQ.range then
				CastQ(JungleMob)
			end
			if PanthMenu.jungle.jungleW and GetDistanceSqr(JungleMob) <= SpellQ.range * SpellQ.range then
				CastW(JungleMob)
			end
			if PanthMenu.jungle.jungleE and GetDistanceSqr(JungleMob) <= SpellE.range * SpellE.range then
				CastE(JungleMob)
			end
		end
	end
end

function CastQ(unit)
	if unit == nil or not SpellQ.ready or (GetDistanceSqr(unit, myHero) > SpellQ.range * SpellQ.range) then
		return false
	end

	if not VIP_USER or not PanthMenu.misc.cast.usePackets then
		CastSpell(_Q, unit)
	elseif VIP_USER and PanthMenu.misc.cast.usePackets then
		Packet("S_CAST", { spellId = _Q, targetNetworkId = unit.networkID }):send()
	end
end

function CastW(unit)
	if unit == nil or not SpellW.ready or (GetDistanceSqr(unit, myHero) > SpellW.range * SpellW.range) then
		return false
	end

	if not VIP_USER or not PanthMenu.misc.cast.usePackets then
		CastSpell(_W, unit)
	elseif VIP_USER and PanthMenu.misc.cast.usePackets then
		Packet("S_CAST", { spellId = _W, targetNetworkId = unit.networkID }):send()
	end
end

function CastE(unit)
	if unit == nil or not SpellE.ready or (GetDistanceSqr(unit) > SpellE.range * SpellE.range) then
		return false
	end

	if not VIP_USER or not PanthMenu.misc.cast.usePackets then
		CastSpell(_E, unit.x, unit.z)
	else
		Packet("S_CAST", { spellId = _E, toX = unit.x, toY = unit.z, fromX = unit.x, fromY = unit.z }):send()
	end
end

function ArrangePriorities()
	for i = 1, enemyCount do
		local enemy = enemyTable[i].player
		SetPriority(priorityTable.AD_Carry, enemy, 1)
		SetPriority(priorityTable.AP, enemy, 2)
		SetPriority(priorityTable.Support, enemy, 3)
		SetPriority(priorityTable.Bruiser, enemy, 4)
		SetPriority(priorityTable.Tank, enemy, 5)
	end
end

function ArrangeTTPriorities()
	for i = 1, enemyCount do
		local enemy = enemyTable[i].player
		SetPriority(priorityTable.AD_Carry, enemy, 1)
		SetPriority(priorityTable.AP, enemy, 1)
		SetPriority(priorityTable.Support, enemy, 2)
		SetPriority(priorityTable.Bruiser, enemy, 2)
		SetPriority(priorityTable.Tank, enemy, 3)
	end
end
function SetPriority(table, hero, priority)
	for i = 1, #table do
		if hero.charName:find(table[i]) ~= nil then
			TS_SetHeroPriority(priority, hero.charName)
		end
	end
end

function GetJungleMob()
		for _, Mob in pairs(JungleFocusMobs) do
			if ValidTarget(Mob, SpellQ.range) then return Mob end
		end
		for _, Mob in pairs(JungleMobs) do
			if ValidTarget(Mob, SpellQ.range) then return Mob end
		end
	end

function DmgCalc()
	for i = 1, enemyCount do
		local enemy = enemyTable[i].player
		if ValidTarget(enemy) and enemy.visible then
			SpellQ.dmg = (SpellQ.ready and getDmg("Q",		enemy, myHero)) or 0
			SpellW.dmg = (SpellW.ready and getDmg("W",		enemy, myHero)) or 0
			SpellE.dmg = (SpellE.ready and getDmg("E",		enemy, myHero)) or 0
			SpellR.dmg = (SpellR.ready and getDmg("R",		enemy, myHero)) or 0
			SpellI.dmg = (SpellI.ready and getDmg("IGNITE", enemy, myHero)) or 0

			if enemy.health < SpellQ.dmg then
				enemyTable[i].indicatorText = "Q Kill"
				enemyTable[i].ready = SpellQ.ready and SpellQ.manaUsage <= myHero.mana
			elseif enemy.health < SpellW.dmg then
				enemyTable[i].indicatorText = "W Kill"
				enemyTable[i].ready = SpellW.ready and SpellW.manaUsage <= myHero.mana
			elseif enemy.health < SpellE.dmg then
				enemyTable[i].indicatorText = "E Kill"
				enemyTable[i].ready = SpellE.ready and SpellE.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellW.dmg then
				enemyTable[i].indicatorText = "Q + W Kill"
				enemyTable[i].ready = SpellQ.ready and SpellW.ready and SpellQ.manaUsage + SpellW.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellE.dmg then
				enemyTable[i].indicatorText = "Q + E Kill"
				enemyTable[i].ready = SpellQ.ready and SpellE.ready and SpellQ.manaUsage + SpellE.manaUsage <= myHero.mana
			elseif enemy.health < SpellW.dmg + SpellE.dmg then
				enemyTable[i].indicatorText = "W + E Kill"
				enemyTable[i].ready = SpellW.ready and SpellE.ready and SpellW.manaUsage + SpellE.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellW.dmg + SpellE.dmg then
				enemyTable[i].indicatorText = "Q + W + E Kill"
				enemyTable[i].ready = SpellQ.ready and SpellW.ready and SpellE.ready and SpellQ.manaUsage + SpellW.manaUsage + SpellE.manaUsage <= myHero.mana
			else
				local dmgTotal = SpellQ.dmg + SpellW.dmg + SpellE.dmg
				local hpLeft = math.round(enemy.health - dmgTotal)
				local percentLeft = math.round(hpLeft / enemy.maxHealth * 100)

				enemyTable[i].indicatorText = percentLeft .. "% Harass"
				enemyTable[i].ready = SpellQ.ready and SpellW.ready and SpellE.ready
			end

			local enemyAD = getDmg("AD", myHero, enemy)

			enemyTable[i].damageGettingText = enemy.charName.." kills me with "..math.ceil(myHero.health / enemyAD).." hits"
		end
	end
end

function KillSteal()
	for i = 1, enemyCount do
		local enemy = enemyTable[i].player
		if ValidTarget(enemy) and enemy.visible then
			if enemy.health < SpellQ.dmg and SpellQ.ready then
				CastQ(enemy)
			elseif enemy.health < SpellW.dmg and SpellW.ready then
				CastW(enemy)
			elseif enemy.health < SpellE.dmg and SpellE.ready then
				CastE(enemy)
			elseif enemy.health < SpellQ.dmg + SpellW.dmg and SpellQ.ready and SpellW.ready then
				CastW(enemy)
			elseif enemy.health < SpellQ.dmg + SpellE.dmg and SpellQ.ready and SpellE.ready then
				CastQ(enemy)
			elseif enemy.health < SpellW.dmg + SpellE.dmg and SpellW.ready and SpellE.ready then
				CastW(enemy)
			elseif enemy.health < SpellQ.dmg + SpellW.dmg + SpellE.dmg then
				CastQ(enemy)
			end

			if PanthMenu.ks.autoIgnite then
				AutoIgnite(enemy)
			end
		end
	end
end

function AutoIgnite(unit)
	if unit.health < SpellI.dmg and GetDistanceSqr(unit) <= SpellI.range * SpellI.range then
		if SpellI.ready then
			CastSpell(SpellI.variable, unit)
		end
	end
end

function isLow(what, unit, slider)
	if what == 'Mana' then
		if unit.mana < (unit.maxMana * (slider / 100)) then
			return true
		else
			return false
		end
	elseif what == 'HP' then
		if unit.health < (unit.maxHealth * (slider / 100)) then
			return true
		else
			return false
		end
	end
end

function GetKillable()
	for i = 1, enemyCount do
		local enemy = enemyTable[i].player
		if enemy.visible and enemy ~= nil and not enemy.dead then
			if enemy.health < SpellR.dmg and SpellR.ready then
				if not enemyTable[i].ultAlert then
					PrintAlert(enemy.charName.." can be Killed by Ult", PanthMenu.misc.ultAlert.alertTime, 128, 255, 0)

					if PanthMenu.misc.ultAlert.Pings and VIP_USER then
						Packet('R_PING',  { x = enemy.x, y = enemy.z, type = PING_FALLBACK }):receive()
					end

					enemyTable[i].ultAlert = true
				end
			end
		else
			enemyTable[i].ultAlert = false
		end
	end
end

function InEnemyTurretRange(unit)
	for i, turret in pairs(GetTurrets()) do
		if turret ~= nil then
			if turret.team ~= myHero.team then
				if GetDistanceSqr(unit, turret) <= turret.range * turret.range then
					return true
				end
			end
		end
	end
	return false
end

-- UpdateWeb Function
LoadProtectedScript('VjUzEzdFTURpN0NFYN50TGhvRUxAbTNLRXlNeER2ZUVMRm1zSyB5TXlMMuXFU0DtM0lFeU19RXJlRRMHbTdDRXlNCwodBCEpMm0yS0V5THlGcmhFTEBvM0NVeU1543JlRUTAbbPNBTlNv8YyZUONAG11SgV5zXjGcjhETEFwsktFPUx5RvNkREyAbDNLmHnNe9vyZUXRAO0zVEX5TXxGcmVBREBtMw03FiAxIwplQUtAbTMqNgooCzJyYUBMQG1fJCQdTX1LcmVFDiEeVn1xPSgaKRYARUhDbTNLJw1NeEZyZUdMQG05S0V5THlDemVFTAZtc0sCOY15xnJlRY3AbTNuRHlNJMZyZxpMQGwsS8V5TnlGcmFCTEBtQD83ECMeRnZgRUxACkA+J3lJckZyZW1pOEhLYh5ZEEZGc2VFTEVtM0tCeU15R3JgTExAbXVLBXkKOYZy48UMQK0zS0V4jHlG72XFTR5tM0saeU15WXLlRUhAbTNPQnlNeTUGFywiJ203TkV5TRouExdFSEltM0sxFiMMKxAAN0xDbTNLRXlNSQZyZUVMQW0zS0V5TXlGcmVFTEBtM0tFeU15RnNlRUxAbTNLRXlNeUZyZUVMQG0zS0V4TXlGcmVFTEBtM0tFeU15RnJlRUxAbDNLRXhNeUZyZUVMQG0zS0V5TXlGcg==DD5156CC3E957E825B5E6A2951F0A145')
rLoader(_ENV, "47307831595649414151514542416741475A4D4E43686F4B41414141414141414141414141514944414141414A514141414167414149416641494141415141414141514B414141415658426B5958526C56325669414145414141414341414141444141414141494144793841414143474145414177554141414A32414141484767454141423846414152304267414464674141414441484241594642415144426751454148554541416873414141415877414F41444D48424159454241674441415941414155494341456143516743427767494178674A44414D64437777554767304D4151634D4441494544424144646767414341554D45414A594241774D64515941424634414467417A427751474267515141774147414141464341674247676B494167634943414D59435177444851734D46426F4E4441454844417743424177514133594941416746444241435741514D444855474141517A4278414564515141424877434141425141414141454341414141484A6C63585670636D5541424163414141427A62324E725A585141424163414141426863334E6C636E5141424151414141423059334141424167414141426A623235755A574E304141515141414141596D39734C58527959574E725A5849755932397441414D4141414141414142555141514641414141633256755A414145474141414145644656434176636D567A644339755A586477624746355A58492F6157513941415148414141414A6D68336157513941415146414141415346644A524141454451414141435A7A59334A706348524F5957316C505141454277414141484E30636D6C755A774145425141414147647A6457494142417741414142565545524256455666546B464E5251414544514141414674654D43303551533161595331365851414541514141414141454A51414141434249564652514C7A45754D41304B5347397A64446F67596D39734C58527959574E725A5849755932397444516F4E43674145477741414145644656434176636D567A6443396B5A57786C64475677624746355A58492F6157513941415147414141415932787663325541414141414141454141414141414241414141424162324A6D64584E6A5958526C5A433573645745414C77414141414941414141434141414141674141414149414141414341414141416741414141494141414144414141414177414141414D4141414144414141414241414141415141414141464141414142514141414155414141414741414141426741414141634141414148414141414277414141416341414141484141414142774141414163414141414941414141427741414141554141414149414141414351414141416B414141414A414141414367414141416F414141414C4141414143774141414173414141414C4141414143774141414173414141414C4141414144414141414173414141414A4141414144414141414177414141414D4141414142414141414149414141426841414141414141764141414141674141414749414141414141433841414141434141414159774144414141414C774141414149414141426B414163414141417641414141415141414141554141414266525535574141454141414142414241414141424162324A6D64584E6A5958526C5A4335736457454141774141414177414141414341414141444141414141414141414142414141414251414141463946546C5941")
