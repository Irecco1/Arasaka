--[[
client -> server:
message = {
    type = "discoverServerRequest",
}

server -> client:
message = {
    type = "discoverServerResponse",
}
]]

-- if it answers to broadcast, it doesnt even have to send ID, it will be in the message from rednet
return function(message, senderId)
    print("recived request from", senderId)
    return {type = "discoverServerResponse"}
end