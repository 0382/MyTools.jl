# @author:      0.382
# @description: 原子核相关的
# 

# -------------------
# 同位素部分
# -------------------

"""
    struct Isotope
        Z::Int
        N::Int
    end
同位素。构造函数：
```julia
Isotope(iso::Isotope)
Isotope(Z::Integer, N::Integer)
Isotope(name::AbstractString)
```
"""
struct Isotope
    Z::Int
    N::Int
    Isotope(Z::Integer, N::Integer) = new(Z, N)
end

Isotope(iso::Isotope) = iso
Isotope(name::AbstractString) = parse(Isotope, name)

"""
    parse(::Type{Isotope}, str::AbstractString)
解析核素符号
"""
Base.parse(::Type{Isotope}, str::AbstractString)::Isotope = begin
    m = match(r"([A-Z][a-z]*)(\d{1,3})", str)
    m === nothing && error("match error in parsing '$str'")
    name = m.captures[1]
    _A = parse(Int, m.captures[2])
    ele = Element(name)
    _Z = getZ(ele)
    _N = _A - _Z
    @assert _N >= 0 "$str isotope has a negative neutron number $_N"
    Isotope(_Z, _N)
end

"获取同位素的质子数"
getZ(iso::Isotope) = iso.Z
"获取同位素的中子数"
getN(iso::Isotope) = iso.N
"获取同位素的核子数"
getA(iso::Isotope) = iso.Z + iso.N

"以文本形式显示同位素，比如`Ne20`"
Base.show(io::IO, ::MIME"text/plain", iso::Isotope) = begin
    ele = Element(iso.Z)
    is_none(ele) && error("no such element")
    print(io, symbol(ele), getA(iso))
end

"以latex形式显示同位素"
Base.show(io::IO, ::MIME"text/markdown", iso::Isotope) = begin
    ele = Element(iso.Z)
    is_none(ele) && error("no such element")
    show(io, "text/markdown", Markdown.parse("``^{$(getA(iso))}\\mathrm{$(symbol(ele))}``"))
end

# ------------------
# 单粒子轨道
# ------------------

const l_name_map = Dict(
     0 => "s",  1 => "p",  2 => "d",  3 => "f",
     4 => "g",  5 => "h",  6 => "i",  7 => "j",
     8 => "k",  9 => "l", 10 => "m", 11 => "n",
    12 => "o" 
)

"""
    abstract type SingleParticleOrbit end
单粒子轨道
"""
abstract type SingleParticleOrbit end

"""
    struct JOrbit <: SingleParticleOrbit
        n::Int  # 主量子数
        l::Int  # 轨道角动量
        j::Int  # 总角动量
        tz::Int # 同位旋
    end
j-shceme 下的单粒子轨道。该结构体以及下面的`MOrbit`中，
总角动量和同位旋相关量都是使用物理上量子数的两倍来表示，以回避半整数
"""
struct JOrbit <: SingleParticleOrbit
    n::Int  # 主量子数
    l::Int  # 轨道角动量
    j::Int  # 总角动量
    tz::Int # 同位旋
    JOrbit(n, l, j, tz) = new(n, l, j, tz)
end

"""
    struct MOrbit <: SingleParticleOrbit
        n::Int  # 主量子数
        l::Int  # 轨道角动量
        j::Int  # 总角动量
        m::Int  # 总角动量的分量
        tz::Int # 同位旋
    end
m-scheme 下的单粒子轨道。
"""
struct MOrbit <: SingleParticleOrbit
    n::Int  # 主量子数
    l::Int  # 轨道角动量
    j::Int  # 总角动量
    m::Int  # 总角动量的分量
    tz::Int # 同位旋
    MOrbit(n, l, j, m, tz) = new(n, l, j, m, tz)
end


"""
    MOrbit(orbit::JOrbit, m::Integer)
通过 j-scheme 的单粒子轨道和``m``量子数来构造 m-scheme 轨道。
"""
MOrbit(orbit::JOrbit, m::Integer) = MOrbit(orbit.n, orbit.l, orbit.j, m, orbit.tz)

