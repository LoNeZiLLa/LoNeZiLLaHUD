require "base/internal/ui/reflexcore"

AmmoCount =
{
};
registerWidget("AmmoCount");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AmmoCount:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

	local player = getPlayer();

    -- Options
    local showFrame = true;
    local colorNumber = false;

    -- Size and spacing
    local frameWidth = 125;
    local frameHeight = 35;
    local framePadding = 5;
    local numberSpacing = 100;
    local iconSpacing = 40;

    -- Colors
    local frameColor = Color(0,0,0,128);

	local weaponIndexSelected = player.weaponIndexSelected;
	local weapon = player.weapons[weaponIndexSelected];
	local ammo = weapon.ammo;
	local outlineColor = player.weapons[weaponIndexSelected].color;

	-- Helpers
    local frameLeft = -frameWidth/2;
    local frameTop = -frameHeight;
    local frameRight = frameLeft + frameWidth;
    local frameBottom = 0;

    local fontX = (frameRight - framePadding) - 2;
    local fontY = -(frameHeight / 2);
    local fontSize = frameHeight * 1.15;

    -- Frame
    if showFrame then
        nvgBeginPath();
        nvgRect(frameRight, frameBottom, -frameWidth, -frameHeight, 5);
		nvgStrokeWidth(2);
		nvgStrokeColor(outlineColor);
		nvgStroke();
        nvgFillColor(frameColor);
        nvgFill();
    end

    -- colour changes when low on ammo
	local fontColor = Color(230,230,230);
	local glow = false;
	if ammo == 0 then
		fontColor = Color(230, 0, 0);
		glow = true;
	elseif ammo < weapon.lowAmmoWarning then
		fontColor = Color(230, 230, 0);
		glow = true;
	end

    nvgFontSize(fontSize);
	nvgFontFace("TitilliumWeb-Bold");
	nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_MIDDLE);

    if weaponIndexSelected == 1 then ammo = "-" end

    if glow then
	    nvgFontBlur(5);
        nvgFillColor(Color(64, 64, 200));
	    nvgText(fontX, fontY, ammo);
    end

	nvgFontBlur(0);
	nvgFillColor(fontColor);
	nvgText(fontX, fontY, ammo);

    -- Draw icon
	local iconX = frameLeft + (iconSpacing / 2) + framePadding;
	local iconY = -(frameHeight / 2);
	local iconSize = (frameHeight / 2) * 0.75;
	local svgName = "internal/ui/icons/weapon" .. weaponIndexSelected;
	iconColor = player.weapons[weaponIndexSelected].color;
	nvgFillColor(iconColor);
	nvgSvg(svgName, iconX, iconY, iconSize);
end
