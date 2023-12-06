require("Core/Class")
local AbstractEntityIndex = require("Entitas/AbstractEntityIndex")

local PrimaryEntityIndex = Class("PrimaryEntityIndex", AbstractEntityIndex)

function PrimaryEntityIndex:Ctor(name, group, getKeys)
    self.m_Index = {}

    self:Activate()
end

function PrimaryEntityIndex:Activate()
    self.base.Activate(self)

    self:IndexEntities(self.m_Group)
end

function PrimaryEntityIndex:GetEntity(key)
    local entity = self.m_Index[key]

    return entity
end

function PrimaryEntityIndex:AddEntity(key, entity)
    local entity =  self.m_Index[key]
    if entity ~= nil then
        --TODO:Exception exist entity
        return 
    end

    self.m_Index[key] = entity
    
    entity.GetAerc():SafeRetain(self)
end

function PrimaryEntityIndex:RemoveEntity(key, entity)
    local entity =  self.m_Index[key]

    if entity ~= nil then
        self.m_Index[key] = nil
        entity.GetAerc():SafeRelease(self)
    end
end

function PrimaryEntityIndex:Clear()
    for key, entity in pairs(self.m_Index) do
        if entity ~= nil then
            entity.GetAerc():SafeRelease(self)
        end
    end

    self.m_Index = {}
end

-- function PrimaryEntityIndex:ToString()
    
-- end

return PrimaryEntityIndex
