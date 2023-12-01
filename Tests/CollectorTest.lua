luaunit = require('luaunit')

package.path = package.path .. ";?.lua"

local Pools = require("Entitas/Pools")
local Entity = require("Entitas/Entity")
local Matcher = require("Entitas/Matcher")
local Group = require("Entitas/Group")
local Collector = require("Entitas/Collector")

local function GetTestEntities()
    local pools = Pools() 

    local results = {}

    for i = 1, 10, 1 do
        local entity = Entity()
        entity:Initialize(i, pools)
        table.insert(results, entity)
    end

    return results
end

function TestCollectorNew()
    local entities = GetTestEntities()

    local collector1 = Collector({Group(Matcher():AnyOf(1, 2))}, {GroupEvent.Added})
    local collector2 = Collector({Group(Matcher():AnyOf(1, 3))}, {GroupEvent.Removed})
    local collector3 = Collector({Group(Matcher():NoneOf(4))}, {GroupEvent.AddedOrRemoved})
end

function TestCollectorGetCollectedEntities()
    local entities = GetTestEntities()

    local group1 = Group(Matcher():AnyOf(1, 2))

    local collector1 = Collector({group1}, {GroupEvent.Added})
    local collector2 = Collector({group1}, {GroupEvent.Removed})

    local component = entities[1]:CreateComponent(1)
    entities[1]:AddComponent(1, component)

    group1:HandleEntity(entities[1], 1, component)

    assert(group1:GetCount() == 1)
    local collector1Entities = collector1:GetCollectedEntities()
    
    local n = 0

    for entity, v in pairs(collector1Entities) do
        assert(entity == entities[1])
        n = n + 1
    end

    assert(n == 1)

    entities[1]:RemoveComponent(1)

    for i, entity in ipairs(entities) do
        group1:HandleEntity(entity)
    end

    local collector2Entities = collector2:GetCollectedEntities()

    n = 0

    for entity, v in pairs(collector2Entities) do
        assert(entity == entities[1])
        n = n + 1
    end

    assert(n == 1)
end

function TestCollectorGetCollectedCount()
    local entities = GetTestEntities()

    local group1 = Group(Matcher():AnyOf(1, 2))
    local group2 = Group(Matcher():AnyOf(3))

    local collector1 = Collector({group1, group2}, {GroupEvent.Added, GroupEvent.Removed})

    local component1 = entities[1]:CreateComponent(1)
    entities[1]:AddComponent(1, component1)

    local component3 = entities[3]:CreateComponent(3)
    entities[3]:AddComponent(3, component3)

    group1:HandleEntity(entities[1], 1, component1)
    group1:HandleEntity(entities[3], 3, component3)
    group2:HandleEntity(entities[3], 3, component3)

    assert(collector1:GetCount() == 1)

    entities[3]:RemoveComponent(3)

    group2:HandleEntity(entities[3], 3, component3)

    assert(collector1:GetCount() == 2)
end

function TestCollectorDeactivate()
    local entities = GetTestEntities()

    local group1 = Group(Matcher():AnyOf(1, 2))

    local collector1 = Collector({group1}, {GroupEvent.Added})

    local component1 = entities[1]:CreateComponent(1)
    entities[1]:AddComponent(1, component1)

    local component2 = entities[2]:CreateComponent(2)
    entities[2]:AddComponent(2, component2)

    local component3 = entities[3]:CreateComponent(3)
    entities[3]:AddComponent(3, component3)

    group1:HandleEntity(entities[1], 1, component1)
    group1:HandleEntity(entities[2], 2, component2)
    group1:HandleEntity(entities[3], 3, component3)

    assert(collector1:GetCount() == 2)

    collector1:Deactivate()

    assert(collector1:GetCount() == 0)
end


os.exit(luaunit.LuaUnit.run())