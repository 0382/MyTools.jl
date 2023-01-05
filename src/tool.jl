
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
    return id_check_code[mod(sum, 11) + 1]
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
    Fibonacci(n::Integer)::BigInt
使用快速幂计算`(1+√5)/2`的`n`次方，以此来计算菲波那切数列。
"""
function Fibonacci(n::Integer)::BigInt
    x1::BigInt = 2
    x2::BigInt = 0
    t1::BigInt = 1
    t2::BigInt = 1
    while !iszero(n)
        if !iszero(n & 0x01)
            x1, x2 = div(x1*t1+5x2*t2, 2), div(x1*t2+x2*t1, 2)
        end
        t1, t2 = div(t1*t1+5*t2*t2,2), t1*t2
        n = div(n, 2)
    end
    return x2
end