    local player = {}
    local utils = require("src.utils")

    function player.new_player(x, y)
        local p = {
            type = utils.object_types.PLAYER, -- for collision purposes
            x = x,
            y = y,
            vx = 0,
            vy = 0,
            accel = 0,
            accel_delta = 300,
            friction = 0.99,
            --sprite = nil,
            angle_increment = 300, -- 5px
            shooting_counter = 0,
            rotation_deg = 0,
            shooting_cooldown = 60,
            on = { shoot = nil, move = nil }, -- events
            -- initializing a value as nil doesn't actually initialize it,
            -- so this table is actually empty. however, we still declare these values here
            -- for reference, so we know which events exist in the game.
            -- we do this all across the project so, while they're being initialized later, we
            -- know they exist in the context by simply checking the table definition.
            particle_frame = 0,
            bbox = hc.rectangle(x, y, 6, 6)
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
            self.bbox.owner = self
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

            -- rotate collision box
            self.bbox:setRotation(math.rad(self.rotation_deg))

            if move_up then
                local rotation_rad = math.rad(self.rotation_deg)
                self.vx = self.vx + math.cos(rotation_rad) * self.accel_delta * dt
                self.vy = self.vy + math.sin(rotation_rad) * self.accel_delta * dt

                self.particle_frame = self.particle_frame + 1

                --spawn a particle every 8 frames
                if self.on.move and self.particle_frame % 8 == 0 then
                    self.particle_frame = 0

                    -- Add perpendicular offset
                    local noise_amount = math.random(-2, 2)
                    local perpendicular_angle = rotation_rad + math.pi/2  -- 90 degrees
                    
                    local offset_x = math.cos(perpendicular_angle) * noise_amount
                    local offset_y = math.sin(perpendicular_angle) * noise_amount
                    
                    local possible_colors = {
                        utils.colors.YELLOW,
                        utils.colors.RED,
                        utils.colors.ORANGE
                    }

                    self.on.move(
                        self.x + offset_x,
                        self.y + offset_y,
                        1.0,
                        1.0,
                        rotation_rad,  -- keep particle aligned with ship
                        possible_colors[math.random(1, #possible_colors)]
                    )
                end
            end

            -- apply friction / drag
            self.vx = self.vx * self.friction
            self.vy = self.vy * self.friction

            -- move
            self.x = self.x + self.vx * dt
            self.y = self.y + self.vy * dt

            --move collision box
            self.bbox:moveTo(self.x, self.y)

            if love.keyboard.isDown('z') and self.shooting_counter == 0 then
                self.shooting_counter = self.shooting_cooldown

                -- signal event
                if self.on.shoot then
                    local rot_rad = math.rad(self.rotation_deg)
                    self.on.shoot(self.x, self.y, rot_rad)
                end
            end
            
            -- screen clamping
            utils.screen_wrap(self)
        end

        function p:draw()
            utils.draw_sprite(self.sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true)
            love.graphics.setColor(1.0, 0.0, 1.0, 0.5)
            self.bbox:draw('fill')
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end

        return p
    end

    return player