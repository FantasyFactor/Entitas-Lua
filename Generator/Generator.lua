cwd = string.match(arg[0], "(.+)/.+.lua$")
package.path = string.format("%s;%s/?.lua", package.path, cwd)
package.path = string.format("%s;%s/../?.lua", package.path, cwd)

require "Generator/Class"
local ContextWriter = require "Generator/Writer/ContextWriter"
local EntityWriter = require "Generator/Writer/EntityWriter"
local MatcherWriter = require "Generator/Writer/MatcherWriter"
local ComponentsLookupWriter = require "Generator/Writer/ComponentsLookupWriter"
local ContextsWriter = require "Generator/Writer/ContextsWriter"

local function GetContext(...)
    local args = {...}
    local sourceRoot = args[1] -- Components所在目录
    local generateRoot = args[2] -- 生成的目标目录
    local scriptEntry = args[3] -- 生成的Lua脚本入口

    package.path = string.format("%s;%s/?.lua", package.path, sourceRoot)

    local moduleInfos = {}
    for i = 4, #args do
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
        generateRoot = generateRoot,
        scriptEntry = scriptEntry ~= "" and scriptEntry,
        moduleInfos = moduleInfos
    }
end

local function Generate(context)
    local generateRoot = context.generateRoot

    if not generateRoot then
        error("Please input generate root")
        return
    end
    local contextsWriter = ContextsWriter(generateRoot)
    for moduleName, components in pairs(context.moduleInfos) do
        contextsWriter:PushModuleName(moduleName)
        os.execute(string.format("mkdir %s\\%s", string.gsub(generateRoot, "/", "\\"), moduleName))
        local contextWriter = ContextWriter(generateRoot, moduleName)
        local entityWriter = EntityWriter(generateRoot, moduleName)
        local componentsLookupWriter = ComponentsLookupWriter(generateRoot, moduleName)
        local matcherWriter = MatcherWriter(generateRoot, moduleName)
        local hasUnique = false
        local hasAttribute = false
        for _, componentInfos in ipairs(components) do
            local name, unique, data = unpack(componentInfos)
            local info = GenerateComponentInfo(name, unique, data)
            if unique then
                contextWriter:PushComponentInfo(info)
                hasUnique = true
            elseif next(info.attributes) then
                contextWriter:PushComponentInfo(info)
                hasAttribute = true
            end
            entityWriter:PushComponentInfo(info)
            componentsLookupWriter:PushComponentName(name)
            matcherWriter:PushComponentName(name)
        end

        matcherWriter:PushRequire(componentsLookupWriter.path, context.scriptEntry)
        entityWriter:PushRequire(componentsLookupWriter.path, context.scriptEntry)
        contextWriter:PushRequire(componentsLookupWriter.path, context.scriptEntry)
        contextWriter:PushRequire(entityWriter.path, context.scriptEntry)
        if hasUnique or hasAttribute then
            contextWriter:PushRequire(matcherWriter.path, context.scriptEntry)
        end
        contextsWriter:PushRequire(contextWriter.path, context.scriptEntry)
        contextsWriter:PushRequire(entityWriter.path, context.scriptEntry)

        contextWriter:Flush()
        entityWriter:Flush()
        componentsLookupWriter:Flush()
        matcherWriter:Flush()
    end
    contextsWriter:Flush()
end

function GenerateComponentInfo(name, unique, data)
    local info = {
        name = name, -- component name
        unique = unique,
        notes = {},
        assigns = {},   -- {{ fieldName, attributes = {[attributeName] = true }}
        attributes = {},
        params = "" -- all component fields
    }

    for _, field in ipairs(data) do
        local fieldName, fieldTypeName, note, attributes = unpack(field)
        local newFieldName = string.format("new%s", UpperCaseFirst(fieldName))
        table.insert(info.assigns, {fieldName, newFieldName})
        table.insert(info.notes, string.format("---@param %s %s %s", newFieldName, fieldTypeName, note))
        if attributes then
            local attributeDict = {}
            for _, attributeName in ipairs(attributes) do
                attributeDict[attributeName] = true
            end
            table.insert(info.attributes, {
                fieldName = fieldName,
                attributes = attributeDict
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

local context = GetContext(...)
Generate(context)

print(string.format("Generate Success"))
