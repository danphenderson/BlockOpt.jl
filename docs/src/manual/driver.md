```@meta
CurrentModule = BlockOpt
DocTestSetup = quote
    import BlockOpt: Driver, pflag, QN_update, SR1, PSB, S_update, S_update_a,
        S_update_b, S_update_c, S_update_d, S_update_e, S_update_f
end
```

# Driver

```@docs
Driver
```

## Interface

The delegation design pattern at play allows us to forward the `DriverOptions`
interface to the `Driver`. In addition to the documented methods, see the
`Options` interface section.

```@docs
QN_update(d::Driver)
SR1
PSB
S_update(d::Driver)
S_update_a
S_update_b
S_update_c
S_update_d
S_update_e
S_update_f
pflag(d::Driver)
```
