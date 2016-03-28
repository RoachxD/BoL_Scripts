--[[


		db   dD d88888b db    db d8888b.  .d88b.   .d8b.  d8888b. d8888b.       .o88b.  .d88b.  d8b   db d888888b d8888b.  .d88b.  db      db      d88888b d8888b.
		88 ,8P' 88'     `8b  d8' 88  `8D .8P  Y8. d8' `8b 88  `8D 88  `8D      d8P  Y8 .8P  Y8. 888o  88 `~~88~~' 88  `8D .8P  Y8. 88      88      88'     88  `8D
		88,8P   88ooooo  `8bd8'  88oooY' 88    88 88ooo88 88oobY' 88   88      8P      88    88 88V8o 88    88    88oobY' 88    88 88      88      88ooooo 88oobY'
		88`8b   88~~~~~    88    88~~~b. 88    88 88~~~88 88`8b   88   88      8b      88    88 88 V8o88    88    88`8b   88    88 88      88      88~~~~~ 88`8b
		88 `88. 88.        88    88   8D `8b  d8' 88   88 88 `88. 88  .8D      Y8b  d8 `8b  d8' 88  V888    88    88 `88. `8b  d8' 88booo. 88booo. 88.     88 `88.
		YP   YD Y88888P    YP    Y8888P'  `Y88P'  YP   YP 88   YD Y8888D'       `Y88P'  `Y88P'  VP   V8P    YP    88   YD  `Y88P'  Y88888P Y88888P Y88888P 88   YD


	Keyboard Controller - Move your hero using the keyboard!

	Changelog:
		March 28, 2016 [r1.6]:
			- Added an Auto-Updater.

		March 23, 2016 [r1.5]:
			- Updated for 6.6.

		March 14, 2016 [r1.4]:
			- Re-wrote the Script as a Class (For my upcoming Auto-Updater).
			- Improved the VIP Check, it will let you know what you can do.
			- Added Bol-Tools Tracker.

		March 11, 2016 [r1.3]:
			- Updated for 6.5HF.

		March 09, 2016 [r1.2]:
			- Updated for 6.5.

		March 07, 2016 [r1.1]:
			- Now the "Disable spells" Option will support Mini-Patches as well.

		March 03, 2016 [r1.0]:
			- First Release.
]]--

local Script =
{
	Name = "Keyboard Controller",
	Version = 1.6
}

function Print(string)
	print("<font color=\"#EB9F0F\">" .. Script.Name .. ":</font> <font color=\"#C34177\">" .. string .. "</font>")
end

class "Updater"
function Updater:__init(LocalVersion, Host, Path, LocalPath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion, CallbackError)
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

function Updater:OnDraw()
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

function Updater:CreateSocket(url)
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

function Updater:Base64Encode(data)
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

function Updater:GetOnlineVersion()
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
		
		if self.File:find('<scr' .. 'ipt>') then
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

function Updater:DownloadUpdate()
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
			ItemSwapper()
		end,
		CallbackNewVersion = function(version)
			Print("New release found (r" .. string.format("%.1f", version) .. "), please wait until it's downloaded!")
		end,
		CallbackError = function(version)
			Print("Download failed, please try again!")
			Print("If the problem persists please contact script's author!")
			ItemSwapper()
		end
	}
	
	Updater(UpdaterInfo.Version, UpdaterInfo.Host, UpdaterInfo.Path, UpdaterInfo.LocalPath, UpdaterInfo.CallbackUpdate, UpdaterInfo.CallbackNoUpdate, UpdaterInfo.CallbackNewVersion, UpdaterInfo.CallbackError)
