local version = "4.140"
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
				- Using SxOrbWalker
				- Overall Improvements (Fixed JungleClear)
				- Added usage of Smite in Combo

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

if myHero.charName ~= "Pantheon" then
	return 
end

_G.Panth_Autoupdate = true

local SxOW_downloadNeeded, SxOW_downloadName = false, "SxOrbWalk"

function AfterDownload()
	SxOW_downloadNeeded = false
	print("<font color=\"#FF0000\">Pantheon - The Artisan of War:</font> <font color=\"#FFFFFF\">Orbwalker library downloaded successfully, please reload (double F9).</font>")
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

if SxOW_downloadNeeded then
	return
end

local script_downloadName = "Pantheon - The Artisan of War"
local script_downloadHost = "raw.github.com"
local script_downloadPath = "/RoachxD/BoL_Scripts/master/Pantheon%20-%20The%20Artisan%20of%20War.lua" .. "?rand=" .. math.random(1, 10000)
local script_downloadUrl = "https://" .. script_downloadHost .. script_downloadPath
local script_filePath = SCRIPT_PATH .. script_downloadName .. ".lua"

function script_Messager(msg) print("<font color=\"#FF0000\">" .. script_downloadName .. ":</font> <font color=\"#FFFFFF\">" .. msg .. ".</font>") end

