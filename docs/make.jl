using Documenter
using BlockOpt

makedocs(
    sitename = "BlockOpt",
    format = Documenter.HTML(
        # See https://github.com/JuliaDocs/Documenter.jl/issues/868
        prettyurls = get(ENV, "CI", nothing) == "true",
        mathengine = Documenter.MathJax2(),
        collapselevel = 1,
    ),
    modules = [BlockOpt],
    pages = [

        "Introduction" => "index.md",
        
        "Overview" => "overview/design.md",

        "Manual" => [
            "manual/model.md",
            "manual/driver.md",
            "manual/options.md",
        ],

        "Tutorials" => [
            "tutorials/installation.md",
            "tutorials/simple.md",
        ]
    ],
)

deploydocs(
    devbranch = "main",
    push_preview = true,
    repo = "github.com/danphenderson/BlockOpt.jl.git",
)
