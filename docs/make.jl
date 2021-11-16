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
    checkdocs = :exports,
    pages = [
        "Introduction" => "index.md",
        "Overview" => "overview/design.md",
        "Manual" => ["manual/model.md", "manual/driver.md", "manual/options.md"],
        "Tutorials" => ["tutorials/simple.md"],
    ],
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(push_preview = true, repo = "github.com/danphenderson/BlockOpt.jl.git")
