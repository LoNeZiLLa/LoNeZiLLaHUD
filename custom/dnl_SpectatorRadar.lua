require "base/internal/ui/reflexcore"

-- TODO item icons for mh/ya/ra/carnage
-- grey out item icons if not spawned
-- grey out player dots if they are dead until they respawn

-- CONSTANTS
ICON_ARMOR = "internal/ui/icons/armor"
ICON_HEALTH = "internal/ui/icons/health"
ICON_CARNAGE = "internal/ui/icons/carnage"
COLOR_MH = Color(60, 80, 255, 255)
COLOR_RA = Color(255, 0, 0, 255)
COLOR_YA = Color(255, 255, 0, 255)
COLOR_CARNAGE = Color(255, 120, 128, 255)

-- Store persistent user_data
dnl_SpectatorRadar = {user_data = {}}
registerWidget("dnl_SpectatorRadar")

function dnl_SpectatorRadar:initialize()
    -- Load stored user_data
    self.user_data = loadUserData()
    
    -- Check user_data exists and if not set the default values
    CheckSetDefaultValue(self, "user_data", "table", {})
    CheckSetDefaultValue(self.user_data, "radar_rotate", "boolean", true)
    CheckSetDefaultValue(self.user_data, "radar_scale", "int", 1500)
    CheckSetDefaultValue(self.user_data, "radar_radius", "int", 200)
    CheckSetDefaultValue(self.user_data, "player_dot_radius", "int", 5)
    CheckSetDefaultValue(self.user_data, "ally_dot_radius", "int", 5)
    CheckSetDefaultValue(self.user_data, "enemy_dot_radius", "int", 5)
    CheckSetDefaultValue(self.user_data, "color_player", "table", Color(255, 255, 255 ,255))
    CheckSetDefaultValue(self.user_data, "color_allies", "table", Color(0, 255, 0, 255))
    CheckSetDefaultValue(self.user_data, "color_enemies", "table", Color(255, 0, 0, 255))
    CheckSetDefaultValue(self.user_data, "color_background", "table", Color(100, 100, 100, 100))
end

function dnl_SpectatorRadar:draw()
    if not shouldShowHUD() then 
        return
    end
    -- Early out if the local player isn't spectating
    -- Position information is only available when spectating
    state = getLocalPlayer().state
    if not (state == PLAYER_STATE_SPECTATOR or 
            state == PLAYER_STATE_QUEUED) then
        return
    end
    -- Draw radar background
    nvgBeginPath()
    nvgCircle(0, 0, self.user_data.radar_radius)
    nvgFillColor(self.user_data.color_background)
    nvgFill()
    
    -- Draw player dot
    nvgBeginPath()
    nvgCircle(0, 0, self.user_data.player_dot_radius)
    nvgFillColor(self.user_data.color_player)
    nvgFill()
    
    -- Draw arrow on player dot
    local spectating_player = getPlayer()
    local spectating_player_yaw_rad = math.rad(spectating_player.anglesDegrees.x)
    --[[
    -- Draw mark on dot showing player direction
    local mark_angle = nil
    if not self.user_data.radar_rotate then
        -- Draw a mark on the player dot in the direction the player is facing
        mark_angle = 0
    else
        -- Draw a mark pointing north
        mark_angle = math.rad(-135)
    end
    nvgBeginPath()
    nvgRotate(mark_angle)
    nvgRect(0, 0, self.user_data.player_dot_radius, self.user_data.player_dot_radius)
    nvgFillColor(self.user_data.color_player)
    nvgFill()
    nvgRotate(-mark_angle)
    --]]
    -- Draw dots for each other player playing
    for i = 1, #players do
        local current_player = players[i]
        if current_player.state == PLAYER_STATE_INGAME and current_player.connected and
           current_player ~= spectating_player then
            -- Determine dot color and radius
            local dot = {}
            if not (world.gameModeIndex == 3 or world.gameModeIndex == 6) or current_player.team ~= spectating_player.team then
                -- Enemy
                dot.color = self.user_data.color_enemies
                dot.radius = self.user_data.enemy_dot_radius
            else
                -- Ally
                dot.color = self.user_data.color_allies
                dot.radius = self.user_data.ally_dot_radius
            end
            
            -- Determine dot coordinates on the radar, depends on relative positions, scale
            dot.x = (current_player.position.x - spectating_player.position.x) * self.user_data.radar_radius / self.user_data.radar_scale
            dot.y = (spectating_player.position.z - current_player.position.z) * self.user_data.radar_radius / self.user_data.radar_scale
            if self.user_data.radar_rotate then
                -- Rotate dot around center depending on player angle
                local rotated_point = rotate_point(dot, -1 * spectating_player_yaw_rad)
                dot.x = rotated_point.x
                dot.y = rotated_point.y
                local vector_length = math.sqrt(dot.x ^ 2 + dot.y ^ 2)
                if vector_length > self.user_data.radar_radius - dot.radius then
                    -- Dot is too far away to fit on radar, keep it on the edge
                    -- Scale vector (rotated_dot_x, rotated_dot_y) back to length (RADAR_RADIUS - dot_radius)
                    dot.x = dot.x / vector_length * (self.user_data.radar_radius - dot.radius)
                    dot.y = dot.y / vector_length * (self.user_data.radar_radius - dot.radius)
                end
            else 

            end
            nvgBeginPath()
            nvgCircle(dot.x, dot.y, dot.radius)
            nvgFillColor(dot.color)
            nvgRotate(spectating_player_yaw_rad)
            nvgFill()
        end
    end
end

function rotate_point(point, angle)
    local sine = math.sin(angle)
    local cosine = math.cos(angle)
    return {["x"] = point.x * cosine - point.y * sine, ["y"] = point.x * sine + point.y * cosine}
end

function dnl_SpectatorRadar:drawOptions(x, y)
    local user = self.user_data
    
    local new_rotate = uiCheckBox(user.radar_rotate, "Rotate the radar with the player?", x, y, 0, true)
    if new_rotate ~= user.radar_rotate then
        user.radar_rotate = new_rotate
    end
    y = y + 50
    user.radar_radius = get_option_value("Radar radius (when widget scale = 1)", user.radar_radius, x, y)
    y = y + 100
    user.radar_scale = get_option_value("Radar scale (how much units the radar radius represents)", user.radar_scale, x, y)
    y = y + 100
    user.player_dot_radius = get_option_value("Player dot radius (when widget scale = 1)", user.player_dot_radius, x, y)
    y = y + 100
    user.ally_dot_radius = get_option_value("Ally dot radius (when widget scale = 1)", user.ally_dot_radius, x, y)
    y = y + 100
    user.enemy_dot_radius = get_option_value("Enemy dot radius (when widget scale = 1)", user.enemy_dot_radius, x, y)
    y = y + 100
    uiColorPicker(x, y, user.color_background, {})
    
    saveUserData(user)
end

function get_option_value(description, var, x, y)
    uiLabel(description, x, y)
    y = y + 40
    local new_var = uiEditBox(var, x, y, 100)
    if new_var ~= var then
        return new_var
    else
        return var
    end
end

function dnl_SpectatorRadar:getOptionsHeight()
    return 1000 -- debug with: ui_optionsmenu_show_properties_height 1
end