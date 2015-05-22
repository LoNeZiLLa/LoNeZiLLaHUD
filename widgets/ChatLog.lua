require "base/internal/ui/reflexcore"

ChatLog =
{
	--canHide = false;
	canPosition = true;

	cursorFlash = 0;
};
registerWidget("ChatLog");

local deathKillMessages = {};
deathKillMessages[DAMAGE_TYPE_MELEE] = "%s butchered %s (Melee)";
deathKillMessages[DAMAGE_TYPE_BURST] = "%s fragged %s (Burst Gun)";
deathKillMessages[DAMAGE_TYPE_SHELL] = "%s fragged %s (Shotgun)";
deathKillMessages[DAMAGE_TYPE_GRENADE] = "%s exploded %s (Grenade Launcher)";
deathKillMessages[DAMAGE_TYPE_PLASMA] = "%s burned %s (Chaingun)";
deathKillMessages[DAMAGE_TYPE_ROCKET] = "%s exploded %s (Rocket Launcher)";
deathKillMessages[DAMAGE_TYPE_BEAM] = "%s melted %s (Ion Cannon)";
deathKillMessages[DAMAGE_TYPE_BOLT] = "%s punctured %s (Bolt Rifle)";
deathKillMessages[DAMAGE_TYPE_STAKE] = "%s staked %s (Stake Gun)";
deathKillMessages[DAMAGE_TYPE_TELEFRAG] = "%s telefragged %s!";

