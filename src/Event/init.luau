local HttpService = game:GetService("HttpService")
local Event = {}
Event.__index = Event

function Event.new()
    local self = setmetatable({
        Connections = {}
    }, Event)

    return self
end

function Event:SetResponse(callback)
    if self.Destroyed then return end
    self.Callback = callback
end

function Event:Fire(...)
    if self.Destroyed then return end
    for _, callback in self.Connections do
        task.spawn(callback, ...)
    end
    if self.Callback then
        task.spawn(self.Callback, ...)
    end
end

function Event:Invoke(...)
    if self.Destroyed then return end
    for _, callback in self.Connections do
        task.spawn(callback, ...)
    end
    if self.Callback then
        return self.Callback(...)
    end
end

function Event:Connect(callback)
    if self.Destroyed then return end
    local id = HttpService:GenerateGUID(false)
    self.Connections[id] = callback
    return {
        Destroy = function ()
            self.Connections[id] = nil
        end
    }
end

function Event:Destroy()
    self.Destroyed = true
    self.Connections = {}
    self.Callback = nil
end

return Event