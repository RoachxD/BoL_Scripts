local MF_Ver = "1.021"
--[[


			.88b  d88. d888888b .d8888. .d8888.      d88888b  .d88b.  d8888b. d888888b db    db d8b   db d88888b 
			88'YbdP`88   `88'   88'  YP 88'  YP      88'     .8P  Y8. 88  `8D `~~88~~' 88    88 888o  88 88'     
			88  88  88    88    `8bo.   `8bo.        88ooo   88    88 88oobY'    88    88    88 88V8o 88 88ooooo 
			88  88  88    88      `Y8b.   `Y8b.      88~~~   88    88 88`8b      88    88    88 88 V8o88 88~~~~~ 
			88  88  88   .88.   db   8D db   8D      88      `8b  d8' 88 `88.    88    88b  d88 88  V888 88.     
			YP  YP  YP Y888888P `8888Y' `8888Y'      YP       `Y88P'  88   YD    YP    ~Y8888P' VP   V8P Y88888P 


		Script - Miss Fortune 1.02 by Roach

		Dependency: 
			- Nothing

		Changelog:
			1.02
				- Fixed Script not Drawing circles
				- Fixed Ult Cancelling
				- Fixed Casting E at Mouse Pos Bug

			1.01
				- Fixed spamming errors to Random Users
				- Changed OnDraw Functionality

			1.00
				- Revamped the whole script
				- Removed Farming Function as SAC / MMA handles that
				- Improved Script's Performance
				- Changed Menu
				- Added Aim-Ult Hotkey
				- Improved Combo
				- Added a lot of features

			0.08
				- Improved Script Performance
				- Fixed Spamming Errors

			0.07
				- Updated the Script after the Rework
				- Improved Bouncing Q Maths (Thanks to Honda for the Input)
				- Improved FPS Drops
				- Fixed Ult Breaking
				- Fixed Spamming Nil Errors
			
			0.06
				- Hopefully improved Bouncing Q

			0.05
				- Fixed Spamming Errors
			
			0.04
				- Fixed Bouncing Q Casting
			
			0.03
				- Improved Bouncing Q
				- Improved Bouncing Q Logics
			
			0.02
				- Fixed Ult Breaking
			
			0.01
				- First Release

]]

if myHero.charName ~= "MissFortune" or not VIP_USER then return end

local MF_Autoupdate = true

local REQUIRED_LIBS = {
	["VPrediction"] = "https://raw.githubusercontent.com/honda7/BoL/master/Common/VPrediction.lua"
}

local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<font color=\"#FF0000\"><b>Free Miss Fortune:</b></font> <font color=\"#FFFFFF\">Required libraries downloaded successfully, please reload (double F9).</font>")
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

local UPDATE_NAME = "Free Miss Fortune"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/RoachxD/BoL_Scripts/master/Free%20Miss%20Fortune.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#FF0000\">"..UPDATE_NAME..":</font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if MF_Autoupdate then
	local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
	if ServerData then
		local ServerVersion = string.match(ServerData, "local MF_Ver = \"%d+.%d+\"")
		ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
		if ServerVersion then
			ServerVersion = tonumber(ServerVersion)
			if tonumber(MF_Ver) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..MF_Ver.." => "..ServerVersion.."), press F9 twice to load the updated version.") end)	 
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

local Config = nil
local VP = VPrediction()

local Spells = {
	["Q"] = { key = _Q, speed = 1400, range =  650, bRange = 500, delay = 0.290, width =   0, ready = false					 },
	["W"] = { key = _W, 																	  ready = false					 },
	["E"] = { key = _E, speed =  500, range =  800, 			  delay = 0.500, width = 300, ready = false					 },
	["R"] = { key = _R, speed =  780, range = 1400,				  delay = 0.333, width = 100, ready = false, casting = false } 
}

function OnLoad()
	Menu()
	Init()
end

function Init()
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1400, DAMAGE_PHYSICAL)
	TargetSelector.name = "Ranged Main"

	Config:addTS(TargetSelector)

	EnemyMinions = minionManager(MINION_ENEMY, Spells.R.range, myHero, MINION_SORT_MAXHEALTH_DEC)

	initDone = true
end

