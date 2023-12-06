local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local ComponentsLookupWriter = Class("ComponentsLookupWriter", LuaFileWriter)

function ComponentsLookupWriter:Ctor(root, moduleName)
    self.name = string.format("%sComponentsLookup", moduleName)
    self.componentNames = {}
    self:Open(string.format("%s/%s/%s.lua", root, moduleName, self.name))
end

function ComponentsLookupWriter:PushComponentName(name)
    table.insert(self.componentNames, name)
end

function ComponentsLookupWriter:Flush()
    LuaFileWriter.Flush(self)
    self:WriteLineFormat("local %s = {}", self.name)
    self:WriteLine()
    for index, componentName in ipairs(self.componentNames) do
        self:WriteLineFormat("%s.%s = %s", self.name, componentName, index)
    end
    self:WriteLine()
    self:WriteLineFormat("%s.TotalComponents = %s", self.name, #self.componentNames)
    self:WriteLine()
    self:WriteLineFormat("return %s", self.name)
    self:Close()
end

return ComponentsLookupWriter