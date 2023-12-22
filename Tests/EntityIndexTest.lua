luaunit = require('luaunit')

package.path = package.path .. ";?.lua"

local Pools = require("Entitas/Pools")
local Entity = require("Entitas/Entity")
local Matcher = require("Entitas/Matcher")
local Group = require("Entitas/Group")
local EntityIndex = require("Entitas/EntityIndex")

local function GetTestEntities()
    local pools = Pools() 

    local results = {}

    for i = 1, 10, 1 do
        local entity = Entity()
        entity:Initialize(i, pools)

        local index = 1
        local component = entity:CreateComponent(index)

        component.x = i % 4
        component.y = math.ceil(i / 4)
        entity:AddComponent(index, component)

        table.insert(results, entity)
    end

    return results
end

local function GetGroup(entities)
    local matcher = Matcher()
    matcher:AnyOf(1)

    local group = Group(matcher)

    for i, entity in ipairs(entities) do
        group:HandleEntity(entity)
    end

    return group
end

local function GetKeys(entity, component)
    local component1 = entity:GetComponent(1)
    return {component1.x}
end

local function GetIndexLength(tb)
    local n = 0

    for k, v in pairs(tb) do
        if k ~= nil then
            n = n + 1 
        end
    end

    return n
end

function TestEntityIndexCtor()
    local entities = GetTestEntities()
    local group = GetGroup(entities)
    local entityIndex = EntityIndex("entityIndex1", group, GetKeys)

    assert(GetIndexLength(entityIndex.m_Index[1]) == 3)
    assert(GetIndexLength(entityIndex.m_Index[3]) == 2)
end

function TestEntityIndexDeactivate()
    local entities = GetTestEntities()
    local group = GetGroup(entities)
    local entityIndex = EntityIndex("entityIndex1", group, GetKeys)

    entityIndex:Deactivate()

    local n = 0

    for k, v in pairs(entityIndex.m_Index) do
        n = n + 1
    end

    assert(n == 0)
end

function TestEntityIndexGetName()
    local entities = GetTestEntities()
    local group = GetGroup(entities)
    local entityIndex = EntityIndex("entityIndex1", group, GetKeys)

    assert(entityIndex:GetName() == "entityIndex1")
end

function TestEntityIndexAddEntity()
    local matcher = Matcher()
    matcher:AnyOf(1)

    local group = Group(matcher)

    local entityIndex = EntityIndex("entityIndex1", group, GetKeys)

    local pools = Pools() 
    local entity = Entity()
    entity:Initialize(20, pools)

    local component = entity:CreateComponent(1)
        
    component.x = 3
    component.y = 1

    entity:AddComponent(1, component)

    entityIndex:AddEntity(component.x, entity)
    
    assert(GetIndexLength(entityIndex.m_Index[3]) == 1)
end

function TestEntityIndexRemoveEntity()
    local entities = GetTestEntities()
    local group = GetGroup(entities)
    local entityIndex = EntityIndex("entityIndex1", group, GetKeys)

    assert(GetIndexLength(entityIndex.m_Index[3]) == 2)

    entityIndex:RemoveEntity(3, entities[3])

    assert(GetIndexLength(entityIndex.m_Index[3]) == 1)

    entityIndex:RemoveEntity(3, entities[7])

    assert(#(entityIndex.m_Index[3]) == 0)

end

function TestEntityIndexGetEntities()
    local entities = GetTestEntities()
    local group = GetGroup(entities)
    local entityIndex = EntityIndex("entityIndex1", group, GetKeys)

    local indexEntities = entityIndex:GetEntities(3)

    assert(GetIndexLength(indexEntities) == 2)
    assert(indexEntities[entities[3]])
    assert(indexEntities[entities[7]])
end


os.exit(luaunit.LuaUnit.run())