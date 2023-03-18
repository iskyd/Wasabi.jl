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

```@index
Modules = [Wasabi.QueryBuilder]
```

```@autodocs
Modules = [Wasabi.QueryBuilder]
```