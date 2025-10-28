local player = {}
local utils = require("src.utils")

player.states = {
    ALIVE = "alive",
    DYING = "dying",
    DEAD = "dead"
}

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
        on = { shoot = nil, move = nil, death = nil }, -- events
        -- initializing a value as nil doesn't actually initialize it,
        -- so this table is actually empty. however, we still declare these values here
        -- for reference, so we know which events exist in the game.
        -- we do this all across the project so, while they're being initialized later, we
        -- know they exist in the context by simply checking the table definition.
        particle_frame = 0,
        bbox = hc.rectangle(x, y, 6, 6),
        --state
        state = player.states.ALIVE,
        respawn_timer = 0,
        respawn_delay = 120,  -- 2 seconds at 60fps
        invulnerable = false,
        invulnerable_timer = 0,
        invulnerable_duration = 120,  -- 2 seconds of invulnerability after respawn
        spawn_x = x,
        spawn_y = y
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
        if self.state == player.states.DEAD then
            return
        end

        if self.state == player.states.DYING then
            self.respawn_timer = self.respawn_timer - 1
            if self.respawn_timer <= 0 then
                self:respawn()
            end
            return  -- Don't process other updates while dead
        end
        
        -- Handle invulnerability
        if self.invulnerable then
            self.invulnerable_timer = self.invulnerable_timer - 1
            if self.invulnerable_timer <= 0 then
                self.invulnerable = false
            end
        end

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

                self.on.move(
                    self.x + offset_x,
                    self.y + offset_y,
                    3.0
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
        if self.state ~= "alive" then
            return
        end
    
        -- blink while invulnerable (draw every other 4 frames)
        if self.invulnerable and math.floor(self.invulnerable_timer / 4) % 2 == 0 then
            return
        end

        utils.draw_sprite(self.sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true)
        if self.bbox ~= nil and debug_draw then
            love.graphics.setColor(1.0, 0.0, 1.0, 0.5)
            self.bbox:draw('fill')
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end
    end

    function p:die()
        if self.state == player.states.DYING then
            return
        end
        
        self.state = player.states.DYING
        self.respawn_timer = self.respawn_delay
        
        -- spawn death particles
        if self.on.death then
            self.on.death(self)
        end
    end

    function p:respawn()
        self.state = player.states.ALIVE
        self.x = self.spawn_x
        self.y = self.spawn_y
        self.vx = 0
        self.vy = 0
        self.rotation_deg = 0
        self.invulnerable = true
        self.invulnerable_timer = self.invulnerable_duration
    end

    function p:is_alive()
        return self.state == player.states.ALIVE
    end

    return p
end

return player