require "base/internal/ui/reflexcore"

DownloadProgressBar =
{
	canPosition = false,
	canHide = false,
	isMenu = false
};
registerWidget("DownloadProgressBar");

local loadingtips = 
{ 
    "Armors respawn after 25 seconds", 
    "The Red Armor is generally the most important item to control in 1v1",
    "Megahealth respawns 30 seconds after the effect is lost",
    "All advanced movement in Reflex is combinations of simple tricks such as circle jump + double jump",
    "Red armor absorbs 75% of incoming damage",
    "Yellow armor absorbs 66% of incoming damage",
    "Green armor absorbs 50% of incoming damage",
    "If you don't have armor, charging at enemies is a bad strategy",
    "Grab community-made maps from www.reflexfiles.com",
    "Rocket Launcher, Bolt Rifle and Ion Cannon do the most damage",
    "Check out our forums at www.reflexfps.net/forums",
    "Powerups respawn every 90 seconds",
    "Thank you for supporting us during Early Access!",
    "Your friends should buy Reflex",
    "Check out www.phgp.tv for news, articles and 24/7 streams!",
	"You can vote for a new map by typing 'callvote map' in the console",
	"You can vote for a new game mode by with 'callvote mode' in the console",
	"You can vote for a new map by typing 'callvote map' in the console",
	"You can vote for a new game mode by with 'callvote mode' in the console",
	"You can vote for a new map by typing 'callvote map' in the console",
	"You can vote for a new game mode by with 'callvote mode' in the console"
};

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function tableSize(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

-- this doesn't really work properly. you'll get the same tip for the entire session.
--local tip = loadingtips[math.random(2)];
local tip = nil;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function DownloadProgressBar:draw()

	-- Clear the tip and early out if there's no downloading going on
	if download.total == download.amount then
		tip = nil;
        return
	end

    -- Get a new tip if required
    if tip == nil then 
        tip = loadingtips[math.random(tableSize(loadingtips))];
    end

	-- 0,0 is center of screen
	local w = 400;
	local h = 180;
	local x = -w/2;
	local y = (viewport.height / 2) - h;

	-- Background, to avoid showing the sky color all the time.
    nvgBeginPath();
    nvgRect(-(viewport.width/2), -(viewport.height/2), viewport.width, viewport.height);
    nvgFillColor(Color(10,10,10,255));
    nvgFill();
	
    -- Logo
    local svgName = "internal/ui/icons/reflexlogo";
	nvgFillColor(Color(20,20,20,255));
	nvgSvg(svgName, 0, -100, 250);

	nvgFontSize(18);
	nvgFontFace(FONT_TEXT);

	-- "Downloading" Text
    local fontx = 0;
	local fonty = y + h - 40;
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
	nvgFillColor(Color(230, 230, 230));
	nvgText(fontx, fonty, "Downloading gamestate..");

	-- progress bar (done as button until we make a progres bar) :)
	local progressx = x + 20;
	local progressy = y + 80;
	local progresswidth = w - 40;
	local percent = 1;
	if download.amount ~= download.total then
		percent = download.amount / download.total;
	end
	uiProgressBar(progressx, progressy, progresswidth, UI_DEFAULT_BUTTON_HEIGHT, percent);

    -- Loading tips

    
    nvgBeginPath();
    nvgFontSize(36);
	nvgFontFace(FONT_HUD);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_BASELINE);
    nvgText(0, progressy - 40, tip);
    nvgFillColor(Color(230,230,230,255));
    nvgFill();
    
    -- Number of gamestates download / total.
	--local text = download.amount .. " / " .. download.total;
	--local fontx = x + w - 22;
	--local fonty = y + h - 50;
	--nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_BASELINE);
	--nvgFontBlur(2);
	--nvgFillColor(Color(0, 0, 0));
	--nvgText(fontx, fonty + 1, text);
	--nvgFontBlur(0);
	--nvgFillColor(Color(230, 230, 230));
	--nvgText(fontx, fonty, text);
end
