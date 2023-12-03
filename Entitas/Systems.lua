require("Core/Class")

local Systems = Class("Systems")

function Systems:Ctor()
    self.m_InitializeSystems = {}
    self.m_ExecuteSystems = {}
    self.m_CleanupSystems = {}
    self.m_TearDownSystems = {}
end

function Systems:Add(system)
    if system == nil then
        return self
    end
    
    if system.Initialize ~= nil and type(system.Initialize) == "Function" then
        table.insert(self.m_InitializeSystems, system)
    end

    if system.Execute ~= nil and type(system.Execute) == "Function" then
        table.insert(self.m_ExecuteSystems, system)
    end

    if system.Cleanup ~= nil and type(system.Cleanup) == "Function" then
        table.insert(self.m_CleanupSystems, system)
    end

    if system.TearDown ~= nil and type(system.TearDown) == "Function" then
        table.insert(self.m_TearDownSystems, system)
    end

    return self
end

local function RemoveElement(t, value)
    local index = nil

    for i, v in ipairs(t) do
        if v == value then
            index = i
            break
        end
    end

    if index ~= nil then
        table.remove(t, index)
    end
end

function Systems:Remove(system)
    if system == nil then
        return
    end
    
    if system.Initialize ~= nil and type(system.Initialize) == "Function" then
        RemoveElement(self.m_InitializeSystems, system)
    end

    if system.Execute ~= nil and type(system.Execute) == "Function" then
        RemoveElement(self.m_ExecuteSystems, system)
    end

    if system.Cleanup ~= nil and type(system.Cleanup) == "Function" then
        RemoveElement(self.m_CleanupSystems, system)
    end

    if system.TearDown ~= nil and type(system.TearDown) == "Function" then
        RemoveElement(self.m_TearDownSystems, system)
    end
end

function Systems:Initialize()
    for i, system in ipairs(self.m_InitializeSystems) do
        system:Initialize()
    end
end

function Systems:Execute()
    for i, system in ipairs(self.m_ExecuteSystems) do
        system:Execute()
    end
end

function Systems:Cleanup()
    for i, system in ipairs(self.m_CleanupSystems) do
        system:Cleanup()
    end
end

function Systems:TearDown()
    for i, system in ipairs(self.m_TearDownSystems) do
        system:TearDown()
    end
end

-- function Systems:ActivateReactiveSystems()
    
-- end

-- function Systems:DeactivateReactiveSystems()
    
-- end

-- function Systems:ClearReactiveSystems()
    
-- end