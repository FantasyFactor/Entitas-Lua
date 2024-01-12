local LuaFileWriter = require "Generator/Writer/LuaFileWriter"
local Template = require "Generator/Template/Template"
local ContextWriter = Class("ContextWriter", LuaFileWriter)

function ContextWriter:Ctor(nameSpace, root, moduleName, enableUnityDebugger)
    self.moduleName = moduleName
    self.enableUnityDebugger = enableUnityDebugger
    self.componentInfos = {}
    self.entityIndexInfos = {}
    self:Open(string.format("%s/%s/%sContext.lua", root, moduleName, moduleName), nameSpace)
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
                fieldNames = {attribute.fieldName},
                isPrimary = attribute.attributes.PrimaryEntityIndex and true or false
            })
        end
    end
end

function ContextWriter:Flush()
    LuaFileWriter.Flush(self)

    local uniqueEntities = self:ConcatByLine(self.componentInfos, function(_, componentInfo)
        if componentInfo.unique then
            return Template.Generate(Template.UniqueEntityTemplate, self.nameSpace, self.fileName, {
                ModuleName = self.moduleName,
                ComponentName = componentInfo.name,
                Notes = self:ConcatByLine(componentInfo.notes),
                Params = componentInfo.params
            })
        end
        return ""
    end)

    local function getFullFieldKey(fieldNames)
        local key = ""
        for _, name in ipairs(fieldNames) do
            key = string.format("%s%s", key, UpperCaseFirst(name))
        end
        return key
    end

    local function getFieldKeys(fieldNames)
        local keys = ""
        for i, name in ipairs(fieldNames) do
            if i == 1 then
                keys = string.format("component.%s", name)
            else
                keys = string.format("%s, component.%s", keys, name)
            end
        end
        return keys
    end

    local function getReplace(attributeInfo)
        return {
            ComponentName = attributeInfo.componentName,
            FieldKey = string.format("%s%s", attributeInfo.componentName, getFullFieldKey(attributeInfo.fieldNames)),
            ModuleName = self.moduleName,
            FieldName = table.concat(attributeInfo.fieldNames, ", "),
            GetEntityFunc = attributeInfo.isPrimary and "GetEntity" or "GetEntities",
            EntityIndexCtor = attributeInfo.isPrimary and "PrimaryEntityIndex" or "EntityIndex",
            GetFieldKeys = getFieldKeys(attributeInfo.fieldNames)
        }
    end

    local addEntityIndexTemplate =
        "\tself:AddEntityIndex(${EntityIndexCtor}(\"${FieldKey}\", self:GetGroup(${ModuleName}Matcher.AnyOf(${ModuleName}ComponentsLookup.${ComponentName})), self.Get${FieldKey}Keys))"
    local addEntityIndex = self:ConcatByLine(self.entityIndexInfos, function(_, attributeInfo)
        return Template.Generate(addEntityIndexTemplate, self.nameSpace, self.fileName, getReplace(attributeInfo))
    end)

    local getEntityKeysTemplate = "function ${FILE_NAME}.Get${FieldKey}Keys(entity, component)\n\treturn {${GetFieldKeys}}\nend\n"
    local getEntityKeys = self:ConcatByLine(self.entityIndexInfos, function(_, attributeInfo)
        return Template.Generate(getEntityKeysTemplate, self.nameSpace, self.fileName, getReplace(attributeInfo))
    end)

    local getEntitiesTemplate =
        "function ${FILE_NAME}:${GetEntityFunc}With${FieldKey}(${FieldName})\n\treturn self:GetEntityIndex(\"${FieldKey}\"):${GetEntityFunc}(${FieldName})\nend\n"
    local getEntities = self:ConcatByLine(self.entityIndexInfos, function(_, attributeInfo)
        return Template.Generate(getEntitiesTemplate, self.nameSpace, self.fileName, getReplace(attributeInfo))
    end)

    local entityIndex = (next(self.entityIndexInfos) and Template.Generate(Template.EntityIndexTemplate, self.nameSpace, self.fileName, {
        AddEntityIndex = addEntityIndex,
        GetEntityKeys = getEntityKeys,
        GetEntities = getEntities
    }) or "")

    local createUnityObserver = ""

    if self.enableUnityDebugger then
        createUnityObserver = Template.Generate(Template.UnityContextObserverTemplate, self.nameSpace, self.fileName, {
            ModuleName = self.moduleName
        })
    end

    self:WriteTemplate(Template.ContextTemplate, {
        ModuleName = self.moduleName,
        CreateUnityObserver = createUnityObserver,
        UniqueEntities = uniqueEntities,
        EntityIndex = entityIndex
    })

    self:Close()
end

return ContextWriter
