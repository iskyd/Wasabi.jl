@testset "coltype" begin
    using SQLite

    @test Wasabi.coltype(SQLite.DB, User, :id) == "INTEGER"
    @test Wasabi.coltype(SQLite.DB, User, :name) == "TEXT"
end