@testset "coltype" begin
    @test Wasabi.coltype(User, :id) == Int
    @test Wasabi.coltype(User, :name) == String
    @test Wasabi.coltype(User, :created_at) == DateTime
end