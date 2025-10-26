local asteroid = {}
local utils = require("src.utils")

asteroid.sizes = {
    SMALL = 0,
    MEDIUM = 1,
    LARGE = 2
}

function asteroid.new_asteroid(x, y, size)
    local a = {
        type = utils.object_types.ASTEROID,
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
        on = { destroy = nil }
        --sprite = nil,
        --bbox = nil
    }

    function a:init()
        a:get_sprite_and_set_bbox()
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

        --move
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        if self.bbox ~= nil then
            self.bbox:moveTo(self.x, self.y)
        end

        --screen wrapping
        utils.screen_wrap(self)
    end

    function a:draw()
        utils.draw_sprite(self.sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true)
        if self.bbox ~= nil then
            love.graphics.setColor(1.0, 0.0, 1.0, 0.5)
            self.bbox:draw('fill')
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end
    end

    function a:get_sprite_and_set_bbox()
        if (self.size == asteroid.sizes.LARGE) then
            self.sprite = asteroid_large
            self.bbox = hc.circle(x, y, 6)
        elseif (self.size == asteroid.sizes.MEDIUM) then
            self.sprite = asteroid_medium
            self.bbox = hc.circle(x, y, 4)
        else
            self.sprite = asteroid_small
            self.bbox = hc.circle(x, y, 2)
        end

        self.bbox.owner = self
    end

    function a:take_damage()
        if self.flag_for_deletion then
            return
        end
        
        self.flag_for_deletion = true
        
        --remove from collision system
        if self.bbox then
            hc.remove(self.bbox)
            self.bbox = nil
        end
        
        -- trigger destroy event
        if self.on.destroy then
            self.on.destroy(self)
        end
    end

    return a
end

return asteroid