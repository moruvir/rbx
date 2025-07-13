local Cleaner = {}
Cleaner.__index = Cleaner

local typeFunctions = {
    ["function"] = function (object)
        object()
    end,

    ["Instance"] = function (object)
        object:Destroy()
    end,

    ["thread"] = function (object)
        task.cancel(object)
    end,

    ["RBXScriptConnection"] = function (object)
        object:Disconnect()
    end,

    ["table"] = function (object)
        if object.Destroy then
            object:Destroy()
        end
    end
}

local function handleObject(object)
    local method = typeFunctions[typeof(object)]
    if not method then
        return
    end
    method(object)
end

function Cleaner.new()
    local self = setmetatable({}, Cleaner)
    self.Objects = {}
    return self
end

function Cleaner:Clone(object)
    return self:Add(object:Clone())
end

function Cleaner:Connect(event, callback)
    return self:Add(event:Connect(callback))
end

function Cleaner:Add(object)
    self.Objects[object] = true
    return object
end

function Cleaner:Destroy()
    local objects = self.Objects
    self.Objects = {}
    for object, _ in objects do
        task.spawn(handleObject, object)
    end
end

return Cleaner