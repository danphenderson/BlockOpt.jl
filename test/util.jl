@testset "@lencheck" begin
    x, y = ones(10), ones(10)
    z = ones(9)
    
    @test (@lencheck 10 x) ≡ nothing
    
    @test (@lencheck 10 x y) ≡ nothing
    
    @test_throws DimensionError @lencheck 10 z
    
    @test_throws DimensionError @lencheck 10 x z
end


@testset "@contract" begin
    abstract type AbstractFoo end
    
    struct Foo <: AbstractFoo end

    func(f::AbstractFoo) = @contract AbstractFoo :func
    
    # testing that func(T) where T<:AbstractFoo throws until method T exists
    @test_throws ContractError func(Foo())

    func(f::Foo) = nothing

    @test func(Foo()) ≡ nothing
end


function test_restricted_type(type)

    @test_throws AccessError type.afield

    @test propertynames(type) ≡ ()
    
    return nothing
end


@testset "@restrict" begin
    struct Bar
        x
    end

    Base.getproperty(b::Bar, s::Symbol) = @restrict Bar

    Base.propertynames(b::Bar) = ()

    bar = Bar(nothing)
    
    test_restricted_type(bar);
end
