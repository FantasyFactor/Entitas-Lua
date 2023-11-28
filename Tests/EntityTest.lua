luaunit = require('luaunit')

package.path = package.path .. ";?.lua"

local Pools = require("Entitas/Pools")
local Entity = require("Entitas/Entity")

function TestEntityNewEntity()
    local pools = Pools() 

    local entity1 = Entity()
    entity1:Initialize(1, pools)

    assert(entity1:GetCreationIndex() == 1)
    assert(entity1:IsEnable())

    local entity2 = Entity()
    entity2:Initialize(2, pools)

    assert(entity2:GetCreationIndex() == 2)
    assert(entity2:IsEnable())
end

function TestEntityCreateComponent()
    local pools = Pools() 

    local entity = Entity()
    entity:Initialize(1, pools)

    local component = entity:CreateComponent(1)

    assert(component ~= nil)
end

function TestEntityAddComponent()
    local pools = Pools() 

    local entity = Entity()
    entity:Initialize(1, pools)

    entity:AddComponent(1, entity:CreateComponent(1))

    assert(entity:HasComponent(1))
end

function TestEntityRemoveComponent()
    local pools = Pools() 

    local entity = Entity()
    entity:Initialize(1, pools)

    entity:AddComponent(1, entity:CreateComponent(1))

    assert(entity:HasComponent(1))

    entity:RemoveComponent(1)

    assert(entity:HasComponent(1) == false)
end

function TestEntityGetComponents()
    local pools = Pools() 

    local entity = Entity()
    entity:Initialize(1, pools)

    local component = entity:CreateComponent(1)

    component.id = 1
    component.name = "Name1"

    entity:AddComponent(1, component)

    local entityComponent = entity:GetComponent(1)

    assert(entityComponent.id == 1)
    assert(entityComponent.name == "Name1")
end

function TestEntityReplaceComponent()
    local pools = Pools() 

    local entity = Entity()
    entity:Initialize(1, pools)

    local component1 = entity:CreateComponent(1)
    component1.id = 1
    component1.name = "Name1"

    entity:AddComponent(1, component1)

    local component2 = entity:CreateComponent(1)
    component2.id = 2
    component2.name = "Name2"

    entity:ReplaceComponent(1, component2)

    local entityComponent = entity:GetComponent(1)

    assert(entityComponent.id == 2)
    assert(entityComponent.name == "Name2")
end

function TestEntityHasComponents()
    local pools = Pools() 

    local entity = Entity()
    entity:Initialize(1, pools)

    entity:AddComponent(1, entity:CreateComponent(1))
    entity:AddComponent(2, entity:CreateComponent(2))

    assert(entity:HasComponents({1}))
    assert(entity:HasComponents({1,2}))
    assert(entity:HasComponents({1,3}) == false)
end

function TestEntityHasAnyComponents()
    local pools = Pools() 

    local entity = Entity()
    entity:Initialize(1, pools)

    entity:AddComponent(1, entity:CreateComponent(1))
    entity:AddComponent(2, entity:CreateComponent(2))

    assert(entity:HasAnyComponent({1}))
    assert(entity:HasAnyComponent({1,2}))
    assert(entity:HasAnyComponent({1,3}))
    assert(entity:HasAnyComponent({3, 4}) == false)
end

function TestEntityRemoveAllComponents()
    local pools = Pools() 

    local entity = Entity()
    entity:Initialize(1, pools)

    entity:AddComponent(1, entity:CreateComponent(1))
    entity:AddComponent(2, entity:CreateComponent(2))

    assert(entity:HasAnyComponent({1}))
    assert(entity:HasAnyComponent({1,2}))
    assert(entity:HasAnyComponent({1,3}))
    assert(entity:HasAnyComponent({3, 4}) == false)
end

os.exit(luaunit.LuaUnit.run())