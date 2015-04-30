require "base/internal/ui/reflexcore"

Timer =
{
};
registerWidget("Timer");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Timer:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

	if	(world.gameState == GAME_STATE_ACTIVE) or
		(world.gameState == GAME_STATE_ROUNDACTIVE) then

		local timeRemaining = world.gameTimeLimit - world.gameTime;
		if timeRemaining < 0 then
			timeRemaining = 0;
		end

		local t = FormatTime(timeRemaining);
		local textTime = string.format("%d:%02d", t.minutes, t.seconds);
		
		local fontSize = 52;
        local frameX = 0;
		local frameY = 0;

        -- Colors
        local frameColor = Color(0,0,0,64);
        local textColor = Color(255,255,255,255);
        local lowTimeFrameColor = Color(200,0,0,64);
        local lowTimeTextColor = Color(255,255,255,255);
	
        -- Options
        local lowTime = 30000; -- in milliseconds

        if timeRemaining < lowTime then
            frameColor = lowTimeFrameColor;
            textColor = lowTimeTextColor;
        end

        -- Background
        nvgBeginPath();
        nvgRect(-fontSize, 0, fontSize * 2, fontSize);
        nvgFillColor(frameColor);
        nvgFill();

		-- Text
        nvgFontSize(52);
		nvgFontFace("TitilliumWeb-Bold");
		nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);
		nvgFontBlur(0);
		nvgFillColor(textColor);
		nvgText(0, 0, textTime);
	end
end
