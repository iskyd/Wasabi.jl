@testset "query builder" begin
    query = QueryBuilder.from(User) |> QueryBuilder.select()
    @test query.source == User
    @test query.select == [QueryBuilder.SelectExpr(source=User, field=:id), QueryBuilder.SelectExpr(source=User, field=:name), QueryBuilder.SelectExpr(source=User, field=:created_at)]
    sql, params = QueryBuilder.build(query)
    @test sql.value  == "SELECT user_alias.id, user_alias.name, user_alias.created_at FROM \"user\" user_alias"
    @test params == Any[]

    query = QueryBuilder.from(User) |> QueryBuilder.select(Symbol[:id]) |> QueryBuilder.limit(10) |> QueryBuilder.offset(5) |> QueryBuilder.orderby(Symbol[:name])
    @test query.source == User
    @test query.select == [QueryBuilder.SelectExpr(source=User, field=:id)]
    @test query.limit == 10
    @test query.offset == 5
    @test query.orderby == Symbol[:name]

    query = QueryBuilder.from(User) |> QueryBuilder.select([:name]) |> QueryBuilder.groupby(Symbol[:name])
    @test query.source == User
    @test query.select == [QueryBuilder.SelectExpr(source=User, field=:name)]
    @test query.groupby == Symbol[:name]

    query = QueryBuilder.from(User) |> QueryBuilder.select([:name]) |> QueryBuilder.join(User, Role, :inner, (:id, :user_id), [:name])
    @test query.source == User
    @test query.select == [QueryBuilder.SelectExpr(source=User, field=:name), QueryBuilder.SelectExpr(source=Role, field=:name)]
    @test query.joins[1].source == User
    @test query.joins[1].target == Role
    @test query.joins[1].type == :inner
    @test query.joins[1].on == (:id, :user_id)

    e = :(or, (User, id, in, [1, 2, 3]), (User, id, in, [7, 8, 9]))
    params = Any[]
    q_where = QueryBuilder.build_where_expr(e, params)
    @test q_where == "WHERE (user_alias.id IN (\$1, \$2, \$3) OR user_alias.id IN (\$4, \$5, \$6))"
    @test params == [1, 2, 3, 7, 8, 9]

    e = :(and, (or, (User, id, notin, [1, 2, 3]), (User, id, eq, 4), (User, id, neq, 5)), (User, id, in, [7, 8, 9]))
    params = Any[]
    q_where = QueryBuilder.build_where_expr(e, params)
    @test q_where == "WHERE ((user_alias.id NOT IN (\$1, \$2, \$3) OR user_alias.id = \$4 OR user_alias.id <> \$5) AND user_alias.id IN (\$6, \$7, \$8))"
    @test params == [1, 2, 3, 4, 5, 7, 8, 9]

    e = :(or, (User, name, like, "%mattia%"), (User, id, in, [1, 2, 3]))
    params = Any[]
    q_where = QueryBuilder.build_where_expr(e, params)
    @test q_where == "WHERE (user_alias.name LIKE \$1 OR user_alias.id IN (\$2, \$3, \$4))"
    @test params == ["%mattia%", 1, 2, 3]

    e = :(and, (User, name, like, "%mattia%"))
    params = Any[]
    q_where = QueryBuilder.build_where_expr(e, params)
    @test q_where == "WHERE (user_alias.name LIKE \$1)"

    query = QueryBuilder.from(User) |> QueryBuilder.select() |> QueryBuilder.join(User, Role, :inner, (:id, :user_id), [:name]) |> QueryBuilder.where(:(or, (User, id, in, [1, 2, 3]), (Role, name, eq, "admin")))
    sql, params = QueryBuilder.build(query)
    @test sql.value == "SELECT user_alias.id, user_alias.name, user_alias.created_at, role_alias.name FROM \"user\" user_alias INNER JOIN \"role\" role_alias ON user_alias.id = role_alias.user_id WHERE (user_alias.id IN (\$1, \$2, \$3) OR role_alias.name = \$4)"
    @test params == [1, 2, 3, "admin"]

    query = QueryBuilder.from(User) |> QueryBuilder.select(User, :id, :total, :count)
    sql, params = QueryBuilder.build(query)
    @test sql.value == "SELECT COUNT(user_alias.id) AS total FROM \"user\" user_alias"

    query = QueryBuilder.from(User) |> QueryBuilder.select(User, :id, :renamed)
    sql, params = QueryBuilder.build(query)
    @test sql.value == "SELECT user_alias.id AS renamed FROM \"user\" user_alias"
end