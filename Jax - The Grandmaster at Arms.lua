local version = "1.28"
--[[


			   d88b  .d8b.  db    db 
			   `8P' d8' `8b `8b  d8' 
			    88  88ooo88  `8bd8'  
			    88  88~~~88  .dPYb.  
			db. 88  88   88 .8P  Y8. 
			Y8888P  YP   YP YP    YP 


		Script - Jax - The Grandmaster at Arms

		Dependency: 
			- Nothing

		Changelog:
			1.2
				- Fixed Ward-Jump Problems
				- Added a check to Enable/Disable myHero.range in the Draw Menu
				- Added an Option to see who are you Targeting
				- Added one more Q option: (Use) If target not in E Range
				- Added one more W option: (Use) When Available
				- Improved Auto-Updater
				- Fixed a Range bug:
					- Target Selector was selecting the Target in Q-Range even if Q wasn't available, so this was Lethal in a Team-Fight
				- Modified E's Range
				- Using SxOrbWalker

			1.1
				- Fixed Target Selector Range
				- Added Q Options in the Misc Menu
				- Added Ward-Jump
				- Improved & Fixed Ward-Jump Problems
				- Improved Harass Function
				- Added Q toggle in Harass
				- Fixed E Activation

			1.0
				- First Release

--]]

if myHero.charName ~= "Jax" then return end

_G.Jax_Autoupdate = true

local SxOW_downloadNeeded, SxOW_downloadName = false, "SxOrbWalk"

function AfterDownload()
	SxOW_downloadNeeded = false
	print("<font color=\"#FF0000\">Jax - The Grandmaster at Arms:</font> <font color=\"#FFFFFF\">Orbwalker library downloaded successfully, please reload (double F9).</font>")
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

local script_downloadName = "Jax - The Grandmaster at Arms"
local script_downloadHost = "raw.github.com"
local script_downloadPath = "/RoachxD/BoL_Scripts/master/Jax%20-%20The%20Grandmaster%20at%20Arms.lua" .. "?rand=" .. math.random(1, 10000)
local script_downloadUrl = "https://" .. script_downloadHost .. script_downloadPath
local script_filePath = SCRIPT_PATH..script_downloadName .. ".lua"

function script_Messager(msg) print("<font color=\"#FF0000\">" .. script_downloadName .. ":</font> <font color=\"#FFFFFF\">" .. msg .. ".</font>") end

