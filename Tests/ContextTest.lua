luaunit = require('luaunit')

package.path = package.path .. ";?.lua"

local Pools = require("Entitas/Pools")
local Entity = require("Entitas/Entity")
local Matcher = require("Entitas/Matcher")
local Group = require("Entitas/Group")
local Collector = require("Entitas/Collector")
local Context = require("Entitas/Context")
local EntityIndex = require("Entitas/EntityIndex")

local function EntityFactory()
    return Entity()
end

local function GetKeys(entity, component)
    local component1 = entity:GetComponent(1)
    return {component1.x}
end

function TestContextCreateEntity()
    local context = Context(0, EntityFactory)

    local entity1 = context:CreateEntity()

    assert(context:GetCount() == 1)
    assert(entity1 ~= nil)
    assert(entity1:IsEnable())
    assert(entity1:GetCreationIndex() == 1)

    entity1:Destroy()

    local entity2 = context:CreateEntity()

    assert(context:GetCount() == 1)
    assert(entity2 == entity1)
    assert(entity2:IsEnable())
    assert(entity2:GetCreationIndex() == 2)
end

function TestContextDestroyAllEntities()
    local context = Context(0, EntityFactory)

    local entity1 = context:CreateEntity()
    local entity2 = context:CreateEntity()
    local entity3 = context:CreateEntity()

    assert(context:GetCount() == 3)

    context:DestroyAllEntities()
    
    assert(entity1:IsEnable() == false)
    assert(entity2:IsEnable() == false)
    assert(entity3:IsEnable() == false)

    assert(context:GetCount() == 0)
end

function TestContextHasEntity()
    local context = Context(0, EntityFactory)

    local entity1 = context:CreateEntity()

    assert(context:HasEntity(entity1))
end

function TestContextGetEntities()
    local context = Context(0, EntityFactory)
    
    local entities = {}

    for i = 1, 10, 1 do
        local entity = context:CreateEntity()
        table.insert(entities, entity) 
    end

    local contextEntities = context:GetEntities()

    for i, entity in ipairs(contextEntities) do
        assert(table.concat(entity))
    end
end

function TestContextGetGroup()
    local context = Context(0, EntityFactory)

    for i = 1, 10, 1 do
        local entity = context:CreateEntity()
        local component = entity:CreateComponent(1)
        entity:AddComponent(1, component)
    end

    local matcher = Matcher():AnyOf(1)

    local group1 = context:GetGroup(matcher)

    local group2 = context:GetGroup(matcher)

    assert(group1 == group2)
    assert(group1:GetCount() == 10)
end

function TestContextAddEntityIndex()
    local group = Group( Matcher():AnyOf(1))

    local entityIndex = EntityIndex("entityIndex1", group, GetKeys)

    local context = Context(0, EntityFactory)
    context:AddEntityIndex(entityIndex)

    assert(context.m_EntityIndices["entityIndex1"] == entityIndex)
end

function TestContextGetEntityIndex()
    local group = Group( Matcher():AnyOf(1))

    local entityIndex = EntityIndex("entityIndex1", group, GetKeys)

    local context = Context(0, EntityFactory)
    context:AddEntityIndex(entityIndex)

    assert(context:GetEntityIndex("entityIndex1") == entityIndex)
end

function TestContextClearComponentPool()
    local context = Context(0, EntityFactory)

    for i = 1, 10, 1 do
        local index = i % 4
        local entity = context:CreateEntity()
        local component = entity:CreateComponent(index)
        entity:AddComponent(index, component)
    end

    context:DestroyAllEntities()

    assert(context.m_ComponentPools.m_Stacks[1]:Count() == 3)

    context:ClearComponentPool(1)

    assert(context.m_ComponentPools.m_Stacks[1] == nil)
end

function TestContextClearAllComponentPool()
    local context = Context(0, EntityFactory)

    for i = 1, 10, 1 do
        local index = i % 4
        local entity = context:CreateEntity()
        local component = entity:CreateComponent(index)
        entity:AddComponent(index, component)
    end

    context:DestroyAllEntities()

    assert(context.m_ComponentPools.m_Stacks[1]:Count() == 3)

    context:ClearAllComponentPool()

    assert(context.m_ComponentPools.m_Stacks == nil)
end

function TestContextCreateCollector()
    local context = Context(0, EntityFactory)

    local triggers = {
        {
            matcher = Matcher():AnyOf(1),
            groupEvent = GroupEvent.Added
        },
        {
            matcher = Matcher():AnyOf(3),
            groupEvent = GroupEvent.Removed
        }
    }

    local collector = context:CreateCollector(triggers)
end


os.exit(luaunit.LuaUnit.run())