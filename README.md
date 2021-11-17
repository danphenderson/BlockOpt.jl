# BlockOpt.jl (Currently Under Development)
| **Documentation** | 
|:-----------------:|
| [![][docs-stable-img]](https://danphenderson.github.io/BlockOpt.jl/dev/) |

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg

Implements a Quasi-Newton Block update with a direct solve of the 
trust-region subproblem to determine the unconstrained minimum of a 
smooth objective function. Forward-Mode AD is used to generate a block
of curvature information at each gradient evaluation, which is incorparated
into a standard update of an indefinte inverse Hessian approximation.

## Installation
The BlockOpt package can be installed by running

```
add https://github.com/danphenderson/TRS.jl
add https://github.com/danphenderson/BlockOpt.jl
```
in [Julia's Pkg REPL mode](https://docs.julialang.org/en/v1/stdlib/Pkg/index.html#Getting-Started-1).


Alternatively, this package can be installed by running
```
using Pkg
Pkg.add(url="https://github.com/danphenderson/TRS.jl")
Pkg.add(url="https://github.com/danphenderson/BlockOpt.jl")
```
in a notebook enviroment. 

The TRS.jl package is an unregistered package requirement for BlockOpt.jl
and it must be installed independetly and prior to installation of the BlockOpt
package.