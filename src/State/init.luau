local Event = require(script.Parent.Event)

local State = {}
State.__index = State

function State.new(data: table?)
    local self = setmetatable({
        Data = data or {},
        Observers = {}
    }, State)

    return self
end

function State:Sub(prefix: string)
    return setmetatable({
        Data = self.Data,
        Prefix = if self.Prefix then self.Prefix .. prefix .. "/" else prefix .. "/",
        Observers = self.Observers
    }, State)
end

function State:Increment(path: string, value: number?)
    return self:Set(path, (self:Get(path)) + (value or 1))
end

function State:Get(path: string)
    if path == nil then
        local dir = self.Data
        if self.Prefix then
            local indexes = string.split(self.Prefix, "/")
            while #indexes > 1 do
                dir = dir[table.remove(indexes, 1)]
            end
        end
        return dir
    end
    if self.Prefix then
        path = self.Prefix .. path
    end

    local indexes = string.split(path, "/")
    local dir = self.Data

    while #indexes > 1 do
        dir = dir[table.remove(indexes, 1)] or {}
    end

    return dir[indexes[1]]
end

function State:Set(path: string, value: any)
    if self.Prefix then
        path = self.Prefix .. path
    end

    local indexes = string.split(path, "/")
    local dir = self.Data

    while #indexes > 1 do
        dir = dir[table.remove(indexes, 1)]
        if dir == nil then
            error("Invalid state path: " .. path)
        end
    end

    dir[indexes[1]] = value

    if self.Observers[path] then
        self.Observers[path]:Fire(value)
    end

    return value
end

function State:Observe(path: string, callback)
    task.spawn(callback, self:Get(path))
    if self.Prefix then
        path = self.Prefix .. path
    end

    if not self.Observers[path] then
        self.Observers[path] = Event.new()
    end
    return self.Observers[path]:Connect(callback)
end

return State