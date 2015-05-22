require "base/internal/ui/reflexcore"

zirra = {
	canPosition = false;
	userData = {};
}
registerWidget("zirra");

function zirra:draw()
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;
	local noGun = {6} --diffrent guns?
	local player = getPlayer();
	for k,v in pairs(noGun) do
		if(player.weaponIndexSelected == v) then
			consolePerformCommand("cl_weapon_offset_z -14");						
		else
			consolePerformCommand("cl_weapon_offset_z 21");
		end		
	end
end