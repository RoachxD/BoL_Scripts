--[[


		 .d8b.  d8b   db d888888b d888888b      d8888b.  .d8b.  .d8888. d88888b db    db db      d888888b
		d8' `8b 888o  88 `~~88~~'   `88'        88  `8D d8' `8b 88'  YP 88'     88    88 88      `~~88~~'
		88ooo88 88V8o 88    88       88         88oooY' 88ooo88 `8bo.   88ooooo 88    88 88         88
		88~~~88 88 V8o88    88       88         88~~~b. 88~~~88   `Y8b. 88~~~~~ 88    88 88         88
		88   88 88  V888    88      .88.        88   8D 88   88 db   8D 88.     88b  d88 88booo.    88
		YP   YP VP   V8P    YP    Y888888P      Y8888P' YP   YP `8888Y' Y88888P ~Y8888P' Y88888P    YP


	Anti BaseUlt - Never fear a BaseUlt again!

	Changelog:
		April 16, 2016 [r1.4]:
			- Fixed a bug with the Auto-Updater.

		April 16, 2016 [r1.3]:
			- Improved the performance of the Script.

		April 07, 2016 [r1.2]:
			- Fixed a bug that was causing the Debug option to create errors.

		April 04, 2016 [r1.1]:
			- Improved a bit the menu.
			- Added a Debug Option.

		April 04, 2016 [r1.0]:
			- First Release.
]]--

local Script =
{
	Name = "Anti BaseUlt",
	Version = 1.4
}

local function Print(string)
	print("<font color=\"#BFC0C2\">" .. Script.Name .. ":</font> <font color=\"#5A87C8\">" .. string .. "</font>")
end

class "ABUpdater"
local random, round = math.random, math.round
function ABUpdater:__init(LocalVersion, Host, Path, LocalPath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion, CallbackError)
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

function ABUpdater:OnDraw()
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
		BackgroundColor = 0xFFBFC0C2,
		ForegroundColor = 0xFF5A87C8
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

function ABUpdater:CreateSocket(url)
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
function ABUpdater:Base64Encode(data)
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
function ABUpdater:GetOnlineVersion()
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

function ABUpdater:DownloadUpdate()
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
			AntiBaseUlt()
		end,
		CallbackNewVersion = function(version)
			Print("New release found (r" .. format("%.1f", version) .. "), please wait until it's downloaded!")
		end,
		CallbackError = function(version)
			Print("Download failed, please try again!")
			Print("If the problem persists please contact script's author!")
			AntiBaseUlt()
		end
	}
	
	ABUpdater(UpdaterInfo.Version, UpdaterInfo.Host, UpdaterInfo.Path, UpdaterInfo.LocalPath, UpdaterInfo.CallbackUpdate, UpdaterInfo.CallbackNoUpdate, UpdaterInfo.CallbackNewVersion, UpdaterInfo.CallbackError)
end)

class "AntiBaseUlt"
function AntiBaseUlt:__init()
	self.SpellData =
	{
		['Ashe'] = 
		{
			MissileName = "EnchantedCrystalArrow",
			Speed = 1600
		},
		['Draven'] = 
		{
			MissileName = "DravenR",
			Speed = 2000
		},
		['Ezreal'] =
		{
			MissileName = "EzrealTrueshotBarrage",
			Speed = 2000
		},
		['Jinx'] = 
		{
			MissileName = "JinxR",
			Speed = 1700
		}
	}
	
	self.RecallingTime = 0
	
	self:OnLoad()
end

