local api = {}

local handlers = {
    keyVerifyRequest = require("handlers.keyVerifyRequest"),
    startRequest = require("handlers.startRequest")
    
    
}

function api.handle(message, senderId)
    local handler = handlers[message.type]

    if handler then
        return handler(message, senderId)
    else
        return {error = "Nieznany typ wiadomości: " .. tostring(message.type)}
    end
end

return api