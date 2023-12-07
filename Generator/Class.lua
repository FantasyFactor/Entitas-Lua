--面向对象的极简实现
function Class(className, super)
    local class = {}
    class.className = className
    class.super = super
    setmetatable(class, {
        __call = function(self, ...)
            local instance = {}
            setmetatable(instance, {
                __index = self
            })
            if instance.Ctor then
                instance:Ctor(...)
            end
            return instance
        end,
        __index = class.super
    })
    return class
end