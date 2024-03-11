using LinearAlgebra

"""
    pade(c::AbstractVector, m::Integer, n::Integer)
c: Taylor series coefficients
m: numerator order
n: denominator order
"""
function pade(c::AbstractVector, m::Integer, n::Integer)
    @assert m >= 0 && n >= 0
    @assert length(c) >= m + n + 1

    Cmat = zeros(n, n)
    for i = 1:n
        for j = 1:n
            idx = m - n + i + j
            if idx <= 0
                Cmat[i, j] = 0
            else
                Cmat[i, j] = c[idx]
            end
        end
    end
    b = Cmat \ c[m+2:m+n+1]
    b = [1; -reverse(b)]
    a = zeros(m+1)
    for i = 1:m+1
        lastb = min(i, n+1)
        a[i] = dot(b[1:lastb], c[i:-1:i-lastb+1])
    end
    return a, b
end