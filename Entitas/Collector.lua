require("Core/Class")
require("Entitas/EntitasConst")

local Delegate = require("Entitas/Delegate")

local Collector = Class("Collector")

function Collector:Ctor(groups, groupEvents)
    self.m_Groups = groups
    self.m_GroupEvents = groupEvents
    self.m_CollectedEntities = {}
    self.m_Count = 0

    -- TODO Exception:#groups ~= #groupEvents
    self:Activate()
end

function Collector:Dtor()
    self:Deactivate()
end

local function AddEntityCache(self, group, entity, index, component)
    local has = self.m_CollectedEntities[entity]
    
    if not has then
        self.m_CollectedEntities[entity] = true
        self.m_Count = self.m_Count + 1
    end
end

function Collector:Activate()
    for i, v in ipairs(self.m_Groups) do
        local group = v
        local groupEvent = self.m_GroupEvents[i]

        --先卸载多余的注册，再监听
        if groupEvent == GroupEvent.Added then
            group.onEntityAdded:RemoveDelegate(self, AddEntityCache)
            group.onEntityAdded:AddDelegate(self, AddEntityCache)
        elseif groupEvent == GroupEvent.Removed then
            group.onEntityRemoved:RemoveDelegate(self, AddEntityCache)
            group.onEntityRemoved:AddDelegate(self, AddEntityCache)
        elseif groupEvent == GroupEvent.AddedOrRemoved then
            group.onEntityAdded:RemoveDelegate(self, AddEntityCache)
            group.onEntityAdded:AddDelegate(self, AddEntityCache)
            group.onEntityRemoved:RemoveDelegate(self, AddEntityCache)
            group.onEntityRemoved:AddDelegate(self, AddEntityCache)
        end
    end
end

function Collector:Deactivate()
    for i, group in ipairs(self.m_Groups) do
        group.onEntityAdded:RemoveDelegate(self, AddEntityCache)
        group.onEntityRemoved:RemoveDelegate(self, AddEntityCache)
    end

    self:ClearCollectedEntities()
end

function Collector:ClearCollectedEntities()
    if self.m_Count == 0 then
        return
    end

    -- TODO:AREC Retain
    self.m_CollectedEntities = {}
    self.m_Count = 0
end

--@return HashSet
function Collector:GetCollectedEntities()
    return self.m_CollectedEntities
end

function Collector:GetCount()
    return self.m_Count
end

function Collector:ToString()
    -- TODO
end

return Collector