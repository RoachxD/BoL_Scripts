--[[


		 .d8b.  db    db d888888b  .d88b.       db       .d8b.  d8b   db d888888b d88888b d8888b. d8b   db
		d8' `8b 88    88 `~~88~~' .8P  Y8.      88      d8' `8b 888o  88 `~~88~~' 88'     88  `8D 888o  88
		88ooo88 88    88    88    88    88      88      88ooo88 88V8o 88    88    88ooooo 88oobY' 88V8o 88
		88~~~88 88    88    88    88    88      88      88~~~88 88 V8o88    88    88~~~~~ 88`8b   88 V8o88
		88   88 88b  d88    88    `8b  d8'      88booo. 88   88 88  V888    88    88.     88 `88. 88  V888
		YP   YP ~Y8888P'    YP     `Y88P'       Y88888P YP   YP VP   V8P    YP    Y88888P 88   YD VP   V8P


	Auto Lantern - Grab the lantern with ease!

	Changelog:
		July 04, 2016 [r3.0]:
			- Updated for 6.13.

		June 21, 2016 [r2.9]:
			- Updated for 6.12.

		June 08, 2016 [r2.8]:
			- Completed the Data Tables.

		June 03, 2016 [r2.7]:
			- Updated for 6.11.

		May 19, 2016 [r2.6]:
			- Updated for 6.10.

		May 04, 2016 [r2.5]:
			- Updated for 6.9.

		April 23, 2016 [r2.4]:
			- Updated for 6.8 Mini-Patch.

		April 20, 2016 [r2.3]:
			- Updated for 6.8.
			- Updated BoL-Tracker's code.

		April 19, 2016 [r2.2]:
			- Fixed some FPS Dropping problems.

		April 16, 2016 [r2.1]:
			- Fixed a bug with the Auto-Updater.

		April 16, 2016 [r2.0]:
			- Improved the performance of the Script.

		April 08, 2016 [r1.9]:
			- Updated for 6.7HF.
			- Modified the menu.

		April 06, 2016 [r1.8]:
			- Updated for 6.7.
			- Created a check so the script won't load if you are Thresh.

		April 01, 2016 [r1.7]:
			- Updated for 6.6HF.

		March 28, 2016 [r1.6]:
			- Removed Debug Prints.

		March 28, 2016 [r1.5]:
			- Fixed the Data Tables, no more usage of IndexOf Function.

		March 28, 2016 [r1.4]:
			- Fixed the bug, now it should work!
	
		March 28, 2016 [r1.3]:
			- Added Bol-Tools Tracker.

		March 28, 2016 [r1.2]:
			- Removed OnDeleteObj Callback as it was useless.

		March 28, 2016 [r1.1]:
			- Added a check to see if Thresh is part of your team, so the script won't load if he isn't.
			- Improved a bit the menu.

		March 28, 2016 [r1.0]:
			- First Release.
]]--

local Script =
{
	Name = "Auto Lantern",
	Version = 3.0
}

local function Print(string)
	print("<font color=\"#3C8430\">" .. Script.Name .. ":</font> <font color=\"#DE540B\">" .. string .. "</font>")
end

if not VIP_USER then
	Print("Sorry, this script is VIP Only!")
	return
end

class "ALUpdater"
local random, round = math.random, math.round
function ALUpdater:__init(LocalVersion, Host, Path, LocalPath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion, CallbackError)
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

function ALUpdater:OnDraw()
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
		BackgroundColor = 0xFF3C8430,
		ForegroundColor = 0xFFDE540B
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

function ALUpdater:CreateSocket(url)
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
function ALUpdater:Base64Encode(data)
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
function ALUpdater:GetOnlineVersion()
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

function ALUpdater:DownloadUpdate()
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
			AutoLantern()
		end,
		CallbackNewVersion = function(version)
			Print("New release found (r" .. format("%.1f", version) .. "), please wait until it's downloaded!")
		end,
		CallbackError = function(version)
			Print("Download failed, please try again!")
			Print("If the problem persists please contact script's author!")
			AutoLantern()
		end
	}
	
	ALUpdater(UpdaterInfo.Version, UpdaterInfo.Host, UpdaterInfo.Path, UpdaterInfo.LocalPath, UpdaterInfo.CallbackUpdate, UpdaterInfo.CallbackNoUpdate, UpdaterInfo.CallbackNewVersion, UpdaterInfo.CallbackError)
