# MyTools.Nucleus

原子核物理相关工具函数。

## 同位素

```@docs
Isotope
getZ(::Isotope)
getN
getA
Base.show(::IO, ::MIME"text/plain", ::Isotope)
Base.show(::IO, ::MIME"text/markdown", ::Isotope)
Base.parse(::Type{Isotope}, ::AbstractString)
```

## 原子核单粒子轨道相关

```@docs
SingleParticleOrbit
JOrbit
MOrbit
MOrbit(::JOrbit, ::Integer)
name
Base.show(::IO, ::JOrbit)
NuclearShell
merge(::NuclearShell, ::NuclearShell)
j_orbits
m_orbits
jsize
msize
psize
nsize
m_config_size
HO_shell
HO_orbits
ValenceSpace
ValenceSpace(::Union{AbstractString, Isotope}, ::Union{NuclearShell, Vector{JOrbit}})
Isotope(::ValenceSpace, ::Integer, ::Integer)
Isotope(::Union{AbstractString, Isotope}, ::Integer, ::Integer)
valence
```

## 一些常数

壳模型常用空间。
```julia
s_shell::NuclearShell
p_shell::NuclearShell
sd_shell::NuclearShell
pf_shell::NuclearShell
```

常用价空间。与`NuclearShell`版本不同的是`ValenceSpace`版本还包含了核芯核子数的信息。
```julia
p_space::ValenceSpace
sd_space::ValenceSpace
pf_space::ValenceSpace
```