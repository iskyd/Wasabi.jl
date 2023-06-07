@testset "colnames" begin
    @test Wasabi.colnames(User) == Symbol[:id, :name, :created_at, :roles]
    @test Wasabi.colnames(Role) == Symbol[:id, :name, :user_id]
end