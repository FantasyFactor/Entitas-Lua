local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local Template = require "Generator/Template/Template"
local ContextWriter = Class("ContextWriter", LuaFileWriter)

function ContextWriter:Ctor(root, moduleName)
    self.moduleName = moduleName
    self.componentInfos = {}
    self.entityIndexInfos = {}
    self:Open(string.format("%s/%s/%sContext.lua", root, moduleName, moduleName))
    self:PushRequire("Entitas/Context.lua")
    self:PushRequire("Entitas/EntityIndex.lua")
    self:PushRequire("Entitas/PrimaryEntityIndex.lua")
end

function ContextWriter:PushComponentInfo(info)
    table.insert(self.componentInfos, info)
    for _, attribute in ipairs(info.fieldAttributes) do
        if attribute.attributes.EntityIndex or attribute.attributes.PrimaryEntityIndex then
            table.insert(self.entityIndexInfos, {
                componentName = info.name,
                fieldName = attribute.fieldName,
                isPrimary = attribute.attributes.PrimaryEntityIndex
            })
        end
    end
end

function ContextWriter:Flush()
    LuaFileWriter.Flush(self)

    local uniqueEntities = self:ConcatByLine(self.componentInfos, function(_, componentInfo)
        if componentInfo.unique then
            return Template.Generate(Template.UniqueEntityTemplate, self.fileName, {
                ModuleName = self.moduleName,
                ComponentName = componentInfo.name,
                Notes = self:ConcatByLine(componentInfo.notes),
                Params = componentInfo.params
            })
        end
        return ""
    end)

    local function getReplace(attributeInfo)
        return {
            ComponentName = attributeInfo.componentName,
            FieldKey = string.format("%s%s", attributeInfo.componentName, UpperCaseFirst(attributeInfo.fieldName)),
            ModuleName = self.moduleName,
            FieldName = attributeInfo.fieldName,
            GetEntityFunc = attributeInfo.isPrimary and "GetEntity" or "GetEntities",
            EntityIndexCtor = attributeInfo.isPrimary and "PrimaryEntityIndex" or "EntityIndex",
        }
    end

    local addEntityIndexTemplate =
        "\tself:AddEntityIndex(${EntityIndexCtor}(\"${FieldKey}\", self:GetGroup(${ModuleName}Matcher.AnyOf(${ModuleName}ComponentsLookup.${ComponentName})), self.Get${FieldKey}Keys))"
    local addEntityIndex = self:ConcatByLine(self.entityIndexInfos, function(_, attributeInfo)
        return Template.Generate(addEntityIndexTemplate, self.fileName, getReplace(attributeInfo))
    end)

    local getEntityKeysTemplate =
        "function ${FILE_NAME}.Get${FieldKey}Keys(entity)\n\treturn {entity:GetComponent(${ModuleName}ComponentsLookup.${ComponentName}).${FieldName}}\nend\n"
    local getEntityKeys = self:ConcatByLine(self.entityIndexInfos, function(_, attributeInfo)
        return Template.Generate(getEntityKeysTemplate, self.fileName, getReplace(attributeInfo))
    end)

    local getEntitiesTemplate =
        "function ${FILE_NAME}:${GetEntityFunc}With${FieldKey}(${FieldName})\n\treturn self:GetEntityIndex(\"${FieldKey}\"):${GetEntityFunc}(${FieldName})\nend\n"
    local getEntities = self:ConcatByLine(self.entityIndexInfos, function(_, attributeInfo)
        return Template.Generate(getEntitiesTemplate, self.fileName, getReplace(attributeInfo))
    end)

    local entityIndex = (next(self.entityIndexInfos) and Template.Generate(Template.EntityIndexTemplate, self.fileName, {
        AddEntityIndex = addEntityIndex,
        GetEntityKeys = getEntityKeys,
        GetEntities = getEntities
    }) or "")

    self:WriteTemplate(Template.ContextTemplate, {
        ModuleName = self.moduleName,
        UniqueEntities = uniqueEntities,
        EntityIndex = entityIndex
    })

    self:Close()
end

return ContextWriter
