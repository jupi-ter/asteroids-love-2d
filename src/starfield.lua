local starfield = {}
local utils = require("src.utils")

local star_colors = {
    utils.colors.DARKBLUE,  
    utils.colors.DARKGREY,  
    utils.colors.LIGHTGREY, 
    utils.colors.WHITE  
}

local warp_factor = 120
local stars = {}

function starfield.init()
    stars = {}
    
    -- create starfield with depth layers
    for i = 1, #star_colors do
        for j = 1, 10 do
            local s = {
                x = math.random() * screen_width,
                y = math.random() * screen_height,
                z = i,  -- depth layer (1-4, determines speed)
                c = star_colors[i],
                size = 1
            }
            table.insert(stars, s)
        end
    end
end

function starfield.update(dt)
    -- move stars horizontally based on depth
    for _, s in ipairs(stars) do
        -- move star right, faster for closer stars (higher z)
        s.x = s.x + (s.z * warp_factor * dt) / 10
        
        -- wrap star around screen
        if s.x > screen_width then
            s.x = 0
            s.y = math.random() * screen_height
        end
    end
end

function starfield.draw()
    -- draw all stars as small rectangles
    -- foreach: key, value. using _ as a throwaway variable since we don't care about the key.
    for _, s in ipairs(stars) do
        love.graphics.setColor(s.c[1], s.c[2], s.c[3], 1.0)
        love.graphics.rectangle("fill", s.x, s.y, s.size, s.size)
    end
    
    -- reset color
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
end

return starfield