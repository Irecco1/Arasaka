local gui = {}


local function get_string_size(str)
    local max_width = 0
    local rows = 0

    for line in (str.."\n"):gmatch("(.-)\n") do
        rows = rows + 1
        if #line > max_width then
            max_width = #line
        end
    end

    return max_width, rows
end

function gui.draw_character(x, y, character, text_color, background_color, invert)
    -- to automatically draw a specyfic box building character

    text_color = text_color or colors.white
    background_color = background_color or colors.black

    -- shuold the colors be inverted
    invert = invert or false
    if invert then
        text_color, background_color = background_color, text_color
    end

    term.setCursorPos(x, y)
    term.setTextColor(text_color)
    term.setBackgroundColor(background_color)
    write(character)
    term.setCursorPos(1,1)
end

local box = {}

-- in the templates file are the symbols that are here. I can't use them directly,
-- as they are a custom CC: Tweaked symbols
function box.top_left_corner(x, y, border_color, background_color)
    gui.draw_character(x, y, "\x97", border_color, background_color, false)
end

function box.top_right_corner(x, y, border_color, background_color)
    gui.draw_character(x, y, "\x94", border_color, background_color, true)
end

function box.bottom_left_corner(x, y, border_color, background_color)
    gui.draw_character(x, y, "\x8a", border_color, background_color, true)
end

function box.bottom_right_corner(x, y, border_color, background_color)
    gui.draw_character(x, y, "\x85", border_color, background_color, true)
end

function box.left(x, y, border_color, background_color)
    gui.draw_character(x, y, "\x95", border_color, background_color, false)
end

function box.right(x, y, border_color, background_color)
    gui.draw_character(x, y, "\x95", border_color, background_color, true)
end

function box.top(x, y, border_color, background_color)
    gui.draw_character(x, y, "\x83", border_color, background_color, false)
end

function box.middle(x, y, border_color, background_color)
    gui.draw_character(x, y, "\x8c", border_color, background_color, false)
end

function box.bottom(x, y, border_color, background_color)
    gui.draw_character(x, y, "\x8f", border_color, background_color, true)
end

function box.right_cross(x, y, border_color, background_color)
    gui.draw_character(x, y, "\x9d", border_color, background_color, false)
end

function box.left_cross(x, y, border_color, background_color)
    gui.draw_character(x, y, "\x91", border_color, background_color, true)
end

function gui.draw_box(data)
    return gui.draw_box_raw(data.x1, data.y1, data.x2, data.y2, data.text, data.stretch, data.border_color, data.background_color, data.text_color)
end

function gui.draw_box_raw(x1, y1, x2, y2, text, stretch, border_color, background_color, text_color)
    -- if not specified, set the colors to standard black and white
    border_color = border_color or colors.white
    background_color = background_color or colors.black
    text_color = text_color or colors.white
    x2 = x2 or x1
    y2 = y2 or y1

    if stretch and text then
        local width, height = get_string_size(text)

        -- check if text width is > than space inside, and if so, move x1 and x2
        local distance_between_x = math.floor(x2-x1-1)
        if distance_between_x < width then
            local width_difference = width - distance_between_x
            x2 = x2+width_difference
        end

        -- check if text height is > than space inside, and if so, move y1 and y2
        local distance_between_y = math.floor(y2-y1-1)
        if distance_between_y < height then
            local height_difference = height - distance_between_y
            y2 = y2+height_difference
        end
    end

    -- preapre background
    paintutils.drawFilledBox(x1, y1, x2, y2, background_color)

    -- create corenrs of the box
    box.top_left_corner(x1, y1, border_color, background_color)
    box.top_right_corner(x2, y1, border_color, background_color)
    box.bottom_left_corner(x1, y2, border_color, background_color)
    box.bottom_right_corner(x2, y2, border_color, background_color)

    -- create top and bottom lines
    for x=x1+1, x2-1 do
        box.top(x, y1, border_color, background_color)
        box.bottom(x, y2, border_color, background_color)
    end

    -- create left and right lines
    for y=y1+1, y2-1 do
        box.left(x1, y, border_color, background_color)
        box.right(x2, y, border_color, background_color)
    end

    -- write text inside. If there is no stretch, it will don't care about going out of borders
    if text then
        local _, height = get_string_size(text)

        local middle_x = math.floor(x1+(x2-x1)/2)
        local middle_y = math.floor(y1+(y2-y1)/2)

        local start_y = middle_y-math.floor(height/2)

        local y = start_y
        for line in (text.."\n"):gmatch("(.-)\n") do
            local line_x = math.floor(middle_x-(#line/2))
        
            term.setCursorPos(line_x+1, y)
            term.setTextColor(text_color)
            term.setBackgroundColor(background_color)
            term.write(line)

            y = y + 1
        end
    end

    return x1, x2, y1, y2
end

function gui.draw_background(image_name, background_color, y_offset)
    local screen_width = 26
    local screen_height = 20
    y_offset = y_offset or 0  -- jeśli nie podano, ustaw na 0

    if not image_name then
        term.setBackgroundColor(background_color or colors.black)
        term.clear()
        term.setCursorPos(1,1)
        return
    end

    local ok, image = pcall(require, "assets."..image_name)
    if not ok then
        term.setBackgroundColor(background_color or colors.black)
        term.clear()
        term.setCursorPos(1,1)
        return
    end

    for y=1,screen_height do
        local row_index = y - y_offset
        local row = image[row_index] or {}  -- <- bezpiecznie: jeśli nil, użyj pustej tabeli
        for x=1,screen_width do
            local cell = row[x] or {char=" ", fg=colors.white, bg=background_color or colors.black}
            term.setCursorPos(x, y)
            term.setTextColor(cell.fg)
            term.setBackgroundColor(cell.bg)
            term.write(cell.char)
        end
    end

    term.setCursorPos(1,1)
end


function gui.button_handler(mouse_pos, button_area)
    return
        mouse_pos.x >= button_area.x1 and
        mouse_pos.x <= button_area.x2 and
        mouse_pos.y >= button_area.y1 and
        mouse_pos.y <= button_area.y2
end

return gui