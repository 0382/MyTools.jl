using Combinatorics


"""
    GPA(score::Int)::Float64
北大 GPA 计算公式
"""
function GPA(score::Int)::Float64
    score < 0 || score > 100 && error("不存在的分数")
    score < 60 && return 0
    return 4 - 3 * (100 - score) * (100 - score) / 1600
end


const id_weight = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
const id_check_code = "10X98765432"

"""
    get_id_check_code(id17::AbstractString)::Char
根据前面17位身份证数字计算校验码
"""
function get_id_check_code(id17::AbstractString)::Char
    length(id17) < 17 && error("至少要给身份证前17位")
    sum = 0
    for i = 1:17
        sum += (id17[i] - '0') * id_weight[i]
    end
    return id_check_code[mod(sum, 11)+1]
end

"""
    check_idcard(id::AbstractString)::Bool
检验身份证校验码是否正确
"""
function check_idcard(id::AbstractString)::Bool
    length(id) != 18 && error("请使用18位身份证")
    return get_id_check_code(id) == id[18]
end

"""
    BMI(weight::AbstractFloat, height::AbstractFloat)::Float64
根据身高体重计算BMI，体重单位：kg，身高单位：m
"""
function BMI(weight::AbstractFloat, height::AbstractFloat)::Float64
    height <= 0 || weight <= 0 && error("不存在的身高或体重")
    return weight / (height * height)
end

"""
    Fibonacci_matrix(n::Integer)::BigInt
使用矩阵快速幂计算菲波那切数列，每个矩阵只维护两个变量。
"""
function Fibonacci_matrix(n::Integer)::BigInt
    n < 0 && throw(ArgumentError("n = $n should not be negative"))
    x1::BigInt = 0
    x2::BigInt = 1
    t1::BigInt = 1
    t2::BigInt = 0
    temp::BigInt = 0
    while !iszero(n)
        if !iszero(n & 0x01)
            temp = x1 * t1
            x1, x2 = temp + x2 * t1 + x1 * t2, temp + x2 * t2
        end
        temp = t1 * t1
        t1, t2 = temp + 2t1 * t2, temp + t2 * t2
        n = div(n, 2)
    end
    return x1
end

"""
    Fibonacci_coeff(n::Integer)::BigInt
使用快速幂计算`(1+√5)/2`的`n`次方，以此来计算菲波那切数列。
"""
function Fibonacci_coeff(n::Integer)::BigInt
    n < 0 && throw(ArgumentError("n = $n should not be negative"))
    x1::BigInt = 2
    x2::BigInt = 0
    t1::BigInt = 1
    t2::BigInt = 1
    while !iszero(n)
        if !iszero(n & 0x01)
            x1, x2 = (x1 * t1 + 5x2 * t2) >> 1, (x1 * t2 + x2 * t1) >> 1
        end
        t1, t2 = (t1 * t1 + 5 * t2 * t2) >> 1, t1 * t2
        n = div(n, 2)
    end
    return x2
end

# 24点游戏节点
struct Node24
    value::Rational{Int}
    childs::Vector{Node24}
    ops::Vector{Char}
    level::Int
    function Node24(value::Rational{Int}, childs::Vector{Node24}, ops::Vector{Char}, level::Int)
        new(value, childs, ops, level)
    end
end

Node24(value::Rational{Int}, childs::Vector{Node24}, ops::Vector{Char}) = Node24(value, childs, ops, 0)
Node24(value::Rational{Int}) = Node24(value, Node24[], Char[])
Node24(value::Integer) = Node24(Rational{Int}(value))

function _show(node::Node24, final::Bool)
    if isempty(node.childs)
        string(numerator(node.value))
    else
        s = _show(node.childs[1], false)
        for i = 1:length(node.ops)
            s *= " $(node.ops[i]) $(_show(node.childs[i+1], false))"
        end
        return (node.level == 1 && !final) ? "($s)" : s
    end    
end

Base.show(io::IO, node::Node24) = begin
    print(io, _show(node, true))
end

function _split(v::AbstractVector{Node24}, n::Int)
    n >= length(v) && throw(ArgumentError("n = $n should be less than length(v) = $(length(v))"))
    ans = []
    for c in combinations(1:length(v), n)
        push!(ans, [v[c], v[setdiff(1:length(v), c)]])
    end
    return ans
end

function _24point_lv1(v::AbstractVector{Node24})
    n = length(v)
    ans = []
    for mask = 1:((1<<n) - 1)
        sum = 0
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

