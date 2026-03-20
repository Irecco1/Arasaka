--[[
client -> server:
message = {
    type = "loginRequest",
    login = "nickname",
    password = "password",
}

server -> client:
message = {
    type = "loginResponse",
    result = true or false,
    reason = "invalidId" or "Reason" or nil
}
invalidId is when a player tries to login from a different device than last time.
]]