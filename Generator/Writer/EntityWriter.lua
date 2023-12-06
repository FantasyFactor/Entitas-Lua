local LuaFileWriter = require "Generator/Writer/LuaFileWriter"

local EntityWriter = Class("EntityWriter", LuaFileWriter)

function EntityWriter:Ctor(root, moduleName)
    self.name = string.format("%sEntity", moduleName)
    self.moduleName = moduleName
    self.componentInfos = {}
    self:Open(string.format("%s/%s/%s.lua", root, moduleName, self.name))
    self:PushRequire("Entitas/Entity.lua")
end

function EntityWriter:PushComponentInfo(info)
    table.insert(self.componentInfos, info)
end

function EntityWriter:Flush()
    LuaFileWriter.Flush(self)
    self:WriteLineFormat("local %s = Class(\"%s\", Entity)", self.name, self.name)
    self:WriteLine()

    for _, componentInfo in ipairs(self.componentInfos) do
        local lookUpName = string.format("%sComponentsLookup.%s", self.moduleName, componentInfo.name)
        -------------------------------------------------------------------------------------------------
        self:WriteLineFormat("function %s:Get%s()", self.name, componentInfo.name)
        self:WriteLineFormat("\treturn self:GetComponent(%s)", lookUpName)
        self:WriteLine("end")
        self:WriteLine()
        -------------------------------------------------------------------------------------------------
        self:WriteLineFormat("function %s:Has%s()", self.name, componentInfo.name)
        self:WriteLineFormat("\tself:HasComponent(%s)", lookUpName)
        self:WriteLine("end")
        self:WriteLine()
        -------------------------------------------------------------------------------------------------
        for _, note in ipairs(componentInfo.notes) do
            self:WriteLine(note)
        end
        self:WriteLineFormat("function %s:Add%s(%s)", self.name, componentInfo.name, componentInfo.params)
        self:WriteLineFormat("\tlocal component = self:CreateComponent(%s)", lookUpName)
        self:WriteLineFormat("\tself:AddComponent(%s, component)", lookUpName)
        self:WriteLine("end")
        self:WriteLine()
        -------------------------------------------------------------------------------------------------
        for _, note in ipairs(componentInfo.notes) do
            self:WriteLine(note)
        end
        self:WriteLineFormat("function %s:Replace%s(%s)", self.name, componentInfo.name, componentInfo.params)
        self:WriteLineFormat("\tlocal component = self:CreateComponent(%s)", lookUpName)
        self:WriteLineFormat("\tself:ReplaceComponent(%s, component)", lookUpName)
        self:WriteLine("end")
        self:WriteLine()
        -------------------------------------------------------------------------------------------------
        self:WriteLineFormat("function %s:Remove%s()", self.name, componentInfo.name)
        self:WriteLineFormat("\tself:ReplaceComponent(%s)", lookUpName)
        self:WriteLine("end")
        self:WriteLine()
    end

    self:WriteLineFormat("return %s", self.name)
    self:Close()
end

return EntityWriter