end)

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
	
	self.GameVersion = GetGameVersion():sub(1, 9)
	self.CastSpellHeader =
	{
		['6.6.137.4'] = 0x15A,
		['6.5.0.280'] = 0x10E,
		['6.5.0.277'] = 0x10E,
		['6.4.0.250'] = 0x49
	}
	
	self:OnLoad()
	
	-- Bol-Tools Tracker
	assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQQfAAAAAwAAAEQAAACGAEAA5QAAAJ1AAAGGQEAA5UAAAJ1AAAGlgAAACIAAgaXAAAAIgICBhgBBAOUAAQCdQAABhkBBAMGAAQCdQAABhoBBAOVAAQCKwICDhoBBAOWAAQCKwACEhoBBAOXAAQCKwICEhoBBAOUAAgCKwACFHwCAAAsAAAAEEgAAAEFkZFVubG9hZENhbGxiYWNrAAQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawAEDAAAAFRyYWNrZXJMb2FkAAQNAAAAQm9sVG9vbHNUaW1lAAQQAAAAQWRkVGlja0NhbGxiYWNrAAQGAAAAY2xhc3MABA4AAABTY3JpcHRUcmFja2VyAAQHAAAAX19pbml0AAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAoAAABzZW5kRGF0YXMABAsAAABHZXRXZWJQYWdlAAkAAAACAAAAAwAAAAAAAwkAAAAFAAAAGABAABcAAIAfAIAABQAAAAxAQACBgAAAHUCAAR8AgAADAAAAAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAcAAAB1bmxvYWQAAAAAAAEAAAABAQAAAAAAAAAAAAAAAAAAAAAEAAAABQAAAAAAAwkAAAAFAAAAGABAABcAAIAfAIAABQAAAAxAQACBgAAAHUCAAR8AgAADAAAAAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAkAAABidWdzcGxhdAAAAAAAAQAAAAEBAAAAAAAAAAAAAAAAAAAAAAUAAAAHAAAAAQAEDQAAAEYAwACAAAAAXYAAAUkAAABFAAAATEDAAMGAAABdQIABRsDAAKUAAADBAAEAXUCAAR8AgAAFAAAABA4AAABTY3JpcHRUcmFja2VyAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAUAAABsb2FkAAQMAAAARGVsYXlBY3Rpb24AAwAAAAAAQHpAAQAAAAYAAAAHAAAAAAADBQAAAAUAAAAMAEAAgUAAAB1AgAEfAIAAAgAAAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAgAAAB3b3JraW5nAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAEBAAAAAAAAAAAAAAAAAAAAAAAACAAAAA0AAAAAAAYyAAAABgBAAB2AgAAaQEAAF4AAgEGAAABfAAABF0AKgEYAQQBHQMEAgYABAMbAQQDHAMIBEEFCAN0AAAFdgAAACECAgUYAQQBHQMEAgYABAMbAQQDHAMIBEMFCAEbBQABPwcICDkEBAt0AAAFdgAAACEAAhUYAQQBHQMEAgYABAMbAQQDHAMIBBsFAAA9BQgIOAQEARoFCAE/BwgIOQQEC3QAAAV2AAAAIQACGRsBAAIFAAwDGgEIAAUEDAEYBQwBWQIEAXwAAAR8AgAAOAAAABA8AAABHZXRJbkdhbWVUaW1lcgADAAAAAAAAAAAECQAAADAwOjAwOjAwAAQGAAAAaG91cnMABAcAAABzdHJpbmcABAcAAABmb3JtYXQABAYAAAAlMDIuZgAEBQAAAG1hdGgABAYAAABmbG9vcgADAAAAAAAgrEAEBQAAAG1pbnMAAwAAAAAAAE5ABAUAAABzZWNzAAQCAAAAOgAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAA4AAAATAAAAAAAIKAAAAAEAAABGQEAAR4DAAIEAAAAhAAiABkFAAAzBQAKAAYABHYGAAVgAQQIXgAaAR0FBAhiAwQIXwAWAR8FBAhkAwAIXAAWARQGAAFtBAAAXQASARwFCAoZBQgCHAUIDGICBAheAAYBFAQABTIHCAsHBAgBdQYABQwGAAEkBgAAXQAGARQEAAUyBwgLBAQMAXUGAAUMBgABJAYAAIED3fx8AgAANAAAAAwAAAAAAAPA/BAsAAABvYmpNYW5hZ2VyAAQLAAAAbWF4T2JqZWN0cwAECgAAAGdldE9iamVjdAAABAUAAAB0eXBlAAQHAAAAb2JqX0hRAAQHAAAAaGVhbHRoAAQFAAAAdGVhbQAEBwAAAG15SGVybwAEEgAAAFNlbmRWYWx1ZVRvU2VydmVyAAQGAAAAbG9vc2UABAQAAAB3aW4AAAAAAAMAAAAAAAEAAQEAAAAAAAAAAAAAAAAAAAAAFAAAABQAAAACAAICAAAACkAAgB8AgAABAAAABAoAAABzY3JpcHRLZXkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFAAAABUAAAACAAUKAAAAhgBAAMAAgACdgAABGEBAARfAAICFAIAAjIBAAQABgACdQIABHwCAAAMAAAAEBQAAAHR5cGUABAcAAABzdHJpbmcABAoAAABzZW5kRGF0YXMAAAAAAAIAAAAAAAEBAAAAAAAAAAAAAAAAAAAAABYAAAAlAAAAAgATPwAAAApAAICGgEAAnYCAAAqAgICGAEEAxkBBAAaBQQAHwUECQQECAB2BAAFGgUEAR8HBAoFBAgBdgQABhoFBAIfBQQPBgQIAnYEAAcaBQQDHwcEDAcICAN2BAAEGgkEAB8JBBEECAwAdggABFgECAt0AAAGdgAAACoCAgYaAQwCdgIAACoCAhgoAxIeGQEQAmwAAABdAAIAKgMSHFwAAgArAxIeGQEUAh4BFAQqAAIqFAIAAjMBFAQEBBgBBQQYAh4FGAMHBBgAAAoAAQQIHAIcCRQDBQgcAB0NAAEGDBwCHw0AAwcMHAAdEQwBBBAgAh8RDAFaBhAKdQAACHwCAACEAAAAEBwAAAGFjdGlvbgAECQAAAHVzZXJuYW1lAAQIAAAAR2V0VXNlcgAEBQAAAGh3aWQABA0AAABCYXNlNjRFbmNvZGUABAkAAAB0b3N0cmluZwAEAwAAAG9zAAQHAAAAZ2V0ZW52AAQVAAAAUFJPQ0VTU09SX0lERU5USUZJRVIABAkAAABVU0VSTkFNRQAEDQAAAENPTVBVVEVSTkFNRQAEEAAAAFBST0NFU1NPUl9MRVZFTAAEEwAAAFBST0NFU1NPUl9SRVZJU0lPTgAECwAAAGluZ2FtZVRpbWUABA0AAABCb2xUb29sc1RpbWUABAYAAABpc1ZpcAAEAQAAAAAECQAAAFZJUF9VU0VSAAMAAAAAAADwPwMAAAAAAAAAAAQJAAAAY2hhbXBpb24ABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAECwAAAEdldFdlYlBhZ2UABA4AAABib2wtdG9vbHMuY29tAAQXAAAAL2FwaS9ldmVudHM/c2NyaXB0S2V5PQAECgAAAHNjcmlwdEtleQAECQAAACZhY3Rpb249AAQLAAAAJmNoYW1waW9uPQAEDgAAACZib2xVc2VybmFtZT0ABAcAAAAmaHdpZD0ABA0AAAAmaW5nYW1lVGltZT0ABAgAAAAmaXNWaXA9AAAAAAACAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAmAAAAKgAAAAMACiEAAADGQEAAAYEAAN2AAAHHwMAB3YCAAArAAIDHAEAAzADBAUABgACBQQEA3UAAAscAQADMgMEBQcEBAIABAAHBAQIAAAKAAEFCAgBWQYIC3UCAAccAQADMgMIBQcECAIEBAwDdQAACxwBAAMyAwgFBQQMAgYEDAN1AAAIKAMSHCgDEiB8AgAASAAAABAcAAABTb2NrZXQABAgAAAByZXF1aXJlAAQHAAAAc29ja2V0AAQEAAAAdGNwAAQIAAAAY29ubmVjdAADAAAAAAAAVEAEBQAAAHNlbmQABAUAAABHRVQgAAQSAAAAIEhUVFAvMS4wDQpIb3N0OiAABAUAAAANCg0KAAQLAAAAc2V0dGltZW91dAADAAAAAAAAAAAEAgAAAGIAAwAAAPyD15dBBAIAAAB0AAQKAAAATGFzdFByaW50AAQBAAAAAAQFAAAARmlsZQAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAAA="), nil, "bt", _ENV))()
	TrackerLoad("PuhqNuwgSjmUXkB2")
end

function KeyboardController:OnLoad()
	self.Config = scriptConfig(Script.Name, "KC")
	self.Config:addParam("Enable", "Enable", SCRIPT_PARAM_ONOFF, true)
	self.Config:addParam("Info", "Keys Settings:", SCRIPT_PARAM_INFO, "")
	self.Config:addParam("Up", "Up", SCRIPT_PARAM_ONKEYDOWN, false, 38)
	self.Config:addParam("Left", "Left", SCRIPT_PARAM_ONKEYDOWN, false, 37)
	self.Config:addParam("Down", "Down", SCRIPT_PARAM_ONKEYDOWN, false, 40)
	self.Config:addParam("Right", "Right", SCRIPT_PARAM_ONKEYDOWN, false, 39)
	
	Print("Successfully loaded r" .. string.format("%.1f", Script.Version) .. ", have fun!")
	
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