local version = "0.04"
--[[


			d88888b d8888b. d88888b d88888b      .88b  d88. d888888b .d8888. .d8888.      d88888b  .d88b.  d8888b. d888888b db    db d8b   db d88888b 
			88'     88  `8D 88'     88'          88'YbdP`88   `88'   88'  YP 88'  YP      88'     .8P  Y8. 88  `8D `~~88~~' 88    88 888o  88 88'     
			88ooo   88oobY' 88ooooo 88ooooo      88  88  88    88    `8bo.   `8bo.        88ooo   88    88 88oobY'    88    88    88 88V8o 88 88ooooo 
			88~~~   88`8b   88~~~~~ 88~~~~~      88  88  88    88      `Y8b.   `Y8b.      88~~~   88    88 88`8b      88    88    88 88 V8o88 88~~~~~ 
			88      88 `88. 88.     88.          88  88  88   .88.   db   8D db   8D      88      `8b  d8' 88 `88.    88    88b  d88 88  V888 88.     
			YP      88   YD Y88888P Y88888P      YP  YP  YP Y888888P `8888Y' `8888Y'      YP       `Y88P'  88   YD    YP    ~Y8888P' VP   V8P Y88888P 


		Script - Free Miss Fortune 0.04 by Roach

		Dependency: 
			- Nothing

		Changelog:
			0.04 - Fixed Bouncing Q Casting
			0.03 - Improved Bouncing Q
				 - Improved Bouncing Q Logics
			0.02 - Fixed Ult Breaking
			0.01 - First Release

]]

if myHero.charName ~= "MissFortune" or not VIP_USER then return end

require 'VPrediction'

