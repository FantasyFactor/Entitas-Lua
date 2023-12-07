local FileWriter = require "Generator/Writer/FileWriter"
local LuaFileWriter = Class("LuaFileWriter", FileWriter)

--- 局部的依赖引入
---@param path string
---@param scriptEntry string
function LuaFileWriter:PushRequire(path, scriptEntry)
    if not self.requires then
        self.requires = {}
    end
    if scriptEntry then
        path = string.gsub(path, scriptEntry, "")
    end
    table.insert(self.requires, path)
end

--- 全局的静态库引入
---@param path string
function LuaFileWriter:PushRequireLib(path)
    if not self.libs then
        self.libs = {}
    end
    table.insert(self.libs, path)
end

function LuaFileWriter:ConcatByLine(t, get)
    local content = ""
    for i, v in ipairs(t) do
        local s = get and get(i, v) or tostring(v)
        if content == "" then
            content = s
        else
            content = string.format("%s\n%s", content, s)
        end
    end
    return content
end

function LuaFileWriter:Flush()
    if self.libs then
        for _, path in ipairs(self.libs) do
            self:WriteLineFormat("require \"%s\"", path)
        end
    end

    if self.requires then
        for _, path in ipairs(self.requires) do
            local name = string.match(path, "/(%w+).lua$")
            if name then
                self:WriteLineFormat("local %s = require \"%s\"", name, string.sub(path, 1, #path - 4))
            end
        end
    end
end

return LuaFileWriter
