return function()
    -- Wrap modem peripheral on render API
    peripheral.find("modem", rednet.open)

    -- Get API to manage messages using their types
    local api = require("handlers.api")
    local hash = require("data.hash")

    while true do
        -- recives message and checks its hash comparing to user's code
        local senderId, message, err, key = hash.receiveSigned()
        if err then
            print("Sender id:", senderId, "error:", err)
            goto continue
        end

        -- if we go through, it means the message is safe and it was send from the user itself
        local ok, response = pcall(api.handle, message, senderId)

        if not ok then
            print("Handler error:", response)
        elseif response then
            hash.sendSigned(senderId, response, key)
        end
        ::continue::
    end
end