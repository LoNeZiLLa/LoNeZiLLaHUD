--------------------------------------------------------------------------------
-- game constants
--------------------------------------------------------------------------------
STATE_DISCONNECTED = 0
STATE_CONNECTING = 1
STATE_CONNECTED = 2

-- see world.gameState
GAME_STATE_WARMUP = 0
GAME_STATE_ACTIVE = 1
GAME_STATE_ROUNDPREPARE = 2
GAME_STATE_ROUNDACTIVE = 3
GAME_STATE_ROUNDCOOLDOWN_SOMEONEWON = 4
GAME_STATE_ROUNDCOOLDOWN_DRAW = 5
GAME_STATE_GAMEOVER = 6

-- see players[1].state
PLAYER_STATE_INGAME = 1
PLAYER_STATE_SPECTATOR = 2
PLAYER_STATE_EDITOR = 3
PLAYER_STATE_QUEUED = 4

-- see pickupTimers[1].type
PICKUP_TYPE_HEALTH100 = 43
PICKUP_TYPE_ARMOR50 = 51
PICKUP_TYPE_ARMOR100 = 52
PICKUP_TYPE_ARMOR150 = 53
PICKUP_TYPE_POWERUPCARNAGE = 60

--------------------------------------------------------------------------------
-- nano constants
--------------------------------------------------------------------------------
NVG_ALIGN_LEFT = 0
NVG_ALIGN_CENTER = 1
NVG_ALIGN_RIGHT = 2

NVG_ALIGN_BASELINE = 0
NVG_ALIGN_TOP = 1
NVG_ALIGN_MIDDLE = 2
NVG_ALIGN_BOTTOM = 3

NVG_SOLID = 1
NVG_HOLE = 2

NVG_CCW = 1
NVG_CW = 2

FONT_HEADER = "oswald-bold";
FONT_HUD = "Solaria";
FONT_TEXT = "roboto-regular";
FONT_TEXT_BOLD = "roboto-bold";
FONT_SIZE_DEFAULT = 24;
FONT_SIZE_SMALL = 22;

--------------------------------------------------------------------------------
-- util functions
--------------------------------------------------------------------------------
function Color(r, g, b, a)
	if a == nil then
		a = 255
	end
	local c = {};
	c.r = r;
	c.g = g;
	c.b = b;
	c.a = a;
	return c;
end
function lerp(a, b, k)
	return a * (1 - k) + b * k;
end

--------------------------------------------------------------------------------
-- takes a raw time from Reflex in ms, and converts to minutes, seconds
--------------------------------------------------------------------------------
function FormatTime(time)
	local t = {};

	t.seconds = math.floor((time + 999) / 1000);
	t.minutes = math.floor(t.seconds / 60);
	t.seconds = t.seconds - t.minutes * 60;
	return t;
end

