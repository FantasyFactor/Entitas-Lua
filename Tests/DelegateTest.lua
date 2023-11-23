luaunit  = require('luaunit')

package.path = package.path .. ";?.lua"

local Delegate = require("Entitas/Delegate")


local function delegate1(value)
    
end

local function delegate2(value)
    
end

function TestNewDelegate()
    local d1 = Delegate()
    local d2 = Delegate(delegate1)
    local d3 = Delegate(delegate1, delegate2)
end

function TestAddDelegate()
    local d1 = Delegate()

    d1:AddDelegate(delegate1)
    d1:AddDelegate(delegate2)

    assert(d1.m_Count == 2)
end

function TestCallDelegate()
    local d1 = Delegate()

    local n = 0

    d1:AddDelegate(function (value)
        n = n + value
    end)
    d1:AddDelegate(function (value)
        n = n* value
    end)

    d1(3)

    assert(n == 9)
end

function TestRemoveDelegate()
    local d1 = Delegate()

    d1:AddDelegate(delegate1)
    d1:AddDelegate(delegate2)

    assert(d1.m_Count == 2)

    d1:RemoveDelegate(delegate1)
    d1:RemoveDelegate(delegate2)

    assert(d1.m_Count == 0)
end

os.exit(luaunit.LuaUnit.run())