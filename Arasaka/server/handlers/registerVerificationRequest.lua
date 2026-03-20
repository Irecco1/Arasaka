--[[
client -> server:
message = {
    type = "registerVerificationRequest",
    login = "nickname",
    code = number,
}

server -> client:
message = {
    type = "registerVerificationResponse",
    result = true or false,
}
]]
local db = require("data.db")

return function(message, senderId)
    local data = db.load()
    -- if code in data is the same as code in message, then its correct. update that user is registerd nad send response
    if data[message.login].code == message.code then
        data[message.login].registered = true
        data[message.login].last_device = senderId
        db.save(data)
        return {
        type = "registerVerificationResponse",
        result = true,
        }
    end

    -- if the code isn't the same, return false
    return {
        type = "registerVerificationResponse",
        result = false,
    }
end