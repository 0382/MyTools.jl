using Documenter
push!(LOAD_PATH, "..")
using MyTools.Ini
using MyTools.Tool

makedocs(
    sitename="MyTools",
    pages=[
        "index.md",
        "Ini" => "ini.md",
        "Tool" => "tool.md"
    ]
)