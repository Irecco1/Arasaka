--[[
client -> server:
message = {
    type = "registerRequest",
    login = "nickname",
    password = "password",
}

server -> client:
message = {
    type = "registerResponse",
    result = true or false,
    reason = "reason" or nil
}
]]

local db = require("data.db")

local function validateLogin(login)
    if login:match("%s") then
        return false, "Login cannot contain\nspace characters"
    end
        return true
end
local function validatePassword(password)
    if #password < 3 then
        return false, "Password is too short"
    elseif #password > 16 then
        return false, "Password is too long"
    elseif password:match("%s") then
        return false, "Password cannot contain\nspace characters"
    end
    return true
end


return function(message, senderId)
    -- load data
    local data = db.load()

    -- if nick exists and register was completed return false
    if data[message.login] and data[message.login].registered then
        return {
            type = "registerResponse",
            result = false,
            reason = "Nick is already in use",
        }
    end

    --[[ check if login is correct
    local ok, reason = validateLogin(message.login)
    if not ok then
        return {
            type = "registerResponse",
            result = false,
            reason = reason,
        }
    end]]
    -- check if password is correct
    local ok, reason = validatePassword(message.password)
    if not ok then
        return {
            type = "registerResponse",
            result = false,
            reason = reason,
        }
    end

    -- if nick doesnt exists, craete account and assign code to verificate using chat box. Until then user is not registered
    local code = math.random(100000, 999999)
    data[message.login] = {password=message.password, registered=false, code=code}
    db.save(data)

    -- wrap chatbox and send code to player
    local chat_box = peripheral.find("chat_box")
    chat_box.sendMessageToPlayer("Your verification code is: "..tostring(code), message.login)

    return {
        type = "registerResponse",
        result = true,
        reason = nil,
    }
end