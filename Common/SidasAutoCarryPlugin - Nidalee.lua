local QReady, EReady, RReady = nil, nil, nil
local RangeQ = 1400

local SkillQ = {spellKey = _Q, range = RangeQ, speed = 1.3, delay = 125, width = 80, configName = "javelinToss", displayName = "Q (Javelin Toss)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true }

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = RangeQ
end

function PluginOnTick()
	nSpellCheck()
	if AutoCarry.MainMenu.AutoCarry then nCombo() end
end

function PluginOnDraw()
	if not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, RangeQ, 0x00FFFF)
	end
end

function nSpellCheck()
	QReady = (myHero:CanUseSpell(_Q) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
end

function KS()
	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if ValidTarget(enemy, RangeQ) and getDmg("Q", enemy, myHero) >= enemy.health then
			CastSpell(_Q, enemy)
		end
	end
end

function nCombo()
	local Target = AutoCarry.GetAttackTarget()

	if ValidTarget(Target) then
		if QReady and GetDistance(Target) < RangeQ then
			AutoCarry.CastSkillshot(SkillQ, Target)
		end
	end
end
