local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local Template = require "Generator/Template/Template"
local EntityWriter = Class("EntityWriter", LuaFileWriter)

function EntityWriter:Ctor(root, moduleName)
    self.moduleName = moduleName
    self.componentInfos = {}
    self.listenerInfos = {}
    self:Open(string.format("%s/%s/%sEntity.lua", root, moduleName, moduleName))
    self:PushRequire("Entitas/Entity.lua")
end

function EntityWriter:PushComponentInfo(info)
    table.insert(self.componentInfos, info)
end

function EntityWriter:PushListenerInfo(info)
    table.insert(self.listenerInfos, info)
end

function EntityWriter:Flush()
    LuaFileWriter.Flush(self)

    self:WriteTemplate(Template.EntityTemplate, {
        Components = self:ConcatByLine(self.componentInfos, function(_, componentInfo)
            return Template.Generate(Template.ComponentTemplate, self.fileName, {
                ModuleName = self.moduleName,
                ComponentName = componentInfo.name,
                Notes = self:ConcatByLine(componentInfo.notes),
                Params = componentInfo.params,
                FieldAssign = self:ConcatByLine(componentInfo.fieldAssigns, function(_, t)
                    local fieldName, newFieldName = unpack(t)
                    if fieldName and newFieldName then
                        return string.format("\tcomponent.%s = %s", fieldName, newFieldName)
                    end
                    return ""
                end)
            })
        end),
        Listeners = self:ConcatByLine(self.listenerInfos, function(_, listenerInfo)
            return Template.Generate(Template.EntityListenerTemplate, self.fileName, {
                ComponentName = listenerInfo.name
            })
        end),
    })

    self:Close()
end

return EntityWriter
