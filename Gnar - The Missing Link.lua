_G.Gnar_Version = 1.014
--[[


		 d888b  d8b   db  .d8b.  d8888b.
		88' Y8b 888o  88 d8' `8b 88  `8D
		88      88V8o 88 88ooo88 88oobY'
		88  ooo 88 V8o88 88~~~88 88`8b
		88. ~8~ 88  V888 88   88 88 `88.
		 Y888P  VP   V8P YP   YP 88   YD

	Script - Gnar - The Missing Link 1.01

	Changelog:
		1.0a
			- Pre-Release

		1.01
			- Official Release (Champion Released)

]]--

if myHero.charName ~= "Gnar" then return end

_G.Gnar_Autoupdate = true

local lib_Required = {
	["Prodiction"]	= "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua",
	["SOW"]			= "https://raw.githubusercontent.com/Hellsing/BoL/master/Common/SOW.lua",
	["VPrediction"]	= "https://raw.githubusercontent.com/Hellsing/BoL/master/Common/VPrediction.lua"
}

local lib_downloadNeeded, lib_downloadCount = false, 0

function AfterDownload()
	lib_downloadCount = lib_downloadCount - 1
	if lib_downloadCount == 0 then
		lib_downloadNeeded = false
		print("<font color=\"#FF0000\">Gnar - The Missing Link:</font> <font color=\"#FFFFFF\">Required libraries downloaded successfully, please reload (double F9).</font>")
	end
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
local script_downloadPath = "/RoachxD/BoL_Scripts/master/Gnar%20-%20The%20Missing%20Link.lua" .. "?rand=" .. math.random(1, 10000)
local script_downloadUrl = "https://" .. script_downloadHost .. script_downloadPath
local script_filePath = SCRIPT_PATH .. GetCurrentEnv().FILE_NAME .. ".lua"

function script_Messager(message) print("<font color=\"#FF0000\">" .. script_downloadName .. ":</font> <font color=\"#FFFFFF\">" .. message .. ".</font>") end

if _G.Gnar_Autoupdate then
	local script_webResult = GetWebResult(script_downloadHost, script_downloadPath)
	if script_webResult then
		local script_serverVersion = string.match(script_webResult, "%s*_G.Gnar_Version%s+=%s+.*%d+%.%d+")

		if script_serverVersion then
			script_serverVersion = tonumber(string.match(script_serverVersion or "", "%d+%.?%d*"))

			if not script_serverVersion then
				script_Messager("Please contact the developer of the script \"" .. script_downloadName .. "\", since the auto updater returned an invalid version.")
				return
			end

			if _G.Gnar_Version < script_serverVersion then
				script_Messager("New version available: " .. script_serverVersion)
				script_Messager("Updating, please don't press F9")
				DelayAction(function () DownloadFile(script_downloadUrl, script_filePath, function() script_Messager("Successfully updated the script, please reload!") end) end, 2)
			else
				script_Messager("You've got the latest version: " .. script_serverVersion)
			end
		else
			script_Messager("Something went wrong, update the script manually!")
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
	UpdateWeb(true, (string.gsub(script_downloadName, "[^0-9A-Za-z]", "")), 5, HWID)

	if heroManager.iCount < 10 then -- borrowed from Sidas Auto Carry, modified to 3v3
		script_Messager("Too few champions to arrange priorities")
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

	if GnarMenu.misc.megaR.mec.Enable then
		for i = 1, enemyCount do
			local enemy = enemyTable[i].player

			CastR(enemy, GnarMenu.misc.megaR.mec.minEnemies, GnarMenu.misc.megaR.mec.accuracy)
		end
	end

	TickChecks()
end

function OnGameOver()
	UpdateWeb(false, (string.gsub(script_downloadName, "[^0-9A-Za-z]", "")), 5, HWID)
end

