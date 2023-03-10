@testset "query builder" begin
    query = QueryBuilder.select(User)
    @test query.source == User
    @test query.select == Symbol[:id, :name]

    query = @pipe QueryBuilder.select(User, Symbol[:id]) |> QueryBuilder.limit(_, 10) |> QueryBuilder.offset(_, 5)
    @test query.source == User
    @test query.select == Symbol[:id]
    @test query.limit == 10
    @test query.offset == 5
end