function Menu()
	Config = scriptConfig("Miss Fortune v"..MF_Ver, "MF")

	Config:addSubMenu("Combo", "Combo")
		Config.Combo:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("usebQ", "Use Bouncing Q", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("Enabled", "Combo!", SCRIPT_PARAM_ONKEYDOWN, false, 32)

	Config:addSubMenu("Harass", "Harass")
		Config.Harass:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.Harass:addParam("usebQ", "Use Bouncing Q", SCRIPT_PARAM_ONOFF, true)
		Config.Harass:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
		Config.Harass:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, false)
		Config.Harass:addParam("mManager", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
		Config.Harass:addParam("Enabled", "Harass!", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))

	Config:addSubMenu("Ultimate", "Ultimate")
		Config.Ultimate:addParam("minEnemies", "Enemies in Cone: ", SCRIPT_PARAM_LIST, 1, {"0 < Enemies", "1 < Enemies", "2 < Enemies", "3 < Enemies", "4 < Enemies"})
		Config.Ultimate:addParam("Enabled", "Get best cone for Ult & Cast", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('T'))

	Config:addSubMenu("Killsteal", "Killsteal")
		Config.Killsteal:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.Killsteal:addParam("usebQ", "Use Bouncing Q", SCRIPT_PARAM_ONOFF, true)

	Config:addSubMenu("Draw", "Draw")
		Config.Draw:addSubMenu("Range Indicators", "Range")
			Config.Draw.Range:addParam("DrawQmin", "Draw Q Min Range", SCRIPT_PARAM_ONOFF, true)
			Config.Draw.Range:addParam("DrawQmas", "Draw Q Min Range", SCRIPT_PARAM_ONOFF, true)
			Config.Draw.Range:addParam("DrawE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
			Config.Draw.Range:addParam("DrawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
		Config.Draw:addParam("lagFree", "Use Lag Free Circles", SCRIPT_PARAM_ONOFF, false)

	Config:addSubMenu("Extras", "Extras")
		Config.Extras:addParam("usePackets", "Use Packet Cast", SCRIPT_PARAM_ONOFF, false)
		Config.Extras:addParam("eGapClosers", "Auto-E Gap Closers", SCRIPT_PARAM_ONOFF, true)
end

function GetCustomTarget()
	TargetSelector:update()

	if _G.MMA_Target and _G.MMA_Target.type == myHero.type then
		return _G.MMA_Target
	elseif _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair then
		return _G.AutoCarry.Attack_Crosshair.target
	elseif TargetSelector.target and not TargetSelector.target.dead and TargetSelector.target.type  == "obj_AI_Hero" then
		return TargetSelector.target
	else
		return nil
	end
end

function OnTick()
	if not initDone or Spells.R.casting then return end

	Check()

	if Config.Combo.Enabled then
		Combo(Target)
	end
	if Config.Harass.Enabled then
		Harass(Target)
	end
	if Config.Ultimate.Enabled then
		CastR(Target)
	end
	if Config.Extras.eGapClosers then
		CheckDashes()
	end

	KillSteal()
end

function Combo(unit)
	if unit == nil then return end

	for i, minion in pairs(EnemyMinions.objects) do
		if minion ~= nil then
			if GetQPriorities(minion, unit) and Config.Combo.usebQ then
				CastbQ(unit)
			elseif not GetQPriorities(minion, unit) and Config.Combo.useQ then
				CastQ(unit)
			end
		end
	end

	if Config.Combo.useW then
		CastW(unit)
	end

	if Config.Combo.useE then
		CastE(unit)
	end
end

function Harass(unit)
	if unit == nil then return end

	for i, minion in pairs(EnemyMinions.objects) do
		if minion ~= nil then
			if GetQPriorities(minion, unit) and Config.Harass.usebQ and not isLowMana(myHero, Config.Harass.mManager) then
				CastbQ(unit)
			elseif not GetQPriorities(minion, unit) and Config.Harass.useQ and not isLowMana(myHero, Config.Harass.mManager) then
				CastQ(unit)
			end
		end
	end

	if Config.Harass.useW and not isLowMana(myHero, Config.Harass.mManager) then
		CastW(unit)
	end

	if Config.Harass.useE and not isLowMana(myHero, Config.Harass.mManager) then
		CastE(unit)
	end
end

function CastQ(unit)
	if unit == nil or not ValidTarget(unit, Spells.Q.range) or not Spells.Q.ready then return end

	if Config.Extras.usePackets then
		Packet("S_CAST", {spellId = Spells.Q.key, targetNetworkId = unit.networkID}):send()
	else
		CastSpell(Spells.Q.key, unit)
	end
end

function CastbQ(unit)
	if unit == nil or not ValidTarget(unit) or not Spells.Q.ready then return end

	for i, minion in pairs(EnemyMinions.objects) do
		Position, HitChance = VP:GetPredictedPos(unit, Spells.Q.delay, Spells.Q.speed, myHero, false)
		if unit == nil or minion == nil or GetDistanceSqr(Position, minion) > Spells.Q.bRange*Spells.Q.bRange or not GetQPriorities(minion, unit) then return end

		if Config.Extras.usePackets then
			Packet("S_CAST", {spellId = Spells.Q.key, targetNetworkId = minion.networkID}):send()
		else
			CastSpell(Spells.Q.key, minion)
		end
	end
end

function CastW(unit)
	if unit == nil or not ValidTarget(unit, myHero.range) or not Spells.W.ready then return end

	CastSpell(Spells.W.key)
end

function CastE(unit)
	if unit == nil or not ValidTarget(unit, Spells.E.range) or not Spells.E.ready then return end

	local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(Target, Spells.E.delay, Spells.E.width, Spells.E.range, Spells.E.speed, myHero)
	if MainTargetHitChance < 2 and GetDistanceSqr(myHero, AOECastPosition) > Spells.E.range*Spells.E.range then return end

	if Config.Extras.usePackets then
		Packet("S_CAST", {spellId = Spells.E.key, toX = AOECastPosition.x, toY = AOECastPosition.z, fromX = AOECastPosition.x, fromy = AOECastPosition.z}):send()
	else
		CastSpell(Spells.E.key, AOECastPosition.x, AOECastPosition.z)
	end
end

function CastR(unit)
	if unit == nil or not ValidTarget(unit, Spells.R.range) or not Spells.R.ready then return end

	local mainCastPosition, mainHitChance, maxHit = VP:GetConeAOECastPosition(unit, Spells.R.delay, 30, Spells.R.range, Spells.R.speed, myHero)
	if mainHitChance < 2 or maxHit < Config.Ultimate.minEnemies then return end

	if Config.Extras.usePackets then
		Packet("S_CAST", {spellId = Spells.R.key, toX = mainCastPosition.x, toY = mainCastPosition.z}):send()
	else
		CastSpell(Spells.R.key, mainCastPosition.x, mainCastPosition.z)
	end
	Spells.R.casting = true
end

function KillSteal()
	local Enemies = GetEnemyHeroes()
	for _, enemy in pairs(Enemies) do
		if not ValidTarget(enemy) or enemy == nil or enemy.dead or GetDistanceSqr(myHero, enemy) > 1400*1400 then return end

		if getDmg("Q", enemy, myHero) > enemy.health and Config.Killsteal.useQ then
			CastQ(enemy)
		end
		if (getDmg("Q", enemy, myHero) + (getDmg("Q", enemy, myHero) * 0.2)) > enemy.health and Config.Killsteal.usebQ then
			CastbQ(enemy)
		end
	end
end

function OnDraw()
	if not myHero.dead then
		if Config.Draw.lagFree then
			if Config.Draw.Range.DrawQmin then
				DrawCircle2(myHero.x, myHero.y, myHero.z, Spells.Q.range,					ARGB(255,178, 0 , 0 ))
			end
			if Config.Draw.Range.DrawQmax then
				DrawCircle2(myHero.x, myHero.y, myHero.z, Spells.Q.range + Spells.Q.bRange,	ARGB(255, 32,178,170))
			end
			if Config.Draw.Range.DrawE then
				DrawCircle2(myHero.x, myHero.y, myHero.z, Spells.E.range,					ARGB(255,128, 0 ,128))
			end
			if Config.Draw.Range.DrawR then
				DrawCircle2(myHero.x, myHero.y, myHero.z, Spells.R.range,					ARGB(255, 0, 255, 255))
			end
		else
			if Config.Draw.Range.DrawQmin then
				DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range,					ARGB(255,178, 0 , 0 ))
			end
			if Config.Draw.Range.DrawQmax then
				DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range + Spells.Q.bRange,	ARGB(255, 32,178,170))
			end
			if Config.Draw.Range.DrawE then
				DrawCircle(myHero.x, myHero.y, myHero.z, Spells.E.range,					ARGB(255,128, 0 ,128))
			end
			if Config.Draw.Range.DrawR then
				DrawCircle(myHero.x, myHero.y, myHero.z, Spells.R.range,					ARGB(255, 0, 255, 255))
			end
		end
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == "missfortunebulletsound" then
		Spells.R.casting = true
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == "missfortunebulletsound" then
		Spells.R.casting = false
	end
