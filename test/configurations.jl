@testset "configurations" begin
    sqlite_configuration = SQLiteConnectionConfiguration(dbname = "test.db")
    @test sqlite_configuration.dbname == "test.db"

    psql_configuration = PostgreSQLConnectionConfiguration(
        endpoint="localhost",
        username="postgres",
        password="postgres",
        port=5432,
        dbname="wasabi"
    )
    @test psql_configuration.endpoint == "localhost"
    @test psql_configuration.username == "postgres"
    @test psql_configuration.password == "postgres"
    @test psql_configuration.port == 5432
    @test psql_configuration.dbname == "wasabi"
end