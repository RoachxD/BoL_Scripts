--[[


		d888888b d888888b d88888b .88b  d88.      .d8888. db   d8b   db  .d8b.  d8888b. d8888b. d88888b d8888b.
		  `88'   `~~88~~' 88'     88'YbdP`88      88'  YP 88   I8I   88 d8' `8b 88  `8D 88  `8D 88'     88  `8D
		   88       88    88ooooo 88  88  88      `8bo.   88   I8I   88 88ooo88 88oodD' 88oodD' 88ooooo 88oobY'
		   88       88    88~~~~~ 88  88  88        `Y8b. Y8   I8I   88 88~~~88 88~~~   88~~~   88~~~~~ 88`8b
		  .88.      88    88.     88  88  88      db   8D `8b d8'8b d8' 88   88 88      88      88.     88 `88.
		Y888888P    YP    Y88888P YP  YP  YP      `8888Y'  `8b8' `8d8'  YP   YP 88      88      Y88888P 88   YD


	Item Swapper - Swap items from your inventory using the Numpad!

	Changelog:
		March 14, 2016:
			- Re-wrote the Script as a Class (For my upcoming Auto-Updater).
			- Added Bol-Tools Tracker.

		March 11, 2016:
			- Updated for 6.5HF.

		March 09, 2016:
			- Updated for 6.5.

		March 07, 2016:
			- Re-wrote the tables to make it look better.
			- Now it will support Mini-Patches as well.

		March 04, 2016:
			- Improved SwapItem Function:
				- It won't send packets if both inventory slots are empty.
				- It will automatically check if the first slot you choose is empty and reverse swap the items.

		March 02, 2016:
			- Fixed a little mistake, the script was not working anymore.

		February 29, 2016:
			- Added a version check so the game won't crash if the Script is used on an "Outdated" Version of the game.

		February 28, 2016:
			- First Release.

]]--

local function Print(string)
	print("<font color=\"#35445A\">Item Swapper:</font> <font color=\"#3A99D9\">" .. string .. "</font>")
end

if not VIP_USER then
	Print("Sorry, this script is VIP Only!")
	return
end

class "ItemSwapper"
function ItemSwapper:__init()
	self.GameVersion = GetGameVersion():sub(1,9)
	self.Packet =
	{
		['6.5.0.280'] =
		{
			Header = 0x121,
			vTable = 0xED67EC,
			SourceSlotTable =
			{
				[1] = 0x56, [2] = 0x17, [3] = 0x42,
				[4] = 0x6D, [5] = 0x74, [6] = 0xC5
			},
			TargetSlotTable =
			{
				[1] = 0x48, [2] = 0x80, [3] = 0x81,
				[4] = 0x2C, [5] = 0xD4, [6] = 0x84
			}
		},
		['6.5.0.277'] =
		{
			Header = 0x121,
			vTable = 0xEF4D68,
			SourceSlotTable =
			{
				[1] = 0x56, [2] = 0x17, [3] = 0x42,
				[4] = 0x6D, [5] = 0x74, [6] = 0xC5
			},
			TargetSlotTable =
			{
				[1] = 0x48, [2] = 0x80, [3] = 0x81,
				[4] = 0x2C, [5] = 0xD4, [6] = 0x84
			}
		},
		['6.4.0.250'] =
		{
			Header = 0x51,
			vTable = 0xE52AB4,
			SourceSlotTable =
			{
				[1] = 0x9C, [2] = 0x7C, [3] = 0xA5,
				[4] = 0xC4, [5] = 0xBF, [6] = 0x92
			},
			TargetSlotTable =
			{
				[1] = 0x8B, [2] = 0xB6, [3] = 0x40,
				[4] = 0xC7, [5] = 0x18, [6] = 0xD4
			}
		}
	}

	self.Keys =
	{
		FirstKey = 0x60,
		SlotKeys =
		{
			[1] = 0x64, [2] = 0x65, [3] = 0x66,
			[4] = 0x61, [5] = 0x62, [6] = 0x63
		}
	}
	
	self:OnLoad()
	
	-- Bol-Tools Tracker
	assert(load(Base64Decode("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"), nil, "bt", _ENV))()
	TrackerLoad("gbyMzEMM2CMOJnZr")
end

function ItemSwapper:OnLoad()
	self.Config = scriptConfig("Item Swapper: Info", "IS")
	self.Config:addParam("KeysInfo", "Keys info:", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("NumPad0", "Numpad 0: Reset Key", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("Numpad1", "Numpad 1: Item Slot 4", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("Numpad2", "Numpad 2: Item Slot 5", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("Numpad3", "Numpad 3: Item Slot 6", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("Numpad4", "Numpad 4: Item Slot 1", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("Numpad5", "Numpad 5: Item Slot 2", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("Numpad6", "Numpad 6: Item Slot 3", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("Sep", "", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("NumLock", "Num Lock must be Active!", SCRIPT_PARAM_INFO, "")
	
	Print("Successfully loaded!")
	if self.Packet[self.GameVersion] == nil then
		Print("The script is outdated for this version of the game (" .. GameVersion .. ")!")
	end
	
	AddMsgCallback(function(msg, key)
		self:OnWndMsg(msg, key)
	end)
end

function ItemSwapper:OnWndMsg(msg, key)
	if msg == 0x100 and key == 0x60 then
		self.Keys.FirstKey = 0x60;
	end
	
	if msg ~= 0x100 or self:IndexOf(self.Keys.SlotKeys, key) == nil then
		return
	end
	
	if self.Keys.FirstKey == 0x60 then
		self.Keys.FirstKey = key
	end

	if self.Keys.FirstKey == key then
		return
	end
	
	self:SwapItem(self:IndexOf(self.Keys.SlotKeys, self.Keys.FirstKey), self:IndexOf(self.Keys.SlotKeys, key))
	self.Keys.FirstKey = 0x60
end

function ItemSwapper:IndexOf(table, value)
	for i = 1, #table do
		if table[i] == value then
			return i
		end
	end
	
	return nil
end

function ItemSwapper:SwapItem(sourceSlotId, targetSlotId)
	if self.Packet[self.GameVersion].SourceSlotTable == nil or self.Packet[self.GameVersion].TargetSlotTable == nil then
		return
	end
	
	if GetInventorySlotIsEmpty(sourceSlotId + 5) and GetInventorySlotIsEmpty(targetSlotId + 5) then
		return
	end
	
	if GetInventorySlotIsEmpty(sourceSlotId + 5) and not GetInventorySlotIsEmpty(targetSlotId + 5) then
		sourceSlotId = sourceSlotId + targetSlotId
		targetSlotId = sourceSlotId - targetSlotId
		sourceSlotId = sourceSlotId - targetSlotId
	end
	
	local CustomPacket = CLoLPacket(self.Packet[self.GameVersion].Header)
	CustomPacket.vTable = self.Packet[self.GameVersion].vTable
	CustomPacket:EncodeF(myHero.networkID)
	CustomPacket:Encode1(self.Packet[self.GameVersion].SourceSlotTable[sourceSlotId])
	CustomPacket:Encode1(self.Packet[self.GameVersion].TargetSlotTable[targetSlotId])
	SendPacket(CustomPacket)
end

ItemSwapper()
