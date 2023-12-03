require("Core/Class")
require("Core/Stack")

local Pools = require("Entitas/Pools")
local Delegate = require("Entitas/Delegate")
local Group = require("Entitas/Group")
local Collector = require("Entitas/Collector")

local Context = Class("Context")

function Context:Ctor(startCreationIndex, entityFactory)
    self.m_CreationIndex = startCreationIndex

    self.m_EntityFactory = entityFactory

    self.m_Entities = {}
    self.m_EntitiesCache = nil
    self.m_EntityCount = 0
    self.m_GroupsForIndex = {} --Dictionary<List<Group>>
    self.m_ComponentPools = Pools()
    self.m_EntityIndices = {}
    self.m_GroupChangedListPool = {}

    self.onEntityCreated = Delegate()    --context, entity
    self.onEntityWillBeDestroyed = Delegate()    --context, entity
    self.onEntityDestroyed = Delegate()     --context, entity
    self.onOnGroupCreated = Delegate()    --context, group

    self.m_ReusableEntities = Stack() --entity
    self.m_RetainedEntities = {}
end

local function UpdateGroupsComponentAddedOrRemoved(self, entity, index, component)
    local groups = self.m_GroupsForIndex[index]

    if groups ~= nil and #groups > 0 then
        local events = {}

        for i, group in ipairs(groups) do
            local event = group:HandleEntityAndGetEvent(entity)
            table.insert(events, event)
        end

        for i, event in ipairs(events) do
            if event ~= nil then
                event(groups[i], entity, index, component)
            end
        end
    end
end

local function UpdateGroupsComponentReplaced(self, entity, index, previousComponent, newComponent)
    local groups = self.m_GroupsForIndex[index]

    if groups ~= nil then
        for i, group in ipairs(groups) do
            group:UpdateEntity()
        end
    end
end

local function OnEntityReleased(self, entity)
    --TODO:Exception entity.IsEnabled
    entity:RemoveAllOnEntityReleasedHandlers()
    self.m_RetainedEntities[entity] = nil
    self.m_ReusableEntities:Push(entity)
end

local function OnDestroyEntity(entity)
    local has = self.m_Entities[entity]

    if not has then
        --TODO:Exception has entity
    end

    self.m_Entities[entity] = nil

    self.m_EntitiesCache = nil

    if self.onEntityWillBeDestroyed ~= nil then
        self.onEntityWillBeDestroyed(self, entity)
    end

    entity:InternalDestroy()
    
    if self.onEntityDestroyed ~= nil then
        self.onEntityDestroyed(self, entity)
    end

    if entity.retainCount == 1 then --TODO:AERC
        entity.onEntityReleased:RemoveDelegate(self.onEntityReleased) 
        self.m_ReusableEntities:Push(entity)
        entity:Release(self)
        entity:RemoveAllOnEntityReleasedHandlers()
    else
        self.m_RetainedEntities[entity] = true
        entity:Release(self)
    end
end

function Context:CreateEntity()
    local entity = nil

    self.m_CreationIndex = self.m_CreationIndex + 1

    if self.m_ReusableEntities:Count() > 0 then
        entity = self.m_ReusableEntities:Pop()
        entity:Reactivate(self.m_CreationIndex)
    else
        entity = self.m_EntityFactory()
        entity:Initialize(self.m_CreationIndex, self.m_ComponentPools)
    end

    self.m_Entities[entity] = true
    self.m_EntityCount = self.m_EntityCount + 1

    self.m_EntitiesCache = nil

    entity.onComponentAdded:AddDelegate(self, UpdateGroupsComponentAddedOrRemoved)
    entity.onComponentRemoved:AddDelegate(self, UpdateGroupsComponentAddedOrRemoved)
    entity.onComponentReplaced:AddDelegate(self, UpdateGroupsComponentReplaced)
    entity.onEntityReleased:AddDelegate(self, OnEntityReleased)
    entity.onDestroyEntity:AddDelegate(self, OnDestroyEntity)

    if self.onEntityCreated ~= nil then
        self.onEntityCreated(self, entity)
    end

    return entity
end

function Context:DestroyAllEntities()
    for entity, has in pairs(self.m_Entities) do
        if entity ~= nil then
            entity:Destroy()
        end
    end

    self.m_Entities = {}
end

function Context:HasEntity(entity)
    local has = self.m_Entities[entity]

    if has then
        return true
    end

    return false
end

function Context:GetEntities()
    if self.m_EntitiesCache == nil then
        self.m_EntitiesCache = {}
        for entity, has in pairs(self.m_Entities) do
            if entity ~= nil then
                table.insert(self.m_EntitiesCache, entity)
            end
        end    
    end

    return self.m_EntitiesCache
end

function Context:GetGroup(matcher)
    local group = self.m_Groups[matcher]
    
    if group == nil then
        group = Group(matcher)
        local entities = self:GetEntities()
        for i, entity in ipairs(entities) do
            group:HandleEntitySilently(entity)
        end

        self.m_Groups[matcher] = group

        for i, index in ipairs(matcher:GetIndices()) do
            local indexGroups = self.m_GroupsForIndex[index]
            if indexGroups == nil then
                indexGroups = {}
                self.m_GroupsForIndex[index] = indexGroups
            end

            table.insert(indexGroups, group)
        end

        if self.onOnGroupCreated ~= nil then
            self.onOnGroupCreated(self, group)
        end
        
    end

    return group
end

-- function Context:AddEntityIndex(entityIndex)
    
-- end

-- function Context:GetEntityIndex(name)
    
-- end

function Context:ResetCreationIndex()
    self.m_CreationIndex = 0
end

function Context:ClearComponentPool(index)
    self.m_ComponentPools:Clear(index)
end

function Context:ClearAllComponentPool()
    self.m_ComponentPools:ClearAll()
end

function Context:Rest()
    self:DestroyAllEntities()
    self.ResetCreationIndex()
end

-- function Context:ToString()
    
-- end

