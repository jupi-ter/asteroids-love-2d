--requires (modules are lowercase)
local utils = require("src.utils")
local player = require("src.player")
local bullet = require("src.bullet")
local particle = require("src.particle")
local asteroid = require("src.asteroid")
local starfield = require("src.starfield")

--globals
screen_width, screen_height = 128, 128
score = 0
lives = 3
high_score = 0
game_states = {
    PLAYING = "playing",
    GAME_OVER = "game over"
}
game_state = game_states.PLAYING
debug_draw = false

--love.run override to lock game to 60 fps
function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
    
    -- Fixed timestep variables
    local fps = 60
    local frame_time = 1 / fps
    local lag = 0
    local last_time = love.timer.getTime()
    
    -- We don't want the first frame's dt to include time taken by love.load
    if love.timer then love.timer.step() end
    
    -- Main loop - return a function that gets called each frame
    return function()
        -- Calculate delta time
        local now = love.timer.getTime()
        local dt = now - last_time
        last_time = now
        
        -- Cap dt to prevent "spiral of death"
        if dt > 0.25 then
            dt = 0.25
        end
        
        lag = lag + dt
        
        -- Process events
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end
        
        -- Update at fixed timestep
        while lag >= frame_time do
            if love.update then
                love.update(frame_time)
            end
            lag = lag - frame_time
        end
        
        -- Draw
        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            
            if love.draw then
                love.draw()
            end
            
            love.graphics.present()
        end
        
        -- Lock framerate
        local elapsed = love.timer.getTime() - now
        if elapsed < frame_time then
            love.timer.sleep(frame_time - elapsed)
        end
    end
end

function init_game()
    -- reset globals
    score = 0
    lives = 3
    game_state = game_states.PLAYING
    
    -- reset HC collision system
    hc.resetHash()

    -- objects
    Player = player.new_player(screen_width/2, screen_height/2)
    Player:init()
    
    -- tables
    bullets = {}
    particles = {}
    asteroids = {}

    starfield.init() --init stars

    -- spawn initial asteroids
    spawn_asteroid(20, 20, asteroid.sizes.LARGE)
    spawn_asteroid(screen_width - 20, 20, asteroid.sizes.LARGE)
    spawn_asteroid(screen_width/2, screen_height - 20, asteroid.sizes.LARGE)

    -- callbacks (lambdas)
    Player.on.shoot = function(x, y, rot)
        local b = bullet.new_bullet(x, y, rot)
        table.insert(bullets, b)
    end

    -- add particle spawner callback
    Player.on.move = function(x, y, scale)
        create_particle(x, y, scale, false)
    end

    -- explosion on death
    Player.on.death = function(self)
        lives = lives - 1

        create_explosion(self.x, self.y)

        if (lives <= 0) then
            self.state = player.states.DEAD

            --game over
            game_state = game_states.GAME_OVER

            -- update high score
            if score > high_score then
                high_score = score
            end
            
            -- clear all game objects' collision boxes
            clear_all_collision_boxes()
        end
    end
end

function clear_all_collision_boxes()
    if Player and Player.bbox then
        hc.remove(Player.bbox)
        Player.bbox = nil
    end
    
    for i = #bullets, 1, -1 do
        if bullets[i].bbox then
            hc.remove(bullets[i].bbox)
            bullets[i].bbox = nil
        end
    end
    
    for i = #asteroids, 1, -1 do
        if asteroids[i].bbox then
            hc.remove(asteroids[i].bbox)
            asteroids[i].bbox = nil
        end
    end
end

function window_setup()
    --setup window
    love.window.setMode(screen_width, screen_height, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        minwidth = 512,
        minheight = 512
    })
    
    --scaling
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.graphics.setBackgroundColor(0.0, 0.0, 0.0)
end

function load_sprites()
    player_center_sprite = utils.load_sprite("ship")
    bullet_sprite = utils.load_sprite("bullet_2")
    particle_sprite = utils.load_sprite("particle")
    asteroid_large = utils.load_sprite("asteroid_large")
    asteroid_medium = utils.load_sprite("asteroid_medium")
    asteroid_small = utils.load_sprite("asteroid_small")
end

function love.load()
    font = love.graphics.newFont("assets/font/monogram.ttf", 16)
    font:setFilter("nearest", "nearest")
    window_setup()
    load_sprites()
    init_game()
end

function love.update(dt)
    starfield.update() --always update stars

    if game_state == game_states.PLAYING then
        if Player ~= nil then
            Player:update()
        end

        --update bullets
        for i = #bullets, 1, -1 do
            local b = bullets[i]
            b:update()

            if b:is_offscreen() then
                -- remove from collision system
                if b.bbox then
                    hc.remove(b.bbox)
                    b.bbox = nil
                end
                table.remove(bullets, i)
            end
        end
        
        -- update asteroids
        for i = #asteroids, 1, -1 do
            local a = asteroids[i]
            a:update()

            if a.flag_for_deletion then
                table.remove(asteroids, i)
            end
        end

        -- update particles
        for i = #particles, 1, -1 do
            local p = particles[i]
            p:update()
            
            if p.flag_for_deletion then
                table.remove(particles, i)
            end
        end

        utils.check_all_collisions()
        
        -- check if all asteroids are destroyed
        if #asteroids == 0 and Player:is_alive() then
            spawn_new_wave()
        end

    elseif game_state == game_states.GAME_OVER then
        
        if love.keyboard.isDown('r') then
            init_game()
        end

        -- still update particles for visual effects
        for i = #particles, 1, -1 do
            local p = particles[i]
            p:update()
            
            if p.flag_for_deletion then
                table.remove(particles, i)
            end
        end
    end
