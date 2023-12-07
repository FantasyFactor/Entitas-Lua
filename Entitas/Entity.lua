require("Core/Class")
local Delegate = require("Entitas/Delegate")
local AERC = require("Entitas/AERC")

local Entity = Class("Entity")

function Entity:Ctor()
    self.m_ComponentBuffer = {}
    self.m_IndexBuffer = {}
    self.m_ComponentPools = nil
    self.m_Components = {}
    self.m_CreationIndex = 0
    self.m_IsEnabled = false
    self.m_Aerc = AERC(self)

    --self.m_ComponentsCache = {}
    --self.m_ComponentIndicesCache = {}

    self.onComponentAdded = Delegate()    --entity, index, component
    self.onComponentRemoved = Delegate()  --entity, index, component
    self.onComponentReplaced = Delegate() --entity, index, previousComponent, newComponent
    self.onEntityReleased = Delegate()    --entity
    self.onDestroyEntity = Delegate()     --entity
end

function Entity:GetCreationIndex()
    return self.m_CreationIndex
end

function Entity:IsEnable()
    return self.m_IsEnabled
end

function Entity:GetAerc()
    return self.m_Aerc
end

function Entity:GetRetainCount()
    return self.m_Aerc:GetCount()
end

function Entity:Initialize(creationIndex, componentPools)
    self:Reactivate(creationIndex)

    self.m_ComponentPools = componentPools
end

function Entity:Reactivate(creationIndex)
    self.m_CreationIndex = creationIndex
    self.m_IsEnabled = true
end

function Entity:AddComponent(index, component)
    -- TODO Exception:m_IsEnabled == false
    -- TODO Exception:HasComponent(index)

    self.m_Components[index] = component;

    if self.onComponentAdded ~= nil then
        self.onComponentAdded(self, index, component);
    end
end

function Entity:RemoveComponent(index)
    -- TODO Exception:m_IsEnabled == false
    -- TODO Exception:HasComponent(index)

    self:ReplaceComponentInternal(index, nil)
end

function Entity:ReplaceComponent(index, component)
    -- TODO Exception:m_IsEnabled == false
    if self:HasComponent(index) then
        self:ReplaceComponentInternal(index, component)
    elseif component ~= nil then
        self:AddComponent(index, component)
    end
end

function Entity:ReplaceComponentInternal(index, replacement)
    local previousComponent = self.m_Components[index]
    if replacement ~= previousComponent then
        self.m_Components[index] = replacement

        if replacement ~= nil then
            if self.onComponentReplaced ~= nil then
                self.onComponentReplaced(self, index, previousComponent, replacement)
            end
        else
            if self.onComponentRemoved ~= nil then
                self.onComponentRemoved(self, index, previousComponent)
            end
        end

        if self.m_ComponentPools ~= nil then
            self.m_ComponentPools:Push(index, previousComponent)
        end
    else
        if self.OnComponentReplaced ~= nil then
            self.OnComponentReplaced(self, index, previousComponent, replacement);
        end
    end
end

function Entity:GetComponent(index)
    -- TODO Exception:HasComponent(index)
    return self.m_Components[index]
end

-- function Entity:GetComponents()
    
-- end

-- function Entity:GetComponentIndices()
    
-- end

function Entity:HasComponent(index)
    return self.m_Components[index] ~= nil
end

function Entity:HasComponents(indices)
    for i, v in ipairs(indices) do
        if v ~= nil then
            if self.m_Components[v] == nil then
                return false
            end
        end
    end

    return true
end

function Entity:HasAnyComponent(indices)
    for i, v in ipairs(indices) do
        if v ~= nil then
            if self.m_Components[v] ~= nil then
                return true
            end
        end
    end

    return false
end

function Entity:RemoveAllComponents()
    for k, v in pairs(self.m_Components) do
        if v ~= nil then
            self:ReplaceComponent(k, nil)
        end
    end
end

function Entity:CreateComponent(index)
    local component = self.m_ComponentPools:Pop(index)

    if component == nil then
        component = {}
    end

    return component
end

function Entity:Retain(owner)
    self.m_Aerc:Retain(owner)
end

function Entity:Release(owner)
    self.m_Aerc:Release(owner)
    
    if self.m_Aerc:GetCount() == 0 then
        if self.onEntityReleased ~= nil then
            self.onEntityReleased(self)
        end
    end  
end

function Entity:Destroy()
    -- TODO Exception:m_IsEnabled == false
    if self.onDestroyEntity ~= nil then
        self.onDestroyEntity(self)
    end
end

function Entity:InternalDestroy()
    self.m_IsEnabled = false;
    self:RemoveAllComponents();
    self.onComponentAdded:RemoveAllDelegate();
    self.onComponentReplaced:RemoveAllDelegate();
    self.onComponentRemoved:RemoveAllDelegate();
    self.onDestroyEntity:RemoveAllDelegate();
end

function Entity:RemoveAllOnEntityReleasedHandlers()
    self.onEntityReleased:RemoveAllDelegate();
end

-- function Entity:ToString()
    
-- end


return Entity