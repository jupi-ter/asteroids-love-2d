--requires (modules are lowercase)
local utils = require("src.utils")
local player = require("src.player")
local bullet = require("src.bullet")
local particle = require("src.particle")
local asteroid = require("src.asteroid")

--globals
screen_width, screen_height = 128, 128
text = {}

function window_setup()
    --setup window
    love.window.setMode(screen_width, screen_height, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        minwidth = 512,
        minheight = 512
    })

    -- Optional: nicer scaling for pixel art
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Background color (RGB 0.0 - 1.0)
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
    window_setup()
    load_sprites()

    --objects
    Player = player.new_player(screen_width/2, screen_height/2)
    Player:init()
    
    --tables
    bullets = {}
    particles = {}
    asteroids = {}
    
    local a = asteroid.new_asteroid(0, 0, asteroid.sizes.LARGE)
    a:init()
    table.insert(asteroids, a)

    --callbacks (lambdas)
    Player.on.shoot = function(x, y, rot)
        local b = bullet.new_bullet(x, y, rot)
        table.insert(bullets, b)
    end

    -- add particle spawner callback
    Player.on.move = function(x, y, rot, xscale, yscale, color)
        local p = particle.new_particle(x, y, xscale, yscale, rot, color)
        p:init()
        table.insert(particles, p)
    end
end

function love.update(dt)
    if Player ~= nil then
        Player:update(dt)
    end

    --update bullets
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b:update(dt)

        if b:is_offscreen() then
            table.remove(bullets, i)
        end
    end
    
    --update asteroids
    for i = #asteroids, 1, -1 do
        local a = asteroids[i]
        a:update(dt)
    end

    --update particles
    for i = #particles, 1, -1 do
        local p = particles[i]
        p:update(dt)
        
        if p.flag_for_deletion then
            table.remove(particles, i)
        end
    end

    while #text > 40 do
        table.remove(text, 1)
    end
end

function love.draw()
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

    --now draw the world

    for i = 1,#text do
        love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
        love.graphics.print(text[#text - (i-1)], 10, i * 15)
    end

    --draw particles
    for i = #particles, 1, -1 do
        local p = particles[i]
        p:draw()
    end

    Player:draw()

    --draw bullets
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b:draw()
    end

    for i = #asteroids, 1, -1 do
        local a = asteroids[i]
        a:draw()
    end

    --stop drawing
    love.graphics.pop()
end