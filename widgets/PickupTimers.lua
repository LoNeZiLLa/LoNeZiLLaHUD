require "base/internal/ui/reflexcore"

PickupTimers =
{
};
registerWidget("PickupTimers");

local PickupVis = {};
PickupVis[PICKUP_TYPE_ARMOR50] = {};
PickupVis[PICKUP_TYPE_ARMOR50].svg = "internal/ui/icons/armor";
PickupVis[PICKUP_TYPE_ARMOR50].color = Color(0,255,0);
PickupVis[PICKUP_TYPE_ARMOR100] = {};
PickupVis[PICKUP_TYPE_ARMOR100].svg = "internal/ui/icons/armor";
PickupVis[PICKUP_TYPE_ARMOR100].color = Color(255,255,0);
PickupVis[PICKUP_TYPE_ARMOR150] = {};
PickupVis[PICKUP_TYPE_ARMOR150].svg = "internal/ui/icons/armor";
PickupVis[PICKUP_TYPE_ARMOR150].color = Color(255,0,0);
PickupVis[PICKUP_TYPE_HEALTH100] = {};
PickupVis[PICKUP_TYPE_HEALTH100].svg = "internal/ui/icons/health";
PickupVis[PICKUP_TYPE_HEALTH100].color = Color(60,80,255);
PickupVis[PICKUP_TYPE_POWERUPCARNAGE] = {};
PickupVis[PICKUP_TYPE_POWERUPCARNAGE].svg = "internal/ui/icons/carnage";
PickupVis[PICKUP_TYPE_POWERUPCARNAGE].color = Color(255,120,128);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function PickupTimers:draw()
	
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

    local translucency = 192;
	
   	-- Find player
	local player = getPlayer();

	-- count pickups
	local pickupCountTotal = 0;
	local pickupCount = 0;
	for k, v in pairs(pickupTimers) do
		pickupCountTotal = pickupCountTotal + 1;

		-- only display timers we care about
		-- (we expose all pickups to SPECATORS only, but we don't want all those pickups in this side list)
		-- (this is only an issue when you're following a player)
		if PickupVis[v.type] ~= nil then
			pickupCount = pickupCount + 1;
		end
	end

    local spaceCount = pickupCount - 1;
    
    -- Options
    local timerWidth = 100;
    local timerHeight = 30;
    local timerSpacing = 5; -- 0 or -1 to remove spacing
    
    -- Helpers
    local rackHeight = (timerHeight * pickupCount) + (timerSpacing * spaceCount);
    local rackTop = -(rackHeight / 2);
    local timerX = 0;
    local timerY = rackTop;

    -- iterate pickups
	for i = 1, pickupCountTotal do
		local pickup = pickupTimers[i];
		local vis = PickupVis[pickup.type];

		if vis ~= nil then
			local backgroundColor = Color(0,0,0,65)
        
			-- Frame background
			nvgBeginPath();
			nvgRect(timerX,timerY,timerWidth,timerHeight);
			nvgFillColor(backgroundColor);
			nvgFill();

			-- Icon
			local iconRadius = timerHeight * 0.40;
			local iconX = timerX + iconRadius + 5;
			local iconY = timerY + (timerHeight / 2);
			local iconColor = vis.color;
			local iconSvg = vis.svg;
      
			-- Plot icon
			nvgFillColor(iconColor);
			nvgSvg(iconSvg, iconX, iconY, iconRadius);

			-- Time
			local t = FormatTime(pickup.timeUntilRespawn);
			local timeX = timerX + (timerWidth / 2) + iconRadius;
			local time = t.seconds + 60 * t.minutes;

			if time == 0 then
				time = "-";
			end

			if not pickup.canSpawn then
				time = "held";
			end

			nvgFontSize(30);
			nvgFontFace("TitilliumWeb-Bold");
			nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);

			nvgFontBlur(0);
			nvgFillColor(Color(255,255,255));
			nvgText(timeX, timerY, time);
        
			timerY = timerY + timerHeight + timerSpacing;
		end
    end
end