end

function OnSendPacket(p)
	if Spells.R.casting then
		if (p.header == Packet.headers.S_MOVE or p.header == Packet.headers.S_CAST) and (Packet(p):get('spellId') ~= SUMMONER_1 and Packet(p):get('spellId') ~= SUMMONER_2) then
			Packet(p):Block()
		end
	end
end

function Check()
	EnemyMinions:update()

	Target = GetCustomTarget()

	for i, Spell in pairs(Spells) do
		Spell.ready = (myHero:CanUseSpell(Spell.key) == READY)
	end
end

function CheckDashes()
	local Enemies = GetEnemyHeroes()
	for _, enemy in pairs(Enemies) do
		if enemy.dead or not ValidTarget(enemy) or GetDistanceSqr(myHero, enemy) > Spells.E.range*Spells.E.range  then return end

		local IsDashing, CanHit, Position = VP:IsDashing(enemy, Spells.E.delay, Spells.E.width, Spells.E.speed, myHero)
		if not IsDashing or not CanHit or GetDistanceSqr(myHero, Position) > Spells.E.range*Spells.E.range or not Spells.E.ready then return end

		if Config.Extras.usePackets then
			Packet("S_CAST", {spellId = Spells.E.key, toX = Position.x, toY = Position.z, fromX = Position.x, fronY = Position.z}):send()
		else
			CastSpell(Spells.E.key, Position.x, Position.z)
		end
	end
