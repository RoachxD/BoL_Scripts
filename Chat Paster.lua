--[[


		 .o88b. db   db  .d8b.  d888888b      d8888b.  .d8b.  .d8888. d888888b d88888b d8888b.
		d8P  Y8 88   88 d8' `8b `~~88~~'      88  `8D d8' `8b 88'  YP `~~88~~' 88'     88  `8D
		8P      88ooo88 88ooo88    88         88oodD' 88ooo88 `8bo.      88    88ooooo 88oobY'
		8b      88~~~88 88~~~88    88         88~~~   88~~~88   `Y8b.    88    88~~~~~ 88`8b
		Y8b  d8 88   88 88   88    88         88      88   88 db   8D    88    88.     88 `88.
		 `Y88P' YP   YP YP   YP    YP         88      YP   YP `8888Y'    YP    Y88888P 88   YD

	Chat Paster - Paste into the chat with ease!
	
	Changelog:
		June 21, 2016 [r1.0]:
			- First Release.
]]--

local Script =
{
	Name = "Chat Paster",
	Version = 1.0
}

local function Print(string)
	print("<font color=\"#581845\">" .. Script.Name .. ":</font> <font color=\"#900C3F\">" .. string .. "</font>")
end

class "CPUpdater"
local random, round = math.random, math.round
function CPUpdater:__init(LocalVersion, Host, Path, LocalPath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion, CallbackError)
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

function CPUpdater:OnDraw()
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
		BackgroundColor = 0xFF581845,
		ForegroundColor = 0x900C3F
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

function CPUpdater:CreateSocket(url)
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
function CPUpdater:Base64Encode(data)
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
function CPUpdater:GetOnlineVersion()
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

function CPUpdater:DownloadUpdate()
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
			ChatPaster()
		end,
		CallbackNewVersion = function(version)
			Print("New release found (r" .. format("%.1f", version) .. "), please wait until it's downloaded!")
		end,
		CallbackError = function(version)
			Print("Download failed, please try again!")
			Print("If the problem persists please contact script's author!")
			ChatPaster()
		end
	}

	CPUpdater(UpdaterInfo.Version, UpdaterInfo.Host, UpdaterInfo.Path, UpdaterInfo.LocalPath, UpdaterInfo.CallbackUpdate, UpdaterInfo.CallbackNoUpdate, UpdaterInfo.CallbackNewVersion, UpdaterInfo.CallbackError)
end)

class "ChatPaster"
function ChatPaster:__init()
	self.Keys =
	{
		CTRL = 0x11,
		N = 0x4E,
		V = 0x56
	}
	
	self.ConfirmationNeeded = false
	self.KeysPressed = false
	
	self:OnLoad()
	
	AddMsgCallback(function(msg, key)
		self:OnWndMsg(msg, key)
	end)
	
	-- Bol-Tools Tracker
	assert(load(Base64Decode("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"), nil, "bt", _ENV))()
	--TrackerLoad("")
end

function ChatPaster:OnLoad()
	self.Config = scriptConfig(Script.Name, "CP")
	self.Config:addSubMenu("General Settings", "Settings")
	self.Config.Settings:addParam("Confirmation", "Confirmation before pasting", SCRIPT_PARAM_ONOFF, true)
	self.Config:addParam("Enable", "Enable", SCRIPT_PARAM_ONOFF, true)
	self.Config:addParam("Version", "Version:", SCRIPT_PARAM_INFO, format("%.1f", Script.Version))
	
	Print("Successfully loaded r" .. format("%.1f", Script.Version) .. ", have fun!")
end

function ChatPaster:OnWndMsg(msg, key)
	if not self.Config.Enable then
		return
	end
	
	local ClipboardText = GetClipboardText()
	if IsKeyDown(self.Keys.CTRL) and key == self.Keys.V then
		if msg == 0x100 then
			if self.KeysPressed then
				return
			end
			
			if self.Config.Settings.Confirmation then
				if not self.ConfirmationNeeded then
					Print("To confirm press CTRL-V once again.")
					Print("You can deny it by pressing 'N'.")
					self.ConfirmationNeeded = true
				else
					SendChat(ClipboardText)
					self.ConfirmationNeeded = false
				end
			else
				SendChat(ClipboardText)
			end
			
			self.KeysPressed = true
		end
		
		if msg == 0x101 then
			self.KeysPressed = false
		end
	end
	
	if msg == 0x100 and key == self.Keys.N then
		if not self.Config.Settings.Confirmation then
			return
		end
		
		self.ConfirmationNeeded = false
	end
end

ChatPaster()