function AntiBaseUlt:OnLoad()
	self.Config = scriptConfig(Script.Name, "ABU")
	self.Config:addSubMenu("Champion Settings", "Champion")
	for _, Hero in pairs(GetEnemyHeroes()) do
		if self.SpellData[Hero.charName] ~= nil then
			self.Config.Champion:addParam(Hero.charName, Hero.charName .. " - " .. self.SpellData[Hero.charName].MissileName, SCRIPT_PARAM_ONOFF, true)
		end
	end
	
	Print("Successfully loaded r" .. format("%.1f", Script.Version) .. ", have fun!")
	
	if next(self.Config.Champion._param) == nil then
	   self.Config.Champion:addParam("Info", "No champions supported!", SCRIPT_PARAM_INFO, "")
	   Print("No champions supported in the enemy team, the script will unload!")
	end
	
	self.Config:addSubMenu("Debug Settings", "Debug")
	self.Config.Debug:addParam("Prints", "Debug Printing", SCRIPT_PARAM_ONOFF, false)
	
	self.Config:addParam("Enable", "Enable Anti BaseUlt", SCRIPT_PARAM_ONOFF, true)
	self.Config:addParam("ScriptVersion", "Script Version: ", SCRIPT_PARAM_INFO, "r" .. format("%.1f", Script.Version))

	
	if self.Config.Champion.Info == nil then
		AddProcessSpellCallback(function(unit, spell)
			self:OnProcessSpell(unit, spell)
		end)
		
		AddCreateObjCallback(function(object)
			self:OnCreateObj(object)
		end)
	end
end

local lower, clock = string.lower, os.clock
function AntiBaseUlt:OnProcessSpell(unit, spell)
	if not self.Config.Enable then
		return
	end
	
	if unit == myHero and find(spell.name, "recall") then
		local RecallSpells =
		{
			['recall'] = 8.0,
			['recallimproved'] = 7.0,
			['odinrecall'] = 4.5,
			['odinrecallimproved'] = 4.0,
			['superrecall'] = 4.0,
			['superrecallimproved'] = 4.0
		}
		
		self.RecallingTime = clock() + RecallSpells[lower(spell.name)]
		self:Debug("Recall Detected! (Finish Time: " .. self.RecallingTime .. " | Actual Time" .. clock() .. ").")
	end
end

function AntiBaseUlt:OnCreateObj(object)
	if not self.Config.Enable then
		return
	end
	
	if not object or not object.valid or object.type ~= "MissileClient" then
		return
	end
	
	local SpellOwner = object.spellOwner
	if not SpellOwner or not SpellOwner.valid then
		return
	end
	
	if self.RecallingTime < clock() then
		return
	end
	
	if SpellOwner.type ~= myHero.type or SpellOwner.team == myHero.team then
		return
	end
	
	if self.SpellData[SpellOwner.charName] == nil or not self.Config.Champion[SpellOwner.charName] then
		return
	end
	
	if self.SpellData[SpellOwner.charName].MissileName ~= object.spellName then
		return
	end
	
	local FountainPos = GetFountain()
	if not self:IsLineCircleIntersection(FountainPos, 500, object.pos, object.spellEnd) then
		self:Debug("BaseUlt not in fountain (" .. SpellOwner.charName .. " - " .. object.spellName ..").")
		return
	end

	local Time = clock() + (GetDistance(object.pos, FountainPos) / self.SpellData[SpellOwner.charName].Speed)
	if 1 + self.RecallingTime < Time or self.RecallingTime - 1 > Time then
		self:Debug("BaseUlt not correctly timed (" .. SpellOwner.charName .. " - " .. object.spellName ..").")
		return
	end
	
	myHero:MoveTo(1 + myHero.x, 1 + myHero.z)
	Print("BaseUlt Prevented (" .. SpellOwner.charName .. " - " .. object.spellName ..").")
end

function AntiBaseUlt:IsLineCircleIntersection(circle, radius, v1, v2)
    local ToLineEnd = v2 - v1
	local ToCircle = circle - v1
	local Theta = (ToCircle.x * ToLineEnd.x + ToCircle.y * ToLineEnd.y) / (ToLineEnd.x * ToLineEnd.x + ToLineEnd.y * ToLineEnd.y)
	Theta = Theta <= 0 and 0 or 1
	
	local Closest = v1 + D3DXVECTOR3(ToLineEnd.x * Theta, ToLineEnd.y * Theta, ToLineEnd.z * Theta)
	local D = circle - Closest
	local Dist = (D.x * D.x) + (D.y * D.y)
	return Dist <= radius * radius
end

function AntiBaseUlt:Debug(string)
	if not self.Config.Debug.Prints then
		return
	end
	
	Print(string)
end