local Ziggs_Ver = "1.051"
--[[


		d88888D d888888b  d888b   d888b  .d8888. 
		YP  d8'   `88'   88' Y8b 88' Y8b 88'  YP 
		   d8'     88    88      88      `8bo.   
		  d8'      88    88  ooo 88  ooo   `Y8b. 
		 d8' db   .88.   88. ~8~ 88. ~8~ db   8D 
		d88888P Y888888P  Y888P   Y888P  `8888Y' 

	Script - Ziggs - The Hexplosives Expert 1.04

	Changelog:
		1.05
			- Fixed Target Type Selection
			- Updated Q's Width for a better Collision
		1.04
			- Added Custom Collision
			- Improved Orbwalker
			- Re-wrote Ult Alerter
			- Fixed W Bug not Exploding
			- Improved Farm Function
			- Fixed MEC Ult
			- Fixed Satchel not Poping
			- Fixed Killsteal Function not Working Properly
			- Fixed Auto-Ignite not Working Properly
			- Updated Variables, some of them were missing in the Tables
			- Fixed MEC Ult Errors
			- Fixed Spamming Errors (after re-load)
			- Added a check to Enable/Disable myHero.range in the Draw Menu
			- Added an Option to see who are you Targeting
			- Fixed Auto-Interup Option

		1.03
			- Added 'Alert Option' for Ult if an enemy is Killable
			- Improved Killsteal Function
			- Fixed Auto-Ignite Option
			- Fixed Spamming Errors About 'ARGB'
			- Added a Slider for the Duration of the 'Alert Option' Text
			- Added a new Combo Logic when you use W in Combo
			- Fixed 'Insta W Popping' Bug
			- Removed In-Built Orbwalker
			- Added SOW as main Orbwalker
			- Added MEC Ult Hotkey
			- Fixed Spamming Errors
			- Fixed Ult Alerter Bug

		1.02
			- Added 'Move to Cursor' Option while Satchel Jumping
			- Fixed W Casting
			- Updated vPrediction Link
			- Improved W Accuracy
			- Fixed Spamming 'nil' Errors
			- Fixed Farming Stuttering if SAC / MMA was Used
			- Re-wrote Killsteal Function
			- Fixed Checks if Spells are ready on Killsteal Function

		1.01
			- Fixed OnDeleteObj Bug
			- Fixed Spamming Errors about 'nil' Table
			- Fixed Spamming Errors about 'range'
			- Fixed Spells throwing at Mouse Pos
			- Removed Auto-Pots Option
			- Fixed Killsteal Option
			- Fixed Auto-Ignite Option
			- Fixed Orbwalker Bug

		1.00
			- First Release
]]--
if myHero.charName ~= "Ziggs" or not VIP_USER then return end

_G.Ziggs_Autoupdate = true

local REQUIRED_LIBS = {
	["Collision"]	= "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/154ae5a9505b2af87c1a6049baa529b934a498a9/Common/Collision.lua",
	["Prodiction"]	= "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/154ae5a9505b2af87c1a6049baa529b934a498a9/Common/Prodiction.lua",
	["SOW"]			= "https://raw.githubusercontent.com/honda7/BoL/master/Common/SOW.lua",
	["VPrediction"] = "https://raw.githubusercontent.com/honda7/BoL/master/Common/VPrediction.lua"
}

local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<font color=\"#FF0000\"><b>Ziggs - The Hexplosives Expert:</b></font> <font color=\"#FFFFFF\">Required libraries downloaded successfully, please reload (double F9).</font>")
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

local UPDATE_NAME = "Ziggs - The Hexplosives Expert"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/RoachxD/BoL_Scripts/master/Ziggs%20-%20The%20Hexplosives%20Expert.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..UPDATE_NAME..".lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#FF0000\">"..UPDATE_NAME..":</font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.Ziggs_Autoupdate then
	local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
	if ServerData then
		local ServerVersion = string.match(ServerData, "local Ziggs_Ver = \"%d+.%d+\"")
		ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
		if ServerVersion then
			ServerVersion = tonumber(ServerVersion)
			if tonumber(Ziggs_Ver) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..Ziggs_Ver.." => "..ServerVersion.."), press F9 twice to load the updated version.") end)	 
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

	if heroManager.iCount < 10 then -- borrowed from Sidas Auto Carry, modified to 3v3
			AutoupdaterMsg("Too few champions to arrange priorities")
	elseif heroManager.iCount == 6 and TTMAP then
		ArrangeTTPriorities()
	else
		ArrangePriorities()
	end
end

function OnTick()
	ComboKey		= ZiggsMenu.combo.comboKey
	HarassKey		= ZiggsMenu.harass.harassKey
	FarmKey			= ZiggsMenu.farming.farmKey
	JungleClearKey	= ZiggsMenu.jungle.jungleKey
	SatchelKey		= ZiggsMenu.misc.satchel.satchJump
	SatchelbKey		= ZiggsMenu.misc.satchel.behindTarget

	if ComboKey then
		Combo(Target)
	end
	if HarassKey then
		Harass(Target)
	end
	if SatchelbKey then
		CastW(Target)
	end
	if FarmKey then
		Farm()
	end
	if JungleClearKey then
		JungleClear()
	end
	if SatchelKey then
		SatchelJump()
	end
	if ZiggsMenu.ks.killSteal then
		KillSteal()
	end
	if ZiggsMenu.misc.mecUlt.Enable then
		for i = 1, enemyCount do
			local enemy = enemyTable[i].player

			CastR(enemy, ZiggsMenu.misc.mecUlt.minEnemies)
		end
		if ZiggsMenu.misc.mecUlt.mecMTC then
			moveToCursor()
		end
	end
	if ZiggsMenu.misc.ultAlert.Enable then
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

	SpellP = {name = "Short Fuse",			buffName = "ZiggsPassiveBuff",																   ready = false,			 dmg = 0								 }

	SpellQ = {name = "Bouncing Bomb",		minrange =  850, maxrange = 1400, mindelay = 0.25, maxdelay = 0.5,	speed = 1750, width = 150, ready = false, pos = nil, dmg = 0, manaUsage = 0					 }
	SpellW = {name = "Satchel Charge",	       range = 1000,					 delay = 0.50, behindpos = nil,	speed = 1750, width = 275, ready = false, pos = nil, dmg = 0, manaUsage = 0, canJump = false }
	SpellE = {name = "Hexplosive Minefield",   range =  900,					 delay = 0.25,					speed = 1750, width = 235, ready = false, pos = nil, dmg = 0, manaUsage = 0					 }
	SpellR = {name = "Mega Inferno Bomb",	   range = 5300, 					 delay = 0.25,					speed = 1750, width = 550, ready = false, pos = nil, dmg = 0, manaUsage = 0					 }

	SpellI = {name = "SummonerDot",			   range =  600,																			   ready = false,			 dmg = 0,				 variable = nil  }

	vPred = VPrediction()

	zSOW = SOW(vPred)

	Prodict = ProdictManager.GetInstance()
	ProdQMin = Prodict:AddProdictionObject(_Q, SpellQ.minrange, SpellQ.speed, SpellQ.mindelay, SpellQ.width)
	ProdQMax = Prodict:AddProdictionObject(_Q, SpellQ.maxrange, SpellQ.speed, SpellQ.maxdelay, SpellQ.width)
	ProdW = Prodict:AddProdictionObject(_W, SpellW.range,	 SpellW.speed, SpellW.delay, SpellW.width)
	ProdE = Prodict:AddProdictionObject(_E, SpellE.range,	 SpellE.speed, SpellE.delay, SpellE.width)
	ProdR = Prodict:AddProdictionObject(_R, SpellR.range,	 SpellR.speed, SpellR.delay, SpellR.width)

	ProdQCollision = Collision(SpellQ.maxrange, SpellQ.speed, SpellQ.maxdelay, SpellQ.width)

	enemyMinions	= minionManager(MINION_ENEMY,	SpellQ.maxrange, myHero.visionPos, MINION_SORT_HEALTH_ASC)
	jungleMinions	= minionManager(MINION_JUNGLE,	SpellQ.maxrange, myHero.visionPos, MINION_SORT_HEALTH_ASC)
	otherMinions	= minionManager(MINION_OTHER,	SpellQ.maxrange, myHero.visionPos, MINION_SORT_HEALTH_ASC)

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

	Consumables = {
		["FLASK"]	= { id = 2041, ready = false },	-- HP and Mana
		["HPPOT"]	= { id = 2003, ready = false },	-- HP
		["MPPOT"]	= { id = 2004, ready = false },	-- Mana
		["ICHOR"]	= { id = 2048, ready = false },	-- Mana Regen.

		UsingMana = false,
		UsingHP = false
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

	buffTypes = { BUFF_STUN, BUFF_ROOT, BUFF_KNOCKUP, BUFF_SUPPRESS, BUFF_SLOW, BUFF_CHARM, BUFF_FEAR, BUFF_TAUNT }

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
	ZiggsMenu = scriptConfig("Ziggs - The Hexplosive Expert", "Ziggs")
	
	ZiggsMenu:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		ZiggsMenu.combo:addParam("comboKey", "Full Combo Key (SBTW)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		ZiggsMenu.combo:addParam("useW", "Use "..SpellW.name.." (W) with Combo", SCRIPT_PARAM_ONOFF, false)
		ZiggsMenu.combo:addParam("useR", "Use "..SpellR.name.." (R): ", SCRIPT_PARAM_LIST, 3, { "If Target Killable", "With Burst", "No" })
		ZiggsMenu.combo:addParam("comboItems", "Use Items with Burst", SCRIPT_PARAM_ONOFF, true)
		ZiggsMenu.combo:permaShow("comboKey")
	
	ZiggsMenu:addSubMenu("["..myHero.charName.."] - Harass Settings", "harass")
		ZiggsMenu.harass:addParam("harassKey", "Harass key (C)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		ZiggsMenu.harass:addParam("qHarass", "Use "..SpellQ.name.." (Q) to Harass", SCRIPT_PARAM_ONOFF, true)
		ZiggsMenu.harass:addParam("eHarass", "Use "..SpellE.name.." (E) to Harass", SCRIPT_PARAM_ONOFF, false)
		ZiggsMenu.harass:addParam("harassMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		ZiggsMenu.harass:permaShow("harassKey")
		
	
	ZiggsMenu:addSubMenu("["..myHero.charName.."] - Farm Settings", "farming")
		ZiggsMenu.farming:addParam("farmKey", "Farming Key (X)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
		ZiggsMenu.farming:addParam("qFarm", "Farm with "..SpellQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		ZiggsMenu.farming:addParam("qFarmMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		ZiggsMenu.farming:permaShow("farmKey")
		
	ZiggsMenu:addSubMenu("["..myHero.charName.."] - Jungle Clear Settings", "jungle")
		ZiggsMenu.jungle:addParam("jungleKey", "Jungle Clear Key (V)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
		ZiggsMenu.jungle:addParam("jungleQ", "Clear with "..SpellQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		ZiggsMenu.jungle:addParam("jungleE", "Clear with "..SpellE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
		
		
	ZiggsMenu:addSubMenu("["..myHero.charName.."] - KillSteal Settings", "ks")
		ZiggsMenu.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
		ZiggsMenu.ks:addParam("useW", "Use "..SpellW.name.." (W) to KS", SCRIPT_PARAM_ONOFF, false)
		ZiggsMenu.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		ZiggsMenu.ks:permaShow("killSteal")
			
	ZiggsMenu:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")	
		ZiggsMenu.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		ZiggsMenu.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
		ZiggsMenu.drawing:addParam("cDraw", "Draw Damage Text", SCRIPT_PARAM_ONOFF, true)
		ZiggsMenu.drawing:addParam("myHero", "Draw My Hero's Range", SCRIPT_PARAM_ONOFF, true)
		ZiggsMenu.drawing:addParam("qDraw", "Draw "..SpellQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		ZiggsMenu.drawing:addParam("wDraw", "Draw "..SpellW.name.." (W) Range", SCRIPT_PARAM_ONOFF, false)
		ZiggsMenu.drawing:addParam("eDraw", "Draw "..SpellE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		ZiggsMenu.drawing:addParam("rDraw", "Draw "..SpellR.name.." (R) Range on the Minimap", SCRIPT_PARAM_ONOFF, true)
	
	ZiggsMenu:addSubMenu("["..myHero.charName.."] - Misc Settings", "misc")
		ZiggsMenu.misc:addSubMenu("Spells - Misc Settings", "smisc")
			ZiggsMenu.misc.smisc:addParam("stopChannel", "Interrupt Channeling Spells", SCRIPT_PARAM_ONOFF, true)
			ZiggsMenu.misc.smisc:addParam("AutoQ", "Auto-Q at CCed Enemies", SCRIPT_PARAM_ONOFF, false)
		ZiggsMenu.misc:addSubMenu("Spells - Satchel Settings", "satchel")
			ZiggsMenu.misc.satchel:addParam("satchJump", "Satchel Jump (G)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('G'))
			ZiggsMenu.misc.satchel:addParam("MTCsatchJump", "Move to Cursor while Satchel Jumping", SCRIPT_PARAM_ONOFF, false)
			ZiggsMenu.misc.satchel:addParam("behindTarget", "Throw "..SpellW.name.." (W) behind Target (T)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('T'))
		ZiggsMenu.misc:addSubMenu("Spells - Ultimate Settings", "umisc")
			ZiggsMenu.misc.umisc:addParam("vPredHC", "vPrediction Hitchance to Ult: ", SCRIPT_PARAM_SLICE, 2, 0, 2, 0)
			ZiggsMenu.misc.umisc:addParam("ultRange", "Max Range to Ult: ", SCRIPT_PARAM_SLICE, SpellR.range, 700, SpellR.range, 0)
			ZiggsMenu.misc.umisc:addParam("ultInfo", "The smaller is the range, the greater is the hitchance!", SCRIPT_PARAM_INFO, "")
		ZiggsMenu.misc:addSubMenu("Spells - Ultimate MEC", "mecUlt")
			ZiggsMenu.misc.mecUlt:addParam("Enable", "Use MEC to Ult", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('U'))
			ZiggsMenu.misc.mecUlt:addParam("minEnemies", "Min. Enemies in Radius: ", SCRIPT_PARAM_SLICE, 2, 2, 5, 0)
			ZiggsMenu.misc.mecUlt:addParam("mecMTC", "Move to Cursor when Searching for Enemies", SCRIPT_PARAM_ONOFF, false)
		ZiggsMenu.misc:addSubMenu("Spells - Collision Settings", "colMisc")
			ZiggsMenu.misc.colMisc:addParam("spellQ", "Use Custom Collision", SCRIPT_PARAM_ONOFF, true)
			ZiggsMenu.misc.colMisc:addParam("Minions", "Check for Normal Minions", SCRIPT_PARAM_ONOFF, true)
			ZiggsMenu.misc.colMisc:addParam("Mobs", "Check for Jungle Mobs", SCRIPT_PARAM_ONOFF, true)
			ZiggsMenu.misc.colMisc:addParam("Others", "Check for Other Minions", SCRIPT_PARAM_ONOFF, true)
			ZiggsMenu.misc.colMisc:addParam("colInfo", "Using the Custom Collision is better because was made specially for Ziggs's Q", SCRIPT_PARAM_INFO, "")
		ZiggsMenu.misc:addSubMenu("Spells - Cast Settings", "cast")
			ZiggsMenu.misc.cast:addParam("usePackets", "Use Packets to Cast Spells", SCRIPT_PARAM_ONOFF, false)
		ZiggsMenu.misc:addSubMenu("Info - Ultimate Alert", "ultAlert")
			ZiggsMenu.misc.ultAlert:addParam("Enable", "Enable Ultimate Alert", SCRIPT_PARAM_ONOFF, true)
			ZiggsMenu.misc.ultAlert:addParam("alertTime", "Time to be shown: ", SCRIPT_PARAM_SLICE, 3, 1, 10, 0)
			ZiggsMenu.misc.ultAlert:addParam("Pings", "Use Client-Side Pings to Alert", SCRIPT_PARAM_ONOFF, false)
			ZiggsMenu.misc.ultAlert:addParam("alertInfo", "It will print a text in the middle of the screen if an Enemy is Killable", SCRIPT_PARAM_INFO, "")

		ZiggsMenu:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
			zSOW:LoadToMenu(ZiggsMenu.Orbwalking)

	ZiggsMenu:addParam("predType", "Prediction Type", SCRIPT_PARAM_LIST, 1, { "Prodiction", "VPrediction" })

	TargetSelector = TargetSelector(TARGET_LESS_CAST, SpellQ.maxrange, DAMAGE_MAGIC)
	TargetSelector.name = "Ziggs"
	ZiggsMenu:addTS(TargetSelector)

	ZiggsMenu:addParam("ziggsVer", "Version: ", SCRIPT_PARAM_INFO, Ziggs_Ver)
end

function OnProcessSpell(unit, spell)
	if ZiggsMenu.misc.smisc.stopChannel then
		if GetDistanceSqr(unit) <= SpellW.range*SpellW.range and SpellW.ready then
			if InterruptingSpells[spell.name] and unit.team ~= myHero.team then
				CastSpell(_W, unit.visionPos.x, unit.visionPos.z)
			end
		end
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == SpellP.buffName then
		SpellP.ready = true
	end
	if ZiggsMenu.misc.smisc.AutoQ then
		if unit.team ~= myHero.team and unit.type == myHero.type then
			for i = 1, #buffTypes do
				local buffType = buffTypes[i]
				if buff.type == buffType then
					CastQ(unit)
				end
			end
		end
	end
	if buff.name == "ItemCrystalFlask" then
		Consumables.UsingHP		= true
		Consumables.UsingMana	= true
	end
	if buff.name == "FlaskOfCrystalWater" then
		Consumables.UsingMana	= true
	end
	if buff.name == "RegenerationPotion" then
		Consumables.UsingHP		= true
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == SpellP.buffName then
		SpellP.ready = false
	end

	if buff.name == "ItemCrystalFlask" then
		Consumables.UsingHP		= false
		Consumables.UsingMana	= false
	end
	if buff.name == "FlaskOfCrystalWater" then
		Consumables.UsingMana	= false
	end
	if buff.name == "RegenerationPotion" then
		Consumables.UsingHP		= false
	end
end

function OnCreateObj(obj)
	if SatchelKey or ComboKey or SatchelbKey then
		if obj.name == "ZiggsW_mis_ground.troy" then
			SpellW.canJump = true
			SatchelJump()
		end
	end

	if FocusJungleNames[obj.name] then
		JungleFocusMobs[#JungleFocusMobs+1] = obj
	elseif JungleMobNames[obj.name] then
		JungleMobs[#JungleMobs+1] = obj
	end
end

function OnDeleteObj(obj)
	if obj.name == "ZiggsW_mis_ground.troy" then
		SpellW.canJump = false
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

function OnDraw()
	if ZiggsMenu.drawing.myHero then
		zSOW:DrawAARange(1, ARGB(255, 0, 189, 22))
	end

	if not myHero.dead then
		if not ZiggsMenu.drawing.mDraw then
			if ZiggsMenu.drawing.qDraw and SpellQ.ready then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.maxrange, ARGB(255,178, 0 , 0 ))
			end
			if ZiggsMenu.drawing.wDraw and SpellW.ready then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellW.range, ARGB(255, 32,178,170))
			end
			if ZiggsMenu.drawing.eDraw and SpellE.ready then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.range, ARGB(255,128, 0 ,128))
			end
			if ZiggsMenu.drawing.rDraw and SpellR.ready then
				DrawCircleMinimap(myHero.x, myHero.y, myHero.z, SpellR.range)
			end
		end
		if ZiggsMenu.drawing.Target then
			if Target ~= nil then
				DrawCircle3D(Target.x, Target.y, Target.z, 70, 1, ARGB(255, 255, 0, 0))
			end
		end
		if ZiggsMenu.drawing.cDraw then
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
	zSOW:ForceTarget(Target)

	DmgCalc()
end

function GetCustomTarget()
	TargetSelector:update()
    if _G.MMA_Target and _G.MMA_Target.type == myHero.type then
    	return _G.MMA_Target
   	elseif _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair then
   		return _G.AutoCarry.Attack_Crosshair.target
   	elseif TargetSelector.target and not TargetSelector.target.dead and TargetSelector.target.type  == myHero.type then
    	return TargetSelector.target
    else
    	return nil
    end
end

function UseItems(unit)
	for i, Item in pairs(Items) do
		local Item = Items[i]
		if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range*Item.range then
			CastItem(Item.id, unit)
		end
	end
end

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil then
		if ZiggsMenu.combo.comboItems then
			UseItems(unit)
		end
		if ZiggsMenu.combo.useW then
			CastW(unit)
			DelayAction(function()
							CastE(unit)
							CastQ(unit)
						end, 0.3)
		else
			CastE(unit)
			CastQ(unit)
		end
		if ZiggsMenu.combo.useR ~= 3 then
			if ZiggsMenu.combo.useR == 1 then
				if unit.health < SpellR.dmg then
					CastR(unit, 1)
				end
			else
				CastR(unit, 1)
			end
		end
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil then
		if not isLow('Mana', myHero, ZiggsMenu.harass.harassMana) then
			if ZiggsMenu.harass.eHarass then
				CastE(unit)
			end
			if ZiggsMenu.harass.qHarass then
				CastQ(unit)
			end
		end
	end
end

function Farm()
	enemyMinions:update()
	for i, minion in pairs(enemyMinions.objects) do
		if ValidTarget(minion) and minion ~= nil then
			if minion.health <= SpellQ.dmg and (GetDistanceSqr(minion) > myHero.range * myHero.range or not zSOW:CanAttack()) and GetDistanceSqr(minion) <= SpellQ.minrange * SpellQ.minrange and ZiggsMenu.farming.qFarm and not isLow('Mana', myHero, ZiggsMenu.farming.qFarmMana) then
				CastQ(minion)
			end
		end		 
	end
end

function JungleClear()
	if ZiggsMenu.jungle.jungleKey then
		local JungleMob = GetJungleMob()
		if JungleMob ~= nil then
			if ZiggsMenu.jungle.jungleQ and SpellQ.ready and GetDistanceSqr(JungleMob) <= SpellQ.maxrange*SpellQ.maxrange then
				CastQ(JungleMob)
			end
			if ZiggsMenu.jungle.jungleE and SpellE.ready and GetDistanceSqr(JungleMob) <= SpellE.range*SpellE.range then
				CastE(JungleMob)
			end
		end
	end
end

function SatchelJump()
	if ZiggsMenu.misc.satchel.MTCsatchJump then
		moveToCursor()
	end

	if not SpellW.ready then return end

	local X, Y, Z = (Vector(myHero) - Vector(mousePos)):normalized():unpack()

	if SpellW.canJump then
		if ZiggsMenu.misc.cast.usePackets then
			Packet('S_CAST', { spellId = _W }):send()
		else
			CastSpell(_W)
		end
	else
		if ZiggsMenu.misc.cast.usePackets then
			Packet('S_CAST', { spellId = _W, fromX = myHero.x + (X * 50), fromY = myHero.z + (Z * 50)}):send()
		else
			CastSpell(_W, myHero.x + (X * 50), myHero.z + (Z * 50))
		end
	end
end

function CastQ(unit)
	if unit == nil or not SpellQ.ready or (GetDistanceSqr(unit, myHero) > SpellQ.maxrange*SpellQ.maxrange) then
		return false
	end
	if GetDistanceSqr(unit, myHero) <= SpellQ.minrange*SpellQ.minrange then
		if ZiggsMenu.predType == 1 then
			SpellQ.pos = ProdQMin:GetPrediction(unit)
			if SpellQ.pos ~= nil then
				if ZiggsMenu.misc.cast.usePackets then
					Packet("S_CAST", { spellId = _Q, toX = SpellQ.pos.x, toY = SpellQ.pos.z, fromX = SpellQ.pos.x, fromY = SpellQ.pos.z }):send()
				else
					CastSpell(_Q, SpellQ.pos.x, SpellQ.pos.z)
				end
				return true
			end
		else
			local CastPos, HitChance, Position = vPred:GetCircularCastPosition(unit, SpellQ.mindelay, SpellQ.width, SpellQ.minrange, SpellQ.speed, myHero, false)

			if HitChance >= 2 then
				if ZiggsMenu.misc.cast.usePackets then
					Packet("S_CAST", { spellId = _Q, toX = CastPos.x, toY = CastPos.z, fromX = CastPos.x, fromY = CastPos.z }):send()
				else
					CastSpell(_Q, CastPos.x, CastPos.z)
				end
				return true
			end
		end
	elseif GetDistanceSqr(unit, myHero) <= SpellQ.maxrange*SpellQ.maxrange then
		if ZiggsMenu.predType == 1 then
			SpellQ.pos = ProdQMax:GetPrediction(unit)
			if SpellQ.pos ~= nil then
				local willCollide = ZiggsMenu.misc.colMisc.spellQ and CustomCollision(unit) or ProdQCollision:GetMinionCollision(unit, SpellQ.pos)
				if not willCollide then
					if ZiggsMenu.misc.cast.usePackets then
						Packet("S_CAST", { spellId = _Q, toX = SpellQ.pos.x, toY = SpellQ.pos.z, fromX = SpellQ.pos.x, fromY = SpellQ.pos.z }):send()
					else
						CastSpell(_Q, SpellQ.pos.x, SpellQ.pos.z)
					end
					return true
				end
			end
		else
			local CastPos, HitChance, Position = vPred:GetCircularCastPosition(unit, SpellQ.maxdelay, SpellQ.width, SpellQ.maxrange, SpellQ.speed, myHero, ZiggsMenu.misc.colMisc.spellQ and false or true)
			local willCollide = CustomCollision(unit)
			if HitChance >= 2 and ((ZiggsMenu.misc.colMisc.spellQ and willCollide ~= nil and not willCollide) or not ZiggsMenu.misc.colMisc.spellQ) then
				if ZiggsMenu.misc.cast.usePackets then
					Packet("S_CAST", { spellId = _Q, toX = CastPos.x, toY = CastPos.z, fromX = CastPos.x, fromY = CastPos.z }):send()
				else
					CastSpell(_Q, CastPos.x, CastPos.z)
				end
				return true
			end
		end
	end
end

function CastW(unit)
	if unit == nil or (GetDistanceSqr(unit) > SpellW.range*SpellW.range) or not SpellW.ready then
		return false
	end
	if ZiggsMenu.predType == 1 then
		SpellW.pos = ProdW:GetPrediction(unit)
		if SpellW.pos ~= nil then
			SpellW.behindpos = unit + (Vector(unit.visionPos.x, unit.visionPos.y, unit.visionPos.z) - Vector(SpellW.pos.x, SpellW.pos.y, SpellW.pos.z)):normalized()*50
			if ZiggsMenu.misc.cast.usePackets then
				Packet("S_CAST", { spellId = _W, toX = SpellW.behindpos.x, toY = SpellW.behindpos.z, fromX = SpellW.behindpos.x, fromY = SpellW.behindpos.z }):send()
			else
				CastSpell(_W, SpellW.behindpos.x, SpellW.behindpos.z)
			end
			return true
		end
	else
		local CastPos, HitChance, Position = vPred:GetCircularCastPosition(unit, SpellW.delay, SpellW.width, SpellW.range, SpellW.speed, myHero, false)
		if HitChance >= 2 then
			SpellW.behindpos = unit + (Vector(unit.visionPos.x, unit.visionPos.y, unit.visionPos.z) - Vector(CastPos.x, CastPos.y, CastPos.z)):normalized()*50
			if ZiggsMenu.misc.cast.usePackets then
				Packet("S_CAST", { spellId = _W, toX = SpellW.behindpos.x, toY = SpellW.behindpos.z, fromX = SpellW.behindpos.x, fromY = SpellW.behindpos.z }):send()
			else
				CastSpell(_W, SpellW.behindpos.x, SpellW.behindpos.z)
			end
			return true
		end
	end
end

function CastE(unit)
	if unit == nil or (GetDistanceSqr(unit) > SpellE.range*SpellE.range) or not SpellE.ready then
		return false
	end

	if ZiggsMenu.predType == 1 then
		SpellE.pos = ProdE:GetPrediction(unit)
		if SpellE.pos ~= nil then
			if ZiggsMenu.misc.cast.usePackets then
				Packet("S_CAST", { spellId = _E, toX = SpellE.pos.x, toY = SpellE.pos.z, fromX = SpellE.pos.x, fromY = SpellE.pos.z }):send()
			else
				CastSpell(_E, SpellE.pos.x, SpellE.pos.z)
			end
			return true
		end
	else
		local CastPos, HitChance, nTargets = vPred:GetCircularAOECastPosition(unit, SpellE.delay, SpellE.width, SpellE.range, SpellE.speed, myHero)
		if HitChance >= 2 then
			if ZiggsMenu.misc.cast.usePackets then
				Packet("S_CAST", { spellId = _E, toX = CastPos.x, toY = CastPos.z, fromX = CastPos.x, fromY = CastPos.z }):send()
			else
				CastSpell(_E, CastPos.x, CastPos.z)
			end
			return true
		end
	end
end


function CastR(unit, mode)
	if unit == nil or (GetDistanceSqr(unit) > ZiggsMenu.misc.umisc.ultRange*ZiggsMenu.misc.umisc.ultRange) or not SpellR.ready then
		return false
	end

	if mode == 1 then
		if ZiggsMenu.predType == 1 then
			SpellR.pos = ProdR:GetPrediction(unit)
			if SpellR.pos ~= nil then
				if ZiggsMenu.misc.cast.usePackets then
					Packet("S_CAST", { spellId = _R, toX = SpellR.pos.x, toY = SpellR.pos.z, fromX = SpellR.pos.x, fromY = SpellR.pos.z }):send()
				else
					CastSpell(_R, SpellR.pos.x, SpellR.pos.z)
				end
				return true
			end
		else
			local CastPos, HitChance, nTargets = vPred:GetCircularAOECastPosition(unit, SpellR.delay, SpellR.width, SpellR.range, SpellR.speed, myHero)
			if HitChance >= ZiggsMenu.misc.umisc.vPredHC then
				if ZiggsMenu.misc.cast.usePackets then
					Packet("S_CAST", { spellId = _R, toX = CastPos.x, toY = CastPos.z, fromX = CastPos.x, fromY = CastPos.z }):send()
				else
					CastSpell(_R, CastPos.x, CastPos.z)
				end
				return true
			end
		end
	else
		local CastPos = GetAoESpellPosition(SpellR.width, unit, SpellR.delay, SpellR.speed)

		if ZiggsMenu.misc.cast.usePackets then
			Packet("S_CAST", { spellId = _R, toX = CastPos.x, toY = CastPos.z, fromX = CastPos.x, fromY = CastPos.z }):send()
		else
			CastSpell(_R, CastPos.x, CastPos.z)
		end
		return true
	end
end

function moveToCursor()
	if GetDistance(mousePos) then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300

		Packet('S_MOVE', { x = moveToPos.x, y = moveToPos.z }):send()
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
			if ValidTarget(Mob, SpellQ.maxrange) then return Mob end
		end
		for _, Mob in pairs(JungleMobs) do
			if ValidTarget(Mob, SpellQ.maxrange) then return Mob end
		end
	end

function DmgCalc()
	for i = 1, enemyCount do
		local enemy = enemyTable[i].player
		if ValidTarget(enemy) and enemy.visible then
			SpellP.dmg = (SpellP.ready and getDmg("P",		enemy, myHero)) or 0
			SpellQ.dmg = (SpellQ.ready and getDmg("Q",		enemy, myHero)) or 0
			SpellW.dmg = (SpellW.ready and getDmg("W",		enemy, myHero)) or 0
			SpellE.dmg = (SpellE.ready and getDmg("E",		enemy, myHero)) or 0
			SpellR.dmg = (SpellR.ready and getDmg("R",		enemy, myHero)) or 0
			SpellI.dmg = (SpellI.ready and getDmg("IGNITE", enemy, myHero)) or 0

			if enemy.health < SpellR.dmg then
				enemyTable[i].indicatorText = "R Kill"
				enemyTable[i].ready = SpellR.ready and SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg then
				enemyTable[i].indicatorText = "Q Kill"
				enemyTable[i].ready = SpellQ.ready and SpellQ.manaUsage <= myHero.mana
			elseif enemy.health < SpellW.dmg then
				enemyTable[i].indicatorText = "W Kill"
				enemyTable[i].ready = SpellW.ready and SpellW.manaUsage <= myHero.mana
			elseif enemy.health < SpellE.dmg then
				enemyTable[i].indicatorText = "E Kill"
				enemyTable[i].ready = SpellE.ready and SpellE.manaUsage <= myHero.mana
			elseif enemy.health < SpellP.dmg then
				enemyTable[i].indicatorText = "P Kill"
				enemyTable[i].ready = SpellP.ready
			elseif enemy.health < SpellQ.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "Q + R Kill"
				enemyTable[i].ready = SpellQ.ready and SpellR.ready and SpellQ.manaUsage + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellP.dmg + SpellQ.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "P + Q + R Kill"
				enemyTable[i].ready = SpellP.ready and SpellQ.ready and SpellR.ready and SpellQ.manaUsage + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellW.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "W + R Kill"
				enemyTable[i].ready = SpellW.ready and SpellR.ready and SpellW.manaUsage + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellP.dmg + SpellW.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "P + W + R Kill"
				enemyTable[i].ready = SpellP.ready and SpellW.ready and SpellR.ready and SpellW.manaUsage + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellE.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "E + R Kill"
				enemyTable[i].ready = SpellE.ready and SpellR.ready and SpellE.manaUsage + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellP.dmg + SpellE.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "P + E + R Kill"
				enemyTable[i].ready = SpellP.ready and SpellE.ready and SpellR.ready and SpellE.manaUsage + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellW.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "Q + W + R Kill"
				enemyTable[i].ready = SpellQ.ready and SpellW.ready and SpellR.ready and SpellQ.manaUsage + SpellW.manaUsage + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellP.dmg + SpellQ.dmg + SpellW.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "P + Q + W + R Kill"
				enemyTable[i].ready = SpellP.ready and SpellQ.ready and SpellW.ready and SpellR.ready and SpellQ.manaUsage + SpellW.manaUsage + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellE.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "Q + E + R Kill"
				enemyTable[i].ready = SpellQ.ready and SpellE.ready and SpellR.ready and SpellQ.manaUsage + SpellE.manaUsage + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellP.dmg + SpellQ.dmg + SpellE.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "P + Q + E + R Kill"
				enemyTable[i].ready = SpellP.ready and SpellQ.ready and SpellE.ready and SpellR.ready and SpellQ.manaUsage + SpellE.manaUsage + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellW.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "Q + W + E + R Kill"
				enemyTable[i].ready = SpellQ.ready and SpellW.ready and SpellE.ready and SpellR.ready and SpellQ.manaUsage + SpellW.manaUsage + SpellE.ready + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellW.dmg + SpellR.dmg + SpellP.dmg then
				enemyTable[i].indicatorText = "All-In Kill"
				enemyTable[i].ready = SpellP.ready and SpellQ.ready and SpellW.ready and SpellE.ready and SpellR.ready and SpellQ.manaUsage + SpellW.manaUsage + SpellE.ready + SpellR.manaUsage <= myHero.mana
			else
				local dmgTotal = SpellP.dmg + SpellQ.dmg + SpellW.dmg + SpellR.dmg
				local hpLeft = math.round(enemy.health - dmgTotal)
				local percentLeft = math.round(hpLeft / enemy.maxHealth * 100)

				enemyTable[i].indicatorText = percentLeft .. "% Harass"
				enemyTable[i].ready = SpellP.ready and SpellQ.ready and SpellW.ready and SpellE.ready and SpellR.ready
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
			if enemy.health < SpellR.dmg then
				CastR(enemy, 1)
			elseif enemy.health < SpellQ.dmg then
				CastQ(enemy)
			elseif enemy.health < SpellW.dmg and ZiggsMenu.ks.useW then
				CastW(enemy)
			elseif enemy.health < SpellE.dmg then
				CastE(enemy)
			elseif enemy.health < SpellQ.dmg + SpellR.dmg and SpellQ.ready and SpellR.ready then
				CastQ(enemy)
			elseif enemy.health < SpellW.dmg + SpellR.dmg and SpellW.ready and SpellR.ready and ZiggsMenu.ks.useW then
				CastW(enemy)
			elseif enemy.health < SpellE.dmg + SpellR.dmg and SpellE.ready and SpellR.ready then
				CastE(enemy)
			elseif enemy.health < SpellQ.dmg + SpellW.dmg + SpellR.dmg and SpellQ.ready and SpellW.ready and SpellR.ready and ZiggsMenu.ks.useW then
				CastW(enemy)
				DelayAction(function()
								CastQ(enemy)
							end, 0.3)
			elseif enemy.health < SpellQ.dmg + SpellE.dmg + SpellR.dmg and SpellQ.ready and SpellE.ready and SpellR.ready then
				CastE(enemy)
				CastQ(enemy)
			elseif enemy.health < SpellQ.dmg + SpellW.dmg + SpellR.dmg and SpellQ.ready and SpellE.ready and SpellR.ready and ZiggsMenu.ks.useW then
				CastW(enemy)
				DelayAction(function()
								CastE(enemy)
								CastQ(enemy)
							end, 0.3)
			end

			if ZiggsMenu.ks.autoIgnite then
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
					PrintAlert(enemy.charName.." can be Killed by Ult", ZiggsMenu.misc.ultAlert.alertTime, 128, 255, 0)

					if ZiggsMenu.misc.ultAlert.Pings then
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

function CustomCollision(unit)
	enemyMinions:update()
	jungleMinions:update()
	otherMinions:update()

	local Col_Vector = {
		FirstBounce = Vector(myHero) + SpellQ.minrange * (Vector(unit) - Vector(myHero)):normalized(),
		SecondBounce = Vector(myHero) + (SpellQ.minrange + (SpellQ.minrange * 0.44711764782193)) * (Vector(unit) - Vector(myHero)):normalized()
	}

	if ZiggsMenu.misc.colMisc.Minions then
		for i, minion in pairs(enemyMinions.objects) do
			if GetDistanceSqr(minion, Col_Vector.FirstBounce) <= SpellQ.width * SpellQ.width and GetDistanceSqr(unit, Col_Vector.FirstBounce) > SpellQ.width * SpellQ.width then
				return true
			end
			if GetDistanceSqr(minion, Col_Vector.SecondBounce) <= SpellQ.width * SpellQ.width and GetDistanceSqr(unit, Col_Vector.SecondBounce) > SpellQ.width * SpellQ.width then
				return true
			end
		end
	end
	if ZiggsMenu.misc.colMisc.Mobs then
		for i, mob in pairs(jungleMinions.objects) do
			if GetDistanceSqr(mob, Col_Vector.FirstBounce) <= SpellQ.width * SpellQ.width and GetDistanceSqr(unit, Col_Vector.FirstBounce) > SpellQ.width * SpellQ.width then
				return true
			end
			if GetDistanceSqr(mob, Col_Vector.SecondBounce) <= SpellQ.width * SpellQ.width and GetDistanceSqr(unit, Col_Vector.SecondBounce) > SpellQ.width * SpellQ.width then
				return true
			end
		end
	end
	if ZiggsMenu.misc.colMisc.Others then
		for i, other in pairs(otherMinions.objects) do
			if GetDistanceSqr(other, Col_Vector.FirstBounce) > SpellQ.width * SpellQ.width and GetDistanceSqr(unit, Col_Vector.FirstBounce) > SpellQ.width * SpellQ.width then
				return true
			end
			if GetDistanceSqr(other, Col_Vector.SecondBounce) > SpellQ.width * SpellQ.width and GetDistanceSqr(unit, Col_Vector.SecondBounce) > SpellQ.width * SpellQ.width then
				return true
			end
		end
	end

	return false
end

function GetCenter(points)
	local sum_x = 0
	local sum_z = 0

	for i = 1, #points do
		sum_x = sum_x + points[i].x
		sum_z = sum_z + points[i].z
	end

	local center = {x = sum_x / #points, y = 0, z = sum_z / #points}

	return center
end

function ContainsThemAll(circle, points)
    local radius_sqr = circle.radius*circle.radius
    local contains_them_all = true
    local i = 1
   
    while contains_them_all and i <= #points do
            contains_them_all = GetDistanceSqr(points[i], circle.center) <= radius_sqr
            i = i + 1
    end
   
    return contains_them_all
end

function FarthestFromPositionIndex(points, position)
	local index = 2
	local actual_dist_sqr
	local max_dist_sqr = GetDistanceSqr(points[index], position)

	for i = 3, #points do
		actual_dist_sqr = GetDistanceSqr(points[i], position)
		if actual_dist_sqr > max_dist_sqr then
			index = i
			max_dist_sqr = actual_dist_sqr
		end
	end

	return index
end

function RemoveWorst(targets, position)
	local worst_target = FarthestFromPositionIndex(targets, position)

	table.remove(targets, worst_target)

	return targets
end

function GetInitialTargets(radius, main_target)
	local targets = {main_target}
	local diameter_sqr = 4 * radius * radius
   
	for i = 1, heroManager.iCount do
		target = heroManager:GetHero(i)
		if target.networkID ~= main_target.networkID and ValidTarget(target) and GetDistanceSqr(main_target, target) < diameter_sqr then table.insert(targets, target) end
	end

	return targets
end

function GetPredictedInitialTargets(radius, main_target, delay, speed, col)
	local predicted_main_target = vPred:GetPredictedPos(main_target, delay, speed, myHero, col)
	local predicted_targets = {predicted_main_target}
	local diameter_sqr = 4 * radius * radius

	for i = 1, heroManager.iCount do
		target = heroManager:GetHero(i)
		if ValidTarget(target) then
			predicted_target = vPred:GetPredictedPos(target, delay, speed, myHero, col)
			if target.networkID ~= main_target.networkID and GetDistanceSqr(predicted_main_target, predicted_target) < diameter_sqr then table.insert(predicted_targets, predicted_target) end
		end
	end

	return predicted_targets
end

function GetAoESpellPosition(radius, main_target, delay, speed)
	local targets = GetPredictedInitialTargets(radius, main_target, delay, speed) 
	local position = GetCenter(targets)
	local best_pos_found = true
	local circle = Circle(position, radius)
	circle.center = position

	if #targets >= ZiggsMenu.misc.mecUlt.minEnemies then best_pos_found = ContainsThemAll(circle, targets) end

	while not best_pos_found do
		targets = RemoveWorst(targets, position)
		position = GetCenter(targets)
		circle.center = position
		best_pos_found = ContainsThemAll(circle, targets)
	end

	return position
end
