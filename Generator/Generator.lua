cwd = string.match(arg[0], "(.+)/.+.lua$")
package.path = string.format("%s;%s/?.lua", package.path, cwd)
package.path = string.format("%s;%s/../?.lua", package.path, cwd)

require "Generator/Class"
local ContextWriter = require "Generator/Writer/ContextWriter"
local EntityWriter = require "Generator/Writer/EntityWriter"
local MatcherWriter = require "Generator/Writer/MatcherWriter"
local ComponentsLookupWriter = require "Generator/Writer/ComponentsLookupWriter"
local ContextsWriter = require "Generator/Writer/ContextsWriter"

function GetContext(...)
    local args = {...}
    local sourceRoot = args[1]       --Components所在目录
    local generateRoot = args[2]     --生成的目标目录
    local scriptEntry = args[3]      --生成的Lua脚本入口

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

function Generate(context)
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
        for _, componentInfos in ipairs(components) do
            local name, unique, data = unpack(componentInfos)
            if unique then
                contextWriter:PushComponentInfo(GenerateComponentInfo(name, data))
                hasUnique = true
            end
            entityWriter:PushComponentInfo(GenerateComponentInfo(name, data))
            componentsLookupWriter:PushComponentName(name)
            matcherWriter:PushComponentName(name)
        end

        matcherWriter:PushRequire(componentsLookupWriter.path, context.scriptEntry)
        entityWriter:PushRequire(componentsLookupWriter.path, context.scriptEntry)
        contextWriter:PushRequire(entityWriter.path, context.scriptEntry)
        if hasUnique then
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

function GenerateComponentInfo(name, data)
    local info = {
        name = name, -- component name
        notes = {},
        assigns = {},
        params = "" -- all component fields
    }

    for _, field in ipairs(data) do
        local fieldName, fieldTypeName, note, initValue = unpack(field)
        local newFieldName = string.format("new%s%s", string.char(string.byte(fieldName, 1, 1) - 32), string.sub(fieldName, 2))
        table.insert(info.assigns, {fieldName, newFieldName})
        table.insert(info.notes, string.format("---@param %s %s %s", newFieldName, fieldTypeName, note))
        if info.params == "" then
            info.params = newFieldName
        else
            info.params = string.format("%s, %s", info.params, newFieldName)
        end
    end

    return info
end

local context = GetContext(...)
Generate(context)

print(string.format("Generate Success"))