local starfield = {}
local utils = require("src.utils")

-- Star colors (converted from PICO-8 palette to RGB)
-- Using darker, more subtle colors for background stars
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
    
    -- Create starfield with depth layers
    for i = 1, #star_colors do
        for j = 1, 10 do
            local s = {
                x = math.random() * screen_width,
                y = math.random() * screen_height,
                z = i,  -- depth layer (1-4, determines speed and size)
                c = star_colors[i],
                size = 1
            }
            table.insert(stars, s)
        end
    end
end

function starfield.update(dt)
    -- Move stars based on depth (horizontally to the right)
    for _, s in ipairs(stars) do
        -- Move star right, faster for closer stars (higher z)
        s.x = s.x + (s.z * warp_factor * dt) / 10
        
        -- Wrap star around screen (from right to left)
        if s.x > screen_width then
            s.x = 0
            s.y = math.random() * screen_height
        end
    end
end

function starfield.draw()
    -- Draw all stars as small rectangles (more visible than points)
    for _, s in ipairs(stars) do
        love.graphics.setColor(s.c[1], s.c[2], s.c[3], 1.0)
        -- Draw as rectangle for better visibility
        love.graphics.rectangle("fill", s.x, s.y, s.size, s.size)
    end
    
    -- Reset color
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
end

-- Optional: Change warp speed dynamically
function starfield.setWarpFactor(factor)
    warp_factor = factor
end

return starfield