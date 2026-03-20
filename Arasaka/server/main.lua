return function()
    -- Wrap modem peripheral on render API
    peripheral.find("modem", rednet.open)

    -- Get API to manage messages using their types
    local api = require("handlers.api")

    while true do
        local senderId, message = rednet.receive()

        local ok, response = pcall(api.handle, message, senderId)

        if not ok then
            print("Handler error:", response)
        elseif response then
            rednet.send(senderId, response, response.type)
        end
    end
end