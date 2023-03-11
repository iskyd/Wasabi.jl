@testset "query builder" begin
    query = QueryBuilder.select(User)
    @test query.source == User
    @test query.select == Symbol[:id, :name]

    query = @pipe QueryBuilder.select(User, Symbol[:id]) |> QueryBuilder.limit(_, 10) |> QueryBuilder.offset(_, 5) |> QueryBuilder.orderby(_, Symbol[:name])
    @test query.source == User
    @test query.select == Symbol[:id]
    @test query.limit == 10
    @test query.offset == 5
    @test query.orderby == Symbol[:name]

    query = @pipe QueryBuilder.select(User, [:name]) |> QueryBuilder.groupby(_, Symbol[:name])
    @test query.source == User
    @test query.select == Symbol[:name]
    @test query.groupby == Symbol[:name]
end