--[[


        d888888b d888888b d88888b .88b  d88.      .d8888. db   d8b   db  .d8b.  d8888b. d8888b. d88888b d8888b.
          `88'   `~~88~~' 88'     88'YbdP`88      88'  YP 88   I8I   88 d8' `8b 88  `8D 88  `8D 88'     88  `8D
           88       88    88ooooo 88  88  88      `8bo.   88   I8I   88 88ooo88 88oodD' 88oodD' 88ooooo 88oobY'
           88       88    88~~~~~ 88  88  88        `Y8b. Y8   I8I   88 88~~~88 88~~~   88~~~   88~~~~~ 88`8b
          .88.      88    88.     88  88  88      db   8D `8b d8'8b d8' 88   88 88      88      88.     88 `88.
        Y888888P    YP    Y88888P YP  YP  YP      `8888Y'  `8b8' `8d8'  YP   YP 88      88      Y88888P 88   YD


	Item Swapper - Swap items from your inventory using the Numpad!

	Changelog:
		April 20, 2016 [r2.7]:
			- Updated for 6.8.
			- Updated BoL-Tracker's code.

		April 16, 2016 [r2.6]:
			- Fixed a bug with the Auto-Updater.

		April 16, 2016 [r2.5]:
			- Improved the performance of the Script.

		April 08, 2016 [r2.4]:
			- Updated for 6.7HF.
			- Fixed a 'nil value' throwing error.
			- Re-structured the Packet Table.

		April 06, 2016 [r2.3]:
			- Updated for 6.7.

		April 04, 2016 [r2.2]:
			- Deleted IndexOf function and its usage.
			- Added Script Version and Game Version to the menu.

		April 01, 2016 [r2.1]:
			- Updated for 6.6HF.

		March 28, 2016 [r2.0]:
			- Improved the Auto-Updater.
			- Added Global Y Offset for the Auto-Updater so the Drawing won't draw in the same Spot.

		March 27, 2016 [r1.9]:
			- Added an Auto-Updater.

		March 23, 2016 [r1.8]:
			- Updated for 6.6.

		March 14, 2016 [r1.7]:
			- Re-wrote the Script as a Class (For my upcoming Auto-Updater).
			- Added Bol-Tools Tracker.

		March 11, 2016 [r1.6]:
			- Updated for 6.5HF.

		March 09, 2016 [r1.5]:
			- Updated for 6.5.

		March 07, 2016 [r1.4]:
			- Re-wrote the tables to make it look better.
			- Now it will support Mini-Patches as well.

		March 04, 2016 [r1.3]:
			- Improved SwapItem Function:
				- It won't send packets if both inventory slots are empty.
				- It will automatically check if the first slot you choose is empty and reverse swap the items.

		March 02, 2016 [r1.2]:
			- Fixed a little mistake, the script was not working anymore.

		February 29, 2016 [r1.1]:
			- Added a version check so the game won't crash if the Script is used on an "Outdated" Version of the game.

		February 28, 2016 [r1.0]:
			- First Release.
]]--

local Script =
{
	Name = "Item Swapper",
	Version = 2.7
}

local function Print(string)
	print("<font color=\"#35445A\">" .. Script.Name .. ":</font> <font color=\"#3A99D9\">" .. string .. "</font>")
end

if not VIP_USER then
	Print("Sorry, this script is VIP Only!")
	return
end

class "ISUpdater"
local random, round = math.random, math.round
function ISUpdater:__init(LocalVersion, Host, Path, LocalPath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion, CallbackError)
	self.LocalVersion = LocalVersion
	self.Host = Host
	self.VersionPath = '/BoL/TCPUpdater/GetScript5.php?script=' .. self:Base64Encode(self.Host .. Path .. '.ver') .. '&rand=' .. random(99999999)
	self.ScriptPath = '/BoL/TCPUpdater/GetScript5.php?script=' .. self:Base64Encode(self.Host .. Path .. '.lua') .. '&rand=' .. random(99999999)
	self.LocalPath = LocalPath
	self.CallbackUpdate = CallbackUpdate
	self.CallbackNoUpdate = CallbackNoUpdate
	self.CallbackNewVersion = CallbackNewVersion
	self.CallbackError = CallbackError

	self.OffsetY = _G.OffsetY and _G.OffsetY or 0
	_G.OffsetY = _G.OffsetY and _G.OffsetY + round(0.08333333333 * WINDOW_H) or round(0.08333333333 * WINDOW_H)

	AddDrawCallback(function()
		self:OnDraw()
	end)

	self:CreateSocket(self.VersionPath)
	self.DownloadStatus = 'Connecting to Server..'
	self.Progress = 0
	AddTickCallback(function()
		self:GetOnlineVersion()
	end)
