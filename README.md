# BlockOpt.jl

| **Documentation** | 
|:-----------------:|
| [![][docs-dev-img]](https://danphenderson.github.io/BlockOpt.jl/dev/) |

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg

See the [documentation](https://danphenderson.github.io/BlockOpt.jl/dev/) to learn more 
about the `BlockOpt` package.

## Installation
The BlockOpt package installs as

```julia
julia> ]
pkg> add https://github.com/danphenderson/TRS.jl
pkg> add https://github.com/danphenderson/BlockOpt.jl # backspace returns to julia prompt 
```

in the [Julia's Pkg REPL mode](https://docs.julialang.org/en/v1/stdlib/Pkg/index.html#Getting-Started-1).


In a notebook environment BlockOpt installs as
```julia
using Pkg
Pkg.add(url="https://github.com/danphenderson/TRS.jl")
Pkg.add(url="https://github.com/danphenderson/BlockOpt.jl")
```
using the Julia package manager [Pkg.jl](https://pkgdocs.julialang.org/v1/).

The [TRS package](https://github.com/oxfordcontrol/TRS.jl) hasn't been updated to install with
the BlockOpt.jl supported julia release versrions ``≥`` `v1.3.0`. The TRS package was
developed in an earlier release of Julia. The BlockOpt trust-region subproblem solve
uses `trs_small` from an updated version of TRS using the current Pkg.jl `.toml` system.
There is an open pull-request to merge the
[forked TRS branch](https://github.com/danphenderson/TRS.jl) used in BlockOpt.jl