if _G.Panth_Autoupdate then
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

	if heroManager.iCount < 10 then -- borrowed from Sidas Auto Carry, modified to 3v3
			script_Messager("Too few champions to arrange priorities")
	elseif heroManager.iCount == 6 and TTMAP then
		ArrangeTTPriorities()
	else
		ArrangePriorities()
	end
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

	SpellI = {name = "summonerdot",			range =  600, ready = false, dmg = 0,				variable = nil }

	SmiteSlot = nil;

	enemyMinions = minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_MAXHEALTH_ASC)
    jungleMinions = minionManager(MINION_JUNGLE, 1000, myHero, MINION_SORT_MAXHEALTH_DEC)

	priorityTable = {
			AP = {
				"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
				"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
				"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "VelKoz", "Xerath", "Ziggs", "Zyra"
			},
			Support = {
				"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean"
			},
			Tank = {
				"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai","Nasus", "Rammus",
				"Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear", "Warwick", "Yorick", "Zac"
			},
			AD_Carry = {
				"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw",
				"Kalista", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
				"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
			},
			Bruiser = {
				"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
				"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao", "Gnar"
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

	enemyCount = 0
	enemyTable = {}

	for i = 1, heroManager.iCount do
		local champ = heroManager:GetHero(i)
        
		if champ.team ~= player.team then
			enemyCount = enemyCount + 1
			enemyTable[enemyCount] = { player = champ, indicatorText = "", damageGettingText = "", ultAlert = false, ready = true}
		end
    end
end

function Menu()
	PanthMenu = scriptConfig("Pantheon - The Artisan of War", "Panth")
	
	PanthMenu:addSubMenu(myHero.charName .. ": Combo Settings", "combo")
		PanthMenu.combo:addParam("comboKey", "Full Combo Key (SBTW)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		PanthMenu.combo:addParam("comboItems", "Use Items with Burst", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.combo:addParam("autoSmite", "Use Smite on Target if QWE Available", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.combo:permaShow("comboKey")
	
	PanthMenu:addSubMenu(myHero.charName .. ": Harass Settings", "harass")
		PanthMenu.harass:addParam("harassKey", "Harass key (C)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		PanthMenu.harass:addParam("hMode", "Harass Mode", SCRIPT_PARAM_LIST, 1, { "Q", "W+E" })
		PanthMenu.harass:addParam("autoQ", "Auto-Q when Target in Range", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey('Z'))
		PanthMenu.harass:addParam("aQT", "Don't Auto-Q if in enemy Turret Range", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.harass:addParam("harassMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		PanthMenu.harass:permaShow("harassKey")
		
	
	PanthMenu:addSubMenu(myHero.charName .. ": Farm Settings", "farming")
		PanthMenu.farming:addParam("farmKey", "Farming Key (X)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
		PanthMenu.farming:addParam("qFarm", "Farm with "..SpellQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.farming:addParam("wFarm", "Farm with "..SpellW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.farming:addParam("FarmMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		PanthMenu.farming:permaShow("farmKey")
		
	PanthMenu:addSubMenu(myHero.charName .. ": Jungle Clear Settings", "jungle")
		PanthMenu.jungle:addParam("jungleKey", "Jungle Clear Key (V)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
		PanthMenu.jungle:addParam("jungleQ", "Clear with "..SpellQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.jungle:addParam("jungleW", "Clear with "..SpellW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.jungle:addParam("jungleE", "Clear with "..SpellE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
		
		
	PanthMenu:addSubMenu(myHero.charName .. ": KillSteal Settings", "ks")
		PanthMenu.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.ks:permaShow("killSteal")
			
	PanthMenu:addSubMenu(myHero.charName .. ": Draw Settings", "drawing")	
		PanthMenu.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		PanthMenu.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.drawing:addParam("cDraw", "Draw Damage Text", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.drawing:addParam("qDraw", "Draw "..SpellQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.drawing:addParam("wDraw", "Draw "..SpellW.name.." (W) Range", SCRIPT_PARAM_ONOFF, false)
		PanthMenu.drawing:addParam("eDraw", "Draw "..SpellE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		PanthMenu.drawing:addParam("rDraw", "Draw "..SpellR.name.." (R) Range on the Minimap", SCRIPT_PARAM_ONOFF, true)
	
	PanthMenu:addSubMenu(myHero.charName .. ": Misc Settings", "misc")
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

		PanthMenu:addSubMenu(myHero.charName .. ": Orbwalking Settings", "Orbwalking")
			SxOrb:LoadToMenu(PanthMenu.Orbwalking, false)

	TargetSelector = TargetSelector(TARGET_LESS_CAST, SpellE.range, DAMAGE_PHYSICAL)
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
			SxOrb:DisableAttacks()
			SxOrb:DisableMove()
		else
			SxOrb:EnableAttacks()
			SxOrb:EnableMove()
		end
	end
end

function OnDraw()
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

	SetSmiteSlot()

	Target = GetCustomTarget()
	SxOrb:ForceTarget(Target)

	DmgCalc()
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
	if SxOrb:CanMove() then
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

		if PanthMenu.combo.autoSmite then
			if SmiteSlot ~= nil and myHero:CanUseSpell(SmiteSlot) == READY then
				if SpellQ.ready and SpellW.ready and SpellE.ready then
					CastSpell(SmiteSlot, unit)
				end
			end
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
			if minion.health <= SpellQ.dmg and (GetDistanceSqr(minion) > myHero.range * myHero.range or not SxOrb:CanAttack()) and PanthMenu.farming.qFarm and not isLow('Mana', myHero, PanthMenu.farming.FarmMana) then
				CastQ(minion)
			elseif minion.health <= SpellW.dmg and (GetDistanceSqr(minion) > myHero.range * myHero.range or not SxOrb:CanAttack()) and PanthMenu.farming.wFarm and not isLow('Mana', myHero, PanthMenu.farming.FarmMana) then
				CastW(minion)
			end
		end		 
	end
end

function JungleClear()
	jungleMinions:update()
	if PanthMenu.jungle.jungleKey then
		for _, JungleMob in pairs(jungleMinions.objects) do
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
						--Packet('R_PING',  { x = enemy.x, y = enemy.z, type = PING_FALLBACK }):receive()
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

function SmiteType()
	local Smites = 
	{
		3715, 3718, 3717, 3716, 3714, -- Red Smites
		3706, 3710, 3709, 3708, 3707  -- Blue Smites
	}

	for _, Item in pairs(Smites) do
		if GetInventoryHaveItem(Item) then
			if Item <= 3710 then
				return "s5_summonersmiteplayerganker"
			else
				return "s5_summonersmiteduel"
			end
		end
	end

	return "summonersmite"
end

function SetSmiteSlot()
	if myHero:GetSpellData(SUMMONER_1).name:find(SmiteType()) then
		SmiteSlot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find(SmiteType()) then
		SmiteSlot = SUMMONER_2
	end
end
