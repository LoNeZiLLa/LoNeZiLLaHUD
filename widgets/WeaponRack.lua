require "base/internal/ui/reflexcore"

WeaponRack =
{
};
registerWidget("WeaponRack");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function WeaponRack:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;
	if isRaceMode() then return end;

	local translucency = 192;
	
   	-- Find player
	local player = getPlayer();

    local weaponCount = 9; -- table.maxn(player.ammo);
    local spaceCount = weaponCount - 1;
    
    -- Options
    local verticalRack = false;
    local weaponWidth = 100;
    local weaponHeight = 30;
    local weaponSpacing = 5; -- 0 or -1 to remove spacing
    
    -- Helpers
    local rackWidth = (weaponWidth * weaponCount) + (weaponSpacing * spaceCount);
    local rackLeft = -(rackWidth / 2);
    local weaponX = rackLeft;
    local weaponY = 0;

    if verticalRack == true then
        rackHeight = (weaponHeight * weaponCount) + (weaponSpacing * spaceCount);
        rackTop = -(rackHeight / 2);
        weaponX = 0;
        weaponY = rackTop;
    end

    for weaponIndex = 1, weaponCount do

        local weapon = player.weapons[weaponIndex];
		local color = weapon.color;
    
		-- if we havent picked up the weapon, colour it grey
		if not weapon.pickedup then
			color.r = 128;
			color.g = 128;
			color.b = 128;
		end

        local backgroundColor = Color(0,0,0,65)
        
        -- Frame background
        nvgBeginPath();
        nvgRect(weaponX,weaponY,weaponWidth,weaponHeight);

        if weaponIndex == player.weaponIndexSelected then 
            backgroundColor.r = lerp(backgroundColor.r, color.r, player.weaponSelectionIntensity);
            backgroundColor.g = lerp(backgroundColor.g, color.g, player.weaponSelectionIntensity);
            backgroundColor.b = lerp(backgroundColor.b, color.b, player.weaponSelectionIntensity);
            backgroundColor.a = lerp(backgroundColor.a, 128, player.weaponSelectionIntensity);

			local outlineColor = Color(
				color.r,
				color.g,
                color.b,
				lerp(0, 255, player.weaponSelectionIntensity));

            nvgStrokeWidth(2);
            nvgStrokeColor(outlineColor);
            nvgStroke();
        end

        nvgFillColor(backgroundColor);
        nvgFill();

        -- Icon
	    local iconRadius = weaponHeight * 0.40;
        local iconX = weaponX + (weaponHeight - iconRadius);
        local iconY = (weaponHeight / 2);
        local iconColor = color;

        if verticalRack == true then
            iconX = weaponX + iconRadius + 5;
            iconY = weaponY + (weaponHeight / 2);
        end

        if weaponIndex == player.weaponIndexSelected then 
			iconColor.r = lerp(iconColor.r, 255, player.weaponSelectionIntensity);
			iconColor.g = lerp(iconColor.g, 255, player.weaponSelectionIntensity);
			iconColor.b = lerp(iconColor.b, 255, player.weaponSelectionIntensity);
			iconColor.a = lerp(iconColor.a, 255, player.weaponSelectionIntensity);
		end
        
        local svgName = "internal/ui/icons/weapon"..weaponIndex;
		nvgFillColor(iconColor);
	    nvgSvg(svgName, iconX, iconY, iconRadius);

        -- Ammo
	    local ammoX = weaponX + (iconRadius) + (weaponWidth / 2);
        local ammoCount = player.weapons[weaponIndex].ammo;

        if verticalRack == true then
            ammoX = weaponX + (weaponWidth / 2) + iconRadius;
        end

        if weaponIndex == 1 then ammoCount = "-" end

        nvgFontSize(30);
        --nvgFontFace("oswald-bold");
        nvgFontFace("TitilliumWeb-Bold");
	    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);

	    nvgFontBlur(0);
	    nvgFillColor(Color(255,255,255));
	    nvgText(ammoX, weaponY, ammoCount);
        
        if verticalRack == true then
            weaponY = weaponY + weaponHeight + weaponSpacing;
        else
            weaponX = weaponX + weaponWidth + weaponSpacing;
        end
       
    end

end
