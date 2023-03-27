@testset "query builder" begin
    query = QueryBuilder.from(User) |> QueryBuilder.select()
    @test query.source == User
    @test query.select == [QueryBuilder.SelectExpr(User, :id, nothing), QueryBuilder.SelectExpr(User, :name, nothing)]
    sql, params = QueryBuilder.build(query)
    @test sql.value  == "SELECT user_alias.id, user_alias.name FROM \"user\" user_alias"
    @test params == Any[]

    query = QueryBuilder.from(User) |> QueryBuilder.select(Symbol[:id]) |> QueryBuilder.limit(10) |> QueryBuilder.offset(5) |> QueryBuilder.orderby(Symbol[:name])
    @test query.source == User
    @test query.select == [QueryBuilder.SelectExpr(User, :id, nothing)]
    @test query.limit == 10
    @test query.offset == 5
    @test query.orderby == Symbol[:name]

    query = QueryBuilder.from(User) |> QueryBuilder.select([:name]) |> QueryBuilder.groupby(Symbol[:name])
    @test query.source == User
    @test query.select == [QueryBuilder.SelectExpr(User, :name, nothing)]
    @test query.groupby == Symbol[:name]

    query = QueryBuilder.from(User) |> QueryBuilder.select([:name]) |> QueryBuilder.join(User, UserProfile, :inner, (:id, :user_id), [:bio])
    @test query.source == User
    @test query.select == [QueryBuilder.SelectExpr(User, :name, nothing), QueryBuilder.SelectExpr(UserProfile, :bio, nothing)]
    @test query.joins[1].source == User
    @test query.joins[1].target == UserProfile
    @test query.joins[1].type == :inner
    @test query.joins[1].on == (:id, :user_id)

    e = :(or, (User, id, in, [1, 2, 3]), (User, id, in, [7, 8, 9]))
    params = Any[]
    q_where = QueryBuilder.build_where_expr(e, params)
    @test q_where == "WHERE (user_alias.id IN \$1 OR user_alias.id IN \$2)"
    @test params == [[1, 2, 3], [7, 8, 9]]

    e = :(and, (or, (User, id, notin, [1, 2, 3]), (User, id, eq, 4), (User, id, neq, 5)), (User, id, in, [7, 8, 9]))
    params = Any[]
    q_where = QueryBuilder.build_where_expr(e, params)
    @test q_where == "WHERE ((user_alias.id NOT IN \$1 OR user_alias.id = \$2 OR user_alias.id <> \$3) AND user_alias.id IN \$4)"
    @test params == [[1, 2, 3], 4, 5, [7, 8, 9]]

    e = :(or, (User, name, like, "%mattia%"), (User, id, in, [1, 2, 3]))
    params = Any[]
    q_where = QueryBuilder.build_where_expr(e, params)
    @test q_where == "WHERE (user_alias.name LIKE \$1 OR user_alias.id IN \$2)"
    @test params == ["%mattia%", [1, 2, 3]]

    e = :(and, (User, name, like, "%mattia%"))
    params = Any[]
    q_where = QueryBuilder.build_where_expr(e, params)
    @test q_where == "WHERE (user_alias.name LIKE \$1)"

    query = QueryBuilder.from(User) |> QueryBuilder.select() |> QueryBuilder.join(User, UserProfile, :inner, (:id, :user_id), [:bio]) |> QueryBuilder.where(:(or, (User, id, in, [1, 2, 3]), (UserProfile, bio, eq, "I'm a developer")))
    sql, params = QueryBuilder.build(query)
    @test sql.value == "SELECT user_alias.id, user_alias.name, user_profile_alias.bio FROM \"user\" user_alias INNER JOIN \"user_profile\" user_profile_alias ON user_alias.id = user_profile_alias.user_id WHERE (user_alias.id IN \$1 OR user_profile_alias.bio = \$2)"
    @test params == [[1, 2, 3], "I'm a developer"]

    query = QueryBuilder.from(User) |> QueryBuilder.select(User, :id, :count)
    sql, params = QueryBuilder.build(query)
    @test sql.value == "SELECT COUNT(user_alias.id) FROM \"user\" user_alias"
end