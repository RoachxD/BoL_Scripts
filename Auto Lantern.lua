--[[


		 .d8b.  db    db d888888b  .d88b.       db       .d8b.  d8b   db d888888b d88888b d8888b. d8b   db
		d8' `8b 88    88 `~~88~~' .8P  Y8.      88      d8' `8b 888o  88 `~~88~~' 88'     88  `8D 888o  88
		88ooo88 88    88    88    88    88      88      88ooo88 88V8o 88    88    88ooooo 88oobY' 88V8o 88
		88~~~88 88    88    88    88    88      88      88~~~88 88 V8o88    88    88~~~~~ 88`8b   88 V8o88
		88   88 88b  d88    88    `8b  d8'      88booo. 88   88 88  V888    88    88.     88 `88. 88  V888
		YP   YP ~Y8888P'    YP     `Y88P'       Y88888P YP   YP VP   V8P    YP    Y88888P 88   YD VP   V8P


	Auto Lantern - Grab the lantern with ease!

	Changelog:
		March 28, 2016 [r1.0]:
			- First Release.

]]--

local Script =
{
	Name = "Auto Lantern",
	Version = 1.0
}

local function Print(string)
	print("<font color=\"#3C8430\">" .. Script.Name .. ":</font> <font color=\"#DE540B\">" .. string .. "</font>")
end

if not VIP_USER then
	Print("Sorry, this script is VIP Only!")
	return
end

class "ALUpdater"
function ALUpdater:__init(LocalVersion, Host, Path, LocalPath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion, CallbackError)
	self.LocalVersion = LocalVersion
	self.Host = Host
	self.VersionPath = '/BoL/TCPUpdater/GetScript5.php?script=' .. self:Base64Encode(self.Host .. Path .. '.ver') .. '&rand=' .. math.random(99999999)
	self.ScriptPath = '/BoL/TCPUpdater/GetScript5.php?script=' .. self:Base64Encode(self.Host .. Path .. '.lua') .. '&rand=' .. math.random(99999999)
	self.LocalPath = LocalPath
	self.CallbackUpdate = CallbackUpdate
	self.CallbackNoUpdate = CallbackNoUpdate
	self.CallbackNewVersion = CallbackNewVersion
	self.CallbackError = CallbackError
	
	self.OffsetY = _G.OffsetY and _G.OffsetY or 0
	_G.OffsetY = _G.OffsetY and _G.OffsetY + math.round(0.08333333333 * WINDOW_H) or math.round(0.08333333333 * WINDOW_H)
	
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
		X = math.round(0.91 * WINDOW_W),
		Y = math.round(0.73 * WINDOW_H) - self.OffsetY,
		Height = math.round(0.01666666666 * WINDOW_H),
		Width = math.round(0.171875 * WINDOW_W),
		Border = 1,
		HeaderFontSize = math.round(0.01666666666 * WINDOW_H),
		ProgressFontSize = math.round(0.01125 * WINDOW_H),
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

