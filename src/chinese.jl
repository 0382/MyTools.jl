# 处理中文

const 一万 = 10000
const 一亿 = 10000_0000
const chinese_digits = "零一二三四五六七八九"

"""
    chinese_digit(x::Integer)::Char
将一个一位数转化为中文。
"""
function chinese_digit(x::Integer)::Char
    0 <= x < 10 || throw(ArgumentError("$x is not a digit"))
    return chinese_digits[3x+1]
end

"""
    parse_chinese_digit(ch::Char)
将一个中文一位数转化为数字。
"""
function parse_chinese_digit(ch::Char)
    pos = findfirst(ch, chinese_digits)
    pos === nothing && throw(ArgumentError("$ch is not a chinese digit"))
    div(pos, 3)
end

"""
    chinese_number(x::Real)::String
将一个实数转换成中文阅读方式。
其中，对于整数和分数，是直接的中文表述；
对于无理数，输出`"无理数" * 该无理数的符号`；
对于小数，是`string(x)`的转述，因为这是浮点数保证无歧义的最小表述。
"""
chinese_number(x::Real)::String = _chinese_number(x)

"""
    parse_chinese(::Type{T<:Real}, s::AbstractString)
解析中文数字表述。只包括整数、分数、和浮点数，不支持无理数。
"""
parse_chinese(::Type{T}, s::AbstractString) where T<:Real = begin
    s = strip(s)
    s == "" && throw(ArgumentError("input string is empty or only contains whitespace"))
    s[1] == '负' && return -_parse_chinese(T, s[4:end])
    _parse_chinese(T, s)
end

# 无理数
function _chinese_number(x::AbstractIrrational)
    return "无理数" * string(x)
end

# 分数
function _chinese_number(x::Rational)
    return _chinese_number(denominator(x)) * "分之" * _chinese_number(numerator(x))
end

# 浮点数
function _chinese_number(x::AbstractFloat)
    s = string(x)
    dot_pos = findfirst('.', s)
    ipart = _chinese_number(parse(Int, s[1:dot_pos-1]))
    e_pos = findfirst('e', s)
    fpart = ""
    if e_pos === nothing
        for i = (dot_pos+1):length(s)
            fpart *= chinese_digit(parse(Int, s[i]))
        end
    else
        for i = (dot_pos+1):(e_pos-1)
            fpart *= chinese_digit(parse(Int, s[i]))
        end
        fpart *= "乘以十的" * _chinese_number(parse(Int, s[e_pos+1:end])) * "次方"
    end
    return ipart * '点' * fpart
end

function _chinese_number(x::Integer)
    x == 0 && return "零"
    if !isa(x, BigInt) && x == typemin(x)
        return "负" * _chinese_number(-widen(x))
    end
    x < 0 && return "负" * _chinese_number(-x)
    t = _chinese_integer_help(x)
    if t[1] == '零'
        return t[4:end]
    end
    return t
end

# 为了照顾更高位还有数字的情况，默认最前面可以有 "零"
# 在最终结果中抹去最高位的 "零"
function _chinese_integer_一万以内(x::Integer)
    result = ""
    if x >= 1000
        result *= chinese_digit(div(x, 1000)) * '千'
        x = rem(x, 1000)
    else
        result *= '零'
    end
    if x >= 100
        result *= chinese_digit(div(x, 100)) * '百'
        x = rem(x, 100)
    elseif result[end] != '零'
        result *= '零'
    end
    if x >= 10
        pos = div(x, 10)
        # 如果前面什么都没有，那么不说 "一十几"
        if pos == 1 && result == "零"
            result *= '十'
        else
            result *= chinese_digit(pos) * '十'
        end
        x = rem(x, 10)
    elseif result[end] != '零'
        result *= '零'
    end
    if x != 0
        result *= chinese_digit(x)
    elseif result[end] == '零'
        result = result[1:end-3]
    end
    return result
end

