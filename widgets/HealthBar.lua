require "base/internal/ui/reflexcore"

HealthBar =
{
};
registerWidget("HealthBar");


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function HealthBar:draw()
 
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

    -- Find player 
    local player = getPlayer();

    -- Options
    local showFrame = true;
    local showIcon = true;
    local flatBar = true;
    local colorNumber = false;
    local colorIcon = true;
    
    -- Size and spacing
    local frameWidth = 460;
    local frameHeight = 55;
    local framePadding = 5;
    local numberSpacing = 100;
    local iconSpacing;

    if showIcon then iconSpacing = 40
    else iconSpacing = 0;
    end
	
    -- Colors
    local frameColor = Color(0,0,0,128);
    local barAlpha = 255;
    local iconAlpha = 255;
	local whiteStroke = Color(255,255,255,255);

    local barColor;
    if player.health > 100 then barColor = Color(16,116,217, barAlpha) end
    if player.health <= 100 then barColor = Color(2,167,46, barAlpha) end
    if player.health <= 80 then barColor = Color(255,176,14, barAlpha) end
    if player.health <= 30 then barColor = Color(236,0,0, barAlpha) end

    local barBackgroundColor;    
    if player.health > 100 then barBackgroundColor = Color(10,68,127, barAlpha) end
    if player.health <= 100 then barBackgroundColor = Color(14,53,9, barAlpha) end
    if player.health <= 80 then barBackgroundColor = Color(105,67,4, barAlpha) end
    if player.health <= 30 then barBackgroundColor = Color(141,30,10, barAlpha) end    

    -- Helpers
    local frameLeft = -frameWidth;
    local frameTop = -frameHeight;
    local frameRight = 0;
    local frameBottom = 0;
 
    local barLeft = frameLeft + framePadding;
    local barTop = frameTop + framePadding;
    local barRight = frameRight - numberSpacing - iconSpacing;
    local barBottom = frameBottom - framePadding;

    local barWidth = frameWidth - numberSpacing - framePadding - iconSpacing;
    local barHeight = frameHeight - (framePadding * 2);

    local fontX = barRight + (numberSpacing / 2);
    local fontY = -(frameHeight / 2);
    local fontSize = frameHeight * 1.15;

    local fillWidth;
    if player.health > 100 then fillWidth = (barWidth / 100) * (player.health - 100);
    else fillWidth = (barWidth / 100) * player.health; end

    -- Frame
    if showFrame then
        nvgBeginPath();
        nvgRect(frameRight, frameBottom, -frameWidth, -frameHeight, 5);
        nvgFillColor(frameColor); 
        nvgFill();
    end
    
    -- Background
    nvgBeginPath();
    nvgRect(barRight, barBottom , -barWidth, -barHeight);
    nvgFillColor(barBackgroundColor); 
    nvgFill();

    -- Bar
    nvgBeginPath();
    nvgRect(barRight, barBottom, -fillWidth, -barHeight);
    nvgFillColor(barColor); 
    nvgFill();

    -- Shading
    if flatBar == false then
        nvgBeginPath();
	    nvgRect(barLeft, barTop, barWidth, barHeight);
        nvgFillLinearGradient(barLeft, barTop, barLeft, barBottom, Color(255,255,255,30), Color(255,255,255,0))
        nvgFill();

        nvgBeginPath();
        nvgMoveTo(barLeft, barTop);
        nvgLineTo(barRight, barTop);
        nvgStrokeWidth(1)
        nvgStrokeColor(Color(255,255,255,60));
        nvgStroke();
    end
          
    -- Draw numbers
    local fontColor;

    if colorNumber then fontColor = barColor
    else fontColor = Color(230,230,230);
    end

    nvgFontSize(fontSize);
    nvgFontFace("TitilliumWeb-Bold");
    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
    
    if not colorNumber then -- Don't glow if the numbers are colored (looks crappy)
		if player.health > 100 then
			nvgFontBlur(5);
			nvgFillColor(Color(64, 64, 200));
			nvgText(fontX, fontY, player.health);
		elseif player.health <= 30 then
			nvgFontBlur(10);
			nvgFillColor(Color(200, 64, 64));
			nvgText(fontX, fontY, player.health);
		end
    end
    
    nvgFontBlur(0);
    nvgFillColor(fontColor);
    nvgText(fontX, fontY, player.health);

    -- Draw icon
    if showIcon then
        local iconX = -(iconSpacing / 2) - framePadding;
        local iconY = -(frameHeight / 2);
        local iconSize = (barHeight / 2) * 0.9;
        local iconColor;

        if colorIcon then iconColor = barColor
        else iconColor = Color(230,230,230, iconAlpha);
        end

		nvgFillColor(iconColor);
        nvgSvg("internal/ui/icons/health", iconX, iconY, iconSize)
    end
end
