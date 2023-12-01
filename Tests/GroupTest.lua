luaunit = require('luaunit')

package.path = package.path .. ";?.lua"

local Pools = require("Entitas/Pools")
local Entity = require("Entitas/Entity")
local Matcher = require("Entitas/Matcher")
local Group = require("Entitas/Group")

local function GetTestEntities()
    local pools = Pools() 

    local results = {}

    for i = 1, 10, 1 do
        local entity = Entity()
        entity:Initialize(i, pools)

        local index = i % 4
        local component = entity:CreateComponent(index)

        entity:AddComponent(index, component)

        table.insert(results, entity)
    end

    return results
end

function TestGroupHandleEntitySilently()
    local entities = GetTestEntities()

    local matcher = Matcher()
    matcher:AnyOf(1, 3) --entity 1, 3, 5, 7, 9 

    local group = Group(matcher)

    for i, entity in ipairs(entities) do
        group:HandleEntitySilently(entity)
    end
    
    assert(group:GetCount() == 5)
    assert(group.m_Entities[entities[1]])
    assert(group.m_Entities[entities[3]])
    assert(group.m_Entities[entities[5]])
    assert(group.m_Entities[entities[7]])
    assert(group.m_Entities[entities[9]])
    assert(not group.m_Entities[entities[6]])
    assert(not group.m_Entities[entities[10]])
end

function TestGroupHandleEntity()
    local entities = GetTestEntities()

    local matcher = Matcher()
    matcher:AnyOf(1, 3) --entity 1, 3, 5, 7, 9 

    local group = Group(matcher)

    for i, entity in ipairs(entities) do
        group:HandleEntity(entity)
    end
    
    assert(group.m_Entities[entities[1]])
    assert(group.m_Entities[entities[3]])
    assert(group.m_Entities[entities[5]])
    assert(group.m_Entities[entities[7]])
    assert(group.m_Entities[entities[9]])
    assert(not group.m_Entities[entities[6]])
    assert(not group.m_Entities[entities[10]])
end

function TestGroupContainsEntity()
    local entities = GetTestEntities()

    local matcher = Matcher()
    matcher:AnyOf(1, 3) --entity 1, 3, 5, 7, 9 

    local group = Group(matcher)

    for i, entity in ipairs(entities) do
        group:HandleEntitySilently(entity)
    end

    assert(group:ContainsEntity(entities[1]))
    assert(group:ContainsEntity(entities[3]))
    assert(group:ContainsEntity(entities[5]))
    assert(group:ContainsEntity(entities[7]))
    assert(group:ContainsEntity(entities[9]))
    assert(not group:ContainsEntity(entities[6]))
    assert(not group:ContainsEntity(entities[10]))
end

function TestGroupGetEntities()
    local entities = GetTestEntities()

    local matcher = Matcher()
    matcher:AnyOf(1, 3) --entity 1, 3, 5, 7, 9 

    local group = Group(matcher)

    for i, entity in ipairs(entities) do
        group:HandleEntitySilently(entity)
    end

    local cacheEnities = group:GetEntities()

    table.sort(cacheEnities, function(a, b) 
        return a:GetCreationIndex() < b:GetCreationIndex()
    end)
    assert(#cacheEnities == 5)
    assert(cacheEnities[1] == entities[1])
    assert(cacheEnities[2] == entities[3])
    assert(cacheEnities[3] == entities[5])
    assert(cacheEnities[4] == entities[7])
    assert(cacheEnities[5] == entities[9])

    local enityBuffer = {}

    group:GetEntities(enityBuffer)

    table.sort(enityBuffer, function(a, b) 
        return a:GetCreationIndex() < b:GetCreationIndex()
    end)
    assert(#enityBuffer == 5)
    assert(enityBuffer[1] == entities[1])
    assert(enityBuffer[2] == entities[3])
    assert(enityBuffer[3] == entities[5])
    assert(enityBuffer[4] == entities[7])
    assert(enityBuffer[5] == entities[9])
end

os.exit(luaunit.LuaUnit.run())