local deathSuicideMessages = {};
deathSuicideMessages[DAMAGE_TYPE_GRENADE] = "%s blew themselves up";
deathSuicideMessages[DAMAGE_TYPE_PLASMA] = "%s burned themselves";
deathSuicideMessages[DAMAGE_TYPE_ROCKET] = "%s blew themselves up";
deathSuicideMessages[DAMAGE_TYPE_LAVA] = "%s melted!";
deathSuicideMessages[DAMAGE_TYPE_DROWN] = "%s drowned!";
deathSuicideMessages[DAMAGE_TYPE_OUTOFWORLD] = "%s fell out of the world!";
deathSuicideMessages[DAMAGE_TYPE_OVERTIME] = "%s's health ran out!";
deathSuicideMessages[DAMAGE_TYPE_SUICIDE] = "%s has committed suicide";

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function formatDeathMessage(logEntry)
	if logEntry.deathSuicide then
		local fmt = deathSuicideMessages[logEntry.deathDamageType];
		if fmt == nil then
			return nil;
		end
		return string.format(fmt, logEntry.deathKilled);
	end

	local fmt = deathKillMessages[logEntry.deathDamageType];
	if fmt == nil then
		return nil;
	end
	return string.format(fmt, logEntry.deathKiller, logEntry.deathKilled);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function formatRaceMessage(logEntry)
	
	-- is this event for the player we're watching?
	local isLocal = logEntry.racePlayerIndex == playerIndexCameraAttachedTo;

	-- find topscore
	local topScore = 0;
	for k, v in pairs(players) do
		if v.connected and v.score ~= 0 then
			if topScore == 0 then
				topScore = v.score;
			else
				topScore = math.min(topScore, v.score);
			end
		end
	end

	if logEntry.raceEvent == RACE_EVENT_FINISH or logEntry.raceEvent == RACE_EVENT_FINISHANDWASRECORD then
		local formattedTime = FormatTimeToDecimalTime(logEntry.raceTime);

		-- fixme: if players draw, if someone finishes in EXACTLY the same time, we can't tell the difference here
		local optText = "";
		if topScore == logEntry.raceTime and logEntry.raceEvent == RACE_EVENT_FINISHANDWASRECORD then
			optText = ", and is in the lead!";
		end

		return string.format("%s finished race in %s%s", logEntry.raceName, formattedTime, optText);
	end

	return nil;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ChatLog:draw()
	local localPlayer = getLocalPlayer();
	local cursorFlashPeriod = 0.25;
	
	local col = Color(230, 230, 230);
	local colTeam = Color(126, 204, 255);
	local colSpec = Color(255, 204, 126);
	local borderPad = 10;
	local logCount = 0;
	local x = 0;
	local y = 0;
	local w = 800;
	local h = 196;
	local bordery = y+12;

	for k, v in pairs(log) do
		logCount = logCount + 1;
	end

	-- no chatlog in menu replay
	if replayName == "menu" then
		return false;
	end
	
	-- prep
	nvgFontSize(FONT_SIZE_DEFAULT);
	nvgFontFace(FONT_HUD);
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	
	-- read input
	local say = sayRegion();
	
	-- if cursor moves, restart flash
	self.cursorFlash = self.cursorFlash + deltaTime;
	if say.cursorChanged then
		self.cursorFlash = 0;
	end

	-- when typing draw border
	if say.hoverAmount > 0 then
		local intensity = say.hoverAmount;
		local borderCol = Color(150, 150, 150, 150 * intensity);
		local bgCol = Color(34+10, 36+10, 40+10, 150 * intensity);

		-- draw bg
		nvgBeginPath();
		nvgRect(x - borderPad, bordery - h - borderPad, w + borderPad * 2, h + borderPad * 2, 10);
		nvgFillColor(bgCol);
		nvgFill();
		nvgStrokeColor(borderCol);
		nvgStroke();

		-- draw separator
		nvgBeginPath();
		nvgMoveTo(x - borderPad, y - 15);
		nvgLineTo(x + w + borderPad, y - 15);
		nvgStroke(borderCol);

		--nvgBeginPath();
		--nvgRect(x, bordery - h, w, h);
		--nvgFillColor(Color(255, 0, 0));
		--nvgFill();

		-- "player: " text
		local entryTextStart = localPlayer.name;
		local entryCol = Color(col.r, col.g, col.b, 255 * intensity);
		if say.sayTeam then
			entryCol.r = colTeam.r;
			entryCol.g = colTeam.g;
			entryCol.b = colTeam.b;
			entryTextStart = entryTextStart .. " (team)";
		elseif say.saySpec then
			entryCol.r = colSpec.r;
			entryCol.g = colSpec.g;
			entryCol.b = colSpec.b;
			entryTextStart = entryTextStart .. " (spec)";
		end
		entryTextStart = entryTextStart .. ": ";
		local entryText = entryTextStart .. say.text;
		local entryLen = string.len(entryTextStart);

		-- entry
		nvgFontBlur(2);
		nvgFillColor(Color(0, 0, 0, intensity*255));
		nvgText(x, y + 1, entryText);
		nvgFontBlur(0);
		nvgFillColor(entryCol);
		nvgText(x, y, entryText);
		
		local textUntilCursor = string.sub(entryText, 0, say.cursor + entryLen);
		local textWidthAtCursor = nvgTextWidth(textUntilCursor);

		-- multiple selection, draw selection field
		if say.cursor ~= say.cursorStart then
			local textUntilCursorStart = string.sub(entryText, 0, say.cursorStart + entryLen);
			local textWidthAtCursorStart = nvgTextWidth(textUntilCursorStart);
		
			local selx = math.min(textWidthAtCursor, textWidthAtCursorStart);
			local selw = math.abs(textWidthAtCursor - textWidthAtCursorStart);
			nvgBeginPath();
			nvgRect(x + selx, y - 10, selw, 22);
			nvgFillColor(Color(255, 192, 192, 128));
			nvgFill();	
		end

		-- flashing cursor
		if self.cursorFlash < cursorFlashPeriod then
			nvgBeginPath();
			nvgMoveTo(x + textWidthAtCursor, y - 10);
			nvgLineTo(x + textWidthAtCursor, y + 12);
			nvgStrokeColor(Color(col.r,col.g,col.b,128*intensity));
			nvgStroke();
		else
			if self.cursorFlash > cursorFlashPeriod*2 then
				self.cursorFlash = 0;
			end
		end
	end
			
	y = y - 34;
	nvgScissor(x, bordery - h, w, h);
	
	-- history
	for i = 1, logCount do
		local logEntry = log[i];
		local intensity = clamp(1 - (logEntry.age - 9), 0, 1); -- fade out from 9->10 seconds

		local text = nil;

		if logEntry.type == LOG_TYPE_CHATMESSAGE then
			local mod = "";

			col = Color(239, 237, 255, 255*intensity);
			if logEntry.chatType == LOG_CHATTYPE_TEAM then
				col = Color(126, 204, 255);
				mod = " (team)";
			end
			if logEntry.chatType == LOG_CHATTYPE_SPECTATOR then
				col = Color(255, 204, 126);
				mod = " (spec)";
			end

			text = logEntry.chatPlayer .. mod .. ": " .. logEntry.chatMessage;

		elseif logEntry.type == LOG_TYPE_NOTIFICATION then
			col = Color(255, 288, 0);
			text = logEntry.notification;
		elseif logEntry.type == LOG_TYPE_DEATHMESSAGE then
			col = Color(255, 30, 30);
			text = formatDeathMessage(logEntry);
		elseif logEntry.type == LOG_TYPE_RACEEVENT then
			col = Color(255, 30, 30);
			text = formatRaceMessage(logEntry);			
		end

		if text ~= nil then
			-- bg
			nvgFontBlur(2);
			nvgFillColor(Color(0, 0, 0, 255*intensity));
			nvgText(x, y + 1, text);

			-- foreground
			nvgFontBlur(0);
			nvgFillColor(col);
			nvgText(x, y, text);

			y = y - 24;
		end
	end
end
