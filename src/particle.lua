local particle = {}
local utils = require("src.utils")

--x, y, xscale, yscale, rotation_rad, move
function particle.new_particle(x, y, scale, move)
    local part = {
        x = x,
        y = y,
        scale = scale,
        rotation_rad = math.rad(math.random(359)),
        decrement_value = 6.0, -- 6/60 ~ .1
        possible_colors = { --backwards because we're decreasing lifetime
            utils.colors.DARKGREY,
            utils.colors.ORANGE,
            utils.colors.YELLOW,
            utils.colors.WHITE
        },
        move = move,
        lifetime = 5,
        flag_for_deletion = false,
        speed_factor = 60,
        speed_x = 0,
        speed_y = 0,
        color = 0
        --sprite = nil,
    }
    
    function part:init()
        self.sprite = particle_sprite
        if self.move then
            self.speed_x = (1 - utils.random_float(2.0)) * self.speed_factor
            self.speed_y = (1 - utils.random_float(2.0)) * self.speed_factor
        end
    end

    function part:update(dt)
        if self.flag_for_deletion then
            return
        end

        if self.move then
            self.x = self.x + (self.speed_x * dt)
            self.y = self.y + (self.speed_y * dt)
        end

        if (self.scale > 0) then
            self.scale = self.scale - (self.decrement_value * dt)
        end

        local idx = math.floor(self.lifetime)
        idx = math.max(1, math.min(#self.possible_colors, idx))
        self.color = self.possible_colors[idx]

        if (self.lifetime > 0) then
            self.lifetime = self.lifetime - (self.decrement_value * dt)
        else
            if (not self.flag_for_deletion) then
                self.flag_for_deletion = true
            end
        end
    end

    function part:draw()
        if (not self.flag_for_deletion) then
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], 1.0)
            love.graphics.circle("fill", self.x, self.y, self.scale)
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end
    end

    return part
end

return particle