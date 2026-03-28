local hash = {}

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
function hash.sendSigned(serverID, msg, secret)
    local timestamp, signature = hash.signMessage(secret, msg)
    msg._timestamp = timestamp
    msg._signature = signature
    rednet.send(serverID, msg)
end

-- recives message and checks the signature
function hash.receiveSigned(secret, protocol, timeout)
    local senderID, msg = rednet.receive(protocol, timeout)

    -- no message in timeout time
    if not senderID then return nil, nil, "SERVER_NOT_RESPONDING" end

    local receivedSig = msg._signature
    local receivedTimestamp = msg._timestamp

    -- if message was sent over 2 seconds ago
    if receivedTimestamp > os.epoch("UTC") + 2000 then return senderID, nil, "OLD_MESSAGE" end

    -- copy message without temporary fields
    local msgCopy = {}
    for k,v in pairs(msg) do
        if k ~= "_signature" and k ~= "_timestamp" then
            msgCopy[k] = v
        end
    end

    local expectedSig = hash.simpleHash(secret .. textutils.serialize(msgCopy) .. receivedTimestamp)

    if receivedSig ~= expectedSig then
        return senderID, nil, "INVALID_SIGNATURE"
    end

    return senderID, msg
end

function hash.readKey()
    local path = "config/_key"

    if fs.exists(path) then
        local file = fs.open(path, "r")
        local data = file.readAll()
        file.close()
        return data
    else
        local file = fs.open(path, "w")
        file.close()
        return 0
    end
end

function hash.writeKey(key)
    local path = "config/_key"
    local file = fs.open(path, "w")
    file.write(key)
    file.close()
end

function hash.handle_recivering(secret, protocol, timeout)
    ::rerty_listening::
    local senderId, msg, err = hash.receiveSigned(secret, protocol, timeout)
    if not senderId then
        -- timed out waiting for response. probably our code is wrong
        return nil, nil, err

    elseif err == "INVALID_SIGNATURE" or err == "OLD_MESSAGE" then
        -- recived error, go back to listening and shorten timout timer
        timeout = timeout - 0.1
        goto rerty_listening
    end

    -- if we are here, there must be no problems and we have actaully recived a correct response
    return senderId, msg
end

return hash