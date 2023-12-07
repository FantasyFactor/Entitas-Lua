require("Core/Class")

local ReactiveSystem = Class("ReactiveSystem", nil, true)

function ReactiveSystem:Ctor(context)
    self.m_Collector = self:GetTrigger(context)
end

function ReactiveSystem:Dtor()
    self:Deactivate()
end

function ReactiveSystem:Activate()
    self.m_Collector:Activate()
end

function ReactiveSystem:Deactivate()
    self.m_Collector:Deactivate()
end

function ReactiveSystem:Clear()
    self.m_Collector:ClearCollectedEntities()
end

function ReactiveSystem:Execute()
    if self.m_Collector ~= nil and self.m_Collector:GetCount() > 0 then
        local entities = self.m_Collector:GetCollectedEntities()

        local buffer = {}
        local bufferSize = 0

        for entity, v in pairs(entities) do
            if self:Filter(entity) then
                entity:Retain(self)

                table.insert(buffer, entity)

                bufferSize = bufferSize + 1
            end
        end

        self.m_Collector:ClearCollectedEntities()

        if bufferSize > 0 then
            self:ExecuteCollection(buffer)

            for i, entity in ipairs(buffer) do
                entity:Release(self)
            end
        end
    end
end

--- 返回Collector
---@param context Context
---@return Collector
function ReactiveSystem:GetTrigger(context)
    --Abstract
    return nil
end

--- 过滤
function ReactiveSystem:Filter(entity)
    --Abstract
    return true
end

--- 处理收集到的Entity
function ReactiveSystem:ExecuteCollection(entities)
    --Abstract
end

return ReactiveSystem