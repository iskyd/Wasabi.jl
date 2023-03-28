@testset "mapping" begin
    using SQLite
    using LibPQ

    @test Wasabi.mapping(SQLite.DB, Any) == "BLOB"
    @test Wasabi.mapping(SQLite.DB, String) == "TEXT"
    @test Wasabi.mapping(SQLite.DB, Int64) == "INTEGER"
    @test Wasabi.mapping(SQLite.DB, Float64) == "REAL"
    @test Wasabi.mapping(SQLite.DB, Bool) == "INTEGER"

    @test Wasabi.mapping(LibPQ.Connection, Bool) == "BOOLEAN"

    abstract type SQLiteJSON end
    Wasabi.mapping(db::Type{SQLite.DB}, t::Type{SQLiteJSON}) = "String"

    @test Wasabi.mapping(SQLite.DB, SQLiteJSON) == "String"
end