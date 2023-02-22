@safetestset "tablename" begin
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

    @test Wasabi.tablename(User) == "user"
    @test Wasabi.tablename(UserProfile) == "user_profile"
end