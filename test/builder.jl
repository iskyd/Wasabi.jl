@testset "query builder" begin
    query = QueryBuilder.select(User)
    @test query.source == User
    @test query.select == Symbol[:id, :name]
    @test QueryBuilder.build(query).value == "SELECT user.id, user.name FROM \"user\" user"

    query = QueryBuilder.select(User, Symbol[:id]) |> QueryBuilder.limit(10) |> QueryBuilder.offset(5) |> QueryBuilder.orderby(Symbol[:name])
    @test query.source == User
    @test query.select == Symbol[:id]
    @test query.limit == 10
    @test query.offset == 5
    @test query.orderby == Symbol[:name]

    query = QueryBuilder.select(User, [:name]) |> QueryBuilder.groupby(Symbol[:name])
    @test query.source == User
    @test query.select == Symbol[:name]
    @test query.groupby == Symbol[:name]

    query = QueryBuilder.select(User, [:name]) |> QueryBuilder.join(User, UserProfile, :inner, (:id, :user_id), [:bio])
    @test query.source == User
    @test query.select == Symbol[:name]
    @test query.joins[1].source == User
    @test query.joins[1].target == UserProfile
    @test query.joins[1].type == :inner
    @test query.joins[1].on == (:id, :user_id)
    @test query.joins[1].select == Symbol[:bio]

    # e = :(or, (User, name, in, [1,2,3]), (User, name, in, [7,8,9]))
    # @test QueryBuilder.build_where_expr(e) == "WHERE (user.name IN $1 OR user.name IN $2)"
end