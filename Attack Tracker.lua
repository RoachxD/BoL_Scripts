--[[


		 .d8b.  d888888b d888888b  .d8b.   .o88b. db   dD      d888888b d8888b.  .d8b.   .o88b. db   dD d88888b d8888b. 
		d8' `8b `~~88~~' `~~88~~' d8' `8b d8P  Y8 88 ,8P'      `~~88~~' 88  `8D d8' `8b d8P  Y8 88 ,8P' 88'     88  `8D 
		88ooo88    88       88    88ooo88 8P      88,8P           88    88oobY' 88ooo88 8P      88,8P   88ooooo 88oobY' 
		88~~~88    88       88    88~~~88 8b      88`8b           88    88`8b   88~~~88 8b      88`8b   88~~~~~ 88`8b   
		88   88    88       88    88   88 Y8b  d8 88 `88.         88    88 `88. 88   88 Y8b  d8 88 `88. 88.     88 `88. 
		YP   YP    YP       YP    YP   YP  `Y88P' YP   YD         YP    88   YD YP   YP  `Y88P' YP   YD Y88888P 88   YD 


	Attack Tracker - Keep Track of your enemy Auto-Attacks
]]--

function OnLoad()
	attackTracker = {
		attacker = nil,
		target = nil
	}

	AttackTrackerMenu = scriptConfig("Attack Tracker", "AT")
		AttackTrackerMenu:addSubMenu("Enable Markers", "enableMarkers")
			AttackTrackerMenu.enableMarkers:addSubMenu("Ally Team", "allyTeam")
				for i, ally in pairs(GetAllyHeroes()) do
					AttackTrackerMenu.enableMarkers.allyTeam:addParam(ally.charName, "Enable for ".. ally.charName ..": ", SCRIPT_PARAM_ONOFF, true)
				end
			AttackTrackerMenu.enableMarkers:addSubMenu("Enemy Team", "enemyTeam")
				local nopeTeam = false
				for i, enemy in pairs(GetEnemyHeroes()) do
					nopeTeam = true
					AttackTrackerMenu.enableMarkers.enemyTeam:addParam(enemy.charName, "Enable for".. enemy.charName ..": ", SCRIPT_PARAM_ONOFF, true)
				end

				if not nopeTeam then
					AttackTrackerMenu.enableMarkers.enemyTeam:addParam("noEnemy", "No enemy found", SCRIPT_PARAM_INFO, "")
				end
		AttackTrackerMenu:addSubMenu("Marker Colors", "markerColors")
			AttackTrackerMenu.markerColors:addSubMenu("Ally Team Colors", "allyColors")
				for i, ally in pairs(GetAllyHeroes()) do
					AttackTrackerMenu.markerColors.allyColors:addParam(ally.charName, ally.charName.." Color: ", SCRIPT_PARAM_COLOR, {255, math.random(1, 255), math.random(1, 255), math.random(1, 255)})
				end
			AttackTrackerMenu.markerColors:addSubMenu("Enemy Team Colors", "enemyColors")
				local nopeColor = false
				for i, enemy in pairs(GetEnemyHeroes()) do
					nopeColor = true
					AttackTrackerMenu.markerColors.enemyColors:addParam(enemy.charName, enemy.charName.." Color: ", SCRIPT_PARAM_COLOR, {255, math.random(1, 255), math.random(1, 255), math.random(1, 255)})
				end

				if not nopeColor then
					AttackTrackerMenu.markerColors.enemyColors:addParam("noEnemy", "No enemy found", SCRIPT_PARAM_INFO, "")
				end
end

function OnProcessSpell(unit, spell)
	if unit.type == myHero.type and unit ~= nil then
		if (unit.team == myHero.team and not AttackTrackerMenu.enableMarkers.allyTeam[unit.charName]) and not AttackTrackerMenu.enableMarkers.enemyTeam[unit.charName] then return end

		if spell.name:lower():find("attack") then
			attackTracker.attacker = unit
			attackTracker.target = spell.target
		end
	end
end

function OnDraw()
	if attackTracker.attacker ~= nil and attackTracker.target ~= nil then
		if GetDistanceSqr(attackTracker.attacker, attackTracker.target) > (attackTracker.attacker.range + attackTracker.attacker:GetDistance(attackTracker.attacker.minBBox)) * (attackTracker.attacker.range + attackTracker.attacker:GetDistance(attackTracker.attacker.minBBox)) then return end

		if not attackTracker.target.dead then
			DrawCircle3D(attackTracker.target.x, attackTracker.target.y, attackTracker.target.z, 50, 1, (attackTracker.attacker.team == myHero.team and ARGB(AttackTrackerMenu.markerColors.allyColors[attackTracker.attacker.charName][1], AttackTrackerMenu.markerColors.allyColors[attackTracker.attacker.charName][2], AttackTrackerMenu.markerColors.allyColors[attackTracker.attacker.charName][3], AttackTrackerMenu.markerColors.allyColors[attackTracker.attacker.charName][4])) or ARGB(AttackTrackerMenu.markerColors.enemyColors[attackTracker.attacker.charName][1], AttackTrackerMenu.markerColors.enemyColors[attackTracker.attacker.charName][2], AttackTrackerMenu.markerColors.enemyColors[attackTracker.attacker.charName][3], AttackTrackerMenu.markerColors.enemyColors[attackTracker.attacker.charName][4]))
			
			local barPos = WorldToScreen(D3DXVECTOR3(attackTracker.target.x, attackTracker.target.y, attackTracker.target.z))
			local pos = { x = barPos.x - 16, y = barPos.y + 21 }

			DrawText(attackTracker.attacker.charName, 16, pos.x, pos.y, (attackTracker.attacker.team == myHero.team and ARGB(AttackTrackerMenu.markerColors.allyColors[attackTracker.attacker.charName][1], AttackTrackerMenu.markerColors.allyColors[attackTracker.attacker.charName][2], AttackTrackerMenu.markerColors.allyColors[attackTracker.attacker.charName][3], AttackTrackerMenu.markerColors.allyColors[attackTracker.attacker.charName][4])) or ARGB(AttackTrackerMenu.markerColors.enemyColors[attackTracker.attacker.charName][1], AttackTrackerMenu.markerColors.enemyColors[attackTracker.attacker.charName][2], AttackTrackerMenu.markerColors.enemyColors[attackTracker.attacker.charName][3], AttackTrackerMenu.markerColors.enemyColors[attackTracker.attacker.charName][4]))
		end
	end
end
