@testset "tablename" begin
    @test Wasabi.tablename(User) == "user"
    @test Wasabi.tablename(UserProfile) == "user_profile"
end