--------------------------------------------------------------------------------
-- get the player in question (the one we're watching through the camera)
--------------------------------------------------------------------------------
function getPlayer()
	if playerIndexCameraAttachedTo < 1 then
		return nil;
	end

	return players[playerIndexCameraAttachedTo];
end

--------------------------------------------------------------------------------
-- get LOCAL player, this may be different to getPlayer() when we're speccing someone
--------------------------------------------------------------------------------
function getLocalPlayer()
	return players[playerIndexLocalPlayer];
end

--------------------------------------------------------------------------------
-- get the first player alive
--------------------------------------------------------------------------------
function getPlayerAlive()
	for k, player in pairs(players) do
		if (player.health > 0) and (player.state == PLAYER_STATE_INGAME) then
			return player;
		end
	end

	return nil;
end

--------------------------------------------------------------------------------
-- check HUD should be shown
--------------------------------------------------------------------------------
function shouldShowHUD()

    local player = getPlayer();

    if player == nil
       or player.state == PLAYER_STATE_EDITOR
       or player.state == PLAYER_STATE_SPECTATOR
       or player.health <= 0 
       or world.gameState == GAME_STATE_GAMEOVER
       or consoleGetVariable("cl_show_hud") == 0
       or isInMenu()
       or not player.connected
       then return false end;

    return true;
end

--------------------------------------------------------------------------------
-- check PlayerStatus should be shown
--------------------------------------------------------------------------------
function shouldShowStatus()

    local player = getPlayer();

    if player == nil
       or player.state == PLAYER_STATE_EDITOR
       or world.gameState == GAME_STATE_GAMEOVER
       or consoleGetVariable("cl_show_hud") == 0
       or isInMenu()
       or showScores
       or not player.connected
       then return false end;

    return true;
end

--------------------------------------------------------------------------------
-- ui constants
--------------------------------------------------------------------------------
UI_HOVER_BORDER_COLOR = Color(252,56,32,102);
UI_COLOR_RED = Color(128, 16, 8);
UI_DEFAULT_BUTTON_HEIGHT = 35;
UI_SCROLLBAR_WIDTH = 12;
UI_DISABLED_TEXT = 110;
UI_MOUSE_SCROLL_SPEED = 10;
UI_WINDOW_HEADER_HEIGHT = 38;
UI_SUBHEADER_HEIGHT = 50;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function uiWindow(title, x, y, w, h)
	local cornerRadius = 3;
	local headerHeight = UI_WINDOW_HEADER_HEIGHT;
	local fonty = headerHeight/2 + 1;

	-- we dont read the result ever, but we want to stop clicks going through the window into the game
	local m = mouseRegion(x, y, w, h);

	nvgSave();
	
	-- window
	nvgBeginPath();
	nvgRoundedRect(x, y, w, h, cornerRadius);
	nvgFillColor(Color(34, 36, 40, 242));
	nvgFill();

	-- drop shadow
	nvgBeginPath();
	nvgRect(x - 10, y - 10, w + 20, h + 30);
	nvgRoundedRect(x, y, w, h, cornerRadius);
	nvgPathWinding(NVG_HOLE);
	nvgFillBoxGradient(
		x, y + 2, w, h, cornerRadius * 2, 10,
		Color(0, 0, 0, 128),
		Color(0, 0, 0, 0));
	nvgFill();
	
	---- header
	nvgBeginPath();
	nvgRoundedRect(x + 1, y + 1, w - 2, headerHeight, cornerRadius - 1);
	nvgFillLinearGradient(
		x, y, x, y + 15,
		Color(255, 255, 255, 8),
		Color(0, 0, 0, 16));
	nvgFill();
	nvgBeginPath();
	nvgMoveTo(x + 0.5, y + 0.5 + headerHeight);
	nvgLineTo(x + 0.5 + w - 1, y + 0.5 + headerHeight);
	nvgStrokeColor(Color(0, 0, 0, 32));
	nvgStroke();
	
	nvgFontSize(26);
	nvgFontFace(FONT_TEXT_BOLD);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
	
	nvgFontBlur(2);
	nvgFillColor(Color(0, 0, 0, 128));
	nvgText(x + w / 2, y + fonty + 1, title);
	
	nvgFontBlur(0);
	nvgFillColor(Color(220, 220, 220, 160));
	nvgText(x + w / 2, y + fonty, title);

	nvgRestore();
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function uiButton(text, icon, x, y, w, h, col, optionalId, enabled)
	local cornerRadius = 5.0;
	local tw = 0;
	local iw = 0;
	if col == nil then
		col = Color(0,0,0,0);
	end

	-- need to pass a number in :) this id is only required if you have a for-loop of buttons or
	-- something which makes their callstack look identical
	if optionalId == nil then
		optionalId = 0;
	end

	local isBlack = col.r == 0 and col.g == 0 and col.b == 0 and col.a == 0;
	local m = {};
	if enabled == false then 
		m.leftHeld = false;
		m.mouseInside = false;
		m.leftUp = false;
		m.hoverAmount = 0;
	else
		m = mouseRegion(x, y, w, h, optionalId);
	end
	nvgSave();

	-- bg
	nvgBeginPath();
	nvgRoundedRect(x + 1, y + 1, w - 2, h - 2, cornerRadius - 1);
	if not isBlack then
		nvgFillColor(col);
		nvgFill();
	end
	local alpha = 32;
	if isBlack then
		alpha = 16;
	end
	if m.leftHeld and m.mouseInside then
		nvgFillBoxGradient(
			x + 5, y + 5, w - 10, h, cornerRadius * 2, 10,
			Color(255, 255, 255, alpha),
			Color(0, 0, 0, alpha));
	else
		nvgFillLinearGradient(
			x, y, x, y + h, 
			Color(255, 255, 255, alpha),
			Color(0, 0, 0, alpha));
	end
	nvgFill();

	-- default border colour
	local bc = Color(0,0,0,48);
	-- modify when hovering
	bc.r = lerp(bc.r, UI_HOVER_BORDER_COLOR.r, m.hoverAmount);
	bc.g = lerp(bc.g, UI_HOVER_BORDER_COLOR.g, m.hoverAmount);
	bc.b = lerp(bc.b, UI_HOVER_BORDER_COLOR.b, m.hoverAmount);
	bc.a = lerp(bc.a, UI_HOVER_BORDER_COLOR.a, m.hoverAmount);

	-- border
	nvgBeginPath();
	nvgRoundedRect(x + 0.5, y + 0.5, w - 1, h - 1, cornerRadius - 0.5);
	nvgStrokeColor(bc);
	nvgStroke();

	local c = 255;
	if enabled == false then
		c = UI_DISABLED_TEXT;
	end

	-- icon
	nvgFontSize(24);
	nvgFontFace(FONT_TEXT_BOLD);
	tw = nvgTextWidth(text);
	if icon ~= nil then
		local iw = 16;
		local ix = x + w*0.5 - tw*0.5 - iw*0.75;
		local iy = y + h*0.5;
		nvgFillColor(Color(c, c, c, 96));
		nvgSvg(icon, ix, iy, iw);
	end

	-- text
	local fontx = x + w*0.5 - tw*0.5 + iw*0.25;
	local fonty = y + h*0.5;
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	nvgFillColor(Color(0, 0, 0, 160));
	nvgText(fontx, fonty - 1, text, NULL);
	nvgFillColor(Color(c, c, c, 160));
	nvgText(fontx, fonty, text, NULL);
	
	nvgRestore();

	return m.leftUp;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function uiButtonVertical(text, x, y, w, h, col, optionalId, enabled)
	local cornerRadius = 5.0;
	local iw = 0;
	if col == nil then
		col = Color(0,0,0,0);
	end

	-- need to pass a number in :) this id is only required if you have a for-loop of buttons or
	-- something which makes their callstack look identical
	if optionalId == nil then
		optionalId = 0;
	end

	local isBlack = col.r == 0 and col.g == 0 and col.b == 0 and col.a == 0;
	local m = {};
	if enabled == false then 
		m.leftHeld = false;
		m.mouseInside = false;
		m.leftUp = false;
		m.hoverAmount = 0;
	else
		m = mouseRegion(x, y, w, h, optionalId);
	end
	nvgSave();

	-- bg
	nvgBeginPath();
	nvgRoundedRect(x + 1, y + 1, w - 2, h - 2, cornerRadius - 1);
	if not isBlack then
		nvgFillColor(col);
		nvgFill();
	end
	local alpha = 32;
	if isBlack then
		alpha = 16;
	end
	if m.leftHeld and m.mouseInside then
		nvgFillBoxGradient(
			x + 5, y + 5, w - 10, h, cornerRadius * 2, 10,
			Color(255, 255, 255, alpha),
			Color(0, 0, 0, alpha));
	else
		nvgFillLinearGradient(
			x, y, x, y + h, 
			Color(255, 255, 255, alpha),
			Color(0, 0, 0, alpha));
	end
	nvgFill();

	-- default border colour
	local bc = Color(0,0,0,48);
	-- modify when hovering
	bc.r = lerp(bc.r, UI_HOVER_BORDER_COLOR.r, m.hoverAmount);
	bc.g = lerp(bc.g, UI_HOVER_BORDER_COLOR.g, m.hoverAmount);
	bc.b = lerp(bc.b, UI_HOVER_BORDER_COLOR.b, m.hoverAmount);
	bc.a = lerp(bc.a, UI_HOVER_BORDER_COLOR.a, m.hoverAmount);

	-- border
	nvgBeginPath();
	nvgRoundedRect(x + 0.5, y + 0.5, w - 1, h - 1, cornerRadius - 0.5);
	nvgStrokeColor(bc);
	nvgStroke();

	local c = 255;
	if enabled == false then
		c = UI_DISABLED_TEXT;
	end

	nvgFontSize(24);
	nvgFontFace(FONT_TEXT_BOLD);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
	local tb = nvgTextBounds("W");
	--local tw = tb.maxx - tb.minx;
	local th = tb.maxy - tb.miny-4;
	local len = string.len(text);

	for i = 1, len do
		local textOffsetY = i - ((len + 1) / 2);
		local fontx = x + w*0.5;
		local fonty = y + h*0.5 + textOffsetY * th;

		local char = string.sub(text, i, i);	
		nvgFillColor(Color(0, 0, 0, 160));
		nvgText(fontx, fonty - 1, char, NULL);
		nvgFillColor(Color(c, c, c, 160));
		nvgText(fontx, fonty, char, NULL);
	end
	
	nvgRestore();

	return m.leftUp;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function uiSlider(x, y, w, min, max, value, optionalId, enabled)
	-- want consistent heights really
	local h = 35;

	-- pos 0->1
	local range = (max - min);
	local pos = (value - min) / range;
	pos = math.max(pos, 0);
	pos = math.min(pos, 1);

	local cy = y + math.floor(h*0.5);
	local kr = math.floor(h*0.25);
	local kx = x + math.floor(pos*w);
	
	-- mouse stuff
	local m = {};
	if enabled == false then
		m.hoverAmount = 0;
		m.leftUp = false;
		m.leftHeld = false;
	else
		m = mouseRegion(kx - kr, cy - kr, kr * 2, kr * 2, optionalId);
	end

	nvgSave();

	local knobColor = 255;
	local slotAlpha = 128;
	local borderAlpha = 92;
	if enabled == false then
		knobColor = 50;
		slotAlpha = 32;
		borderAlpha = 32;
	end

	-- Slot
	local slotWidth = 2.5;
	nvgBeginPath();
	nvgRoundedRect(x, cy - slotWidth, w, slotWidth*2, slotWidth);
	nvgFillBoxGradient(
		x, cy - slotWidth + 1, w, slotWidth*2, slotWidth, slotWidth,
		Color(0, 0, 0, 32),
		Color(0, 0, 0, slotAlpha));
	nvgFill();

	-- Knob Shadow
	nvgBeginPath();
	nvgRect(x + math.floor(pos*w) - kr - 5, cy - kr - 5, kr * 2 + 5 + 5, kr * 2 + 5 + 5 + 3);
	nvgCircle(x + math.floor(pos*w), cy, kr);
	nvgPathWinding(NVG_HOLE);
	nvgFillRadialGradient(
		x + math.floor(pos*w), cy + 1, kr - 3, kr + 3, 
		Color(0, 0, 0, 64), 
		Color(0, 0, 0, 0));
	nvgFill();

	--Knob
	nvgBeginPath();
	nvgCircle(kx, cy, kr-1);
	nvgFillColor(Color(40, 43, 48, 255));
	nvgFill();
	nvgFillLinearGradient(
		x, cy - kr, x, cy + kr, 
		Color(knobColor, knobColor, knobColor, 16),
		Color(0, 0, 0, 16));
	nvgFill();
	
	-- default border colour
	local bc = Color(0,0,0,borderAlpha);
	-- modify when hovering
	bc.r = lerp(bc.r, UI_HOVER_BORDER_COLOR.r, m.hoverAmount);
	bc.g = lerp(bc.g, UI_HOVER_BORDER_COLOR.g, m.hoverAmount);
	bc.b = lerp(bc.b, UI_HOVER_BORDER_COLOR.b, m.hoverAmount);
	bc.a = lerp(bc.a, UI_HOVER_BORDER_COLOR.a, m.hoverAmount);

	--border
	nvgBeginPath();
	nvgCircle(x + math.floor(pos*w), cy, kr - 0.5);
	nvgStrokeColor(bc);
	nvgStroke();

	nvgRestore();

	if m.leftHeld then
		-- get the desired position in Nx1080 viewport
		local desiredKnobX = m.mousex;

		-- convert this into desiredValue
		local desiredValue = ((desiredKnobX - x) / w) * range + min;

		-- and store
		value = desiredValue;
		value = math.min(value, max);
		value = math.max(value, min);
	end
	return value;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function uiProgressBar(x, y, w, h, percentage)
	local cornerRadius = h/2;
	local tw = 0;

	nvgSave();

	-- under
	local slotWidth = h/2;
	nvgBeginPath();
	nvgRoundedRect(x, y, w, slotWidth*2, cornerRadius);
	nvgFillColor(Color(25,25,25,255));
	nvgFill();

	-- over
	if percentage > 0 then
		nvgBeginPath();
		nvgRoundedRect(x + 2, y + 2, w * percentage - 4, h - 4, cornerRadius - 1);
		nvgFillColor(UI_COLOR_RED);
		nvgFill();
		nvgFillLinearGradient(
			x, y, x, y + h, 
			Color(255, 255, 255, 32),
			Color(0, 0, 0, 32));
		nvgFill();
	end

	-- border
	nvgBeginPath();
	nvgRoundedRect(x + 1, y + 1, w - 2, h - 2, cornerRadius - 1);
	nvgBeginPath();
	nvgRoundedRect(x + 0.5, y + 0.5, w - 1, h - 1, cornerRadius - 0.5);
	nvgStrokeColor(Color(0,0,0,48));
	nvgStroke();

	-- text
	local text = math.ceil(percentage * 100) .. "%";
	nvgFontSize(FONT_SIZE_DEFAULT);
	nvgFontFace(FONT_TEXT_BOLD);
	local fontx = x + w*0.5 - tw*0.5;
	local fonty = y + h*0.5;
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
	nvgFillColor(Color(0, 0, 0, 160));
	nvgText(fontx, fonty - 1, text, NULL);
	nvgFillColor(Color(255, 255, 255, 160));
	nvgText(fontx, fonty, text, NULL);
	
	nvgRestore();
