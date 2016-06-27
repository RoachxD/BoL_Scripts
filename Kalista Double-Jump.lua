local LastAATick = 0
function OnTick()
	local AttackSpeed = 0.644 * myHero.attackSpeed
	if AttackSpeed <= 1.70 then
		return
	end
	
	local EnemyHeroes = GetEnemyHeroes()
	local TickCount = GetTickCount()
	local CanAttack, CanMove = TickCount > LastAATick + 1000 / AttackSpeed - 150, TickCount >= LastAATick + 1
	if not (CanAttack or CanMove) then
		return
	end
	
	for _, hero in pairs(EnemyHeroes) do
		if hero and hero.valid and not hero.dead and hero.bTargetable then
			local Range = myHero.range + myHero.boundingRadius + hero.boundingRadius
			if GetDistanceSqr(myHero, hero) <= Range * Range then
				if CanAttack then
					myHero:Attack(hero)
					return
				end
				
				if CanMove then
					myHero:MoveTo(mousePos)
					return
				end
			end
		end
	end
end

function OnAnimation(unit, anim)
	if unit ~= myHero or not (anim:lower():find("attack") or anim:lower():find("crit")) then
		return
	end
	
	LastAATick = GetTickCount() - GetLatency() * 0.5
end