"""
    name(orbit::SingleParticleOrbit)
单粒子轨道的名字。例如`p(0d3/2)`，其中最外面的`p, n`表示质子或者中子，
`l > 12`以后的轨道角动量都用`"x"`表示。（我想也没人对这之后的轨道角动量感兴趣。）
"""
function name(orbit::SingleParticleOrbit)
    nucleon_type = orbit.tz == -1 ? "p" : "n"
    l_name = get(l_name_map, orbit.l, "x")
    "$(nucleon_type)($(orbit.n)$(l_name)$(orbit.j)/2)"
end

"显示j-scheme轨道"
Base.show(io::IO, orbit::JOrbit) = print(io, name(orbit))

"""
    struct NuclearShell
        orbits::Vector{JOrbit}
    end
原子核中壳的概念。实际上就是一系列的轨道组合而已，不保证真的具有物理意义。
按照壳模型计算的一般习惯，只需要j-scheme的轨道就够了。
"""
struct NuclearShell
    orbits::Vector{JOrbit}
    NuclearShell(orbits) = new(orbits)
end
NuclearShell(ns::NuclearShell) = ns

"""
    merge(ns1::NuclearShell, ns2::NuclearShell)
    merge(ns1::NuclearShell, ns2::NuclearShell, xns...)
合并两个壳。反正本代码中，壳只是一个计算上的概念，表示一系列轨道的集合。
把这些集合合并起来就是了。
"""
function Base.merge(ns1::NuclearShell, ns2::NuclearShell)
    NuclearShell(vcat(ns1.orbits, ns2.orbits))
end

function Base.merge(ns1::NuclearShell, ns2::NuclearShell, xns...)
    merge(NuclearShell(vcat(ns1.orbits, ns2.orbits)), xns...)
end

Base.merge(ns::NuclearShell) = ns

const s_shell = NuclearShell([
    JOrbit(0, 0, 1, -1), # 0s1/2
    JOrbit(0, 0, 1, 1)
])

const p_shell = NuclearShell([
    JOrbit(0, 1, 3, -1),  # 0p3/2
    JOrbit(0, 1, 3, 1),
    JOrbit(0, 1, 1, -1),  # 0p1/2
    JOrbit(0, 1, 1, 1)
])

const sd_shell = NuclearShell([
    JOrbit(0, 2, 5, -1),  # 0d5/2
    JOrbit(0, 2, 5, 1),
    JOrbit(1, 0, 1, -1),  # 1s1/2
    JOrbit(1, 0, 1, 1),
    JOrbit(0, 2, 3, -1),  # 0d3/2
    JOrbit(0, 2, 3, 1)
])

const pf_shell = NuclearShell([
    JOrbit(0, 3, 7, -1),  # 0f7/2
    JOrbit(0, 3, 7, 1),
    JOrbit(1, 1, 3, -1),  # 1p3/2
    JOrbit(1, 1, 3, 1),
    JOrbit(0, 3, 5, -1),  # 0f5/2
    JOrbit(0, 3, 5, 1),
    JOrbit(1, 1, 1, -1),  # 1p1/2
    JOrbit(1, 1, 1, 1)
])

"""
    j_orbits(ns::NuclearShell)
获得壳内所有的j-scheme轨道
"""
function j_orbits(ns::NuclearShell)
    ns.orbits
end

"""
    m_orbits(ns::NuclesrShell)
获得壳内所有的m-scheme轨道
"""
function m_orbits(ns::NuclearShell)
    orbits = Vector{MOrbit}()
    for orb in ns.orbits
        for m = -orb.j:2:orb.j
            push!(orbits, MOrbit(orb, m))
        end
    end
    return orbits
end

"""
    jsize(ns::NuclearShell)
壳内有几条j-scheme轨道。
"""
function jsize(ns::NuclearShell)
    length(ns.orbits)
end

"""
    msize(ns::NuclearShell)
计算壳内有几条m-scheme轨道，也就是能够容纳几个核子。
"""
function msize(ns::NuclearShell)
    sum = 0
    for orb in ns.orbits
        sum += orb.j + 1
    end
    return sum
