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

local sprite_path = "assets/sprites/"

function utils.load_sprite(sprite_name)
    --concatenation is with ..
    return love.graphics.newImage(sprite_path .. sprite_name .. ".png")
end

function utils.screen_wrap(object)
    local half_sw = object.sprite.getWidth(object.sprite) / 2
    local half_sh = object.sprite.getHeight(object.sprite) / 2

    if object.x + half_sw < 0 then
        object.x = screen_width + half_sw
    elseif object.x - half_sw > screen_width then
        object.x = -half_sw
    end

    if object.y + half_sh < 0 then
        object.y = screen_height + half_sh
    elseif object.y - half_sh > screen_height then
        object.y = -half_sh
    end
end

return utils
