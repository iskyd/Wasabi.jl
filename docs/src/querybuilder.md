```@meta
CurrentModule = Wasabi.QueryBuilder
```

# QueryBuilder

You can use QueryBuilder to create and execute a query in a simple and fast way.
```
using Wasabi

mutable struct User <: Wasabi.Model
    id::Int
    name::String
end

configuration = Wasabi.SQLiteConnectionConfiguration("test.db")
conn = Wasabi.connect(configuration)

query = QueryBuilder.select(User) |> QueryBuilder.limit(1)
users = Wasabi.df2model(User, Wasabi.execute_query(conn, user))
```

QueryBuilder supports select, join, where, limit, offset, group by and order by.
Where conditions are expressed as Julia Expr object.

```
query = QueryBuilder.select(User) |> QueryBuilder.where(:(or, (User, name, like, "%mattia%"), (User, id, in, [1, 2, 3]))) |> QueryBuilder.limit(1)
sql, params = QueryBuilder.build(query)
println(sql.value) # SELECT user.id, user.name FROM "user" user WHERE (user.name LIKE $1 OR user.id IN $2) LIMIT 1
println(params) # 2-element Vector{Any}: "%mattia%" [1, 2, 3]
```

```@index
Modules = [Wasabi.QueryBuilder]
```

```@autodocs
Modules = [Wasabi.QueryBuilder]
```