--[[
client -> server
message = {
    type = "startRequest",
    data = {
        login = "Irecco"
        
    }

}



]]




local db = require("data.db")

return function(message, senderId)
    print("Start request. Id: ", senderId, "login: ", message.data.login)
    return {
        type = "startResponse"
    }
end