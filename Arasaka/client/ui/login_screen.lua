--require important files
local hash = require("hash")
local gui = require("gui")
local settings = require("config.settings")

-- colors for boxes
local POPUP_BOX = {
    border_color = colors.red,
    background_color = colors.black,
    text_color = colors.white,
}

local POPUP_INFO = {
    border_color = colors.white,
    background_color = colors.lightBlue,
    text_color = colors.black,
}

local INPUT_FIELD = {
    border_color = colors.red,
    background_color = colors.lightGray,
    text_color = colors.black,
}

local X_BUTTON = {
    border_color = colors.red,
    background_color = colors.yellow,
    text_color = colors.black,
}

local CONFIRM_BUTTON = {
    border_color = colors.red,
    background_color = colors.green,
    text_color = colors.black,
}

-- ===========================
-- BUTTONS VARIABLES
-- ===========================

local login_box = {
        x1 = 4,
        y1 = 5,
        y2 = 19,
        x2 = 23,
    }

local function btn_start_var_get()
    return {
        x1 = 10,
        y1 = 14,
        x2 = 17,
        y2 = 16,
        text = "Start!",
        stretch = true,
        border_color = colors.red,
        background_color = colors.black,
        text_color = colors.white,
    }
end

local function btn_login_field_var_get()
    return {
        x1 = login_box.x1+1,
        y1 = login_box.y1+3,
        x2 = login_box.x2-1,
        y2 = login_box.y1+5,
        text = "",
        stretch = false,
        border_color = INPUT_FIELD.border_color,
        background_color = INPUT_FIELD.background_color,
        text_color = INPUT_FIELD.text_color,
    }
end

local function btn_X_var_get()
    return {
        x1 = login_box.x2-2,
        y1 = login_box.y1,
        x2 = login_box.x2,
        y2 = login_box.y1+2,
        text = "X",
        stretch = false,
        border_color = X_BUTTON.border_color,
        background_color = X_BUTTON.background_color,
        text_color = X_BUTTON.text_color,
    }
end

local function btn_get_code_var_get(text)
    return {
        x1 = login_box.x2 - #text -1,
        y1 = login_box.y2 - 2,
        x2 = login_box.x2,
        y2 = login_box.y2,
        text = text,
        stretch = false,
        border_color = CONFIRM_BUTTON.border_color,
        background_color = CONFIRM_BUTTON.background_color,
        text_color = CONFIRM_BUTTON.text_color,
    }
end

local function btn_code_var_get()
    return {
        x1 = login_box.x1 + 1,
        y1 = login_box.y1 + 8,
        x2 = login_box.x2 - 1,
        y2 = login_box.y1 + 10,
        text = "",
        stretch = false,
        border_color = INPUT_FIELD.border_color,
        background_color = INPUT_FIELD.background_color,
        text_color = INPUT_FIELD.text_color,
    }
end





-- local functions
local function get_mouse_input()
    local mouse_pos = {}
    local _, button, x, y = os.pullEvent("mouse_click")
    mouse_pos.x = x
    mouse_pos.y = y
    mouse_pos.button = button
    return mouse_pos
end

local function verify_key(login)
    local timeout = 2

    -- read saved key and send signed message to server
    local key = hash.readKey()
    local message = {
        type="keyVerifyRequest",
        data={
            login=login,
            }
        }
    hash.sendSigned(SERVER_ID, message, key)
    
    ::rerty_listening::
    local senderId, msg, err = hash.receiveSigned(key, "keyVerifyResponse", timeout)
    if not senderId then
        -- timed out waiting for response. probably our code is wrong
        return false

    elseif err == "INVALID_SIGNATURE" or err == "OLD_MESSAGE" then
        -- recived error, go back to listening and shorten timout timer
        timeout = timeout - 0.1
        goto rerty_listening
    end

    -- if we are here, there must be no problems and we have actaully recived a correct response
    return true
end

local function get_new_key(login)
    rednet.send(SERVER_ID, {type="newKeyRequest", data={login=login} })
end

local function input_field(x, y)
    local input = ""
    term.setCursorPos(x, y)
    term.setCursorBlink(true)
    term.setBackgroundColor(INPUT_FIELD.background_color)
    term.setTextColor(INPUT_FIELD.text_color)
    input = read()
    term.setCursorBlink(false)
    return input
end

local function create_info(message)
    gui.draw_box_raw(1, 1, 1, 1, message, true, POPUP_INFO.border_color, POPUP_INFO.background_color, POPUP_INFO.text_color)
    sleep(3)
end


--[[ THE PLAN
1. We get a nice welcome screen
2. There is gonna be only one button "START" or some other shit
3. After pressing button, you get the option to write your nick
4. After that server sends you on chat a 16 number code you use to login
4.1 in settings of client you will have an option to keep loged in for future
4.2 otherwise, each time you try to log-in you will get a new code
4.3 in server's data there will be a need to keep 2 codes: temporary and confirmed.
it's to prevent code change if someone tries to use your nick 

addon: main menu should have a place to write nick and press start button
So that when you press start you already send to server startRequest, where later we check
if it was with or without a code


]]

