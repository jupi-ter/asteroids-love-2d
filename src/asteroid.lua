local asteroid = {}
local utils = require("src.utils")

asteroid.sizes = {
    SMALL = 0,
    MEDIUM = 1,
    LARGE = 2
}

function asteroid.new_asteroid(x, y, size)
    local a = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        direction_deg = 0,
        speed = 5,
        size = size,
        rotation_deg = 0,
        angle_increment = 100,
        friction = 0.99,
        accel_delta = 200,
        sprite = nil
    }

    function a:init()
        a:get_sprite()
        self.rotation_deg = math.random(359)
        self.direction_deg = math.random(359)
    end

    function a:update(dt)
        --rotate
        self.rotation_deg = self.rotation_deg + (self.angle_increment * dt)

        local direction_rad = math.rad(self.direction_deg)

        --vectorize
        self.vx = self.vx + math.cos(direction_rad) * self.accel_delta * dt
        self.vy = self.vy + math.sin(direction_rad) * self.accel_delta * dt

        --apply friction
        self.vx = self.vx * self.friction
        self.vy = self.vy * self.friction

        --apply vector position to x, y
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        --screen wrapping
        utils.screen_wrap(self)
    end

    function a:draw()
        utils.draw_sprite(self.sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true)
    end

    function a:get_sprite()
        if (self.size == asteroid.sizes.LARGE) then
            self.sprite = asteroid_large
        elseif (self.size == asteroid.sizes.MEDIUM) then
            self.sprite = asteroid_medium
        else
            self.sprite = asteroid_small
        end
    end

    return a
end

return asteroid