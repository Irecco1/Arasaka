--[[
client -> server
message = {
    type = "keyVerifyRequest",
    data = {
        login="Steve"
        }
    }

server -> client
message = {
    type = "keyVerifyResponse", 
]]

return function(message, senderId)
    print("Key verify request. Id: ", senderId, "login: ", message.data.login)
    return {type="keyVerifyResponse"}
end