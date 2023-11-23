luaunit  = require('luaunit')

package.path = package.path .. ";?.lua"

function TestHelloWorld()
    print("HelloWorld") 
end

os.exit(luaunit.LuaUnit.run())