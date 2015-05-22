require "base/internal/ui/reflexcore"
 
zirraXhair = {
        canPosition = false;
        userData = {};
}
registerWidget("zirraXhair");
 
function zirraXhair:draw()
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;
        local crosshairs = {};
	  --Crosshair value per weapon.
	  crosshairs[1] = 1
	  crosshairs[2] = 2
	  crosshairs[3] = 3
	  crosshairs[4] = 4
	  crosshairs[5] = 5
	  crosshairs[6] = 6
	  crosshairs[7] = 7
	  crosshairs[8] = 8
        local player = getPlayer();
        for k,v in pairs(crosshairs) do
                if(crosshairs[player.weaponIndexSelected]) then
			consolePerformCommand("ui_crosshairs_type " .. crosshairs[player.weaponIndexSelected])
                end            
        end
end