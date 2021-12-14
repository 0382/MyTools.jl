# 泡利算符

const σ0 = [1 0; 0 1]
const σx = [0 1; 1 0]
const σy = [0 -im; im 0]
const σz = [1 0; 0 -1]
const σv = σx + σy + σz

"""
    ⊗(x::AbstractVector, y::AbstractVector)
张量积
"""
⊗(x::AbstractVector, y::AbstractVector) = begin
    T = promote_type(eltype(x), eltype(y))
    lx = length(x)
    ly = length(y)
    z = zeros(T, lx * ly)
    for i = 1:lx
        for j = 1:ly
            z[(i-1)*ly+j] = x[i] * y[j]
        end
    end
    return z
end

"""
    ⊗(x::AbstractMatrix, y::AbstractMatrix)
张量积
"""
⊗(x::AbstractMatrix, y::AbstractMatrix) = begin
    T = promote_type(eltype(x), eltype(y))
    xrows, xcols = size(x)
    yrows, ycols = size(y)
    z = zeros(T, xrows * yrows, xcols * ycols)
    for xj = 1:xcols
        for yj = 1:ycols
            for xi = 1:xrows
                for yi = 1:yrows
                    z[(xi-1)*yrows+yi, (xj-1)*ycols+yj] = x[xi, xj] * y[yi, yj]
                end
            end
        end
    end
    return z
end