require("Core/Class")
require("Core/Stack")

local Pools = Class("Pools")


function Pools:Ctor()
    self.m_Stacks = {}
end

function Pools:Push(key, value)
    local stack = self.m_Stacks[key] 
    if stack == nil then
        stack = Stack()
        self.m_Stacks[key] = stack
    end

    stack:Push(value)
end

function Pools:Pop(key)
    local stack = self.m_Stacks[key] 
    if stack == nil then
        stack = Stack()
        self.m_Stacks[key] = stack
    end

    if stack:Count() > 0 then
        return stack:Pop()
    end
    
    return nil
end

function Pools:Clear()
    self.m_Stacks = nil
end

return Pools