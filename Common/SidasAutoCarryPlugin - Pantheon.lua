--[[
 
        Auto Carry Plugin - Pantheon Edition
		Author: Roach_
		Version: 2.0d
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
			Version: 2.0d
				Fixed Auto-Pots Problem
				Hopefully fixed AutoE Bug
				
			Version: 2.0c
				Improved combo function
				Fixed Harass Function
				Rewrote Low Checks Functions
				Added a new Check for Mana Potions
					- One for Harass/Farm
					- One for Potions
				Deleted Wooglets Support as an Usable Item
				
			Version: 2.0b
				Fixed Auto Potions
				Changed Min Mana Display in Menu
				Removed Auto Spell Leveler from Menu as it's not done yet
			
			Version: 2.0a
				Added a Toggle for for Core Combo
				Added an Extra Menu
				Added Customizable Chase Combo
				Added Farm with Q
				Added Lane Clear with E
				Added Auto Pots/Items
				Added Minimum Mana to Harass/Farm - Check
				Modified Menu - More customizable
				Modified KS only with Q
				Modified Harass - Working with Mixed Mode
				Optimised Chase Combo
				Rewrited some Functions
				-- Fully Optimised the Script
				
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

local SkillQ = {spellKey = _Q, range = qwRange, speed = 2, delay = 0, width = 200, configName = "spearShot", displayName = "Q (Spear Shot)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = true }
local SkillW = {spellKey = _W, range = qwRange, speed = 2, delay = 0, width = 200, configName = "AoZ", displayName = "W (Aegis of Zeonia)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = true }
local SkillE = {spellKey = _E, range = eRange, speed = 2, delay = 0, width = 200, configName = "heartseekerStrike", displayName = "E (Heartseeker Strike)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true }

local QReady, WReady, EReady, RReady, FlashReady = false, false, false, false, false

-- Regeneration
local UsingHPot, UsingMPot, UsingFlask, Recall = false, false, false, false

-- Our lovely script
function PluginOnLoadMenu()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Menu:addParam("pPlugin", "[Cast Options]", SCRIPT_PARAM_INFO, "")
	Menu:addParam("pCombo", "[Combo Options]", SCRIPT_PARAM_INFO, "")
	Menu:addParam("pAutoQ", "Auto Cast Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("pAutoW", "Auto Cast W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("pAutoE", "Auto Cast E", SCRIPT_PARAM_ONOFF, true)
	Menu:permaShow("pPlugin")
	
	Menu:addParam("pGap", "", SCRIPT_PARAM_INFO, "")
	
	Menu:addParam("pChase", "[Chase Combo Options]", SCRIPT_PARAM_INFO, "")
	Menu:addParam("pChaseCombo", "Use Chase Combo", SCRIPT_PARAM_ONKEYDOWN, false, pChaseComboHotkey)
	Menu:addParam("pAutoCW", "Auto Cast W - Chase", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("pAutoCE", "Auto Cast E - Chase", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("pAutoCQ", "Auto Cast Q - Chase", SCRIPT_PARAM_ONOFF, true)
	Menu:permaShow("pChase")
	Menu:permaShow("pChaseCombo")
	
	Menu:addParam("pGap", "", SCRIPT_PARAM_INFO, "")
	
	Menu:addParam("pKS", "[Kill Steal Options]", SCRIPT_PARAM_INFO, "")
	Menu:addParam("pKillsteal", "Auto Kill Steal with Q", SCRIPT_PARAM_ONOFF, true)
	Menu:permaShow("pKS")
	Menu:permaShow("pKillsteal")
	
	Menu:addParam("pGap", "", SCRIPT_PARAM_INFO, "")
	
	Menu:addParam("pMisc", "[Misc Options]", SCRIPT_PARAM_INFO, "")
	-- Menu:addParam("pAutoLVL", "Auto Level Spells", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("pMinMana", "Minimum Mana to Farm/Harass", SCRIPT_PARAM_SLICE, 40, 0, 100, -1)
	Menu:addParam("pEscape", "Escape Artist", SCRIPT_PARAM_ONKEYDOWN, false, pEscapeHotkey)
	Menu:addParam("pEscapeFlash", "Escape: Flash to Mouse", SCRIPT_PARAM_ONOFF, false)
	Menu:permaShow("pMisc")
	Menu:permaShow("pEscape")
	
	Menu:addParam("pGap", "", SCRIPT_PARAM_INFO, "")
	
	Menu:addParam("pH", "[Harass Options]", SCRIPT_PARAM_INFO, "")
	Menu:addParam("pHarass", "Auto Harass with Q", SCRIPT_PARAM_ONOFF, true)
	
	Menu:addParam("pGap", "", SCRIPT_PARAM_INFO, "")
	
	Menu:addParam("pFarm", "[Farm Options]", SCRIPT_PARAM_INFO, "")
	Menu:addParam("pFarmQ", "Auto Farm with Q", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("pFarmE", "Auto Clear Lane with E", SCRIPT_PARAM_ONOFF, false)
	
	Extras = scriptConfig("Sida's Auto Carry: "..myHero.charName.." Extras", myHero.charName)
	Extras:addParam("pDraw", "[Draw Options]", SCRIPT_PARAM_INFO, "")
	Extras:addParam("pDCR", "Draw Combo Range", SCRIPT_PARAM_ONOFF, true)
	Extras:addParam("pDCT", "Draw Crit Text", SCRIPT_PARAM_ONOFF, true)
	
	Extras:addParam("pGap", "", SCRIPT_PARAM_INFO, "")
	
	Extras:addParam("pHPMana", "[Auto Pots/Items Options]", SCRIPT_PARAM_INFO, "")
	Extras:addParam("pHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
	Extras:addParam("pMP", "Auto Auto Mana Pots", SCRIPT_PARAM_ONOFF, true)
	Extras:addParam("pHPHealth", "Minimum Health for Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
	Extras:addParam("pMana", "Minimum Mana for Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
end

function PluginOnLoad() 
	-- Params/PluginMenu
	PluginOnLoadMenu()
	
	-- Range
	AutoCarry.SkillsCrosshair.range = qwRange
	
	lastAnimation = nil
end 


function PluginOnTick()
	if Recall then return end

	-- Get Attack Target
	Target = AutoCarry.GetAttackTarget()

	-- Check Spells
	pChecks()

	-- Check if myHero is using _E
	if isChanneling("Spell3") then
		AutoCarry.CanAttack = false
		AutoCarry.CanMove = false
	else
		AutoCarry.CanAttack = true
		AutoCarry.CanMove = true
	end

	-- Combo, Harass, Killsteal, Escape Combo, Farm - Checks
	pCombo()
	pChaseCombo()
	pHarass()
	pKillsteal()
	pEscapeCombo()
	pFarm()
	
	-- Draw Critical Text
	pDrawCritText()
	
	-- Auto Regeneration
	if Extras.pHP and IsLow('Health') and not (UsingHPot or UsingFlask) and (HPReady or FSKReady) then CastSpell((hpSlot or fskSlot)) end
	if Extras.pMP and IsLow('Mana') and not (UsingMPot or UsingFlask) and(MPReady or FSKReady) then CastSpell((mpSlot or fskSlot)) end
end

function PluginOnDraw()
	-- Draw Panth's Range = 600
	if not myHero.dead and Extras.pDCR then
		DrawCircle(myHero.x, myHero.y, myHero.z, qwRange, 0x00FF00)
	end
end

-- Animation Detection
function PluginOnAnimation(unit, animationName)
	-- Set lastAnimation = Last Animation used
	if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end

-- Object Detection
function PluginOnCreateObj(obj)
	if obj.name:find("TeleportHome.troy") then
		if GetDistance(obj, myHero) <= 70 then
			Recall = true
		end
	end
	if obj.name:find("Regenerationpotion_itm.troy") then
		if GetDistance(obj, myHero) <= 70 then
			UsingHPot = true
		end
	end
	if obj.name:find("Global_Item_HealthPotion.troy") then
		if GetDistance(obj, myHero) <= 70 then
			UsingHPot = true
			UsingFlask = true
		end
	end
	if obj.name:find("Global_Item_ManaPotion.troy") then
		if GetDistance(obj, myHero) <= 70 then
			UsingFlask = true
			UsingMPot = true
		end
	end
end

function PluginOnDeleteObj(obj)
	if obj.name:find("TeleportHome.troy") then
		Recall = false
	end
	if obj.name:find("Regenerationpotion_itm.troy") then
		UsingHPot = false
	end
	if obj.name:find("Global_Item_HealthPotion.troy") then
		UsingHPot = false
		UsingFlask = false
	end
	if obj.name:find("Global_Item_ManaPotion.troy") then
		UsingMPot = false
		UsingFlask = false
	end
end

-- Custom Functions
function pCombo()
	if Menu.pCombo and Menu2.AutoCarry then
		if ValidTarget(Target) then
			if QReady and Menu.pAutoQ and GetDistance(Target) < qwRange then 
				CastSpell(SkillQ.spellKey, Target)
			end
			
			if WReady and Menu.pAutoW and GetDistance(Target) < qwRange then
				CastSpell(SkillW.spellKey, Target)
			end
			
			if EReady and Menu.pAutoE and GetDistance(Target) < eRange then
				if not Target.canMove or GetDistance(Target) < 175 then
					AutoCarry.CastSkillshot(SkillE, Target)
				end
			end
		end
	end
end

function pHarass()
	if Menu.pHarass and Menu2.MixedMode then
		if ValidTarget(Target) then
			if QReady and GetDistance(Target) < qwRange and not IsLow('Mana Harass') then 
				CastSpell(SkillQ.spellKey, Target)
				myHero:Attack(Target)
			end
		end
	end
end

function pFarm()
	if Menu.pFarmQ and (Menu2.LastHit) and not IsLow('Mana Farm') then
		for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
			if ValidTarget(minion) and QReady and GetDistance(minion) <= qwRange then
				if minion.health < getDmg("Q", minion, myHero) then
					CastSpell(_Q, minion)
				end
			end
		end
	end
	if Menu.pFarmE and (Menu2.LaneClear) and not IsLow('Mana Farm') then
		for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
			if ValidTarget(minion) and EReady and GetDistance(minion) <= eRange then
				if minion.health < getDmg("E", minion, myHero) then
					CastSpell(_E, minion)
				end
			end
		end
	end
end

function pChaseCombo()
	if Menu.pChaseCombo then
		if ValidTarget(Target) then
			if WReady and Menu.pAutoCW  and GetDistance(Target) < qwRange then
				CastSpell(SkillW.spellKey, Target)
			end
			
			if EReady and Menu.pAutoCE and GetDistance(Target) < eRange then
				AutoCarry.CastSkillshot(SkillE, Target)
			end
			
			if QReady and Menu.pAutoCQ and GetDistance(Target) < qwRange and isChanneling("Spell3") then 
				CastSpell(SkillQ.spellKey, Target)
			end
		end
		if not isChanneling("Spell3") then
			myHero:MoveTo(mousePos.x, mousePos.z)
		end
		
	end
end

function pKillsteal()
	if Menu.pKillsteal then
		for _, enemy in pairs(AutoCarry.EnemyTable) do
			if QReady then
				if ValidTarget(enemy) and GetDistance(enemy) < qwRange and enemy.health < getDmg("Q", enemy, myHero) then
					CastSpell(SkillQ.spellKey, enemy)
				end
			end
		end
	end
end

function pEscapeCombo()	
	if Menu.pEscape then
		if WReady and GetDistance(Target) < qwRange then
			CastSpell(SkillW.spellKey, Target)
			if Menu.pEscapeFlash and FlashReady and GetDistance(mousePos) > 300 and isChanneling("Spell2") then
				CastSpell(FlashSlot, mousePos.x, mousePos.z)
			end
		end
		
		if Menu.pEscapeFlash then
			myHero:MoveTo(mousePos.x, mousePos.z)
		end
	end
end

function isChanneling(animationName)
	if lastAnimation == animationName then
		return true
	else
		return false
	end
end

function pChecks()
	hpSlot, mpSlot, fskSlot = GetInventorySlotItem(2003),GetInventorySlotItem(2004),GetInventorySlotItem(2041)

	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then
		FlashSlot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then
		FlashSlot = SUMMONER_2
	end

	QReady = (myHero:CanUseSpell(SkillQ.spellKey) == READY)
	WReady = (myHero:CanUseSpell(SkillW.spellKey) == READY)
	EReady = (myHero:CanUseSpell(SkillE.spellKey) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	WGTReady = (wgtSlot ~= nil and myHero:CanUseSpell(wgtSlot) == READY)
	HPReady = (hpSlot ~= nil and myHero:CanUseSpell(hpSlot) == READY)
	MPReady = (mpSlot ~= nil and myHero:CanUseSpell(mpSlot) == READY)
	FSKReady = (fskSlot ~= nil and myHero:CanUseSpell(fskSlot) == READY)

	FlashReady = (FlashSlot ~= nil and myHero:CanUseSpell(FlashSlot) == READY)
end

function pDrawCritText()
	if not myHero.dead and Extras.pDCT then
		for _, enemy in pairs(AutoCarry.EnemyTable) do
			if ValidTarget(enemy) then
				if enemy.health <= enemy.maxHealth*0.15 then
					PrintFloatText(enemy, 10, "Critical Hit!")
				end
			end
		end
	end
end

function IsLow(Name)
	if Name == 'Mana' then
		if (myHero.mana / myHero.maxMana) <= (Extras.pMana / 100) then
			return true
		else
			return false
		end
	end
	if Name == 'Mana Harass' or Name == 'Mana Farm' then
		if (myHero.mana / myHero.maxMana) <= (Menu.pMinMana / 100) then
			return true
		else
			return false
		end
	end
	if Name == 'Health' then
		if (myHero.health / myHero.maxHealth) <= (Extras.pHPHealth / 100) then
			return true
		else
			return false
		end
	end
end

--UPDATEURL=https://raw.github.com/RoachxD/BoL_Scripts/master/Common/SidasAutoCarryPlugin%20-%20Pantheon.lua
--HASH=D2A4E405F4D438CE222C0762EFC64C5E
