require("Core/Class")
local AbstractEntityIndex = require("Entitas/AbstractEntityIndex")

local EntityIndex = Class("EntityIndex", AbstractEntityIndex)


function EntityIndex:Ctor(name, group, getKeys)
    self.m_Index = {}

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
    table.insert(entities, entity)

    entity.GetAerc():SafeRetain(self)
end

function EntityIndex:RemoveEntity(key, entity)
    local entities = self:GetEntities(key)
    
    local removeIndex = nil

    for i, value in ipairs(entities) do
        if entity == value then
            removeIndex = i
            break
        end
    end

    if removeIndex ~= nil then
        table.remove(entities, removeIndex)
        entity.GetAerc():SafeRelease(self)
    end
end

function EntityIndex:Clear()
    for key, entities in pairs(self.m_Index) do
        for i, entity in ipairs(entities) do
            if entity ~= nil then
                entity.GetAerc():SafeRelease(self)
            end
        end
    end

    self.m_Index = {}
end

-- function EntityIndex:ToString()
    
-- end

return EntityIndex
