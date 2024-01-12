cwd = string.match(arg[0], "(.+)/.+.lua$")
package.path = string.format("%s;%s/?.lua", package.path, cwd)
package.path = string.format("%s;%s/../?.lua", package.path, cwd)

require "Generator/Class"
local ContextWriter = require "Generator/Writer/ContextWriter"
local EntityWriter = require "Generator/Writer/EntityWriter"
local MatcherWriter = require "Generator/Writer/MatcherWriter"
local ComponentsLookupWriter = require "Generator/Writer/ComponentsLookupWriter"
local ContextsWriter = require "Generator/Writer/ContextsWriter"
local EventSystemsWriter = require "Generator/Writer/EventSystemsWriter"

local function GetContext(...)
    local args = {...}
    local nameSpace = args[1]
    local sourceRoot = args[2] -- Components所在目录
    local generateRoot = args[3] -- 生成的目标目录
    local scriptEntry = args[4] -- 生成的Lua脚本入口
    local generateContexts = args[5] -- 是否生成Contexts
    local enableUnityDebugger = args[6] -- 是否启用Unity调试接口
    package.path = string.format("%s;%s/?.lua", package.path, sourceRoot)

    local moduleInfos = {}
    for i = 7, #args do
        if args[i] and args[i] ~= "" then
            local module, name = string.match(args[i], "(%w+)\\(%w+)$")
            if module then
                if not moduleInfos[module] then
                    moduleInfos[module] = require(string.format("%s/%s", module, name))
                end
            end
        end
    end
    return {
        nameSpace = nameSpace,
        generateRoot = generateRoot,
        scriptEntry = scriptEntry ~= "" and scriptEntry,
        moduleInfos = moduleInfos,
        generateContexts = generateContexts == "1",
        enableUnityDebugger = enableUnityDebugger == "1"
    }
end

local function GenerateAttributes(list)
    local attributes = {}
    if list then
        for _, args in ipairs(list) do
            local t = type(args)
            if t == "table" and args[1] then
                local name = table.remove(args, 1)
                attributes[name] = args
            elseif t == "string" then
                attributes[args] = {}
            else
                error("Unsupport param")
            end
        end
    end
    return attributes
end

