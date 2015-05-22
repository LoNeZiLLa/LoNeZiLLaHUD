require "base/internal/ui/development/GameEvent";

local function drawBars(x,y,w,h,fc)
	nvgBeginPath();
	nvgRect(x,y,w,h);
	nvgFillColor(fc);
	nvgFill();
end

local function drawBar(label, v, x,y,w,h)
	nvgBeginPath()	
	nvgFillColor(Color(255,255,255));
	nvgText(x,y, label);
	nvgText(x,y + 15, v );		
	drawBars(x - w - 5,y + 5,w, h * v, v >= 0 and Color(255,255,255) or Color(255,0,0));
	nvgClosePath();
end

gameEventsExample = {
	userData = {};
	};
	

function gameEventsExample:draw()
		if(not shouldShowHUD) then return end;
		 gameEvents:update() -- update info.
		 self:ammo(getPlayer());
		 self:healthtext(getPlayer());
		 self:armortext(getPlayer());
		 
		 gameEvents:lastCall(); -- if using in multiple scripts only call once.
end
registerWidget("gameEventsExample");

function gameEventsExample:ammo(p)
	local p_idx = playerIndexCameraAttachedTo;	
	local w_idx = p.weaponIndexSelected;
	local ammo = gameEvents.players[p_idx].weapons[w_idx].ammo;	
	local emptyWeapTable = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0,[6] = 0,[7] = 0,[8] = 0};
	self.ammoused = self.ammoused or {};
	self.ammoused[p_idx] = self.ammoused[p_idx] or emptyWeapTable;
		if(ammo.change ~= 0) then --change of value occurred			
			
			self.ammoused = self:resetObject(self.ammoused); -- reset if game ended other stuff. just example.
		
			self.ammoused[p_idx][w_idx] = self.ammoused[p_idx][w_idx] + ammo.change;
		end;
	drawBar("ammo used", self.ammoused[p_idx][w_idx], 105,35, 20, 0.1 * self.ammoused[p_idx][w_idx]);
end

function gameEventsExample:healthtext(p)		
	local p_idx = playerIndexCameraAttachedTo; -- Current player index.
	local e_health = gameEvents.players[p_idx].health; -- gameEvent object, players[current player index].health. get event object.	
	if(e_health.changed ~= 0) then --change of value occurred
		self.health = self.health or {}; -- create if not set, reuse if not nil.
	
		local e_gameState = gameEvents.world.gameState;
		self.health[p_idx] = self.health[p_idx] or 0;
	
		self.health = self:resetObject(self.health); -- reset if game ended other stuff. just example.
	
		if(gameEvents.last.players[p_idx].health > 0 and p.health > 0) then --you were alive?
			self.health[p_idx] = self.health[p_idx] + e_health.change;
		end
	end
	drawBar("health/damage", self.health[p_idx], 5,35, 20, 0.01 * self.health[p_idx]);
	
end

function gameEventsExample:armortext(p)
	local p_idx = playerIndexCameraAttachedTo
	local e_armor = gameEvents.players[p_idx].armor;
	if(e_armor.changed ~= 0) then --change of value occurred
		self.armor = self.armor or {};
		local e_gameState = gameEvents.world.gameState;
		self.armor[p_idx] = self.armor[p_idx] or 0;		
				
		self.armor = self:resetObject(self.armor); -- reset if game ended other stuff. just example.
				
		if(gameEvents.last.players[p_idx].armor > 0 and p.armor > 0) then --you were alive?
			self.armor[p_idx] = self.armor[p_idx] + e_armor.change;
		end
	end;
	drawBar("armor/loss", self.armor[p_idx], -75,35, 20, 0.01 * self.armor[p_idx]);	
end

function gameEventsExample:resetObject(obj)
	if(gameEvents.world.gameState.change > 0 or gameEvents.world.gameState.change < 0 or not gameEvents.world.gameModeIndex.equal) then 
		obj = nil;
		return obj;
	end
	return obj;
end