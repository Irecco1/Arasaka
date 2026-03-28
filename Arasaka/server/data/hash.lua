local db = require("data.db")

local hash = {}

local function get_code(msg)
    local data = db.load()
    local login = msg.data.login or ""
    if not data[login] then data[login] = {} end
    return data[login].code or 0
end

local function get_temporary_code(msg)
    local data = db.load()
    local login = msg.data.login
    return data[login].temp_code
end

-- basic hash function
function hash.simpleHash(str)
    local h = 0
    for i = 1, #str do
        h = (h * 31 + string.byte(str, i)) % 2^32
    end
    return h
end

-- message signature
function hash.signMessage(secret, messageTable)
    local timestamp = os.epoch("utc")
    local serialized = textutils.serialize(messageTable)
    local signature = hash.simpleHash(secret .. serialized .. timestamp)
    return timestamp, signature
end

-- send signed message
function hash.sendSigned(clientID, msg, secret)
    local timestamp, signature = hash.signMessage(secret, msg)
    msg._timestamp = timestamp
    msg._signature = signature
    rednet.send(clientID, msg, msg.type)
end

-- recives message and checks the signature
function hash.receiveSigned()
    local senderID, msg = rednet.receive()

    -- if someone sends request for new code, send it via chat no matter what
    if msg.type == "newKeyRequest" then
        local login = msg.data.login
        local chat_box = peripheral.find("chat_box")

        -- generate random key for player and sabe it in his daata temp_code
        local code = math.random(10000000000000, 99999999999999)
        local code_str = string.format("%.0f", code)
        local data = db.load()
        if not data[login] then data[login] = {} end
        data[login].temp_code = code
        db.save(data)

        local message = {
            {text = 'Click your code to copy it: '},
            {
                text = code_str,
                underlined = true,
                clickEvent = {
                    action = 'copy_to_clipboard',
                    value = code_str
                }
            }
        }
        local json = textutils.serialiseJSON(message)
        chat_box.sendFormattedMessageToPlayer(json, login)
        return senderID, nil, "KEY_REQUEST"
    end

    local secret = get_code(msg)
    local temp_secret = get_temporary_code(msg)

    local receivedSig = msg._signature
    local receivedTimestamp = msg._timestamp

    -- if message was sent over 2 seconds ago
    if receivedTimestamp > os.epoch("UTC") + 2000 then return senderID, nil, "OLD_MESSAGE" end

    -- if it's reply attack
    local data = db.load()
    local last_signature = data[msg.data.login].last_signature
    if receivedSig == last_signature then return senderID, nil, "REPLY_ATTACK" end

    -- copy message without temporary fields
    local msgCopy = {}
    for k,v in pairs(msg) do
        if k ~= "_signature" and k ~= "_timestamp" then
            msgCopy[k] = v
        end
    end

    local expectedSig = hash.simpleHash(secret .. textutils.serialize(msgCopy) .. receivedTimestamp)
    local expectedSigTemp = hash.simpleHash(temp_secret .. textutils.serialize(msgCopy) .. receivedTimestamp)
    
    if receivedSig ~= expectedSig and receivedSig ~= expectedSigTemp then
        return senderID, nil, "INVALID_SIGNATURE"
    end

    --save temporary signature as normal if it was correct
    if receivedSig == expectedSigTemp and receivedSig ~= expectedSig then
        local data = db.load()
        data[msg.data.login].code = temp_secret
        db.save(data)
        secret = temp_secret
    end

    -- save last signature for reply attacks
    local data = db.load()
    data[msg.data.login].last_signature = receivedSig
    db.save(data)

    return senderID, msg, nil, secret
end

return hash