local function GenerateComponentInfo(name, unique, data, attributes)
    local info = {
        name = name, -- component name
        unique = unique,
        notes = {},
        fieldAssigns = {}, --[[fieldName, newFieldName]]
        fieldAttributes = {}, -- [{ fieldName : string; attributes : {[attributeName : string] : [attributeName, param...]}]
        componentAttributes = GenerateAttributes(attributes), -- {[attributeName : string] : [attributeName, param...]}
        params = "" -- all component fields
    }

    for _, field in ipairs(data) do
        local fieldName, fieldTypeName, note, fieldAttributes = unpack(field)
        local newFieldName = string.format("new%s", UpperCaseFirst(fieldName))
        table.insert(info.fieldAssigns, {fieldName, newFieldName})
        table.insert(info.notes, string.format("---@param %s %s %s", newFieldName, fieldTypeName, note))
        if fieldAttributes then
            table.insert(info.fieldAttributes, {
                fieldName = fieldName,
                attributes = GenerateAttributes(fieldAttributes)
            })
        end
        if info.params == "" then
            info.params = newFieldName
        else
            info.params = string.format("%s, %s", info.params, newFieldName)
        end
    end

    return info
end

local function GenerateComponent(context, componentIndex, componentInfos)
    local name, unique, data, attributes = unpack(componentInfos)
    local info = GenerateComponentInfo(name, unique, data, attributes)
    if unique then
        context.contextWriter:PushComponentInfo(info)
        context.hasUnique = true
    elseif next(info.fieldAttributes) then
        context.contextWriter:PushComponentInfo(info)
        context.hasAttribute = true
    end
    context.entityWriter:PushComponentInfo(info)
    context.componentsLookupWriter:PushComponentName(name)
    context.matcherWriter:PushComponentName(name)
    if next(info.componentAttributes) then
        if info.componentAttributes.Event then
            local priority = unpack(info.componentAttributes.Event)
            local eventInfo = {
                name = name,
                priority = priority or 0,
                index = componentIndex
            }
            if not context.eventSystemsWriter then
                context.eventSystemsWriter = EventSystemsWriter(context.nameSpace, context.generateRoot, context.moduleName)
            end
            context.eventSystemsWriter:PushEventInfo(eventInfo)
            local listenerName = string.format("%sListener", name)
            context.entityWriter:PushComponentInfo(GenerateComponentInfo(listenerName, false, {{"listeners", "table", ""}}))
            context.entityWriter:PushListenerInfo({
                name = name
            })
            context.componentsLookupWriter:PushComponentName(listenerName)
        end
    end
end

local function Generate(context)
    local generateRoot = context.generateRoot

    if not generateRoot then
        error("Please input generate root")
        return
    end
    if context.generateContexts then
        context.contextsWriter = ContextsWriter(context.nameSpace, generateRoot, context.enableUnityDebugger)
    end
    context.eventSystemsWriter = nil
    for moduleName, components in pairs(context.moduleInfos) do
        os.execute(string.format("mkdir %s\\%s", string.gsub(generateRoot, "/", "\\"), moduleName))
        context.hasUnique = false
        context.hasAttribute = false
        context.contextWriter = ContextWriter(context.nameSpace, generateRoot, moduleName, context.enableUnityDebugger)
        context.entityWriter = EntityWriter(context.nameSpace, generateRoot, moduleName)
        context.componentsLookupWriter = ComponentsLookupWriter(generateRoot, moduleName)
        context.matcherWriter = MatcherWriter(generateRoot, moduleName)
        context.moduleName = moduleName

        for componentIndex, componentInfos in ipairs(components) do
            GenerateComponent(context, componentIndex, componentInfos)
        end

        context.matcherWriter:PushRequire(context.componentsLookupWriter.path, context.scriptEntry)
        context.entityWriter:PushRequire(context.componentsLookupWriter.path, context.scriptEntry)
        context.contextWriter:PushRequire(context.componentsLookupWriter.path, context.scriptEntry)
        context.contextWriter:PushRequire(context.entityWriter.path, context.scriptEntry)
        if context.hasUnique or context.hasAttribute then
            context.contextWriter:PushRequire(context.matcherWriter.path, context.scriptEntry)
        end
        if context.contextsWriter then
            context.contextsWriter:PushModuleName(moduleName)
            context.contextsWriter:PushRequire(context.contextWriter.path, context.scriptEntry)
            context.contextsWriter:PushRequire(context.entityWriter.path, context.scriptEntry)
        end
        context.contextWriter:Flush()
        context.entityWriter:Flush()
        context.componentsLookupWriter:Flush()
        context.matcherWriter:Flush()

        if context.eventSystemsWriter then
            context.eventSystemsWriter:PushRequire(context.matcherWriter.path, context.scriptEntry)
        end
    end
    if context.contextsWriter then
        context.contextsWriter:Flush()
    end
    if context.eventSystemsWriter then
        context.eventSystemsWriter:Flush()
    end
end

function Split(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for s in string.gmatch(str, string.format("([^%s]+)", sep)) do
        table.insert(t, s)
    end
    return t
end

function UpperCaseFirst(str)
    local firstChar = string.byte(str, 1, 1)
    if firstChar >= 97 and firstChar <= 122 then
        return string.format("%s%s", string.char(firstChar - 32), string.sub(str, 2))
    end
    return str
end

function LowerCaseFirst(str)
    local firstChar = string.byte(str, 1, 1)
    if firstChar >= 65 and firstChar <= 90 then
        return string.format("%s%s", string.char(firstChar + 32), string.sub(str, 2))
    end
    return str
end

local context = GetContext(...)
Generate(context)

print(string.format("Generate Success"))
