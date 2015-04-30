require "base/internal/ui/reflexcore"

WeaponName =
{
};
registerWidget("WeaponName");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function WeaponName:draw()
	local x = 0;
	local y = 0;
	
   	-- Find player and early out if possible
	local player = getPlayer();
	if player == nil or player.health <= 0 or isInMenu() then return end;

	local alpha = 255 * player.weaponSelectionIntensity;

	nvgFontSize(36);
	nvgFontFace("TitilliumWeb-Bold");
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);

	local weapon = player.weapons[player.weaponIndexSelected];
		
	-- bg
	nvgFontBlur(2);
	nvgFillColor(Color(0, 0, 0, alpha));
	nvgText(x, y + 1, weapon.name);

	-- foreground
	local col = {};
	col.r = weapon.color.r;
	col.g = weapon.color.g;
	col.b = weapon.color.b;
	col.a = alpha;
	nvgFontBlur(0);
	nvgFillColor(col);
	nvgText(x, y, weapon.name);
end
