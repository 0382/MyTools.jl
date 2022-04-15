import Base:~,==

"""
    mutable struct StaticBitVector{N} <: AbstractVector{Bool}
BitVector with static size, only allows `64N` size.
"""
mutable struct StaticBitVector{N} <: AbstractVector{Bool}
    chunks::NTuple{N, UInt64}
    StaticBitVector{N}(chunks::NTuple{N, UInt64}) where N = begin
        @assert 0 < N <= fld(typemax(Int64), 64)
        new(chunks)
    end
end

StaticBitVector(chunks::NTuple{N, UInt64}) where N = StaticBitVector{N}(chunks)
StaticBitVector(min_num::Integer) = begin
    N = convert(Int, cld(min_num, 64))
    StaticBitVector{N}(ntuple(i -> zero(UInt64), N))
end
StaticBitVector(idxs::AbstractVector{<:Integer}) = begin
    N = convert(Int, cld(maximum(idxs), 64))
    sbv = StaticBitVector{N}(ntuple(i -> zero(UInt64), N))
    for i in idxs
        sbv[i] = true
    end
end
StaticBitVector(bv::BitVector) = begin
    N = length(bv.chunks)
    StaticBitVector{N}(ntuple(i -> bv.chunks[i], N))
end
StaticBitVector(bs::BitSet) = begin
    N = length(bs.bits) + bs.offset
    f = i -> begin
        if i <= bs.offset
            zero(UInt64)
        else
            bs.bits[i - bs.offset]
        end
    end
    StaticBitVector{N}(ntuple(f, N))
end

Base.zeros(::Type{StaticBitVector{N}}) where N = StaticBitVector(ntuple(i->zero(UInt64), N))
Base.ones(::Type{StaticBitVector{N}}) where N = StaticBitVector(ntuple(i->~zero(UInt64), N))
@inline Base.count(sbv::StaticBitVector{N}) where N = begin
    s = 0
    @inbounds @simd for i = 1:N
        s += count_ones(sbv.chunks[i])
    end
    return s
end

"""
    count_ones_start(x::UInt64, idx::Int64)
count_ones of `x` at bit position `idx:64`
"""
@inline count_ones_start(x::UInt64, idx::Int64) = begin
    count_ones(x >> (idx - 1))
end

"""
    count_ones_stop(x::UInt64, idx::Int64)
count_ones of `x` at bit position `1:idx`
"""
@inline count_ones_stop(x::UInt64, idx::Int64) = begin
    count_ones(x << (64 - idx))
end

"""
    count_ones_in(x::UInt64, irange::UnitRange)
count_ones of `x` at bit position `irange`
"""
@inline count_ones_in(x::UInt64, irange::UnitRange) = begin
    count_ones((x >> (irange.start - 1)) << (63 - irange.stop + irange.start))
end

Base.count(sbv::StaticBitVector{N}, irange::UnitRange) where N = begin
    idx_start, offset_start = fldmod1(irange.start, 64)
    idx_stop, offset_stop = fldmod1(irange.stop, 64)
    if idx_start == idx_stop
        return count_ones_in(sbv.chunks[idx_start], offset_start:offset_stop)
    end
    s = count_ones_start(sbv.chunks[idx_start], offset_start) + count_ones_stop(sbv.chunks[idx_stop], offset_stop)
    @inbounds for idx in idx_start+1:idx_stop-1
        s += count_ones(sbv.chunks[idx])
    end
    return s
end

==(sbv1::StaticBitVector{N}, sbv2::StaticBitVector{N}) where N = sbv1.chunks == sbv2.chunks

Base.length(::StaticBitVector{N}) where N = N * 64
Base.size(::StaticBitVector{N}) where N = (N * 64,)
Base.iterate(sbv::StaticBitVector{N}, state = 1) where N = state > N * 64 ? nothing : (sbv[state], state + 1)
Base.eltype(::StaticBitVector{N}) where N = Bool
Base.firstindex(::StaticBitVector{N}) where N = 1
Base.lastindex(::StaticBitVector{N}) where N = N * 64
Base.getindex(sbv::StaticBitVector{N}, i::Integer) where N = begin
    @assert 0 < i <= length(sbv)
    idx, offset = Base.get_chunks_id(i)
    return convert(Bool, (sbv.chunks[idx] >> offset) & 0x01)
end

Base.setindex!(sbv::StaticBitVector{N}, v::Bool, i::Integer) where N = begin
    @assert 0 < i <= length(sbv)
    idx, offset = Base.get_chunks_id(i)
    @inbounds num = sbv.chunks[idx]
    num = (num & ~(UInt64(0x01) << offset)) | (convert(UInt64, v) << offset)
    ptr = convert(Ptr{UInt64}, pointer_from_objref(sbv))
    GC.@preserve sbv unsafe_store!(ptr, num, idx)
    return sbv
end

Base.summary(io::IO, sbv::StaticBitVector{N}) where N = begin
    print(io, length(sbv), "-element StaticBitVector")
end

~(sbv::StaticBitVector{N}) where N = begin
    return StaticBitVector{N}(ntuple(i -> ~sbv.chunks[i], N))
end

Base.union(sbv1::StaticBitVector{N}, sbv2::StaticBitVector{N}) where N = begin
    return StaticBitVector{N}(ntuple(i -> sbv1.chunks[i] | sbv2.chunks[i], N))
end

Base.intersect(sbv1::StaticBitVector{N}, sbv2::StaticBitVector{N}) where N = begin
    return StaticBitVector{N}(ntuple(i -> sbv1.chunks[i] & sbv2.chunks[i], N))
end

Base.xor(sbv1::StaticBitVector{N}, sbv2::StaticBitVector{N}) where N = begin
    return StaticBitVector{N}(ntuple(i -> sbv1.chunks[i] ⊻ sbv2.chunks[i], N))
end

Base.symdiff(sbv1::StaticBitVector{N}, sbv2::StaticBitVector{N}) where N = xor(sbv1, sbv2)
Base.setdiff(sbv1::StaticBitVector{N}, sbv2::StaticBitVector{N}) where N = begin
    return StaticBitVector{N}(ntuple(i -> sbv1.chunks[i] & ~sbv2.chunks[i], N))
end

Base.issubset(sbv1::StaticBitVector{N}, sbv2::StaticBitVector{N}) where N = count(sbv1 & ~sbv2) == 0
