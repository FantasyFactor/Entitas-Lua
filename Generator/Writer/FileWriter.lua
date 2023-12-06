local Template = require "Generator/Template/Template"
local FileWriter = Class("FileWriter")

function FileWriter:Open(path)
    self.path = path
    self.fileName = string.match(self.path, "/(%w+)%.+")
    self.fileStream = io.open(path, "w+")
end

function FileWriter:WriteLine(content)
    if content then
        self.fileStream:write(string.format("%s\n", content))
    else
        self.fileStream:write("\n")
    end
end

function FileWriter:WriteLineFormat(format, ...)
    self.fileStream:write(string.format("%s\n", string.format(format, ...)))
end

function FileWriter:WriteTemplate(template, replace)
    self:WriteLine(Template.Generate(template, self.fileName, replace))
end

function FileWriter:Close()
    self.fileStream:close()
end

return FileWriter