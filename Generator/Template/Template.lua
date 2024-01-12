local Template = {}

Template.FILE_NAME_PLACEHOLDER = "FILE_NAME"
Template.NAME_SPACE_PLACEHOLDER = "NAME_SPACE"

setmetatable(Template, {
    __index = function(t, k)
        local f, err = io.open(string.format("%s/Template/%s.txt", cwd, k))
        assert(f, err)
        t[k] = f:read("*a")
        f:close()
        return rawget(t, k)
    end
})

function Template.Generate(template, nameSpace, fileName, replace)
    replace = replace or {}
    replace[Template.FILE_NAME_PLACEHOLDER] = fileName
    replace[Template.NAME_SPACE_PLACEHOLDER] = nameSpace
    return string.gsub(template, "%${([%w_]+)}", replace)
end

return Template
