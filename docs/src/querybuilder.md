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

users = @pipe QueryBuilder.select(User) |> QueryBuilder.limit(_, 1) |> Wasabi.execute_query(conn, _) |> Wasabi.df2model(User, _)
```

```@index
Modules = [Wasabi.QueryBuilder]
```

```@autodocs
Modules = [Wasabi.QueryBuilder]
```