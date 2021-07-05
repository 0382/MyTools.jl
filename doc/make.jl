using Documenter
push!(LOAD_PATH, "..")
using MyTools.Ini
using MyTools.Tool
using MyTools.AtomName

makedocs(
    sitename="MyTools",
    pages=[
        "index.md",
        "Ini" => "ini.md",
        "Tool" => "tool.md"
    ]
)