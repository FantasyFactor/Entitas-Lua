require("Core/Class")

local Matcher = Class("Matcher")

function Matcher:Ctor()
    self.m_Indices = nil
    self.m_AllOfIndices = nil
    self.m_AnyOfIndices = nil
    self.m_NoneOfIndices = nil

    self.m_IndicesBuffer = {}
end

local function MergeIndices(self, allOfIndices, anyOfIndices, noneOfIndices)
    local hashSet = {}  --TODO：优化效率
    
    local hasIndex = false

    if allOfIndices ~= nil then
        for i, v in ipairs(allOfIndices) do
            if not hashSet[v] then
                table.insert(self.m_IndicesBuffer, v)
                hasIndex = true
                hashSet[v] = true
            end
        end
    end

    if anyOfIndices ~= nil then
        for i, v in ipairs(anyOfIndices) do
            if not hashSet[v] then
                table.insert(self.m_IndicesBuffer, v)
                hasIndex = true
                hashSet[v] = true
            end
        end
    end

    if noneOfIndices ~= nil then
        for i, v in ipairs(noneOfIndices) do
            if not hashSet[v] then
                table.insert(self.m_IndicesBuffer, v)
                hasIndex = true
                hashSet[v] = true
            end
        end
    end

    if not hasIndex then
        return nil --没有任何数据  
    end

    local result = self.m_IndicesBuffer

    table.sort(result)

    self.m_IndicesBuffer = {}

    return result
end


local function DistinctIndices(self, ...)
    local n = select("#", ...)

    if n == 0 then
        return nil
    end

    local hasIndex = false

    local hashSet = {}  --TODO：优化效率

    for i = 1, n, 1 do
        local index = select(i, ...)
        if index ~= nil and not hashSet[index] then
            table.insert(self.m_IndicesBuffer, index)
            hashSet[index] = true
            hasIndex = true
        end
    end

    if not hasIndex then
       return nil --没有任何数据  
    end

    local result = self.m_IndicesBuffer

    table.sort(result)

    self.m_IndicesBuffer = {}

    return result
end

function Matcher:GetIndices()
    if self.m_Indices == nil then
        if self.m_AllOfIndices ~= nil or self.m_AnyOfIndices ~= nil or self.m_NoneOfIndices ~= nil then
            self.m_Indices = MergeIndices(self, self.m_AllOfIndices, self.m_AnyOfIndices, self.m_NoneOfIndices)
        end
    end

    return self.m_Indices
end

function Matcher:AllOf(...)
    self.m_AllOfIndices = DistinctIndices(self, ...)
    self.m_Indices = nil

    return self
end

function Matcher:AnyOf(...)
    self.m_AnyOfIndices = DistinctIndices(self, ...)
    self.m_Indices = nil

    return self
end

function Matcher:NoneOf(...)
    self.m_NoneOfIndices = DistinctIndices(self, ...)
    self.m_Indices = nil

    return self
end

function Matcher:Matches(entity)
    local matchAll = self.m_AllOfIndices == nil or entity:HasComponents(self.m_AllOfIndices) 
    local matchAny = self.m_AnyOfIndices == nil or entity:HasAnyComponent(self.m_AnyOfIndices) 
    local matchNone = self.m_NoneOfIndices == nil or not entity:HasAnyComponent(self.m_NoneOfIndices)  

    return matchAll and matchAny and matchNone
end


return Matcher