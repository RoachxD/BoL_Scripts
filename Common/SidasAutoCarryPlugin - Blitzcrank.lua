--[[
 
        Auto Carry Plugin - Blitzcrank Edition
		Author: Roach_
		Version: 1.0b
		Copyright 2013

		Dependency: Sida's Auto Carry: Revamped
 
		How to install:
			Make sure you already have AutoCarry installed.
			Name the script EXACTLY "SidasAutoCarryPlugin - Blitzcrank.lua" without the quotes.
			Place the plugin in BoL/Scripts/Common folder.

		Features:
			Combo with Autocarry
			Fully supports Q with movement/attack disable
			Killsteal with R
			Stop enemy ultimates with R
			Draw Q and R Range
			Escape Artist(with Flash)

		History:
			Version: 1.0b
				Fixed Errors
				Fixed Prediction
				No more grabing minions
		
			Version: 1.0a
				First release
--]]
if myHero.charName ~= "Blitzcrank" then return end

local Target
local bEscapeHotkey = string.byte("T")

-- Prediction
local aRange, qRange, rRange = 125, 1050, 600

local FlashSlot = nil

local bPred = nil

local SkillQ = {spellKey = _Q, range = qRange, speed = 1.8, delay = 0, width = 120, configName = "rocketGrab", displayName = "Q (Rocket Grab)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true }
local SkillW = {spellKey = _W, range = 0, speed = 2, delay = 0, width = 75, configName = "overdrive", displayName = "W (Overdrive)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = false }
local SkillE = {spellKey = _E, range = eRange, speed = 2, delay = 0, width = 25, configName = "powerFist", displayName = "E (Power Fist)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = true }

local QReady, WReady, EReady, RReady, FlashReady = false, false, false, false, false

function PluginOnLoad() 
	-- Params
	AutoCarry.PluginMenu:addParam("bCombo", "Use Combo With Auto Carry", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("bWC", "Use W in Combo", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("bUltSilence", "Silence Enemy Ultimates", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("bKillsteal", "Killsteal with Ultimate", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("bDQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("bDRR", "Draw Ultimate Range", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("bEscape", "Escape Artist", SCRIPT_PARAM_ONKEYDOWN, false, bEscapeHotkey)
	AutoCarry.PluginMenu:addParam("bEscapeFlash", "Escape: Flash to Mouse", SCRIPT_PARAM_ONOFF, false)
	
	-- Range
	AutoCarry.SkillsCrosshair.range = qRange
	
	lastAnimation = nil
end 


function PluginOnTick()
	-- Get Attack Target
	Target = AutoCarry.GetAttackTarget()

	-- Check Spells
	bSpellCheck()

	-- Check if myHero is using _Q
	if isChanneling("Spell1") then
		AutoCarry.CanAttack = false
		AutoCarry.CanMove = false
	else
		AutoCarry.CanAttack = true
		AutoCarry.CanMove = true
	end

	-- Combo, Ultimate Silence, Killsteal, Escape Combo - Checks
	if AutoCarry.PluginMenu.bCombo and AutoCarry.MainMenu.AutoCarry then bCombo() end
	if AutoCarry.PluginMenu.bUltSilence then bUltCombo() end
	if AutoCarry.PluginMenu.bKillsteal then bKillsteal() end
	if AutoCarry.PluginMenu.bEscape then bEscapeCombo() end
end

function PluginOnDraw()
	-- Draw Blitzcrank's Ranges = 1050, 600
	if not myHero.dead and AutoCarry.PluginMenu.bDQR then
		DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FF00)
	end
	if not myHero.dead and AutoCarry.PluginMenu.bDRR then
		DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0xFF0000)
	end
end

function PluginOnAnimation(unit, animationName)
	-- Set lastAnimation = Last Animation used
	if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
	
	if AutoCarry.PluginMenu.bUltSilence and ValidTarget(unit) and unit.team == TEAM_ENEMY and RReady and GetDistance(unit) <= (rRange-10) then
		if spell.name == "KatarinaR"				or	spell.name == "GalioIdolOfDurand"			or	spell.name == "Crowstorm"			or	spell.name == "DrainChannel" 
		or spell.name == "AbsoluteZero"				or	spell.name == "ShenStandUnited"				or	spell.name == "UrgotSwap2"			or	spell.name =="AlZaharNetherGrasp" 
		or spell.name == "FallenOne"				or	spell.name == "Pantheon_GrandSkyfall_Jump"	or	spell.name == "CaitlynAceintheHole" or	spell.name == "MissFortuneBulletTime"
		or spell.name == "InfiniteDuress"			or	spell.name == "Teleport"					or	spell.name == "Meditate" then 
			CastSpell(_R, unit)
		end
	end
end

-- Custom Functions
function bCombo()
	if ValidTarget(Target) then
		if QReady and GetDistance(Target) < (qRange-25) then
			bSkillshot(SkillQ, Target)
		end
		
		if WReady and AutoCarry.PluginMenu.bWC then
			CastSpell(SkillW.spellKey)
		end
		
		if EReady then
			CastSpell(SkillE.spellKey)
		end
	end
end

function bKillsteal()
	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if ValidTarget(enemy) and GetDistance(enemy) < rRange and enemy.health < (getDmg("R", enemy, myHero)) then
			CastSpell(_R) 
		end
	end
end

function bEscapeCombo()	
	if QReady and GetDistance(Target) < (qRange-25) then
		bSkillshot(SkillQ, Target)
		CastSpell(SkillE.spellKey)
		if AutoCarry.PluginMenu.bEscapeFlash and FlashReady and GetDistance(mousePos) > 300 and isChanneling("Attack") then
			CastSpell(FlashSlot, mousePos.x, mousePos.z)
		end
	end
	
	if AutoCarry.PluginMenu.bEscapeFlash then
		CastSpell(SkillW.spellKey)
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
end

function isChanneling(animationName)
	if lastAnimation == animationName then
		return true
	else
		return false
	end
end

function bSpellCheck()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then
		FlashSlot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then
		FlashSlot = SUMMONER_2
	end

	QReady = (myHero:CanUseSpell(SkillQ.spellKey) == READY)
	WReady = (myHero:CanUseSpell(SkillW.spellKey) == READY)
	EReady = (myHero:CanUseSpell(SkillE.spellKey) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)

	FlashReady = (FlashSlot ~= nil and myHero:CanUseSpell(FlashSlot) == READY)
end

function bSkillshot(spell, target) 
    if not AutoCarry.GetCollision(spell, myHero, target) then
        AutoCarry.CastSkillshot(spell, target)
    end
end

--UPDATEURL=
--HASH=70B1EBC9449E4FA774112516F4BD2DB3
