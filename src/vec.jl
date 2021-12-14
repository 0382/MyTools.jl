import Base: +, -, *, /
import LinearAlgebra: ×

"""
    struct Vec{N, T<:Real} <: AbstractVector{T}
    const Vec2{T} = Vec{2, T}
    const Vec3{T} = Vec{3, T}
    const Vec4{T} = Vec{4, T}
笛卡尔坐标系向量。
"""
struct Vec{N,T<:Real} <: AbstractVector{T}
    data::NTuple{N,T}
    Vec{N,T}(data::NTuple{N,T}) where {N,T<:Real} = new(data)
end

Vec(v::Vec) = v
Vec(data::NTuple{N,T}) where {N,T<:Real} = Vec{N,T}(data)
Vec(data...) = Vec(promote(data...))

+(va::Vec{N,Ta}, vb::Vec{N,Tb}) where {N,Ta,Tb} = Vec(ntuple(i -> va.data[i] + vb.data[i], N))
-(va::Vec{N,Ta}, vb::Vec{N,Tb}) where {N,Ta,Tb} = Vec(ntuple(i -> va.data[i] - vb.data[i], N))
*(k::Tk, va::Vec{N,Ta}) where {N,Ta,Tk<:Real} = Vec(ntuple(i -> k * va.data[i], N))
/(va::Vec{N,Ta}, k::Tk) where {N,Ta,Tk<:Real} = inv(k) * va
*(va::Vec{N,Ta}, k::Tk) where {N,Ta,Tk<:Real} = k * va

Base.iterate(v::Vec{N,T}, state = 1) where {N,T} = state > N ? nothing : (v.data[state], state + 1)
Base.size(v::Vec{N,T}) where {N,T} = (N,)
Base.size(v::Vec{N,T}, dim) where {N,T} = dim == 1 ? N : dim > 1 ? 1 : error("Vec size: dimension out of range")
Base.length(v::Vec{N,T}) where {N,T} = N
Base.eltype(::Type{Vec{N,T}}) where {N,T} = T
Base.getindex(v::Vec{N,T}, i::Integer) where {N,T} = v.data[i]
Base.firstindex(v::Vec{N,T}) where {N,T} = 1
Base.lastindex(v::Vec{N,T}) where {N,T} = N

const Vec2{T} = Vec{2,T}
const Vec3{T} = Vec{3,T}
const Vec4{T} = Vec{4,T}
Vec2(data::NTuple{2,T}) where {T<:Real} = Vec{2,T}(data)
Vec3(data::NTuple{3,T}) where {T<:Real} = Vec{3,T}(data)
Vec4(data::NTuple{4,T}) where {T<:Real} = Vec{4,T}(data)
Vec2(x, y) = Vec2(promote(x, y))
Vec3(x, y, z) = Vec3(promote(x, y, z))
Vec4(x, y, z, w) = Vec4(promote(x, y, z, w))

Vec3(v::Vec2, z = 0) = Vec3(promote(v.data..., z))
Vec4(v::Vec2, z = 0, w = 0) = Vec4(promote(v.data..., z, w))
Vec4(v::Vec3, w = 0) = Vec3(promote(v.data..., w))

×(va::Vec3{Ta}, vb::Vec3{Tb}) where {Ta,Tb} = begin
    Vec3(
        va.data[2] * vb.data[3] - va.data[3] * vb.data[2],
        va.data[3] * vb.data[1] - va.data[1] * vb.data[3],
        va.data[1] * vb.data[2] - va.data[2] * vb.data[1]
    )
end

Base.getproperty(v::Vec{N,T}, sym::Symbol) where {N,T<:Real} = begin
    if N <= 0 || N > 4
        return getfield(v, sym)
    end
    if N >= 1 && sym == :x
        return v.data[1]
    elseif N >= 2 && sym == :y
        return v.data[2]
    elseif N >= 3 && sym == :z
        return v.data[3]
    elseif N >= 4 && sym == :w
        return v.data[4]
    end
    getfield(v, sym)
end