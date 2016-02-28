--[[


		 .o88b.  .d88b.  db       .d88b.  d8888b. d88888b db    db db           d8888b. d8888b.  .d8b.  db   d8b   db d888888b d8b   db  d888b  .d8888. 
		d8P  Y8 .8P  Y8. 88      .8P  Y8. 88  `8D 88'     88    88 88           88  `8D 88  `8D d8' `8b 88   I8I   88   `88'   888o  88 88' Y8b 88'  YP 
		8P      88    88 88      88    88 88oobY' 88ooo   88    88 88           88   88 88oobY' 88ooo88 88   I8I   88    88    88V8o 88 88      `8bo.   
		8b      88    88 88      88    88 88`8b   88~~~   88    88 88           88   88 88`8b   88~~~88 Y8   I8I   88    88    88 V8o88 88  ooo   `Y8b. 
		Y8b  d8 `8b  d8' 88booo. `8b  d8' 88 `88. 88      88b  d88 88booo.      88  .8D 88 `88. 88   88 `8b d8'8b d8'   .88.   88  V888 88. ~8~ db   8D 
		 `Y88P'  `Y88P'  Y88888P  `Y88P'  88   YD YP      ~Y8888P' Y88888P      Y8888D' 88   YD YP   YP  `8b8' `8d8'  Y888888P VP   V8P  Y888P  `8888Y' 


	Colorful Drawings - Randomize drawings until you get epilepsy!

	Changelog:
		February 28, 2016:
			- Renamed the script to "Colorful Drawings".
			- Added a menu where you can choose which function to "override", so it will randomize the color of that.
			- It now includes more than circles (Lines, Rectangles and so on).
	
		May 29, 2014 (3):
			- Added a new Color Changing Mode! (Many Thanks to Hellsing)
	
		May 29, 2014 (2):
			- Fixed a Bug.
	
		May 29, 2014 (1):
			- First Release.

]]--
local rClock = 0

function OnLoad()
	NewFunctions =
	{
		["DrawArrow"] =
			function(v1, v2, c1, c2, c3, color)
				color = RandomizeColor(color)
				
				OldFunctions["DrawArrow"](v1, v2, c1, c2, c3, color)
			end,
		["DrawCircle"] =
			function(x, y, z, size, color)
				color = RandomizeColor(color)
				
				OldFunctions["DrawCircle"](x, y, z, size, color)
			end,
		["DrawLine"] =
			function(x1, y1, x2, y2, width, color)
				color = RandomizeColor(color)
				
				OldFunctions["DrawLine"](x1, y1, x2, y2, width, color)
			end,
		["DrawLines"] =
			function(object, l, color)
				color = RandomizeColor(color)
				
				OldFunctions["DrawLines"](object, l, color)
			end,
		["DrawLines2"] =
			function(points, width, color)
				color = RandomizeColor()
				
				OldFunctions["DrawLines2"](points, width, color)
			end,
		["DrawRectangle"] =
			function(x, y, width, height, color)
				color = RandomizeColor()
				
				OldFunctions["DrawRectangle"](x, y, width, height, color)
			end,
		["DrawText"] =
			function(text, size, x, y, color)
				color = RandomizeColor(color)
				
				OldFunctions["DrawText"](text, size, x, y, color)
			end,
		["DrawArrows"] =
			function(posStart, posEnd, size, color, splitSize)
				color = RandomizeColor(color)
				
				OldFunctions["DrawArrows"](posStart, posEnd, size, color, splitSize)
			end,
		["DrawRectangleOutline"] =
			function(x, y, width, height, color, borderWidth)
				color = RandomizeColor(color)
				
				OldFunctions["DrawRectangleOutline"](x, y, width, height, color, borderWidth)
			end,
		["DrawLineBorder3D"] =
			function(x1, y1, z1, x2, y2, z2, size, color, width)
				color = RandomizeColor(color)
				
				OldFunctions["DrawLineBorder3D"](x1, y1, z1, x2, y2, z2, size, color, width)
			end,
		["DrawLineBorder"] =
			function(x1, y1, x2, y2, size, color, width)
				color = RandomizeColor(color)
				
				OldFunctions["DrawLineBorder"](x1, y1, x2, y2, size, color, width)
			end,
		["DrawCircleMinimap"] =
			function(x, y, z, radius, width, color, quality)
				color = RandomizeColor(color)
				
				OldFunctions["DrawCircleMinimap"](x, y, z, radius, width, color, quality)
			end,
		["DrawCircle2D"] =
			function(x, y, radius, width, color, quality)
				color = RandomizeColor(color)
				
				OldFunctions["DrawCircle2D"](x, y, radius, width, color, quality)
			end,
		["DrawCircle3D"] =
			function(x, y, z, radius, width, color, quality)
				color = RandomizeColor(color)
				
				OldFunctions["DrawCircle3D"](x, y, z, radius, width, color, quality)
			end,
		["DrawLine3D"] =
			function(x1, y1, z1, x2, y2, z2, width, color)
				color = RandomizeColor(color)
				
				OldFunctions["DrawLine3D"](x1, y1, z1, x2, y2, z2, width, color)
			end,
		["DrawLines3D"] =
			function(points, width, color)
				color = RandomizeColor(color)
				
				OldFunctions["DrawLines3D"](points, width, color)
			end,
		["DrawTextA"] =
			function(text, size, x, y, color, halign, valign)
				color = RandomizeColor(color)
				
				OldFunctions["DrawTextA"](text, size, x, y, color, halign, valign)
			end,
		["DrawText3D"] =
			function(text, x, y, z, size, color, center)
				color = RandomizeColor(color)
				
				OldFunctions["DrawText3D"](text, x, y, z, size, color, center)
			end,
		["DrawHitBox"] =
			function(object, linesize, linecolor)
				color = RandomizeColor(linecolor)
				
				OldFunctions["DrawHitBox"](object, linesize, linecolor)
			end
	}
	
	OldFunctions = {}
	SmoothColors =
	{
		{ Current = 255, Min = 0, Max = 255, Mode = -1 },
		{ Current = 255, Min = 0, Max = 255, Mode = -1 },
		{ Current = 255, Min = 0, Max = 255, Mode = -1 },
	}

	ColorfulMenu = scriptConfig("Colorful Drawings", "CD")
		ColorfulMenu:addParam("Enable", "Enable!", SCRIPT_PARAM_ONOFF, true)
		ColorfulMenu:addSubMenu("Drawing Functions", "DF")
			ColorfulMenu.DF:addParam("MainFunctions", "Main Functions:", SCRIPT_PARAM_INFO, " ")
			ColorfulMenu.DF:addParam("DrawArrow", "DrawArrow", SCRIPT_PARAM_ONOFF, false)
			ColorfulMenu.DF:addParam("DrawCircle", "DrawCircle", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawLine", "DrawLine", SCRIPT_PARAM_ONOFF, false)
			ColorfulMenu.DF:addParam("DrawLines", "DrawLines", SCRIPT_PARAM_ONOFF, false)
			ColorfulMenu.DF:addParam("DrawLines2", "DrawLines2", SCRIPT_PARAM_ONOFF, false)
			ColorfulMenu.DF:addParam("DrawRectangle", "DrawRectangle", SCRIPT_PARAM_ONOFF, false)
			ColorfulMenu.DF:addParam("DrawText", "DrawText", SCRIPT_PARAM_ONOFF, false)
			ColorfulMenu.DF:addParam("Sep", "", SCRIPT_PARAM_INFO, " ")
			ColorfulMenu.DF:addParam("SecondaryFunctions", "Secondary Functions:", SCRIPT_PARAM_INFO, " ")
			ColorfulMenu.DF:addParam("DrawArrows", "DrawArrows", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawRectangleOutline", "DrawRectangleOutline", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawLineBorder3D", "DrawLineBorder3D", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawLineBorder", "DrawLineBorder", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawCircleMinimap", "DrawCircleMinimap", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawCircle2D", "DrawCircle2D", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawCircle3D", "DrawCircle3D", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawLine3D", "DrawLine3D", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawLines3D", "DrawLines3D", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawTextA", "DrawTextA", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawText3D", "DrawText3D", SCRIPT_PARAM_ONOFF, true)
			ColorfulMenu.DF:addParam("DrawHitBox", "DrawHitBox", SCRIPT_PARAM_ONOFF, true)
	ColorfulMenu:addParam("Interval", "Interval to change colors: ", SCRIPT_PARAM_SLICE, 1, 1, 10)
	ColorfulMenu:addParam("Mode", "Color Change Mode: ", SCRIPT_PARAM_LIST, 1, { "Rainbow", "Smooth Changing" })
	ColorfulMenu:addParam("HaveFun", "Have fun!", SCRIPT_PARAM_INFO, " ")

	for _, Param in pairs(ColorfulMenu.DF._param) do
		if string.find(Param.var, "Draw") then
			OldFunctions[Param.var] = rawget(_G, Param.var)
		end
	end
end

function OnTick()
	if not ColorfulMenu.Enable then
		for _, Param in pairs(ColorfulMenu.DF._param) do
			if string.find(Param.var, "Draw") then
				_G[Param.var] = OldFunctions[Param.var]
			end
		end
		return
	end
	
	for _, Param in pairs(ColorfulMenu.DF._param) do
		if string.find(Param.var, "Draw") then
			if ColorfulMenu.DF[Param.var] then
				_G[Param.var] = NewFunctions[Param.var]
			else
				_G[Param.var] = OldFunctions[Param.var]
			end
		end
	end
	
	if os.clock() >= rClock then
		MixColors()

		rClock = os.clock() + (ColorfulMenu.Interval / 100)
	end
end

function MixColors()
	for i = 1, #SmoothColors do
		local Color = SmoothColors[i]
		
		Color.Current = Color.Current + Color.Mode * i
		if Color.Current < Color.Min then
			Color.Current = Color.Min
			Color.Mode = 1
		elseif Color.Current > Color.Max then
			Color.Current = Color.Max
			Color.Mode = -1
		end
	end
end

function RandomizeColor(color)
	return (ColorfulMenu.Mode == 1 and ARGB(color ~= nil and math.floor(color / 0x01000000) or 255, math.random(1, 255), math.random(1, 255), math.random(1, 255))) or ARGB(color ~= nil and math.floor(color / 0x01000000) or 255, SmoothColors[1].Current, SmoothColors[2].Current, SmoothColors[3].Current)
end
