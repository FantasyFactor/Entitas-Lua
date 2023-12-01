require("Core/Class")

local Delegate = require("Entitas/Delegate")

local Group = Class("Group")

function Group:Ctor(matcher)
    self.m_Matcher = matcher
    self.m_Entities = {}
    self.m_Count = 0

    self.m_EntitiesCache = nil

    self.onEntityAdded = Delegate()    --group, entity, index, component
    self.onEntityRemoved = Delegate()    --group, entity, index, component
    self.onEntityUpdated = Delegate()    --group, entity, index, previousComponent, newComponent
end

local function AddEntitySilently(self, entity)
    if entity:IsEnable() then
        local has = self.m_Entities[entity]
        if not has then
            self.m_EntitiesCache = nil
            self.m_Entities[entity] = true
            self.m_Count = self.m_Count + 1

            return true
        end 

        return false
    end

    return false
end

local function AddEntity(self, entity, index, component)
    if AddEntitySilently(self, entity) and self.onEntityAdded ~= nil then
        self.onEntityAdded(self, entity, index, component)
    end
end

local function RemoveEntitySilently(self, entity)
    local has = self.m_Entities[entity]
    if has then
        self.m_Entities[entity] = nil
        self.m_EntitiesCache = nil
        self.m_Count = self.m_Count - 1
        return true
    end 
    return false
end

local function RemoveEntity(self, entity, index, component)
    local has = self.m_Entities[entity]
    if has then
        self.m_Entities[entity] = nil
        self.m_EntitiesCache = nil
        
        if self.onEntityRemoved ~= nil then
            self.onEntityRemoved(self, entity, index, component)
        end

    end
end

local function CopyTo(hashSet, array)
    for entity, v in pairs(hashSet) do
        if v == true then
            table.insert(array, entity)
        end
    end
end

function Group:GetCount()
    return self.m_Count
end

function Group:HandleEntitySilently(entity)
    if self.m_Matcher:Matches(entity) then
        AddEntitySilently(self, entity)
    else
        RemoveEntitySilently(self, entity)    
    end
end

function Group:HandleEntity(entity, index, component)
    if self.m_Matcher:Matches(entity) then
        AddEntity(self, entity, index, component)
    else
        RemoveEntity(self, entity, index, component)    
    end
end

function Group:UpdateEntity(entity, index, previousComponent, newComponent)
    if self.m_Entities[entity] then
        if self.onEntityRemoved ~= nil then
            self.onEntityRemoved(self, entity, index, previousComponent)
        end
        if self.onEntityAdded ~= nil then
            self.onEntityAdded(self, entity, index, newComponent)
        end

        if self.onEntityUpdated ~= nil then
            self.onEntityUpdated(self, entity, index, previousComponent, newComponent)
        end
    end
end

function Group:ContainsEntity(entity)
    return self.m_Entities[entity] == true
end

function Group:GetEntities(buffer)
    if buffer == nil then
        if self.m_EntitiesCache == nil then
            self.m_EntitiesCache = {}
            CopyTo(self.m_Entities, self.m_EntitiesCache)
        end
        return self.m_EntitiesCache
    else
        CopyTo(self.m_Entities, buffer)
        return buffer
    end
end

-- function Group:ToString()
    
-- end

return Group