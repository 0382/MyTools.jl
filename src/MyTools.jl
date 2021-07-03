module MyTools

include("inifile.jl")

# export inifile related types and functions
export IniFile, IniItem, IniSection,
       isgood, error_msg, read_inifile, saveAs
       getValue, getString, getBool, getInt, getFloat

end