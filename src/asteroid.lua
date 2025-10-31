local asteroid = {}
local utils = require("src.utils")

asteroid.sizes = {
    SMALL = 0,
    MEDIUM = 1,
    LARGE = 2
}

function asteroid.new_asteroid(x, y, size, inherited_vx, inherited_vy)
    local a = {
        type = utils.object_types.ASTEROID,
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        direction_deg = 0,
        size = size,
        rotation_deg = 0,
        angle_increment = 3,
        friction = 0.98,
        on = { destroy = nil },
        points = 0
        --sprite = nil,
        --bbox = nil
    }

    function a:init()
        a:setup()
        self.rotation_deg = math.random(359)
        
        -- If spawned from a parent asteroid, inherit some velocity
        if inherited_vx and inherited_vy then
            self.direction_deg = math.random(359)
            
            -- Add parent velocity plus new random velocity
            local direction_rad = math.rad(self.direction_deg)
            local speed = self:get_speed_for_size()
            
            self.vx = inherited_vx * 0.5 + math.cos(direction_rad) * speed
            self.vy = inherited_vy * 0.5 + math.sin(direction_rad) * speed 
        else
            -- New asteroid spawned at edge - give it velocity toward center
            self.direction_deg = self:calculate_direction_to_center()
            
            -- Add some randomness to the angle (+-45 degrees)
            self.direction_deg = self.direction_deg + math.random(-45, 45)
            
            local direction_rad = math.rad(self.direction_deg)
            local speed = self:get_speed_for_size()
            
            self.vx = math.cos(direction_rad) * speed
            self.vy = math.sin(direction_rad) * speed
        end
    end

    function a:get_speed_for_size()
        -- bigger asteroids move slower
        if self.size == asteroid.sizes.LARGE then
            return 0.1
        elseif self.size == asteroid.sizes.MEDIUM then
            return 0.25
        else
            return 0.5
        end
    end

    function a:calculate_direction_to_center()
        local center_x = screen_width / 2
        local center_y = screen_height / 2
        
        local dx = center_x - self.x
        local dy = center_y - self.y
        
        -- calculate angle in degrees
        return math.deg(math.atan2(dy, dx))
    end

    function a:update()
        -- rotate
        self.rotation_deg = self.rotation_deg + self.angle_increment

        -- direct velocity movement
        self.x = self.x + self.vx
        self.y = self.y + self.vy

        if self.bbox ~= nil then
            self.bbox:moveTo(self.x, self.y)
        end

        --screen wrapping
        utils.screen_wrap(self)
    end

    function a:draw()
        utils.draw_sprite(self.sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true)
        
        utils.debug_draw(self.bbox)
    end

    function a:setup()
       -- setup sprite and bbox and points
        if (self.size == asteroid.sizes.LARGE) then
            self.points = 30
            self.sprite = asteroid_large_sprite
            self.bbox = hc.circle(x, y, 6)
        elseif (self.size == asteroid.sizes.MEDIUM) then
            self.points = 20
            self.sprite = asteroid_medium_sprite
            self.bbox = hc.circle(x, y, 4)
        else
            self.points = 10
            self.sprite = asteroid_small_sprite
            self.bbox = hc.circle(x, y, 2)
        end

        self.bbox.owner = self
    end

    function a:take_damage()
        if self.flag_for_deletion then
            return
        end
        
        self.flag_for_deletion = true
        
        -- remove from collision system
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