require("Core/Class")
local AbstractEntityIndex = require("Entitas/AbstractEntityIndex")

local EntityIndex = Class("EntityIndex", AbstractEntityIndex)


function EntityIndex:Ctor(name, group, getKeys)
    self.m_Index = {} --<key, <entity, has>>

    self:Activate()
end

function EntityIndex:Activate()
    self.base.Activate(self)

    self:IndexEntities(self.m_Group)
end

function EntityIndex:GetEntities(key)
    local entities = self.m_Index[key]

    if entities == nil then
        entities = {}
        self.m_Index[key] = entities
    end

    return entities
end

function EntityIndex:AddEntity(key, entity)
    local entities = self:GetEntities(key)
    local has = entities[entity]
    if not has then
        entities[entity] = true
    end

    entity:GetAerc():SafeRetain(self)
end

function EntityIndex:RemoveEntity(key, entity)
    local entities = self:GetEntities(key)

    entities[entity] = nil

    entity:GetAerc():SafeRelease(self)
end

function EntityIndex:Clear()
    for key, entities in pairs(self.m_Index) do
        for entity in pairs(entities) do
            if entity ~= nil then
                entity:GetAerc():SafeRelease(self)
            end
        end
    end

    self.m_Index = {}
end

-- function EntityIndex:ToString()
    
-- end

return EntityIndex
