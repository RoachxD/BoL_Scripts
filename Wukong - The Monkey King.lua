local version = "3.073"
--[[


			db   d8b   db db    db db   dD  .d88b.  d8b   db  d888b  
			88   I8I   88 88    88 88 ,8P' .8P  Y8. 888o  88 88' Y8b 
			88   I8I   88 88    88 88,8P   88    88 88V8o 88 88      
			Y8   I8I   88 88    88 88`8b   88    88 88 V8o88 88  ooo 
			`8b d8'8b d8' 88b  d88 88 `88. `8b  d8' 88  V888 88. ~8~ 
			 `8b8' `8d8'  ~Y8888P' YP   YD  `Y88P'  VP   V8P  Y888P


		Script - Wukong - The Monkey King 3.0 by Roach

		Dependency: 
			- Nothing

		Changelog:
			3.0
				- Re-wrote the Whole Script
				- Removed the Auto-Pots Options
				- Removed the Auto-Decoy Option
				- Added a lot of features (Check main Post)
				- Fixed Typo
				- Added AA Range on Draw
				- Fixed 'InTurretRange' Function
				- Fixed Spammine Errors
				- Added a check to Enable/Disable myHero.range in the Draw Menu
				- Added an Option to see who are you Targeting
				- Fixed Target Type Selection
				- Fixed Ult not Casting
				- Improved Auto-Updater
				- Fixed a Range bug:
					- Target Selector was selecting the Target in E-Range even if E wasn't available, so this was Lethal in a Team-Fight
				- Using SxOrbWalker
				- Removed "Draw My Hero's Range" Option

			2.6
				- Added Support for SAC and MMA Target Selector
				- Added Summoner Spells as an Exception at Blocking Packets while Wukong is Channeling Ult (VIP USERS)
				- Changed Harass Menu
				- Indented better the Script
				- Fixed Harass Bug while not Using W to Escape
				- Improved Orbwalker
				- Improved Decoy Escape

			2.5
				- Added Auto-Decoy Spells
				- Fixed Ult not Casting
				- Fixed Harass Mode
				- Added Orbwalker to Harass
				- Fixed Farming Bug
				- Added Last Hitter
				- Fixed Auto-Updater

			2.4
				- Added Mana Check for Farming
				- Added Mana Check for Mixed Clear
				- Added Auto-Updater
				- Added Smart Combo: Q-AA-E-AA / E-AA-Q-AA
				- Added Smart Clear: Q-AA-E-AA / E-AA-Q-AA
				- Fixed MEC Ult Bug
				- Improved Ult functionality

			2.3
				- Removed some useless stuff
				- Added Tiamat / Hydra usage in the Clearing Option
				- Added MEC for Ultimate
				- Removed Escape Artist
				- Removed Damage Calculation Draw
				- Added permaShow to 'mecUlt'
				- Changed TargetSelector mode to 'TARGET_LESS_CAST_PRIORITY'
				- Removed Orbwalker from Mixed Clear
				- Fixed Ultimate Canceling Bug

			2.2
				- Fixed Consumables
				- Fixed some typo from the Autocarry Version
				- Added Tiamat and Hydra on the Items List
				- Removed Orbwalker from Lane Clear
				- Fixed Jungle Clear
				- Added a Check to the Harass Option for Decoy (W) to Enable/Disable it while Harassing
				- Addded a third Harass mode: Q+E(+W)
				- Fixed spamming errors

			2.1
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

			1.3
				- Added a new Check for using Q in Harass Mode
				- Fixed Harass Function(Many thanks to Sida for his ideea with the DelayedAction)
				- Rewrote Low Checks Functions
				- Added a new Check for Mana Potions
					- One for Harass/Farm
					- One for Potions
				- Deleted Wooglets Support as an Usable Item

			1.2
				- Fixed Harass Option
				- Changed the way to check if mana is low
				- Added Animation Check

			1.1
				- Fixed bugs

			1.0
				- First Release

--]]

if myHero.charName ~= "MonkeyKing" then return end

_G.Wu_Autoupdate = true

local SxOW_downloadNeeded, SxOW_downloadName = false, "SxOrbWalk"

function AfterDownload()
	SxOW_downloadNeeded = false
	print("<font color=\"#FF0000\">Wukong - The Monkey King:</font> <font color=\"#FFFFFF\">Orbwalker library downloaded successfully, please reload (double F9).</font>")
end

local SxOW_fileName = LIB_PATH .. SxOW_downloadName .. ".lua"

if FileExist(SxOW_fileName) then
	require(SxOW_downloadName)
else
	SxOW_downloadNeeded = true

	LuaSocket = require("socket")
	ScriptSocket = LuaSocket.connect("sx-bol.eu", 80)
	ScriptSocket:send("GET /BoL/TCPUpdater/GetScript.php?script=raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua&rand=" .. tostring(math.random(1000)) .. " HTTP/1.0\r\n\r\n")
	ScriptReceive, ScriptStatus = ScriptSocket:receive('*a')
	ScriptRaw = string.sub(ScriptReceive, string.find(ScriptReceive, "<bols" .. "cript>") + 11, string.find(ScriptReceive, "</bols" .. "cript>") - 1)
	ScriptFileOpen = io.open(SxOW_fileName, "w+")
	ScriptFileOpen:write(ScriptRaw)
	ScriptFileOpen:close()

	DelayAction(function() AfterDownload() end, 0.3)
end

if SxOW_downloadNeeded then return end

local script_downloadName = "Wukong - The Monkey King"
local script_downloadHost = "raw.github.com"
local script_downloadPath = "/RoachxD/BoL_Scripts/master/Wukong%20-%20The%20Monkey%20King.lua".."?rand=" .. math.random(1, 10000)
local script_downloadUrl = "https://"..script_downloadHost..script_downloadPath
local script_filePath = SCRIPT_PATH..script_downloadName .. ".lua"

function script_Messager(msg) print("<font color=\"#FF0000\">" .. script_downloadName .. ":</font> <font color=\"#FFFFFF\">" .. msg .. ".</font>") end

if _G.Wu_Autoupdate then
	local script_webResult = GetWebResult(script_downloadHost, script_downloadPath)
	if script_webResult then
		local script_serverVersion = string.match(script_webResult, "local%s+version%s+=%s+\"%d+.%d+\"")
		
		if script_serverVersion then
			script_serverVersion = tonumber(string.match(script_serverVersion or "", "%d+%.?%d*"))

			if not script_serverVersion then
				script_Messager("Please contact the developer of the script \"" .. script_downloadName .. "\", since the auto updater returned an invalid version.")
				return
			end

			if tonumber(version) < script_serverVersion then
				script_Messager("New version available: " .. script_serverVersion)
				script_Messager("Updating, please don't press F9")
				DelayAction(function () DownloadFile(script_downloadUrl, script_filePath, function() script_Messager("Successfully updated the script, please reload!") end) end, 2)
			else
				script_Messager("You've got the latest version: " .. script_serverVersion)
			end
		end
	else
		script_Messager("Error downloading server version!")
	end
end

function OnLoad()
	Variables()
	Menu()

	HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER") .. os.getenv("USERNAME") .. os.getenv("COMPUTERNAME") .. os.getenv("PROCESSOR_LEVEL") .. os.getenv("PROCESSOR_REVISION")))
	UpdateWeb(true, (string.gsub(script_downloadName, "[^0-9A-Za-z]", "")), 5, HWID)

	if heroManager.iCount < 10 then -- borrowed from Sidas Auto Carry, modified to 3v3
			AutoupdaterMsg("Too few champions to arrange priorities")
	elseif heroManager.iCount == 6 and TTMAP then
		ArrangeTTPriorities()
	else
		ArrangePriorities()
	end
end

function OnUnload()
	UpdateWeb(false, (string.gsub(script_downloadName, "[^0-9A-Za-z]", "")), 5, HWID)
end

function OnTick()
	ComboKey		= WukongMenu.combo.comboKey
	HarassKey		= WukongMenu.harass.harassKey
	FarmKey			= WukongMenu.farming.farmKey
	JungleClearKey	= WukongMenu.jungle.jungleKey

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

	if WukongMenu.harass.autoQ then
		if (WukongMenu.harass.aQT and not InEnemyTurretRange(myHero)) or not WukongMenu.harass.aQT then
			CastQ(Target)
		end
	end

	if WukongMenu.ks.killSteal then
		KillSteal()
	end

	if WukongMenu.misc.ult.Enable then
		if CountEnemyHeroInRange(SpellR.range) >= WukongMenu.misc.ult.minEnemies and myHero:GetSpellData(_R).name ~= "monkeykingspintowinleave" then
			CastSpell(_R)
		end
	end

	TickChecks()
end

function Variables()
	if GetGame().map.shortName == "twistedTreeline" then
		TTMAP = true
	else
		TTMAP = false
	end

	SpellQ = { name = "Crushing Blow",	range = 300  , ready = false, dmg = 0, manaUsage = 0					}
	SpellE = { name = "Nimbus Strike",	range = 625  , ready = false, dmg = 0, manaUsage = 0					}
	SpellR = { name = "Cyclone",		range = 162.5, ready = false, dmg = 0, manaUsage = 0					}

	SpellI = { name = "SummonerDot",	range = 600  , ready = false, dmg = 0,					variable = nil	}

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
			ADC = {
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
	WukongMenu = scriptConfig("Wukong - The Monkey King", "Wu")
	
	WukongMenu:addSubMenu("[" .. myHero.charName .. "] - Combo Settings", "combo")
		WukongMenu.combo:addParam("comboKey", "Full Combo Key (SBTW)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		WukongMenu.combo:addParam("smartCombo", "Use Smart Combo", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.combo:addParam("comboItems", "Use Items with Burst", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.combo:addParam("useUlt", SpellR.name .. " (R): ", SCRIPT_PARAM_LIST, 3, { "Always", "If Killable", "No" })
		WukongMenu.combo:permaShow("comboKey")
	
	WukongMenu:addSubMenu("[" .. myHero.charName .. "] - Harass Settings", "harass")
		WukongMenu.harass:addParam("harassKey", "Harass key (C)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		WukongMenu.harass:addParam("smartHarass", "Use Smart Harass", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.harass:addParam("hMode", "Harass Mode", SCRIPT_PARAM_LIST, 3, { "E + Q", "E", "Q+E" })
		WukongMenu.harass:addParam("autoQ", "Auto-Q when Target in Range", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey('Z'))
		WukongMenu.harass:addParam("aQT", "Don't Auto-Q if in enemy Turret Range", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.harass:addParam("harassMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		WukongMenu.harass:permaShow("harassKey")
		
	
	WukongMenu:addSubMenu("[" .. myHero.charName .. "] - Farm Settings", "farming")
		WukongMenu.farming:addParam("farmKey", "Farming Key (X)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
		WukongMenu.farming:addParam("qFarm", "Farm with " .. SpellQ.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.farming:addParam("eFarm", "Farm with " .. SpellE.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.farming:addParam("FarmMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		WukongMenu.farming:permaShow("farmKey")
		
	WukongMenu:addSubMenu("[" .. myHero.charName .. "] - Jungle Clear Settings", "jungle")
		WukongMenu.jungle:addParam("jungleKey", "Jungle Clear Key (V)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
		WukongMenu.jungle:addParam("smartClear", "Use Smart Jungle Clear", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.jungle:addParam("jungleQ", "Clear with " .. SpellQ.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.jungle:addParam("jungleE", "Clear with " .. SpellE.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.jungle:permaShow("jungleKey")
		
		
	WukongMenu:addSubMenu("[" .. myHero.charName .. "] - KillSteal Settings", "ks")
		WukongMenu.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.ks:addParam("useUlt", "Use " .. SpellR.name .. " (R) to KS", SCRIPT_PARAM_ONOFF, false)
		WukongMenu.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.ks:permaShow("killSteal")
			
	WukongMenu:addSubMenu("[" .. myHero.charName .. "] - Draw Settings", "drawing")	
		WukongMenu.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		WukongMenu.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.drawing:addParam("cDraw", "Draw Damage Text", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.drawing:addParam("qDraw", "Draw " .. SpellQ.name .. " (Q) Range", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.drawing:addParam("eDraw", "Draw " .. SpellE.name .. " (E) Range", SCRIPT_PARAM_ONOFF, true)
		WukongMenu.drawing:addParam("rDraw", "Draw " .. SpellR.name .. " (R) Range", SCRIPT_PARAM_ONOFF, true)
	
	WukongMenu:addSubMenu("[" .. myHero.charName .. "] - Misc Settings", "misc")
		WukongMenu.misc:addSubMenu("Spells - Misc Settings", "smisc")
			WukongMenu.misc.smisc:addParam("stopChannel", "Interrupt Channeling Spells", SCRIPT_PARAM_ONOFF, true)
		if VIP_USER then
			WukongMenu.misc:addSubMenu("Spells - Cast Settings", "cast")
				WukongMenu.misc.cast:addParam("usePackets", "Use Packets to Cast Spells", SCRIPT_PARAM_ONOFF, false)
		end
		WukongMenu.misc:addSubMenu("Spells - Ultimate Settings", "ult")
			WukongMenu.misc.ult:addParam("Enable", "Enable Ult MEC", SCRIPT_PARAM_ONOFF, true)
			WukongMenu.misc.ult:addParam("minEnemies", "Min. Enemies in Range: ", SCRIPT_PARAM_SLICE, 2, 2, 5, 0)

		WukongMenu:addSubMenu("[" .. myHero.charName .. "] - Orbwalking Settings", "Orbwalking")
			SxOrb:LoadToMenu(WukongMenu.Orbwalking, false)

	TargetSelector = TargetSelector(TARGET_LESS_CAST, SpellE.range, DAMAGE_PHYSICAL)
	TargetSelector.name = "Wukong"
	WukongMenu:addTS(TargetSelector)

	WukongMenu:addParam("wuVer", "Version: ", SCRIPT_PARAM_INFO, version)
end

function OnProcessSpell(unit, spell)
	if WukongMenu.misc.smisc.stopChannel then
		if GetDistanceSqr(unit) <= SpellR.range * SpellR.range and myHero:GetSpellData(_R).name ~= "monkeykingspintowinleave" then
			if InterruptingSpells[spell.name] then
				CastSpell(_R)
			end
		end
		if unit.isMe then 
			if spell.name == "MonkeyKingDecoy" then
				SxOrb:DisableAttacks()
				DelayAction(function()
								SxOrb:EnableAttacks()
							end, 1.5)
			end
			if spell.name == "MonkeyKingSpinToWin" then
				SxOrb:DisableAttacks()
				DelayAction(function()
								SxOrb:EnableAttacks()
							end, 4.0)
			end
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
	if not myHero.dead then
		if not WukongMenu.drawing.mDraw then
			if WukongMenu.drawing.qDraw and SpellQ.ready then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.range, ARGB(255,178, 0 , 0 ))
			end
			if WukongMenu.drawing.eDraw and SpellE.ready then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.range, ARGB(255, 32,178,170))
			end
			if WukongMenu.drawing.rDraw and SpellR.ready then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.range, ARGB(255,128, 0 ,128))
			end
		end
		if WukongMenu.drawing.Target then
			if Target ~= nil then
				DrawCircle3D(Target.x, Target.y, Target.z, 70, 1, ARGB(255, 255, 0, 0))
			end
		end
		if WukongMenu.drawing.cDraw then
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
	UpdateWeb(false, (string.gsub(script_downloadName, "[^0-9A-Za-z]", "")), 5, HWID)
end

function TickChecks()
	-- Checks if Spells Ready
	SpellQ.ready = (myHero:CanUseSpell(_Q) == READY)
	SpellE.ready = (myHero:CanUseSpell(_E) == READY)
	SpellR.ready = (myHero:CanUseSpell(_R) == READY)

	SpellQ.manaUsage = myHero:GetSpellData(_Q).mana
	SpellE.manaUsage = myHero:GetSpellData(_E).mana
	SpellR.manaUsage = myHero:GetSpellData(_R).mana

	if myHero:GetSpellData(SUMMONER_1).name:find(SpellI.name) then
		SpellI.variable = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find(SpellI.name) then
		SpellI.variable = SUMMONER_2
	end
	SpellI.ready = (SpellI.variable ~= nil and myHero:CanUseSpell(SpellI.variable) == READY)

	TargetSelector.range = TargetSelectorRange()
	Target = GetCustomTarget()
	SxOrb:ForceTarget(Target)

	DmgCalc()

	if not ComboKey and not FarmKey and not HarassKey and not JungleClearKey then
		for i, cb in ipairs(SxOrb.AfterAttackCallbacks) do
			table.remove(SxOrb.AfterAttackCallbacks, i)
		end
	end

	if GetGame().isOver then
		UpdateWeb(false, (string.gsub(script_downloadName, "[^0-9A-Za-z]", "")), 5, HWID)
	end
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
		if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
			CastItem(Item.id, unit)
		end
	end
end

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		if WukongMenu.combo.comboItems then
			UseItems(unit)
		end
		
		if WukongMenu.combo.smartCombo then
			if GetDistanceSqr(unit) > SxOrb.MyRange * SxOrb.MyRange then
				CastE(unit)
				SxOrb:RegisterAfterAttackCallback(CastQ)
			else
				SxOrb:RegisterAfterAttackCallback(CastQ)
				if not SpellQ.ready then
					DelayAction(function()
									SxOrb:RegisterAfterAttackCallback(CastE)
								end, 0.3)
				end
			end
		else
			if GetDistanceSqr(unit) > SxOrb.MyRange * SxOrb.MyRange then
				CastE(unit)
				CastQ(unit)
			else
				CastQ(unit)
				if not SpellQ.ready then
					CastE(unit)
				end
			end
		end

		if WukongMenu.combo.useUlt ~= 3 then
			if WukongMenu.combo.useUlt ~= 1 then
				if GetDistanceSqr(unit) <= SpellR.range * SpellR.range and myHero:GetSpellData(_R).name ~= "monkeykingspintowinleave" then
					CastSpell(_R)
				end
			else
				if unit.health < SpellR.dmg and GetDistanceSqr(unit) <= SpellR.range * SpellR.range and myHero:GetSpellData(_R).name ~= "monkeykingspintowinleave" then
					CastSpell(_R)
				end
			end
		end
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		if not isLow('Mana', myHero, WukongMenu.harass.harassMana) then
			--- Harass Mode 1 E + Q ---
			if WukongMenu.harass.hMode == 1 then
				if WukongMenu.harass.smartHarass then
					if GetDistanceSqr(unit) > SxOrb.MyRange * SxOrb.MyRange then
						CastE(unit)
					else
						SxOrb:RegisterAfterAttackCallback(CastE)
					end
					SxOrb:RegisterAfterAttackCallback(CastQ)
				else
					CastE(unit)
					CastQ(unit)
				end
			end

			--- Harass Mode 2 E ---
			if WukongMenu.harass.hMode == 2 then
				if WukongMenu.harass.smartHarass then
					if GetDistanceSqr(unit) > SxOrb.MyRange * SxOrb.MyRange then
						CastE(unit)
					else
						SxOrb:RegisterAfterAttackCallback(CastE)
					end
				else
					CastE(unit)
				end
			end

			--- Harass Mode 3 Q + E ---
			if WukongMenu.harass.hMode == 3 then
				if WukongMenu.harass.smartHarass then
					SxOrb:RegisterAfterAttackCallback(CastQ)
					if not SpellQ.ready then
						SxOrb:RegisterAfterAttackCallback(CastE)
					end
				else
					if GetDistanceSqr(unit) < SxOrb.MyRange * SxOrb.MyRange then
						CastQ(unit)
						CastE(unit)
					end
				end
			end
		end
	end
end

function Farm()
	enemyMinions:update()
	for i, minion in pairs(enemyMinions.objects) do
		if ValidTarget(minion) and minion ~= nil then
			if minion.health <= SpellQ.dmg and not SxOrb:CanAttack() and WukongMenu.farming.qFarm and not isLow('Mana', myHero, WukongMenu.farming.FarmMana) then
				CastQ(minion)
			end
			if minion.health <= SpellE.dmg and (GetDistanceSqr(minion) > SxOrb.MyRange * SxOrb.MyRange or not SxOrb:CanAttack()) and WukongMenu.farming.eFarm and not isLow('Mana', myHero, WukongMenu.farming.FarmMana) then
				CastE(minion)
			end
		end		 
	end
end

function JungleClear()
	if WukongMenu.jungle.jungleKey then
		local JungleMob = GetJungleMob()
		if JungleMob ~= nil then
			if WukongMenu.jungle.jungleQ and GetDistanceSqr(JungleMob) <= SpellQ.range * SpellQ.range then
				if WukongMenu.jungle.smartClear then
					SxOrb:RegisterAfterAttackCallback(CastQ)
				else
					CastQ(unit)
				end
			end
			if WukongMenu.jungle.jungleE and GetDistanceSqr(JungleMob) <= SpellE.range * SpellE.range then
				if WukongMenu.jungle.smartClear then
					DelayAction(function()
									if GetDistanceSqr(JungleMob) > SxOrb.MyRange * SxOrb.MyRange and not SpellQ.ready then
										CastE(JungleMob)
									else
										SxOrb:RegisterAfterAttackCallback(CastE)
									end
								end, 0.3)
				else
					CastE(JungleMob)
				end
			end
		end
	end
end

function CastQ(unit)
	if unit == nil or not SpellQ.ready or (GetDistanceSqr(unit, myHero) > SpellQ.range * SpellQ.range) then
		return false
	end

	if not VIP_USER or not WukongMenu.misc.cast.usePackets then
		CastSpell(_Q, unit)
	elseif VIP_USER and WukongMenu.misc.cast.usePackets then
		Packet("S_CAST", { spellId = _Q, targetNetworkId = unit.networkID }):send()
	end
	myHero:Attack(unit)
end

function CastE(unit)
	if unit == nil or not SpellE.ready or (GetDistanceSqr(unit) > SpellE.range * SpellE.range) then
		return false
	end

	if not VIP_USER or not WukongMenu.misc.cast.usePackets then
		CastSpell(_E, unit)
	else
		Packet("S_CAST", { spellId = _E, targetNetworkId = unit.networkID }):send()
	end
end

function ArrangePriorities()
	for i = 1, enemyCount do
		local enemy = enemyTable[i].player
		SetPriority(priorityTable.ADC, enemy, 1)
		SetPriority(priorityTable.AP, enemy, 2)
		SetPriority(priorityTable.Support, enemy, 3)
		SetPriority(priorityTable.Bruiser, enemy, 4)
		SetPriority(priorityTable.Tank, enemy, 5)
	end
end

function ArrangeTTPriorities()
	for i = 1, enemyCount do
		local enemy = enemyTable[i].player
		SetPriority(priorityTable.ADC, enemy, 1)
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

function TargetSelectorRange()
	return SpellE.ready and SpellE.range or SpellQ.range
end

function DmgCalc()
	for i = 1, enemyCount do
		local enemy = enemyTable[i].player
		if ValidTarget(enemy) and enemy.visible then
			SpellQ.dmg = (SpellQ.ready and getDmg("Q",		enemy, myHero	)) or 0
			SpellE.dmg = (SpellE.ready and getDmg("E",		enemy, myHero	)) or 0
			SpellR.dmg = (SpellR.ready and getDmg("R",		enemy, myHero, 3)) or 0
			SpellI.dmg = (SpellI.ready and getDmg("IGNITE", enemy, myHero	)) or 0

			if enemy.health < SpellQ.dmg then
				enemyTable[i].indicatorText = "Q Kill"
				enemyTable[i].ready = SpellQ.ready and SpellQ.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellI.dmg then
				enemyTable[i].indicatorText = "Q + Ign Kill"
				enemyTable[i].ready = SpellQ.ready and SpellI.ready and SpellQ.manaUsage <= myHero.mana
			elseif enemy.health < SpellE.dmg then
				enemyTable[i].indicatorText = "E Kill"
				enemyTable[i].ready = SpellE.ready and SpellE.manaUsage <= myHero.mana
			elseif enemy.health < SpellE.dmg + SpellI.dmg then
				enemyTable[i].indicatorText = "E + Ign Kill"
				enemyTable[i].ready = SpellE.ready and SpellI.ready and SpellE.manaUsage <= myHero.mana
			elseif enemy.health < SpellR.dmg then
				enemyTable[i].indicatorText = "R Kill"
				enemyTable[i].ready = SpellR.ready and SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellR.dmg + SpellI.dmg then
				enemyTable[i].indicatorText = "R + Ign Kill"
				enemyTable[i].ready = SpellR.ready and SpellI.ready and SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellE.dmg then
				enemyTable[i].indicatorText = "E + Q Kill"
				enemyTable[i].ready = SpellQ.ready and SpellE.ready and SpellQ.manaUsage + SpellE.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellE.dmg + SpellI.dmg then
				enemyTable[i].indicatorText = "E + Q + Ign Kill"
				enemyTable[i].ready = SpellQ.ready and SpellE.ready and SpellI.ready and SpellQ.manaUsage + SpellE.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellE.dmg + SpellR.dmg then
				enemyTable[i].indicatorText = "E + Q + R Kill"
				enemyTable[i].ready = SpellQ.ready and SpellE.ready and SpellR.ready and SpellQ.manaUsage + SpellE.manaUsage + SpellR.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellE.dmg + SpellR.dmg + SpellI.dmg then
				enemyTable[i].indicatorText = "E + Q + R + Ign Kill"
				enemyTable[i].ready = SpellQ.ready and SpellE.ready and SpellR.ready and SpellI.ready and SpellQ.manaUsage + SpellE.manaUsage + SpellR.manaUsage <= myHero.mana
			else
				local dmgTotal = SpellQ.dmg + SpellE.dmg + SpellR.dmg
				local hpLeft = math.round(enemy.health - dmgTotal)
				local percentLeft = math.round(hpLeft / enemy.maxHealth * 100)

				enemyTable[i].indicatorText = percentLeft .. "% Harass"
				enemyTable[i].ready = SpellQ.ready and SpellE.ready and SpellR.ready
			end

			local enemyAD = getDmg("AD", myHero, enemy)

			enemyTable[i].damageGettingText = enemy.charName .. " kills me with " .. math.ceil(myHero.health / enemyAD) .. " hits"
		end
	end
end

function KillSteal()
	for i = 1, enemyCount do
		local enemy = enemyTable[i].player
		if ValidTarget(enemy) and enemy.visible then
			if enemy.health < SpellQ.dmg and SpellQ.ready then
				CastQ(enemy)
			elseif enemy.health < SpellE.dmg and SpellE.ready then
				CastE(enemy)
			elseif enemy.health < SpellR.dmg and SpellR.ready and WukongMenu.ks.useUlt then
				CastSpell(_R)
			elseif enemy.health < SpellQ.dmg + SpellE.dmg and SpellQ.ready and SpellE.ready then
				CastE(enemy)
			elseif enemy.health < SpellQ.dmg + SpellE.dmg + SpellR.dmg and SpellQ.ready and SpellE.ready and SpellR.ready and WukongMenu.ks.useUlt then
				CastE(enemy)
				DelayAction(function()
								CastQ(enemy)
							end, 0.3)
			end

			if WukongMenu.ks.autoIgnite then
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

-- UpdateWeb
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
