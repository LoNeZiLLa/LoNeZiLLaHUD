require "base/internal/ui/reflexcore"

ItemReminder =
{
};
registerWidget("ItemReminder");

--
function SetSettings()
    consolePerformCommand("ui_set_widget_anchor ItemReminder 0 0");
    consolePerformCommand("ui_set_widget_offset ItemReminder 0 50");
end

SetSettings();

function ItemReminder:draw()

    -- Offsets
    local iconRadius = 36/2;
    local iconX = -(50 + iconRadius*2);
    local iconY = 2;

    -- Count pickups
    local pickupCount = 0;
    for k, v in pairs(pickupTimers) do
        pickupCount = pickupCount + 1;
    end

    -- Iterate pickups
    for i = 1, pickupCount do
        local pickup = pickupTimers[i];

        -- Icon
        local iconSvg = "internal/ui/icons/armor";    -- default armour icon
        if pickup.type == PICKUP_TYPE_ARMOR50 then
            iconColor = Color(0,255,0);
        elseif pickup.type == PICKUP_TYPE_ARMOR100 then
            iconColor = Color(255,255,0);
        elseif pickup.type == PICKUP_TYPE_ARMOR150 then
            iconColor = Color(255,8,8);
        elseif pickup.type == PICKUP_TYPE_HEALTH100 then
            iconSvg = "internal/ui/icons/health";
            iconColor = Color(74,164,255);
        elseif pickup.type == PICKUP_TYPE_POWERUPCARNAGE then
            iconSvg = "internal/ui/icons/carnage";
            iconColor = Color(255,120,128);
        end

        -- Time
        local t = FormatTime(pickup.timeUntilRespawn);
        local time = t.seconds + 60 * t.minutes;

        if time > 0 and time <= 5 then

            -- Frame background
            nvgBeginPath();
            nvgRect(-55,-16,110,36);
            nvgFillColor(Color(240,240,240,64));
            nvgFill();

            -- Set up font
            nvgFontSize(30);
            nvgFontFace("roboto-regular");
            nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

            -- Show item icon as well
            nvgFillColor(iconColor);
            nvgSvg(iconSvg, iconX, iconY, iconRadius);

            -- Print message
            local x = 0;
            local y = 0;

            nvgFontBlur(10);
            nvgFillColor(Color(0, 0, 0, 255));
            nvgText(x, y, "Spawning");

            nvgFontBlur(0);
            nvgFillColor(iconColor);
            nvgText(x, y, "Spawning");

        end

    end
end