end)

class "AutoLantern"
function AutoLantern:__init()
	self.GameVersion = GetGameVersion():split(' ')[1]
	self.Packet =
	{
		['6.13.148.7588'] =
		{
			Header = 0x12A,
			vTable = 0x102268C,
			DataTable =
			{
				[0x4A] = 0x00, [0xC3] = 0xF9, [0x35] = 0xFB, [0x42] = 0xFD, [0xA3] = 0xFF, [0xDF] = 0x55, [0x25] = 0xFC, [0x1D] = 0xFA,
				[0xC5] = 0xF8, [0xD9] = 0xF7, [0x63] = 0xF6, [0xD3] = 0x2E, [0x4C] = 0xF4, [0xCE] = 0x2F, [0x99] = 0xF2, [0x72] = 0x37,
				[0x83] = 0xF0, [0x48] = 0xEF, [0xB9] = 0x41, [0x2F] = 0xED, [0x13] = 0xEC, [0xAB] = 0xEB, [0x3F] = 0xEA, [0x8C] = 0xE9,
				[0x2C] = 0xE8, [0x64] = 0xE7, [0x24] = 0xE6, [0x01] = 0xB6, [0xF8] = 0xE4, [0x2B] = 0x53, [0xB4] = 0xE2, [0x84] = 0xB8,
				[0xE3] = 0xE0, [0x70] = 0x52, [0x30] = 0xDE, [0x8E] = 0xBA, [0x6D] = 0xDC, [0x54] = 0x51, [0xA2] = 0xDA, [0x14] = 0xBC,
				[0xE4] = 0xD8, [0x76] = 0x4F, [0x22] = 0xD6, [0x73] = 0xBE, [0xB2] = 0xD4, [0x55] = 0x4E, [0xDE] = 0xD2, [0x23] = 0xC0,
				[0xD2] = 0xD0, [0xE2] = 0xCF, [0x80] = 0x4D, [0xCF] = 0xCD, [0xDB] = 0xCC, [0x06] = 0xCB, [0xCB] = 0xCA, [0x8D] = 0xC9,
				[0x8A] = 0xC8, [0x28] = 0xC7, [0xCC] = 0xC6, [0xA5] = 0x4B, [0xAD] = 0xC4, [0x60] = 0x4C, [0xF5] = 0xC2, [0x3D] = 0x01,
				[0x81] = 0x02, [0xDD] = 0x04, [0x0E] = 0x08, [0x9F] = 0x10, [0xF9] = 0x20, [0xEE] = 0x40, [0x88] = 0x21, [0x7A] = 0x11,
				[0xE5] = 0x22, [0x2D] = 0x44, [0x4B] = 0x23, [0x34] = 0x46, [0xC1] = 0x47, [0xB5] = 0x8E, [0x7C] = 0x91, [0x9E] = 0x93,
				[0xD5] = 0x95, [0x5F] = 0x97, [0x66] = 0x99, [0x32] = 0x9B, [0x3C] = 0x9D, [0x74] = 0x9F, [0x41] = 0xA1, [0x8F] = 0xA3,
				[0xFE] = 0xA5, [0xAA] = 0x0B, [0x93] = 0x16, [0x6A] = 0x2C, [0xBA] = 0x58, [0x05] = 0x2D, [0xD7] = 0x17, [0xF1] = 0x03,
				[0x52] = 0x06, [0xE8] = 0x0C, [0x2E] = 0x18, [0x57] = 0x30, [0x39] = 0x60, [0x7E] = 0x31, [0xFA] = 0x19, [0x7D] = 0x32,
				[0x50] = 0x64, [0xA4] = 0x33, [0xEA] = 0x66, [0x26] = 0x67, [0xC2] = 0xCE, [0x4E] = 0xD1, [0x38] = 0xD3, [0xC9] = 0xD5,
				[0x00] = 0xD7, [0xF0] = 0xD9, [0x27] = 0xDB, [0x82] = 0xDD, [0x1B] = 0xDF, [0x0D] = 0xE1, [0x29] = 0xE3, [0x61] = 0xE5,
				[0xC6] = 0x0F, [0xE6] = 0x1E, [0xFB] = 0x3C, [0x58] = 0x78, [0x9D] = 0x3D, [0x0B] = 0x1F, [0x96] = 0x3E, [0xA0] = 0x7C,
				[0x09] = 0x3F, [0xB3] = 0x7E, [0x53] = 0x7F, [0xAC] = 0xFE, [0x37] = 0xB4, [0xD6] = 0x59, [0x5B] = 0xB2, [0xB0] = 0x5A,
				[0x40] = 0xB0, [0x17] = 0xAF, [0x49] = 0x5B, [0xBB] = 0xAD, [0xCD] = 0xAC, [0x12] = 0xAB, [0xEF] = 0xAA, [0x2A] = 0xA9,
				[0x0A] = 0xA8, [0x86] = 0xA7, [0x71] = 0xA6, [0x11] = 0xA4, [0x08] = 0xA2, [0x5E] = 0xA0, [0xF3] = 0x9E, [0x31] = 0x9C,
				[0x9A] = 0x9A, [0x10] = 0x98, [0x8B] = 0x96, [0x04] = 0x94, [0x67] = 0x92, [0xCA] = 0x90, [0x16] = 0x8F, [0x3A] = 0x8D,
				[0x4D] = 0x8C, [0x36] = 0x8B, [0x78] = 0x8A, [0x6B] = 0x89, [0xA7] = 0x88, [0xF6] = 0x87, [0xC4] = 0x86, [0xE0] = 0x5C,
				[0x92] = 0x84, [0x20] = 0x5D, [0x02] = 0x82, [0xF4] = 0x5E, [0xEC] = 0x80, [0x51] = 0x7D, [0x6F] = 0x7B, [0xF2] = 0x7A,
				[0xB7] = 0x79, [0x0F] = 0x42, [0x15] = 0x43, [0x6E] = 0x75, [0xF7] = 0x45, [0x77] = 0x73, [0x21] = 0x72, [0xC8] = 0x71,
				[0xE1] = 0x49, [0x9C] = 0x6F, [0x4F] = 0x6E, [0x69] = 0x6D, [0xFF] = 0x6C, [0x3B] = 0x6B, [0x97] = 0x6A, [0x6C] = 0x69,
				[0x89] = 0x4A, [0x85] = 0x65, [0x62] = 0x63, [0x46] = 0x62, [0x90] = 0x61, [0x9B] = 0x5F, [0x1C] = 0x81, [0x43] = 0x83,
				[0x19] = 0x85, [0x1A] = 0x09, [0x7B] = 0x12, [0xBC] = 0x24, [0x33] = 0x48, [0xC0] = 0x25, [0xD8] = 0x13, [0xDA] = 0x26,
				[0x1E] = 0x05, [0x03] = 0x0A, [0x98] = 0x14, [0x65] = 0x28, [0x75] = 0x50, [0xE9] = 0x29, [0xDC] = 0x15, [0xA8] = 0x2A,
				[0xED] = 0x54, [0x7F] = 0x2B, [0xE7] = 0x56, [0xA1] = 0x57, [0x68] = 0xAE, [0xEB] = 0xB1, [0xC7] = 0xB3, [0xBD] = 0xB5,
				[0xAE] = 0xB7, [0x91] = 0xB9, [0x18] = 0xBB, [0xA6] = 0xBD, [0x45] = 0xBF, [0x95] = 0xC1, [0xBF] = 0xC3, [0xFD] = 0xC5,
				[0x5D] = 0x0D, [0xB6] = 0x1A, [0x87] = 0x34, [0x1F] = 0x68, [0xBE] = 0x35, [0x5A] = 0x1B, [0x44] = 0x36, [0xB1] = 0x07,
				[0x59] = 0x0E, [0xB8] = 0x1C, [0x47] = 0x38, [0x94] = 0x70, [0x79] = 0x39, [0x5C] = 0x1D, [0xD0] = 0x3A, [0x0C] = 0x74,
				[0x56] = 0x3B, [0x3E] = 0x76, [0xFC] = 0x77, [0xAF] = 0xEE, [0xA9] = 0xF1, [0x07] = 0xF3, [0xD4] = 0xF5, [0xD1] = 0x27,
			}
		},
		['6.12.147.611'] =
		{
			Header = 0x17,
			vTable = 0x1015B74,
			DataTable =
			{
				[0x4A] = 0x00, [0xC3] = 0xF9, [0x35] = 0xFB, [0x42] = 0xFD, [0xA3] = 0xFF, [0xDF] = 0x55, [0x25] = 0xFC, [0x1D] = 0xFA,
				[0xC5] = 0xF8, [0xD9] = 0xF7, [0x63] = 0xF6, [0xD3] = 0x2E, [0x4C] = 0xF4, [0xCE] = 0x2F, [0x99] = 0xF2, [0x72] = 0x37,
				[0x83] = 0xF0, [0x48] = 0xEF, [0xB9] = 0x41, [0x2F] = 0xED, [0x13] = 0xEC, [0xAB] = 0xEB, [0x3F] = 0xEA, [0x8C] = 0xE9,
				[0x2C] = 0xE8, [0x64] = 0xE7, [0x24] = 0xE6, [0x01] = 0xB6, [0xF8] = 0xE4, [0x2B] = 0x53, [0xB4] = 0xE2, [0x84] = 0xB8,
				[0xE3] = 0xE0, [0x70] = 0x52, [0x30] = 0xDE, [0x8E] = 0xBA, [0x6D] = 0xDC, [0x54] = 0x51, [0xA2] = 0xDA, [0x14] = 0xBC,
				[0xE4] = 0xD8, [0x76] = 0x4F, [0x22] = 0xD6, [0x73] = 0xBE, [0xB2] = 0xD4, [0x55] = 0x4E, [0xDE] = 0xD2, [0x23] = 0xC0,
				[0xD2] = 0xD0, [0xE2] = 0xCF, [0x80] = 0x4D, [0xCF] = 0xCD, [0xDB] = 0xCC, [0x06] = 0xCB, [0xCB] = 0xCA, [0x8D] = 0xC9,
				[0x8A] = 0xC8, [0x28] = 0xC7, [0xCC] = 0xC6, [0xA5] = 0x4B, [0xAD] = 0xC4, [0x60] = 0x4C, [0xF5] = 0xC2, [0x3D] = 0x01,
				[0x81] = 0x02, [0xDD] = 0x04, [0x0E] = 0x08, [0x9F] = 0x10, [0xF9] = 0x20, [0xEE] = 0x40, [0x88] = 0x21, [0x7A] = 0x11,
				[0xE5] = 0x22, [0x2D] = 0x44, [0x4B] = 0x23, [0x34] = 0x46, [0xC1] = 0x47, [0xB5] = 0x8E, [0x7C] = 0x91, [0x9E] = 0x93,
				[0xD5] = 0x95, [0x5F] = 0x97, [0x66] = 0x99, [0x32] = 0x9B, [0x3C] = 0x9D, [0x74] = 0x9F, [0x41] = 0xA1, [0x8F] = 0xA3,
				[0xFE] = 0xA5, [0xAA] = 0x0B, [0x93] = 0x16, [0x6A] = 0x2C, [0xBA] = 0x58, [0x05] = 0x2D, [0xD7] = 0x17, [0xF1] = 0x03,
				[0x52] = 0x06, [0xE8] = 0x0C, [0x2E] = 0x18, [0x57] = 0x30, [0x39] = 0x60, [0x7E] = 0x31, [0xFA] = 0x19, [0x7D] = 0x32,
				[0x50] = 0x64, [0xA4] = 0x33, [0xEA] = 0x66, [0x26] = 0x67, [0xC2] = 0xCE, [0x4E] = 0xD1, [0x38] = 0xD3, [0xC9] = 0xD5,
				[0x00] = 0xD7, [0xF0] = 0xD9, [0x27] = 0xDB, [0x82] = 0xDD, [0x1B] = 0xDF, [0x0D] = 0xE1, [0x29] = 0xE3, [0x61] = 0xE5,
				[0xC6] = 0x0F, [0xE6] = 0x1E, [0xFB] = 0x3C, [0x58] = 0x78, [0x9D] = 0x3D, [0x0B] = 0x1F, [0x96] = 0x3E, [0xA0] = 0x7C,
				[0x09] = 0x3F, [0xB3] = 0x7E, [0x53] = 0x7F, [0xAC] = 0xFE, [0x37] = 0xB4, [0xD6] = 0x59, [0x5B] = 0xB2, [0xB0] = 0x5A,
				[0x40] = 0xB0, [0x17] = 0xAF, [0x49] = 0x5B, [0xBB] = 0xAD, [0xCD] = 0xAC, [0x12] = 0xAB, [0xEF] = 0xAA, [0x2A] = 0xA9,
				[0x0A] = 0xA8, [0x86] = 0xA7, [0x71] = 0xA6, [0x11] = 0xA4, [0x08] = 0xA2, [0x5E] = 0xA0, [0xF3] = 0x9E, [0x31] = 0x9C,
				[0x9A] = 0x9A, [0x10] = 0x98, [0x8B] = 0x96, [0x04] = 0x94, [0x67] = 0x92, [0xCA] = 0x90, [0x16] = 0x8F, [0x3A] = 0x8D,
				[0x4D] = 0x8C, [0x36] = 0x8B, [0x78] = 0x8A, [0x6B] = 0x89, [0xA7] = 0x88, [0xF6] = 0x87, [0xC4] = 0x86, [0xE0] = 0x5C,
				[0x92] = 0x84, [0x20] = 0x5D, [0x02] = 0x82, [0xF4] = 0x5E, [0xEC] = 0x80, [0x51] = 0x7D, [0x6F] = 0x7B, [0xF2] = 0x7A,
				[0xB7] = 0x79, [0x0F] = 0x42, [0x15] = 0x43, [0x6E] = 0x75, [0xF7] = 0x45, [0x77] = 0x73, [0x21] = 0x72, [0xC8] = 0x71,
				[0xE1] = 0x49, [0x9C] = 0x6F, [0x4F] = 0x6E, [0x69] = 0x6D, [0xFF] = 0x6C, [0x3B] = 0x6B, [0x97] = 0x6A, [0x6C] = 0x69,
				[0x89] = 0x4A, [0x85] = 0x65, [0x62] = 0x63, [0x46] = 0x62, [0x90] = 0x61, [0x9B] = 0x5F, [0x1C] = 0x81, [0x43] = 0x83,
				[0x19] = 0x85, [0x1A] = 0x09, [0x7B] = 0x12, [0xBC] = 0x24, [0x33] = 0x48, [0xC0] = 0x25, [0xD8] = 0x13, [0xDA] = 0x26,
				[0x1E] = 0x05, [0x03] = 0x0A, [0x98] = 0x14, [0x65] = 0x28, [0x75] = 0x50, [0xE9] = 0x29, [0xDC] = 0x15, [0xA8] = 0x2A,
				[0xED] = 0x54, [0x7F] = 0x2B, [0xE7] = 0x56, [0xA1] = 0x57, [0x68] = 0xAE, [0xEB] = 0xB1, [0xC7] = 0xB3, [0xBD] = 0xB5,
				[0xAE] = 0xB7, [0x91] = 0xB9, [0x18] = 0xBB, [0xA6] = 0xBD, [0x45] = 0xBF, [0x95] = 0xC1, [0xBF] = 0xC3, [0xFD] = 0xC5,
				[0x5D] = 0x0D, [0xB6] = 0x1A, [0x87] = 0x34, [0x1F] = 0x68, [0xBE] = 0x35, [0x5A] = 0x1B, [0x44] = 0x36, [0xB1] = 0x07,
				[0x59] = 0x0E, [0xB8] = 0x1C, [0x47] = 0x38, [0x94] = 0x70, [0x79] = 0x39, [0x5C] = 0x1D, [0xD0] = 0x3A, [0x0C] = 0x74,
				[0x56] = 0x3B, [0x3E] = 0x76, [0xFC] = 0x77, [0xAF] = 0xEE, [0xA9] = 0xF1, [0x07] = 0xF3, [0xD4] = 0xF5, [0xD1] = 0x27,
			}
		},
		['6.11.145.3450'] =
		{
			Header = 0x111,
			vTable = 0xF13530,
			DataTable =
			{
				[0x01] = 0xF1, [0x02] = 0x31, [0x03] = 0xB1, [0x04] = 0x7A, [0x05] = 0xFA, [0x06] = 0x3A, [0x07] = 0xBA, [0x08] = 0x78,
				[0x09] = 0xF8, [0x0A] = 0x38, [0x0B] = 0xB8, [0x0C] = 0x7B, [0x0D] = 0xFB, [0x0E] = 0x3B, [0x0F] = 0xBB, [0x10] = 0x79,
				[0x11] = 0xF9, [0x12] = 0x39, [0x13] = 0xB9, [0x14] = 0x76, [0x15] = 0xF6, [0x16] = 0x36, [0x17] = 0xB6, [0x18] = 0x74,
				[0x19] = 0xF4, [0x1A] = 0x34, [0x1B] = 0xB4, [0x1C] = 0x77, [0x1D] = 0xF7, [0x1E] = 0x37, [0x1F] = 0xB7, [0x20] = 0x75,
				[0x21] = 0xF5, [0x22] = 0x35, [0x23] = 0xB5, [0x24] = 0x7E, [0x25] = 0xFE, [0x26] = 0x3E, [0x27] = 0xBE, [0x28] = 0x7C,
				[0x29] = 0xFC, [0x2A] = 0x3C, [0x2B] = 0xBC, [0x2C] = 0x7F, [0x2D] = 0xFF, [0x2E] = 0x3F, [0x2F] = 0xBF, [0x30] = 0x7D,
				[0x31] = 0xFD, [0x32] = 0x3D, [0x33] = 0xBD, [0x34] = 0x72, [0x35] = 0xF2, [0x36] = 0x32, [0x37] = 0xB2, [0x38] = 0x70,
				[0x39] = 0xF0, [0x3A] = 0x30, [0x3B] = 0xB0, [0x3C] = 0x73, [0x3D] = 0xF3, [0x3E] = 0x33, [0x3F] = 0xB3, [0x40] = 0x51,
				[0x41] = 0xD1, [0x42] = 0x11, [0x43] = 0x91, [0x44] = 0x5A, [0x45] = 0xDA, [0x46] = 0x1A, [0x47] = 0x9A, [0x48] = 0x58,
				[0x49] = 0xD8, [0x4A] = 0x18, [0x4B] = 0x98, [0x4C] = 0x5B, [0x4D] = 0xDB, [0x4E] = 0x1B, [0x4F] = 0x9B, [0x50] = 0x59,
				[0x51] = 0xD9, [0x52] = 0x19, [0x53] = 0x99, [0x54] = 0x56, [0x55] = 0xD6, [0x56] = 0x16, [0x57] = 0x96, [0x58] = 0x54,
				[0x59] = 0xD4, [0x5A] = 0x14, [0x5B] = 0x94, [0x5C] = 0x57, [0x5D] = 0xD7, [0x5E] = 0x17, [0x5F] = 0x97, [0x60] = 0x55,
				[0x61] = 0xD5, [0x62] = 0x15, [0x63] = 0x95, [0x64] = 0x5E, [0x65] = 0xDE, [0x66] = 0x1E, [0x67] = 0x9E, [0x68] = 0x5C,
				[0x69] = 0xDC, [0x6A] = 0x1C, [0x6B] = 0x9C, [0x6C] = 0x5F, [0x6D] = 0xDF, [0x6E] = 0x1F, [0x6F] = 0x9F, [0x70] = 0x5D,
				[0x71] = 0xDD, [0x72] = 0x1D, [0x73] = 0x9D, [0x74] = 0x52, [0x75] = 0xD2, [0x76] = 0x12, [0x77] = 0x92, [0x78] = 0x50,
				[0x79] = 0xD0, [0x7A] = 0x10, [0x7B] = 0x90, [0x7C] = 0x53, [0x7D] = 0xD3, [0x7E] = 0x13, [0x7F] = 0x93, [0x80] = 0x61,
				[0x81] = 0xE1, [0x82] = 0x21, [0x83] = 0xA1, [0x84] = 0x6A, [0x85] = 0xEA, [0x86] = 0x2A, [0x87] = 0xAA, [0x88] = 0x68,
				[0x89] = 0xE8, [0x8A] = 0x28, [0x8B] = 0xA8, [0x8C] = 0x6B, [0x8D] = 0xEB, [0x8E] = 0x2B, [0x8F] = 0xAB, [0x90] = 0x69,
				[0x91] = 0xE9, [0x92] = 0x29, [0x93] = 0xA9, [0x94] = 0x66, [0x95] = 0xE6, [0x96] = 0x26, [0x97] = 0xA6, [0x98] = 0x64,
				[0x99] = 0xE4, [0x9A] = 0x24, [0x9B] = 0xA4, [0x9C] = 0x67, [0x9D] = 0xE7, [0x9E] = 0x27, [0x9F] = 0xA7, [0xA0] = 0x65,
				[0xA1] = 0xE5, [0xA2] = 0x25, [0xA3] = 0xA5, [0xA4] = 0x6E, [0xA5] = 0xEE, [0xA6] = 0x2E, [0xA7] = 0xAE, [0xA8] = 0x6C,
				[0xA9] = 0xEC, [0xAA] = 0x2C, [0xAB] = 0xAC, [0xAC] = 0x6F, [0xAD] = 0xEF, [0xAE] = 0x2F, [0xAF] = 0xAF, [0xB0] = 0x6D,
				[0xB1] = 0xED, [0xB2] = 0x2D, [0xB3] = 0xAD, [0xB4] = 0x62, [0xB5] = 0xE2, [0xB6] = 0x22, [0xB7] = 0xA2, [0xB8] = 0x60,
				[0xB9] = 0xE0, [0xBA] = 0x20, [0xBB] = 0xA0, [0xBC] = 0x63, [0xBD] = 0xE3, [0xBE] = 0x23, [0xBF] = 0xA3, [0xC0] = 0x41,
				[0xC1] = 0xC1, [0xC2] = 0x01, [0xC3] = 0x81, [0xC4] = 0x4A, [0xC5] = 0xCA, [0xC6] = 0x0A, [0xC7] = 0x8A, [0xC8] = 0x48,
				[0xC9] = 0xC8, [0xCA] = 0x08, [0xCB] = 0x88, [0xCC] = 0x4B, [0xCD] = 0xCB, [0xCE] = 0x0B, [0xCF] = 0x8B, [0xD0] = 0x49,
				[0xD1] = 0xC9, [0xD2] = 0x09, [0xD3] = 0x89, [0xD4] = 0x46, [0xD5] = 0xC6, [0xD6] = 0x06, [0xD7] = 0x86, [0xD8] = 0x44,
				[0xD9] = 0xC4, [0xDA] = 0x04, [0xDB] = 0x84, [0xDC] = 0x47, [0xDD] = 0xC7, [0xDE] = 0x07, [0xDF] = 0x87, [0xE0] = 0x45,
				[0xE1] = 0xC5, [0xE2] = 0x05, [0xE3] = 0x85, [0xE4] = 0x4E, [0xE5] = 0xCE, [0xE6] = 0x0E, [0xE7] = 0x8E, [0xE8] = 0x4C,
				[0xE9] = 0xCC, [0xEA] = 0x0C, [0xEB] = 0x8C, [0xEC] = 0x4F, [0xED] = 0xCF, [0xEE] = 0x0F, [0xEF] = 0x8F, [0xF0] = 0x4D,
				[0xF1] = 0xCD, [0xF2] = 0x0D, [0xF3] = 0x8D, [0xF4] = 0x42, [0xF5] = 0xC2, [0xF6] = 0x02, [0xF7] = 0x82, [0xF8] = 0x40,
				[0xF9] = 0xC0, [0xFA] = 0x00, [0xFB] = 0x80, [0xFC] = 0x43, [0xFD] = 0xC3, [0xFE] = 0x03, [0xFF] = 0x83, [0x00] = 0x71
			}
		}
	}

	self.LanternObject = nil
	self.LanternTick = 0
	for _, Hero in pairs(GetAllyHeroes()) do
		if Hero.charName == "Thresh" then
			self.ThreshFound = true
			break
		else
			self.ThreshFound = false
		end
	end

	self:OnLoad()

	-- Bol-Tools Tracker
	assert(load(Base64Decode("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"), nil, "bt", _ENV))()
	TrackerLoad("DRRkJTi7o3TfeaNv")
