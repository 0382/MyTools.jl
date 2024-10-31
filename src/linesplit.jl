struct LineSplit{Ti<:Integer}
    parts::Ti
    sizes::Vector{Ti}
    offsets::Vector{Ti}
    LineSplit{Ti}(parts, sizes, offsets) where Ti = new(parts, sizes, offsets)
end

function LineSplit(length::Integer, parts::Integer, method = :Linear)
    @assert length >= 0 && parts > 0
    Ti = promote_type(typeof(length), typeof(parts))
    m_length::Ti = convert(Ti, length)
    m_parts::Ti = convert(Ti, parts)
    m_offsets = zeros(Ti, m_parts + 1)
    m_sizes = zeros(Ti, m_parts)
    if method == :Linear
        split_size, split_rem = divrem(m_length, m_parts)
        m_sizes[1:split_rem] .= split_size + 1
        m_sizes[split_rem+1:m_parts] .= split_size
        m_offsets[2:m_parts+1] .= accumulate(+, m_sizes)
    elseif method == :Triangular
        for i = 1:m_parts
            m_offsets[i+1] = round(Ti, m_length * sqrt(i/m_parts))
        end
        m_offsets[end] = m_length
        m_sizes = diff(m_offsets)
    elseif method == :InvTriangular
        for i = 1:m_parts
            m_offsets[i+1] = round(Ti, m_length * (1 - sqrt((m_parts - i)/m_parts)))
        end
        m_offsets[end] = m_length
        m_sizes = diff(m_offsets)
    end
    return LineSplit{Ti}(m_parts, m_sizes, m_offsets)
end