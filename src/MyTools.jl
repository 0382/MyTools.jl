module MyTools

module Atom
    using Printf
    include("atom.jl")
    export Element, NoneElement, is_none, ElementConstructType,
        getZ, atomic_number, symbol, chinese, english, latin, pinyin,
        find_element_with_Z,
        find_element_with_symbol,
        find_element_with_chinese,
        find_element_with_english,
        find_element_with_latin,
        find_element_with_pinyin,
        find_element,
        show_element_table
end # module AtomName

module Nucleus
    using ..Atom
    import ..Atom:getZ
    include("nucleus.jl")
    export Isotope,
        getN, getA,
        SingleParticleOrbit,
        JOrbit, MOrbit,
        name,
        NuclearShell,
        s_shell, p_shell, sd_shell, pf_shell,
        j_orbits, m_orbits,
        jsize, msize, psize, nsize,
        max_pj, max_nj,
        partition,
        m_config_size,
        HO_shell, HO_orbits,
        ValenceSpace,
        valence,
        p_space, sd_space, pf_space
end

module Ini
    include("inifile.jl")
    export IniFile, IniItem, IniSection,
       isgood, error_msg, saveAs,
       getValue, getString, getBool, getInt, getFloat
end # module Ini

module Tool
    include("tool.jl")
    export GPA, get_id_check_code, check_idcard
end # module Tool

end # module MyTools