-- / Auto-Update Function / --
local autoupdateenabled = true
local UPDATE_SCRIPT_NAME = "Free Miss Fortune"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/RoachxD/BoL_Scripts/master/Free%20Miss%20Fortune.lua?chunk="..math.random(1, 1000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local ServerData
if autoupdateenabled then
	GetAsyncWebResult(UPDATE_HOST, UPDATE_PATH, function(d) ServerData = d end)
	function update()
		if ServerData ~= nil then
			local ServerVersion
			local send, tmp, sstart = nil, string.find(ServerData, "local version = \"")
			if sstart then
				send, tmp = string.find(ServerData, "\"", sstart+1)
			end
			if send then
				ServerVersion = tonumber(string.sub(ServerData, sstart+1, send-1))
			end

			if ServerVersion ~= nil and tonumber(ServerVersion) ~= nil and tonumber(ServerVersion) > tonumber(version) then
				DownloadFile(UPDATE_URL.."?nocache"..myHero.charName..os.clock(), UPDATE_FILE_PATH, function () print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> successfully updated. Reload (double F9) Please. ("..version.." => "..ServerVersion..")</font>") end)
			elseif ServerVersion then
				print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> You have got the latest version: <u><b>"..ServerVersion.."</b></u></font>")
			end		
			ServerData = nil
		end
	end
	AddTickCallback(update)
end
-- / Auto-Update Function / --

local Config = nil
local lastAnimation = nil
local VP = VPrediction()
local SkillQ = { speed = 2000, range =  650, bRange = 550, delay = 0.290, width =   0, ready = false			   }
local SkillW = { 																	   ready = false			   }
local SkillE = { speed =  500, range = 	800, 			   delay = 0.333, width = 400, ready = false			   }
local SkillR = { speed =  775, range = 1400, 			   delay = 0.261, width = 100, ready = false, buff = false } 

-- / OnLoad Function / --
function OnLoad()
	---> On Load Functions
		Menu()
		Init()
	---<
end
-- / OnLoad Function / --

-- / Init Function / --
function Init()
	---> Load Target Selector
		TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1400, DAMAGE_PHYSICAL)
		TargetSelector.name = "Ranged Main"

		Config:addTS(TargetSelector)
	---<
	---> Load Enemy Minions
		EnemyMinions = minionManager(MINION_ENEMY, SkillR.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	---<

	initDone = true
end
-- / Init Function / --

-- / Menu Function / --
function Menu()
	---> Main Menu
		Config = scriptConfig("Miss Fortune", "Miss Fortune")
		---> Combo Key
		Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			Config:permaShow("Combo")
		---<
		---> Harass Key
		Config:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))
			Config:permaShow("Harass")
		---<
		---> Farm Key
		Config:addParam("Farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))
			Config:permaShow("Farm")
		---<
		---> Combo Menu
		Config:addSubMenu("Combo options", "ComboSub")
			Config.ComboSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
			Config.ComboSub:addParam("usebQ", "Use Bouncing Q", SCRIPT_PARAM_ONOFF, true)
			Config.ComboSub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
			Config.ComboSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
			Config.ComboSub:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, true)
			Config.ComboSub:addParam("mManager", "Mana slider", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
		---<
		---> Harass Menu
		Config:addSubMenu("Harass options", "HarassSub")
			Config.HarassSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
			Config.HarassSub:addParam("usebQ", "Use Bouncing Q", SCRIPT_PARAM_ONOFF, true)
			Config.HarassSub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
			Config.HarassSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, false)
			Config.HarassSub:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, false)
			Config.HarassSub:addParam("mManager", "Mana slider", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
		---<
		---> Farming Menu
		Config:addSubMenu("Farm", "FarmSub")
			Config.FarmSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, false)
			Config.FarmSub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
		---<
		---> Killsteal Menu
		Config:addSubMenu("KS", "KS")
			Config.KS:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
			Config.KS:addParam("usebQ", "Use Bouncing Q", SCRIPT_PARAM_ONOFF, true)
		---<
		---> Extras Menu
		Config:addSubMenu("Extra Config", "Extras")
			Config.Extras:addParam("RMinRange", "R Minimum Range", SCRIPT_PARAM_SLICE, 500, 0, 1400, 0)
			Config.Extras:addParam("RMinEnemies", "R Minimum Number of Enemies", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)
			Config.Extras:addParam("EGapClosers", "E Gap Closers", SCRIPT_PARAM_ONOFF, true)
		---<
		---> Draw Menu
		Config:addSubMenu("Draw", "Draw")
			Config.Draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
			Config.Draw:addParam("DrawE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
			Config.Draw:addParam("DrawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
		---<
	---<
end
-- / Menu Function / --

-- / GetCustomTarget Function / --
function GetCustomTarget()
	---> Update Target Selector
		TargetSelector:update()
	---<
	---> Check Target Selector from MMA / SAC
		if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
		if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
	---<

	return TargetSelector.target
end
-- / GetCustomTarget Function / --

-- / OnTick Function / --
function OnTick()
	if not initDone then return end
	---> Load General Checks
		Check()
	---<
	---> Config Combo
		if Config.Combo and Target ~= nil then
			Combo(Target)
		end
	---<
	---> Config Harass
		if Config.Harass and Target ~= nil then
			Harass(Target)
		end
	---<
	---> Config Farm
		if Config.Farm then
			Farm()
		end
	---<
	---> Config Dashes
		if Config.Extras.EGapClosers then
			CheckDashes()
		end
	---<
	---> Config Killsteal
		KillSteal()
	---<
end
-- / OnTick Function / --

-- / Combo Function / --
function Combo(Target)
	if not SkillR.buff then
		for i, minion in ipairs(EnemyMinions.objects) do
			if GetDistance(minion) <= SkillQ.range and GetDistance(Target, minion) < (SkillQ.range - 150) and GetQVectorAngle(minion, Target) <= 35 and SkillQ.ready and Config.HarassSub.usebQ and not isLowMana('Combo') then
				CastbQ(Target)
			elseif (GetDistance(Target, minion) > (SkillQ.range - 150) or not GetQVectorAngle(minion, Target) <= 35) and SkillQ.ready and Config.HarassSub.useQ and not isLowMana('Combo') then
				CastQ(Target)
			end
		end

		if SkillW.ready and Config.ComboSub.useW and not isLowMana('Combo') then
			CastW(Target)
		end

		if SkillE.ready and Config.ComboSub.useE and not isLowMana('Combo') then
			CastE(Target)
		end

		if SkillR.ready and Config.ComboSub.useR and not isLowMana('Combo') and GetDistance(Target) > Config.Extras.RMinRange then
			CastR(Target)
		end
	end
end
-- / Combo Function / --

-- / Harass Function / --
function Harass(Target)
	if not SkillR.buff then
		for i, minion in ipairs(EnemyMinions.objects) do
			if GetDistance(minion) <= SkillQ.range and GetDistance(Target, minion) < (SkillQ.range - 150) and GetQVectorAngle(minion, Target) <= 35 and SkillQ.ready and Config.HarassSub.usebQ and not isLowMana('Harass') then
				CastbQ(Target)
			elseif (GetDistance(Target, minion) > (SkillQ.range - 150) or not GetQVectorAngle(minion, Target) <= 35) and SkillQ.ready and Config.HarassSub.useQ and not isLowMana('Harass') then
				CastQ(Target)
			end
		end

		if SkillW.ready and Config.HarassSub.useW and not isLowMana('Harass') then
			CastW(Target)
		end

		if SkillE.ready and Config.HarassSub.useE and not isLowMana('Harass') then
			CastE(Target)
		end

		if SkillR.ready and Config.HarassSub.useR and not isLowMana('Harass') and GetDistance(Target) > Config.Extras.RMinRange then
			CastR(Target)
		end
	end
end
-- / Harass Function / --

-- / CastQ Function / --
function CastQ(Target)
	---> Dynamic Q Cast
		if Target ~= nil and ValidTarget(Target, SkillQ.range) and SkillQ.ready then
			Packet("S_CAST", {spellId = _Q, targetNetworkId = Target.networkID}):send()
		end
	---<
end
-- / CastQ Function / --

-- / CastbQ Function / --
function CastbQ(Target)
	---> Minion Q Cast
		for i, minion in ipairs(EnemyMinions.objects) do
			if minion ~= nil and GetDistance(minion) <= SkillQ.range then
				if Target ~= nil and GetDistance(minion, Target) <= (SkillQ.range - 150) and GetQVectorAngle(minion, Target) <= 35 and SkillQ.ready then
					for i, bminion in ipairs(EnemyMinions.objects) do
						if GetClosestBetween(minion, Target, bminion) == Target and bminion ~= minion then
							Packet("S_CAST", {spellId = _Q, targetNetworkId = minion.networkID}):send()
						end
					end
				end
			end
		end
	---<
	---> Champ Q Cast
		local Enemies = GetEnemyHeroes()
		for i, enemy in pairs(Enemies) do
			if enemy ~= nil and GetDistance(enemy) <= SkillQ.range and Target ~= enemy then
				local QAngle = GetQVectorAngle(enemy, Target)
				if Target ~= nil and GetDistance(enemy, Target) <= (SkillQ.range - 150) and QAngle <= 35 and SkillQ.ready then
					Packet("S_CAST", {spellId = _Q, targetNetworkId = enemy.networkID}):send()
				end
			end
		end
	---<
end
-- / CastbQ Function / --

-- / CastW Function / --
function CastW(Target)
	---> Dynamic W Cast
		if Target ~= nil and ValidTarget(Target, myHero.range) and SkillW.ready then
			CastSpell(_W)
		end
	---<
end
-- / CastW Function / --

-- / CastE Function / --
function CastE(Target)
	---> Dynamic E Cast
		if Target ~= nil and ValidTarget(Target, SkillE.range) and SkillE.ready then
			local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(Target, SkillE.delay, SkillE.width, SkillE.range, SkillE.speed, myHero)
			if MainTargetHitChance >= 2 and GetDistance(AOECastPosition) < SkillE.range then
				CastSpell(_E, AOECastPosition.x, AOECastPosition.z)
			end
		end
	---<
end
-- / CastE Function / --

-- / CastR Function / --
function CastR(Target)
	---> Dynamic R Cast
		if not SkillR.ready then return end
		local CastPosition, HitChance, heroPos = VP:GetCircularCastPosition(Target, SkillR.delay, 1)
		if HitChance < 2 then return end

		if SkillR.ready and Target ~= nil and ValidTarget(Target, SkillR.range) then
			if CountEnemyHeroInRange(Config.Extras.RMinRange) <= Config.Extras.RMinEnemies then
				Count, RCastPosition = GetBestCone(SkillR.range, 30)
				if Count <= Config.Extras.RMinEnemies then
					Packet("S_CAST", {spellId = _R, toX = RCastPosition.x, toY = RCastPosition.z}):send()
				end
			end
		end
	---<
end
-- / CastR Function / --

-- / Farm Function / --
function Farm()
	if not SkillR.buff then
		if Config.FarmSub.useE then
			FarmE()
		end
		if Config.FarmSub.useW then
			FarmW()
		end
	end
end
-- / Farm Function / --

-- / Reset Function / --
function Reset()
	if _G.MMA_Loaded and _G.MMA_NextAttackAvailability < 0.6 then
		return true
	elseif _G.AutoCarry and (_G.AutoCarry.shotFired or _G.AutoCarry.Orbwalker:IsAfterAttack()) then 
		return true
	else
		return false
	end
end
-- / Reset Function / --

-- / KillSteal Function / --
function KillSteal()
	if not SkillR.buff then
		local Enemies = GetEnemyHeroes()
		for i, enemy in pairs(Enemies) do
			if ValidTarget(enemy) and not enemy.dead and GetDistance(enemy) < 1400 then
				if getDmg("Q", enemy, myHero) > enemy.health and  Config.KS.useQ then
					CastQ(enemy)
				end
				if (getDmg("Q", enemy, myHero) + (getDmg("Q", enemy, myHero) * 0.2)) > enemy.health and  Config.KS.usebQ then
					CastbQ(enemy)
				end
			end
		end
	end
end
-- / KillSteal Function / --

-- / OnDraw Function / --
function OnDraw()
	if Config.Draw.DrawQ then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillQ.range, 1,  ARGB(255, 0, 255, 255))
	end

	if Config.Draw.DrawW then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, WRange, 1,  ARGB(255, 0, 255, 255))
	end

	if Config.Draw.DrawE then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillE.range, 1,  ARGB(255, 0, 255, 255))
	end

	if Config.Draw.DrawR then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, RRange, 1,  ARGB(255, 0, 255, 255))
	end
