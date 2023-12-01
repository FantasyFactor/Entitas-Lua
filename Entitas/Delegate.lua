local Delegate = {}

local DelegateImplementation = {}

local function Invoke(self, ...)
    for i = 1, self.m_Count, 1 do
        local value = self.m_InvokeList[i]
        if value ~= nil and value.callback ~= nil then
            value.callback(value.target, ...)
        end
    end
end

local function AddDelegate(self, target, ...)
    local n = select("#", ...)
    for i = 1, n, 1 do
        local callback = select(i, ...)
        if type(callback) == "function" then
            local value = {target = target, callback = callback}
            table.insert(self.m_InvokeList, value)
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
                local value = self.m_InvokeList[j]
                if value.target == target and value.callback == callback then
                    table.remove(self.m_InvokeList, j)
                    self.m_Count = self.m_Count - 1
                    break
                end
            end
        else
            error(string.format("Can't add not function type:%s", type(callback))) 
        end
    end
end

local function GetCount(self)
    return self.m_Count
end

setmetatable(Delegate, {
    __call = function()
        local delegate = {m_InvokeList = {}, m_Count = 0}
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
DelegateImplementation.GetCount = GetCount
DelegateImplementation.Invoke = Invoke

return Delegate