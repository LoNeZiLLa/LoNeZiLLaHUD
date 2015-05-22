
-----------------------------------------------------------------------------
--	Author: aliasedfrog 05/20/2015
--
--	Usage, gameEvents.player[variables].increase	-- boolean
--	Usage, gameEvents.player[variables].decrease	-- boolean
--	Usage, gameEvents.player[variables].equal		-- boolean
--	Usage, gameEvents.player[variables].change	-- number, difference between frames, I.E (player.previousHealth - player.health);
--
-- 	Simple Example URL: http://pastebin.com/raw.php?i=D1fYjYda
--
------------------------------------------------------------------------------

local function copyTables(destination, keysTable, valuesTable)
	valuesTable = valuesTable or keysTable
	local mt = getmetatable(keysTable)
	if mt and getmetatable(destination) == nil then
		setmetatable(destination, mt)
	end
	for k,v in pairs(keysTable) do
		if type(v) == 'table' then
			destination[k] = copyTables({}, v, valuesTable[k])
		else
			destination[k] = valuesTable[k]
		end
	end
	return destination
end

local function updateTables(target, a, b)
	for k,v in pairs(a) do		
		if type(v) == 'table' and type(b[k]) == 'table' then 
			if(not target[k]) then target[k] = {}; end;
			updateTables(target[k], a[k], b[k]);
		elseif(type(a[k]) =='number' and type(b[k]) == 'number') then
			if(not target[k]) then target[k] = {}; end;
			copyTables(target[k], {increase = "", decrease = "",  equal = "", change = ""}, {increase = (a[k] > b[k]), decrease = (b[k] > a[k]), equal = (a[k] == b[k]), change = (a[k] - b[k])});
		end;
	end;
	return target;
end



gameEvents = {
	_VERSION     = '0.1';
	_DESCRIPTION = 'GameEvent System for Reflex';
	last = {};
	update = function(self)
		if(not self.initd) then self.initd = true; copyTables(self.last, {world = world,players = players,pickupTimers = pickupTimers}); end;
		--update table.
		updateTables(self, {world = world,players = players,pickupTimers = pickupTimers}, self.last)
		
	end;	
	lastCall = function(self)
		copyTables(self.last, {world = world,players = players,pickupTimers = pickupTimers}); 
	end;
};