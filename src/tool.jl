
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
    get_id_check_code(id17::String)::Char
根据前面17位身份证数字计算校验码
"""
function get_id_check_code(id17::String)::Char
    length(id17) < 17 && error("至少要给身份证前17位")
    sum = 0
    for i = 1:17
        sum += (id17[i] - '0') * id_weight[i]
    end
    return id_check_code[mod(sum, 11) + 1]
end

"""
    check_idcard(id::String)::Bool
检验身份证校验码是否正确
"""
function check_idcard(id::String)::Bool
    length(id) != 18 && error("请使用18位身份证")
    return get_id_check_code(id) == id[18]
end