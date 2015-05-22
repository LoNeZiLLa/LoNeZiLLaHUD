require "base/internal/ui/reflexcore"

GameMessages =
{
	canPosition = false,
	lastTickSeconds = -1;
};
registerWidget("GameMessages");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function drawText(text, secondRow)
	local x = 0;
	local y = -70;	-- pull it above cursor
	local alpha = 255;
	local fontSize = 48;
	local fontColor = Color(230, 230, 230, alpha);

	if secondRow == true then
		y = y + 40;
		fontSize = 36;
		fontColor.r = 180;
		fontColor.g = 180;
	end
	
	nvgFontSize(fontSize);
	nvgFontFace(FONT_HUD);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

	-- bg
	nvgFontBlur(2);
	nvgFillColor(Color(0, 0, 0, alpha));
	nvgText(x, y + 1, text);

	-- foreground
	nvgFontBlur(0);
	nvgFillColor(fontColor);
	nvgText(x, y, text);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function drawCountdown(gameType, visible)
	local timeRemaining = world.gameTimeLimit - world.gameTime;
	local t = FormatTime(timeRemaining);

	-- this flicks to 0 some times, just clamp it to 1
	t.seconds = math.max(1, t.seconds);

	if visible == true then
		local text = gameType .. " begins in " .. t.seconds .. "..";
		drawText(text);
	end

	if GameMessages.lastTickSeconds ~= t.seconds then
		GameMessages.lastTickSeconds = t.seconds;
		playSound("internal/ui/match/match_countdown_tick");
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function drawWinner()
	local player = getPlayerAlive();
	if player ~= nil then
		local gameMode = gamemodes[world.gameModeIndex];
		if gameMode.hasTeams then
			local teamName = world.teams[player.team].name;
			drawText(teamName .. " wins the round!");
		else
			drawText(player.name .. " wins the round");
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function getTopTwoPlayers(playersOut)
	local have1 = false;
	local have2 = false;

	for k, player in pairs(players) do 
		if player.state == PLAYER_STATE_INGAME then
			if not have1 then
				playersOut[1] = player;
				have1 = true;
			elseif not have2 then
				playersOut[2] = player;
				have2 = true;
			else
				local minIndex = 1;
				if playersOut[2].score < playersOut[1].score then
					minIndex = 2;
				end

				if playersOut[minIndex].score < player.score then
					playersOut[minIndex] = player;
				end
			end
		end
	end

	return have1 and have2;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function drawPlus2()
	local gameMode = gamemodes[world.gameModeIndex];
	local pointsToWin = gameMode.pointsToWin;

	local scores = { };
	local topName = "";
	scores[1] = 0;
	scores[2] = 0;
	
	if gameMode.hasTeams then
		scores[1] = world.teams[1].score;
		scores[2] = world.teams[2].score;

		if scores[2] > scores[1] then
			topName = world.teams[2].name;
		else
			topName = world.teams[1].name;
		end
	else
		local topPlayers = {};
		if getTopTwoPlayers(topPlayers) then
			scores[1] = topPlayers[1].score;
			scores[2] = topPlayers[2].score;
			if scores[1] > scores[2] then
				topName = topPlayers[1].name;
			else
				topName = topPlayers[2].name;
			end
		end
	end

	local topScore = math.max(scores[1], scores[2]);
	if topScore >= (pointsToWin - 1) then
		if scores[1] == scores[2] then
			drawText("First player to +2 wins", true);
		else
			drawText("Match point " .. topName, true);
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function GameMessages:draw()

	-- Game-begins-in-3-2-1
	-- This goes here because otherwise ticks are not heard if shouldShowStatus is false.
	if world.timerActive and world.gameState == GAME_STATE_WARMUP then
		drawCountdown("Game", shouldShowStatus());
	elseif world.timerActive and world.gameState == GAME_STATE_ROUNDPREPARE then
		drawCountdown("Round", shouldShowStatus());
	end
	
	-- Early out if HUD shouldn't be shown.
    if not shouldShowStatus() then return end;

	if world.timerActive then

		-- FIGHT! / OVERTIME!
		if world.gameState == GAME_STATE_ACTIVE or world.gameState == GAME_STATE_ROUNDACTIVE then
			if world.gameTime < 2000 then
				local text = "";

				if world.overTimeCount == 0 then
					local gameMode = gamemodes[world.gameModeIndex];
					drawText(gameMode.shortName == "race" and "RUN" or "FIGHT");
				elseif world.overTimeCount == 1 then
					drawText("OVERTIME!");
				else
					drawText(world.overTimeCount .. "x OVERTIME!");
				end
			end
		end

		-- ROUND DRAW
		if world.gameState == GAME_STATE_ROUNDCOOLDOWN_DRAW then
			drawText("Round Draw");
		end

		-- announce winner
		if world.gameState == GAME_STATE_ROUNDCOOLDOWN_SOMEONEWON then
			drawWinner();
		end

		-- announce +2 to win
		if world.gameState == GAME_STATE_ROUNDPREPARE then
			drawPlus2();
		end
	end

end
