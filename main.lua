function draw_sprite(sprite, x, y, rotation, image_xscale, image_yscale, draw_from_origin)
    if sprite ~= nil then
        if draw_from_origin then
            love.graphics.draw(sprite, x, y, rotation, image_xscale, image_yscale, sprite.getWidth(sprite) / 2, sprite.getHeight(sprite) / 2)
        else
            love.graphics.draw(sprite, x, y, rotation, image_xscale, image_yscale, 0, 0)
        end
    end
end

function new_player(xx, yy)
    local p = {
        x = xx,
        y = yy,
        spd = 120, --this is pixels per second 120/60 || (120*0.0167) = 2px per button press
        sprite = nil,
        angle_increment = 300, -- 5px
        shooting_counter = 0,
        rotation_deg = 0
    }

    function p:update(dt)
        -- decrement shooting counter
        if self.shooting_counter > 0 then
            self.shooting_counter = self.shooting_counter - 1
            if self.shooting_counter < 0 then
                self.shooting_counter = 0
            end
        end

        local move_left = love.keyboard.isDown("left")
        local move_right = love.keyboard.isDown("right")
        local move_up = love.keyboard.isDown("up")

        --rotate
        if move_left then
            self.x = self.x - self.spd * dt
        end

        if move_right then
            self.x = self.x + self.spd * dt
        end

        --accelerate
        if move_up then self.y = self.y - self.spd * dt end

        if love.keyboard.isDown("space") and self.shooting_counter == 0 then
            self.shooting_counter = 60

            local b = new_pbullet(self.x, self.y)
            table.insert(bullets, b)
        end

        -- screen clamping
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
function new_pbullet(xx, yy)
	local bul = {
		x = xx,
		y = yy,
		spd = 480,
		sprite = nil,
        run_once = false,
        rotation = 0.0
	}

    function bul:init()
        if self.run_once then
            return
        end

        self.sprite = bullet_sprite

        self.run_once = true
    end

	function bul:update(dt)
        self:init()
    
		self.y = self.y - self.spd * dt
	end

	function bul:draw()
		draw_sprite(self.sprite, self.x, self.y, self.rotation, 1, 1, true)
	end

	function bul:is_offscreen()
		return self.x < 0 or self.x > 128 or self.y < 0 or self.y > 128
	end

	return bul
end

function love.load()
    local width, height = 128, 128

    love.window.setMode(width, height, {
        fullscreen = true,
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