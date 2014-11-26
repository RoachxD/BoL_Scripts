_G.Gnar_Version = 1.03
--[[


		 d888b  d8b   db  .d8b.  d8888b.
		88' Y8b 888o  88 d8' `8b 88  `8D
		88      88V8o 88 88ooo88 88oobY'
		88  ooo 88 V8o88 88~~~88 88`8b
		88. ~8~ 88  V888 88   88 88 `88.
		 Y888P  VP   V8P YP   YP 88   YD

	Script - Gnar - The Missing Link 1.03

	Changelog:
		1.0a
			- Pre-Release

		1.01
			- Official Release (Champion Released)

		1.02
			- Updated Values of the Spells
			- Both Forms are fully working
			- Fixed W not working on Mega Form
			- Fixed Damage Calculations
			- Fixed Spells not casting
			- Fixed a Menu bug
			- Fixed E not casting in Mega Form
			- Fixed bug where AA wasn't reset after using E in Mini Form (Update your SOW)
			- Fixed farming Bug where Gnar was farming with Spells even if the options were disabled in the Menu
			- Fixed a bug where Gnar would not cast E or W in Mega Form
			- Added option to Stun enemies in Ally turrets when the Aggro is on them
			- Added Q-Catcher Helper (Drawing)
			- Fixed Unit-Hop and added a Cool feature to jump on Pets
			- Re-wrote Ult Function and Tested it, works like a charm

		1.03
			- I am back to Work (I guess this shouldn't be here) - That's all I've got to say, for now!
			- Changed Gnar's Spell Values, will work much better
			- Indented Better the Script
			- Removed Auto-Catch Option Completely
			- Rewrote all Spell Functions
			- Improved Ult Functionality
			- Removed Damage Calculations (Will write other function in a future version)
			- Changed Farm Menu
			- Improved Q Collision
			- Fixed every other Bug
]]--

if myHero.charName ~= "Gnar" then return end

function Script_SendMessage(message)
	if message == nil then
		return end

	print("<font color=\"#FF0000\">Gnar - The Missing Link:</font> <font color=\"#FFFFFF\">" .. message .. ".</font>")
end

_G.Gnar_Autoupdate = true

local lib_Required =
{
	["Prodiction"]	= "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua",
	["SxOrbWalk"]	= "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
	["VPrediction"]	= "https://raw.githubusercontent.com/Hellsing/BoL/master/Common/VPrediction.lua"
}

local lib_downloadNeeded, lib_downloadCount = false, 0

function AfterDownload()
	lib_downloadCount = lib_downloadCount - 1

	if lib_downloadCount == 0 then
		lib_downloadNeeded = false
		Script_SendMessage("Required libraries downloaded successfully, please reload (double F9)")
	end
end

if not VIP_USER then
	lib_Required["Prodiction"] = nil
end

for lib_downloadName, lib_downloadUrl in pairs(lib_Required) do
	local lib_fileName = LIB_PATH .. lib_downloadName .. ".lua"

	if FileExist(lib_fileName) then
		require(lib_downloadName)
	else
		lib_downloadNeeded = true
		lib_downloadCount = lib_downloadCount and lib_downloadCount + 1 or 1

		DownloadFile(lib_downloadUrl, lib_fileName, function() AfterDownload() end)
	end
end

if lib_downloadNeeded then return end

local script_downloadName = "Gnar - The Missing Link"
local script_downloadHost = "raw.github.com"
local script_downloadPath = "/RoachxD/BoL_Scripts/master/" .. script_downloadName:gsub(" ", "%%20") .. ".lua?rand=" .. tostring(math.random(1000))
local script_downloadUrl = "https://" .. script_downloadHost .. script_downloadPath
local script_filePath = SCRIPT_PATH .. GetCurrentEnv().FILE_NAME .. ".lua"

if _G.Gnar_Autoupdate then
	local script_webResult = GetWebResult(script_downloadHost, script_downloadPath)

	if script_webResult then
		local script_serverVersion = string.match(script_webResult, "_G.Gnar_Version%s+=%s+%d+%.%d+")

		if script_serverVersion then
			script_serverVersion = tonumber(string.match(script_serverVersion or "", "%d+%.%d+"))

			if not script_serverVersion then
				Script_SendMessage("The Auto-Updater returned an invalid Version, please contact the Developer of the Script")

				return
			end

			if _G.Gnar_Version < script_serverVersion then
				Script_SendMessage("New version available: " .. script_serverVersion)
				Script_SendMessage("Updating, please don't press F9")

				DelayAction(
					function() 
						DownloadFile(script_downloadUrl, script_filePath,
							function()
								Script_SendMessage("Successfully updated from " .. _G.Gnar_Version .. " to " .. script_serverVersion .. "), press F9 twice to load the updated version")
							end
						)
					end, 2
				)
			else
				Script_SendMessage("You've got the latest version: " .. script_serverVersion)
			end
		else
			Script_SendMessage("The Auto-Updater returned an invalid Version, please contact the Developer of the Script")
		end
	else
		Script_SendMessage("The Auto-Updater couldn't download Script's Informations, please contact the Developer of the Script")
	end
end

function OnLoad()
	Variables()
	Menu()

	if heroManager.iCount < 10 then -- borrowed from Sidas Auto Carry, modified to 3v3
		Script_SendMessage("Too few champions to arrange priorities")
	elseif heroManager.iCount == 6 and TTMAP then
		ArrangeTTPriorities()
	else
		ArrangePriorities()
	end
end


function OnTick()
	ComboKey		= GnarMenu.combo.comboKey
	HarassKey		= GnarMenu.harass.harassKey
	FarmKey			= GnarMenu.farming.farmKey
	JungleClearKey	= GnarMenu.jungle.jungleKey
	HopKey			= GnarMenu.misc.hop.UnitHop

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

	if HopKey then
		if GnarMenu.misc.hop.MTCUnitHop then
			moveToCursor()
		end

		UnitHop()
	end

	if GnarMenu.ks.killSteal then
		KillSteal()
	end

	if GnarMenu.misc.mec.Enable then
		for i, enemy in pairs(GetEnemyHeroes()) do
			CastR(GnarMenu.misc.mec.minEnemies, GnarMenu.misc.mec.accuracy)
		end
	end

	TickChecks()
end


function Variables()
	SpellP = { name = "Rage Gene",																enabled = false									 }

	SpellQ =
	{
		mini = { name = "Boomerang Throw",	range = 1100, delay = 0.066, speed = 1400, width =  60, ready = false, pos = nil, dmg = 0			 },
		mega = { name = "Boulder Toss",		range = 1100, delay = 0.060, speed = 2100, width =  90, ready = false, pos = nil, dmg = 0			 }
	}

	SpellW =
	{
		mega = { name = "Wallop",			range =  525, delay = 0.25, speed =	1200, width =  80, ready = false, pos = nil, dmg = 0		 	 }
	}

	SpellE =
	{
		mini = { name = "Hop",				range =  475, delay = 0.695, speed = 2000, width = 150, ready = false, pos = nil, dmg = 0			 },
		mega = { name = "Crunch",			range =  475, delay = 0.695, speed = 2000, width = 350, ready = false, pos = nil, dmg = 0			 }
	}

	SpellR =
	{
		mega = { name = "GNAR!",			range =  590, delay = 0.066, speed = 1400, width = 400, ready = false, pos = nil, dmg = 0			 }
	}

	SpellI = { name = "SummonerDot",		range =  600,									   ready = false,			 dmg = 0, variable = nil }

	SpellW_= {								range =  300, 									   lastJump = 0										 }

	vPred = VPrediction()

	priorityTable =
	{
			AP =
			{
				"Annie", "Ahri", "Akali", "Anivia", "Annie", "Azir", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger",
				"Karthus", "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
				"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "VelKoz", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra"
			},
			Support =
			{
				"Alistar", "Blitzcrank", "Braum", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean"
			},
			Tank =
			{
				"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
				"Warwick", "Yorick", "Zac"
			},
			AD_Carry =
			{
				"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
				"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
			},
			Bruiser =
			{
				"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Gnar", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
				"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
			}
		}

	InterruptingSpells =
	{
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

	Items =
	{
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

	allyMinions = minionManager(MINION_ALLY, SpellQ.mini.range, myHero)
	enemyMinions = minionManager(MINION_ENEMY, SpellQ.mini.range, myHero)
	jungleMinions = minionManager(MINION_JUNGLE, SpellQ.mini.range, myHero)
	petMinions = minionManager(MINION_OTHER, SpellQ.mini.range, myHero)

	petNames = { "annietibbers", "shacobox", "malzaharvoidling", "heimertyellow", "heimertblue", "yorickdecayedghoul" }

	buffTypes = { BUFF_STUN, BUFF_ROOT, BUFF_KNOCKUP, BUFF_SUPPRESS, BUFF_SLOW, BUFF_CHARM, BUFF_FEAR, BUFF_TAUNT }

	qObject = { variable = nil, endVariable = nil }
end

function Menu()
	GnarMenu = scriptConfig("Gnar - The Missing Link", "Gnar")
	
	GnarMenu:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		GnarMenu.combo:addParam("comboKey", "Full Combo Key (SBTW)", SCRIPT_PARAM_ONKEYDOWN, false, 32) -- Done
		GnarMenu.combo:addParam("useR", "Use " .. SpellR.mega.name .. " (R): ", SCRIPT_PARAM_LIST, 3, { "If Target Killable", "With Burst", "No" })
		GnarMenu.combo:addParam("comboItems", "Use Items with Burst", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.combo:permaShow("comboKey") -- Done
	
	GnarMenu:addSubMenu("["..myHero.charName.."] - Harass Settings", "harass") -- Done
		GnarMenu.harass:addParam("harassKey", "Harass key (C)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C")) -- Done
		GnarMenu.harass:addParam("qminiHarass", "Use " .. SpellQ.mini.name .. " (Q) to Harass", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.harass:addParam("qmegaHarass", "Use " .. SpellQ.mega.name .. " (Q) to Harass", SCRIPT_PARAM_ONOFF, false) -- Done
		GnarMenu.harass:addParam("wmegaHarass", "Use " .. SpellW.mega.name .. " (W) to Harass", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.harass:permaShow("harassKey") -- Done
		
	
	GnarMenu:addSubMenu("["..myHero.charName.."] - Farm Settings", "farming") -- Done
		GnarMenu.farming:addParam("qminiFarm", "Use " .. SpellQ.mini.name .. " (Q)", SCRIPT_PARAM_LIST, 3, { "No", "Freeze", "LaneClear", "Both" }) -- Done
		GnarMenu.farming:addParam("qmegaFarm", "Use " .. SpellQ.mega.name .. " (Q)", SCRIPT_PARAM_LIST, 3, { "No", "Freeze", "LaneClear", "Both" }) -- Done
		GnarMenu.farming:addParam("wmegaFarm", "Use " .. SpellW.mega.name .. " (W)", SCRIPT_PARAM_LIST, 3, { "No", "Freeze", "LaneClear", "Both" }) -- Done
		GnarMenu.farming:permaShow("farmKey") -- Done
		
	GnarMenu:addSubMenu("["..myHero.charName.."] - Jungle Clear Settings", "jungle") -- Done
		GnarMenu.jungle:addParam("qminiJungle", "Clear with " .. SpellQ.mini.name .. " (Q)", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.jungle:addParam("qmegaJungle", "Clear with " .. SpellQ.mega.name .. " (Q)", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.jungle:addParam("wmegaJungle", "Clear with " .. SpellW.mega.name .. " (W)", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.jungle:addParam("emegaJungle", "Clear with " .. SpellE.mega.name .. " (E)", SCRIPT_PARAM_ONOFF, true) -- Done
		
		
	GnarMenu:addSubMenu("["..myHero.charName.."] - KillSteal Settings", "ks") -- Done
		GnarMenu.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.ks:addParam("useR", "Use " .. SpellR.mega.name .. " (R) to KS", SCRIPT_PARAM_ONOFF, false) -- Done
		GnarMenu.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.ks:permaShow("killSteal") -- Done
			
	GnarMenu:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing") -- Done
		GnarMenu.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false) -- Done
		GnarMenu.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.drawing:addParam("catcher", "Draw Q-Catch Helper", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.drawing:addParam("qDraw", "Draw " .. SpellQ.mini.name .. ' / ' .. SpellQ.mega.name .. " (Q) Range", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.drawing:addParam("wDraw", "Draw " .. SpellW.mega.name .. " (W) Range", SCRIPT_PARAM_ONOFF, false) -- Done
		GnarMenu.drawing:addParam("eDraw", "Draw " .. SpellE.mini.name .. ' / ' .. SpellE.mega.name .. " (E) Range", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.drawing:addParam("rDraw", "Draw " .. SpellR.mega.name .. " (R) Range", SCRIPT_PARAM_ONOFF, true) -- Done
	
	GnarMenu:addSubMenu("["..myHero.charName.."] - Misc Settings", "misc") -- Done
		GnarMenu.misc:addSubMenu("Spells - Hop Settings", "hop") -- Done
			GnarMenu.misc.hop:addParam("UnitHop", "Unit-Hop (G)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('G')) -- Done
			GnarMenu.misc.hop:addParam("MTCUnitHop", "Move to Cursor while Unit-Hoping", SCRIPT_PARAM_ONOFF, false) -- Done
			GnarMenu.misc.hop:addParam("warn", "Don't jump if in Mega-Form", SCRIPT_PARAM_ONOFF, false) -- Done
		GnarMenu.misc:addSubMenu("Spells - " .. SpellQ.mini.name .. " (Q) Settings", "miniQ")
			GnarMenu.misc.miniQ:addParam("ccTarget", "Auto-MiniQ at CCed Targets", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.misc:addSubMenu("Spells - " .. SpellQ.mega.name .. " (Q) Settings", "megaQ") -- Done
			GnarMenu.misc.megaQ:addParam("howTo", "Use " .. SpellQ.mega.name .. " (Q): ", SCRIPT_PARAM_LIST, 1, { "If outside of Melee Range", "When Available" }) -- Done
		GnarMenu.misc:addSubMenu("Spells - " .. SpellW.mega.name .. " (W) Settings", "megaW") -- Done
			GnarMenu.misc.megaW:addParam("interrupt", "Auto-interrupt Channeling Spells with " .. SpellW.mega.name .. " (W)", SCRIPT_PARAM_ONOFF, true) -- Done
			GnarMenu.misc.megaW:addParam("turretAggro", "Try to stun enemies in allied Turret Range", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.misc:addSubMenu("Spells - " .. SpellE.mega.name .. " (E) Settings", "megaE") -- Done
			GnarMenu.misc.megaE:addParam("howTo", "Use " .. SpellE.mega.name .. " (E): ", SCRIPT_PARAM_LIST, 1, { "If outside of Melee Range", "When Available" }) -- Done
		GnarMenu.misc:addSubMenu("Spells - " .. SpellR.mega.name .. " (R) Settings", "megaR") -- Done
			GnarMenu.misc.megaR:addParam("interrupt", "Auto-interrupt Channeling Spells with " .. SpellR.mega.name .. " (R)", SCRIPT_PARAM_ONOFF, false) -- Done
			GnarMenu.misc.megaR:addParam("turretAggro", "Try to stun enemies in allied Turret Range", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.misc:addSubMenu("Spells - " .. SpellR.mega.name .. " (R) MEC Settings", "mec") -- Done
			GnarMenu.misc.mec:addParam("Enable", "Enable the use of Mec to cast " .. SpellR.mega.name .. " (R)", SCRIPT_PARAM_ONOFF, true) -- Done
			GnarMenu.misc.mec:addParam("minEnemies", "Min. Enemies to use " .. SpellR.mega.name .. " (R): ", SCRIPT_PARAM_SLICE, 2, 2, 5, 0) -- Done
			GnarMenu.misc.mec:addParam("posTo", "Position to throw the enemies: ", SCRIPT_PARAM_LIST, 1, { "Closest Wall", "Mouse-Position" }) -- Done
			GnarMenu.misc.mec:addParam("accuracy", "Accuracy to hit the Wall: ", SCRIPT_PARAM_SLICE, 30, 1, 50, 0) -- Done

		GnarMenu.misc:addSubMenu("Spells - Cast Settings", "cast") -- Done
			GnarMenu.misc.cast:addParam("usePackets", "Use Packets to Cast Spells", SCRIPT_PARAM_ONOFF, false) -- Done

		GnarMenu:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking") -- Done
			SxOrb:LoadToMenu(GnarMenu.Orbwalking, false) -- Done

	GnarMenu:addParam("predType", "Prediction Type", SCRIPT_PARAM_LIST, 2, { "Prodiction", "VPrediction" }) -- Done

	TargetSelector = TargetSelector(TARGET_LESS_CAST, SpellQ.mini.range, DAMAGE_PHYSICAL)
	TargetSelector.name = "Gnar"
	GnarMenu:addTS(TargetSelector)

	GnarMenu:addParam("gnarVer", "Version: ", SCRIPT_PARAM_INFO, _G.Gnar_Version)
end

function OnProcessSpell(unit, spell)
	if GnarMenu.misc.megaW.interrupt or GnarMenu.misc.megaR.interrupt then
		if (GnarMenu.misc.megaW.interrupt and SpellW.mega.ready) or SpellR.mega.ready then
			if GetDistanceSqr(unit) <= ((GnarMenu.misc.megaW.interrupt and (SpellW.mega.range * SpellW.mega.range)) or SpellR.mega.range * SpellR.mega.range) then
				if InterruptingSpells[spell.name] and unit.team ~= myHero.team then
					CastSpell(GnarMenu.misc.megaW.interrupt and _W or _R, unit.x, unit.z)
				end
			end
		end
	end

	if unit == myHero then
		if not spell.name:lower():find("attack") and myHero.mana == 100 then
			SpellP.enabled = true
		end
	end

	if unit.type == "Obj_AI_Turret" then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if spell.target == enemy and (GnarMenu.misc.megaR.turretAggro or GnarMenu.misc.megaW.turretAggro) and not enemy.canMove and SpellP.enabled then
				if GnarMenu.misc.megaW.turretAggro then
					CastWEnemy(enemy)
				elseif GnarMenu.misc.megaR.turretAggro then
					CastR(1, GnarMenu.misc.mec.accuracy, enemy)
				else
					CastWEnemy(enemy)
					DelayAction(function()
									if enemy.canMove and not SpellW.mega.ready then
										CastR(1, GnarMenu.misc.mec.accuracy, enemy)
									end
								end, 0.3)
				end
			end
		end
	end
end

function OnGainBuff(unit, buff)
	if GnarMenu.misc.miniQ.ccTarget then
		if unit.team ~= myHero.team and unit.type == myHero.type then
			for i = 1, #buffTypes do
				local buffType = buffTypes[i]

				if buff.type == buffType then
					CastQEnemy(unit)
				end
			end
		end
	end
end

function OnDraw()
	if GnarMenu.drawing.catcher then
		if (qObject.variable ~= nil and qObject.variable.valid) and (qObject.endVariable ~= nil and qObject.endVariable.valid) then
			DrawLineBorder3D(qObject.variable.x, qObject.variable.y, qObject.variable.z, qObject.endVariable.x, qObject.endVariable.y, qObject.endVariable.z, 125, GetHeroQRectangle(myHero, qObject.variable.x, qObject.variable.z, qObject.endVariable.x, qObject.endVariable.z) and ARGB(255, 255, 255, 255) or ARGB(255, 150, 3, 3), 1)
		end
	end

	if not myHero.dead then
		if not GnarMenu.drawing.mDraw then
			if GnarMenu.drawing.qDraw and (SpellP.enabled and SpellQ.mega.ready or SpellQ.mini.ready) then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellP.enabled and SpellQ.mega.range or SpellQ.mini.range, ARGB(255,178, 0 , 0 ))
			end

			if GnarMenu.drawing.wDraw and SpellW.mega.ready and SpellP.enabled then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellW.mega.range, ARGB(255, 32,178,170))
			end

			if GnarMenu.drawing.eDraw and (SpellP.enabled and SpellE.mega.ready or SpellE.mini.ready) then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellP.enabled and SpellE.mega.range or SpellE.mini.range, ARGB(255,128, 0 ,128))
			end

			if GnarMenu.drawing.rDraw and SpellR.mega.ready and SpellP.enabled then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellR.mega.range, ARGB(255, 0, 255, 0))
			end
		end

		if GnarMenu.drawing.Target then
			if Target ~= nil then
				DrawCircle3D(Target.x, Target.y, Target.z, 70, 1, ARGB(255, 255, 0, 0))
			end
		end
	end
end


function OnCreateObj(object)
	if not SpellQ.mini.ready then
		if (qObject.variable == nil or not qObject.variable.valid) or (qObject.endVariable == nil or not qObject.endVariable.valid) then
			if object.name:find("Q_mis.troy") and GetDistanceSqr(myHero, object) > 75 * 75 then
				qObject.variable = object
			end

			if object.name:find("Q_Target.troy") then
				qObject.endVariable = object
			end
		end
	end
end

function TickChecks()
	SpellQ.mini.ready, SpellQ.mega.ready = (myHero:CanUseSpell(_Q) == READY), (myHero:CanUseSpell(_Q) == READY)
	SpellW.mega.ready					 = (myHero:CanUseSpell(_W) == READY)
	SpellE.mini.ready, SpellE.mega.ready = (myHero:CanUseSpell(_E) == READY), (myHero:CanUseSpell(_E) == READY)
	SpellR.mega.ready					 = (myHero:CanUseSpell(_R) == READY)

	if myHero:GetSpellData(SUMMONER_1).name:find(SpellI.name) then
		SpellI.variable = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find(SpellI.name) then
		SpellI.variable = SUMMONER_2
	end

	SpellI.ready = (SpellI.variable ~= nil and myHero:CanUseSpell(SpellI.variable) == READY)

	if myHero.mana == 100 then
		DelayAction(function()
						SpellP.enabled = true
					end, 5)
	elseif myHero.mana == 0 then
		SpellP.enabled = false
	end

	Target = GetCustomTarget()

	if not VIP_USER and GnarMenu.misc.cast.usePackets then
		GnarMenu.misc.cast.usePackets = false

		Script_SendMessage("You can't activate Packet Cast as long as you are not a Vip User.")
	end

	if not VIP_USER and GnarMenu.predType == 1 then
		GnarMenu.predType = 2

		Script_SendMessage("You can't use Prodiction as long as you are not a Vip User.")
	end

	TargetSelector.range = TargetSelectorRange()
	SxOrb:ForceTarget(Target)
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
	for i, Item in pairs(Items) do
		local Item = Items[i]

		if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
			CastItem(Item.id, unit)
		end
	end
end

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil then
		if GnarMenu.combo.comboItems then
			UseItems(unit)
		end

		CastQEnemy(unit)
		CastWEnemy(unit)
		CastE(unit)

		if (GnarMenu.combo.useR == 1 and unit.health < SpellR.mega.dmg) or GnarMenu.combo.useR == 2 then
			CastR(1, 50, unit)
		end
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil then
		if SpellP.enabled and GnarMenu.harass.qmegaHarass or GnarMenu.harass.qminiHarass then
			CastQEnemy(unit)
		end

		if SpellP.enabled and GnarMenu.harass.wmegaHarass then
			CastWEnemy(unit)
		end
	end
end

function Farm()
	CastQMinion()
	CastWMinion()
end

function JungleClear()
	jungleMinions:update()
	if GnarMenu.jungle.jungleKey then
		for index, minion in pairs(jungleMinions.objects) do
			if minion ~= nil then
				if SpellP.enabled then
					if GnarMenu.jungle.qmegaJungle and GetDistanceSqr(minion) <= SpellQ.mega.range * SpellQ.mega.range then
						CastSpell(_Q, minion.x, minion.z)
					end

					if GnarMenu.jungle.wmegaJungle and GetDistanceSqr(minion) <= SpellW.mega.range * SpellW.mega.range then
						CastSpell(_W, minion.x, minion.z)
					end

					if GnarMenu.jungle.emegaJungle and GetDistanceSqr(minion) <= SpellE.mega.range * SpellE.mega.range then
						CastSpell(_E, minion.x, minion.z)
					end
				else
					if GnarMenu.jungle.qminiJungle and GetDistanceSqr(minion) <= SpellQ.mini.range * SpellQ.mini.range then
						CastSpell(_Q, minion.x, minion.z)
					end
				end
			end
		end
	end
end

function UnitHop()
	if GnarMenu.misc.hop.warn and not SpellP.enabled or not GnarMenu.misc.hop.warn then
		if SpellE.mini.ready or SpellE.mega.ready then
			local Distance = SpellW_.range

			allyMinions:update()
			for i, obj in pairs(allyMinions.objects) do 
				if obj.valid and obj ~= nil then
					MousePos = getMousePos()
					if GetDistanceSqr(obj, MousePos) <= Distance * Distance and GetDistanceSqr(obj, myHero) <= SpellE.mini.range * SpellE.mini.range then
						CastSpell(_E, obj.x, obj.z)
						SpellW_.lastJump = os.clock() + 2
					end
				end
			end

			enemyMinions:update()
			for i, obj in pairs(enemyMinions.objects) do 
				if obj.valid and obj ~= nil then
					MousePos = getMousePos()
					if GetDistanceSqr(obj, MousePos) <= Distance * Distance and GetDistanceSqr(obj, myHero) <= SpellE.mini.range * SpellE.mini.range then
						CastSpell(_E, obj.x, obj.z)
						SpellW_.lastJump = os.clock() + 2
					end
				end
			end

			jungleMinions:update()
			for i, obj in pairs(jungleMinions.objects) do 
				if obj.valid and obj ~= nil then
					MousePos = getMousePos()
					if GetDistanceSqr(obj, MousePos) <= Distance * Distance and GetDistanceSqr(obj, myHero) <= SpellE.mini.range * SpellE.mini.range then
						CastSpell(_E, obj.x, obj.z)
						SpellW_.lastJump = os.clock() + 2
					end
				end
			end

			petMinions:update()
			for i, obj in pairs(petMinions.objects) do 
				if obj.valid and obj ~= nil then
					if table.contains(petNames, obj.name:lower()) then
						MousePos = getMousePos()
						if GetDistanceSqr(obj, MousePos) <= Distance * Distance and GetDistanceSqr(obj, myHero) <= SpellE.mini.range * SpellE.mini.range then
							CastSpell(_E, obj.x, obj.z)
							SpellW_.lastJump = os.clock() + 2
						end
					end
				end
			end
		end
	end
end

function getMousePos(range)
	local temprange = range or SpellW_.range
	local MyPos = Vector(myHero.x, myHero.y, myHero.z)
	local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)

	return MyPos - (MyPos - MousePos):normalized() * temprange
end

function CastQEnemy(unit)
	if unit == nil or not SpellQ.mini.ready or not SpellQ.mega.ready or (SpellP.enabled and GetDistanceSqr(unit, myHero) > SpellQ.mega.range * SpellQ.mega.range or GetDistanceSqr(unit, myHero) > SpellQ.mini.range * SpellQ.mini.range) then
		return false
	end

	if not SpellP.enabled and GetDistanceSqr(unit, myHero) <= SpellQ.mini.range * SpellQ.mini.range then
		if GnarMenu.predType == 1 then
			local endPos, Info = Prodiction.GetPrediction(unit, SpellQ.mini.range, SpellQ.mini.speed, SpellQ.mini.delay, SpellQ.mini.width, myHero)

			if endPos ~= nil then
				if (GetQCollisionObjects(endPos.x, endPos.z) ~= nil and GetDistanceSqr(myHero, endPos) < 180 * 180) or GetQCollisionObjects(endPos.x, endPos.z) == nil then
					if GnarMenu.misc.cast.usePackets and VIP_USER then
						Packet("S_CAST", { spellId = _Q, toX = endPos.x, toY = endPos.z, fromX = endPos.x, fromY = endPos.z }):send()
					else
						CastSpell(_Q, endPos.x, endPos.z)
					end
					return true
				end
			end
		else
			local CastPos, HitChance, Position = vPred:GetLineCastPosition(unit, SpellQ.mini.delay, SpellQ.mini.width, SpellQ.mini.range, SpellQ.mini.speed, myHero, false)

			if HitChance >= 2 then
				if (GetQCollisionObjects(endPos.x, endPos.z) ~= nil and GetDistanceSqr(myHero, endPos) < 180 * 180) or GetQCollisionObjects(endPos.x, endPos.z) == nil then
					if GnarMenu.misc.cast.usePackets and VIP_USER then
						Packet("S_CAST", { spellId = _Q, toX = CastPos.x, toY = CastPos.z, fromX = CastPos.x, fromY = CastPos.z }):send()
					else
						CastSpell(_Q, CastPos.x, CastPos.z)
					end
					return true
				end
			end
		end
	elseif SpellP.enabled and GetDistanceSqr(unit, myHero) <= SpellQ.mega.range * SpellQ.mega.range then
		if GnarMenu.misc.megaQ.howTo == 1 and GetDistanceSqr(unit, myHero) > SxOrb.MyRange * SxOrb.MyRange or GnarMenu.misc.megaQ.howTo == 2 then
			if GnarMenu.predType == 1 then
				local endPos, Info = Prodiction.GetPrediction(unit, SpellQ.mega.range, SpellQ.mega.speed, SpellQ.mega.delay, SpellQ.mega.width, myHero)

				if endPos ~= nil then
					if (GetQCollisionObjects(endPos.x, endPos.z) ~= nil and GetDistanceSqr(myHero, endPos) < 40 * 40) or GetQCollisionObjects(endPos.x, endPos.z) == nil then
						if GnarMenu.misc.cast.usePackets and VIP_USER then
							Packet("S_CAST", { spellId = _Q, toX = endPos.x, toY = endPos.z, fromX = endPos.x, fromY = endPos.z }):send()
						else
							CastSpell(_Q, endPos.x, endPos.z)
						end
						return true
					end
				end
			else
				local CastPos, HitChance, Position = vPred:GetCircularCastPosition(unit, SpellQ.mega.delay, SpellQ.mega.width, SpellQ.mega.range, SpellQ.mega.speed, myHero, true)
				
				if HitChance >= 2 then
					if (GetQCollisionObjects(endPos.x, endPos.z) ~= nil and GetDistanceSqr(myHero, endPos) < 40 * 40) or GetQCollisionObjects(endPos.x, endPos.z) == nil then
						if GnarMenu.misc.cast.usePackets and VIP_USER then
							Packet("S_CAST", { spellId = _Q, toX = CastPos.x, toY = CastPos.z, fromX = CastPos.x, fromY = CastPos.z }):send()
						else
							CastSpell(_Q, CastPos.x, CastPos.z)
						end
						return true
					end
				end
			end
		end
	end
end

function CastQMinion()
	if not SpellQ.mini.ready or not SpellQ.mega.ready then
		return end

	for _, Minion in ipairs(enemyMinions) do
		if Minion == nil then
			return end

		local minionInRangeAa = SxOrb.MyRange * SxOrb.MyRange <= GetDistanceSqr(myHero, Minion)
		local minionInRangeSpell = GetDistanceSqr(myHero, Minion) <= ((SpellP.enabled and SpellQ.mega.range) or SpellQ.mini.range)
		local minionKillableAa = SxOrbWalk:GetAADmg(Minion) >= Minion.health;
		local minionKillableSpell = Minion.health <= SpellQ.mini.dmg or SpellQ.mega.dmg
		local lastHit = IsKeyDown(SxOrb.SxOrbMenu.Keys._param[4].key) and (GnarMenu.farming.qminiFarm == (2 or 4) or GnarMenu.farming.qmegaFarm == (2 or 4))
		local laneClear = IsKeyDown(SxOrb.SxOrbMenu.Keys._param[3].key) and (GnarMenu.farming.qminiFarm == (3 or 4) or GnarMenu.farming.qmegaFarm == (3 or 4))

		if (lastHit and minionInRangeSpell and minionKillableSpell) and ((minionInRangeAa and not minionKillableAa) or not minionInRangeAa) then
			if GnarMenu.misc.cast.usePackets and VIP_USER then
				Packet("S_CAST", { spellId = _Q, toX = Minion.x, toY = Minion.z, fromX = Minion.x, fromY = Minion.z }):send()
			else
				CastSpell(_Q, Minion.x, Minion.z)
			end
		elseif (laneClear and minionInRangeSpell and not minionKillableSpell) and ((minionInRangeAa and not minionKillableAa) or not minionInRangeAa) then
			if GnarMenu.misc.cast.usePackets and VIP_USER then
				Packet("S_CAST", { spellId = _Q, toX = Minion.x, toY = Minion.z, fromX = Minion.x, fromY = Minion.z }):send()
			else
				CastSpell(_Q, Minion.x, Minion.z)
			end
		end
	end
end

function CastWEnemy(unit)
	if unit == nil or (GetDistanceSqr(unit) > SpellW.mega.range * SpellW.mega.range) or not SpellW.mega.ready or not SpellP.enabled then
		return false
	end

	if GnarMenu.predType == 1 then
		local endPos, Info = Prodiction.GetPrediction(unit, SpellW.mega.range, SpellW.mega.speed, SpellW.mega.delay, SpellW.mega.width, myHero)
		
		if endPos ~= nil then
			if GnarMenu.misc.cast.usePackets and VIP_USER then
				Packet("S_CAST", { spellId = _W, toX = endPos.x, toY = endPos.z, fromX = endPos.x, fromY = endPos.z }):send()
			else
				CastSpell(_W, endPos.x, endPos.z)
			end
			return true
		end
	else
		local CastPos, HitChance, Position = vPred:GetLineCastPosition(unit, SpellW.mega.delay, SpellW.mega.width, SpellW.mega.range, SpellW.mega.speed, myHero, false)
		
		if HitChance >= 2 then
			if GnarMenu.misc.cast.usePackets and VIP_USER then
				Packet("S_CAST", { spellId = _W, toX = CastPos.x, toY = CastPos.z, fromX = CastPos.x, fromY = CastPos.z }):send()
			else
				CastSpell(_W, CastPos.x, CastPos.z)
			end
			return true
		end
	end
end

function CastWMinion()
	if not SpellW.mega.ready or not SpellP.enabled then
		return end

	for _, Minion in ipairs(enemyMinions) do
		if Minion == nil then
			return end

		local minionInRangeAa = SxOrb.MyRange * SxOrb.MyRange <= GetDistanceSqr(myHero, Minion)
		local minionInRangeSpell = GetDistanceSqr(myHero, Minion) <= (SpellP.enabled and SpellW.mega.range)
		local minionKillableAa = SxOrbWalk:GetAADmg(Minion) >= Minion.health
		local minionKillableSpell = ObjectManager.Player.GetSpellDamage(minion, SpellSlot.Q) >= minion.Health
		local lastHit = IsKeyDown(SxOrb.SxOrbMenu.Keys._param[4].key) and GnarMenu.farming.wmegaFarm == (2 or 4)
		local laneClear = IsKeyDown(SxOrb.SxOrbMenu.Keys._param[3].key) and GnarMenu.farming.wmegaFarm == (3 or 4)

		if (lastHit and minionInRangeSpell and minionKillableSpell) and ((minionInRangeAa and not minionKillableAa) or not minionInRangeAa) then
			if GnarMenu.misc.cast.usePackets and VIP_USER then
				Packet("S_CAST", { spellId = _W, toX = Minion.x, toY = Minion.z, fromX = Minion.x, fromY = Minion.z }):send()
			else
				CastSpell(_W, Minion.x, Minion.z)
			end
		elseif (laneClear and minionInRangeSpell and not minionKillableSpell) and ((minionInRangeAa and not minionKillableAa) or not minionInRangeAa) then
			if GnarMenu.misc.cast.usePackets and VIP_USER then
				Packet("S_CAST", { spellId = _W, toX = Minion.x, toY = Minion.z, fromX = Minion.x, fromY = Minion.z }):send()
			else
				CastSpell(_W, Minion.x, Minion.z)
			end
		end
	end
end

function CastE(unit)
	if unit == nil or not SpellE.mega.ready or (GetDistanceSqr(unit, myHero) > SpellE.mega.range * SpellE.mega.range) or not SpellP.enabled then
		return false
	end

	if GetDistanceSqr(unit, myHero) <= SpellE.mega.range * SpellE.mega.range then
		if GnarMenu.misc.megaE.howTo == 1 and GetDistanceSqr(unit, myHero) > SxOrb.MyRange * SxOrb.MyRange or GnarMenu.misc.megaE.howTo == 2 then
			if GnarMenu.predType == 1 then
				local endPos, Info = Prodiction.GetPrediction(unit, SpellE.mega.range, SpellE.mega.speed, SpellE.mega.delay, SpellE.mega.width, myHero)
				
				if endPos ~= nil then
					if GnarMenu.misc.cast.usePackets and VIP_USER then
						Packet("S_CAST", { spellId = _E, toX = endPos.x, toY = endPos.z, fromX = endPos.x, fromY = endPos.z }):send()
					else
						CastSpell(_E, endPos.x, endPos.z)
					end
					return true
				end
			else
				local CastPos, HitChance, Position = vPred:GetCircularCastPosition(unit, SpellE.mega.delay, SpellE.mega.width, SpellE.mega.range, SpellE.mega.speed, myHero, false)
				
				if HitChance >= 2 then
					if GnarMenu.misc.cast.usePackets and VIP_USER then
						Packet("S_CAST", { spellId = _E, toX = CastPos.x, toY = CastPos.z, fromX = CastPos.x, fromY = CastPos.z }):send()
					else
						CastSpell(_E, CastPos.x, CastPos.z)
					end
					return true
				end
			end
		end
	end
end

function CastR(count, accuracy, unit)
	unit = unit and unit or nil

	if unit ~= nil then
		if not unit.valid or (GetDistanceSqr(unit) > SpellR.mega.range * SpellR.mega.range) or not SpellR.mega.ready or not SpellP.enabled then
			return false
		end
	end

	if CountEnemiesNearUnit(myHero, SpellR.mega.range) >= count then
		if GnarMenu.misc.mec.posTo == 1 then
			CastRToCollision()
		else
			if GnarMenu.misc.cast.usePackets and VIP_USER then
				Packet("S_CAST", { spellId = _R, toX = mousePos.x, toY = mousePos.z, fromX = mousePos.x, fromY = mousePos.z }):send()
			else
				CastSpell(_R, mousePos.x, mousePos.z)
			end
		end
	end
end

function CastRToCollision()
	local center = myHero
	local points = 36
	local radius = 300

	local slice = 2 * math.pi / points

	for i = 0, points, 1 do
		local angle = slice * i
		local newX = center.x + radius * math.cos(angle)
		local newY = center.z + radius * math.sin(angle)
		local p = Vector(newX, newY, 0)

		if IsWall(p) then
			if GnarMenu.misc.cast.usePackets and VIP_USER then
				Packet("S_CAST", { spellId = _R, toX = p.x, toY = p.z, fromX = p.x, fromY = p.z }):send()
			else
				CastSpell(_R, p.x, p.z)
			end
		end
	end
end

function moveToCursor()
	if GetDistance(mousePos) then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized() * 300

		if VIP_USER then
			Packet('S_MOVE', { x = moveToPos.x, y = moveToPos.z }):send()
		else
			myHero:MoveTo(moveToPos.x, moveToPos.y)
		end
	end		
end

function ArrangePriorities()
	for i, enemy in pairs(GetEnemyHeroes())	do
		SetPriority(priorityTable.AD_Carry, enemy, 1)
		SetPriority(priorityTable.AP, enemy, 2)
		SetPriority(priorityTable.Support, enemy, 3)
		SetPriority(priorityTable.Bruiser, enemy, 4)
		SetPriority(priorityTable.Tank, enemy, 5)
	end
end

function ArrangeTTPriorities()
	for i, enemy in pairs(GetEnemyHeroes()) do
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

function KillSteal()
	for i, enemy in pairs(GetEnemyHeroes()) do
		-- Mini Damage Calculations
		SpellQ.mini.dmg =   5 + ((myHero:GetSpellData(_Q).level - 1) *  30) + (myHero.totalDamage * 1.15)
		SpellW.mini.dmg =  10 + ((myHero:GetSpellData(_W).level - 1) *  10) + myHero.ap + ((enemy.maxHealth * 0.06) + (myHero:GetSpellData(_W).level - 1) * (enemy.maxHealth * 0.02))
		SpellE.mini.dmg =  20 + ((myHero:GetSpellData(_E).level - 1) *  40) + (myHero.maxhealth * 0.06)

		-- Mega Damage Calculations
		SpellQ.mega.dmg =   5 + ((myHero:GetSpellData(_Q).level - 1) *  40) + (myHero.totalDamage * 1.20)
		SpellW.mega.dmg =  25 + ((myHero:GetSpellData(_W).level - 1) *  20) + myHero.totalDamage
		SpellE.mega.dmg =  20 + ((myHero:GetSpellData(_E).level - 1) *  40) + (myHero.maxhealth * 0.06)
		SpellR.mega.dmg = 200 + ((myHero:GetSpellData(_R).level - 1) * 100) + (myHero.totalDamage * 1.20) + (myHero.ap * 0.5)

		if ValidTarget(enemy) and enemy.visible then
			if enemy.health < SpellR.mega.dmg and GnarMenu.ks.useR then
				CastR(1, 50, enemy)
			elseif enemy.health < SpellQ.mega.dmg and SpellP.enabled or enemy.health < SpellQ.mini.dmg then
				CastQEnemy(enemy)
			elseif enemy.health < SpellW.mega.dmg and SpellP.enabled then
				CastWEnemy(enemy)
			elseif enemy.health < SpellE.mega.dmg and SpellP.enabled or enemy.health < SpellE.mini.dmg then
				CastE(enemy)
			elseif enemy.health < SpellQ.mega.dmg + SpellR.mega.dmg and SpellP.enabled and GnarMenu.ks.useR then
				CastQEnemy(enemy)
			elseif enemy.health < SpellW.mega.dmg + SpellR.mega.dmg and SpellP.enabled and GnarMenu.ks.useR then
				CastWEnemy(enemy)
			elseif enemy.health < SpellE.mega.dmg + SpellR.mega.dmg and SpellP.enabled and GnarMenu.ks.useR then
				CastE(enemy)
			elseif enemy.health < SpellQ.mega.dmg + SpellW.mega.dmg + SpellR.mega.dmg and SpellP.enabled and GnarMenu.ks.useR then
				CastE(enemy)
			elseif enemy.health < SpellQ.mega.dmg + SpellE.mega.dmg + SpellR.mega.dmg and SpellP.enabled and GnarMenu.ks.useR then
				CastE(enemy)
			elseif enemy.health < SpellQ.mega.dmg + SpellW.mega.dmg + SpellR.mega.dmg and SpellP.enabled and GnarMenu.ks.useR then
				CastE(enemy)
			end

			if GnarMenu.ks.autoIgnite then
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

function CountEnemiesNearUnit(unit, range)
	local count = 0

	for i = 1, heroManager.iCount do
		currentEnemy = heroManager:GetHero(i)
		
		if currentEnemy.team ~= myHero.team and currentEnemy.type == myHero.type then
			if GetDistanceSqr(currentEnemy, unit) <= range * range and not currentEnemy.dead then
				count = count + 1
			end
		end
	end

	return count
end

function TargetSelectorRange()
	if SpellP.enabled then
		return SpellQ.mega.ready and SpellQ.mega.range or SpellE.mega.range
	else
		return SpellQ.mini.ready and SpellQ.mini.range or SpellE.mini.range
	end
end

function GetHeroQRectangle(unit, x1, y1, x2, y2)
	local o = { x = -(y2 - y1), y = x2 - x1 }
	local len = math.sqrt((o.x * o.x) + (o.y * o.y))
	
	o.x, o.y = o.x / len * 250 / 2, o.y / len * 250 / 2

	local points =
	{
		D3DXVECTOR2(x1 + o.x, y1 + o.y),
		D3DXVECTOR2(x1 - o.x, y1 - o.y),
		D3DXVECTOR2(x2 - o.x, y2 - o.y),
		D3DXVECTOR2(x2 + o.x, y2 + o.y)
	}

	_polygon = Polygon(Point(points[1].x, points[1].y), Point(points[2].x, points[2].y), Point(points[3].x, points[3].y), Point(points[4].x, points[4].y))

	return _polygon:contains(Point(unit.x, unit.z))
end

function GetQCollisionObjects(point_x, point_y)
	local PossibleCollisionObjects = {}

	for _, Object in ipairs(enemyMinions.objects) do
		table.insert(PossibleCollisionObjects, Object)
	end

	for _, Object in ipairs(jungleMinions.objects) do
		table.insert(PossibleCollisionObjects, Object)
	end

	local o = { x = -(point_y - myHero.z), y = point_x - myHero.x }
	local len = math.sqrt((o.x * o.x) + (o.y * o.y))
	
	o.x, o.y = o.x / len * ((SpellP.enabled and SpellQ.mega.width) or SpellQ.mini.width) / 2, o.y / len * ((SpellP.enabled and SpellQ.mega.width) or SpellQ.mini.width) / 2

	local points =
	{
		D3DXVECTOR2(myHero.x + o.x, myHero.z + o.y),
		D3DXVECTOR2(myHero.x - o.x, myHero.z - o.y),
		D3DXVECTOR2(point_x - o.x, point_y - o.y),
		D3DXVECTOR2(point_x + o.x, point_y + o.y)
	}

	_polygon = Polygon(Point(points[1].x, points[1].y), Point(points[2].x, points[2].y), Point(points[3].x, points[3].y), Point(points[4].x, points[4].y))

	for _, Object in ipairs(PossibleCollisionObjects) do

		if Object ~= nil and _polygon:contains(Point(Object.x, Object.z)) then
			return Object
		else
			return nil
		end
	end
end