end
-- / OnDraw Function / --

-- / OnGainBuff Function / --
function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == "missfortunebulletsound" then
		SkillR.buff = true
	end
end
-- / OnGainBuff Function / --

-- / OnLoseBuff Function / --
function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == "missfortunebulletsound" then
		SkillR.buff = false
	end
end
-- / OnLoseBuff Function / --

-- / Check Function / --
function Check()
	---> Check Minions Update
		EnemyMinions:update()
	---<
	---> Set up Target
		tsTarget = GetTarget()
		if tsTarget and tsTarget.type == "obj_AI_Hero" then
			Target = tsTarget
		else
			Target = nil
		end
	---<
	---> Set up Skills
		SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
		SkillW.ready = (myHero:CanUseSpell(_W) == READY)
		SkillE.ready = (myHero:CanUseSpell(_E) == READY)
		SkillR.ready = (myHero:CanUseSpell(_R) == READY)
	---<
	---> Set up Ult
		if SkillR.buff then
			if _G.AutoCarry then 
				if _G.AutoCarry.MainMenu ~= nil then
						if _G.AutoCarry.CanAttack ~= nil then
							_G.AutoCarry.CanAttack = false
							_G.AutoCarry.CanMove = false
						end
				elseif _G.AutoCarry.Keys ~= nil then
					if _G.AutoCarry.MyHero ~= nil then
						_G.AutoCarry.MyHero:MovementEnabled(false)
						_G.AutoCarry.MyHero:AttacksEnabled(false)
					end
				end
			elseif _G.MMA_Loaded then
				_G.MMA_Orbwalker	= false
				_G.MMA_HybridMode	= false
				_G.MMA_LaneClear	= false
				_G.MMA_LastHit		= false
			end
		else
			if _G.AutoCarry then 
				if _G.AutoCarry.MainMenu ~= nil then
						if _G.AutoCarry.CanAttack ~= nil then
							_G.AutoCarry.CanAttack = true
							_G.AutoCarry.CanMove = true
						end
				elseif _G.AutoCarry.Keys ~= nil then
					if _G.AutoCarry.MyHero ~= nil then
						_G.AutoCarry.MyHero:MovementEnabled(true)
						_G.AutoCarry.MyHero:AttacksEnabled(true)
					end
				end
			end
		end
	---<
