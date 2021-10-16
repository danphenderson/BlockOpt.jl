using Documenter
using BlockOpt

makedocs(
    sitename = "BlockOpt",
    format = Documenter.HTML(),
    modules = [BlockOpt],
    pages = [ 
        "Introduction" => "index.md",

        "Architecture" => [
            "architecture/info.md",
            "architecture/interface.md",
            "architecture/reference.md",
        ],

        "Manual" => [
            "manual/info.md",
            "manual/model.md",
            "manual/driver.md",
            "manual/reference.md"
        ],

        "Tutorials" => [
            "tutorials/info.md",
            "tutorials/reference.md"
        ],
    ],
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    push_preview = true,
    repo = "github.com/danphenderson/BlockOpt.jl.git",
)
