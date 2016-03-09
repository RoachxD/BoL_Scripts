--[[


		db   dD d88888b db    db d8888b.  .d88b.   .d8b.  d8888b. d8888b.       .o88b.  .d88b.  d8b   db d888888b d8888b.  .d88b.  db      db      d88888b d8888b.
		88 ,8P' 88'     `8b  d8' 88  `8D .8P  Y8. d8' `8b 88  `8D 88  `8D      d8P  Y8 .8P  Y8. 888o  88 `~~88~~' 88  `8D .8P  Y8. 88      88      88'     88  `8D
		88,8P   88ooooo  `8bd8'  88oooY' 88    88 88ooo88 88oobY' 88   88      8P      88    88 88V8o 88    88    88oobY' 88    88 88      88      88ooooo 88oobY'
		88`8b   88~~~~~    88    88~~~b. 88    88 88~~~88 88`8b   88   88      8b      88    88 88 V8o88    88    88`8b   88    88 88      88      88~~~~~ 88`8b
		88 `88. 88.        88    88   8D `8b  d8' 88   88 88 `88. 88  .8D      Y8b  d8 `8b  d8' 88  V888    88    88 `88. `8b  d8' 88booo. 88booo. 88.     88 `88.
		YP   YD Y88888P    YP    Y8888P'  `Y88P'  YP   YP 88   YD Y8888D'       `Y88P'  `Y88P'  VP   V8P    YP    88   YD  `Y88P'  Y88888P Y88888P Y88888P 88   YD


	Keyboard Controller - Move your hero using the keyboard!

	Changelog:
		March 09, 2016:
			- Updated for 6.5.

		March 07, 2016:
			- Now the "Disable spells" Option will support Mini-Patches as well.

		March 03, 2016:
			- First Release.
]]--

Player = myHero

DirectionCases = 
{
	["Up"] = { X = 0, Y = 200 },
	["Left"] = { X = -200, Y = 0 },
	["Down"] = { X = 0, Y = -200 },
	["Right"] = { X = 200, Y = 0 }
}

SpellsCharacters =
{
	["Q"] = true,
	["W"] = true,
	["E"] = true,
	["R"] = true,
	["D"] = true,
	["F"] = true
}

function OnLoad()
	KCConfig = scriptConfig("Keyboard Controller", "KG")
	KCConfig:addParam("Enable", "Enable", SCRIPT_PARAM_ONOFF, true)
	KCConfig:addParam("Info", "Keys Settings:", SCRIPT_PARAM_INFO, "")
	KCConfig:addParam("Up", "Up", SCRIPT_PARAM_ONKEYDOWN, false, 38)
	KCConfig:addParam("Left", "Left", SCRIPT_PARAM_ONKEYDOWN, false, 37)
	KCConfig:addParam("Down", "Down", SCRIPT_PARAM_ONKEYDOWN, false, 40)
	KCConfig:addParam("Right", "Right", SCRIPT_PARAM_ONKEYDOWN, false, 39)
	
	print("<font color=\"#D2444A\">Keyboard Controller:</font> <font color=\"#FFFFFF\">Successfully loaded!</font>")
	
	if VIP_USER then
		KCConfig:addParam("Sep", "", SCRIPT_PARAM_INFO, "")
		KCConfig:addParam("DisableSpells", "Disable spells when script's keys are binded to spells' keys", SCRIPT_PARAM_ONOFF, true)
		
		if CastSpellHeader[GameVersion] == nil then
			print("<font color=\"#D2444A\">Keyboard Controller:</font> <font color=\"#FFFFFF\">Spell disabling is outdated for this version of the game (" .. GameVersion .. ")!</font>")
		end
	end
end

function OnTick()
	if not KCConfig.Enable then
		return
	end
	
	local Direction = { X = Player.x, Y = Player.z }
	for _, v in pairs(KCConfig._param) do
		if KCConfig[v.var] and DirectionCases[v.var] ~= nil then
			Direction = { X = Direction.X + DirectionCases[v.var].X, Y = Direction.Y + DirectionCases[v.var].Y }
		end
	end
	
	if Direction.X ~= Player.x or Direction.Y ~= Player.z then
		Player:MoveTo(Direction.X, Direction.Y)
	end
end

if not VIP_USER then
	return
end

GameVersion = GetGameVersion():sub(1,9)
CastSpellHeader =
{
	['6.4.0.250'] = 0x49,
	['6.5.0.277'] = 0x10E
}

function OnSendPacket(p)
	if not KCConfig.Enable or not KCConfig.DisableSpells then
		return
	end
	
	if CastSpellHeader[GameVersion] == nil or p.header ~= CastSpellHeader[GameVersion] then
		return
	end
	
	for _, v in pairs(KCConfig._param) do
		if KCConfig[v.var] and v.key ~= nil and SpellsCharacters[string.char(v.key)] ~= nil and SpellsCharacters[string.char(v.key)] then
			p:Block()
		end
	end
end
