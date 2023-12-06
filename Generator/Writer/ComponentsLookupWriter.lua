local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local Template = require "Generator/Template/Template"
local ComponentsLookupWriter = Class("ComponentsLookupWriter", LuaFileWriter)

function ComponentsLookupWriter:Ctor(root, moduleName)
    self.moduleName = moduleName
    self.componentNames = {}
    self:Open(string.format("%s/%s/%s.lua", root, moduleName, string.format("%sComponentsLookup", moduleName)))
end

function ComponentsLookupWriter:PushComponentName(name)
    table.insert(self.componentNames, name)
end

function ComponentsLookupWriter:Flush()
    LuaFileWriter.Flush(self)

    local componentIndices = self:ConcatByLine(self.componentNames, function(index, componentName)
        return string.format("%s.%s = %s", self.fileName, componentName, index)
    end)

    self:WriteTemplate(Template.ComponentsLookupTemplate, {
        ModuleName = self.moduleName,
        ComponentCount = #self.componentNames,
        ComponentIndices = componentIndices
    })

    self:Close()
end

return ComponentsLookupWriter