end

--------------------------------------------------------------------------------
-- windowHeight: the height of the scrollbar (and window it represents)
-- itemsHeight: the height of everything that goes in the region
-- scrollBarData: persistent data which holds scrollbar state
--------------------------------------------------------------------------------
function uiScrollBar(x, y, windowHeight, itemsHeight, scrollBarData)
	local w = UI_SCROLLBAR_WIDTH;
	local cornerRadius = 2.5;

	if scrollBarData.dragOffsetY == nil then
		scrollBarData.dragOffsetY = 0;
	end

	nvgSave();

	-- handle scroll knob
	local scrollStartY = 0;
	local scrollEndY = 1;
	local scrollEnabled = false;
	if itemsHeight <= windowHeight then
		-- not enough items => no scrolling
		-- clamp
		scrollBarData.dragOffsetY = 0;
	else
		-- we have scrolling!
		scrollStartY = scrollBarData.dragOffsetY / itemsHeight;
		scrollEndY = (scrollBarData.dragOffsetY + windowHeight) / itemsHeight;
		scrollEnabled = true;

		-- clamp at top
		if scrollBarData.dragOffsetY < 0 then
			scrollBarData.dragOffsetY = 0;
		end
		-- clamp at bottom
		if scrollBarData.dragOffsetY + windowHeight > itemsHeight then
			scrollBarData.dragOffsetY = itemsHeight - windowHeight;
		end
	end

	-- slot
	local slotWidth = w/2;
	nvgBeginPath();
	nvgRoundedRect(x, y, w, windowHeight, cornerRadius);
	nvgFillBoxGradient(
		x, y, slotWidth*2, windowHeight, cornerRadius, cornerRadius,
		Color(0, 0, 0, 32),
		Color(0, 0, 0, 128));
	nvgFill();

	-- mouse input for slot
	local mslot = mouseRegion(x, y, w, windowHeight);

	-- scroll knob
	local knobY = y + scrollStartY * windowHeight;
	local knobHeight = (scrollEndY - scrollStartY) * windowHeight;
	local m = mouseRegion(x, knobY, w, knobHeight);
	nvgBeginPath();
	nvgRoundedRect(x+1, knobY, w-2, knobHeight, cornerRadius);
	local a = 16;
	if m.hover and scrollEnabled then
		local c = Color(UI_COLOR_RED.r, UI_COLOR_RED.g, UI_COLOR_RED.b, UI_COLOR_RED.a);
		c.a = 128;
		nvgFillColor(c);
		nvgFill();
	else
		nvgFillColor(Color(255, 255, 255, 30));
		nvgFill();
	end
	nvgFillLinearGradient(
		x, knobY, x, knobY + knobHeight, 
		Color(255, 255, 255, a),
		Color(0, 0, 0, a));
	nvgFill();

	-- knob grab
	if m.leftDown then
		scrollBarData.grabScreenY = m.mousey;
		scrollBarData.grabDragOffsetY = scrollBarData.dragOffsetY;
	end

	-- knob pull
	if m.leftHeld then
		-- offset in screen coords
		local mouseMovedY = m.mousey - scrollBarData.grabScreenY;

		-- convert to item space coords
		local scale = itemsHeight / windowHeight;
		local offset = scale * mouseMovedY;

		-- apply offset
		scrollBarData.dragOffsetY = scrollBarData.grabDragOffsetY + offset;
	
	elseif m.mouseWheel ~= 0 then
		-- wheel
		scrollBarData.dragOffsetY = scrollBarData.dragOffsetY - m.mouseWheel * UI_MOUSE_SCROLL_SPEED;
	else
		-- wheel for slot
		scrollBarData.dragOffsetY = scrollBarData.dragOffsetY - mslot.mouseWheel * UI_MOUSE_SCROLL_SPEED;
	end

	-- clamp
	scrollBarData.dragOffsetY = math.min(scrollBarData.dragOffsetY, itemsHeight - windowHeight);
	scrollBarData.dragOffsetY = math.max(scrollBarData.dragOffsetY, 0);

	nvgRestore();
