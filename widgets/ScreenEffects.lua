require "base/internal/ui/reflexcore"

ScreenEffects =
{
};
registerWidget("ScreenEffects");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ScreenEffects:draw()
 
    -- Find player
    local player = getPlayer();

    -- Early out if possible
    if player == nil or
       player.state == PLAYER_STATE_EDITOR or 
       player.state == PLAYER_STATE_SPECTATOR or 
       world.gameState == GAME_STATE_GAMEOVER or
       isInMenu() 
       then return false end;

    if not player.connected then return end;
    
    local x = -(viewport.width / 2);
    local y = -(viewport.height / 2);
    local width = viewport.width;
    local height = viewport.height;
    local innerRadius = width / 3;
    local textY = (height / 2) - 110;
    
    local bloodOuterColor = Color(138,7,7);
    local bloodInnerColor = Color(0,0,0,0);
    local deathInnerColor = Color(0,0,0,150);
    local deathOuterColor = Color(0,0,0,255);

    if player.health > 0 and player.health <= 30 then
        nvgBeginPath();
        nvgRect(x, y, width, height);
        nvgFillRadialGradient(0, 0, innerRadius, width, bloodInnerColor, bloodOuterColor);
        nvgFill();
    end

    if player.health <= 0 and gamemodes[world.gameModeIndex].canRespawn == true then
        nvgBeginPath();
        nvgRect(x, y, width, height);
        nvgFillRadialGradient(0, 0, innerRadius, width, deathInnerColor, deathOuterColor);
        nvgFill();

        nvgFontSize(80);
	    nvgFontFace(FONT_HUD);
	    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

        nvgFontBlur(10);
        nvgFillColor(Color(180,0,0,255));
        nvgText(0, textY, "FRAGGED");

        nvgFontBlur(0);
        nvgFillColor(Color(230,0,0,255));
        nvgText(0, textY, "FRAGGED");

        nvgFontSize(26);
	    nvgFontFace("titilliumWeb-regular");
	    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
        nvgFillColor(Color(230,230,230,255));
        nvgText(0, textY + 50, "Press jump or attack to respawn");

        --nvgFontSize(20);
	    --nvgFontFace("titilliumWeb-regular");
	    --nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
        --nvgFillColor(Color(230,230,230,255));
        --nvgText(0, textY + 70, "Forced respawn in X");
    end

    if player.health <= 0 and gamemodes[world.gameModeIndex].canRespawn == false then

        nvgFontSize(80);
	    nvgFontFace(FONT_HUD);
	    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

        nvgFontBlur(10);
        nvgFillColor(Color(180,0,0,255));
        nvgText(0, textY, "FRAGGED");

        nvgFontBlur(0);
        nvgFillColor(Color(230,0,0,255));
        nvgText(0, textY, "FRAGGED");

        nvgFontSize(26);
	    nvgFontFace("titilliumWeb-regular");
	    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
        nvgFillColor(Color(230,230,230,255));
        nvgText(0, textY + 50, "Waiting for next round..");

        --nvgFontSize(20);
	    --nvgFontFace("titilliumWeb-regular");
	    --nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
        --nvgFillColor(Color(230,230,230,255));
        --nvgText(0, textY + 70, "Forced respawn in X");
    end
end
