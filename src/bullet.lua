local bullet = {}
local utils = require("src.utils")

-- bullet constructor
function bullet.new_bullet(x, y, rotation_rad)
    local bul = {
        type = utils.object_types.BULLET,
        x = x,
        y = y,
        spd = 480,
        vx = 0,
        vy = 0,
        --sprite = nil
        rotation_rad = rotation_rad,
        run_once = false,
        bbox = hc.rectangle(x, y, 8, 4)
    }

    function bul:init()
        if self.run_once then
            return
        end
        
        self.sprite = bullet_sprite
        self.bbox.owner = self
        
        self.bbox:setRotation(self.rotation_rad)

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

        if self.bbox ~= nil then
            self.bbox:moveTo(self.x, self.y)
        end
    end

	function bul:draw()
		utils.draw_sprite(self.sprite, self.x, self.y, rotation_rad, 1, 1, true)
        --debug draw
        if self.bbox ~= nil and debug_draw then
            love.graphics.setColor(1.0, 0.0, 1.0, 0.5)
            self.bbox:draw('fill')
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end
	end

	function bul:is_offscreen()
		return self.x < 0 or self.x > screen_width or self.y < 0 or self.y > screen_height
	end

    return bul
end

return bullet