end

function AutoLantern:OnLoad()
	if self.ThreshFound and myHero.charName ~= "Thresh" then
		self.Config = scriptConfig(Script.Name, "AL")
		self.Config:addSubMenu("General Settings", "GeneralSettings")
		self.Config.GeneralSettings:addParam("Percentage", "Percentage:", SCRIPT_PARAM_SLICE, 20, 10, 90, 0)
		self.Config.GeneralSettings:addParam("LowHP", "Enable", SCRIPT_PARAM_ONOFF, true)
		self.Config:addParam("OnTap", "Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('T'))
		self.Config:addParam("ScriptVersion", "Script Version: ", SCRIPT_PARAM_INFO, "r" .. format("%.1f", Script.Version))
		self.Config:addParam("GameVersion", "Game Version: ", SCRIPT_PARAM_INFO, sub(self.GameVersion, 1, 3))

		AddProcessSpellCallback(function(unit, spell)
			self:OnProcessSpell(unit, spell)
		end)

		AddCreateObjCallback(function(object)
			self:OnCreateObj(object)
		end)

		AddTickCallback(function()
			self:OnTick()
		end)
	end

	Print("Successfully loaded r" .. format("%.1f", Script.Version) .. ", have fun!")
	if not self.ThreshFound or myHero.charName == "Thresh" then
		Print((myHero.charName ~= "Thresh") and "Thresh not found in your team, the script will unload!" or "The script detected that you are Thresh, it will unload!")
	end

	if self.Packet[self.GameVersion] == nil then
		Print("The script is outdated for this version of the game (" .. self.GameVersion .. ")!")
	end
end

local clock = os.clock
function AutoLantern:OnProcessSpell(unit, spell)
	if unit ~= myHero or spell.name ~= "LanternWAlly" then
		return
	end

	self.LanternTick = clock()
end

function AutoLantern:OnCreateObj(object)
	if object.name ~= "ThreshLantern" or object.team ~= myHero.team then
		return
	end

	self.LanternObject = object
end

function AutoLantern:OnTick()
	if self.LanternObject == nil then
		return
	end

	local HPPercentage = (myHero.health / myHero.maxHealth) * 100
	if (self.Config.GeneralSettings.LowHP and self.Config.GeneralSettings.Percentage >= HPPercentage) or self.Config.OnTap then
		local TickCalc = clock() - self.LanternTick
		if TickCalc < 5 then
			return
		end

		self:GrabLantern(self.LanternObject)
	end
end

function AutoLantern:GrabLantern(object)
	if object == nil or object.name ~= "ThreshLantern" or object.team ~= myHero.team or GetDistanceSqr(object) > 250000 then
		return
	end

	local CustomPacket = CLoLPacket(self.Packet[self.GameVersion].Header)
	CustomPacket.vTable = self.Packet[self.GameVersion].vTable
	CustomPacket:EncodeF(myHero.networkID)
	CustomPacket:EncodeF(object.networkID)
	CustomPacket.pos = CustomPacket.pos - 4
	for i = 1, 4 do
		local temp = CustomPacket:Decode1()
		CustomPacket.pos = CustomPacket.pos - 1
		CustomPacket:Encode1(self.Packet[self.GameVersion].DataTable[temp])
		CustomPacket.pos = CustomPacket.pos - 4 + i
	end

	SendPacket(CustomPacket)
end