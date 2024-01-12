local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local Template = require "Generator/Template/Template"
local ContextsWriter = Class("ContextsWriter", LuaFileWriter)

function ContextsWriter:Ctor(nameSpace, root, enableUnityDebugger)
    self.moduleNames = {}
    self.enableUnityDebugger = enableUnityDebugger
    self:Open(string.format("%s/Contexts.lua", root), nameSpace)
    self:PushRequireLib("Core/Singleton")
end

function ContextsWriter:PushModuleName(name)
    table.insert(self.moduleNames, name)
end

function ContextsWriter:Flush()
    LuaFileWriter.Flush(self)

    local createContexts = self:ConcatByLine(self.moduleNames, function(_, moduleName)
        return string.format("\tself.%s = %sContext(1, %sEntity)", string.lower(moduleName), moduleName, moduleName)
    end)

    local resetContexts = self:ConcatByLine(self.moduleNames, function(_, moduleName)
        return string.format("\tself.%s:Reset()", string.lower(moduleName))
    end)

    local createContextObservers = ""
    local destroyContextObservers = ""
    if self.enableUnityDebugger then
        createContextObservers = self:ConcatByLine(self.moduleNames, function(_, moduleName)
            local lowerModuleName = string.lower(moduleName)
            return string.format("\tself.%s:CreateObserver()", lowerModuleName)
        end)
        destroyContextObservers = self:ConcatByLine(self.moduleNames, function(_, moduleName)
            local lowerModuleName = string.lower(moduleName)
            return string.format("\tself.%s:DestroyObserver()", lowerModuleName)
        end)
    end

    self:WriteTemplate(Template.ContextsTemplate, {
        CreateContexts = createContexts,
        ResetContexts = resetContexts,
        CreateContextObservers = createContextObservers,
        DestroyContextObservers = destroyContextObservers
    })
    self:Close()
end

return ContextsWriter
