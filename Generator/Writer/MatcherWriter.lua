local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local Template = require "Generator/Template/Template"
local MatcherWriter = Class("MatcherWriter", LuaFileWriter)

function MatcherWriter:Ctor(root, moduleName)
    self.moduleName = moduleName
    self.componentNames = {}
    self:Open(string.format("%s/%s/%sMatcher.lua", root, moduleName, moduleName))

    self:PushRequire("Entitas/Matcher.lua")
end

function MatcherWriter:PushComponentName(name)
    table.insert(self.componentNames, name)
end

function MatcherWriter:Flush()
    LuaFileWriter.Flush(self)

    self:WriteTemplate(Template.MatcherTemplate, {
        Matchers = self:ConcatByLine(self.componentNames, function(_, componentName)
            local template = [[function ${FILE_NAME}.Match${ComponentName}()
    if not ${FILE_NAME}.${ComponentName}Matcher then
        ${FILE_NAME}.${ComponentName}Matcher = Matcher():AllOf(${ModuleName}ComponentsLookup.${ComponentName})
    end
    return ${FILE_NAME}.${ComponentName}Matcher
end
]]
            return Template.Generate(template, self.nameSpace, self.fileName, {
                ModuleName = self.moduleName,
                ComponentName = componentName,
            })
        end)
    })

    self:Close()
end

return MatcherWriter
