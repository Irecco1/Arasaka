--[[
client -> server:
message = {
    type = "loginVerificationRequest",
    login = "nickname",
    code = number,
}

server -> client:
message = {
    type = "loginVerificationResponse",
    result = true or false,
}
]]