end
-- / Check Function / --

-- / CountMinionsHitE Function / --
function CountMinionsHitE(pos, radius)
	local n = 0
	for i, minion in pairs(EnemyMinions.objects) do
		if GetDistance(minion, pos) < (radius + 50) then
			n = n + 1
		end
	end
	return n
end
-- / CountMinionsHitE Function / --

-- / GetBestEPositionFarm Function / --
function GetBestEPositionFarm()
	local MaxE = 0 
	local MaxEPos 
	for i, minion in pairs(EnemyMinions.objects) do
		local hitE = CountMinionsHitE(minion, 100)
		if hitE > MaxE or MaxEPos == nil then
			MaxEPos = minion
			MaxE = hitE
		end
	end

	if MaxEPos then
		return MaxEPos
	else
		return nil
	end
end
-- / GetBestEPositionFarm Function / --

-- / FarmE Function / --
function FarmE()
	if SkillE.ready and #EnemyMinions.objects > 0 then
		local EPos = GetBestEPositionFarm()
		if EPos then
			CastSpell(_E, EPos.x, EPos.z)
		end
	end
end
-- / FarmE Function / --

-- / FarmW Function / --
function FarmW()
	if SkillW.ready and #EnemyMinions.objects > 2 then
		CastSpell(_W)
	end
end
-- / FarmW Function / --

