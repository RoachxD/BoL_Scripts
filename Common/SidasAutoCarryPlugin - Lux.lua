--[[
 
        Auto Carry Plugin - Lux Edition
		Author: Roach_
		Version: 1.0a
		Copyright 2013

		Dependency: Sida's Auto Carry: Revamped
 
		How to install:
			Make sure you already have AutoCarry installed.
			Name the script EXACTLY "SidasAutoCarryPlugin - Lux.lua" without the quotes.
			Place the plugin in BoL/Scripts/Common folder.

		Features:
			Combo with Autocarry
			Fully supports E with Auto-ePop
			Harass with Mixed Mode
			Killsteal with Ultimate
			Draw Combo Range
			Draw Killable Targets (by Ultimate)
			Escape Artist(with Flash)

		History:
			Version: 1.0a
				First release
--]]
 
if myHero.charName ~= "Lux" then return end

local Target
local ePop

-- Prediction
local qRange, eRange, rRange = 1175, 1100, 3000

local FlashSlot = nil

local SkillQ = {spellKey = _Q, range = qRange, speed = 1.2, delay = 200, width = 100, configName = "lightBinding", displayName = "Q (Light Binding)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true}
local SkillE = {spellKey = _E, range = eRange, speed = 1.3, delay = 200, width = 0, configName = "lucentSingularity", displayName = "E (Lucent Singularity)", minion = false}
local SkillR = {spellKey = _R, range = rRange, speed = 12, delay = 1000, width = 190, configName = "finalSpark", displayName = "R (Final Spark)", minion = false}

local QReady, WReady, EReady, RReady, FlashReady = false, false, false, false, false

function PluginOnLoad()
	-- Params/PluginMenu
	AutoCarry.PluginMenu:addParam("lPlugin", "[Lux Plugin Options]", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("lCombo", "Use Combo With Auto Carry", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("lHarass", "Harass with Mixed Mode", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("lComboOption", "[Combo Options]", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("lQ", "Use Light Binding with Combo", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("lE", "Use Lucent Singularity with Combo", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("lR", "Use Final Spark with Combo", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("lUltOption", "[Ultimate Options]", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("lUltAim", "Activate Auto-Aim with R", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("lUlt", "Snipe the Target with your Ultimate", SCRIPT_PARAM_ONKEYDOWN, false, 82) -- R
	AutoCarry.PluginMenu:addParam("lDrawOption", "[Draw Options]", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("lDQ", "Draw Q", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("lDE", "Draw E", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("lDR", "Draw R", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("lDKR", "Draw Text when Target is Killable by Ultimate", SCRIPT_PARAM_ONOFF, true)
	
	-- Range
	AutoCarry.SkillsCrosshair.range = qRange
end


function PluginOnTick()
	-- Get Attack Target
	Target = AutoCarry.GetAttackTarget()
	
	-- Check Spells
	lSpellCheck()

	-- Combo, Harass, Ultimate, Escape Combo - Checks
	if AutoCarry.PluginMenu.lCombo and AutoCarry.MainMenu.AutoCarry then lCombo() end
	if AutoCarry.PluginMenu.lHarass and AutoCarry.MainMenu.MixedMode then lHarass() end
	if AutoCarry.PluginMenu.lUlt and AutoCarry.PluginMenu.lUltAim then lUlt() end
end

function PluginOnDraw()
	if not myHero.dead then
		if AutoCarry.PluginMenu.lDQ and QReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x0099CC)
		end
		if AutoCarry.PluginMenu.lDE and EReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x0099CC)
		end
		if AutoCarry.PluginMenu.lDR and RReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0xFF0000)
		end
		
		if AutoCarry.PluginMenu.lDKR then
			if ValidTarget(Target) then
				RDmg = getDmg("R", Target, myHero)
			end

			if ValidTarget(Target) and Target.type == "obj_AI_Hero" and RReady and GetDistance(Target) < rRange and GetDistance(Target) > 300 and Target.health < RDmg then
				DrawCircle(Target.x, Target.y, Target.z, 150, 0xFF0000)
				DrawText("Use R to ult!", 50, 520, 100, 0xFFFF0000)
				PrintFloatText(Target, 0, "Ult!")
			end
		end
	end
end

function PluginOnCreateObj(obj)
	if obj ~= nil and obj.valid then
		if obj.name:lower():find("luxlightstrike") then -- and isObjectOnEnemy(obj) then
			ePop = obj
		end
	end
end

function PluginOnDeleteObj(obj)
	if obj == ePop then
		ePop = nil
	end
end

-- Custom Functions
function lCombo()
	if ValidTarget(Target) then
		if AutoCarry.PluginMenu.lQ and QReady and GetDistance(Target) < qRange then
			if not AutoCarry.GetCollision(SkillQ, myHero, Target) then
				AutoCarry.CastSkillshot(SkillQ, Target)
			end
		end
		if AutoCarry.PluginMenu.lE and EReady and GetDistance(Target) < eRange then
			AutoCarry.CastSkillshot(SkillE, Target)
		end
		lPop()

		if AutoCarry.PluginMenu.lR and RReady and GetDistance(Target) < rRange then
			AutoCarry.CastSkillshot(SkillR, Target)
		end
	end
end

function lHarass()
	if ValidTarget(Target) then 
		if EReady and GetDistance(Target) < eRange then
			AutoCarry.CastSkillshot(SkillE, Target)
		end
		
		lPop()
	end
end

function rUlt()
	if RReady and GetDistance(Target) <= rRange then
		if not AutoCarry.GetCollision(SkillR, myHero, Target) then
			AutoCarry.CastSkillshot(SkillR, Target)
		end
	end
end

function lPop()
	if ePop ~= nil and ePop.valid then
		if GetDistance(Target, ePop) < 300 then
			CastSpell(_E)
		end
	end
end

function lSpellCheck()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then
		FlashSlot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then
		FlashSlot = SUMMONER_2
	end

	QReady = (myHero:CanUseSpell(SkillQ.spellKey) == READY)
	--WReady = (myHero:CanUseSpell(SkillW.spellKey) == READY)
	EReady = (myHero:CanUseSpell(SkillE.spellKey) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)

	FlashReady = (FlashSlot ~= nil and myHero:CanUseSpell(FlashSlot) == READY)
end
