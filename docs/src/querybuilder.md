```@meta
CurrentModule = Wasabi.QueryBuilder
```

# QueryBuilder

You can use QueryBuilder to create and execute a query in a simple and fast way.
```
using Wasabi
using SQLite

mutable struct User <: Wasabi.Model
    id::Int
    name::String
end

configuration = SQLiteConnectionConfiguration("test.db")
conn = Wasabi.connect(configuration)

query = QueryBuilder.from(User) |> QueryBuilder.select() |> QueryBuilder.limit(1)
users = Wasabi.df2model(User, Wasabi.execute_query(conn, user))
```

QueryBuilder supports select, join, where, limit, offset, group by and order by.

Select can be expressed as vector of symbols or using SelectExpr object. If no arguments are passed to select then all fields of the model are selected. You can also use alias and select function like count, sum, avg and so on.

```
QueryBuilder.from(User) |> QueryBuilder.select() # Select all fields from user model
QueryBuilder.from(User) |> QueryBuilder.select([:id, :name]) # SELECT user_alias.id, user_alias.name FROM user user_alias
QueryBuilder.from(User) |> QueryBuilder.select(User, :id, :total, :count) # SELECT COUNT(user_alias.id) AS total FROM user user_alias
```

Join are expressed using source, target, type (inner, outer ...), on, select.
Here's an example to join User with UserProfile using an INNER JOIN and selecting the "bio" column from UserProfile .


```
query = QueryBuilder.from(User) |> QueryBuilder.select() |> QueryBuilder.join(User, UserProfile, :inner, (:id, :user_id), [:bio])

# SELECT user.id, user.name, user_profile.bio FROM "user" user INNER JOIN "user_profile" user_profile ON user.id = user_profile.user_id
```

Where conditions are expressed as Julia Expr object where you can nest and/or conditions. The condition needs to be expressed as (Model, fieldname, function, params).

```
query = QueryBuilder.from(User) |> QueryBuilder.select() |> QueryBuilder.where(:(or, (User, name, like, "%mattia%"), (User, id, in, [1, 2, 3]))) |> QueryBuilder.limit(1)
sql, params = QueryBuilder.build(query)

# println(sql.value) SELECT user.id, user.name FROM "user" user WHERE (user.name LIKE $1 OR user.id IN $2) LIMIT 1
# println(params) # 2-element Vector{Any}: "%mattia%" [1, 2, 3]
```

```@index
Modules = [Wasabi.QueryBuilder]
```

```@autodocs
Modules = [Wasabi.QueryBuilder]
```