end
	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function uiSubHeader(x, y, w)
	local h = UI_SUBHEADER_HEIGHT;

	nvgBeginPath();
	nvgRect(x, y, w, h);
	nvgFillLinearGradient(
		x, y, x, y + h, 
		Color(255, 255, 255, 16),
		Color(0, 0, 0, 16));
	nvgFill(vg);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function uiToolTip(x, y, text)
	local pad = 3;

	x = x + 15;

	nvgFontSize(FONT_SIZE_SMALL);
	nvgFontFace(FONT_TEXT_BOLD);
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_TOP);
	
	local bounds = nvgTextBounds(text);
	local rectx = x + bounds.minx - pad;
	local recty = y + bounds.miny - pad;
	local rectw = bounds.maxx - bounds.minx + pad * 2;
	local recth = bounds.maxy - bounds.miny + pad * 2;

	nvgSave();
	
	nvgBeginPath();
	nvgRoundedRect(rectx, recty, rectw, recth, 3);
	local col = Color(30, 30, 30, 230);
	nvgFillColor(col);
	nvgFill(vg);
	nvgStrokeColor(Color(200, 200, 30, 170));
	nvgStrokeWidth(.5);
	nvgStroke();

	nvgFontBlur(2);
	nvgFillColor(Color(0, 0, 0, 128));
	nvgText(x, y, text);
	
	nvgFontBlur(0);
	nvgFillColor(Color(220, 220, 220, 160));
	nvgText(x, y, text);

	nvgRestore();
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function uiCheckBox(value, text, x, y, optionalId, enabled)
	local h = 35;
	local c = 255;

	if enabled == false then c = UI_DISABLED_TEXT end;

	nvgFontSize(FONT_SIZE_SMALL);
	nvgFontFace(FONT_TEXT);
	nvgFillColor(Color(c, c, c, 160));

	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	nvgText(x + 28, y + h*0.5, text);

	local w = 28 + nvgTextWidth(text);

	local m = {};
	if enabled == false then
		m.hoverAmount = 0;
		m.leftUp = false;
	else
		m = mouseRegion(x, y, w, h, optionalId);
	end

	local px = x + 1;
	local py = y + math.floor(h*0.5) - 9;
	local pr = 22;
	nvgBeginPath();
	nvgRoundedRect(px, py, 18, 18, 8);
	nvgFillBoxGradient(px, py + 1, 18, 18, 3, 3, Color(0, 0, 0, 32), Color(0, 0, 0, 92));
	nvgFill();

	if m.hover then
		local c= Color(0,0,0,0);
		c.r = lerp(c.r, UI_HOVER_BORDER_COLOR.r, m.hoverAmount);
		c.g = lerp(c.g, UI_HOVER_BORDER_COLOR.g, m.hoverAmount);
		c.b = lerp(c.b, UI_HOVER_BORDER_COLOR.b, m.hoverAmount);
		c.a = lerp(c.a, UI_HOVER_BORDER_COLOR.a, m.hoverAmount);
		nvgStrokeColor(c);
		nvgStroke();
	end

	local valueColor = Color(UI_COLOR_RED.r, UI_COLOR_RED.g, UI_COLOR_RED.b);
	if enabled == false then
		valueColor.r = valueColor.r * .5;
		valueColor.g = valueColor.g * .5;
		valueColor.b = valueColor.b * .5;
	end
	if value then	
		nvgBeginPath();
		nvgRoundedRect(px+2, py+2, 18-4, 18-4, 12);
		nvgFillBoxGradient(
			px, py, pr, pr, 3*2, 10,
			valueColor,
			Color(0, 0, 0, 0));
		--nvgFillColor(UI_COLOR_RED);
		nvgFill();
	end

	if m.leftUp then
		value = not value;
	end

	return value;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