end

function ISUpdater:OnDraw()
	if (self.DownloadStatus == 'Downloading Script:' or self.DownloadStatus == 'Downloading Version:') and self.Progress == 100 then
		return
	end

	local LoadingBar =
	{
		X = round(0.91 * WINDOW_W),
		Y = round(0.73 * WINDOW_H) - self.OffsetY,
		Height = round(0.01666666666 * WINDOW_H),
		Width = round(0.171875 * WINDOW_W),
		Border = 1,
		HeaderFontSize = round(0.01666666666 * WINDOW_H),
		ProgressFontSize = round(0.01125 * WINDOW_H),
		BackgroundColor = 0xFF3A99D9,
		ForegroundColor = 0xFF35445A
	}

	DrawText(self.DownloadStatus, LoadingBar.HeaderFontSize, LoadingBar.X - 0.5 * LoadingBar.Width, LoadingBar.Y - LoadingBar.Height - LoadingBar.Border, LoadingBar.BackgroundColor)
	DrawLine(LoadingBar.X, LoadingBar.Y, LoadingBar.X, LoadingBar.Y + LoadingBar.Height, LoadingBar.Width, LoadingBar.BackgroundColor)
	if self.Progress > 0 then
		local Width = 0.01 * ((LoadingBar.Width - 2 * LoadingBar.Border) * self.Progress)
		local Offset = 0.5 * (LoadingBar.Width - Width)
		DrawLine(LoadingBar.X - Offset + LoadingBar.Border, LoadingBar.Y + LoadingBar.Border, LoadingBar.X - Offset + LoadingBar.Border, LoadingBar.Y + LoadingBar.Height - LoadingBar.Border, Width, LoadingBar.ForegroundColor)
	end

	DrawText(self.Progress .. '%', LoadingBar.ProgressFontSize, LoadingBar.X - 2 * LoadingBar.Border, LoadingBar.Y + LoadingBar.Border, self.Progress < 50 and LoadingBar.ForegroundColor or LoadingBar.BackgroundColor)
end

function ISUpdater:CreateSocket(url)
	if not self.LuaSocket then
		self.LuaSocket = require("socket")
	else
		self.Socket:close()
		self.Socket = nil
		self.Size = nil
		self.RecvStarted = false
	end

	self.LuaSocket = require("socket")
	self.Socket = self.LuaSocket.tcp()
	self.Socket:settimeout(0, 'b')
	self.Socket:settimeout(99999999, 't')
	self.Socket:connect('sx-bol.eu', 80)
	self.Url = url
	self.Started = false
	self.LastPrint = ""
	self.File = ""
end