function ALUpdater:Base64Encode(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return ((data:gsub('.', function(x)
		local r, b = '', x:byte()
		for i = 8, 1, -1 do
			r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
		end
		
		return r;
	end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then
			return ''
		end
		
		local c = 0
		for i = 1, 6 do
			c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
		end
		
		return b:sub(c + 1, c + 1)
	end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

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
	if self.File:find('</size>') then
		if not self.Size then
			self.Size = tonumber(self.File:sub(self.File:find('<size>') + 6, self.File:find('</size>') - 1))
		end
		
		if self.File:find('<script>') then
			local _,ScriptFind = self.File:find('<script>')
			local ScriptEnd = self.File:find('</script>')
			if ScriptEnd then
				ScriptEnd = ScriptEnd - 1
			end
			
			local DownloadedSize = self.File:sub(ScriptFind + 1, ScriptEnd or -1):len()
			self.Progress = math.round(100 / self.Size * DownloadedSize, 2)
		end
	end
	
	if self.File:find('</script>') then
		local a, b = self.File:find('\r\n\r\n')
		self.File = self.File:sub(a, -1)
		self.NewFile = ''
		for line, content in ipairs(self.File:split('\n')) do
			if content:len() > 5 then
				self.NewFile = self.NewFile .. content
			end
		end
		
		local HeaderEnd, ContentStart = self.File:find('<script>')
		local ContentEnd, _ = self.File:find('</script>')
		if not ContentStart or not ContentEnd then
			if self.CallbackError and type(self.CallbackError) == 'function' then
				self.CallbackError()
			end
		else
			self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1, ContentEnd - 1)))
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
	if self.File:find('</size>') then
		if not self.Size then
			self.Size = tonumber(self.File:sub(self.File:find('<size>') + 6, self.File:find('</size>') - 1))
		end
		
		if self.File:find('<script>') then
			local _, ScriptFind = self.File:find('<script>')
			local ScriptEnd = self.File:find('</script>')
			if ScriptEnd then
				ScriptEnd = ScriptEnd - 1
			end
			
			local DownloadedSize = self.File:sub(ScriptFind + 1, ScriptEnd or -1):len()
			self.Progress = math.round(100 / self.Size * DownloadedSize, 2)
		end
	end
	
	if self.File:find('</script>') then
		local a, b = self.File:find('\r\n\r\n')
		self.File = self.File:sub(a,-1)
		self.NewFile = ''
		for line, content in ipairs(self.File:split('\n')) do
			if content:len() > 5 then
				self.NewFile = self.NewFile .. content
			end
		end
		
		local HeaderEnd, ContentStart = self.NewFile:find('<script>')
		local ContentEnd, _ = self.NewFile:find('</script>')
		if not ContentStart or not ContentEnd then
			if self.CallbackError and type(self.CallbackError) == 'function' then
				self.CallbackError()
			end
		else
			local newf = self.NewFile:sub(ContentStart + 1, ContentEnd - 1)
			local newf = newf:gsub('\r','')
			if newf:len() ~= self.Size then
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

AddLoadCallback(function()
	local UpdaterInfo =
	{
		Version = Script.Version,
		Host = 'raw.githubusercontent.com',
		Path = '/RoachxD/BoL_Scripts/master/' .. Script.Name:gsub(' ', '%%20'),
		LocalPath = SCRIPT_PATH .. '/' .. Script.Name .. '.lua',
		CallbackUpdate = function(newVersion, oldVersion)
			Print("Updated to r" .. string.format("%.1f", newVersion) .. ", please 2xF9 to reload!")
		end,
		CallbackNoUpdate = function(version)
			Print("No updates found!")
			AutoLantern()
		end,
		CallbackNewVersion = function(version)
			Print("New release found (r" .. string.format("%.1f", version) .. "), please wait until it's downloaded!")
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
	self.GameVersion = GetGameVersion():sub(1, 9)
	self.Packet =
	{
		['6.6.137.4'] =
		{
			Header = 0x1E,
			vTable = 0xEA7E78,
			DataTable =
			{
				[0x4F] = 0x01, [0x14] = 0x02, [0x9E] = 0x03, [0x24] = 0x04, [0x50] = 0x05, [0xF6] = 0x06, [0x78] = 0x07, [0x83] = 0x08,
				[0x75] = 0x09, [0xC2] = 0x0A, [0xB9] = 0x0B, [0x6E] = 0x0C, [0x5B] = 0x0D, [0xC8] = 0x0E, [0xBB] = 0x0F, [0x45] = 0x10,
				[0xC9] = 0x11, [0xA1] = 0x12, [0x69] = 0x13, [0x5E] = 0x14, [0xA6] = 0x15, [0x82] = 0x16, [0x9D] = 0x17, [0x17] = 0x18,
				[0x09] = 0x19, [0x65] = 0x1A, [0x55] = 0x1B, [0xFD] = 0x1C, [0xDC] = 0x1D, [0x27] = 0x1E, [0xB2] = 0x1F, [0x36] = 0x20,
				[0x28] = 0x21, [0x71] = 0x22, [0x19] = 0x23, [0xB0] = 0x24, [0x8E] = 0x25, [0x67] = 0x26, [0x53] = 0x27, [0x47] = 0x28,
				[0x1C] = 0x29, [0xF5] = 0x2A, [0xE4] = 0x2B, [0x90] = 0x2C, [0xB7] = 0x2D, [0xFB] = 0x2E, [0x3A] = 0x2F, [0x85] = 0x30,
				[0x66] = 0x31, [0x8F] = 0x32, [0xF4] = 0x33, [0x6C] = 0x34, [0x20] = 0x35, [0xCD] = 0x37, [0xD3] = 0x38, [0xB6] = 0x39,
				[0xC3] = 0x3A, [0xF3] = 0x3B, [0x2B] = 0x3C, [0x8A] = 0x3D, [0xB3] = 0x3E, [0xE0] = 0x3F, [0x60] = 0x40, [0xA8] = 0x41,
				[0x37] = 0x42, [0x1E] = 0x43, [0xBE] = 0x44, [0x5F] = 0x45, [0x29] = 0x46, [0x74] = 0x47, [0x1B] = 0x48, [0xE9] = 0x49,
				[0xB8] = 0x4A, [0xC0] = 0x4B, [0xF2] = 0x4C, [0x3D] = 0x4D, [0x61] = 0x4E, [0xFA] = 0x4F, [0x35] = 0x50, [0x4C] = 0x51,
				[0xEF] = 0x52, [0x2A] = 0x53, [0x3B] = 0x54, [0xFC] = 0x55, [0x04] = 0x56, [0x16] = 0x57, [0xA7] = 0x58, [0x32] = 0x59,
				[0x80] = 0x5A, [0x70] = 0x5B, [0xAA] = 0x5C, [0xD4] = 0x5D, [0x98] = 0x5E, [0xB4] = 0x5F, [0xD2] = 0x60, [0xAC] = 0x61,
				[0xEC] = 0x62, [0x64] = 0x63, [0xE2] = 0x64, [0xD6] = 0x65, [0x15] = 0x66, [0xA2] = 0x67, [0xFF] = 0x68, [0x1D] = 0x69,
				[0x48] = 0x6A, [0x97] = 0x6B, [0x33] = 0x6C, [0x41] = 0x6D, [0x9C] = 0x6E, [0x58] = 0x6F, [0x62] = 0x70, [0x2C] = 0x71,
				[0x0E] = 0x72, [0xD7] = 0x73, [0x46] = 0x74, [0xA4] = 0x75, [0xCA] = 0x76, [0xE7] = 0x77, [0x7C] = 0x78, [0x30] = 0x79,
				[0x1A] = 0x7A, [0x12] = 0x7B, [0xD5] = 0x7C, [0x91] = 0x7D, [0x68] = 0x7E, [0x3C] = 0x7F, [0x9B] = 0x80, [0xF1] = 0x81,
				[0x08] = 0x82, [0x10] = 0x83, [0x6A] = 0x84, [0x52] = 0x85, [0xD0] = 0x86, [0x39] = 0x87, [0x4D] = 0x88, [0xBF] = 0x89,
				[0x73] = 0x8A, [0xC6] = 0x8B, [0xE3] = 0x8C, [0x06] = 0x8D, [0x49] = 0x8E, [0x18] = 0x8F, [0xEB] = 0x90, [0x1F] = 0x91,
				[0x38] = 0x92, [0xDA] = 0x93, [0x3F] = 0x94, [0xDD] = 0x95, [0x84] = 0x96, [0x44] = 0x97, [0xBD] = 0x98, [0x94] = 0x99,
				[0x0A] = 0x9A, [0x9A] = 0x9B, [0x31] = 0x9C, [0x81] = 0x9D, [0x34] = 0x9E, [0xF9] = 0x9F, [0x4E] = 0xA0, [0xBA] = 0xA1,
				[0x13] = 0xA2, [0xAF] = 0xA3, [0x7D] = 0xA4, [0x76] = 0xA5, [0x89] = 0xA6, [0x5A] = 0xA7, [0x3E] = 0xA8, [0x26] = 0xA9,
				[0xBC] = 0xAA, [0x77] = 0xAB, [0x0D] = 0xAC, [0x79] = 0xAD, [0x86] = 0xAE, [0x8B] = 0xAF, [0xC7] = 0xB0, [0x92] = 0xB1,
				[0x72] = 0xB2, [0x22] = 0xB3, [0x2F] = 0xB4, [0x59] = 0xB5, [0xE1] = 0xB6, [0xFE] = 0xB7, [0x88] = 0xB8, [0x8C] = 0xB9,
				[0xD8] = 0xBA, [0xB1] = 0xBB, [0x21] = 0xBC, [0xC5] = 0xBD, [0x51] = 0xBE, [0xC1] = 0xBF, [0xD1] = 0xC0, [0xEA] = 0xC1,
				[0xA5] = 0xC2, [0xA3] = 0xC3, [0x87] = 0xC4, [0x93] = 0xC5, [0x9F] = 0xC6, [0x54] = 0xC7, [0xEE] = 0xC8, [0x99] = 0xC9,
				[0x01] = 0xCA, [0x40] = 0xCB, [0x6D] = 0xCC, [0x96] = 0xCD, [0x23] = 0xCE, [0xC4] = 0xCF, [0xDF] = 0xD0, [0xA0] = 0xD1,
				[0xCB] = 0xD2, [0xCF] = 0xD3, [0xCC] = 0xD4, [0xE6] = 0xD5, [0xF7] = 0xD6, [0x00] = 0xD7, [0xDB] = 0xD8, [0x7B] = 0xD9,
				[0x5D] = 0xDA, [0x7A] = 0xDB, [0x0C] = 0xDC, [0xE5] = 0xDD, [0xCE] = 0xDE, [0xE8] = 0xDF, [0x0B] = 0xE0, [0xAD] = 0xE1,
				[0x6F] = 0xE2, [0x43] = 0xE3, [0x2E] = 0xE4, [0x8D] = 0xE5, [0x5C] = 0xE6, [0xB5] = 0xE7, [0x7E] = 0xE8, [0x4B] = 0xE9,
				[0xAE] = 0xEA, [0x25] = 0xEB, [0x57] = 0xEC, [0x03] = 0xED, [0xAB] = 0xEE, [0x6B] = 0xEF, [0xF0] = 0xF0, [0x56] = 0xF1,
				[0xDE] = 0xF2, [0x11] = 0xF3, [0xED] = 0xF4, [0x7F] = 0xF5, [0x42] = 0xF6, [0xD9] = 0xF7, [0x2D] = 0xF8, [0x0F] = 0xF9,
				[0x95] = 0xFA, [0x02] = 0xFB, [0x05] = 0xFC, [0xA9] = 0xFD, [0x07] = 0xFE, [0x63] = 0xFF, [0xF8] = 0x00
			}
		},
		['6.5.0.280'] =
		{
			Header = 0xC,
			vTable = 0xECFD58,
			DataTable =
			{
				[0x17] = 0x01, [0x42] = 0x02, [0x6D] = 0x03, [0x74] = 0x04, [0xC5] = 0x05, [0x03] = 0x06, [0x07] = 0x07, [0x6F] = 0x08,
				[0xF3] = 0x09, [0xF9] = 0x0A, [0xAF] = 0x0B, [0x30] = 0x0C, [0x29] = 0x0D, [0xA9] = 0x0E, [0xF6] = 0x0F, [0xE3] = 0x10,
				[0xCF] = 0x11, [0x1A] = 0x12, [0x99] = 0x13, [0x84] = 0x14, [0x22] = 0x15, [0xF4] = 0x16, [0xCA] = 0x17, [0x46] = 0x18,
				[0x3B] = 0x19, [0xC2] = 0x1A, [0xAB] = 0x1B, [0x0C] = 0x1C, [0xAE] = 0x1D, [0x1D] = 0x1E, [0x9E] = 0x1F, [0x77] = 0x20,
				[0x2A] = 0x21, [0xEE] = 0x22, [0x8A] = 0x23, [0xFC] = 0x24, [0x90] = 0x25, [0x48] = 0x26, [0x44] = 0x27, [0x9B] = 0x28,
				[0xDD] = 0x29, [0x51] = 0x2A, [0xDA] = 0x2B, [0x27] = 0x2C, [0xD7] = 0x2D, [0xBE] = 0x2E, [0x0B] = 0x2F, [0x2D] = 0x30,
				[0x96] = 0x31, [0x75] = 0x32, [0x9F] = 0x33, [0xA2] = 0x34, [0x8D] = 0x35, [0xBF] = 0x36, [0x5D] = 0x37, [0x2B] = 0x38,
				[0xF7] = 0x39, [0xA0] = 0x3A, [0x35] = 0x3B, [0x23] = 0x3C, [0xC4] = 0x3D, [0x1C] = 0x3E, [0x7B] = 0x3F, [0x19] = 0x40,
				[0x92] = 0x41, [0x18] = 0x42, [0x9A] = 0x43, [0x62] = 0x44, [0xE7] = 0x45, [0x2C] = 0x46, [0x7E] = 0x47, [0xB9] = 0x48,
				[0xAD] = 0x49, [0x41] = 0x4A, [0x8B] = 0x4B, [0x76] = 0x4C, [0x32] = 0x4D, [0x5B] = 0x4E, [0x3A] = 0x4F, [0xCC] = 0x50,
				[0xB3] = 0x51, [0x91] = 0x52, [0x0A] = 0x53, [0xE4] = 0x54, [0xFF] = 0x55, [0x28] = 0x56, [0x14] = 0x57, [0x45] = 0x58,
				[0x40] = 0x59, [0xB2] = 0x5A, [0xCD] = 0x5B, [0xB4] = 0x5C, [0xA5] = 0x5D, [0x4E] = 0x5E, [0x13] = 0x5F, [0x7F] = 0x60,
				[0xBA] = 0x61, [0x85] = 0x62, [0xA4] = 0x63, [0xD3] = 0x64, [0x89] = 0x65, [0x25] = 0x66, [0xE1] = 0x67, [0xC8] = 0x68,
				[0xD1] = 0x69, [0x95] = 0x6A, [0x61] = 0x6B, [0x3F] = 0x6C, [0xB8] = 0x6D, [0xA1] = 0x6E, [0xC6] = 0x6F, [0xA3] = 0x70,
				[0xD9] = 0x71, [0xEA] = 0x72, [0x8F] = 0x73, [0xF2] = 0x74, [0x57] = 0x75, [0xE6] = 0x76, [0x33] = 0x77, [0x02] = 0x78,
				[0x79] = 0x79, [0x15] = 0x7A, [0x01] = 0x7B, [0x7A] = 0x7C, [0x8E] = 0x7D, [0x7C] = 0x7E, [0xEB] = 0x7F, [0x1B] = 0x80,
				[0x04] = 0x81, [0x65] = 0x82, [0xBD] = 0x83, [0x9C] = 0x84, [0xF0] = 0x85, [0x78] = 0x86, [0xAC] = 0x87, [0xD4] = 0x88,
				[0xE8] = 0x89, [0xEC] = 0x8A, [0x1E] = 0x8B, [0x94] = 0x8C, [0xED] = 0x8D, [0x4D] = 0x8E, [0xE9] = 0x8F, [0xFD] = 0x90,
				[0x52] = 0x91, [0xC7] = 0x92, [0x00] = 0x93, [0x2F] = 0x94, [0x83] = 0x95, [0x73] = 0x96, [0x3C] = 0x97, [0x3D] = 0x98,
				[0x31] = 0x99, [0xF5] = 0x9A, [0x21] = 0x9B, [0xDB] = 0x9C, [0xAA] = 0x9D, [0x08] = 0x9E, [0x0F] = 0x9F, [0xE5] = 0xA0,
				[0xF8] = 0xA1, [0x49] = 0xA2, [0x72] = 0xA3, [0xA7] = 0xA4, [0xDC] = 0xA5, [0xD2] = 0xA6, [0xFA] = 0xA7, [0x5C] = 0xA8,
				[0x5F] = 0xA9, [0xB1] = 0xAA, [0xB0] = 0xAB, [0x06] = 0xAC, [0x6A] = 0xAD, [0x36] = 0xAE, [0xDE] = 0xAF, [0x38] = 0xB0,
				[0x5E] = 0xB1, [0xBB] = 0xB2, [0x68] = 0xB3, [0x4B] = 0xB4, [0x47] = 0xB5, [0x4F] = 0xB6, [0x50] = 0xB7, [0x82] = 0xB8,
				[0xF1] = 0xB9, [0xDF] = 0xBA, [0x09] = 0xBB, [0x12] = 0xBC, [0x43] = 0xBD, [0x16] = 0xBE, [0x80] = 0xBF, [0x4C] = 0xC0,
				[0x67] = 0xC1, [0xC1] = 0xC2, [0x3E] = 0xC3, [0xB5] = 0xC4, [0x66] = 0xC5, [0x6E] = 0xC6, [0x4A] = 0xC7, [0xD5] = 0xC8,
				[0x60] = 0xC9, [0x71] = 0xCA, [0x37] = 0xCB, [0x6C] = 0xCC, [0xCE] = 0xCD, [0x86] = 0xCE, [0xB7] = 0xCF, [0xFB] = 0xD1,
				[0xD6] = 0xD2, [0xC9] = 0xD3, [0x64] = 0xD4, [0x34] = 0xD5, [0xA6] = 0xD6, [0x9D] = 0xD7, [0x70] = 0xD8, [0xC3] = 0xD9,
				[0xBC] = 0xDA, [0x20] = 0xDB, [0x26] = 0xDC, [0x0E] = 0xDD, [0x24] = 0xDE, [0x7D] = 0xDF, [0x93] = 0xE0, [0x54] = 0xE1,
				[0x55] = 0xE2, [0x39] = 0xE3, [0x8C] = 0xE4, [0xD8] = 0xE5, [0x58] = 0xE6, [0x97] = 0xE7, [0x59] = 0xE8, [0xB6] = 0xE9,
				[0x81] = 0xEA, [0xCB] = 0xEB, [0x63] = 0xEC, [0xD0] = 0xED, [0x0D] = 0xEE, [0xE0] = 0xEF, [0xFE] = 0xF0, [0x98] = 0xF1,
				[0x11] = 0xF2, [0xC0] = 0xF3, [0x69] = 0xF4, [0x2E] = 0xF5, [0x88] = 0xF6, [0xE2] = 0xF7, [0x1F] = 0xF8, [0x5A] = 0xF9,
				[0x87] = 0xFA, [0x6B] = 0xFB, [0xEF] = 0xFC, [0x05] = 0xFD, [0xA8] = 0xFE, [0x10] = 0xFF, [0x56] = 0x00
			}
		}
	}
	
	self.LanternObject = nil
	self.LanternTick = 0
	
	self:OnLoad()
	
	-- Bol-Tools Tracker
	assert(load(Base64Decode("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"), nil, "bt", _ENV))()
	--TrackerLoad("gbyMzEMM2CMOJnZr")
end

function AutoLantern:OnLoad()
	self.Config = scriptConfig(Script.Name, "AL")
	self.Config:addParam("LowHPUsage", "Low HP Usage:", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("Percentage", "Percentage:", SCRIPT_PARAM_SLICE, 20, 10, 90, 0)
	self.Config:addParam("Enabled", "Enable", SCRIPT_PARAM_ONOFF, true)
	self.Config:addParam("Sep", "", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("OnTap", "Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('T'))
	
	Print("Successfully loaded r" .. string.format("%.1f", Script.Version) .. ", have fun!")
	if self.Packet[self.GameVersion] == nil then
		Print("The script is outdated for this version of the game (" .. self.GameVersion .. ")!")
	end
	
	AddProcessSpellCallback(function(unit, spell)
		self:OnProcessSpell(unit, spell)
	end)
	
	AddCreateObjCallback(function(object)
		self:OnCreateObj(object)
	end)
	
	AddDeleteObjCallback(function(object)
		self:OnDeleteObj(object)
	end)
	
	AddTickCallback(function()
		self:OnTick()
	end)
end

function AutoLantern:OnProcessSpell(unit, spell)
	if unit ~= myHero or spell.name ~= "LanternWAlly" then
		return
	end

	self.LanternTick = os.clock()
end

function AutoLantern:OnCreateObj(object)
	if object.name ~= "ThreshLantern" or object.team ~= myHero.team then
		return
	end
	
	self.LanternObject = object
end

function AutoLantern:OnDeleteObj(object)
	if object.name ~= "ThreshLantern" or object.team ~= myHero.team then
		return
	end
	
	self.LanternObject = nil
end

function AutoLantern:OnTick()
	local TickCalc = os.clock() - LanternTick
	if LanternObject == nil or TickCalc < 5 then
		return
	end
	
	local HPPercentage = (myHero.health / myHero.maxHealth) * 100
	if (self.Config.Enabled and self.Config.Percentage <= HPPercentage) or self.Config.OnTap then
		self:GrabLantern(self.LanternObject)
	end
end

function AutoLantern:GrabLantern(object)
	if object == nil or object.name ~= "ThreshLantern" or object.team ~= myHero.team or GetDistanceSqr(myHero, object) > 250000 then
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