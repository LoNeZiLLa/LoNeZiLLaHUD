require "base/internal/ui/reflexcore"
require "base/internal/ui/gamestrings"

PlayerStatus =
{
	canPosition = true,
	lastTickSeconds = -1;
};
registerWidget("PlayerStatus");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function drawPlayerText(text, textColor, x, y)
	-- bg
	nvgFontBlur(2);
	nvgFillColor(Color(0, 0, 0, 255));
	nvgText(x, y + 1, text);

	-- foreground
	nvgFontBlur(0);
	nvgFillColor(textColor);
	nvgText(x, y, text);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function PlayerStatus:draw()
	-- localPlayer status:
	--
	-- mode: Free for all / 1v1 / tdm / .....
	-- state:	Queud for match, in position %d of %d
	--
	-- camera: Freecam / Following: newborn
	-- caminfo: use < and > to cycle players, use / to cycle modes
	--

    -- Early out if HUD shouldn't be shown.
    if not shouldShowStatus() then return end;

   	-- localPlayer = player who owns this client
	-- player = player we're watching
	local localPlayer = getLocalPlayer();
	if localPlayer == nil then return end;
	local player = getPlayer();
	if player == nil then return end;
	
	local gamemode = gamemodes[world.gameModeIndex];
	local modename = gamemode.name;
	local showCameraState = false;
	
	-- first, gather state
	local state = nul;
	if localPlayer.state == PLAYER_STATE_QUEUED then
	
		state = string.format(GAMESTRING_status_Queued, localPlayer.queuePosition, world.playerQueueLength);
		showCameraState = true;
	
	elseif (localPlayer.state == PLAYER_STATE_INGAME) and (localPlayer.health <= 0) and (world.gameState == GAME_STATE_ACTIVE or world.gameState == GAME_STATE_ROUNDACTIVE or world.gameState == GAME_STATE_ROUNDCOOLDOWN_SOMEONEWON or world.gameState == GAME_STATE_ROUNDCOOLDOWN_DRAW) then

		if not gamemode.canRespawn then
			state = "You died, waiting for next round..";
			showCameraState = true;
		end

	elseif localPlayer.state == PLAYER_STATE_SPECTATOR then

		if world.gameState == GAME_STATE_WARMUP then
			state = "Spectating (in warmup)..";
		else
			state = "Spectating..";
		end
		showCameraState = true;
	
	elseif world.gameState == GAME_STATE_WARMUP then

		-- warmup
		-- (when timer starts, game is preparing, don't display state box)
		if not world.timerEnambed then
			local numReady = 0;
			local numPlaying = 0;

			for k, v in pairs(players) do 
				if v.connected and v.state == PLAYER_STATE_INGAME then
					numPlaying = numPlaying + 1;
					if v.ready then
						numReady = numReady + 1;
					end
				end
			end

			if numPlaying >= 2 then
				state = string.format(GAMESTRING_warmup_players_ready, numReady, numPlaying);
			else
				state = GAMESTRING_warmup_need_2_players;
			end
		end

	end

	-- gather camera state if required
	local camera = "";
	local cameraInfo = "";
	if showCameraState then
		-- todo: cache these rather than looking up frame?
		local keyPrevCamera = bindReverseLookup("cl_camera_prev_player");
		local keyNextCamera = bindReverseLookup("cl_camera_next_player");
		local keyFreeCamera = bindReverseLookup("cl_camera_freecam");
		
		cameraInfo = "use "..keyPrevCamera.." and "..keyNextCamera.." to cycle players, use "..keyFreeCamera.." for freecam";

		if (playerIndexCameraAttachedTo == playerIndexLocalPlayer) or (playerIndexCameraAttachedTo == 0) then 
			camera = "Free Camera";
		else
			camera = string.format("Following: %s", player.name);
		end
	end

	if state ~= nil then
		
		local vpad = 5;
		local hpad = 5;
		local w = 0;
		local y = 0;
		local x = 0;

		local lineHeight = 40;
		local h = vpad * 2 + lineHeight * 2;
		if showCameraState then
			h = h + lineHeight * 3;
		end

		local iy = y + vpad + lineHeight/2;
	
		-- mode
		nvgFontSize(60);
		nvgFontFace(FONT_HUD);
		nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

		drawPlayerText(modename, Color(255, 255, 240), x, iy);
		iy = iy + lineHeight;

		-- state
		nvgFontSize(35);
		nvgFontFace("titilliumWeb-regular");
		drawPlayerText(state, Color(240, 240, 240), x, iy);
		iy = iy + lineHeight;

		if showCameraState then
			-- spacer
			--iy = iy + lineHeight;
            nvgFontSize(18);

			-- camera
			drawPlayerText(camera, Color(255, 240, 240), x, iy);
			iy = iy + (lineHeight / 2);

			-- camera info
			drawPlayerText(cameraInfo, Color(255, 240, 240), x, iy);
			iy = iy + (lineHeight / 2);
		end
	end
end
