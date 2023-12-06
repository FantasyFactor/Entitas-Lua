require "Core/Class"
local ContextWriter = require "Generator/Writer/ContextWriter"
local EntityWriter = require "Generator/Writer/EntityWriter"
local MatcherWriter = require "Generator/Writer/MatcherWriter"
local ComponentsLookupWriter = require "Generator/Writer/ComponentsLookupWriter"
local ContextsWriter = require "Generator/Writer/ContextsWriter"

function GetArgs(...)
    local arg = {...}

    local cwd = arg[1]
    local sourceRoot = arg[2]
    local generateRoot = arg[3]

    local moduleInfos = {}
    for i = 4, #arg do
        if arg[i] and arg[i] ~= "" then
            local shortPath = string.sub(arg[i], #cwd + 1 + #sourceRoot + 1)
            local module, name = string.match(shortPath, "(%w+)\\(%w+)$")
            if module then
                if not moduleInfos[module] then
                    moduleInfos[module] = {
                        path = string.sub(arg[i], #cwd + 1),
                        module = module
                    }
                end
            end
        end
    end

    return {
        generateRoot = generateRoot,
        moduleInfos = moduleInfos
    }
end

function Generate(args)
    local generateRoot = args.generateRoot

    if not generateRoot then
        error("Please input generate root")
        return
    end

    local contextsWriter = ContextsWriter(generateRoot)
    for moduleName, moduleInfo in pairs(args.moduleInfos) do
        contextsWriter:PushModuleName(moduleName)
        os.execute(string.format("mkdir %s\\%s", generateRoot, moduleName))
        local contextWriter = ContextWriter(generateRoot, moduleName)
        local entityWriter = EntityWriter(generateRoot, moduleName)
        local componentsLookupWriter = ComponentsLookupWriter(generateRoot, moduleName)
        local matcherWriter = MatcherWriter(generateRoot, moduleName)
        local components = require(moduleInfo.path)
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

        matcherWriter:PushRequire(componentsLookupWriter.path)
        entityWriter:PushRequire(componentsLookupWriter.path)
        contextWriter:PushRequire(entityWriter.path)
        if hasUnique then
            contextWriter:PushRequire(matcherWriter.path)
        end
        contextsWriter:PushRequire(contextWriter.path)

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
        params = "" -- all component fields
    }

    for _, field in ipairs(data) do
        local fieldName, fieldTypeName, note, initValue = unpack(field)
        local newFieldName = string.format("new%s%s", string.char(string.byte(fieldName, 1, 1) - 32), string.sub(fieldName, 2))
        table.insert(info.notes, string.format("---@param %s %s %s", newFieldName, fieldTypeName, note))
        if info.params == "" then
            info.params = newFieldName
        else
            info.params = string.format("%s, %s", info.params, newFieldName)
        end
    end

    return info
end

local args = GetArgs(...)
Generate(args)