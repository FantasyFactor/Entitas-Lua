local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local Template = require "Generator/Template/Template"
local ContextWriter = Class("ContextWriter", LuaFileWriter)

function ContextWriter:Ctor(root, moduleName)
    self.moduleName = moduleName
    self.componentInfos = {}
    self:Open(string.format("%s/%s/%sContext.lua", root, moduleName, moduleName))
    self:PushRequire("Entitas/Context.lua")
end

function ContextWriter:PushComponentInfo(info)
    table.insert(self.componentInfos, info)
end

function ContextWriter:Flush()
    LuaFileWriter.Flush(self)

    local uniqueEntities = self:ConcatByLine(self.componentInfos, function(_, componentInfo)
        return Template.Generate(Template.UniqueEntityTemplate, self.fileName, {
            ModuleName = self.moduleName,
            ComponentName = componentInfo.name,
            Notes = self:ConcatByLine(componentInfo.notes),
            Params = componentInfo.params
        })
    end)

    self:WriteTemplate(Template.ContextTemplate, {
        ModuleName = self.moduleName,
        UniqueEntities = uniqueEntities
    })

    self:Close()
end

return ContextWriter
