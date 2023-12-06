local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local ContextsWriter = Class("ContextsWriter", LuaFileWriter)

function ContextsWriter:Ctor(root)
    self.name = "Contexts"
    self.moduleNames = {}
    self:Open(string.format("%s/%s.lua", root, self.name))
    self:PushRequire("Core/Singleton.lua")
end

function ContextsWriter:PushModuleName(name)
    table.insert(self.moduleNames, name)
end

function ContextsWriter:Flush()
    LuaFileWriter.Flush(self)
    self:WriteLineFormat("local %s = Singleton(\"%s\")", self.name, self.name)
    self:WriteLine()
    self:WriteLineFormat("function %s:Init()", self.name)
    for _, moduleName in ipairs(self.moduleNames) do
        self:WriteLineFormat("\tself.%s = %sContext(1, %sContext.NewEntity)", string.lower(moduleName), moduleName, moduleName)
    end
    self:WriteLine("end")
    self:WriteLine()

    self:WriteLineFormat("function %s:Reset()", self.name)
    for _, moduleName in ipairs(self.moduleNames) do
        self:WriteLineFormat("\tself.%s:Reset()", string.lower(moduleName))
    end
    self:WriteLine("end")
    self:WriteLine()

    self:WriteLineFormat("return %s", self.name)
    self:Close()
end

return ContextsWriter
