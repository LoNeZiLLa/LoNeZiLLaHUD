require "base/internal/ui/reflexcore"

MenuBar =
{
	canPosition = false,
	canHide = false,
	isMenu = false,

	visibility = 1,
};
registerWidget("MenuBar");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function uiMenuBarButton(text, x, y, width, height, a)
	local fontx = x + width/2;
	local fonty = y + height - 35;

	local m = mouseRegion(x, y, width, height);

	-- glow
	-- nvgBeginPath();
	-- local glowColor = Color(183,0,0,0);
	-- glowColor.a = lerp(glowColor.a, 60, m.hoverAmount);
	-- nvgRect(x, y, width, height);
	-- nvgFillRadialGradient(width/2, 100, 0, 80, glowColor, Color(0,0,0,0))
	-- nvgFill();

	-- font colour, white
	local fontc = Color(96, 103, 113, a);
	
	-- Lerp when hovered
	fontc.r = lerp(fontc.r, 255, m.hoverAmount);
	fontc.g = lerp(fontc.g, 255, m.hoverAmount);
	fontc.b = lerp(fontc.b, 255, m.hoverAmount);

	-- Glow when pressed
	if m.leftHeld then
	nvgFontSize(35);
	nvgFontFace(FONT_HEADER);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);

	nvgFontBlur(40);
	nvgFillColor(Color(64,124,209));
	nvgText(fontx, fonty, text);
	end
	
	-- Underline when hovered
	local underlineColor = Color(0,0,0,0);
	underlineColor.r = lerp(underlineColor.r, 183, m.hoverAmount)
	underlineColor.a = lerp(underlineColor.a, 255, m.hoverAmount)
	
	nvgBeginPath();
	nvgRect(x, y + height - 5, width, 5);
	nvgFillColor(underlineColor);
	nvgFill();

	--nvgBeginPath();
	--nvgMoveTo(x, 0);
	--nvgLineTo(x, height);
	--nvgStrokeColor(90, 90, 90, 1);
	--nvgStrokeWidth(1);
	--nvgStroke();

	nvgFontSize(35);
	nvgFontFace(FONT_HEADER);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);

	nvgFontBlur(0);
	nvgFillColor(fontc);
	nvgText(fontx, fonty, text);

	return m.leftUp;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function MenuBar:draw()
	local showMenuBar = clientGameState == STATE_DISCONNECTED or isInMenu();
	if replayName == "menu" then
		showMenuBar = true;
	end

	if showMenuBar then
		MenuBar.visibility = math.min(1, MenuBar.visibility + deltaTimeRaw*4);
	else
		MenuBar.visibility = math.max(0, MenuBar.visibility - deltaTimeRaw*4);
	end

	if MenuBar.visibility <= 0 then
		return
	end

	-- origin is center of screen
	local x = -viewport.width / 2;
	local y = -viewport.height / 2;
	local extent = viewport.width / 2 + 10;
	local height = 100;

	-- fade out, or slide out
	--y = y - height * (1 - MenuBar.visibility) * (1 - MenuBar.visibility);
	local a = 255 * MenuBar.visibility;

	nvgSave();

	-- background, goes along top of screen
	nvgBeginPath();
	nvgRect(x, y, extent * 2, height);
	nvgFillColor(Color(17, 21, 26, a));
	nvgFill();

	-- logo on the left
	local logox = x + 50;
	local logorad = 30;
	local svgName = "internal/ui/icons/reflexlogo";
	nvgFillColor(Color(255, 255, 255, a));
	nvgSvg(svgName, logox, y + 50, logorad);
	
	-- reflex on the left
	local fontx = logox + logorad * 2 - 15;
	local fonty = y + height - 20;
	nvgFontSize(98);
	nvgFontFace(FONT_HEADER);
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_BASELINE);
	nvgFontBlur(0);
	nvgFillColor(Color(255, 255, 255, a));
	nvgText(fontx, fonty, "REFLEX");
	local fontendx = fontx + nvgTextWidth("REFLEX");

	-- we draw our menu bar headers always at a fixed aspect ratio
	local width43 = viewport.height * 1.0;

	-- position font, but don't let it overlap logo at crazy aspect ratios
	fontx = -width43/2;
	fonty = height - 25;
	if fontx <= fontendx + 20 then
		fontx = fontendx + 20
	end

	-- draw buttons on menu
	local buttonSpacing = 180;
	local buttonWidth = 150

	-- when we're in menu replay, we still want to still connect messages on menubar
	local consideredDisconnected = (clientGameState == STATE_DISCONNECTED) or (replayName == "menu");
    if consideredDisconnected then
		-- start
        if uiMenuBarButton("START SERVER", fontx, y, buttonWidth, height, a) then
	    	setMenuStack("StartGameMenu");
	    end
	    fontx = fontx + buttonSpacing;
    
		-- find match
		if uiMenuBarButton("FIND MATCH", fontx, y, buttonWidth, height, a) then
			setMenuStack("ServerBrowserMenu");
		end
		fontx = fontx + buttonSpacing;

		-- options
		if uiMenuBarButton("OPTIONS", fontx, y, buttonWidth, height, a) then
			setMenuStack("OptionsMenu");
		end
		fontx = fontx + buttonSpacing;

		-- replays		
        --uiMenuBarButton("REPLAYS", fontx, y, buttonWidth, height, a);
	    --fontx = fontx + buttonSpacing;

		-- quit
        if uiMenuBarButton("QUIT", fontx, y, buttonWidth, height, a) then
		    consolePerformCommand("quit");
        end

	elseif clientGameState == STATE_CONNECTED then
		-- find match
		if uiMenuBarButton("MATCH", fontx, y, buttonWidth, height, a) then
			setMenuStack("InGameMenu");
		end
		fontx = fontx + buttonSpacing;

		-- find match
		if uiMenuBarButton("FIND MATCH", fontx, y, buttonWidth, height, a) then
			setMenuStack("ServerBrowserMenu");
		end
		fontx = fontx + buttonSpacing;

		-- options
		if uiMenuBarButton("OPTIONS", fontx, y, buttonWidth, height, a) then
			setMenuStack("OptionsMenu");
		end
		fontx = fontx + buttonSpacing;

		-- disconnect
        if uiMenuBarButton("DISCONNECT", fontx, y, buttonWidth, height, a) then
		    consolePerformCommand("disconnect");
        end
		fontx = fontx + buttonSpacing;
    end

	nvgRestore();
end
