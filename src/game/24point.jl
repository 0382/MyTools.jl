struct Node24{T<:Integer}
    value::Rational{T}
    children::Vector{Node24{T}}
    ops::Vector{Char}
    level::Int
    function Node24(value::Rational{T}, children::Vector{Node24{T}}, ops::Vector{Char}, level::Int) where T<:Integer
        new{T}(value, children, ops, level)
    end
end

Node24(value::Rational{T}, children::Vector{Node24{T}}, ops::Vector{Char}) where T<:Integer = Node24(value, children, ops, 0)
Node24(value::Rational{T}) where T<:Integer = Node24(value, Node24{T}[], Char[])
Node24(value::Integer) = Node24(value//1)

function _show(node::Node24, final::Bool)
    isempty(node.children) && return string(numerator(node.value))
    s = _show(node.children[1], false)
    for i in 1:length(node.ops)
        s *= " $(node.ops[i]) " * _show(node.children[i+1], false)
    end
    return (node.level == 1 && !final) ? "($s)" : s
end

Base.show(io::IO, node::Node24) = print(io, _show(node, true))

function lv1_24point(v::AbstractVector{Node24{T}}) where T <: Integer
    n = length(v)
    if n == 1
        v[1].level == 0 && return v
        return []
    end
    ans = []
    for mask = 1:((1<<n) - 1)
        sum = zero(Rational{T})
        ops = Char[]
        skip = false
        for i = 1:n
            if !iszero(mask & (1<<(i-1)))
                sum += v[i].value
                push!(ops, '+')
            else
                if iszero(v[i].value) # 等于0时和加法等价
                    skip = true
                    break
                end
                sum -= v[i].value
                push!(ops, '-')
            end
        end
        skip && continue
        sum < 0 && continue # 结果为正数时，总是可以期待每个节点都是正数
        first_plus = trailing_zeros(mask) + 1
        w = copy(v)
        if first_plus != 1
            w[first_plus], w[1] = w[1], w[first_plus]
            ops[first_plus], ops[1] = ops[1], ops[first_plus]
        end
        push!(ans, Node24(sum, w, ops[2:end], 1))
    end
    return ans
end

function lv2_24point(v::AbstractVector{Node24{T}}) where T<:Integer
    n = length(v)
    if n == 1
        v[1].level == 0 && return v
        return []
    end
    ans = []
    for mask = 1:((1<<n) - 1)
        prod = one(Rational{T})
        ops = Char[]
        skip = false
        for i = 1:n
            if !iszero(mask & (1<<(i-1)))
                prod *= v[i].value
                push!(ops, '×')
            else
                if isone(v[i].value) || iszero(v[i].value) # 等于1时和乘法等价
                    skip = true
                    continue
                end
                prod //= v[i].value
                push!(ops, '/')
            end
        end
        skip && continue
        first_mul = trailing_zeros(mask) + 1
        w = copy(v)
        if first_mul != 1
            w[first_mul], w[1] = w[1], w[first_mul]
            ops[first_mul], ops[1] = ops[1], ops[first_mul]
        end
        push!(ans, Node24(prod, w, ops[2:end], 2))
    end
    return ans
end

function lv_24point(v, level)
    level == 1 && return lv1_24point(v)
    level == 2 && return lv2_24point(v)
    return []
end

function _next_lv(level)
    level == 1 && return 2
    level == 2 && return 1
    return 0
end

function make_24nodes(v::AbstractVector{Node24{T}}, level) where T <: Integer
    n = length(v)
    n == 1 && return v
    lv = 0
    for i = 1:n
        v[i].level == 0 && continue
        if lv == 0
            lv = v[i].level
        elseif lv != v[i].level
            return Node24{T}[]
        end
    end
    (lv != 0 && lv == level) && return Node24{T}[]
    n == 2 && return lv_24point(v, level)
    next_level = _next_lv(level)
    if n == 3
        ans = lv_24point(v, level)
        st = Set{typeof(v[1].value)}()
        for i = 1:n
            if v[i].level == 0
                v[i].value in st && continue # 简单的剪枝，不能完全去重
                push!(st, v[i].value)
            end
            w = copy(v)
            deleteat!(w, i)
            for t in lv_24point(w, next_level)
                ans = vcat(ans, lv_24point([v[i], t], level))
            end
        end
    end
    if n == 4
        ans = lv_24point(v, level)
        st = Set{typeof(v[1].value)}()
        for i = 1:n
            if v[i].level == 0
                v[i].value in st && continue # 简单的剪枝，不能完全去重
                push!(st, v[i].value)
            end
            w = copy(v)
            deleteat!(w, i)
            for t in make_24nodes(w, next_level)
                ans = vcat(ans, lv_24point([v[i], t], level))
            end
        end

        for i in 1:n
            for j in (i+1):n
                for k in (i+1):n
                    k == j && continue
                    for l in (k+1):n
                        l == j && continue
                        for t1 in lv_24point([v[i], v[j]], next_level)
                            for t2 in lv_24point([v[k], v[l]], next_level)
                                ans = vcat(ans, lv_24point([t1, t2], level))
                            end
                        end
                    end
                end
            end
        end
    end
    n >= 5 && error("Not implemented yet")
    return ans
end

"""
    play_24point(v::AbstractVector{T}) where T<:Integer
24点游戏，给定4个整数，返回所有可能的表达式
"""
function play_24point(v::AbstractVector{T}) where T<:Integer
    n = length(v)
    nodes = Node24.(v)
    ans = Node24{T}[]
    for x in make_24nodes(nodes, 1)
        if x.value == 24
            push!(ans, x)
        end
    end
    for x in make_24nodes(nodes, 2)
        if x.value == 24
            push!(ans, x)
        end
    end
    return ans
end
