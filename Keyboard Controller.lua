--[[


		db   dD d88888b db    db d8888b.  .d88b.   .d8b.  d8888b. d8888b.       .o88b.  .d88b.  d8b   db d888888b d8888b.  .d88b.  db      db      d88888b d8888b.
		88 ,8P' 88'     `8b  d8' 88  `8D .8P  Y8. d8' `8b 88  `8D 88  `8D      d8P  Y8 .8P  Y8. 888o  88 `~~88~~' 88  `8D .8P  Y8. 88      88      88'     88  `8D
		88,8P   88ooooo  `8bd8'  88oooY' 88    88 88ooo88 88oobY' 88   88      8P      88    88 88V8o 88    88    88oobY' 88    88 88      88      88ooooo 88oobY'
		88`8b   88~~~~~    88    88~~~b. 88    88 88~~~88 88`8b   88   88      8b      88    88 88 V8o88    88    88`8b   88    88 88      88      88~~~~~ 88`8b
		88 `88. 88.        88    88   8D `8b  d8' 88   88 88 `88. 88  .8D      Y8b  d8 `8b  d8' 88  V888    88    88 `88. `8b  d8' 88booo. 88booo. 88.     88 `88.
		YP   YD Y88888P    YP    Y8888P'  `Y88P'  YP   YP 88   YD Y8888D'       `Y88P'  `Y88P'  VP   V8P    YP    88   YD  `Y88P'  Y88888P Y88888P Y88888P 88   YD


	Keyboard Controller - Move your hero using the keyboard!

	Changelog:
		March 23, 2016:
			- Updated for 6.6.

		March 14, 2016:
			- Re-wrote the Script as a Class (For my upcoming Auto-Updater).
			- Improved the VIP Check, it will let you know what you can do.
			- Added Bol-Tools Tracker.

		March 11, 2016:
			- Updated for 6.5HF.

		March 09, 2016:
			- Updated for 6.5.

		March 07, 2016:
			- Now the "Disable spells" Option will support Mini-Patches as well.

		March 03, 2016:
			- First Release.
]]--

function Print(string)
	print("<font color=\"#EB9F0F\">Keyboard Controller:</font> <font color=\"#C34177\">" .. string .. "</font>")
end

class "KeyboardController"
function KeyboardController:__init()
	self.DirectionCases = 
	{
		["Up"] = { X = 0, Y = 200 },
		["Left"] = { X = -200, Y = 0 },
		["Down"] = { X = 0, Y = -200 },
		["Right"] = { X = 200, Y = 0 }
	}

	self.SpellsCharacters =
	{
		["Q"] = true,
		["W"] = true,
		["E"] = true,
		["R"] = true,
		["D"] = true,
		["F"] = true
	}
	
	self.GameVersion = GetGameVersion():sub(1,9)
	self.CastSpellHeader =
	{
		['6.6.137.4'] = 0x15A,
		['6.5.0.280'] = 0x10E,
		['6.5.0.277'] = 0x10E,
		['6.4.0.250'] = 0x49
	}
	
	self:OnLoad()
	
	-- Bol-Tools Tracker
	assert(load(Base64Decode("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"), nil, "bt", _ENV))()
	TrackerLoad("PuhqNuwgSjmUXkB2")
end

function KeyboardController:OnLoad()
	self.Config = scriptConfig("Keyboard Controller", "KG")
	self.Config:addParam("Enable", "Enable", SCRIPT_PARAM_ONOFF, true)
	self.Config:addParam("Info", "Keys Settings:", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("Up", "Up", SCRIPT_PARAM_ONKEYDOWN, false, 38)
	self.Config:addParam("Left", "Left", SCRIPT_PARAM_ONKEYDOWN, false, 37)
	self.Config:addParam("Down", "Down", SCRIPT_PARAM_ONKEYDOWN, false, 40)
	self.Config:addParam("Right", "Right", SCRIPT_PARAM_ONKEYDOWN, false, 39)
	
	Print("Successfully loaded!")
	
	if VIP_USER then
		if self.CastSpellHeader[self.GameVersion] ~= nil then
			self.Config:addParam("Sep", "", SCRIPT_PARAM_INFO, "")
			self.Config:addParam("DisableSpells", "Disable spells when script's keys are binded to spells' keys", SCRIPT_PARAM_ONOFF, true)
			
			Print("As a VIP User you can Block Spells if you are moving using Spell Keys!")
			
			AddSendPacketCallback(function(p)
				self:OnSendPacket(p)
			end)
		else
			Print("Spell disabling is outdated for this version of the game (" .. GameVersion .. ")!")
		end
	else
		Print("As a non VIP User you can't Block Spells if you are moving using Spell Keys!")
	end
	
	AddTickCallback(function()
		self:OnTick()
	end)
end

function KeyboardController:OnTick()
	if not self.Config.Enable then
		return
	end
	
	local Direction = { X = myHero.x, Y = myHero.z }
	for _, v in pairs(self.Config._param) do
		if self.Config[v.var] and self.DirectionCases[v.var] ~= nil then
			Direction = { X = Direction.X + self.DirectionCases[v.var].X, Y = Direction.Y + self.DirectionCases[v.var].Y }
		end
	end
	
	if Direction.X ~= myHero.x or Direction.Y ~= myHero.z then
		myHero:MoveTo(Direction.X, Direction.Y)
	end
end

function KeyboardController:OnSendPacket(p)
	if not self.Config.Enable or not self.Config.DisableSpells then
		return
	end
	
	if self.CastSpellHeader[self.GameVersion] == nil or p.header ~= self.CastSpellHeader[self.GameVersion] then
		return
	end
	
	for _, v in pairs(self.Config._param) do
		if self.Config[v.var] and v.key ~= nil and self.SpellsCharacters[string.char(v.key)] ~= nil and self.SpellsCharacters[string.char(v.key)] then
			p:Block()
		end
	end
end

KeyboardController()
