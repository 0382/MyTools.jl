
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

function make_kshell_script(io::IO, snt::AbstractString, core::Union{Isotope, AbstractString}, vp::Union{AbstractVector, Integer}, vn::Union{AbstractVector, Integer}, p_is_hole::Bool, n_is_hole::Bool)
    if !isa(vp, AbstractVector)
        vp = [vp]
    end
    if !isa(vn, AbstractVector)
        vn = [vn]
    end
    core = Isotope(core)
    println(io, "N")
    println(io, snt, ".snt")
    for δp in vp
        for δn in vn
            if δp == 0 && δn == 0
                continue
            end
            println(io, δp, ",", δn)
            if p_is_hole && n_is_hole
                iso = Isotope(core, -δp, -δn)
            elseif p_is_hole && !n_is_hole
                iso = Isotope(core, -δp, δn)
            elseif !p_is_hole && n_is_hole
                iso = Isotope(core, δp, -δn)
            else
                iso = Isotope(core, δp, δn)
            end
            show(io, "text/plain", iso)
            println(io, "_", snt)
            println(io, 10)
            println(io, 0)
            println(io, "")
            println(io, "N")
        end
    end
    for _ in 1:10
        println(io, "")
    end
end

"生成粒子粒子kshell_ui的输入文件"
make_kshell_pp(io, snt, core, vp, vn) = make_kshell_script(io, snt, core, vp, vn, false, false)
"生成粒子空穴kshell_ui的输入文件"
make_kshell_ph(io, snt, core, vp, vn) = make_kshell_script(io, snt, core, vp, vn, false, true)
"生成空穴粒子kshell_ui的输入文件"
make_kshell_hp(io, snt, core, vp, vn) = make_kshell_script(io, snt, core, vp, vn, true, false)
"生成空穴空穴kshell_ui的输入文件"
make_kshell_hh(io, snt, core, vp, vn) = make_kshell_script(io, snt, core, vp, vn, true, true)