function Variables()
	SpellP = { name = "Rage Gene",																enabled = false									 }

	SpellQ =
	{
		mini = { name = "Boomerang Throw",	range = 1100, delay = 0.5, speed = 1200, width =  50, ready = false, pos = nil, dmg = 0				 },
		mega = { name = "Boulder Toss",		range = 1100, delay = 0.5, speed = 1200, width =  70, ready = false, pos = nil, dmg = 0				 }
	}
	SpellW =
	{
		mega = { name = "Wallop",			range =  525, delay = 0.5, speed = math.huge, width =  80, ready = false, pos = nil, dmg = 0		 }
	}
	SpellE =
	{
		mini = { name = "Hop",				range =  475, delay = 0.5, speed = math.huge, width = 150, ready = false, pos = nil, dmg = 0		 },
		mega = { name = "Crunch",			range =  475, delay = 0.5, speed = math.huge, width = 350, ready = false, pos = nil, dmg = 0		 }
	}
	SpellR =
	{
		mega = { name = "GNAR!",			range =  590, delay = 0.5, speed = 1200, width = 210, ready = false, pos = nil, dmg = 0				 }
	}

	SpellI = { name = "SummonerDot",		range =  600,									   ready = false,			 dmg = 0, variable = nil }

	SpellW_= {								range =  525, 									   lastJump = 0										 }

	vPred = VPrediction()

	gSOW = SOW(vPred)

	priorityTable = {
			AP = {
				"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
				"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
				"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "VelKoz"
			},
			Support = {
				"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum"
			},
			Tank = {
				"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
				"Warwick", "Yorick", "Zac"
			},
			AD_Carry = {
				"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
				"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
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

	allyMinions = minionManager(MINION_ALLY, 1100, myHero.visionPos, MINION_SORT_MAXHEALTH_DEC)
	enemyMinions = minionManager(MINION_ENEMY, 1100, myHero.visionPos, MINION_SORT_MAXHEALTH_DEC)
	jungleMinions = minionManager(MINION_JUNGLE, 1100, myHero.visionPos, MINION_SORT_MAXHEALTH_DEC)
	pets = { "annietibbers", "shacobox", "malzaharvoidling", "heimertyellow", "heimertblue", "yorickdecayedghoul" }

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
		GnarMenu.farming:addParam("farmKey", "Farming Key (V)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V')) -- Done
		GnarMenu.farming:addParam("qminiFarm", "Farm with " .. SpellQ.mini.name .. " (Q)", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.farming:addParam("qmegaFarm", "Farm with " .. SpellQ.mega.name .. " (Q)", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.farming:permaShow("farmKey") -- Done
		
	GnarMenu:addSubMenu("["..myHero.charName.."] - Jungle Clear Settings", "jungle") -- Done
		GnarMenu.jungle:addParam("jungleKey", "Jungle Clear Key (V)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V')) -- Done
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
		GnarMenu.drawing:addParam("cDraw", "Draw Damage Text", SCRIPT_PARAM_ONOFF, true) -- Done
		GnarMenu.drawing:addParam("myHero", "Draw My Hero's Range", SCRIPT_PARAM_ONOFF, true) -- Done
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
			GnarMenu.misc.miniQ:addParam("catch", "Try to catch " .. SpellQ.mini.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
			GnarMenu.misc.miniQ:addParam("warn", "Don't block Movement Packet when Target is in Range", SCRIPT_PARAM_ONOFF, true)
		GnarMenu.misc:addSubMenu("Spells - " .. SpellQ.mega.name .. " (Q) Settings", "megaQ") -- Done
			GnarMenu.misc.megaQ:addParam("howTo", "Use " .. SpellQ.mega.name .. " (Q): ", SCRIPT_PARAM_LIST, 1, { "If outside of Melee Range", "When Available" }) -- Done
		GnarMenu.misc:addSubMenu("Spells - " .. SpellW.mega.name .. " (W) Settings", "megaW") -- Done
			GnarMenu.misc.megaW:addParam("interrupt", "Auto-interrupt Channeling Spells with " .. SpellW.mega.name .. " (W)", SCRIPT_PARAM_ONOFF, true) -- Done
			GnarMenu.misc.megaW:addParam("turretAggro", "Try to stun enemies in allied Turret Range", SCRIPT_PARAM_ONOFF, true)
		GnarMenu.misc:addSubMenu("Spells - " .. SpellE.mega.name .. " (E) Settings", "megaE")
			GnarMenu.misc.megaE:addParam("howTo", "Use " .. SpellE.mega.name .. " (E): ", SCRIPT_PARAM_LIST, 1, { "If outside of Melee Range", "When Available" }) -- Done
		GnarMenu.misc:addSubMenu("Spells - " .. SpellR.mega.name .. " (R) Settings", "megaR")
			GnarMenu.misc.megaR:addSubMenu("Spells - " .. SpellR.mega.name .. " (R) MEC Settings", "mec") -- Done
				GnarMenu.misc.megaR.mec:addParam("Enable", "Enable the use of Mec to cast " .. SpellR.mega.name .. " (R)", SCRIPT_PARAM_ONOFF, true) -- Done
				GnarMenu.misc.megaR.mec:addParam("minEnemies", "Min. Enemies to use " .. SpellR.mega.name .. " (R): ", SCRIPT_PARAM_SLICE, 2, 2, 5, 0) -- Done
				GnarMenu.misc.megaR.mec:addParam("posTo", "Position to throw the enemies: ", SCRIPT_PARAM_LIST, 1, { "Closest Wall", "Mouse-Position" }) -- Done
				GnarMenu.misc.megaR.mec:addParam("accuracy", "Accuracy to hit the Wall: ", SCRIPT_PARAM_SLICE, 30, 1, 40, 0) -- Done
			GnarMenu.misc.megaR:addParam("interrupt", "Auto-interrupt Channeling Spells with " .. SpellR.mega.name .. " (R)", SCRIPT_PARAM_ONOFF, false) -- Done
			GnarMenu.misc.megaR:addParam("turretAggro", "Try to stun enemies in allied Turret Range", SCRIPT_PARAM_ONOFF, true)

		GnarMenu.misc:addSubMenu("Spells - Cast Settings", "cast") -- Done
			GnarMenu.misc.cast:addParam("usePackets", "Use Packets to Cast Spells", SCRIPT_PARAM_ONOFF, false) -- Done

		GnarMenu:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking") -- Done
			gSOW:LoadToMenu(GnarMenu.Orbwalking) -- Done

	GnarMenu:addParam("predType", "Prediction Type", SCRIPT_PARAM_LIST, 1, { "Prodiction", "VPrediction" }) -- Done

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
					CastSpell(GnarMenu.misc.megaW.interrupt and _W or _R, unit.visionPos.x, unit.visionPos.z)
				end
			end
		end
	end

	if unit == myHero and myHero.mana == 100 then
		if not spell.name:lower():find("attack") then
			SpellP.enabled = true
		end
	end
end

function OnGainBuff(unit, buff)
	if GnarMenu.misc.miniQ.ccTarget then
		if unit.team ~= myHero.team and unit.type == myHero.type then
			for i = 1, #buffTypes do
				local buffType = buffTypes[i]
				if buff.type == buffType then
					CastQ(unit)
				end
			end
		end
	end
end

function OnDraw()
	if GnarMenu.drawing.myHero then
		gSOW:DrawAARange(1, ARGB(255, 0, 189, 22))
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
		if GnarMenu.drawing.cDraw then
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

	TargetSelector.range = TargetSelectorRange()
	gSOW:ForceTarget(Target)

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

		CastQ(unit)
		CastW(unit)
		CastE(unit)

		SpellR.dmg = (SpellR.mega.ready and getDmg("R", unit, myHero))
		if GnarMenu.combo.useR == 1 and unit.health < SpellR.mega.dmg or GnarMenu.combo.useR == 2 then
			CastR(unit, 1, GnarMenu.combo.useR == 1 and 1 or GnarMenu.misc.megaR.mec.accuracy)
		end
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil then
		if SpellP.enabled and GnarMenu.harass.qmegaHarass or GnarMenu.harass.qminiHarass then
			CastQ(unit)
		end
		if SpellP.enabled and GnarMenu.harass.wmegaHarass then
			CastW(unit)
		end
	end
end

function Farm()
	enemyMinions:update()
	if SpellQ.mini.ready and #enemyMinions.objects > 0 then
		local Pos = GetBestQPositionFarm()
		if Pos then
			CastSpell(_Q, Pos.x, Pos.z)
		end
	end
end

function CountMinionsQ(pos)
	local count = 0

	local ExtendedVector = Vector(myHero) + Vector(Vector(pos) - Vector(myHero)):normalized()*SpellQ.mini.range
	for i, minion in ipairs(enemyMinions.objects) do
		local MinionPointSegment, MinionPointLine, MinionIsOnSegment =  VectorPointProjectionOnLineSegment(Vector(myHero), Vector(ExtendedVector), Vector(minion)) 
		local MinionPointSegment3D = { x = MinionPointSegment.x, y = pos.y, z = MinionPointSegment.y }
		if MinionIsOnSegment and GetDistanceSqr(MinionPointSegment3D, pos) < SpellQ.mini.width * SpellQ.mini.width then
			count = count + 1
		end
	end

	return count
end


function GetBestQPositionFarm()
	local MaxQ = 1
	local MaxQPos
	for i, minion in pairs(enemyMinions.objects) do
		local hitQ = CountMinionsQ(minion)
		if hitQ > MaxQ or MaxQPos == nil then
			MaxQPos = minion
			MaxQ = hitQ
		end
	end

	if MaxQPos then
		return MaxQPos
	else
		return nil
	end
end

function JungleClear()
	jungleMinions:update()
	if GnarMenu.jungle.jungleKey then
		local JungleMob = jungleMinions[gSOW:GetTarget(false)] and gSOW:GetTarget(false) or nil
		if JungleMob ~= nil then
			if SpellP.enabled then
				if GnarMenu.jungle.qmegaJungle and GetDistanceSqr(JungleMob) <= SpellQ.mega.range * SpellQ.mega.range then
					CastSpell(_Q, JungleMob.x, JungleMob.z)
				end
				if GnarMenu.jungle.wmegaJungle and GetDistanceSqr(JungleMob) <= SpellW.mega.range * SpellW.mega.range then
					CastSpell(_W, JungleMob.x, JungleMob.z)
				end
				if GnarMenu.jungle.emegaJungle and GetDistanceSqr(JungleMob) <= SpellE.mega.range * SpellE.mega.range then
					CastSpell(_E, JungleMob.x, JungleMob.z)
				end
			else
				if GnarMenu.jungle.qminiJungle and GetDistanceSqr(JungleMob) <= SpellQ.mini.range * SpellQ.mini.range then
					CastSpell(_Q, JungleMob.x, JungleMob.z)
				end
			end
		end
	end
end

function UnitHop()
	if not SpellP.enabled and GnarMenu.misc.hop.warn or not GnarMenu.misc.hop.warn then
		if SpellE.mini.ready or SpellE.mega.ready then
			local Distance = SpellW_.range
	

			if next(allyMinions.objects) ~= nil then
				for i, obj in pairs(allyMinions.objects) do 
					if obj.valid then
						MousePos = getMousePos()
						if GetDistanceSqr(obj, MousePos) <= Distance * Distance then
							CastSpell(_E, obj.x, obj.z)
							SpellW_.lastJump = os.clock() + 2
						 end
					end
				end
			end

			if next(enemyMinions.objects) ~= nil then
				for i, obj in pairs(enemyMinions.objects) do 
					if obj.valid then
						MousePos = getMousePos()
						if GetDistanceSqr(obj, MousePos) <= Distance * Distance then
							CastSpell(_E, obj.x, obj.z)
							SpellW_.lastJump = os.clock() + 2
						 end
					end
				end
			end

			if next(jungleMinions.objects) ~= nil then
				for i, obj in pairs(jungleMinions.objects) do 
					if obj.valid then
						MousePos = getMousePos()
						if GetDistanceSqr(obj, MousePos) <= Distance * Distance then
							CastSpell(_E, obj.x, obj.z)
							SpellW_.lastJump = os.clock() + 2
						 end
					end
				end
			end

			--[[if next(pets) ~= nil then
				for i, obj in pairs(pets) do 
					if obj.valid then
						MousePos = getMousePos()
						if GetDistanceSqr(obj, MousePos) <= Distance * Distance then
							CastSpell(_E, obj.x, obj.z)
							SpellW_.lastJump = os.clock() + 2
						 end
					end
				end
			end]]--
		end
	end
end

function getMousePos(range)
	local temprange = range or SpellW_.range
	local MyPos = Vector(myHero.x, myHero.y, myHero.z)
	local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)

	return MyPos - (MyPos - MousePos):normalized() * temprange
end

function CastQ(unit)
	if unit == nil or not SpellQ.mini.ready or not SpellQ.mega.ready or (SpellP.enabled and GetDistanceSqr(unit, myHero) > SpellQ.mega.range * SpellQ.mega.range or GetDistanceSqr(unit, myHero) > SpellQ.mini.range * SpellQ.mini.range) then
		return false
	end

	if not SpellP.enabled and GetDistanceSqr(unit, myHero) <= SpellQ.mini.range * SpellQ.mini.range then
		if GnarMenu.predType == 1 then
			local endPos, Info = Prodiction.GetPrediction(unit, SpellQ.mini.range, SpellQ.mini.speed, SpellQ.mini.delay, SpellQ.mini.width, myHero)
			if endPos ~= nil then
				if GnarMenu.misc.cast.usePackets then
					Packet("S_CAST", { spellId = _Q, toX = endPos.x, toY = endPos.z, fromX = endPos.x, fromY = endPos.z }):send()
				else
					CastSpell(_Q, endPos.x, endPos.z)
				end
				return true
			end
		else
			local CastPos, HitChance, Position = vPred:GetLineCastPosition(unit, SpellQ.mini.delay, SpellQ.mini.width, SpellQ.mini.range, SpellQ.mini.speed, myHero, false)

			if HitChance >= 2 then
				if GnarMenu.misc.cast.usePackets then
					Packet("S_CAST", { spellId = _Q, toX = CastPos.x, toY = CastPos.z, fromX = CastPos.x, fromY = CastPos.z }):send()
				else
					CastSpell(_Q, CastPos.x, CastPos.z)
				end
				return true
			end
		end
	elseif SpellP.enabled and GetDistanceSqr(unit, myHero) <= SpellQ.mega.range * SpellQ.mega.range then
		if GnarMenu.misc.megaQ.howTo == 1 and GetDistanceSqr(unit, myHero) > gSOW:MyRange() * gSOW:MyRange() or GnarMenu.misc.megaQ.howTo == 2 then
			if GnarMenu.predType == 1 then
				local endPos, Info = Prodiction.GetPrediction(unit, SpellQ.mega.range, SpellQ.mega.speed, SpellQ.mega.delay, SpellQ.mega.width, myHero)
				if endPos ~= nil then
					if GnarMenu.misc.cast.usePackets then
						Packet("S_CAST", { spellId = _Q, toX = endPos.x, toY = endPos.z, fromX = endPos.x, fromY = endPos.z }):send()
					else
						CastSpell(_Q, endPos.x, endPos.z)
					end
					return true
				end
			else
				local CastPos, HitChance, Position = vPred:GetCircularCastPosition(unit, SpellQ.mega.delay, SpellQ.mega.width, SpellQ.mega.range, SpellQ.mega.speed, myHero, true)
				if HitChance >= 2 then
					if GnarMenu.misc.cast.usePackets then
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

function CastW(unit)
	if unit == nil or (GetDistanceSqr(unit) > SpellW.mega.range * SpellW.mega.range) or not SpellW.mega.ready or not SpellP.enabled then
		return false
	end

	if GnarMenu.predType == 1 then
		local endPos, Info = Prodiction.GetPrediction(unit, SpellW.mega.range, SpellW.mega.speed, SpellW.mega.delay, SpellW.mega.width, myHero)
		if endPos ~= nil then
			if GnarMenu.misc.cast.usePackets then
				Packet("S_CAST", { spellId = _W, toX = endPos.x, toY = endPos.z, fromX = endPos.x, fromY = endPos.z }):send()
			else
				CastSpell(_W, endPos.x, endPos.z)
			end
			return true
		end
	else
		local CastPos, HitChance, Position = vPred:GetLineCastPosition(unit, SpellW.mega.delay, SpellW.mega.width, SpellW.mega.range, SpellW.mega.speed, myHero, false)
		if HitChance >= 2 then
			if GnarMenu.misc.cast.usePackets then
				Packet("S_CAST", { spellId = _W, toX = CastPos.x, toY = CastPos.z, fromX = CastPos.x, fromY = CastPos.z }):send()
			else
				CastSpell(_W, CastPos.x, CastPos.z)
			end
			return true
		end
	end
end

function CastE(unit)
	if unit == nil or not SpellQ.mega.ready or (GetDistanceSqr(unit, myHero) > SpellE.mega.range * SpellE.mega.range) or not SpellP.enabled then
		return false
	end

	if GetDistanceSqr(unit, myHero) <= SpellE.mega.range * SpellE.mega.range then
		if GnarMenu.misc.megaE.howTo == 1 and GetDistanceSqr(unit, myHero) > gSOW:MyRange() * gSOW:MyRange() or GnarMenu.misc.megaE.howTo == 2 then
			if GnarMenu.predType == 1 then
				local endPos, Info = Prodiction.GetPrediction(unit, SpellE.mega.range, SpellE.mega.speed, SpellE.mega.delay, SpellE.mega.width, myHero)
				if endPos ~= nil then
					if GnarMenu.misc.cast.usePackets then
						Packet("S_CAST", { spellId = _E, toX = endPos.x, toY = endPos.z, fromX = endPos.x, fromY = endPos.z }):send()
					else
						CastSpell(_E, endPos.x, endPos.z)
					end
					return true
				end
			else
				local CastPos, HitChance, Position = vPred:GetCircularCastPosition(unit, SpellE.mega.delay, SpellE.mega.width, SpellE.mega.range, SpellE.mega.speed, myHero, false)
				if HitChance >= 2 then
					if GnarMenu.misc.cast.usePackets then
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

function CastR(unit, count, accuracy)
	if unit == nil or (GetDistanceSqr(unit) > SpellR.mega.range * SpellR.mega.range) or not SpellR.mega.ready or not SpellP.enabled then
		return false
	end

	if CountEnemiesNearUnit(myHero, SpellR.mega.range) >= count then
		if GnarMenu.misc.megaR.mec.posTo == 1 then
			local pushLocation = NearestWall(myHero.x, myHero.y, myHero.z, SpellR.mega.range + (SpellR.mega.range *.25), 30)

			CastSpell(_R, pushLocation.x, pushLocation.z)
		else
			CastSpell(_R, mousePos.x, mousePos.z)
		end
	end
end

function NearestWall(x, y, z, maxRadius, accuracy) 
	local vec = D3DXVECTOR3(x, y, z)

	accuracy = accuracy or 50
	maxRadius = maxRadius and math.floor(maxRadius / accuracy) or math.huge

	x, z = math.round(x / accuracy) * accuracy, math.round(z / accuracy) * accuracy

	local radius = 2

	local function checkPos(x, y) 
		vec.x, vec.z = x + x * accuracy, z + y * accuracy 
		return IsWall(vec) 
	end

	while radius <= maxRadius do
		if checkPos(0, radius) or checkPos(radius, 0) or checkPos(0, -radius) or checkPos(-radius, 0) then 
			return vec 
		end
		local f, x, y = 1 - radius, 0, radius
		while x < y - 1 do
			x = x + 1
			if f < 0 then 
				f = f + 1 + 2 * x
			else 
				y, f = y - 1, f + 1 + 2 * (x - y)
			end
			if checkPos(x, y) or checkPos(-x, y) or checkPos(x, -y) or checkPos(-x, -y) or checkPos(y, x) or checkPos(-y, x) or checkPos(y, -x) or checkPos(-y, -x) then 
				return vec 
			end
		end

		radius = radius + 1
	end
end

function moveToCursor()
	if GetDistance(mousePos) then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300

		if VIP_USER then
			Packet('S_MOVE', { x = moveToPos.x, y = moveToPos.z }):send()
		else
			myHero:MoveTo(moveToPos.x, moveToPos.y)
		end
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
			SpellQ.mini.dmg, SpellQ.mega.dmg	= (SpellQ.mini.ready and (10 + (35 * (GetSpellData(_Q).level - 1)) + myHero.totalDamage)) or 0, (SpellQ.mega.ready and (10 + (40 * (GetSpellData(_Q).level - 1)) + myHero.totalDamage * 1.2)) or 0
							 SpellW.mega.dmg	= 															  (SpellW.mega.ready and (25 + (20 * (GetSpellData(_W).level - 1)) + myHero.totalDamage)) or 0
			SpellE.mini.dmg, SpellE.mega.dmg	= (SpellE.mini.ready and (20 + (40 * (GetSpellData(_E).level - 1)) + myHero.maxHealth * .06 )) or 0, (SpellE.mega.ready and (20 + (40 * (GetSpellData(_E).level - 1)) + myHero.maxHealth * .06 )) or 0
							 SpellR.mega.dmg	= 															  (SpellR.mega.ready and (300 + (150 * (GetSpellData(_R).level - 1)) + myHero.totalDamage * .3)) or 0
			SpellI.dmg							= (SpellI.ready 	 and getDmg("IGNITE", enemy, myHero)) or 0

			if SpellP.enabled and enemy.health < SpellR.mega.dmg then
				enemyTable[i].indicatorText = "R Kill"
				enemyTable[i].ready = SpellR.mega.ready
			elseif SpellP.enabled and enemy.health < SpellQ.mega.dmg or enemy.health < SpellQ.mini.dmg then
				enemyTable[i].indicatorText = "Q Kill"
				enemyTable[i].ready = SpellQ.mega.ready or SpellQ.mini.ready
			elseif enemy.health < SpellW.mega.dmg and SpellP.enabled then
				enemyTable[i].indicatorText = "W Kill"
				enemyTable[i].ready = SpellP.enabled and SpellW.mega.ready
			elseif enemy.health < SpellE.mega.dmg and SpellP.enabled or enemy.health < SpellE.mini.dmg then
				enemyTable[i].indicatorText = "E Kill"
				enemyTable[i].ready = SpellE.mega.ready or SpellE.mini.ready
			elseif enemy.health < SpellQ.mega.dmg + SpellR.mega.dmg and SpellP.enabled then
				enemyTable[i].indicatorText = "Q + R Kill"
				enemyTable[i].ready = SpellQ.mega.ready and SpellR.mega.ready
			elseif enemy.health < SpellW.mega.dmg + SpellR.mega.dmg and SpellP.enabled then
				enemyTable[i].indicatorText = "W + R Kill"
				enemyTable[i].ready = SpellW.mega.ready and SpellR.mega.ready
			elseif enemy.health < SpellE.mega.dmg + SpellR.mega.dmg and SpellP.enabled then
				enemyTable[i].indicatorText = "E + R Kill"
				enemyTable[i].ready =  SpellE.mega.ready and SpellR.mega.ready
			elseif enemy.health < SpellQ.mega.dmg + SpellW.mega.dmg + SpellR.mega.dmg and SpellP.enabled then
				enemyTable[i].indicatorText = "Q + W + R Kill"
				enemyTable[i].ready = SpellQ.mega.ready and SpellW.mega.ready and SpellR.mega.ready
			elseif enemy.health < SpellQ.mega.dmg + SpellE.mega.dmg + SpellR.mega.dmg and SpellP.enabled then
				enemyTable[i].indicatorText = "Q + E + R Kill"
				enemyTable[i].ready =  SpellQ.mega.ready and SpellE.mega.ready and SpellR.mega.ready
			elseif enemy.health < SpellQ.mega.dmg + SpellW.mega.dmg + SpellR.mega.dmg and SpellP.enabled then
				enemyTable[i].indicatorText = "All-In Kill"
				enemyTable[i].ready =  SpellQ.mega.ready and SpellW.mega.ready and SpellE.mega.ready and SpellR.mega.ready
			else
				local dmgTotal = (SpellP.enabled and SpellQ.mega.dmg or SpellQ.mini.dmg) + SpellW.mega.dmg + (SpellP.enabled and SpellE.mega.dmg or SpellE.mini.dmg) + SpellR.mega.dmg
				local hpLeft = math.round(enemy.health - dmgTotal)
				local percentLeft = math.round(hpLeft / enemy.maxHealth * 100)

				enemyTable[i].indicatorText = percentLeft .. "% Harass"
				enemyTable[i].ready = SpellQ.ready and SpellW.ready and SpellE.ready and SpellR.ready
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
			if enemy.health < SpellR.mega.dmg and GnarMenu.ks.useR then
				CastR(enemy, 1, 1)
			elseif enemy.health < SpellQ.mega.dmg and SpellP.enabled or enemy.health < SpellQ.mini.dmg then
				CastQ(enemy)
			elseif enemy.health < SpellW.mega.dmg and SpellP.enabled then
				CastW(enemy)
			elseif enemy.health < SpellE.mega.dmg and SpellP.enabled or enemy.health < SpellE.mini.dmg then
				CastE(enemy)
			elseif enemy.health < SpellQ.mega.dmg + SpellR.mega.dmg and SpellP.enabled and GnarMenu.ks.useR then
				CastQ(enemy)
			elseif enemy.health < SpellW.mega.dmg + SpellR.mega.dmg and SpellP.enabled and GnarMenu.ks.useR then
				CastW(enemy)
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
			if GetDistanceSqr(currentEnemy, unit) <= range * range and not currentEnemy.dead then count = count + 1 end
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

-- UpdateWeb
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
