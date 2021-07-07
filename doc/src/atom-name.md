# MyTools.AtomName

原子核名称

## 元素周期表

```@docs
Element
NoneElement
is_none
Z(::Element)
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

## 原子核

```@docs
Isotope
NuclearShell
Z(::Isotope)
N
A
Base.show(::IO, ::MIME"text/plain", ::Isotope)
Base.show(::IO, ::MIME"text/markdown", ::Isotope)
isotope
m_config_size
Base.parse(::Type{Isotope}, ::AbstractString)
m_config_size
valence
```
