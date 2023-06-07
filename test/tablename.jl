@testset "tablename" begin
    @test Wasabi.tablename(User) == "user"
    @test Wasabi.tablename(Role) == "role"
end