function _chinese_integer_help(x::Integer, 亿::Int = 0)
    higher = ""
    if x >= 一亿
        higher = _chinese_integer_help(div(x, 一亿), 亿 + 1)
        x = rem(x, 一亿)
    end
    lower = ""
    if x >= 一万
        lower = _chinese_integer_一万以内(div(x, 一万)) * '万'
        x = rem(x, 一万)
    end
    lower *= _chinese_integer_一万以内(x)
    if lower == ""
        return higher
    else
        higher * lower * repeat('亿', 亿)
    end
end

function 装得下几个亿(::Type{T}) where T<:Integer
    T === BigInt && return typemax(Int64)
    sizeof(T) <= 2 && return 0
    return exponent(sizeof(T)) - 1
end

function _parse_chinese(::Type{T}, s::AbstractString) where T<:Integer
    yi_pos = match(r"亿+", s)
    yi_pos === nothing && return _parse_chinese_help(s)%T
    几个亿 = length(yi_pos.match)
    几个亿 > 装得下几个亿(T) && throw(OverflowError("$s is larger than $T"))
    parts = split(s, yi_pos.match)
    leader_num = _parse_chinese_help(parts[1])
    leader = widemul(leader_num, T(一亿)^几个亿)
    leader % T != leader && throw(OverflowError("$s is larger than $T"))
    几个亿 -= 1
    while 几个亿 > 0
        pos = findfirst(repeat('亿', 几个亿), parts[2])
        if pos === nothing
            几个亿 -= 1
            continue
        end
        parts = split(parts[2], repeat('亿', 几个亿))
        leader += _parse_chinese_help(parts[1]) * T(一亿)^几个亿
        leader % T != leader && throw(OverflowError("$s is larger than $T"))
    end
    leader += _parse_chinese_help(parts[2])
    leader % T != leader && throw(OverflowError("$s is larger than $T"))
    return leader % T
end

# 解析小于一个亿的数字到 `Int64`
function _parse_chinese_help(s::AbstractString)
    parts = split(s, '万')
    if length(parts) == 1
        _parse_一万以内(s)
    else
        _parse_一万以内(parts[1]) * 一万 + _parse_一万以内(parts[2])
    end
end

function _parse_一万以内(s::AbstractString)
    s == "" && return 0
    if length(s) == 1
        s == "十" && return 10
        return parse_chinese_digit(s[1])
    end
    if s[1] == '零'
        s[4] == '零' && throw(ArgumentError("$s is not a chinese integer"))
        return _parse_一万以内(s[4:end])
    end
    if s[1] == '十'
        length(s) != 2 && throw(ArgumentError("$s is not a chinese integer"))
        return 10 + parse_chinese_digit(s[end])
    end
    if s[4] == '千'
        return parse_chinese_digit(s[1]) * 1000 + _parse_一万以内(s[7:end])
    elseif s[4] == '百'
        return parse_chinese_digit(s[1]) * 100 + _parse_一万以内(s[7:end])
    elseif s[4] == '十'
        return parse_chinese_digit(s[1]) * 10 + _parse_一万以内(s[7:end])
    end
    throw(ArgumentError("$s is not a chinese integer"))
end

function _parse_chinese(::Type{Rational{T}}, s::AbstractString) where T<:Integer
    parts = split(s, "分之")
    length(parts) != 2 && throw(ArgumentError("$s is not a chinese Rational"))
    de = _parse_chinese(T, parts[1])
    nu = _parse_chinese(T, parts[2])
    return nu // de
end

function _parse_chinese(::Type{T}, s::AbstractString) where T<:AbstractFloat
    parts = split(s, "乘以十的")
    1 <= length(parts) <=2 || throw(ArgumentError("$s is not a chinese floating point"))
    e_part = 0
    if length(parts) == 2
        if endswith(parts[2], "次方")
            e_part = _parse_chinese(Int, parts[2][1:end-6])
        else
            throw(ArgumentError("$s is not a chinese floating point"))
        end
    end
    parts = split(parts[1], "点")
    1 <= length(parts) <= 2 || throw(ArgumentError("$s is not a chinese floating point"))
    i_part = _parse_chinese(Int, parts[1])
    f_part = ""
    if length(parts) == 2
        for c in parts[2]
            f_part *= string(parse_chinese_digit(c))
        end
    end
    return parse(T, string(i_part) * '.' * f_part * 'e' * string(e_part))
end