local gsub, byte, sub = string.gsub, string.byte, string.sub
function ISUpdater:Base64Encode(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return (gsub((gsub(data, '.', function(x)
		local r, b = '', byte(x)
		for i = 8, 1, -1 do
			r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
		end

		return r;
	end) .. '0000'), '%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then
			return ''
		end

		local c = 0
		for i = 1, 6 do
			c = c + (sub(x, i, i) == '1' and 2 ^ (6 - i) or 0)
		end

		return sub(b, 1 + c, 1 + c)
	end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

local find, len = string.find, string.len
function ISUpdater:GetOnlineVersion()
	if self.GotScriptVersion then
		return
	end

	self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
	if self.Status == 'timeout' and not self.Started then
		self.Started = true
		self.Socket:send("GET " .. self.Url .. " HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
	end

	if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
		self.RecvStarted = true
		self.DownloadStatus = 'Downloading Version:'
		self.Progress = 0
	end

	self.File = self.File .. (self.Receive or self.Snipped)
	if find(self.File, '</size>') then
		if not self.Size then
			self.Size = tonumber(sub(self.File, 6 + find(self.File, '<size>'), find(self.File, '</size>') - 1))
		end

		if find(self.File, '<script>') then
			local _,ScriptFind = find(self.File, '<script>')
			local ScriptEnd = find(self.File, '</script>')
			if ScriptEnd then
				ScriptEnd = ScriptEnd - 1
			end

			local DownloadedSize = len(sub(self.File, 1 + ScriptFind, ScriptEnd or -1))
			self.Progress = round(100 / self.Size * DownloadedSize, 2)
		end
	end

	if find(self.File, '</script>') then
		local a, b = find(self.File, '\r\n\r\n')
		self.File = sub(self.File, a, -1)
		self.NewFile = ''
		for line, content in ipairs(self.File:split('\n')) do
			if len(content) > 5 then
				self.NewFile = self.NewFile .. content
			end
		end

		local HeaderEnd, ContentStart = find(self.File, '<script>')
		local ContentEnd, _ = find(self.File, '</script>')
		if not ContentStart or not ContentEnd then
			if self.CallbackError and type(self.CallbackError) == 'function' then
				self.CallbackError()
			end
		else
			self.OnlineVersion = (Base64Decode(sub(self.File, 1 + ContentStart, ContentEnd - 1)))
			self.OnlineVersion = tonumber(self.OnlineVersion)
			if self.OnlineVersion > self.LocalVersion then
				if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
					self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
				end

				self:CreateSocket(self.ScriptPath)
				self.DownloadStatus = 'Connecting to Server..'
				self.Progress = 0
				AddTickCallback(function()
					self:DownloadUpdate()
				end)
			else
				if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
					self.CallbackNoUpdate(self.LocalVersion)
				end
			end
		end

		self.GotScriptVersion = true
	end
end

function ISUpdater:DownloadUpdate()
	if self.GotScriptUpdate then
		return
	end

	self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
	if self.Status == 'timeout' and not self.Started then
		self.Started = true
		self.Socket:send("GET " .. self.Url .. " HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
	end

	if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
		self.RecvStarted = true
		self.DownloadStatus = 'Downloading Script:'
		self.Progress = 0
	end

	self.File = self.File .. (self.Receive or self.Snipped)
	if find(self.File, '</size>') then
		if not self.Size then
			self.Size = tonumber(sub(self.File, 6 + find(self.File, '<size>'), find(self.File, '</size>') - 1))
		end

		if find(self.File, '<script>') then
			local _, ScriptFind = find(self.File, '<script>')
			local ScriptEnd = find(self.File, '</script>')
			if ScriptEnd then
				ScriptEnd = ScriptEnd - 1
			end

			local DownloadedSize = len(sub(self.File, 1 + ScriptFind, ScriptEnd or -1))
			self.Progress = round(100 / self.Size * DownloadedSize, 2)
		end
	end

	if find(self.File, '</script>') then
		local a, b = find(self.File, '\r\n\r\n')
		self.File = sub(self.File, a, -1)
		self.NewFile = ''
		for line, content in ipairs(self.File:split('\n')) do
			if len(content) > 5 then
				self.NewFile = self.NewFile .. content
			end
		end

		local HeaderEnd, ContentStart = find(self.NewFile, '<script>')
		local ContentEnd, _ = find(self.NewFile, '</script>')
		if not ContentStart or not ContentEnd then
			if self.CallbackError and type(self.CallbackError) == 'function' then
				self.CallbackError()
			end
		else
			local newf = sub(self.NewFile, 1 + ContentStart, ContentEnd - 1)
			local newf = gsub(newf, '\r','')
			if len(newf) ~= self.Size then
				if self.CallbackError and type(self.CallbackError) == 'function' then
					self.CallbackError()
				end

				return
			end

			local newf = Base64Decode(newf)
			if type(load(newf)) ~= 'function' then
				if self.CallbackError and type(self.CallbackError) == 'function' then
					self.CallbackError()
				end
			else
				local f = io.open(self.LocalPath,"w+b")
				f:write(newf)
				f:close()
				if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
					self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
				end
			end
		end

		self.GotScriptUpdate = true
	end
end

local format = string.format
AddLoadCallback(function()
	local UpdaterInfo =
	{
		Version = Script.Version,
		Host = 'raw.githubusercontent.com',
		Path = '/RoachxD/BoL_Scripts/master/' .. gsub(Script.Name, ' ', '%%20'),
		LocalPath = SCRIPT_PATH .. '/' .. Script.Name .. '.lua',
		CallbackUpdate = function(newVersion, oldVersion)
			Print("Updated to r" .. format("%.1f", newVersion) .. ", please 2xF9 to reload!")
		end,
		CallbackNoUpdate = function(version)
			Print("No updates found!")
			ItemSwapper()
		end,
		CallbackNewVersion = function(version)
			Print("New release found (r" .. format("%.1f", version) .. "), please wait until it's downloaded!")
		end,
		CallbackError = function(version)
			Print("Download failed, please try again!")
			Print("If the problem persists please contact script's author!")
			ItemSwapper()
		end
	}

	ISUpdater(UpdaterInfo.Version, UpdaterInfo.Host, UpdaterInfo.Path, UpdaterInfo.LocalPath, UpdaterInfo.CallbackUpdate, UpdaterInfo.CallbackNoUpdate, UpdaterInfo.CallbackNewVersion, UpdaterInfo.CallbackError)
end)

class "ItemSwapper"
function ItemSwapper:__init()
	self.GameVersion = sub(GetGameVersion(), 1, 9)
	self.Packet =
	{
		
		['6.8.140.7'] =
		{
			Header = 0x14,
			vTable = 0xEB7BC4,
			SourceSlotTable =
			{
				[1] = 0x92, [2] = 0x89, [3] = 0x25,
				[4] = 0x27, [5] = 0x69, [6] = 0x40
			},
			TargetSlotTable =
			{
				[1] = 0xDE, [2] = 0xDC, [3] = 0xDA,
				[4] = 0xD8, [5] = 0xD6, [6] = 0xD4
			}
		},
		['6.7.139.4'] =
		{
			Header = 0xFE,
			vTable = 0xE941B8,
			SourceSlotTable =
			{
				[1] = 0x7C, [2] = 0x5C, [3] = 0x1B,
				[4] = 0x0E, [5] = 0x35, [6] = 0xCD
			},
			TargetSlotTable =
			{
				[1] = 0x52, [2] = 0x28, [3] = 0xDA,
				[4] = 0x59, [5] = 0x50, [6] = 0x7C
			}
		},
		['6.7.138.9'] =
		{
			Header = 0xFE,
			vTable = 0xE941B8,
			SourceSlotTable =
			{
				[1] = 0x7C, [2] = 0x5C, [3] = 0x1B,
				[4] = 0x0E, [5] = 0x35, [6] = 0xCD
			},
			TargetSlotTable =
			{
				[1] = 0x52, [2] = 0x28, [3] = 0xDA,
				[4] = 0x59, [5] = 0x50, [6] = 0x7C
			}
		},
		['6.6.138.7'] =
		{
			Header = 0x139,
			vTable = 0xEC2164,
			SourceSlotTable =
			{
				[1] = 0xF8, [2] = 0x4F, [3] = 0x14,
				[4] = 0x9E, [5] = 0x24, [6] = 0x50
			},
			TargetSlotTable =
			{
				[1] = 0x2C, [2] = 0xD9, [3] = 0x7F,
				[4] = 0xF4, [5] = 0xF1, [6] = 0x8D
			}
		},
		['6.6.137.4'] =
		{
			Header = 0x139,
			vTable = 0xEC1164,
			SourceSlotTable =
			{
				[1] = 0xF8, [2] = 0x4F, [3] = 0x14,
				[4] = 0x9E, [5] = 0x24, [6] = 0x50
			},
			TargetSlotTable =
			{
				[1] = 0x2C, [2] = 0xD9, [3] = 0x7F,
				[4] = 0xF4, [5] = 0xF1, [6] = 0x8D
			}
		},
		Encode = function(packet, networkID, sourceSlotId, targetSlotId)
			local Struct =
			{
				['6.8.140.7'] = function()
					packet:EncodeF(networkID)
					packet:Encode1(self.Packet[self.GameVersion].SourceSlotTable[sourceSlotId])
					packet:Encode1(self.Packet[self.GameVersion].TargetSlotTable[targetSlotId])
				end,
				['6.7.139.4'] = function()
					packet:EncodeF(networkID)
					packet:Encode1(self.Packet[self.GameVersion].TargetSlotTable[targetSlotId])
					packet:Encode1(self.Packet[self.GameVersion].SourceSlotTable[sourceSlotId])
				end,
				['6.7.138.9'] = function()
					packet:EncodeF(networkID)
					packet:Encode1(self.Packet[self.GameVersion].TargetSlotTable[targetSlotId])
					packet:Encode1(self.Packet[self.GameVersion].SourceSlotTable[sourceSlotId])
				end,
				['6.6.138.7'] = function()
					packet:EncodeF(networkID)
					packet:Encode1(self.Packet[self.GameVersion].SourceSlotTable[sourceSlotId])
					packet:Encode1(self.Packet[self.GameVersion].TargetSlotTable[targetSlotId])
				end,
				['6.6.137.4'] = function()
					packet:EncodeF(networkID)
					packet:Encode1(self.Packet[self.GameVersion].SourceSlotTable[sourceSlotId])
					packet:Encode1(self.Packet[self.GameVersion].TargetSlotTable[targetSlotId])
				end,
				['6.5.0.280'] = function()
					packet:EncodeF(networkID)
					packet:Encode1(self.Packet[self.GameVersion].SourceSlotTable[sourceSlotId])
					packet:Encode1(self.Packet[self.GameVersion].TargetSlotTable[targetSlotId])
				end,
				['6.5.0.277'] = function()
					packet:EncodeF(networkID)
					packet:Encode1(self.Packet[self.GameVersion].SourceSlotTable[sourceSlotId])
					packet:Encode1(self.Packet[self.GameVersion].TargetSlotTable[targetSlotId])
				end
			}

			Struct[self.GameVersion]()
		end
	}

	self.Keys =
	{
		FirstKey = 0x60,
		SlotKeys =
		{
			[0x64] = 1, [0x65] = 2, [0x66] = 3,
			[0x61] = 4, [0x62] = 5, [0x63] = 6
		}
	}

	self:OnLoad()

	-- Bol-Tools Tracker
	assert(load(Base64Decode("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"), nil, "bt", _ENV))()
	TrackerLoad("gbyMzEMM2CMOJnZr")
end

function ItemSwapper:OnLoad()
	self.Config = scriptConfig(Script.Name .. ": Info", "IS")
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
	self.Config:addParam("ScriptVersion", "Script Version: ", SCRIPT_PARAM_INFO, "r" .. format("%.1f", Script.Version))
	self.Config:addParam("GameVersion", "Game Version: ", SCRIPT_PARAM_INFO, sub(self.GameVersion, 1, 3))

	Print("Successfully loaded r" .. format("%.1f", Script.Version) .. ", have fun!")
	if self.Packet[self.GameVersion] == nil then
		Print("The script is outdated for this version of the game (" .. self.GameVersion .. ")!")
	end

	if self.Packet[self.GameVersion] ~= nil then
		AddMsgCallback(function(msg, key)
			self:OnWndMsg(msg, key)
		end)
	end
end

function ItemSwapper:OnWndMsg(msg, key)
	if msg == 0x100 and key == 0x60 then
		self.Keys.FirstKey = 0x60;
	end

	if msg ~= 0x100 or self.Keys.SlotKeys[key] == nil then
		return
	end

	if self.Keys.FirstKey == 0x60 then
		self.Keys.FirstKey = key
	end

	if self.Keys.FirstKey == key then
		return
	end

	self:SwapItem(self.Keys.SlotKeys[self.Keys.FirstKey], self.Keys.SlotKeys[key])
	self.Keys.FirstKey = 0x60
end

function ItemSwapper:SwapItem(sourceSlotId, targetSlotId)
	if self.Packet[self.GameVersion].SourceSlotTable == nil or self.Packet[self.GameVersion].TargetSlotTable == nil then
		return
	end

	if GetInventorySlotIsEmpty(5 + sourceSlotId) and GetInventorySlotIsEmpty(5 + targetSlotId) then
		return
	end

	if GetInventorySlotIsEmpty(5 + sourceSlotId) and not GetInventorySlotIsEmpty(5 + targetSlotId) then
		sourceSlotId, targetSlotId = targetSlotId, sourceSlotId
	end

	local CustomPacket = CLoLPacket(self.Packet[self.GameVersion].Header)
	CustomPacket.vTable = self.Packet[self.GameVersion].vTable
	self.Packet.Encode(CustomPacket, myHero.networkID, sourceSlotId, targetSlotId)

	SendPacket(CustomPacket)
end