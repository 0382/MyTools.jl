using Documenter
push!(LOAD_PATH, "..")
using MyTools
using MyTools.Ini
using MyTools.Tool
using MyTools.Atom
using MyTools.Nucleus
using MyTools.Chinese

makedocs(
    sitename="MyTools",
    pages=[
        "index.md",
        "Base" => "base.md",
        "Ini" => "ini.md",
        "Tool" => "tool.md",
        "Atom" => "atom.md",
        "Nucleus" => "nucleus.md",
        "Chinese" => "chinese.md"
    ]
)

deploydocs(
    repo = "github.com/0382/MyTools.jl.git",
    target = "build/"
)