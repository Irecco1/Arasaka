local gui = require("gui")

local function get_events()
    local mouse_pos = {}
    local eventData
    local event

    eventData = {os.pullEvent()}
    event = eventData[1]
    mouse_pos = {x=eventData[3], y=eventData[4]}
    return eventData, event, mouse_pos
end

local function login_button()
    return gui.draw_box(2, 14, 12, 16, "Login", false, colors.red, colors.lightGray, colors.black)
end

local function register_button()
    return gui.draw_box(15, 14, 25, 16, "Register", false, colors.red, colors.lightGray, colors.black)    
end

return function()
    while true do
        ::screen_main::
        local mouse_pos = {}
        local btn_login = {}
        local btn_register = {}

        local eventData
        local event

        gui.draw_background("arasaka")
        btn_login.x1, btn_login.x2, btn_login.y1, btn_login.y2 = login_button()
        btn_register.x1, btn_register.x2, btn_register.y1, btn_register.y2 = register_button()

        eventData, event, mouse_pos = get_events()

        -- login button
        if event == "mouse_click" and gui.button_handler(mouse_pos, btn_login) then

            ::screen_login::

            --redraw the menu. It's in case someone goes back
            gui.draw_background("arasaka")

            -- a lot of code will be reused from register (it was created first).
            -- boxes will be the same, as well as many names, but it should be sending
            -- login instead of register requests and whats VERY IMPORTANT
            -- I have to add 2 factor verification, that if you try to login from a different
            -- device than last time, it should send again a new verification tokem

            -- additionally, all future operations (shop, casino, etc.), should NOT be
            -- possible, if deviceId of the client is different from the one that
            -- was used last time. It's to avoid someone creating his own program
            -- which will just send some requests with someone else's informations

            -- if senderId ~= nick.device_id then go fuck yourself, no cookie, bad hacker end
            


            -- if login complete and data saved, break out of the login_screen loop and go forward. To space! I mean- to main!
            break
        end

        --register button
        if event == "mouse_click" and gui.button_handler(mouse_pos, btn_register) then

            ::screen_register::

            --redraw the menu. It's in case someone goes back
            gui.draw_background("arasaka")
            -- variables to send to server
            local login
            local password

            -- create a window to input login and password


            --main box
            gui.draw_box(2, 3, 25, 19, "", false, colors.red, colors.lightGray)

            -- login field
            gui.draw_character(3, 4, "Login:", colors.black, colors.lightGray)
            local btn_login_field = {}
            btn_login_field.x1, btn_login_field.x2, btn_login_field.y1, btn_login_field.y2 = gui.draw_box(3, 5, 24, 7, "", false, colors.black, colors.white, colors.black)

            -- paswwrod field
            gui.draw_character(3, 8, "Password:", colors.black, colors.lightGray)
            local btn_passw_field = {}
            btn_passw_field.x1, btn_passw_field.x2, btn_passw_field.y1, btn_passw_field.y2 = gui.draw_box(3, 9, 24, 11, "", false, colors.black, colors.white, colors.black)

            -- continue button
            gui.draw_character(3, 12, "Continue...", colors.black, colors.green)

            -- X to go back
            gui.draw_character(25, 3, "X", colors.back, colors.orange)

            while true do
                -- loop to be able to press and edit user input

                eventData, event, mouse_pos = get_events()
                --gather input from user in login window
                if event == "mouse_click" and gui.button_handler(mouse_pos, btn_login_field) then
                    gui.draw_box(3, 5, 24, 7, "", false, colors.black, colors.white, colors.black)
                    login = ""
                    term.setTextColor(colors.black)
                    term.setBackgroundColor(colors.white)
                    term.setCursorPos(4, 6)
                    term.setCursorBlink(true)
                    login = read()
                    term.setCursorBlink(false)
                

                --gather input from user in password window
                elseif event == "mouse_click" and gui.button_handler(mouse_pos, btn_passw_field) then
                    gui.draw_box(3, 9, 24, 11, "", false, colors.black, colors.white, colors.black)
                    password = ""
                    term.setTextColor(colors.black)
                    term.setBackgroundColor(colors.white)
                    term.setCursorPos(4, 10)
                    term.setCursorBlink(true)
                    password = read()
                    term.setCursorBlink(false)
                
                elseif event == "mouse_click" and mouse_pos.x == 25 and mouse_pos.y == 3 then
                    goto screen_main
                
                -- if pressed continue, then continue
                elseif event == "mouse_click" and gui.button_handler(mouse_pos, {x1=3, x2=10, y1=12, y2=12}) then
                    break
                end
            end

            -- send a request to server with register data
            rednet.send(SERVER_ID, {type="registerRequest", login=login, password=password})
            
            ::again_register::
            local SenderId, message = rednet.receive("registerResponse", 3)
            
            if not SenderId then
                -- took to long to recive response from server. Go back to register input windows
                gui.draw_box(1, 1, 1, 1, "Server took\ntoo long!", true, colors.red, colors.white, colors.black)
                sleep(3)
                goto screen_register
            end

            if message.type == "registerResponse" and message.result then
                --data was correct, awaiting for the user to put verification code

                ::screen_verification::
                -- window for verification code
                gui.draw_box(2, 14, 25, 19, "", false, colors.red, colors.lightGray)
                gui.draw_character(3, 15, "Verification code:", colors.black, colors.lightGray)

                local btn_verif_field = {}
                local code
                btn_verif_field.x1, btn_verif_field.x2, btn_verif_field.y1, btn_verif_field.y2 = gui.draw_box(3, 16, 10, 18, "", false, colors.black, colors.white, colors.black)

                -- X to go back
                gui.draw_character(25, 14, "X", colors.black, colors.orange)

                while true do
                    eventData, event, mouse_pos = get_events()
                    if event == "mouse_click" and gui.button_handler(mouse_pos, btn_verif_field) then
                        code = 0
                        term.setTextColor(colors.black)
                        term.setBackgroundColor(colors.white)
                        term.setCursorPos(4, 17)
                        term.setCursorBlink(true)
                        code = tonumber(read())
                        term.setCursorBlink(false)
                        break
                    elseif event == "mouse_click" and mouse_pos.x == 25 and mouse_pos.y == 14 then
                        -- go back
                        goto screen_register
                    end
                end

                -- check if its only numbers
                if not code then
                    code = 0
                    -- it will automatically fail when compared with the server data
                end

                -- send a request to server with register code
                rednet.send(SERVER_ID, {type="registerVerificationRequest", login=login, code=code})

                ::again_verify::
                SenderId, message = rednet.receive("registerVerificationResponse", 3)

               if not SenderId then
                    -- took to long to recive response from server. Go back to register input windows
                    gui.draw_box(1, 1, 1, 1, "Server took\ntoo long!", true, colors.balck, colors.lightBlue, colors.black)
                    sleep(3)
                    goto screen_register
                end

                if message.type == "registerVerificationResponse" and message.result then
                    -- everything went correctly, user registered, restart screen
                    gui.draw_box(1, 1, 1, 1, "Registration complited", true, colors.balck, colors.lightBlue, colors.black)
                    sleep(3)
                    goto screen_main

                elseif message.type == "registerVerificationResponse" and not message.result then
                    -- code was incorrect. go back to register step
                    gui.draw_box(1, 1, 1, 1, "Code incorrect!", true, colors.balck, colors.lightBlue, colors.black)
                    sleep(3)
                    code = 0
                    goto screen_register
                    
                elseif message.type ~= "registerVerificationResponse" then
                    --got a different message, go back to listening
                    goto again_verify
                end

            elseif message.type == "registerResponse" and not message.result then
                --register didnt work, display why and go back to input window
                gui.draw_box(1, 1, 1, 1, message.reason, true, colors.balck, colors.lightBlue, colors.black)
                sleep(3)
                goto screen_register

            elseif message.type ~= "registerResponse" then
                --got a different message, go back to listening
                goto again_register
            end

        end


        ::continue::
    end
end