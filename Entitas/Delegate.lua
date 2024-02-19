local Delegate = {}

local DelegateImplementation = {}

local function Invoke(self, ...)
    for i = 1, self.m_Count, 1 do
        local target = self.m_Targets[i]
        local callback = self.m_Callbacks[i]
        if callback ~= nil then
            callback(target, ...)
        end
    end
end

local function AddDelegate(self, target, ...)
    local n = select("#", ...)
    for i = 1, n, 1 do
        local callback = select(i, ...)
        if type(callback) == "function" then
            table.insert(self.m_Targets, target)
            table.insert(self.m_Callbacks, callback)
            self.m_Count = self.m_Count + 1
        else
            error(string.format("Can't add not function type:%s", type(callback))) 
        end
    end
end

local function RemoveDelegate(self, target, ...)
    local n = select("#", ...)
    for i = 1, n, 1 do
        local callback = select(i, ...)
        if type(callback) == "function" then
            for j = 1, self.m_Count, 1 do
                local currentTarget = self.m_Targets[j]
                local currentCallback = self.m_Callbacks[j]
                if currentTarget == target and currentCallback == callback then
                    table.remove(self.m_Targets, j)
                    table.remove(self.m_Callbacks, j)
                    self.m_Count = self.m_Count - 1
                    break
                end
            end
        else
            error(string.format("Can't add not function type:%s", type(callback))) 
        end
    end
end

local function RemoveAllDelegate(self)
    self.m_Targets = {}
    self.m_Callbacks = {}
    self.m_Count = 0
end

local function GetCount(self)
    return self.m_Count
end

setmetatable(Delegate, {
    __call = function()
        local delegate = {m_Targets = {}, m_Callbacks = {}, m_Count = 0}
        setmetatable(delegate, DelegateImplementation)
        return delegate
    end
})

DelegateImplementation.__index = function(t, k)
    return DelegateImplementation[k]
end

DelegateImplementation.__newindex = function(t, k, value)
    error("Can't set field by Delegate") 
end

DelegateImplementation.__call = Invoke
DelegateImplementation.AddDelegate = AddDelegate
DelegateImplementation.RemoveDelegate = RemoveDelegate
DelegateImplementation.RemoveAllDelegate = RemoveAllDelegate
DelegateImplementation.GetCount = GetCount
DelegateImplementation.Invoke = Invoke

return Delegate