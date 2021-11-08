@testset "  @lencheck" begin
    n = 10;
    x, y = ones(n), ones(n)
    z = ones(n-1)
    
    @test (@lencheck n x) ≡ nothing
    
    @test (@lencheck n x y) ≡ nothing
    
    @test_throws DimensionError @lencheck n z
    
    @test_throws DimensionError @lencheck n x z
end


@testset "  @contract" begin
    abstract type AbstractFoo end
    
    struct Foo <: AbstractFoo end

    func(f::AbstractFoo) = @contract AbstractFoo :func
    
    # func(T) where T<:AbstractFoo throws until T overloads func 
    @test_throws ContractError func(Foo())

    func(f::Foo) = nothing

    @test func(Foo()) ≡ nothing
end


@testset "  @restrict" begin
    struct Bar
        x
    end

    Base.getproperty(b::Bar, s::Symbol) = @restrict typeof(Bar)

    bar = Bar(nothing)
    
    @test_throws AccessError bar.x
    
    @test_throws AccessError bar.y
    
    @test getfield(bar, :x) ≡ nothing
end