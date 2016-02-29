--[[


		d888888b d888888b d88888b .88b  d88.      .d8888. db   d8b   db  .d8b.  d8888b. d8888b. d88888b d8888b.
		  `88'   `~~88~~' 88'     88'YbdP`88      88'  YP 88   I8I   88 d8' `8b 88  `8D 88  `8D 88'     88  `8D
		   88       88    88ooooo 88  88  88      `8bo.   88   I8I   88 88ooo88 88oodD' 88oodD' 88ooooo 88oobY'
		   88       88    88~~~~~ 88  88  88        `Y8b. Y8   I8I   88 88~~~88 88~~~   88~~~   88~~~~~ 88`8b
		  .88.      88    88.     88  88  88      db   8D `8b d8'8b d8' 88   88 88      88      88.     88 `88.
		Y888888P    YP    Y88888P YP  YP  YP      `8888Y'  `8b8' `8d8'  YP   YP 88      88      Y88888P 88   YD


	Item Swapper - Swap items from your inventory using the Numpad!

	Changelog:
		February 29, 2016:
			- Added a version check so the game won't crash if the Script is used on an "Outdated" Version of the game.
			
		February 28, 2016:
			- First Release.

]]--
GameVersion = GetGameVersion():sub(1,3)
SourceSlotDataTable =
{
	['6.4'] =
	{
		[1] = 0x9C, [2] = 0x7C, [3] = 0xA5,
		[4] = 0xC4, [5] = 0xBF, [6] = 0x92
	}
}

TargetSlotDataTable =
{
	['6.4'] =
	{
		[1] = 0x8B, [2] = 0xB6, [3] = 0x40,
		[4] = 0xC7, [5] = 0x18, [6] = 0xD4
	}
}

FirstKey = 0x60;
Keys = { 0x64, 0x65, 0x66, 0x61, 0x62, 0x63 }

function OnLoad()
	ISConfig = scriptConfig("Item Swapper: Info", "IS")
	ISConfig:addParam("KeysInfo", "Keys info:", SCRIPT_PARAM_INFO, "")
	ISConfig:addParam("NumPad0", "Numpad 0: Reset Key", SCRIPT_PARAM_INFO, "")
	ISConfig:addParam("Numpad1", "Numpad 1: Item Slot 4", SCRIPT_PARAM_INFO, "")
	ISConfig:addParam("Numpad2", "Numpad 2: Item Slot 5", SCRIPT_PARAM_INFO, "")
	ISConfig:addParam("Numpad3", "Numpad 3: Item Slot 6", SCRIPT_PARAM_INFO, "")
	ISConfig:addParam("Numpad4", "Numpad 4: Item Slot 1", SCRIPT_PARAM_INFO, "")
	ISConfig:addParam("Numpad5", "Numpad 5: Item Slot 2", SCRIPT_PARAM_INFO, "")
	ISConfig:addParam("Numpad6", "Numpad 6: Item Slot 3", SCRIPT_PARAM_INFO, "")
	ISConfig:addParam("Sep", "", SCRIPT_PARAM_INFO, "")
	ISConfig:addParam("NumLock", "Num Lock must be Active!", SCRIPT_PARAM_INFO, "")
	
	print("<font color=\"#D2444A\">Item Swapper:</font> <font color=\"#FFFFFF\">Successfully loaded!</font>")
	if SourceSlotDataTable[GameVersion] == nil or TargetSlotDataTable[GameVersion] == nil then
		print("<font color=\"#D2444A\">Item Swapper:</font> <font color=\"#FFFFFF\">The script is outdated for this version of the game (" .. GameVersion .. ")!</font>")
	end
end

function OnWndMsg(msg, key)
	if msg == 0x100 and key == 0x60 then
		FirstKey = 0x60;
	end
	
	if msg ~= 0x100 or IndexOf(Keys, key) == nil then
		return
	end
	
	if FirstKey == 0x60 then
		FirstKey = key
	end

	if FirstKey == key then
		return
	end
	
	SwapItem(IndexOf(Keys, FirstKey), IndexOf(Keys, key))
	FirstKey = 0x60
end

function IndexOf(table, value)
	for i = 1, #table do
		if table[i] == value then
			return i
		end
	end
	
	return nil
end

function SwapItem(sourceSlotId, targetSlotId)
	if SourceSlotDataTable[GameVersion] == nil or TargetSlotDataTable[GameVersion] == nil then
		return
	end
	
	local Packet = CLoLPacket(0x51)
	Packet.vTable = 0xE52AB4
	Packet:EncodeF(myHero.networkID)
	Packet:Encode1(SourceSlotDataTable[sourceSlotId])
	Packet:Encode1(TargetSlotDataTable[targetSlotId])
	SendPacket(Packet)
end
