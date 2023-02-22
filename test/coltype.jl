@safetestset "coltype" begin
    using Wasabi

    struct User <: Wasabi.Model
        id::Int
        name::String
    end

    @test Wasabi.coltype(User, :id) == Int64
    @test Wasabi.coltype(User, :name) == String
end