@safetestset "colnames" begin
    using Wasabi

    struct User <: Wasabi.Model
        id::Int
        name::String
    end

    struct UserProfile <: Wasabi.Model
        id::Int
        user_id::Int
        bio::String
    end

    @test Wasabi.colnames(User) == Symbol[:id, :name]
    @test Wasabi.colnames(UserProfile) == Symbol[:id, :user_id, :bio]
end