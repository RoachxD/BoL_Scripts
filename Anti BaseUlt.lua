--[[


		 .d8b.  d8b   db d888888b d888888b      d8888b.  .d8b.  .d8888. d88888b db    db db      d888888b
		d8' `8b 888o  88 `~~88~~'   `88'        88  `8D d8' `8b 88'  YP 88'     88    88 88      `~~88~~'
		88ooo88 88V8o 88    88       88         88oooY' 88ooo88 `8bo.   88ooooo 88    88 88         88
		88~~~88 88 V8o88    88       88         88~~~b. 88~~~88   `Y8b. 88~~~~~ 88    88 88         88
		88   88 88  V888    88      .88.        88   8D 88   88 db   8D 88.     88b  d88 88booo.    88
		YP   YP VP   V8P    YP    Y888888P      Y8888P' YP   YP `8888Y' Y88888P ~Y8888P' Y88888P    YP


	Anti BaseUlt - Never fear a BaseUlt again!

	Changelog:
		April 04, 2016 [r1.0]:
			- First Release.
]]--

local Script =
{
	Name = "Anti BaseUlt",
	Version = 1.0
}

local function Print(string)
	print("<font color=\"#BFC0C2\">" .. Script.Name .. ":</font> <font color=\"#5A87C8\">" .. string .. "</font>")
end

class "ABUpdater"
function ABUpdater:__init(LocalVersion, Host, Path, LocalPath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion, CallbackError)
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

function ABUpdater:OnDraw()
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

function ABUpdater:Base64Encode(data)
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
			AntiBaseUlt()
		end,
		CallbackNewVersion = function(version)
			Print("New release found (r" .. string.format("%.1f", version) .. "), please wait until it's downloaded!")
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
	self.Config = scriptConfig("Anti BaseUlt", "ABU")
	self.Config:addSubMenu("Champions", "Champions")
	for _, Hero in pairs(GetEnemyHeroes()) do
		if self.SpellData[Hero.charName] ~= nil then
			self.Config.Champions:addParam(Hero.charName, Hero.charName .. " - " .. self.SpellData[Hero.charName].MissileName, SCRIPT_PARAM_ONOFF, true)
		end
	end
	
	Print("Successfully loaded r" .. string.format("%.1f", Script.Version) .. ", have fun!")
	
	if next(self.Config.Champions._param) == nil then
	   self.Config.Champions:addParam("Info", "No champions supported!", SCRIPT_PARAM_INFO, "")
	   Print("No champions supported in the enemy team, the script will unload!")
	end
	
	self.Config:addParam("Enable", "Enable Anti BaseUlt", SCRIPT_PARAM_ONOFF, true)

	
	if self.Config.Champions.Info == nil then
		AddProcessSpellCallback(function(unit, spell)
			self:OnProcessSpell(unit, spell)
		end)
		
		AddCreateObjCallback(function(object)
			self:OnCreateObj(object)
		end)
	end
end

function AntiBaseUlt:OnProcessSpell(unit, spell)
	if not self.Config.Enable then
		return
	end
	
	if unit == myHero and spell.name:find("recall") then
		local RecallSpells =
		{
			['recall'] = 8.0,
			['recallimproved'] = 7.0,
			['odinrecall'] = 4.5,
			['odinrecallimproved'] = 4.0,
			['superrecall'] = 4.0,
			['superrecallimproved'] = 4.0
		}
		
		self.RecallingTime = os.clock() + RecallSpells[spell.name:lower()]
		Print("Detected Recall (Finish tick: " .. self.RecallingTime .." | Actual Tick: " .. os.clock() .. ").")
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
	
	if self.RecallingTime < os.clock() then
		return
	end
	
	if SpellOwner.type ~= myHero.type or SpellOwner.team == myHero.team then
		return
	end
	
	if self.SpellData[SpellOwner.charName] == nil or not self.Config.Champions[SpellOwner.charName] then
		return
	end
	
	if self.SpellData[SpellOwner.charName].MissileName ~= object.spellName then
		return
	end
	
	local FountainPos = GetFountain()
	if not self:IsLineCircleIntersection(FountainPos, 500, object.pos, object.spellEnd) then
		return
	end

	local Time = os.clock() + (GetDistance(object.pos, FountainPos) / self.SpellData[SpellOwner.charName].Speed)
	if self.RecallingTime + 1 < Time or self.RecallingTime - 1 > Time then
		return
	end
	
	myHero:MoveTo(myHero.x + 1, myHero.z + 1)
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

AntiBaseUlt()