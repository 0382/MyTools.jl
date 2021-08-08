using Documenter
push!(LOAD_PATH, "..")
using MyTools.Ini
using MyTools.Tool
using MyTools.Atom
using MyTools.Nucleus

makedocs(
    sitename="MyTools",
    pages=[
        "index.md",
        "Ini" => "ini.md",
        "Tool" => "tool.md",
        "Atom" => "atom.md",
        "Nucleus" => "nucleus.md"
    ]
)