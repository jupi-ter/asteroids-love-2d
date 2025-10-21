local utils = {}

utils.colors = {
    BLACK = {0.0, 0.0, 0.0},
    DARKBLUE = {0.114, 0.169, 0.325},
    DARKPURPLE = {0.494, 0.145, 0.325},
    DARKGREEN = {0.0, 0.529, 0.318},
    BROWN = {0.671, 0.322, 0.212},
    DARKGREY = {0.373, 0.341, 0.31},
    LIGHTGREY = {0.761, 0.765, 0.78},
    WHITE = {1.0, 0.945, 0.91},
    RED = {1.0, 0.0, 0.302},
    ORANGE = {1.0, 0.639, 0.0},
    YELLOW = {1.0, 0.925, 0.153},
    GREEN = {0.0, 0.894, 0.212},
    BLUE = {0.161, 0.678, 1.0},
    LAVENDER = {0.514, 0.463, 0.612},
    PINK = {1.0, 0.467, 0.659},
    LIGHTPEACH = {1.0, 0.8, 0.667}
}

function utils.draw_sprite(sprite, x, y, rotation, image_xscale, image_yscale, draw_from_origin)
    if sprite ~= nil then
        if draw_from_origin then
            love.graphics.draw(sprite, x, y, rotation, image_xscale, image_yscale, sprite.getWidth(sprite) / 2, sprite.getHeight(sprite) / 2)
        else
            love.graphics.draw(sprite, x, y, rotation, image_xscale, image_yscale, 0, 0)
        end
    end
end

function utils.lengthdir_x(len, dir)
    return len * math.cos(dir * math.pi / -180)
end

function utils.lengthdir_y(len, dir)
    return len * math.sin(dir * math.pi / -180)
end

local sprite_path = "assets/sprites/"

function utils.load_sprite(sprite_name)
    --concatenation is with ..
    return love.graphics.newImage(sprite_path .. sprite_name .. ".png")
end

return utils
