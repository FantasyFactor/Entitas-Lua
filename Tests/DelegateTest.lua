luaunit  = require('luaunit')

package.path = package.path .. ";?.lua"

local Delegate = require("Entitas/Delegate")


local function delegate1(self, value)
    
end

local function delegate2(self, value)
    
end

function TestNewDelegate()
    local d1 = Delegate()
    assert(d1.m_InvokeList ~= nil)
    assert(d1.m_Count == 0)
end

function TestAddDelegate()
    local d1 = Delegate()

    d1:AddDelegate(nil, delegate1)
    d1:AddDelegate(nil, delegate2)

    assert(d1.m_Count == 2)
end

function TestCallDelegate()
    local d1 = Delegate()

    local n = 0

    d1:AddDelegate(nil, function (self, value)
        n = n + value
    end)
    d1:AddDelegate(nil, function (self, value)
        n = n* value
    end)

    d1(3)

    assert(n == 9)
end

function TestRemoveDelegate()
    local d1 = Delegate()

    d1:AddDelegate(nil, delegate1)
    d1:AddDelegate(nil, delegate2)

    assert(d1:GetCount() == 2)

    d1:RemoveDelegate(nil, delegate1)
    d1:RemoveDelegate(nil, delegate2)

    assert(d1:GetCount() == 0)
end

os.exit(luaunit.LuaUnit.run())