-- / CheckDashes Function / --
function CheckDashes()
	local Enemies = GetEnemyHeroes()
	for idx, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) and GetDistance(enemy) < SkillE.range and Config.Extras.EGapClosers then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SkillE.delay, SkillE.width, SkillE.speed, myHero)
			if IsDashing and CanHit and GetDistance(Position) < SkillE.range and SkillE.ready then
				CastSpell(_E, Position.x, Position.z)
			end
		end
	end
end
-- / CheckDashes Function / --

-- / isLowMana Function / --
function isLowMana(name)
	if name == 'Combo' or 'combo' then
		if myHero.mana < (myHero.maxMana * ( Config.ComboSub.mManager / 100)) then
			return true
		else
			return false
		end
	elseif name == 'Harass' or 'harass' then
		if myHero.mana < (myHero.maxMana * ( Config.HarassSub.mManager / 100)) then
			return true
		else
			return false
		end
	end
end
-- / isLowMana Function / --

-- / CountVectorsBetween Function / --
function CountVectorsBetween(V1, V2, Vectors)
	local result = 0	 
	for i, test in ipairs(Vectors) do
		local NVector = V1:crossP(test)
		local NVector2 = test:crossP(V2)
		if NVector.y >= 0 and NVector2.y >= 0 then
			result = result + 1
		end
	end
	return result
end
-- / CountVectorsBetween Function / --

-- / MidPointBetween Function / --
function MidPointBetween(V1, V2) 
	return Vector((V1.x + V2.x)/2, 0, (V1.z + V2.z)/2)
end
-- / MidPointBetween Function / --

-- / GetBestCone Function / --
function GetBestCone(Radius, Angle)
	local Targets = {}
	local PosibleCastPoints = {}

	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			local Position = VP:GetPredictedPos(enemy, SkillR.delay)
			if Position and (GetDistance(myHero.visionPos, Position) <= Radius) and (GetDistance(myHero.visionPos, enemy) <= Radius) then
				table.insert(Targets, Vector(Position.x - myHero.x, 0, Position.z - myHero.z))
			end
		end
	end
	
	local Best = 0
	local BestCastPos = nil

	if #Targets == 1 then
		Best = 1
		BestCastPos = Radius*Vector(Targets[1].x,0,Targets[1].z):normalized()
	elseif #Targets > 1  then
		for i, edge in ipairs(Targets) do
			local Edge1 = Radius*Vector(edge.x,0,edge.z):normalized()
			local Edge2 = Edge1:rotated(0, Angle, 0)
			local Edge3 = Edge1:rotated(0, -Angle, 0)
			
			Count1 = CountVectorsBetween(Edge1, Edge2, Targets)
			Count2 = CountVectorsBetween(Edge3, Edge1, Targets)
			
			if Count1 >= Best then
				Best = Count1
				BestCastPos = MidPointBetween(Edge1, Edge2)
			end
			if Count2 >= Best then
				Best = Count2
				BestCastPos = MidPointBetween(Edge3, Edge1)
			end
		end
	end
	

	if BestCastPos then
		BestCastPos = Vector(myHero.x + BestCastPos.x, 0, myHero.z+BestCastPos.z)
	end
	return Best, BestCastPos
end	
-- / GetBestCone Function / --

-- / CountEnemiesInCone Function / --
function CountEnemiesInCone(CastPoint, Radius, Angle)
	local Direction = Radius * (-Vector(myHero.x, 0, myHero.z) + Vector(CastPoint.x,0,CastPoint.z)):normalized()
	local Vector1 = Direction:rotated(0, Angle/2, 0) 
	local Vector2 = Direction:rotated(0, -Angle/2, 0)
	local Targets = {}

	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			local Position = VP:GetPredictedPos(enemy, Rdelay/1000)
			if Position and (GetDistance(myHero.visionPos, Position) <= Radius) and GetDistance(myHero.visionPos, enemy) <= Radius then
				table.insert(Targets, Vector(Position.x - myHero.x, 0, Position.z - myHero.z))
			end
		end
	end
	return CountVectorsBetween(Vector2, Vector1, Targets)
end
-- / CountEnemiesInCone Function / --

-- / GetQVectorAngle Function / --
function GetQVectorAngle(Target, bTarget)
	local VectorToEnemy = Vector(Target) - Vector(myHero)
	local VectorToTarget = Vector(bTarget) - Vector(Target)
	
	return (VectorToTarget:angle(VectorToEnemy) / 57)
end
-- / GetQVectorAngle Function / --

-- / GetClosestBetween Function / --
function GetClosestBetween(point, target1, target2)
	if GetDistance(point, target1) > GetDistance(point, target2) then return target2 end
	else return target1 end
end
-- / GetClosestBetween Function / --
