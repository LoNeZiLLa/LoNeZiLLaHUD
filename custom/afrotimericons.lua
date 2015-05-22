require "base/internal/ui/reflexcore"

local function lerpLoop(a, b, k)	
	--patch for tables interpolates every value in table.
	if(type(b) == 'table') then
		local result = {};
		for i,v in pairs(b) do
			result[i] = lerpLoop(a[i], b[i], k);
		end
		return result;
	end
	k = k * 2;
	if(k < 1) then	
		return a * (1 - k) + b * k;
	else
	k = k - 1;
		return b * (1 - k) + a  * k;
	end			
end

local function checkDefaults(container, target)
	for k, v in pairs(container) do			
		if(type(v) == 'table') then checkDefaults(v, target);
		CheckSetDefaultValue(target, k, type(v), v);
		end
	end	 
end

local function copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end
	

local VERTICALTIMER = 1;
local LINETIMER = 2;

AFROPickupIcons =
{	
	canPosition = true,
	canHide = true,
	offset = {x = -200, y = 125},
	frame = { color = Color(0,0,0,0) };
	prevPickupTimers = {},
	interpolate = {},
	position = {
			x = 0,
			y = 0
	}
	,
	size = {
			spacing = 0;
			width = 400;
			height = 35; 			
			timer = {
					width = 35, height = 35
			};
	}
	,
	userData = {};
	defaultData = {	
			timers ={
			["inverse"] = false;
			[VERTICALTIMER] = {enabled = false;};
			[LINETIMER] = {enabled = false;};
			},
			text = {
					color = Color(255,255,255,255),
					sizes = {
							small = 20,
							med = 30,
							large = 45,
					},
					defaultFace = FONT_HUD,
					growAndShrink = true,
					flash = true,
					flashColor = COLORRED;
			},
			frame = { 
					padding = 5,
					color = Color(0,0,0,0),
					edgeRounding = 0,
					strokeWidth = 0,
					strokeColor = Color(0,0,0,0)
			},	
			icon = {
				growAndShrink = false, -- causes massive frame drops due to svgs.
				flashWhenAvailable = true,
				interpolated = true;
				notAvailAlpha = 32;
				availAlpha = 64;
				timerRunningAlpha = 12;
			},
	}
	,
	pickupsList = {
			[PICKUP_TYPE_ARMOR50] = {
				svg = "internal/ui/icons/armor",
				color = Color(0,255,0),
				},
			[PICKUP_TYPE_ARMOR100] = {
				svg = "internal/ui/icons/armor",
				color = Color(255,255,0),
			},
			[PICKUP_TYPE_ARMOR150] = {
				svg = "internal/ui/icons/armor",
				color = Color(255,0,0),
			},
			[PICKUP_TYPE_HEALTH100] = {
				svg = "internal/ui/icons/health",
				color = Color(60,80,255),
			},
			[PICKUP_TYPE_POWERUPCARNAGE] = {
				svg = "internal/ui/icons/carnage",
				color = Color(255,120,128),
			},
	},
	pickupExcludeList = {
			[PICKUP_TYPE_ARMOR50] = true;
	},
	--------------------------------------------
	--	DRAW!
	--------------------------------------------
	draw = function(self)
		--create/update a global gameTime value.
		_G.AFROgameTime = AFROgameTime and AFROgameTime + deltaTime or deltaTime;
		--Self draw Control
		if self.noDraw then self.init(self) end
		if(gamemodes[world.gameModeIndex].shortName == 'race') then return end;
	    -- Early out if HUD shouldnt be shown
	    if not shouldShowHUD() then return end;
	    
		-- count pick ups
		local pickupCount = 0;
		for k, v in pairs(pickupTimers) do
			if self.pickupsList[v.type] and not self.pickupExcludeList[v.type] then 
				pickupCount = pickupCount + 1;
			end
		end
		if pickupCount <= 0 then return end;
		
		--local timerX = frameLeft + self.userData.frame.padding * 2;	
		local timerX = self.position.x;
		local timerY = self.position.y;
		
		--hack to order pickups by type till fixed
		local pickups = copy(pickupTimers);
		table.sort(pickups, function(a,b)
			if a.type >= 60 or b.type >=60 then return a.type < b.type;
			elseif (a.type >= 50 and a.type < 60) or (b.type >= 50 and b.type < 60) then return a.type > b.type;
			else return a.type < b.type;
			end;
		end);
			
		local count = 0;
		
		local drawAsLine = self.userData.timers[LINETIMER].enabled;			
		if(drawAsLine) then 		
			-- Frame		
			local timersWidth = ((self.size.timer.width / 2 + self.size.spacing) * pickupCount)
			local frameLeft = timerX - timersWidth + self.size.timer.width / 2 + self.userData.frame.padding;
			local frameTop = -self.size.height;
			local frameRight = self.position.x;
			local frameBottom = self.position.y;
			self:drawRect(frameLeft, frameTop, 200 + timersWidth  , self.size.height, self.frame.color);
		end
		
		-- iterate pick ups
		for k,pickup in pairs(pickups) do
			if self.pickupsList[pickup.type] and not self.pickupExcludeList[pickup.type] then 					
				local drawVertical = drawAsLine and false or self.userData.timers[VERTICALTIMER].enabled;		
				local inverse = self.userData.timers.inverse;
				local vertTravelLength = inverse and -200 or 200;				
				self:drawTimer(drawVertical or drawAsLine, timerX, timerY, self.size.timer.width, self.size.timer.height, vertTravelLength, pickup, k);					
				if drawAsLine then 
					if(inverse) then
						timerX = timerX + self.size.timer.width / 2 + self.size.spacing;
					else
						timerX = timerX - self.size.timer.width / 2 - self.size.spacing;
					end;			
				end;					
				if not drawVertical and not drawAsLine then timerX = timerX + self.size.timer.width + self.size.spacing; end;			
				if drawVertical and not drawAsLine then timerY = timerY + self.size.timer.height + self.size.spacing; end;
			end
		end
		--copy of previous timers for comparisons
		self.prevPickupTimers = copy(pickups);
	end
	,
	--------------------------------------------
	--	Initialize!!
	--------------------------------------------
	initialize = function(self)	
		--Load userData!
		self.userData = loadUserData()		
		if(not self.userData) then 
			consolePerformCommand("ui_set_widget_offset AFROPickupIcons -200 125");			
		end;
		--Check against defaults!
		self:check();	
		
		--------------------------------------
		-- 	Helper function to drawRects
		--------------------------------------
		self.drawRect = function(self, x, y, w, h, fc, sc, sw)
		nvgBeginPath();	
				nvgRoundedRect(x, y, w, h, self.userData.frame.edgeRounding);	
				if sc then nvgStrokeColor(sc); end
				if sw then nvgStrokeWidth(sw); end
				if sc or sw then nvgStroke(); end;
				nvgFillColor(fc);
				nvgFill();
		end
		---------------------------------------
		--	Function to draw vertical timers
		---------------------------------------
		self.drawTimer = function(self, vert, x, y, w, h, l, pickup, i)
				--table to hold interpolation related stuff.
				self.interpolate[i] = self.interpolate[i] or {};
				local a = pickup.timeUntilRespawn  / 1000
				local mod = (a - math.floor(a)); -- interpolation value. for 1 second durations. based on pickups countdown.
				-- Icon
				local iconRadius = h * 0.5;
				local iconX = x + iconRadius;
				local iconY = y;					
				local iconColor = copy(self.pickupsList[pickup.type].color);
				-- Time
				local t = FormatTime(pickup.timeUntilRespawn);
				local time = t.seconds + 60 * t.minutes;
				local x = x + (w / 2) + iconRadius;		
				
				if time == 0 then
					time = "";
					iconColor.a = self.userData.icon.availAlpha;				
				end
				if not pickup.canSpawn or pickup.timeUntilRespawn > 30000 then
					time = pickup.canSpawn and time or "";
					iconColor.a = self.userData.icon.notAvailAlpha;
				end
				
				local position = vert and x or y;				
				-- Time until respawn lerp value.				
				local tur = pickup.timeUntilRespawn > 30000 and 1 or pickup.timeUntilRespawn / 30000;			
				-- interpolate icon moving back to position from running position.
				if(pickup.timeUntilRespawn <= 30000 and pickup.canSpawn and pickup.timeUntilRespawn > 0) then					
					position = (self.userData.icon.interpolated) and lerp(vert and x or y, l, tur) or position;
					iconColor.a = lerp(iconColor.a, self.userData.icon.timerRunningAlpha, tur);						
				elseif(pickup.timeUntilRespawn > 30000 or not pickup.canSpawn) then 
					--if timerUntilRespawn > 30 sec move to max lerp position.
					position = l
				end
				
				-- move icon to its timer running position over the next second.
				if(self.prevPickupTimers[i] and self.prevPickupTimers[i].timeUntilRespawn <= 0 and self.userData.icon.interpolated
						and pickup.timeUntilRespawn > 0 or self.interpolate[i] and self.interpolate[i].running) then	
					position = lerp(l * tur, vert and x or y, mod);
					self.interpolate[i].running = mod >= deltaTime * 2;
				end			
				
				-- simple alpha flash using gameTimer we built at start of draw() will create a 1 second timer.
				if(pickup.timeUntilRespawn <= 0 and pickup.canSpawn and self.userData.icon.flashWhenAvailable)then				
					local mod = (AFROgameTime - math.floor(AFROgameTime));
					iconColor.a = lerpLoop(iconColor.a, iconColor.a * 4, mod)
				end				
				
				-- simple grow/shrink / flash as approaching spawn.
				local activeIconRaidus = iconRadius;
				local textColor = copy(self.userData.text.color);
				local textSize = activeIconRaidus * 2;
				local activeIconColor = copy(iconColor);
				-- if timer less than 5 seconds left. flash/grow and shrink @ 1 sec pace. timer built from timeUntilRespawn, will be in sync with count down.
				if(t.seconds > 0 and t.seconds <= 5 and t.minutes < 1) then	
					if(self.userData.icon.growAndShrink) then
						activeIconRaidus = lerpLoop(activeIconRaidus, activeIconRaidus * 1.5, mod);
					end
					activeIconColor = lerpLoop(activeIconColor, Color(255,255,255, activeIconColor.a), mod);
					if(self.userData.text.growAndShrink) then
						textSize = lerpLoop(textSize, textSize * 1.5, mod);
					end
					if(self.userData.text.flash) then
						textColor = lerpLoop(textColor, self.userData.text.flashColor, mod);
					end
				end
							
				local svgName = "internal/ui/icons/armor";
				nvgFillColor(activeIconColor);
				--draw active icon.
				nvgSvg(self.pickupsList[pickup.type].svg, (vert) and position or x , ((vert) and y or position) - h / 2, activeIconRaidus);	
				if pickup.timeUntilRespawn > 0 then							
					--drawing a shadow of icon @ start/end position.
					iconColor.a = self.userData.icon.timerRunningAlpha;
					nvgFillColor(iconColor);				
					nvgSvg(self.pickupsList[pickup.type].svg, x , y - h / 2, iconRadius);	
				end	
				--draw time on icon.
				nvgFontSize(textSize);
				nvgFontFace(self.userData.text.defaultFace);
				nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
				nvgFillColor(textColor);				
				nvgText((vert) and position or x, ((vert) and y or position) - h / 2, time);			
		end		
	end
	,
	--------------------------------------------
	--	Draw Options!
	--------------------------------------------
	drawOptions = function(self, x, y)		
		local padding = 10;
		local textWidth = 100		
		local lineColor = Color(255,255,255,64)
		----------------------------------------
		-- Helpers
		----------------------------------------
		local step = function(y)
			return y + 35 + padding
		end
		local tab = function(x) 
			return  x + nvgTextWidth("1tab"); -- 4char tab haha.
		end
		local rtab = function(x) 
			return  x - nvgTextWidth("1tab");
		end
		local function editBox(x, y, width, label, value)			
			assert(type(value) == 'string' or type(value) == 'number', "editBox value must be string/number");
			if(label) then uiLabel(label, x, y); end;			
			return uiEditBox(value, x + nvgTextWidth(label or ""), y, textWidth);			
		end
		
		
		local styleX = x;
		local styleY = y;
		uiLabel("Style:", x, styleY);	
		styleX = styleX + nvgTextWidth("Style:") + padding;
		self.userData.timers.inverse = uiCheckBox(self.userData.timers.inverse, "Invert timer paths", styleX, styleY);		
		styleY = step(styleY);
		self.userData.icon.interpolated = uiCheckBox(self.userData.icon.interpolated, "Icon interpolated", styleX, styleY);		
		styleY = step(styleY);
		self.userData.timers[VERTICALTIMER].enabled = uiCheckBox(self.userData.timers[VERTICALTIMER].enabled, "Draw as vertical column", styleX, styleY);		
		styleY = step(styleY);
		if(self.userData.timers[VERTICALTIMER].enabled) then self.userData.timers[LINETIMER].enabled = false; end;
		self.userData.timers[LINETIMER].enabled = uiCheckBox(self.userData.timers[LINETIMER].enabled, "Draw timers in a line", styleX, styleY);	
		if(self.userData.timers[LINETIMER].enabled) then self.userData.timers[VERTICALTIMER].enabled = false; end;
		styleY = step(styleY);
		local iconX = x;
		local iconY = styleY;
		
		nvgBeginPath();
		nvgMoveTo(iconX, iconY - 5);
		nvgLineTo(iconX + 275 - 5, iconY - 5);
		nvgStrokeColor(lineColor);
		nvgStrokeWidth(1);
		nvgStroke();
		nvgClosePath();
		
		uiLabel("Icon:", iconX, iconY);
		iconX = styleX;
		self.userData.icon.flashWhenAvailable = uiCheckBox(self.userData.icon.flashWhenAvailable, "Flash when Available", iconX, iconY);
		iconY = step(iconY);
		uiLabel("Start Alpha", iconX, iconY);		
		local textX = iconX + nvgTextWidth("UnAvail Alpha") + padding;
		self.userData.icon.timerRunningAlpha = uiEditBox(self.userData.icon.timerRunningAlpha, textX, iconY, textWidth);
		iconY = step(iconY);
		uiLabel("End", iconX, iconY);		
		textX = iconX + nvgTextWidth("UnAvail Alpha") + padding;
		self.userData.icon.availAlpha = uiEditBox(self.userData.icon.availAlpha, textX, iconY, textWidth);
		iconY = step(iconY);
		uiLabel("UnAvailable", iconX, iconY);		
		textX = iconX + nvgTextWidth("UnAvail Alpha") + padding;
		self.userData.icon.notAvailAlpha = uiEditBox(self.userData.icon.notAvailAlpha, textX, iconY, textWidth);
		
		
		
		local tX = x + 275;
		local tY = y;
		
		nvgBeginPath();
		nvgMoveTo(tX - 5, tY);
		nvgLineTo(tX - 5, (self.optionsHeight or tY + 300));
		nvgStrokeColor(lineColor);
		nvgStrokeWidth(1);
		nvgStroke();
		nvgClosePath();
		
		uiLabel("Text:", tX, tY);
		tX = tab(tX);
		local colorTX = tX;
		tY = step(tY);
		uiLabel("Face:", tX, tY)
		textX = tX + nvgTextWidth("Face:") + padding;
		self.userData.text.defaultFace = uiEditBox(self.userData.text.defaultFace, textX, tY, textWidth)		
		tY = step(tY);
		self.userData.text.growAndShrink = uiCheckBox(self.userData.text.growAndShrink, "Grow And Shrink", tX, tY);			
		tY = step(tY);
		self.userData.text.flash = uiCheckBox(self.userData.text.flash, "Flash", tX, tY);	
		tY = step(tY);
		local colorTY = tY;
				
		local color = self.userData.text.color;		
		uiLabel("Color", colorTX, colorTY)		
		local colorTX2 = colorTX;
		colorTX = colorTX + nvgTextWidth("Flash Color") + padding
		color.r = editBox(colorTX, colorTY, textWidth, "R", color.r);
		colorTY = step(colorTY);

		color.g = editBox(colorTX, colorTY, textWidth, "G", color.g);
		colorTY = step(colorTY);
		
		color.b = editBox(colorTX, colorTY, textWidth, "B", color.b);
		colorTY = step(colorTY);
		
		color.a = round(editBox(colorTX, colorTY, textWidth, "A", color.a));
		
		colorTY = step(colorTY);
		self.userData.text.color = color;
		colorTX = colorTX2;
		local color2 = self.userData.text.color;		
		uiLabel("Flash Color", colorTX, colorTY)
		colorTX = colorTX + nvgTextWidth("Flash Color") + padding
		color2.r = editBox(colorTX, colorTY, textWidth, "R", color2.r);
		colorTY = step(colorTY);

		color2.g = editBox(colorTX, colorTY, textWidth, "G", color2.g);
		colorTY = step(colorTY);
		
		color2.b = editBox(colorTX, colorTY, textWidth, "B", color2.b);
		colorTY = step(colorTY);
		
		color2.a = round(editBox(colorTX, colorTY, textWidth, "A", color2.a));
		
		colorTY = step(colorTY);
		self.userData.text.flashColor = color2;
		
		--save changes.
		self.optionsHeight = colorTY;
		saveUserData(self.userData);
	end
	,	
	getOptionsHeight = function(self)
		return (self.optionsHeight or 0) + 100; --100 padding!
	end
	,
	check = function(self)		
		CheckSetDefaultValue(self, "userData", 'table', {});
		checkDefaults(self.defaultData, self.userData);
	end,
};

registerWidget("AFROPickupIcons");