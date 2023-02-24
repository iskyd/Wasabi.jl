@safetestset "tablename" begin
    using Wasabi

    struct User <: Wasabi.Model
        id::Int
        name::Union{String,Nothing}
    end

    @test Wasabi.isnullable(User, :id) == false
    @test Wasabi.isnullable(User, :name) == true
end