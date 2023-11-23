local Delegate = {}

local DelegateImplementation = {}

local function Invoke(self, ...)
    for i = 1, self.m_Count, 1 do
        self.m_InvokeList[i](...)
    end
end

local function AddDelegate(self, ...)
    for _, v in pairs({...}) do
        if type(v) == "function" then
            table.insert(self.m_InvokeList, v)
            self.m_Count = self.m_Count + 1
        else
            error(string.format("Can't add not function type:%s", type(v))) 
        end
    end
end

local function RemoveDelegate(self, ...)
    for _, v in pairs({...}) do
        if type(v) == "function" then
            for i = 1, self.m_Count, 1 do
                if self.m_InvokeList[i] == v then
                    table.remove(self.m_InvokeList, i)
                    self.m_Count = self.m_Count - 1
                    break
                end
            end
        else
            error(string.format("Can't add not function type:%s", type(v))) 
        end
    end
end

setmetatable(Delegate, {
    __call = function(self, ...)
        local delegate = {m_InvokeList = {}, m_Count = 0}
        setmetatable(delegate, DelegateImplementation)
        --print(delegate)
        delegate:AddDelegate(...)
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
DelegateImplementation.Invoke = Invoke

return Delegate