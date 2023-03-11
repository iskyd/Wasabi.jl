```@meta
CurrentModule = Wasabi.QueryBuilder
```

# QueryBuilder

You can use QueryBuilder to create and execute a query in a simple and fast way.
```
using Wasabi
using Pipe

mutable struct User <: Wasabi.Model
    id::Int
    name::String
end

configuration = Wasabi.SQLiteConnectionConfiguration("test.db")
conn = Wasabi.connect(configuration)

res = @pipe QueryBuilder.select(User, Symbol[:id]) |> QueryBuilder.limit(_, 10) |> QueryBuilder.offset(_, 5) |> QueryBuilder.orderby(_, Symbol[:name]) |> Wasabi.execute_query(conn, _)
```

```@index
Modules = [Wasabi.QueryBuilder]
```

```@autodocs
Modules = [Wasabi.QueryBuilder]
```