return function()
    while true do
        -- local variables
        local btn_start = {}
        local mouse_pos = {}
        local login = LOGIN

        -- draw the background
        gui.draw_background("arasaka")
        

        -- draw start button
        local btn_start_var = btn_start_var_get()
        btn_start.x1, btn_start.x2, btn_start.y1, btn_start.y2 = gui.draw_box(btn_start_var)
        -- draw important legal notice
        gui.draw_character(1, 18, "By pressing start you\naccept all terms\nand conditions. Click here", colors.lightGray, colors.gray)

        -- gather user mouse input
        mouse_pos = get_mouse_input()

        -- create functionality for start button
        if gui.button_handler(mouse_pos, btn_start) then
            
            -- start was pressed, begin loging process.

            -- check if auto login is enabled. If so, send message to server to check, if code is correct
            local settings_data = settings.get()
            if settings_data.auto_login and verify_key(login) then
                -- congratulations! Key is correct so we auto login
                return
            end

        
            -- if there is no auto login or something went wrong, you have to write login and code manually
            -- first we need to get user's login
            
            -- lets create small window where you can type your nick
            -- it should have the functionality of closing it and confirming nick
            -- after sending nick, a code window will appear where you can paste your code


            ::redraw_login::
            -- creating popup box. first we draw background to get rid of start button
            gui.draw_background("arasaka")


            -- now we prepare the entire big popup window 
            gui.draw_box_raw(login_box.x1, login_box.y1, login_box.x2, login_box.y2, "", false, POPUP_BOX.border_color, POPUP_BOX.background_color, POPUP_BOX. text_color)
            gui.draw_character(login_box.x1+1, login_box.y1+2, "Login:", POPUP_BOX.text_color, POPUP_BOX.background_color)

            -- now we prepare the input field. it's position, colors and we save it's xs and ys for button functionality
            local btn_login_field = {}
            local btn_login_field_var = btn_login_field_var_get()
            btn_login_field.x1, btn_login_field.x2, btn_login_field.y1, btn_login_field.y2 = gui.draw_box(btn_login_field_var)
            
            -- now we prepare the X button to close menu and get code button to, you guessed it, crash the syst... I mean, to get the code
            local btn_X = {}
            local btn_X_var = btn_X_var_get()

            local btn_get_code = {}
            local btn_get_code_var = btn_get_code_var_get("Get key")

            btn_X.x1, btn_X.x2, btn_X.y1, btn_X.y2 = gui.draw_box(btn_X_var)
            btn_get_code.x1, btn_get_code.x2, btn_get_code.y1, btn_get_code.y2 = gui.draw_box(btn_get_code_var)
            
            -- prepare everything for code input
            local btn_code = {}
            local btn_code_var = btn_code_var_get()

            -- now we can start listening for inputs
            local code_window_active = false
            local confirm = false
            local key = ""
            while true do
                mouse_pos = get_mouse_input()

                -- take care of X button, it will quit to main menu
                if gui.button_handler(mouse_pos, btn_X) then
                    break
                
                -- take care of input field for login. It should allow you to start typing
                elseif gui.button_handler(mouse_pos, btn_login_field) then
                    login = input_field(login_box.x1+2, login_box.y1+4)

                -- get key button functionality. if Login empty, area denied, kill user (jkjk)
                elseif gui.button_handler(mouse_pos, btn_get_code) then
                    if not confirm then
                        if login == "" then
                            create_info("Login cannot be empty")
                            goto redraw_login
                        end

                        -- send code on chat, it can be copied to clipboard
                        get_new_key(login)

                        -- draw box for code input and enable it
                        gui.draw_character(login_box.x1+1, login_box.y1 + 7, "Paste code here:", POPUP_BOX.text_color, POPUP_BOX.background_color)
                        btn_code.x1, btn_code.x2, btn_code.y1, btn_code.y2 = gui.draw_box(btn_code_var)
                        confirm = true


                        -- draw over get key button with confirm text
                        local btn_confirm_var = btn_get_code_var_get("Confirm")
                        gui.draw_box(btn_confirm_var)

                    elseif confirm then
                        -- we come here, when the code was already sent and the same position
                        -- as the get_code button was pressed (it should have different text now)
                        -- so it's time to send a message to server to see, if key is correct
                        -- we alse make sure that code has proper lenght

                        hash.sendSigned(SERVER_ID, {type="startRequest", data={login=login}}, key)

                        local senderId, message, err = hash.handle_recivering(key, "startResponse", 2)

                        if not senderId then
                            -- there was a problem
                            create_info("Error:\n"..err)
                            break
                        end

                        -- if we are here, it means everything needs to be correct and we can actually start
                        CODE = key
                        LOGIN = login
                        
                        -- save login in settings
                        local data = settings.get()
                        data.login = login
                        settings.save(data)

                        -- save code
                        hash.writeKey(key)
                        return


                    else
                        create_info("Incorrect code")
                        goto redraw_login
                    end
                
                -- code field button has been pressed!  
                elseif confirm and gui.button_handler(mouse_pos, btn_code) then
                    -- read input
                    key = input_field(login_box.x1 + 2, login_box.y1 + 9)
                    -- save new key
                    hash.writeKey(key)
                end

            end
        elseif gui.button_handler(mouse_pos, {x1=23, x2=26, y1=20, y2=20}) then
            create_info("Please ask an\nadministrator for a link\nto terms and coditions")
        end
    end
end