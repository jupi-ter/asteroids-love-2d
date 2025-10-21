local bullet = {}
local utils = require("src.utils")

-- bullet constructor
function bullet.new_bullet(x, y, rotation_rad)
    local bul = {
        x = x,
        y = y,
        spd = 480,
        vx = 0,
        vy = 0,
        sprite = nil,
        rotation_rad = rotation_rad,
        run_once = false
    }

    function bul:init()
        if self.run_once then
            return
        end
        
        self.sprite = bullet_sprite
        
        --set speed
        self.vx = math.cos(rotation_rad) * self.spd
        self.vy = math.sin(rotation_rad) * self.spd

        self.run_once = true
    end

    function bul:update(dt)
        self:init()
        -- move at constant velocity
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt
    end

	function bul:draw()
		utils.draw_sprite(self.sprite, self.x, self.y, rotation_rad, 1, 1, true)
	end

	function bul:is_offscreen()
		return self.x < 0 or self.x > 128 or self.y < 0 or self.y > 128
	end

    return bul
end

return bullet