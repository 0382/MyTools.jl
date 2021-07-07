module MyTools

module AtomName
    include("atom-name.jl")
    export Element, NoneElement, is_none,
        Z, atomic_number, symbol, chinese, english, latin, pinyin,
        find_element_with_Z,
        find_element_with_symbol,
        find_element_with_chinese,
        find_element_with_english,
        find_element_with_latin,
        find_element_with_pinyin,
        find_element,
        Isotope, N, A,
        NuclearShell,
        isotope,
        m_config_size,
        p_shell, sd_shell, pf_shell,
        m_config_size,
        valence
end # module AtomName

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