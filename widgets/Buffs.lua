require "base/internal/ui/reflexcore"

Buffs =
{
};
registerWidget("Buffs");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function drawBuff(x, y, name, col, time)
	local alpha = 255;

	nvgFontSize(25);
	nvgFontFace("TitilliumWeb-Bold");
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_BASELINE);

	-- time
	if time ~= nil then
		local t = FormatTime(time);
		local textTime;
		
		--if t.minutes > 0 then
			textTime = string.format("%d:%02d", t.minutes, t.seconds);
		--else
		--	textTime = t.seconds;
		--end

		local colTime = Color(255, 255, 255, 255);
	
		-- pulse red when nearly out
		if time < 3000 then
			-- pulse
			local timeAway = math.mod(time, 1000);
			local intensity = math.abs(timeAway - 500) / 500;
			--consolePrint(intensity);
			colTime.b = 128 + intensity * 127;
			colTime.g = 128 + intensity * 127;

			-- fade out at end
			if time < 500 then
				colTime.b = 128;
				colTime.g = 128;
				colTime.a = 255 - intensity*255;

				alpha = colTime.a;
			end
		end
		
		-- bg
		nvgFontBlur(2);
		nvgFillColor(Color(0, 0, 0, alpha));
		nvgText(x + 120, y + 1, textTime);

		-- foreground
		nvgFontBlur(0);
		nvgFillColor(colTime);
		nvgText(x + 120, y, textTime);
	end

	-- bg
	--nvgFontBlur(2);
	--nvgFillColor(Color(0, 0, 0, alpha));
	--nvgText(x, y + 1, name);

	-- foreground
	local c = col;
	c.a = alpha;
	nvgFontBlur(0);
	nvgFillColor(c);
	nvgText(x, y, name);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Buffs:draw()
	
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;
    
    local x = 0;
	local y = 0;
	
	-- find player
	local player = getPlayer();
	if player == nil then return end;

	-- mega
	if player.hasMega then
		drawBuff(x, y, "Megahealth", Color(128,128,255), nil);
		y = y - 30;
	end

	-- carnage
	if player.carnageTimer > 0 then
		drawBuff(x, y, "Carnage", Color(128,128,255), player.carnageTimer);
		y = y - 30;
	end
end
