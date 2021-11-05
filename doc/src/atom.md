# MyTools.Atom

元素周期表相关函数。

## 简介

借助本库，你可以从任意名称构造元素，也可以从在元素的任意表示形式上做转换。

```@setup atom
push!(LOAD_PATH, "../../src/")
using MyTools.Atom
```

- 构建元素`struct`
```@example atom
Element("Fe")
```
```@example atom
Element("氦")
```

- 名称转换
```@example atom
getZ("溴")
```
```@example atom
chinese("Zr")
```
```@example atom
symbol(82)
```

## API列表

```@docs
Element
NoneElement
is_none
getZ(::ElementConstructType)
atomic_number
symbol
chinese
english
latin
pinyin
find_element_with_Z
find_element_with_symbol
find_element_with_chinese
find_element_with_english
find_element_with_latin
find_element_with_pinyin
find_element
```