end

"""
    psize(ns::NuclearShell)
计算壳内能够容纳几个质子。
"""
function psize(ns::NuclearShell)
    sum = 0
    for orb in ns.orbits
        (orb.tz == -1) && (sum += orb.j + 1)
    end
    return sum
end

"""
    nsize(ns::NuclearShell)
计算壳内能够容纳几个中子。
"""
function nsize(ns::NuclearShell)
    sum = 0
    for orb in ns.orbits
        (orb.tz == 1) && (sum += orb.j + 1)
    end
    return sum
end

"""
    max_pj(ns::NuclearShell)
计算壳内质子最大角动量。
"""
function max_pj(ns::NuclearShell)
    maxj = 1
    for orb in ns.orbits
        if orb.tz == -1
            maxj = max(maxj, orb.j)
        end
    end
    return maxj
end

"""
    max_nj(ns::NuclearShell)
计算壳内中子最大角动量
"""
function max_nj(ns::NuclearShell)
    maxj = 1
    for orb in ns.orbits
        if orb.tz == 1
            maxj = max(maxj, orb.j)
        end
    end
    return maxj
end

"""
    partition(n::Int, capacities::AbstractArray)
将 `n` 个小球放入 `length(capacities)` 个容器内，每个容器的容量由 `capacities` 数组指定
生成所有可能的放置方式
"""
function partition(n::Int, capacities::AbstractArray)
    result = Vector{Vector{Int}}()
    cap_size = length(capacities)
    next = (n::Int, pos::Int, line::Vector{Int}) -> begin
        if pos == cap_size
            if n <= capacities[end]
                xline = copy(line)
                xline[end] = n
                push!(result, xline)
            end
        else
            for i = 0:min(n, capacities[pos])
                xline = copy(line)
                xline[pos] = i
                next(n - i, pos + 1, xline)
            end
        end
        nothing
    end
    line = zeros(Int, length(capacities))
    next(n, 1, line)
    return result
end

"""
    binominal_safe(n::Integer, m::Integer)
判断这个二项式系数是否会溢出。
"""
function binominal_safe(n::Integer, m::Integer)
    n, m = promote(n, m)
    m = min(m, div(n, 2))
    try
        binomial(n, m)
    catch err
        if isa(err, OverflowError)
            return false
        else
            throw(err)
        end
    end
    return true
end

# 对于 julia 来说，`~m = -m - 1` 的小trick就不好用了
# 不过应该也无伤大雅
@inline m2index(m::Int) = m >= 0 ? m : (-m + 1)
@inline index2m(idx::Int) = isodd(idx) ? idx : (-idx + 1)

"""
    m_config_size(ns::NuclearShell, Z::Integer, N::Integer)
计算某一壳内，`Z+N`核子数的全组态大小。结果没有问题，效率也还行，但是大体系可能会压不住内存。
光靠GC确实还有不太行，可能用c++来写会好很一点。
"""
function m_config_size(ns::NuclearShell, Z::Integer, N::Integer)
    orbits = m_orbits(ns)
    orbit_number = msize(ns)

    p_m_map = zeros(Int64, max_pj(ns) + 1)
    n_m_map = zeros(Int64, max_nj(ns) + 1)

    for orb in orbits
        if orb.tz == -1
            p_m_map[m2index(orb.m)] += 1
        else
            n_m_map[m2index(orb.m)] += 1
        end
    end
    # @assert binominal_safe(maximum(p_m_map), Z) "binomial of Int64 may overflow"
    # @assert binominal_safe(maximum(n_m_map), N) "binomial of Int64 may overflow"

    hist_pM = Dict{Int, Int128}()
    p_ptn = partition(Z, p_m_map)
    for line in p_ptn
        num = Int128(1)
        m = 0
        for idx = 1:length(line)
            m += line[idx] * index2m(idx)
            num *= binomial(p_m_map[idx], line[idx])
        end
        hist_pM[m] = get(hist_pM, m, Int128(0)) + num
    end
    p_ptn = nothing
    GC.gc()

    hist_nM = Dict{Int, Int128}()
    n_ptn = partition(N, n_m_map)
    for line in n_ptn
        num = Int128(1)
        m = 0
        for idx = 1:length(line)
            m += line[idx] * index2m(idx)
            num *= binomial(n_m_map[idx], line[idx])
        end
        hist_nM[m] = get(hist_nM, m, Int128(0)) + num
    end
    n_ptn = nothing
    GC.gc()

    sum::BigInt = 0
    target = isodd(N + Z)
    for (pm, pnum) in hist_pM
        for (nm, nnum) in hist_nM
            if pm + nm == target
                sum += pnum * nnum
            end
        end
    end
    return sum