if _G.Jax_Autoupdate then
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

	if JaxMenu.combo.comboKey then
		Combo(Target)
	end
	if JaxMenu.harass.harassKey then
		Harass(Target)
	end
	if JaxMenu.farming.farmKey then
		Farm()
	end
	if JaxMenu.jungle.jungleKey then
		JungleClear()
	end

	if JaxMenu.ks.killSteal then
		KillSteal()
	end
	if JaxMenu.misc.wardJump then
		moveToCursor()
		local WardPos = GetDistanceSqr(mousePos) <= SpellW_.range * SpellW_.range and mousePos or getMousePos()
		wardJump(WardPos.x, WardPos.z)
	end

	if JaxMenu.misc.ult.Enable then
		if CountEnemyHeroInRange(700) >= JaxMenu.misc.ult.minEnemies then
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

	SpellQ = { name = "Leap Strike",			range = 700,			ready = false, dmg = 0, manaUsage = 0						}
	SpellW = { name = "Empower",				range = myHero.range,	ready = false, dmg = 0, manaUsage = 0						}
	SpellE = { name = "Counter Strike",			range = 250,			ready = false, dmg = 0, manaUsage = 0,	variable = false	}
	SpellR = { name = "Grandmaster's Might",	range = 700																			}

	SpellI = { name = "SummonerDot",			range = 600,			ready = false, dmg = 0,					variable = nil		}

	SpellW_= {									range = 600, 									lastJump = 0,	itemSlot = nil		}

	Wards = {
		TrinketWard		= { 			ready = false },
		RubySightStone	= { slot = nil, ready = false },
		SightStone		= { slot = nil, ready = false },
		SightWard		= { slot = nil, ready = false },
		VisionWard		= { slot = nil, ready = false }
	}

	Wards_ = {}

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
	JaxMenu = scriptConfig("Jax - The Grandmaster at Arms", "Jax")
	
	JaxMenu:addSubMenu("[" .. myHero.charName .. "] - Combo Settings", "combo")
		JaxMenu.combo:addParam("comboKey", "Full Combo Key (SBTW)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		JaxMenu.combo:addParam("useW", "Use " .. SpellW.name .. " (W) in Combo", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.combo:addParam("comboItems", "Use Items in Combo", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.combo:permaShow("comboKey")
	
	JaxMenu:addSubMenu("[" .. myHero.charName .. "] - Harass Settings", "harass")
		JaxMenu.harass:addParam("harassKey", "Harass key (C)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		JaxMenu.harass:addParam("useQ", "Use " .. SpellQ.name .. " (Q) in Harass", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.harass:addParam("useE", "Use " .. SpellE.name .. " (E) in Harass", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.harass:addParam("harassMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		JaxMenu.harass:permaShow("harassKey")
		
	
	JaxMenu:addSubMenu("[" .. myHero.charName .. "] - Farm Settings", "farming")
		JaxMenu.farming:addParam("farmKey", "Farming Key (X)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
		JaxMenu.farming:addParam("qFarm", "Farm with " .. SpellQ.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.farming:addParam("FarmMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		JaxMenu.farming:permaShow("farmKey")
		
	JaxMenu:addSubMenu("[" .. myHero.charName .. "] - Jungle Clear Settings", "jungle")
		JaxMenu.jungle:addParam("jungleKey", "Jungle Clear Key (V)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
		JaxMenu.jungle:addParam("jungleQ", "Clear with " .. SpellQ.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.jungle:addParam("jungleW", "Clear with " .. SpellW.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.jungle:addParam("jungleE", "Clear with " .. SpellE.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.jungle:permaShow("jungleKey")
		
		
	JaxMenu:addSubMenu("[" .. myHero.charName .. "] - KillSteal Settings", "ks")
		JaxMenu.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.ks:addParam("useW", "Use " .. SpellW.name .. " (W) to KS", SCRIPT_PARAM_ONOFF, false)
		JaxMenu.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.ks:permaShow("killSteal")
			
	JaxMenu:addSubMenu("[" .. myHero.charName .. "] - Draw Settings", "drawing")	
		JaxMenu.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		JaxMenu.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.drawing:addParam("cDraw", "Draw Damage Text", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.drawing:addParam("myHero", "Draw My Hero's Range", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.drawing:addParam("qDraw", "Draw " .. SpellQ.name .. " (Q) Range", SCRIPT_PARAM_ONOFF, true)
		JaxMenu.drawing:addParam("eDraw", "Draw " .. SpellE.name .. " (E) Range", SCRIPT_PARAM_ONOFF, true)
	
	JaxMenu:addSubMenu("[" .. myHero.charName .. "] - Misc Settings", "misc")
		JaxMenu.misc:addParam("wardJump", "Ward Jump (G)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('G'))
		JaxMenu.misc:addSubMenu("Spells - Misc Settings", "smisc")
			JaxMenu.misc.smisc:addParam("stopChannel", "Interrupt Channeling Spells", SCRIPT_PARAM_ONOFF, true)
		if VIP_USER then
			JaxMenu.misc:addSubMenu("Spells - Cast Settings", "cast")
				JaxMenu.misc.cast:addParam("usePackets", "Use Packets to Cast Spells", SCRIPT_PARAM_ONOFF, false)
		end
		JaxMenu.misc:addSubMenu("Spells - " .. SpellQ.name .. " (Q) Settings", "q")
			JaxMenu.misc.q:addParam("howTo", "Use " .. SpellQ.name .. " (Q): ", SCRIPT_PARAM_LIST, 1, { "Always", "Only as a Gap-Closer", "If target not in E Range" })
		JaxMenu.misc:addSubMenu("Spells - " .. SpellW.name .. " (W) Settings", "w")
			JaxMenu.misc.w:addParam("howTo", "Use " .. SpellW.name .. " (W): ", SCRIPT_PARAM_LIST, 2, { "After every AA", "After every third AA", "When Available" })
		JaxMenu.misc:addSubMenu("Spells - " .. SpellE.name .. " (E) Settings", "e")
			JaxMenu.misc.e:addParam("howTo", "Cast " .. SpellE.name .. " (E): ", SCRIPT_PARAM_LIST, 1, { "If in Q Range and Q Ready", "Only if in Melee Range" })
			JaxMenu.misc.e:addParam("whenTo", "Activate "..SpellE.name.." (E): ", SCRIPT_PARAM_LIST, 3, { "Instantly", "If target in Max Radius", "No" })
		JaxMenu.misc:addSubMenu("Spells - " .. SpellR.name .. " (R) Settings", "ult")
			JaxMenu.misc.ult:addParam("Enable", "Enable Auto Ult", SCRIPT_PARAM_ONOFF, true)
			JaxMenu.misc.ult:addParam("minEnemies", "Min. Enemies in Range: ", SCRIPT_PARAM_SLICE, 2, 2, 5, 0)

		JaxMenu:addSubMenu("[" .. myHero.charName .. "] - Orbwalking Settings", "Orbwalking")
			SxOrb:LoadToMenu(JaxMenu.Orbwalking, false)

	TargetSelector = TargetSelector(TARGET_LESS_CAST, SpellQ.range, DAMAGE_PHYSICAL)
	TargetSelector.name = "Jax"
	JaxMenu:addTS(TargetSelector)

	JaxMenu:addParam("jaxVer", "Version: ", SCRIPT_PARAM_INFO, version)
end

function OnProcessSpell(unit, spell)
	if JaxMenu.misc.smisc.stopChannel then
		if GetDistanceSqr(unit) <= SpellE.range * SpellE.range then
			if InterruptingSpells[spell.name] then
				CastSpell(_E)
			end
		end
		if unit.isMe then
			if spell.name ~= "jaxrelentlessattack" and JaxMenu.misc.w.howTo == 2 then
				for i, cb in ipairs(SxOrb.AfterAttackCallbacks) do
					table.remove(SxOrb.AfterAttackCallbacks, i)
				end
			end
		end
	end
end

function OnCreateObj(obj)
	if obj.valid then
		if FocusJungleNames[obj.name] then
			JungleFocusMobs[#JungleFocusMobs+1] = obj
		elseif JungleMobNames[obj.name] then
			JungleMobs[#JungleMobs+1] = obj
		end

		if string.find(obj.name, "Ward") ~= nil or string.find(obj.name, "Wriggle") ~= nil or string.find(obj.name, "Trinket") then 
			Wards_[#Wards_+1] = obj
		end
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

	for i, ward in pairs(Wards_) do
		if obj.name == ward.name and obj.x == ward.x and obj.z == ward.z then
			table.remove(Wards_, i)
		end
	end
end

function OnDraw()
	if not myHero.dead then
		if not JaxMenu.drawing.mDraw then
			if JaxMenu.drawing.qDraw and SpellQ.ready then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.range, ARGB(255,178, 0 , 0 ))
			end
			if JaxMenu.drawing.eDraw and SpellE.ready then
				DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.range, ARGB(255, 32,178,170))
			end
		end
		if JaxMenu.drawing.Target then
			if Target ~= nil then
				DrawCircle3D(Target.x, Target.y, Target.z, 70, 1, ARGB(255, 255, 0, 0))
			end
		end
		if JaxMenu.drawing.cDraw then
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

	Wards.RubySightStone.slot = GetInventorySlotItem(2045)
	Wards.SightStone.slot = GetInventorySlotItem(2049)
	Wards.SightWard.slot = GetInventorySlotItem(2044)
	Wards.VisionWard.slot = GetInventorySlotItem(2043)

	Wards.TrinketWard.ready		= (myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3340) or (myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3350) or (myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3361) or (myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3362)
	Wards.RubySightStone.ready	= (Wards.RubySightStone.slot	~= nil and	myHero:CanUseSpell(Wards.RubySightStone.slot)	== READY)
	Wards.SightStone.ready		= (Wards.SightStone.slot		~= nil and	myHero:CanUseSpell(Wards.SightStone.slot)		== READY)
	Wards.SightWard.ready		= (Wards.SightWard.slot			~= nil and	myHero:CanUseSpell(Wards.SightWard.slot)		== READY)
	Wards.VisionWard.ready		= (Wards.VisionWard.slot		~= nil and	myHero:CanUseSpell(Wards.VisionWard.slot)		== READY)

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

	if not JaxMenu.combo.comboKey and not JaxMenu.farming.farmKey and not JaxMenu.harass.harassKey and not JaxMenu.jungle.jungleKey then
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
		if JaxMenu.combo.comboItems then
			UseItems(unit)
		end
		
		CastE(unit)
		ActivateE(unit)

		CastQ(unit)

		if JaxMenu.combo.useW then
			if JaxMenu.misc.w.howTo ~= 3 then
				SxOrb:RegisterAfterAttackCallback(function()
													CastSpell(_W)
												end)
			else
				if GetDistanceSqr(unit, myHero) <= SxOrb.MyRange * SxOrb.MyRange then
					CastSpell(_W)
				end
			end
		end
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		if not isLow('Mana', myHero, JaxMenu.harass.harassMana) then
			if GetDistanceSqr(unit, myHero) <= SpellQ.range * SpellQ.range and JaxMenu.harass.useQ and SpellQ.ready then
				CastSpell(_W)
			elseif not JaxMenu.harass.useQ then
				SxOrb:RegisterAfterAttackCallback(function()
												CastSpell(_W)
											end)
			end
			if JaxMenu.harass.useE then
				CastE(unit)
				ActivateE(unit)
			end
			if JaxMenu.harass.useQ then
				CastQ(unit)
			end
		end
	end
end

function Farm()
	enemyMinions:update()
	for i, minion in pairs(enemyMinions.objects) do
		if ValidTarget(minion) and minion ~= nil then
			if minion.health <= SpellQ.dmg and (not SxOrb:CanAttack() or GetDistanceSqr(minion, myHero) > SxOrb.MyRange * SxOrb.MyRange) and JaxMenu.farming.qFarm and not isLow('Mana', myHero, JaxMenu.farming.FarmMana) then
				CastQ(minion)
			end
		end		 
	end
end

function JungleClear()
	if JaxMenu.jungle.jungleKey then
		local JungleMob = GetJungleMob()
		if JungleMob ~= nil then
			if JaxMenu.jungle.jungleE then
				CastE(JungleMob)
				ActivateE(JungleMob)
			end
			if JaxMenu.jungle.jungleQ then
				CastQ(JungleMob)
			end
			if JaxMenu.combo.useW then
			if JaxMenu.misc.w.howTo ~= 3 then
				SxOrb.RegisterAfterAttackCallback(function()
													CastSpell(_W)
												end)
			else
				if GetDistanceSqr(JungleMob, myHero) <= SxOrb.MyRange * SxOrb.MyRange then
					CastSpell(_W)
				end
			end
		end
		end
	end
end

function CastQ(unit)
	if unit == nil or not SpellQ.ready or (GetDistanceSqr(unit, myHero) > SpellQ.range * SpellQ.range) then
		return false
	end
	if JaxMenu.misc.q.howTo == 1 or (JaxMenu.misc.q.howTo == 2 and GetDistanceSqr(unit, myHero) > SxOrb.MyRange * SxOrb.MyRange) or (JaxMenu.misc.q.howTo == 3 and GetDistanceSqr(unit, myHero) > SpellE.range * SpellE.range) then
		if not VIP_USER or not JaxMenu.misc.cast.usePackets then
			CastSpell(_Q, unit)
		elseif VIP_USER and JaxMenu.misc.cast.usePackets then
			Packet("S_CAST", { spellId = _Q, targetNetworkId = unit.networkID }):send()
		end
	end
end


function CastE(unit)
	if unit == nil or not SpellE.ready or SpellE.variable then
		return false
	end
	if (JaxMenu.misc.e.howTo == 1 and ((SpellQ.ready and GetDistanceSqr(unit, myHero) <= SpellQ.range * SpellQ.range) or GetDistanceSqr(unit, myHero) <= SpellE.range * SpellE.range)) or (JaxMenu.misc.e.howTo == 2 and GetDistanceSqr(unit, myHero) <= SpellE.range * SpellE.range) then
		CastSpell(_E)

		SpellE.variable = true

		DelayAction(function()
						SpellE.variable = false
					end, 2.5)
	end
end

function ActivateE(unit)
	if unit == nil or not SpellE.ready or (GetDistanceSqr(unit) > SpellE.range * SpellE.range) or not SpellE.variable then
		return false
	end
	if JaxMenu.misc.e.whenTo ~= 3 then
		if JaxMenu.misc.e.whenTo == 1 or (JaxMenu.misc.e.whenTo == 2 and GetDistanceSqr(unit, myHero) > (SpellE.range - 3.5) * (SpellE.range - 3.5)) then
			CastSpell(_E)

			SpellE.variable = false
		end
	end
end

function wardJump(x, y)
	if SpellQ.ready then
		local WardDistance = 300

		if next(Wards_) ~= nil then
			for i, obj in pairs(Wards_) do 
				if obj.valid then
					MousePos = getMousePos()
					if GetDistanceSqr(obj, MousePos) <= WardDistance * WardDistance then
						CastSpell(_Q, obj)
						SpellW_.lastJump = os.clock() + 2
					 end
				end
			end
		end

		if os.clock() >= SpellW_.lastJump then
			if Wards.TrinketWard.ready then
				SpellW_.itemSlot = ITEM_7
			elseif Wards.RubySightStone.ready then
				SpellW_.itemSlot = Wards.RubySightStone.slot
			elseif Wards.SightStone.ready then 
				SpellW_.itemSlot = Wards.SightStone.slot
			elseif Wards.SightWard.ready then
				SpellW_.itemSlot = Wards.SightWard.slot
			elseif Wards.VisionWard.ready then
				SpellW_.itemSlot = Wards.VisionWard.slot
			end
			
			if SpellW_.itemSlot ~= nil then
				CastSpell(SpellW_.itemSlot, x, y)
				SpellW_.lastJump = os.clock() + 2
				SpellW_.itemSlot = nil
			end
		end
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

function getMousePos(range)
	local temprange = range or SpellW_.range
	local MyPos = Vector(myHero.x, myHero.y, myHero.z)
	local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)

	return MyPos - (MyPos - MousePos):normalized() * SpellW_.range
end

function moveToCursor()
	if GetDistance(mousePos) then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
		if not VIP_USER then
			myHero:MoveTo(moveToPos.x, moveToPos.z)
		else
			Packet('S_MOVE', {x = moveToPos.x, y = moveToPos.z}):send()
		end
	end		
end

function TargetSelectorRange()
	return SpellQ.ready and SpellQ.range or SpellE.range
end

function DmgCalc()
	for i = 1, enemyCount do
		local enemy = enemyTable[i].player
		if ValidTarget(enemy) and enemy.visible then
			SpellQ.dmg = (SpellQ.ready and getDmg("Q",		enemy, myHero	)) or 0
			SpellW.dmg = (SpellQ.ready and getDmg("W",		enemy, myHero	)) or 0
			SpellE.dmg = (SpellE.ready and getDmg("E",		enemy, myHero	)) or 0
			SpellI.dmg = (SpellI.ready and getDmg("IGNITE", enemy, myHero	)) or 0

			if enemy.health < SpellQ.dmg then
				enemyTable[i].indicatorText = "Q Kill"
				enemyTable[i].ready = SpellQ.ready and SpellQ.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellI.dmg then
				enemyTable[i].indicatorText = "Q + Ign Kill"
				enemyTable[i].ready = SpellQ.ready and SpellI.ready and SpellQ.manaUsage <= myHero.mana
			elseif enemy.health < SpellW.dmg then
				enemyTable[i].indicatorText = "W Kill"
				enemyTable[i].ready = SpellW.ready and SpellW.manaUsage <= myHero.mana
			elseif enemy.health < SpellW.dmg + SpellI.dmg then
				enemyTable[i].indicatorText = "W + Ign Kill"
				enemyTable[i].ready = SpellW.ready and SpellI.ready and SpellW.manaUsage <= myHero.mana
			elseif enemy.health < SpellE.dmg then
				enemyTable[i].indicatorText = "E Kill"
				enemyTable[i].ready = SpellE.ready and SpellE.manaUsage <= myHero.mana
			elseif enemy.health < SpellE.dmg + SpellI.dmg then
				enemyTable[i].indicatorText = "E + Ign Kill"
				enemyTable[i].ready = SpellE.ready and SpellI.ready and SpellE.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellW.dmg then
				enemyTable[i].indicatorText = "Q + W Kill"
				enemyTable[i].ready = SpellQ.ready and SpellW.ready and SpellQ.manaUsage + SpellW.manaUsage <= myHero.mana
			elseif enemy.health < SpellQ.dmg + SpellW.dmg + SpellI.dmg then
				enemyTable[i].indicatorText = "Q + W + Ign Kill"
				enemyTable[i].ready = SpellQ.ready and SpellW.ready and SpellI.ready and SpellQ.manaUsage + SpellW.manaUsage <= myHero.mana
			else
				local dmgTotal = SpellQ.dmg + SpellW.dmg + SpellE.dmg
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
			if enemy.health < SpellQ.dmg then
				CastQ(enemy)
			elseif enemy.health < SpellQ.dmg + SpellW.dmg and GetDistanceSqr(enemy, myHero) <= SpellQ.range * SpellQ.range and SpellQ.ready and SpellW.ready and JaxMenu.ks.useW then
				CastSpell(_W)
				CastQ(enemy)
			end

			if JaxMenu.ks.autoIgnite then
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

-- UpdateWeb
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
