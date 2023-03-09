@testset "colnames" begin
    @test Wasabi.colnames(User) == Symbol[:id, :name]
    @test Wasabi.colnames(UserProfile) == Symbol[:id, :user_id, :bio]
end