function _24point_lv2(v::AbstractVector{Node24})
    n = length(v)
    ans = []
    for mask = 1:((1<<n) - 1)
        pord = 1//1
        ops = Char[]
        skip = false
        for i = 1:n
            if !iszero(mask & (1<<(i-1)))
                pord *= v[i].value
                push!(ops, '*')
            else
                if isone(v[i].value) || iszero(v[i].value) # 等于1时和乘法等价
                    skip = true
                    continue
                end
                pord //= v[i].value
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
        push!(ans, Node24(pord, w, ops[2:end], 2))
    end
    return ans
end

function build_24_nodes(v::AbstractVector{Node24})
    n = length(v)
    n == 1 && return v
    lv = 0
    for i = 1:n
        v[i].level == 0 && continue
        if lv == 0
            lv = v[i].level
        else
            lv != v[i].level && return
        end
    end
    if n == 2
        ans = []
        if lv != 1
            push!(ans, Node24(v[1].value + v[2].value, [v[1], v[2]], ['+'], 1))
            # 如果结果是正数，总是可以期待每个节点都是正数
            if v[1].value < v[2].value
                push!(ans, Node24(v[2].value - v[1].value, [v[2], v[1]], ['-'], 1))
            else
                push!(ans, Node24(v[1].value - v[2].value, [v[1], v[2]], ['-'], 1))
            end
        end
        if lv != 2
            push!(ans, Node24(v[1].value * v[2].value, [v[1], v[2]], ['*'], 2))
            if !iszero(v[2].value)
                push!(ans, Node24(v[1].value // v[2].value, [v[1], v[2]], ['/'], 2))
            end
            if !iszero(v[1].value)
                push!(ans, Node24(v[2].value // v[1].value, [v[2], v[1]], ['/'], 2))
            end
        end
        return ans
    end
    if n == 3
        ans = []
        if lv != 1
            ans = vcat(ans, _24point_lv1(v))
        end
        if lv != 2
            ans = vcat(ans, _24point_lv2(v))
        end
        st = Set{Rational{Int}}()
        for i = 1:n
            v[i].value in st && continue
            push!(st, v[i].value)
            t = copy(v)
            deleteat!(t, i)
            if lv != 1
                for x in _24point_lv1(t)
                    ans = vcat(ans, _24point_lv2([x, v[i]]))
                end
            end
            if lv != 2
                for x in _24point_lv2(t)
                    ans = vcat(ans, _24point_lv1([x, v[i]]))
                end
            end
        end
        return ans
    end
    ans = []
    if lv != 1
        ans = vcat(ans, _24point_lv1(v))
        for (a, b) in _split(v, 3)
            ta = _24point_lv1(a)
            for x in ta
                ans = vcat(ans, _24point_lv2([x, b[1]]))
            end
        end
        for (a, b) in _split(v, 2)
            ta = _24point_lv1(a)
            tb = _24point_lv1(b)
            for x in ta
                for y in tb
                    ans = vcat(ans, _24point_lv2([x, y]))
                end
            end
            for x in ta
                ans = vcat(ans, _24point_lv2([x, b[1], b[2]]))
                for y in _24point_lv2([x, b[1]])
                    ans = vcat(ans, _24point_lv1([y, b[2]]))
                end
                for y in _24point_lv2([x, b[2]])
                    ans = vcat(ans, _24point_lv1([y, b[1]]))
                end
            end
        end
    end
    if lv != 2
        ans = vcat(ans, _24point_lv2(v))
        for (a, b) in _split(v, 3)
            ta = _24point_lv2(a)
            for x in ta
                ans = vcat(ans, _24point_lv1([x, b[1]]))
            end
        end
        for (a, b) in _split(v, 2)
            ta = _24point_lv2(a)
            tb = _24point_lv2(b)
            for x in ta
                for y in tb
                    ans = vcat(ans, _24point_lv1([x, y]))
                end
            end
            for x in ta
                ans = vcat(ans, _24point_lv1([x, b[1], b[2]]))
                for y in _24point_lv1([x, b[1]])
                    ans = vcat(ans, _24point_lv2([y, b[2]]))
                end
                for y in _24point_lv1([x, b[2]])
                    ans = vcat(ans, _24point_lv2([y, b[1]]))
                end
            end
        end
    end
    return ans
end

function play_24game(v::AbstractVector{T}) where T<:Integer
    n = length(v)
    nodes = Node24.(v)
    t = build_24_nodes(nodes)
    ans = Node24[]
    for x in t
        if x.value == 24
            push!(ans, x)
        end
    end
    return ans
end
