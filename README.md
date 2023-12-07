# Entitas-Lua
基于Entitas开发的Lua版本


# 组件
- [x] Entity
- [x] Matcher
- [x] Group
- [x] Collector
- [x] Context
- [x] Systems
- [x] EntityIndex
- [x] AERC
- [x] ReactiveSystem






# 代码生成器
通过使用lua执行Generator.lua并传入参数或者直接执行generate.bat即可根据路径参数生成Entitas代码
### 组件目录结构必须遵循：
#### 组件根目录 - 模块目录 - 模块组件集合.lua
### 组件定义
每个组件定义为一个数组：[组件名, 是否唯一, 字段数组]</br>
字段数组：[字段名, 字段类型名, 生成注释]
```
local Color = {"Color", false, {
    {"r", "number", "r通道"},
    {"g", "number", "g通道"},
    {"b", "number", "b通道"},
    {"a", "number", "a通道"},
}}

local View = {"View", false, {
    {"gameObject", "userdata", "GameObject"},
}}

return {Color, View}
```


