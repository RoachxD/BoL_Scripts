--[[
 
        Auto Carry Plugin - Pantheon Edition
		Author: Roach_
		Version: 1.1c
		Copyright 2013

		Dependency: Sida's Auto Carry: Revamped
 
		How to install:
			Make sure you already have AutoCarry installed.
			Name the script EXACTLY "SidasAutoCarryPlugin - Pantheon.lua" without the quotes.
			Place the plugin in BoL/Scripts/Common folder.

		Features:
			Combo with Autocarry
			Fully supports E with movement/attack disable
			Harass with Mixed Mode
			Killsteal with Q/W or W+Q
			Draw Combo Range
			Draw Critical Hit on Target
			Escape Artist(with Flash)

		History:
			Version: 1.1c
				Added Chase Combo
				Fixed a bug where E was not casting
				Changed Plugin Menu
				Added a Mini-Menu
				Fixed "Draw Crit Text"
		
			Version: 1.1b
				Auto combo after Ultimate. (With a check!)
				Toggle for Auto Q Harass when in enemy range , with a mana check. (You will harass them until you'll have Mana for one last Combo)
		
			Version: 1.1a
				Optimised Escape Artist
				Optimised Killsteal(You can KS with Q+W)
				Fixed Ultimate Bugsplat(TESTED)
				Fixed Mixed Mode Harass
				Re-wrote majority of the Functions
				Hopefully fixed DCT(Draw Critical Text)
				Changed Circle's Color(Range Circle)
				Speeded-Up the Script(Some FPS Drops on Escape Artist and Ultimate)
				
			Version: 1.0d
				Fixed Escape Artist
				Fixed a problem with Flash, it was flashing before Stunning the enemy
				Optimised Escape Artist
				Fully removed Auto-Ignite
				Fixed all the Bugsplats (TESTED)
				Hopefully fixed Mixed Mode Harass
				
			Version: 1.0c
				Real fix for E.
				Fixed Killsteal.
				Hopefully fixed OnTick bugsplat.
				Removed Auto-Ignite, because it exists in SAC too.
			
			Version: 1.0b
				Temporarily fix for E.
				Fixed some bugsplats on draw.
			
			Version: 1.0a
				First release
--]]
if myHero.charName ~= "Pantheon" then return end

local Target
local pEscapeHotkey = string.byte("T")
local pChaseComboHotkey = string.byte("N")

-- Prediction
local qwRange, eRange = 600, 300

local FlashSlot = nil

local SkillQ = {spellKey = _Q, range = cRange, speed = 2, delay = 0, width = 200, configName = "spearShot", displayName = "Q (Spear Shot)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = true }
local SkillW = {spellKey = _W, range = cRange, speed = 2, delay = 0, width = 200, configName = "AoZ", displayName = "W (Aegis of Zeonia)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = true }
local SkillE = {spellKey = _E, range = eRange, speed = 2, delay = 0, width = 200, configName = "heartseekerStrike", displayName = "E (Heartseeker Strike)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true }

local QReady, WReady, EReady, RReady, FlashReady = false, false, false, false, false

function PluginOnLoad() 
	-- Params/PluginMenu
	AutoCarry.PluginMenu:addParam("pPlugin", "[Pantheon Plugin Options]", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("pCombo", "Use Combo With Auto Carry", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("pChaseCombo", "Use Chase Combo", SCRIPT_PARAM_ONKEYDOWN, false, pChaseComboHotkey)
	AutoCarry.PluginMenu:addParam("pHarass", "Harass with Mixed Mode", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("pUltCombo", "Auto-Combo After Ultimate", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("pKillsteal", "Killsteal with Q/W/W+Q", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("pDCR", "Draw Combo Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("pDCT", "Draw Crit Text", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("pEscape", "Escape Artist", SCRIPT_PARAM_ONKEYDOWN, false, pEscapeHotkey)
	AutoCarry.PluginMenu:addParam("pEscapeFlash", "Escape: Flash to Mouse", SCRIPT_PARAM_ONOFF, false)
	
	-- Params/Mini-Menu
	AutoCarry.PluginMenu:permaShow("pCombo")
	AutoCarry.PluginMenu:permaShow("pHarass")
	AutoCarry.PluginMenu:permaShow("pUltCombo")
	AutoCarry.PluginMenu:permaShow("pKillsteal")
	AutoCarry.PluginMenu:permaShow("pEscape")
	
	-- Range
	AutoCarry.SkillsCrosshair.range = qwRange
	
	lastAnimation = nil
end 


function PluginOnTick()
	-- Get Attack Target
	Target = AutoCarry.GetAttackTarget()

	-- Check Spells
	pSpellCheck()

	-- Check if myHero is using _E
	if isChanneling("Spell3") then
		AutoCarry.CanAttack = false
		AutoCarry.CanMove = false
	else
		AutoCarry.CanAttack = true
		AutoCarry.CanMove = true
	end

	-- Combo, Harass, Killsteal, Escape Combo - Checks
	if AutoCarry.PluginMenu.pCombo and AutoCarry.MainMenu.AutoCarry then pCombo() end
	if AutoCarry.PluginMenu.pChaseCombo then pChaseCombo() end
	if AutoCarry.PluginMenu.pHarass and AutoCarry.MainMenu.MixedMode then pHarass() end
	if AutoCarry.PluginMenu.pUltCombo then pUltCombo() end
	if AutoCarry.PluginMenu.pKillsteal then pKillsteal() end
	if AutoCarry.PluginMenu.pEscape then pEscapeCombo() end
	
	-- Draw Critical Text
	if not myHero.dead and AutoCarry.PluginMenu.pDCT then pDrawCritText() end
end

function PluginOnDraw()
	-- Draw Panth's Range = 600
	if not myHero.dead and AutoCarry.PluginMenu.pDCR then
		DrawCircle(myHero.x, myHero.y, myHero.z, qwRange, 0x00FF00)
	end
end

function PluginOnAnimation(unit, animationName)
	-- Set lastAnimation = Last Animation used
	if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end

-- Custom Functions
function pCombo()
	if ValidTarget(Target) then
		if QReady and GetDistance(Target) < qwRange then 
			CastSpell(SkillQ.spellKey, Target)
		end
		
		if WReady and GetDistance(Target) < qwRange then
			CastSpell(SkillW.spellKey, Target)
		end
		
		if EReady and GetDistance(Target) < eRange then
			AutoCarry.CastSkillshot(SkillE, Target)
		end
	end
end

function pHarass()
	if ValidTarget(Target) then
		if QReady and GetDistance(Target) < qwRange and (myHero.mana > (45+55+40+(GetSpellData(_E).level*5))) then 
			CastSpell(SkillQ.spellKey, Target)
			myHero:Attack(Target)
		end
	end
end

function pChaseCombo()
	if ValidTarget(Target) then
		if WReady and GetDistance(Target) < qwRange then
			CastSpell(SkillW.spellKey, Target)
		end
		
		if EReady and GetDistance(Target) < eRange and isChanneling("Spell2") then
			AutoCarry.CastSkillshot(SkillE, Target)
		end
		
		if QReady and GetDistance(Target) < qwRange and isChanneling("Spell3") then 
			CastSpell(SkillQ.spellKey, Target)
		end
	end
end

function pUltCombo()
	if isChanneling("Spell4") then pCombo() end
end

function pKillsteal()
	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if QReady and WReady then
			if ValidTarget(enemy) and GetDistance(enemy) < qwRange and enemy.health < (getDmg("Q", enemy, myHero) + getDmg("W", enemy, myHero)) and myHero.mana >= (myHero:GetSpellData(_W).mana + myHero:GetSpellData(_Q).mana) then
				CastSpell(SkillW.spellKey, enemy)
				if isChanneling("Spell2") then CastSpell(SkillQ.spellKey, enemy) end
			end 
		elseif not QReady and WReady then
			if ValidTarget(enemy) and GetDistance(enemy) < qwRange and enemy.health < getDmg("W", enemy, myHero) then
				CastSpell(SkillW.spellKey, enemy)
			end 
		elseif QReady and not WReady then
			if ValidTarget(enemy) and GetDistance(enemy) < qwRange and enemy.health < getDmg("Q", enemy, myHero) then
				CastSpell(SkillQ.spellKey, enemy)
			end 
		end
	end
end

function pEscapeCombo()	
	if WReady and GetDistance(Target) < qwRange then
		CastSpell(SkillW.spellKey, Target)
		if AutoCarry.PluginMenu.pEscapeFlash and FlashReady and GetDistance(mousePos) > 300 and isChanneling("Spell2") then
			CastSpell(FlashSlot, mousePos.x, mousePos.z)
		end
	end
	
	if AutoCarry.PluginMenu.pEscapeFlash then
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

function pSpellCheck()
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

function pDrawCritText()
	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if ValidTarget(enemy) then
			if enemy.health <= enemy.maxHealth*0.15 then
				PrintFloatText(enemy, 10, "CRITICAL HIT!")
			end
		end
	end
end
