@safetestset "coltype" begin
    using Wasabi

    struct User <: Wasabi.Model
        id::Int
        name::String
    end

    SAMPLE_MAPPING = Dict{Type,String}(
        Int => "INTEGER",
        String => "TEXT"
    )

    @test Wasabi.coltype(SAMPLE_MAPPING, User, :id) == "INTEGER"
    @test Wasabi.coltype(SAMPLE_MAPPING, User, :name) == "TEXT"
end