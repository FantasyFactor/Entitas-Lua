local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local Template = require "Generator/Template/Template"
local EventSystemsWriter = Class("EventSystemsWriter", LuaFileWriter)

function EventSystemsWriter:Ctor(nameSpace, root, moduleName)
    self.moduleName = moduleName
    self.eventInfos = {}
    self:Open(string.format("%s/%s/%sEventSystems.lua", root, moduleName, moduleName), nameSpace)
    self:PushRequire("Entitas/Systems.lua")
    self:PushRequire("Entitas/ReactiveSystem.lua")
end

function EventSystemsWriter:PushEventInfo(info)
    table.insert(self.eventInfos, info)
end

function EventSystemsWriter:Flush()
    LuaFileWriter.Flush(self)

    table.sort(self.eventInfos, function(lhs, rhs)
        if lhs.priority ~= rhs.priority then
            return lhs.priority > rhs.priority
        end
        return lhs.index < rhs.index
    end)

    self:WriteTemplate(Template.EventSystemsTemplate, {
        Systems = self:ConcatByLine(self.eventInfos, function(_, eventInfo)
            return Template.Generate(Template.EventSystemTemplate, self.nameSpace, string.format("%sEventSystem", eventInfo.name), {
                ModuleName = self.moduleName,
                ComponentName = eventInfo.name,
            })
        end),
        RegisterSystems = self:ConcatByLine(self.eventInfos, function(_, eventInfo)
            return string.format("\tself:Add(%sEventSystem(context))    --priority:%s", eventInfo.name, eventInfo.priority, {
                ModuleName = self.moduleName,
                ComponentName = eventInfo.name,
            })
        end)
    })

    self:Close()
end

return EventSystemsWriter
