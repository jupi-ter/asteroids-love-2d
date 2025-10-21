local player = {}
local utils = require("src.utils")

function player.new_player(x, y)
    local p = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        accel = 0,
        accel_delta = 300,
        friction = 0.99,
        sprite = nil,
        angle_increment = 300, -- 5px
        shooting_counter = 0,
        rotation_deg = 0,
        shooting_cooldown = 60,
        on = { shoot = nil, move = nil } -- events
    }

    function p:decrement_shoot_cooldown()
    -- decrement shooting counter
        if self.shooting_counter > 0 then
            self.shooting_counter = self.shooting_counter - 1
            if self.shooting_counter < 0 then
                self.shooting_counter = 0
            end
        end
    end

    function p:init()
        self.sprite = player_center_sprite
    end

    function p:update(dt)
        p:decrement_shoot_cooldown()

        local move_left = love.keyboard.isDown("left")
        local move_right = love.keyboard.isDown("right")
        local move_up = love.keyboard.isDown("up")

        -- rotate
        if move_left then
            self.rotation_deg = self.rotation_deg - (self.angle_increment * dt)
        end

        if move_right then
            self.rotation_deg = self.rotation_deg + (self.angle_increment * dt)
        end

        if move_up then
            local rotation_rad = math.rad(self.rotation_deg)
            self.vx = self.vx + math.cos(rotation_rad) * self.accel_delta * dt
            self.vy = self.vy + math.sin(rotation_rad) * self.accel_delta * dt

        end

        -- apply friction / drag
        self.vx = self.vx * self.friction
        self.vy = self.vy * self.friction

        -- move
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        if love.keyboard.isDown('z') and self.shooting_counter == 0 then
            self.shooting_counter = self.shooting_cooldown

            -- signal event
            if self.on.shoot then
                local rot_rad = math.rad(self.rotation_deg)
                self.on.shoot(self.x, self.y, rot_rad)
            end
        end

        -- todo: screen wrapping
        if self.x > 128 then self.x = 128 end
        if self.x < 0 then self.x = 0 end
        if self.y < 0 then self.y = 0 end
        if self.y > 128 then self.y = 128 end
    end

    function p:draw()
        if self.sprite ~= nil then
            utils.draw_sprite(self.sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true)
        end
    end

    return p
end

return player