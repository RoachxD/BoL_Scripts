--[[


		 .o88b.  .d88b.  db       .d88b.  d8888b. d88888b db    db db            .o88b. d888888b d8888b.  .o88b. db      d88888b .d8888. 
		d8P  Y8 .8P  Y8. 88      .8P  Y8. 88  `8D 88'     88    88 88           d8P  Y8   `88'   88  `8D d8P  Y8 88      88'     88'  YP 
		8P      88    88 88      88    88 88oobY' 88ooo   88    88 88           8P         88    88oobY' 8P      88      88ooooo `8bo.   
		8b      88    88 88      88    88 88`8b   88~~~   88    88 88           8b         88    88`8b   8b      88      88~~~~~   `Y8b. 
		Y8b  d8 `8b  d8' 88booo. `8b  d8' 88 `88. 88      88b  d88 88booo.      Y8b  d8   .88.   88 `88. Y8b  d8 88booo. 88.     db   8D 
		 `Y88P'  `Y88P'  Y88888P  `Y88P'  88   YD YP      ~Y8888P' Y88888P       `Y88P' Y888888P 88   YD  `Y88P' Y88888P Y88888P `8888Y' 


	Colorful Circles - Have Fun!

	Changelog:
		- Who the fuck cares?

]]--
local rClock = 0

function OnLoad()
	RAINBOW = ARGB(255, math.random(1, 255), math.random(1, 255), math.random(1, 255))
	
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawRainbowCircle

	ColorfulMenu = scriptConfig("Colorful Circles", "HF")
		ColorfulMenu:addParam("Enable", "ENABLEEE!!", SCRIPT_PARAM_ONOFF, true)
		ColorfulMenu:addParam("interval", "Interval to change colors: ", SCRIPT_PARAM_SLICE, 0.1, 0.1, 10, -1)
		ColorfulMenu:addParam("haveFun", "Have fun!", SCRIPT_PARAM_INFO, "")
end

function OnTick()
	if ColorfulMenu.Enable then
		_G.DrawCircle = DrawRainbowCircle

		if os.clock() >= rClock then
			RAINBOW = ARGB(255, math.random(1, 255), math.random(1, 255), math.random(1, 255))
			rClock = os.clock() + ColorfulMenu.interval
		end
	else
		_G.DrawCircle = _G.oldDrawCircle 
	end
end

function DrawRainbowCircle(x, y, z, range)
	return _G.oldDrawCircle(x, y, z, range, RAINBOW)
end
