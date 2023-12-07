local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local Template = require "Generator/Template/Template"
local ContextsWriter = Class("ContextsWriter", LuaFileWriter)

function ContextsWriter:Ctor(root)
    self.moduleNames = {}
    self:Open(string.format("%s/Contexts.lua", root))
    self:PushRequireLib("Core/Singleton")
end

function ContextsWriter:PushModuleName(name)
    table.insert(self.moduleNames, name)
end

function ContextsWriter:Flush()
    LuaFileWriter.Flush(self)

    local createContexts = self:ConcatByLine(self.moduleNames, function(_, moduleName)
        return string.format("\tself.%s = %sContext(1, %sContext.NewEntity)", string.lower(moduleName), moduleName, moduleName)
    end)

    local resetContexts = self:ConcatByLine(self.moduleNames, function(_, moduleName)
        return string.format("\tself.%s:Reset()", string.lower(moduleName))
    end)

    self:WriteTemplate(Template.ContextsTemplate, {
        CreateContexts = createContexts,
        ResetContexts = resetContexts
    })
    self:Close()
end

return ContextsWriter
