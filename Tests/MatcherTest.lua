luaunit = require('luaunit')

package.path = package.path .. ";?.lua"

local Pools = require("Entitas/Pools")
local Entity = require("Entitas/Entity")
local Matcher = require("Entitas/Matcher")

function TestMatcherAllOf()
    local mathcer = Matcher():AllOf(1, 3, 4)

    assert(#mathcer.m_AllOfIndices == 3)
    assert(mathcer.m_AllOfIndices[1] == 1)
    assert(mathcer.m_AllOfIndices[2] == 3)
    assert(mathcer.m_AllOfIndices[3] == 4)
end

function TestMatcherAnyOf()
    local mathcer = Matcher():AnyOf(2, 6, 3)

    assert(#mathcer.m_AnyOfIndices == 3)
    assert(mathcer.m_AnyOfIndices[1] == 2)
    assert(mathcer.m_AnyOfIndices[2] == 3)
    assert(mathcer.m_AnyOfIndices[3] == 6)
end

function TestMatcherNoneOf()
    local mathcer = Matcher():NoneOf(5)

    assert(#mathcer.m_NoneOfIndices == 1)
    assert(mathcer.m_NoneOfIndices[1] == 5)
end

function TestMatcherGetIndices()
    local mathcher = Matcher():AllOf(1, 3, 4):AnyOf(2, 3, 6):NoneOf(5)

    local indices = mathcher:GetIndices()

    assert(#indices == 6)
    assert(indices[1] == 1)
    assert(indices[2] == 2)
    assert(indices[3] == 3)
    assert(indices[4] == 4)
    assert(indices[5] == 5)
    assert(indices[6] == 6)
end

function TestMatcherMatch()
    local mathcher = Matcher():AnyOf(2, 3, 6)

    local pools = Pools() 

    local entity = Entity()
    entity:Initialize(1, pools)

    assert(mathcher:Match(entity) == false)

    entity:AddComponent(1, {}) --1
    assert(mathcher:Match(entity) == false)

    entity:AddComponent(3, {}) --1, 3
    assert(mathcher:Match(entity) == true)

    mathcher:AllOf(1, 3, 4)
    assert(mathcher:Match(entity) == false)

    entity:AddComponent(4, {}) --1, 3, 4
    assert(mathcher:Match(entity) == true)

    mathcher:NoneOf(5)
    assert(mathcher:Match(entity) == true)

    entity:AddComponent(5, {}) --1, 3, 4, 5
    assert(mathcher:Match(entity) == false)
end

os.exit(luaunit.LuaUnit.run())