__editBox_flash = 0; -- hmm hidden globals
__editBox_offetX = 0;
__editBox_offetX_id = 0;
function uiEditBox(text, x, y, w, optionalId, enabled)
	local h = 35;
	local padx = h*0.3;

	local c = 255;
	local t = nil;
	if enabled == false then
		c = UI_DISABLED_TEXT;
		t.text = text;
		t.focus = false;
		t.apply = false;
	else
		t = textRegion(x, y, w, h, text, optionalId);
	end

	nvgSave();

	-- Edit
	nvgBeginPath();
	nvgRoundedRect(x+1,y+1, w-2,h-2, 5-1);
	nvgFillBoxGradient(x+1, y+1+1.5, w-2, h-2, 3,4, Color(c,c,c,32), Color(32,32,32,32));
	nvgFill();
	
	-- default border colour
	local bc = Color(0,0,0,48);
	-- modify when hovering
	bc.r = lerp(bc.r, UI_HOVER_BORDER_COLOR.r, t.hoverAmount);
	bc.g = lerp(bc.g, UI_HOVER_BORDER_COLOR.g, t.hoverAmount);
	bc.b = lerp(bc.b, UI_HOVER_BORDER_COLOR.b, t.hoverAmount);
	bc.a = lerp(bc.a, UI_HOVER_BORDER_COLOR.a, t.hoverAmount);

	-- border
	nvgBeginPath();
	nvgRoundedRect(x+0.5,y+0.5, w-1,h-1, 5-0.5);
	nvgStrokeColor(bc);
	nvgStroke();
	
	-- apply font & calculate cursor pos
	nvgFontSize(FONT_SIZE_SMALL);
	nvgFontFace(FONT_TEXT);
	nvgFillColor(Color(c,c,c,92));
	local textUntilCursor = string.sub(t.text, 0, t.cursor);
	local textWidthAtCursor = nvgTextWidth(textUntilCursor);
	
	-- text positioning (this may be a frame behind at this point, but it used for input, one what is on the screen, so that's fine)
	local offsetx = 0;
	if t.focus then -- only use __editBox_offetX if we have focus
		if __editBox_offetX_id == t.id then
			offsetx = __editBox_offetX;
		else
			__editBox_offetX_id = t.id;
			offsetx = 0;
		end
	end
	local textx = x+padx + offsetx;
	local texty = y+h*0.5;

	-- handle clicking inside region to change cursor location / drag select multiple characters
	-- (note: this can update the cursor inside t)
	if (t.leftDown or t.leftHeld) and t.mouseInside then
		local mousex = t.mousex;
		local lentext = string.len(t.text);
		local prevDistanceFromCursor;
		local newCusror = lentext;
		for l = 0, lentext do
			local s = string.sub(t.text, 0, l);
			local tw = nvgTextWidth(s);
			local endtext = textx + tw;

			local distanceFromCursor = math.abs(endtext - t.mousex);

			-- was prev distance closer?
			if l > 0 then
				if distanceFromCursor > prevDistanceFromCursor then
					newCusror = l-1;
					break;
				end
			end

			prevDistanceFromCursor = distanceFromCursor;
		end

		-- drag selection only if we were holding the mouse (and didn't just push it now), 
		-- otherwise it's a click and we just want to go to that cursor
		local dragSelection = t.leftHeld and not t.leftDown;

		-- set cursor, and read updated cursors for rendering below
		t.cursorStart, t.cursor = textRegionSetCursor(t.id, newCusror, dragSelection);
	end

	-- update these, cursor may have changed!
	textUntilCursor = string.sub(t.text, 0, t.cursor);
	textWidthAtCursor = nvgTextWidth(textUntilCursor);

	-- keep the cursor inside the bounds of the text entry
	if t.focus then
		-- the string buffer can be wider than this edit box, when that happens, we need to 
		-- clip the texture, but also ensure that the cursor remains visible
		local cursorx = (x+padx+offsetx) + textWidthAtCursor;
		local endx = (x+w-padx);
		local cursorpast = cursorx - endx;
		if cursorpast > 0 then
			offsetx = offsetx - cursorpast;
		end

		local startx = x+padx;
		local cursorearly = startx - cursorx;
		if cursorearly > 0 then
			offsetx = offsetx + cursorearly;
		end

		-- store into common global var, we're the entry with focus
		__editBox_offetX = offsetx;
		__editBox_offetX_id = t.id;
	else
		-- no-longer holding it, reset
		if __editBox_offetX_id == t.id then
			__editBox_offetX_id = 0;
		end
	end

	-- update these, offsset may have changed!
	textx = x+padx + offsetx;
	
	-- scissor text & cursor etc
	local halfpadx = padx*.5;
	nvgScissor(x+halfpadx, y, w-halfpadx*2, h);

	-- draw text
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	nvgText(textx, texty, t.text);

	-- cursor
	if t.focus then
		local cursorFlashPeriod = 0.25;

		__editBox_flash = __editBox_flash + deltaTime;

		-- if cursor moves, restart flash
		if t.cursorChanged then
			__editBox_flash = 0;
		end

		-- multiple selection, draw selection field
		if t.cursor ~= t.cursorStart then
			local textUntilCursorStart = string.sub(t.text, 0, t.cursorStart);
			local textWidthAtCursorStart = nvgTextWidth(textUntilCursorStart);
		
			local selx = math.min(textWidthAtCursor, textWidthAtCursorStart);
			local selw = math.abs(textWidthAtCursor - textWidthAtCursorStart);
			nvgBeginPath();
			nvgRect(textx + selx, texty - h * .35, selw, h * .7);
			nvgFillColor(Color(255, 192, 192, 128));
			nvgFill();	
		end

		-- flashing cursor
		if __editBox_flash < cursorFlashPeriod then
			nvgBeginPath();
			nvgMoveTo(textx + textWidthAtCursor, texty - h*.35);
			nvgLineTo(textx + textWidthAtCursor, texty + h*.35);
			nvgStrokeColor(Color(c,c,c,64));
			nvgStroke();
		else
			if __editBox_flash > cursorFlashPeriod*2 then
				__editBox_flash = 0;
			end
		end
	end

	nvgRestore();

	if t.apply then
		-- apply, return new value
		return t.text;
	elseif t.focus then
		-- return value at time of focus started
		return t.textInitial;
	else
		-- return value client passed in
		return text;
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function uiLabel(text, x, y, enabled)
	local h = 35;

	-- enabled is optional (so it can be nil)
	local c = 255;
	if enabled == false then c = UI_DISABLED_TEXT; end;

	nvgSave();

	nvgFontSize(FONT_SIZE_DEFAULT);
	nvgFontFace(FONT_TEXT);
	nvgFillColor(Color(c, c, c, 128));

	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	nvgText(x, y + h*0.5, text);

	nvgRestore();
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function uiComboxBox(options, selection, x, y, w, comboBoxData, optionalId, enabled)
	local cornerRadius = 5;
	local h = 35;

	-- init bogus combox data
	if comboBoxData.opened == nil then
		comboBoxData.opened = false;
	end

	nvgSave();

	-- calcaulte popup height
	local itemHeight = 20;
	local ph = 0;
	if comboBoxData.opened then
		-- popup
		local px = x;
		local py = y + h;
		local pw = w;

		-- calc height
		local count = 0;
		for k, v in pairs(options) do 
			count = count + 1;
		end			
		ph = count * itemHeight;
	end	

	-- background & outline
	nvgBeginPath();
	nvgRoundedRect(x+1,y+1, w-2,h-2, cornerRadius-1);
	nvgFillLinearGradient(x,y,x,y+h, Color(255,255,255,16), Color(0,0,0,16));
	nvgFill();
	nvgBeginPath();
	nvgRoundedRect(x+0.5,y+0.5, w-1,h-1, cornerRadius-0.5);
	nvgStrokeColor(Color(0,0,0,48));
	nvgStroke();
	
	-- mouse
	local m = {};
	if enabled == false then 
		m.leftHeld = false;
		m.mouseInside = false;
		m.leftUp = false;
		m.hoverAmount = 0;
	else
		m = mouseRegion(x, y, w, h + ph, optionalId);
	end

	-- hover
	-- note: mouse region will grow to include popups when we've opened combo box
	if m.hoverAmount ~= 0 then
		local c= Color(0,0,0,0);
		c.r = lerp(c.r, UI_HOVER_BORDER_COLOR.r, m.hoverAmount);
		c.g = lerp(c.g, UI_HOVER_BORDER_COLOR.g, m.hoverAmount);
		c.b = lerp(c.b, UI_HOVER_BORDER_COLOR.b, m.hoverAmount);
		c.a = lerp(c.a, UI_HOVER_BORDER_COLOR.a, m.hoverAmount);
		nvgStrokeColor(c);
		nvgStroke();

		nvgBeginPath();
		nvgMoveTo(x+w-20, y+1);
		nvgLineTo(x+w-20, y+h-1);
		nvgStroke();
	end

	local c = 255;
	if enabled == false then c = UI_DISABLED_TEXT end;

	-- text
	nvgFontSize(FONT_SIZE_DEFAULT);
	nvgFontFace(FONT_TEXT);
	nvgFillColor(Color(c,c,c,160));
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	nvgText(x+h*0.3,y+h*0.5, selection);

	-- down arrow
	local ix = x + w - 16;
	local iy = y + h/2-3;
	local fy = 3; -- how fat
	local dy = 5; -- how far to step down
	local dx = 5; -- how far to step over
	nvgBeginPath();
	nvgMoveTo(ix, iy);
	nvgLineTo(ix, iy+fy);
	nvgLineTo(ix+dx, iy+fy+dy);
	nvgLineTo(ix+dx*2, iy+fy);
	nvgLineTo(ix+dx*2, iy);
	nvgLineTo(ix+dx, iy+dy);
	nvgLineTo(ix, iy);
	nvgFillColor(Color(c,c,c,160));
	nvgFill();

	local wasOpen = comboBoxData.opened;
	if m.leftDown then
		comboBoxData.opened = true;
	end

	-- combo opened?
	if comboBoxData.opened then

		-- popup
		local px = x;
		local py = y + h;
		local pw = w;

		-- draw border & bg
		nvgBeginPath();
		nvgRoundedRect(px, py, pw, ph, 3);
		nvgFillColor(Color(30, 30, 30, 230));
		nvgFill(vg);
		nvgStrokeColor(Color(200, 200, 30, 170));
		nvgStrokeWidth(.5);
		nvgStroke();
		
		-- draw items
		local iy = py;
		local foundSelection = false;
		for k, v in pairs(options) do 

			-- mouse inside this item?
			local mouseIn = 
				not foundSelection and
				(x <= m.mousex) and 
				(m.mousex <= (x + w)) and
				(iy <= m.mousey) and
				(m.mousey <= (iy + itemHeight));

			if mouseIn then

				-- draw bg behind selected item
				nvgBeginPath();
				nvgRect(x, iy, w, itemHeight-1);
				nvgFillColor(Color(128, 128, 128, 40));
				nvgFill();	
							
				-- handle selection
				if m.leftUp or m.leftDown then
					selection = v;
					comboBoxData.opened = false;
				end

				-- prevent multiple highlights right on the edges
				foundSelection = true;
			end
			
			-- draw text
			nvgFontSize(FONT_SIZE_SMALL);
			nvgFontFace(FONT_TEXT);
			nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);

			nvgFontBlur(2);
			nvgFillColor(Color(0, 0, 0, 128));
			nvgText(x+3, iy+itemHeight/2, v);
	
			nvgFontBlur(0);
			nvgFillColor(Color(220, 220, 220, 160));
			nvgText(x+3, iy+itemHeight/2, v);
			
			iy = iy + itemHeight;
		end
	end

	-- if not hovering, clear open state
	if not m.hover then
		comboBoxData.opened = false;
	end
	
	-- if down is pressed on top part on combo, we clear open state too
	if wasOpen and m.leftDown and comboBoxData.opened then
		comboBoxData.opened = false;
	end

	nvgRestore();

	return selection;
end

--------------------------------------------------------------------------------
-- item for uiScrollSelection()
--------------------------------------------------------------------------------
function uiScrollSelectionItem(x, y, row, item, isSelected, mouse, itemWidth, itemHeight)
	-- background
	nvgBeginPath();
	nvgRect(x, y, itemWidth, itemHeight);
	local col = Color(30, 30, 30, 128);
	if row % 2 == 0 then
		col.r = 60;
		col.g = 60;
		col.b = 60;
	end
	col.r = lerp(col.r, UI_COLOR_RED.r, mouse.hoverAmount);
	col.g = lerp(col.g, UI_COLOR_RED.g, mouse.hoverAmount);
	col.b = lerp(col.b, UI_COLOR_RED.b, mouse.hoverAmount);
	if isSelected then
		col.r = UI_COLOR_RED.r;
		col.g = UI_COLOR_RED.g;
		col.b = UI_COLOR_RED.b;
		col.a = 255;
	end
	nvgFillColor(col);
	nvgFill(vg);

	-- text
	nvgFontSize(FONT_SIZE_SMALL);
	nvgFontFace(FONT_TEXT_BOLD);
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	
	nvgFontBlur(2);
	nvgFillColor(Color(0, 0, 0, 128));
	nvgText(x+10, y + itemHeight / 2 + 1, item);
	
	nvgFontBlur(0);
	nvgFillColor(Color(220, 220, 220, 160));
	nvgText(x+10, y + itemHeight / 2, item);

	-- return true if selected
	return mouse.leftUp;
end

--------------------------------------------------------------------------------
-- generic scroll selection
--------------------------------------------------------------------------------
function uiScrollSelection(items, selection, x, y, w, h, scrollBarData, itemHeight, itemDrawFunction)
	
	-- alloc people to specify custom height
	if itemHeight == nil then
		itemHeight = 35;
	end;

	-- allow people to specify a special draw function
	if itemDrawFunction == nil then
		itemDrawFunction = uiScrollSelectionItem;
	end

	local mouseWheelScroll = 0;

	-- count items
	local itemCount = 0;
	for k, v in pairs(items) do
		itemCount = itemCount + 1;
	end			

	-- scrollbar (draw this first, it updates where we drag to, so there's not a frame of lag on scrollbar)
	local windowHeight = h;
	local itemsHeight = itemCount * itemHeight;
	uiScrollBar(x+w-UI_SCROLLBAR_WIDTH, y, windowHeight, itemsHeight, scrollBarData);

	-- draw maps
	local miny = y;
	local maxy = y + h;
	nvgScissor(x, miny, w, maxy-miny);
	local row = 0;
	local dragOffsetY = scrollBarData.dragOffsetY;
	local startY = y - dragOffsetY;
	for k, item in pairs(items) do 
		local top = miny + row * itemHeight - dragOffsetY;
		local bottom = miny + (row + 1) * itemHeight - dragOffsetY;

		if bottom > miny and top < maxy then
			local itemY = startY + row * itemHeight;

			-- clamp mouse region against scissor region
			local itemMinY = itemY+1;
			local itemMaxY = itemMinY + itemHeight-1;
			itemMinY = math.max(itemMinY, miny);
			itemMaxY = math.min(itemMaxY, maxy);
			if itemMinY >= itemMaxY then 
				itemMinY = viewport.height+1; -- hacky :S just throw region off screen
				itemMaxY = viewport.height+2; -- hacky :S just throw region off screen 
			end
			local itemWidth = w-UI_SCROLLBAR_WIDTH;
			local itemMouse = mouseRegion(x, itemMinY, itemWidth, itemMaxY - itemMinY, row);
	
			-- handle mouse wheel efficiently. we could loop through everything doing mouse detection then
			-- loop again doing 
			if itemMouse.mouseWheel ~= 0 and mouseWheelScroll == 0 then
				mouseWheelScroll = itemMouse.mouseWheel;
			end	

			if itemDrawFunction(x, itemY, row, item, item == selection, itemMouse, itemWidth, itemHeight) then
				selection = item;
			end
		end
		row = row + 1;
	end
	nvgResetScissor();

	-- if the mouse wheel scrolled, scroll dragOffsetY for NEXT frame, don't handle it half way down when we get to it
	if mouseWheelScroll ~= 0 then
		-- wheel
		scrollBarData.dragOffsetY = scrollBarData.dragOffsetY - mouseWheelScroll * UI_MOUSE_SCROLL_SPEED;

		-- clamp
		scrollBarData.dragOffsetY = math.min(scrollBarData.dragOffsetY, itemsHeight - windowHeight);
		scrollBarData.dragOffsetY = math.max(scrollBarData.dragOffsetY, 0);
	end

	-- border on top, bit dodgey
	nvgBeginPath();
	nvgRoundedRect(x, y, w, h, 3);
	nvgStrokeColor(Color(0, 0, 0, 48));
	nvgStroke();

	return selection;
end