end

function isLowMana(unit, slider)
	if unit.mana < (unit.maxMana * (slider / 100)) then
		return true
	else
		return false
	end
end

function GetTriangle(triangle_target, angle, unit)
	if triangle_target == nil or unit == nil or GetDistanceSqr(unit, triangle_target) > Spells.Q.bRange*Spells.Q.bRange or GetDistanceSqr(myHero, triangle_target) > Spells.Q.range*Spells.Q.range then return end

	v1 = (Vector(triangle_target) - Vector(myHero)):rotated(0, angle / (180 * math.pi), 0):normalized()
	v2 = (Vector(triangle_target) - Vector(myHero)):rotated(0, -(angle / (180 * math.pi)), 0):normalized()
	triangle = Polygon(Point(triangle_target.x, triangle_target.z), Point(triangle_target.x + 300 * v1.x, triangle_target.z + 300 * v1.z), Point(triangle_target.x + 300 * v2.x, triangle_target.z + 300 * v2.z))

	if triangle:contains(Point(unit.x, unit.z)) then
		return true
	else
		return false
	end
end

function GetQPriorities(minion, unit)
	if minion == nil or unit == nil or GetDistanceSqr(unit, triangle_target) > Spells.Q.bRange*Spells.Q.bRange or GetDistanceSqr(myHero, triangle_target) > Spells.Q.range*Spells.Q.range then return end

	for i, secure_minion in pairs(EnemyMinions.objects) do
		if secure_minion == nil then return end

		if GetTriangle(minion, 40, unit) and TargetHaveBuff("missfortunepassivestack", unit) then
			return true
		end
		if GetTriangle(minion, 20, unit) and ((GetTriangle(minion, 20, secure_minion) and GetDistance(minion, secure_minion) > GetDistance(minion, unit)) or not GetTriangle(minion, 20, secure_minion)) and minion ~= secure_minion then
			return true
		end
		if GetTriangle(minion, 40, unit) and ((GetTriangle(minion, 40, secure_minion) and GetDistance(minion, secure_minion) > GetDistance(minion, unit)) or not GetTriangle(minion, 40, secure_minion)) and minion ~= secure_minion then
			return true
		end
		if GetTriangle(minion, 90, unit) and ((GetTriangle(minion, 90, secure_minion) and GetDistance(minion, secure_minion) > GetDistance(minion, unit)) or not GetTriangle(minion, 90, secure_minion)) and minion ~= secure_minion then
			return true
		end
	end

	return false
end

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

function round(num) 
	if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
		DrawCircleNextLvl(x, y, z, radius, 1, color, PanthMenu.drawing.lfc.CL) 
	end
end
