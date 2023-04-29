@testset "types" begin
    now = Dates.now()

    @test Wasabi.to_sql_value(1) == 1
    @test Wasabi.to_sql_value("test") == "test"
    @test Wasabi.to_sql_value(now) == Dates.format(now, "yyyy-mm-ddTHH:MM:SS.s")
    @test Wasabi.to_sql_value(Date(now)) == Dates.format(Date(now), "yyyy-mm-dd")
    @test Wasabi.to_sql_value(Wasabi.AutoIncrement(1)) == 1

    @test Wasabi.from_sql_value(Any, 1) == 1
    @test Wasabi.from_sql_value(Int, 1) == 1
    @test Wasabi.from_sql_value(String, "test") == "test"
    @test Wasabi.from_sql_value(DateTime, "2023-03-30T00:00:00.000") == DateTime("2023-03-30T00:00:00.000")
    @test Wasabi.from_sql_value(Date, "2023-01-01") == Date("2023-01-01")
    @test Wasabi.from_sql_value(Wasabi.AutoIncrement, 1) == Wasabi.AutoIncrement(1)
end