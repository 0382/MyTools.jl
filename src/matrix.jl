LinearAlgebra.ldlt!(A::AbstractMatrix{<:Union{Float32, Float64, ComplexF32, ComplexF64}}) = begin
    @assert ishermitian(A)
    n = size(A, 1)
    @inbounds for i = 1:n-1
        iszero(A[i, i]) && throw(ZeroPivotException("factorization encountered one or more zero pivots. Consider switching to a pivoted LU factorization."))
        ldiv!(UnitLowerTriangular(@view A[1:i, 1:i]), @view(A[1:i, i+1]))
        @inbounds @simd for j = 1:i
            A[j, i+1] = A[j, i+1] / A[j, j]
        end
        @inbounds @simd for j = 1:i
            A[i+1, j] = conj(A[j, i+1])
        end
        @inbounds @simd for j = 1:i
            A[i+1, i+1] -= abs2(A[j, i+1]) * A[j, j]
        end
    end
    return LDLt(A)
end

LinearAlgebra.ldlt!(A::Union{Symmetric{T,Matrix{T}}, Hermitian{T, Matrix{T}}}) where {T<:Union{Float32, Float64, ComplexF32, ComplexF64}} = begin
    n = size(A, 1)
    if A.uplo == 'L'
        @inbounds for i = 1:n-1
            iszero(A[i, i]) && throw(ZeroPivotException("factorization encountered one or more zero pivots. Consider switching to a pivoted LU factorization."))
            ldiv!(UnitLowerTriangular(@view A.data[1:i, 1:i]), @view(adjoint(A.data)[1:i, i+1]))
            @inbounds @simd for j = 1:i
                A.data[i+1, j] = A.data[i+1, j] / A.data[j, j]
            end
            @inbounds @simd for j = 1:i
                A.data[i+1, i+1] -= abs2(A.data[i+1, j]) * A.data[j, j]
            end
        end
    elseif A.uplo == 'U'
        @inbounds for i = 1:n-1
            iszero(A[i, i]) && throw(ZeroPivotException("factorization encountered one or more zero pivots. Consider switching to a pivoted LU factorization."))
            ldiv!(adjoint(UnitUpperTriangular(@view A.data[1:i, 1:i])), @view(A.data[1:i, i+1]))
            @inbounds @simd for j = 1:i
                A.data[j, i+1] = A.data[j, i+1] / A.data[j, j]
            end
            @inbounds @simd for j = 1:i
                A.data[i+1, i+1] -= abs2(A.data[j, i+1]) * A.data[j, j]
            end
        end
    end
    return LDLt(A)
end

LinearAlgebra.ldlt(A::AbstractArray) = begin
    B = similar(A, float(eltype(A)))
    copyto!(B, A)
    LinearAlgebra.ldlt!(B)
end

LinearAlgebra.ldiv!(f::LDLt{T, <:AbstractMatrix{T}}, b::StridedVecOrMat{T}) where T<:Union{Float32, Float64, ComplexF32, ComplexF64} = begin
    ldiv!(f.L, b)
    ldiv!(f.D, b)
    ldiv!(f.Lt, b)
end

Base.show(io::IOContext{Base.TTY}, ::MIME"text/plain", f::LDLt{T,Matrix{T}}) where {T<:Union{Float32, Float64, ComplexF32, ComplexF64}} = begin
    println(io, typeof(f))
    println(io, "L factor:")
    show(io, "text/plain", UnitLowerTriangular(f.data))
    println(io, "\nD factor:")
    show(io, "text/plain", Diagonal(f.data))
end

Base.show(io::IOContext{Base.TTY}, ::MIME"text/plain", f::Union{LDLt{T,Symmetric{T, Matrix{T}}}, LDLt{T, Hermitian{T, Matrix{T}}}}) where {T<:Union{Float32, Float64, ComplexF32, ComplexF64}} = begin
    println(io, typeof(f))
    if f.data.uplo == 'L'
        println(io, "L factor:")
        show(io, "text/plain", UnitLowerTriangular(f.data.data))
    elseif f.data.uplo == 'U'
        println(io, "U factor:")
        show(io, "text/plain", UnitUpperTriangular(f.data.data))
    else
        throw(InvalidArgumentException("invalid uplo"))
    end
    println("\nD factor:")
    show(io, "text/plain", Diagonal(f.data.data))
end

Base.getproperty(f::LDLt{T,Matrix{T}}, p::Symbol) where {T<:Union{Float32, Float64, ComplexF32, ComplexF64}} = begin
    if p == :L
        return UnitLowerTriangular(f.data)
    elseif p == :D
        return Diagonal(f.data)
    elseif p == :d
        return diag(f.data)
    elseif p == :Lt
        return UnitUpperTriangular(f.data)
    else
        return getfield(f, p)
    end
end

Base.getproperty(f::Union{LDLt{T,Symmetric{T, Matrix{T}}}, LDLt{T, Hermitian{T, Matrix{T}}}}, p::Symbol) where {T<:Union{Float32, Float64, ComplexF32, ComplexF64}} = begin
    if p == :L
        if f.data.uplo == 'L'
            return UnitLowerTriangular(f.data.data)
        elseif f.data.uplo == 'U'
            return UnitUpperTriangular(f.data.data)'
        else
            throw(InvalidArgumentException("invalid uplo"))
        end
    elseif p == :D
        return Diagonal(f.data.data)
    elseif p == :d
        return diag(f.data.data)
    elseif p == :Lt
        if f.data.uplo == 'L'
            return UnitLowerTriangular(f.data.data)'
        elseif f.data.uplo == 'U'
            return UnitUpperTriangular(f.data.data)
        else
            throw(InvalidArgumentException("invalid uplo"))
        end
    else
        return getfield(f, p)
    end
end