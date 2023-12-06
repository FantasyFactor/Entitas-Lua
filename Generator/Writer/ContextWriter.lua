local LuaFileWriter = require "Generator/Writer/LuaFileWriter"

local ContextWriter = Class("ContextWriter", LuaFileWriter)

function ContextWriter:Ctor(root, moduleName)
    self.name = string.format("%sContext", moduleName)
    self.entityName = string.format("%sEntity", moduleName)
    self.moduleName = moduleName
    self.componentInfos = {}
    self:Open(string.format("%s/%s/%s.lua", root, moduleName, self.name))
    self:PushRequire("Entitas/Context.lua")
end

function ContextWriter:PushComponentInfo(info)
    table.insert(self.componentInfos, info)
end

function ContextWriter:Flush()
    LuaFileWriter.Flush(self)
    self:WriteLineFormat("local %s = Class(\"%s\", Context)", self.name, self.name)
    self:WriteLine()

    self:WriteLineFormat("function %s.NewEntity()", self.name)
    self:WriteLineFormat("\treturn %s()", self.entityName)
    self:WriteLine("end")
    self:WriteLine()

    for _, componentInfo in ipairs(self.componentInfos) do
        self:WriteLineFormat("function %s:Get%sEntity()", self.name, componentInfo.name)
        self:WriteLineFormat("\treturn self:GetGroup(%sMatcher.Match%s()):GetSingleEntity()", self.moduleName, componentInfo.name)
        self:WriteLine("end")
        self:WriteLine()
        -------------------------------------------------------------------------------------------------
        self:WriteLineFormat("function %s:Get%s()", self.name, componentInfo.name)
        self:WriteLineFormat("\treturn self:Get%sEntity():Get%s()", componentInfo.name, componentInfo.name)
        self:WriteLine("end")
        self:WriteLine()
        -------------------------------------------------------------------------------------------------
        self:WriteLineFormat("function %s:Has%s()", self.name, componentInfo.name)
        self:WriteLineFormat("\treturn self:Get%sEntity() ~= nil", componentInfo.name)
        self:WriteLine("end")
        self:WriteLine()
        -------------------------------------------------------------------------------------------------
        for _, note in ipairs(componentInfo.notes) do
            self:WriteLine(note)
        end
        self:WriteLineFormat("function %s:Set%s(%s)", self.name, componentInfo.name, componentInfo.params)
        self:WriteLineFormat("\tif self:Has%s() then", componentInfo.name)
        self:WriteLineFormat("\t\t error(\"this context already has an entity with %s\")", componentInfo.name)
        self:WriteLineFormat("\tend")
        self:WriteLineFormat("\tlocal entity = self:CreateEntity()")
        self:WriteLineFormat("\tentity:Add%s(%s)", componentInfo.name, componentInfo.params)
        self:WriteLineFormat("\treturn entity")
        self:WriteLine("end")
        self:WriteLine()
        -------------------------------------------------------------------------------------------------
        for _, note in ipairs(componentInfo.notes) do
            self:WriteLine(note)
        end
        self:WriteLineFormat("function %s:Replace%s(%s)", self.name, componentInfo.name, componentInfo.params)
        self:WriteLineFormat("\tlocal entity = self:Get%sEntity()", componentInfo.name)
        self:WriteLineFormat("\tif entity == nil then")
        self:WriteLineFormat("\t\tentity = self:Set%s(%s)", componentInfo.name, componentInfo.params)
        self:WriteLine("\telse")
        self:WriteLineFormat("\t\tentity:Replace%s(%s)", componentInfo.name, componentInfo.params)
        self:WriteLine("\tend")
        self:WriteLine("end")
        self:WriteLine()
        -------------------------------------------------------------------------------------------------
        self:WriteLineFormat("function %s:Remove%s()", self.name, componentInfo.name)
        self:WriteLineFormat("\tself:Get%sEntity():Destroy()", componentInfo.name)
        self:WriteLine("end")
        self:WriteLine()
    end

    self:WriteLineFormat("return %s", self.name)
    self:Close()
end

return ContextWriter
