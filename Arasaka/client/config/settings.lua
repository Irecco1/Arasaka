local settings = {}

local path = "config/settings.json"
local data = {}

function settings.get()
    if fs.exists(path) then
        local file = fs.open(path, "r")
        data = textutils.unserializeJSON(file.readAll()) or {}
        file.close()
    else
        data = {
            login = "",
            auto_login = false, 
        }
    end
    return data
end

function settings.save(new_data)
    local file = fs.open(path, "w")
    file.write(textutils.serializeJSON(new_data))
    file.close()
end

return settings