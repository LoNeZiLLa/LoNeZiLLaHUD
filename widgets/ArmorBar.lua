require "base/internal/ui/reflexcore"

ArmorBar =
{
};
registerWidget("ArmorBar");

-- smoothedHealth += (currentHealth - oldHealth) * deltaTime

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ArmorBar:initialize()
	-- load data stored in engine
	self.userData = loadUserData();
	
	-- ensure it has what we need
	CheckSetDefaultValue(self, "userData", "table", {});
	CheckSetDefaultValue(self.userData, "showFrame", "boolean", true);
	CheckSetDefaultValue(self.userData, "showIcon", "boolean", true);
	CheckSetDefaultValue(self.userData, "flatBar", "boolean", false);
	CheckSetDefaultValue(self.userData, "colorNumber", "boolean", false);
	CheckSetDefaultValue(self.userData, "colorIcon", "boolean", false);

	CheckSetDefaultValue(self.userData, "barAlpha", "number", 160);
	CheckSetDefaultValue(self.userData, "iconAlpha", "number", 32);	
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ArmorBar:drawOptions(x, y)

	local sliderWidth = 200;
	local sliderStart = 140;
	local user = self.userData;

	user.showFrame = uiCheckBox(user.showFrame, "Show frame", x, y);
	y = y + 30;
	
	user.showIcon = uiCheckBox(user.showIcon, "Show icon", x, y);
	y = y + 30;

	user.flatBar = uiCheckBox(user.flatBar, "Flat bar style", x, y);
	y = y + 30;

	user.colorNumber = uiCheckBox(user.colorNumber, "Color numbers by armor", x, y);
	y = y + 30;

	user.colorIcon= uiCheckBox(user.colorIcon, "Color icon by armor", x, y);
	y = y + 30;
	
	uiLabel("Bar Alpha:", x, y);
	user.barAlpha = clampTo2Decimal(uiSlider(x + sliderStart, y, sliderWidth, 0, 255, user.barAlpha));
	user.barAlpha = clampTo2Decimal(uiEditBox(user.barAlpha, x + sliderStart + sliderWidth + 10, y, 60));
	y = y + 40;
	
	uiLabel("Icon Alpha:", x, y);
	user.iconAlpha = clampTo2Decimal(uiSlider(x + sliderStart, y, sliderWidth, 1, 255, user.iconAlpha));
	user.iconAlpha = clampTo2Decimal(uiEditBox(user.iconAlpha, x + sliderStart + sliderWidth + 10, y, 60));
	y = y + 40;
	
	saveUserData(user);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ArmorBar:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;
	if isRaceMode() then return end;

	local player = getPlayer();

    -- Options
    local showFrame = self.userData.showFrame;
    local showIcon = self.userData.showIcon;
    local flatBar = self.userData.flatBar;
    local colorNumber = self.userData.colorNumber;
    local colorIcon = self.userData.colorIcon;
    
    -- Size and spacing
    local frameWidth = 600;
    local frameHeight = 45;
    local framePadding = 5;
    local numberSpacing = 100;
    local iconSpacing;

    if showIcon then iconSpacing = 40
    else iconSpacing = 0;
    end
	
    -- Colors
    local frameColor = Color(0,0,0,128);
    local barAlpha = self.userData.barAlpha
    local iconAlpha = self.userData.iconAlpha

    local barColor;
    if player.armorProtection == 0 then barColor = Color(0,255,0, barAlpha) end
    if player.armorProtection == 1 then barColor = Color(245,245,50, barAlpha) end
    if player.armorProtection == 2 then barColor = Color(236,0,0, barAlpha) end

    local barBackgroundColor;    
    if player.armorProtection == 0 then barBackgroundColor = Color(0,100,0, barAlpha) end
    if player.armorProtection == 1 then barBackgroundColor = Color(122,122,50, barAlpha) end
    if player.armorProtection == 2 then barBackgroundColor = Color(141,30,10, barAlpha) end    

    -- Helpers
    local frameLeft = 0;
    local frameTop = -frameHeight;
    local frameRight = frameWidth;
    local frameBottom = 0;
 
    local barLeft = frameLeft + iconSpacing + numberSpacing
    local barTop = frameTop + framePadding;
    local barRight = frameRight - framePadding;
    local barBottom = frameBottom - framePadding;

    local barWidth = frameWidth - numberSpacing - framePadding - iconSpacing;
    local barHeight = frameHeight - (framePadding * 2);

    local fontX = barLeft - (numberSpacing / 2);
    local fontY = -(frameHeight / 2);
    local fontSize = frameHeight * 1.15;
 
    if player.armorProtection == 0 then fillWidth = math.min((barWidth / 100) * player.armor, barWidth);
    elseif player.armorProtection == 1 then fillWidth = math.min((barWidth / 150) * player.armor, barWidth);
    elseif player.armorProtection == 2 then fillWidth = (barWidth / 200) * player.armor;
    end

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
    nvgRect(barLeft, barBottom, fillWidth, -barHeight);
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
    else fontColor = Color(255,255,255);
    end
    
    nvgFontSize(fontSize);
	nvgFontFace("TitilliumWeb-Bold");
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
    
    if not colorNumber then -- Don't glow if the numbers are colored (looks crappy)
    
	    if player.armor <= 30 then
        nvgFontBlur(5);
        nvgFillColor(Color(64, 64, 200));
	    nvgText(fontX, fontY, player.armor);
        end
	       
    end
    
	nvgFontBlur(0);
	nvgFillColor(fontColor);
	nvgText(fontX, fontY, player.armor);
    
    -- Draw icon
    
    if showIcon then
        local iconX = (iconSpacing / 2) + framePadding;
        local iconY = -(frameHeight / 2);
        local iconSize = (barHeight / 2) * 0.9;
        local iconColor;
    
        if colorIcon then iconColor = barColor
        else iconColor = Color(230,230,230, iconAlpha);
        end
    
		nvgFillColor(iconColor);
        nvgSvg("internal/ui/icons/armor", iconX, iconY, iconSize);
    end

end
