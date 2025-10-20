function draw_sprite(sprite, x, y, rotation, image_xscale, image_yscale, draw_from_origin)
    if sprite ~= nil then
        if draw_from_origin then
            love.graphics.draw(sprite, x, y, rotation, image_xscale, image_yscale, sprite.getWidth(sprite) / 2, sprite.getHeight(sprite) / 2)
        else
            love.graphics.draw(sprite, x, y, rotation, image_xscale, image_yscale, 0, 0)
        end
    end
end

function new_particle(xx, yy)
    local part = {
        x = xx,
        y = yy
    }

    function part:init()

    end

    function part:update()

    end

    function part:draw()

    end

    return part
end

function new_player(xx, yy)
    local p = {
        x = xx,
        y = yy,
        vx = 0,
        vy = 0,
        accel = 0,
        accel_delta = 200,
        max_accel = 300,  --this is pixels per second 120/60 || (120*0.0167) = 2px per button press
        friction = 0.99,
        sprite = nil,
        angle_increment = 300, -- 5px
        shooting_counter = 0,
        rotation_deg = 0,
        shooting_cooldown = 15
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

            local b = new_pbullet(self.x, self.y, math.rad(self.rotation_deg))
            table.insert(bullets, b)
        end

        -- todo: screen wrapping
        if self.x > 128 then self.x = 128 end
        if self.x < 0 then self.x = 0 end
        if self.y < 0 then self.y = 0 end
        if self.y > 128 then self.y = 128 end
    end

    function p:draw()
        if self.sprite ~= nil then
            draw_sprite(self.sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true)
        end
    end

    return p
end

--player bullet
function new_pbullet(xx, yy, rotation_rad)
    local bul = {
        x = xx,
        y = yy,
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
		draw_sprite(self.sprite, self.x, self.y, rotation_rad, 1, 1, true)
	end

	function bul:is_offscreen()
		return self.x < 0 or self.x > 128 or self.y < 0 or self.y > 128
	end

	return bul
end

function love.load()
    local width, height = 128, 128

    love.window.setMode(width, height, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        minwidth = 128,
        minheight = 128
    })

    -- Optional: nicer scaling for pixel art
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Background color (RGB 0.0 - 1.0)
    love.graphics.setBackgroundColor(0.0, 0.0, 0.0)

    --load sprites first
    player_center_sprite = love.graphics.newImage("ship.png")
    bullet_sprite = love.graphics.newImage("bullet_2.png")

    --objects
    player = new_player(64,64)
    player:init()

    bullets = {}
end

function love.update(dt)
    player:update(dt)

    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b:update(dt)

        if b:is_offscreen() then
            table.remove(bullets, i)
        end
    end
end

function love.draw()
    local win_w, win_h = love.graphics.getDimensions()
    local scale_x = win_w / 128
    local scale_y = win_h / 128

    -- uniform scaling (preserves aspect ratio, no stretching)
    local scale = math.min(scale_x, scale_y)

    --start drawing
    love.graphics.push()
    love.graphics.scale(scale, scale)

    -- center the game world in the window
    local offset_x = (win_w/scale - 128) / 2
    local offset_y = (win_h/scale - 128) / 2
    love.graphics.translate(offset_x, offset_y)

    -- now draw your world
    player:draw()

    --draw bullets
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b:draw()
    end

    --stop drawing
    love.graphics.pop()
end