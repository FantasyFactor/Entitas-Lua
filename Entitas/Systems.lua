require("Core/Class")

local ReactiveSystem = require("Entitas/ReactiveSystem")

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
    
    if system.Initialize ~= nil and type(system.Initialize) == "function" then
        table.insert(self.m_InitializeSystems, system)
    end

    if system.Execute ~= nil and type(system.Execute) == "function" then
        table.insert(self.m_ExecuteSystems, system)
    end

    if system.Cleanup ~= nil and type(system.Cleanup) == "function" then
        table.insert(self.m_CleanupSystems, system)
    end

    if system.TearDown ~= nil and type(system.TearDown) == "function" then
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
    
    if system.Initialize ~= nil and type(system.Initialize) == "function" then
        RemoveElement(self.m_InitializeSystems, system)
    end

    if system.Execute ~= nil and type(system.Execute) == "function" then
        RemoveElement(self.m_ExecuteSystems, system)
    end

    if system.Cleanup ~= nil and type(system.Cleanup) == "function" then
        RemoveElement(self.m_CleanupSystems, system)
    end

    if system.TearDown ~= nil and type(system.TearDown) == "function" then
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

function Systems:ActivateReactiveSystems()
    for i, system in ipairs(self.m_ExecuteSystems) do
        if system.IsAssignableFrom(ReactiveSystem) then
            system:Activate()
        end

        -- nestedSystems
        if system.IsAssignableFrom(Systems) then
            system:ActivateReactiveSystems()
        end
    end
end

function Systems:DeactivateReactiveSystems()
    for i, system in ipairs(self.m_ExecuteSystems) do
        if system.IsAssignableFrom(ReactiveSystem) then
            system:Deactivate()
        end

        -- nestedSystems
        if system.IsAssignableFrom(Systems) then
            system:DeactivateReactiveSystems()
        end
    end
end

function Systems:ClearReactiveSystems()
    for i, system in ipairs(self.m_ExecuteSystems) do
        if system.IsAssignableFrom(ReactiveSystem) then
            system:Clear()
        end

        -- nestedSystems
        if system.IsAssignableFrom(Systems) then
            system:ClearReactiveSystems()
        end
    end
end

return Systems