end

"""
    HO_shell(N::Integer)
构建一个`N = 2n + l`的谐振子壳层。
"""
function HO_shell(N::Integer)
    orbits = JOrbit[]
    for n = 0:div(N, 2)
        l = N - 2n
        for j in (l > 0 ? [2l+1, 2l-1] : [2l+1])
            push!(orbits, JOrbit(n, l, j, -1))
            push!(orbits, JOrbit(n, l, j, 1))
        end
    end
    NuclearShell(orbits)
end

"""
    HO_orbits(Nmax::Integer)
构建从`N = 0`到`N = Nmax`的所有谐振子轨道。
"""
function HO_orbits(Nmax::Integer)
    merge(ntuple(i -> HO_shell(i - 1), Nmax + 1)...)
end

"""
    struct ValenceSpace
        core_neutron::Int
        core_proton::Int
        ns::NuclearShell
    end
表示价空间的内。这个还是要有一定物理意义的，价轨道应该在核芯之上。
"""
struct ValenceSpace
    core_proton::Int  # 核芯的质子数
    core_neutron::Int # 核芯的中子数
    ns::NuclearShell  # 价轨道
    ValenceSpace(cp, cn, ns) = new(cp, cn, ns)
end

ValenceSpace(vs::ValenceSpace) = vs
"""
    ValenceSpace(core::Union{AbstractString, Isotope}, ns::Union{NuclearShell, Vector{JOrbit}})
`core`可以用一个同位素表示，比如``^{18}O``，价轨道可以用`NuclearShell`，也可以直接指定轨道。
"""
ValenceSpace(core::Union{AbstractString, Isotope}, ns::Union{NuclearShell, Vector{JOrbit}}) = begin
    iso = Isotope(core)
    ValenceSpace(iso.Z, iso.N, NuclearShell(ns))
end

"""
    Isotope(ns::ValenceSpace, Z::Integer, N::Integer)
给定一个价空间，给定价核子数目，得到核素。
"""
function Isotope(vs::ValenceSpace, Z::Integer, N::Integer)
    ns = vs.ns
    @assert Z < psize(ns) "Z = $Z is larger than valence size $(psize(ns))"
    @assert N < nsize(ns) "N = $N is larger than valence size $(nsize(ns))"
    Isotope(vs.core_proton + Z, vs.core_neutron + N)
end

"""
    Isotope(core::Union{AbstractString, Isotope}, Z::Integer, N::Integer)
给定一个核芯，以及在其之上的价核子数目，得到核素。这个函数没有价空间大小检查。
"""
function Isotope(core::Union{AbstractString, Isotope}, Z::Integer, N::Integer)
    iso = Isotope(core)
    Isotope(iso.Z + Z, iso.N + N)
end

"""
    valence(iso::Isotope, vs::ValenceSpace)
计算一个核素去掉核芯之后，价核子数目。
"""
function valence(iso::Isotope, vs::ValenceSpace)
    z = iso.Z - vs.core_proton
    n = iso.N - vs.core_neutron
    @assert z < psize(vs.ns) "valence proton number $z is larger than valence size $(psize(vs.ns))"
    @assert n < nsize(vs.ns) "valence neutron number $n is larger than valence size $(nsize(vs.ns))"
    return z, n
end

const p_space = ValenceSpace(2, 2, p_shell)
const sd_space = ValenceSpace(8, 8, sd_shell)
const pf_space = ValenceSpace(20, 20, pf_shell)