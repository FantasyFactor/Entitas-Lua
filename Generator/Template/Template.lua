local Template = {}

Template.FILE_NAME_PLACE_HOLDER = "FILE_NAME"

setmetatable(Template, {
    __index = function(t, k)
        local f, err = io.open(string.format("%s/Template/%s.txt", cwd, k))
        assert(f, err)
        t[k] = f:read("*a")
        f:close()
        return rawget(t, k)
    end
})

function Template.Generate(template, fileName, replace)
    replace = replace or {}
    replace[Template.FILE_NAME_PLACE_HOLDER] = fileName
    return string.gsub(template, "%${([%w_]+)}", replace)
end

return Template
