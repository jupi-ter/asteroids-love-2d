--requires (modules are lowercase)
local utils = require("src.utils")
local player = require("src.player")
local bullet = require("src.bullet")
local particle = require("src.particle")

--globals
width, height = 320, 240

function window_setup()
    --setup window
    love.window.setMode(width, height, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        minwidth = width,
        minheight = height
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
end

function love.load()
    window_setup()
    load_sprites()

    --objects
    Player = player.new_player(width/2,height/2)
    Player:init()
    
    --tables
    bullets = {}
    particles = {}
    
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
    Player:update(dt)

    --update bullets
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b:update(dt)

        if b:is_offscreen() then
            table.remove(bullets, i)
        end
    end

    --update particles
    for i = #particles, 1, -1 do
        local p = particles[i]
        p:update(dt)
        
        if p.flag_for_deletion then
            table.remove(particles, i)
        end
    end
end

function love.draw()
    local win_w, win_h = love.graphics.getDimensions()
    local scale_x = win_w / width
    local scale_y = win_h / height

    -- uniform scaling (preserves aspect ratio, no stretching)
    local scale = math.min(scale_x, scale_y)

    --start drawing
    love.graphics.push()
    love.graphics.scale(scale, scale)

    -- center the game world in the window
    local offset_x = (win_w/scale - width) / 2
    local offset_y = (win_h/scale - height) / 2
    love.graphics.translate(offset_x, offset_y)

    --now draw the world

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

    --stop drawing
    love.graphics.pop()
end