end

function spawn_new_wave()
    local num_asteroids = math.min(5, 3 + math.floor(score / 500))
    
    -- spawn at edges of screen
    for i = 1, num_asteroids do
        local x, y
        local side = math.random(1, 4)
        if side == 1 then -- top
            x = math.random(0, screen_width)
            y = -10
        elseif side == 2 then -- right
            x = screen_width + 10
            y = math.random(0, screen_height)
        elseif side == 3 then -- bottom
            x = math.random(0, screen_width)
            y = screen_height + 10
        else -- left
            x = -10
            y = math.random(0, screen_height)
        end
        
        spawn_asteroid(x, y, asteroid.sizes.LARGE)
    end
end

function love.draw()
    love.graphics.setFont(font)
    local win_w, win_h = love.graphics.getDimensions()
    local scale_x = win_w / screen_width
    local scale_y = win_h / screen_height

    -- uniform scaling (preserves aspect ratio, no stretching)
    local scale = math.min(scale_x, scale_y)

    --start drawing
    love.graphics.push()
    love.graphics.scale(scale, scale)

    -- center the game world in the window
    local offset_x = (win_w/scale - screen_width) / 2
    local offset_y = (win_h/scale - screen_height) / 2
    love.graphics.translate(offset_x, offset_y)

    --now draw the world :)
    starfield.draw() --always draw stars

    if game_state == game_states.PLAYING then
        draw_playing_state()
    elseif game_state == game_states.GAME_OVER then
        draw_game_over_state()
    end

    --stop drawing
    love.graphics.pop()
end

function draw_playing_state()
    -- draw particles
    for i = #particles, 1, -1 do
        local p = particles[i]
        p:draw()
    end

    if Player then
        Player:draw()
    end

    -- draw bullets
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b:draw()
    end

    for i = #asteroids, 1, -1 do
        local a = asteroids[i]
        a:draw()
    end

    draw_player_data()
end

function draw_game_over_state()
    for i = #particles, 1, -1 do
        local p = particles[i]
        p:draw()
    end
    
    -- draw remaining asteroids
    for i = #asteroids, 1, -1 do
        local a = asteroids[i]
        a:draw()
    end
    
    -- draw game over screen
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

    local game_over_text = "GAME OVER"
    local text_width = love.graphics.getFont():getWidth(game_over_text)
    love.graphics.print(game_over_text, (screen_width - text_width) / 2, screen_height / 2 - 20)
    
    local final_score_text = "FINAL SCORE: " .. score
    local score_width = love.graphics.getFont():getWidth(final_score_text)
    love.graphics.print(final_score_text, (screen_width - score_width) / 2, screen_height / 2)
    
    if score == high_score and high_score > 0 then
        love.graphics.setColor(utils.colors.YELLOW[1], utils.colors.YELLOW[2], utils.colors.YELLOW[3], 1.0)
        local new_high_text = "NEW HIGH SCORE!"
        local high_width = love.graphics.getFont():getWidth(new_high_text)
        love.graphics.print(new_high_text, (screen_width - high_width) / 2, screen_height / 2 + 10)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    elseif high_score > 0 then
        local high_score_text = "HIGH SCORE: " .. high_score
        local high_width = love.graphics.getFont():getWidth(high_score_text)
        love.graphics.print(high_score_text, (screen_width - high_width) / 2, screen_height / 2 + 10)
    end
    
    local restart_text = "PRESS R TO RESTART"
    local restart_width = love.graphics.getFont():getWidth(restart_text)
    love.graphics.print(restart_text, (screen_width - restart_width) / 2, screen_height / 2 + 30)
end

function draw_player_data()
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    love.graphics.print("LIVES: " .. math.max(0, lives), 10, 10)
    love.graphics.print("SCORE: " .. score, 10, 20)

    if high_score > 0 then
        love.graphics.print("HIGH: " .. high_score, 10, 30)
    end
end

--helper callback functions
function spawn_asteroid(x, y, size, parent_vx, parent_vy)
    local a = asteroid.new_asteroid(x, y, size, parent_vx, parent_vy)
    a:init()
    
    a.on.destroy = function(self)
        score = score + self.points
        
        create_explosion(self.x, self.y)

        --spawn smaller asteroids, passing parent velocity
        if self.size == asteroid.sizes.LARGE then
            spawn_asteroid(self.x + 10, self.y, asteroid.sizes.MEDIUM, self.vx, self.vy)
            spawn_asteroid(self.x - 10, self.y, asteroid.sizes.MEDIUM, self.vx, self.vy)
        elseif self.size == asteroid.sizes.MEDIUM then
            spawn_asteroid(self.x + 5, self.y, asteroid.sizes.SMALL, self.vx, self.vy)
            spawn_asteroid(self.x - 5, self.y, asteroid.sizes.SMALL, self.vx, self.vy)
        end
        --small asteroids don't spawn anything
    end

    table.insert(asteroids, a)
end

function create_particle(x, y, scale, move)
    local p = particle.new_particle(x, y, scale, move)
    p:init()
    table.insert(particles, p)
end

function create_explosion(x,y)
    local scale = (2.5 + math.random())
    for i = 1, 16, 1 do
        create_particle(x, y, scale, true)
    end
end