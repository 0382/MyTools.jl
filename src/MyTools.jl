module MyTools

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