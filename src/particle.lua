local particle = {}
local utils = require("src.utils")

function particle.new_particle(x, y, xscale, yscale, rotation_rad, color)
    local part = {
        x = x,
        y = y,
        xscale = xscale,
        yscale = yscale,
        rotation_rad = rotation_rad,
        flag_for_deletion = false,
        decrement_value = 6.0, -- 6/60 = 0.1
        sprite = nil,
        color = color
    }

    function part:init()
        self.sprite = particle_sprite
    end

    function part:update(dt)
        if (self.xscale > 0) then
            self.xscale = self.xscale - (self.decrement_value * dt)
            self.yscale = self.yscale - (self.decrement_value * dt)
        else
            if (not self.flag_for_deletion) then
                self.flag_for_deletion = true
                self.xscale = 0.0
                self.yscale = 0.0
            end
        end
    end

    function part:draw()
        if (not self.flag_for_deletion) then
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], 1.0)
            utils.draw_sprite(self.sprite, self.x, self.y, self.rotation_rad, self.xscale, self.yscale, true)
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end
    end

    return part
end

return particle