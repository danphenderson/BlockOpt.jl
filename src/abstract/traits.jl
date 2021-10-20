export AbstractNameTrait


"""
    AbstractNameTrait

A name trait of an `AbstractBlockOptType` type.
"""
abstract type AbstractNameTrait end


"""
    Name <: AbstractNameTrait

Holds the `name` of types implementing the `has_name` trait.
"""
mutable struct Name <: AbstractNameTrait name::String end


"""
    NoName <: AbstractNameTrait

Default trait of `AbstractNameTrait` assigned to subtypes of `AbstractBlockOptType`.
"""
struct NoName <: AbstractNameTrait end


"""
    has_name(::Type{<:BlockOptType})

The default trait for an `AbstractBlockOptType`@ref is `NoName`.

## Example
Assigning a `name` to type `T`, a concrete `subtype` of `AbstractBlockOptType`:

```julia
has_name(::T) = Name(name)
```

here, we are naming objects of type `T` by the given string `name`.
"""
has_name(::Type{<:AbstractBlockOptType}) = NoName()


"""
   name(type::T) where {T<:AbstractBlockOptType}
   
The name of type `T` or nothing when `T` hasn't been given a `Name`.

See also: `has_name`.
"""
name(type::T) where {T<:AbstractBlockOptType} = name(has_name(T), type)

name(::Name, type) = getfield(type, :name)

name(::NoName, type) = nothing

"""
   name(type::T) where {T<:AbstractBlockOptType}
   
Sets the name of type `T` or does nothing when `T` hasn't been given a `Name`.

See also: `has_name`.
"""
name!(type::T, name) where {T<:AbstractBlockOptType} = name!(has_name(T), type, name)

name!(::Name, type, name) = setfield!(type, :name, name)

name!(::NoName, type, name) = nothing


"""
    StateTrait <: AbstractStateTrait

The default type of `AbstractStateTrait`.
"""
abstract type StateTrait end


"""
    Stores a set of traits for subtypes of `AbstractBlockOptType` given the `AbstractNameTrait`.
    
## ATTRIBUTE
```julia
struct States <: StateTrait
    states::Set
end
```

See also: `has_states`.
"""
struct States <: StateTrait states::Set end


"""
    NoStates <: StateTrait

Default trait of `AbstractStateTrait` given to subtypes of `AbstractBlockOptType`.
"""
struct NoStates <: StateTrait end


"""
    has_states(::Type{<:BlockOptType})::AbstractNameTrait

The default `AbstractStateTrait`@ref assigned to subtypes of `AbstractBlockOptType`
is `NoName`.

## Example
Assigning states to concrete `T::AbstractBlockOptType`:

```julia
has_states(::T) = States(states)
```

here, we are assining the set of state stymbols to objects of type `T`.
"""
has_states(::Type{<:AbstractBlockOptType}) = NoStates()


"""
    states(type::T) where {T<:AbstractBlockOptType}
   
The states of type `T` or nothing when `T` hasn't been given a `Name`.

See also: `has_states`.
"""
states(type::T) where {T<:AbstractBlockOptType} = name(has_states(T), type)

states(::States, type) = getfield(type, :States)

states(::NoStates, type) = NoStates()