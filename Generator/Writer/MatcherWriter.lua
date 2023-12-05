local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local MatcherWriter = Class("MatcherWriter", LuaFileWriter)

function MatcherWriter:Ctor(root, moduleName)
    self.name = string.format("%sMatcher", moduleName)
    self.moduleName = moduleName
    self.componentNames = {}
    self:Open(string.format("%s/%s/%s.lua", root, moduleName, self.name))

    self:PushRequire("Entitas/Matcher.lua")
end

function MatcherWriter:PushComponentName(name)
    table.insert(self.componentNames, name)
end

function MatcherWriter:Flush()
    LuaFileWriter.Flush(self)
    self:WriteLineFormat("local %s = {}", self.name)
    self:WriteLine()

    self:WriteLineFormat("function %s.AllOf(...)", self.name)
    self:WriteLineFormat("\treturn Matcher():AllOf(...)")
    self:WriteLine("end")
    self:WriteLine()

    self:WriteLineFormat("function %s.AnyOf(...)", self.name)
    self:WriteLineFormat("\treturn Matcher():AnyOf(...)")
    self:WriteLine("end")
    self:WriteLine()

    for _, componentName in pairs(self.componentNames) do
        self:WriteLineFormat("function %s.Match%s()", self.name, componentName)
        self:WriteLineFormat("\tif not %s.%sMatcher then", self.name, componentName)
        self:WriteLineFormat("\t\t %s.%sMatcher = Matcher():AllOf(%sComponentsLookup.%s)", self.name, componentName, self.moduleName, componentName)
        self:WriteLine("\tend")
        self:WriteLineFormat("\treturn %s.%sMatcher", self.name, componentName)
        self:WriteLine("end")
        self:WriteLine()
    end

    self:WriteLineFormat("return %s", self.name)
    
    self:Close()
end

return MatcherWriter
