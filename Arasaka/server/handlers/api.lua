local api = {}

local handlers = {
    discoverServerRequest = require("handlers.discoverServerRequest"),
    registerRequest = require("handlers.registerRequest"),
    registerVerificationRequest = require("handlers.registerVerificationRequest"),
    loginRequest = require("handlers.registerRequest"),
    loginVerificationRequest = require("handlers.registerVerificationRequest"),
    
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