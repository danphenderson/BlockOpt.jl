# Installation

The BlockOpt package installs as

```julia-repl
julia> ]
pkg> add https://github.com/danphenderson/TRS.jl
pkg> add https://github.com/danphenderson/BlockOpt.jl # backspace after returns user to julia prompt 
```

in the [Julia's Pkg REPL mode].(https://docs.julialang.org/en/v1/stdlib/Pkg/index.html#Getting-Started-1).


In a notebook environment
```julia
using Pkg
Pkg.add(url="https://github.com/danphenderson/TRS.jl")
Pkg.add(url="https://github.com/danphenderson/BlockOpt.jl")
```
`BlockOpt.jl` installs using the Julia package manager [Pkg.jl](https://pkgdocs.julialang.org/v1/).

The [TRS package](https://github.com/oxfordcontrol/TRS.jl) is an unregistered package 
requirement for BlockOpt.jl. There is an open pull-request to merge the 
[forked branch](https://github.com/danphenderson/TRS.jl) of TRS.jl used in this packages
trust-region subproblem solve. The pull request focuses on updating the master branch to the latest 
evolution of the Julia package management system. 