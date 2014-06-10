--[[


		 .d8b.  d8888b. db    db  .d8b.  d8b   db  .o88b. d88888b d8888b.      d888888b db    db d8888b. d8b   db       .d8b.  d8888b.  .d88b.  db    db d8b   db d8888b. 
		d8' `8b 88  `8D 88    88 d8' `8b 888o  88 d8P  Y8 88'     88  `8D      `~~88~~' 88    88 88  `8D 888o  88      d8' `8b 88  `8D .8P  Y8. 88    88 888o  88 88  `8D 
		88ooo88 88   88 Y8    8P 88ooo88 88V8o 88 8P      88ooooo 88   88         88    88    88 88oobY' 88V8o 88      88ooo88 88oobY' 88    88 88    88 88V8o 88 88   88 
		88~~~88 88   88 `8b  d8' 88~~~88 88 V8o88 8b      88~~~~~ 88   88         88    88    88 88`8b   88 V8o88      88~~~88 88`8b   88    88 88    88 88 V8o88 88   88 
		88   88 88  .8D  `8bd8'  88   88 88  V888 Y8b  d8 88.     88  .8D         88    88b  d88 88 `88. 88  V888      88   88 88 `88. `8b  d8' 88b  d88 88  V888 88  .8D 
		YP   YP Y8888D'    YP    YP   YP VP   V8P  `Y88P' Y88888P Y8888D'         YP    ~Y8888P' 88   YD VP   V8P      YP   YP 88   YD  `Y88P'  ~Y8888P' VP   V8P Y8888D' 

	Advanced Turn Around - Dodge it, by turning around!
]]--

function OnLoad()
	TurnAroundTable = {
		lastTargetedPos = { x = nil, z = nil },
		lastMove = 0,
		champions = {
			{ charName = "Cassiopeia", key = "CassiopeiaPetrifyingGaze",				range = 750 * 750, spellName = "Spell - Petrifying Gaze (R)",	var = -100 },
			{ charName = "Shaco",	   key = "ShacoBasicAttack" or "ShacoCritAttack",	range = 125 * 125, spellName = "Other - Auto-attacks",			var =  100 },
			{ charName = "Shaco",	   key = "TwoShivPoison",							range = 625 * 625, spellName = "Spell - Two-Shiv Poison (E)",	var =  100 },
			{ charName = "Tryndamere", key = "MockingShout",							range = 850 * 850, spellName = "Spell - Mocking Shout (W)",		var =  100 }
		}
	}

	oldMoveTo = myHero.MoveTo
	myHero.MoveTo = function(unit, x, z)
						if TurnAroundTable.lastMove ~= 0 then return end

						TurnAroundTable.lastTargetedPos.x, TurnAroundTable.lastTargetedPos.z = x, z

						return oldMoveTo(unit, x, z)
					end

	TurnAroundMenu = scriptConfig("Advanced Turn Around", "TA")
		TurnAroundMenu:addParam("Enable", "Enable the Script", SCRIPT_PARAM_ONOFF, true)

		TurnAroundMenu:addSubMenu("Champions and Spells", "cas")
		for i = 1, #TurnAroundTable.champions, 1 do
			if i ~= 3 then
				TurnAroundMenu.cas:addSubMenu(TurnAroundTable.champions[i].charName.."'s Spells to Avoid", TurnAroundTable.champions[i].charName)
			end
			TurnAroundMenu.cas[TurnAroundTable.champions[i].charName]:addParam(TurnAroundTable.champions[i].key, TurnAroundTable.champions[i].spellName, SCRIPT_PARAM_ONOFF, true)
		end
end

function OnProcessSpell(unit, spell)
	if not TurnAroundMenu.Enable or (myHero.charName == "Teemo" and myHero.isStealthed) then return end

	if unit ~= nil and unit.team ~= myHero.team then
		for i = 1, #TurnAroundTable.champions, 1 do
			if TurnAroundMenu.cas[TurnAroundTable.champions[i].charName][TurnAroundTable.champions[i].key] then
				if spell.name:find(TurnAroundTable.champions[i].key) and (GetDistanceSqr(unit, myHero) <= TurnAroundTable.champions[i].range and unit.charName ~= "Shaco" or spell.target == myHero) then
					oldMoveTo(myHero, myHero.x + ((unit.x - myHero.x) * (TurnAroundTable.champions[i].var) / GetDistance(unit)), myHero.z + ((unit.z - myHero.z) * (TurnAroundTable.champions[i].var) / GetDistance(unit)))

					TurnAroundTable.lastMove = os.clock()
				end
			end
		end
	end
end 

function OnWndMsg(msg, key)
	if not TurnAroundMenu.Enable then return end

	if msg == WM_RBUTTONDOWN then
		TurnAroundTable.lastTargetedPos.x, TurnAroundTable.lastTargetedPos.z = mousePos.x, mousePos.z
	end
end

function OnTick()
	if not TurnAroundMenu.Enable or TurnAroundTable.lastMove == 0 then return end

	if os.clock() - TurnAroundTable.lastMove >= .7 and (TurnAroundTable.lastTargetedPos.x ~= myHero.x and TurnAroundTable.lastTargetedPos.z ~= myHero.z) and (TurnAroundTable.lastTargetedPos.x ~= nil and TurnAroundTable.lastTargetedPos.z ~= nil) then
		oldMoveTo(myHero, TurnAroundTable.lastTargetedPos.x, TurnAroundTable.lastTargetedPos.z)

		TurnAroundTable.lastMove = 0
	end
end
