local db = {}

local path = "data/db.json"
local data = {}

function db.load()
    if fs.exists(path) then
        local file = fs.open(path, "r")
        data = textutils.unserializeJSON(file.readAll()) or {}
        file.close()
    else
        data = {}
    end
    return data
end

function db.save(new_data)
    local file = fs.open(path, "w")
    file.write(textutils.serializeJSON(new_data))
    file.close()
end

return db