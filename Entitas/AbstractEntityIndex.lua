require("Core/Class")

local AbstractEntityIndex = Class("AbstractEntityIndex", nil, true)

--- 构造函数
---@param name string 名称
---@param group Group 组
---@param getKeys function 返回符合的Entity，table Fun(entity, component)
function AbstractEntityIndex:Ctor(name, group, getKeys)
    self.m_Name = name
    self.m_Group = group
    self.m_GetKeys = getKeys
end

function AbstractEntityIndex:Dtor()
    self:Deactivate()
end

function AbstractEntityIndex:GetName()
    return self.m_Name
end

function AbstractEntityIndex:IndexEntities(group)
    local entities = group:GetEntities()

    for i, entity in ipairs(entities) do
        local keys = self.m_GetKeys(entity, nil)

        for j, key in ipairs(keys) do
            if key ~= nil then
                self:AddEntity(key, entity)
            end
        end
    end
end

local function OnEntityAdded(group, entity, index, component)
    local keys = self.m_GetKeys(entity, component)

    for i, key in ipairs(keys) do
        if key ~= nil then
            self:AddEntity(key, entity)
        end
    end
end

local function OnEntityRemoved(group, entity, index, component)
    local keys = self.m_GetKeys(entity, component)

    for i, key in ipairs(keys) do
        if key ~= nil then
            self:RemoveEntity(key, entity)
        end
    end
end

function AbstractEntityIndex:Activate()
    self.m_Group.onEntityAdded:AddDelegate(self, OnEntityAdded)
    self.m_Group.onEntityRemoved:AddDelegate(self, OnEntityRemoved)
end

function AbstractEntityIndex:Deactivate()
    self.m_Group.onEntityAdded:RemoveDelegate(self, OnEntityAdded)
    self.m_Group.onEntityRemoved:RemoveDelegate(self, OnEntityRemoved)
    self:Clear()
end

function AbstractEntityIndex:AddEntity(key, entity)
    --Abstract
end

function AbstractEntityIndex:RemoveEntity(key, entity)
    --Abstract
end

function AbstractEntityIndex:Clear()
    --Abstract
end

return AbstractEntityIndex