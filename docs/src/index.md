```@meta
CurrentModule = Wasabi
```

# Wasabi

Wasabi is a simple ORM for Julia. It currently supports PostgreSQL and SQLite.
Wasabi uses [package extensions](https://github.com/JuliaLang/julia/blob/v1.9.0-beta3/NEWS.md#package-manager) so it requires Julia >= 1.9 to run. Using SQLite or LibPQ automatically includes Wasabi features to support it as backend database. 

```julia
using Wasabi
using SQLite

# connect to database
configuration = SQLiteConnectionConfiguration("test.db")
conn = Wasabi.connect(configuration)

# declare models
mutable struct User <: Wasabi.Model
    id::Union{Nothing, AutoIncrement}
    name::String
end

Wasabi.primary_key(m::Type{User}) = Wasabi.PrimaryKeyConstraint(Symbol[:id])

struct UserProfile <: Wasabi.Model
    id::Int
    user_id::Int
    bio::Union{String,Nothing}
end

Wasabi.primary_key(m::Type{UserProfile}) = Wasabi.PrimaryKeyConstraint(Symbol[:id])
Wasabi.foreign_keys(m::Type{UserProfile}) = [Wasabi.ForeignKeyConstraint(Symbol[:user_id], :user, Symbol[:id])]

Wasabi.create_schema(conn, User)
Wasabi.create_schema(conn, UserProfile)

user = User("John Doe")
Wasabi.insert!(conn, user)

# If struct is mutable, autoincrement id is automatically set to the model
# println(user.id) -> 1

u = Wasabi.first(conn, User, keys[!, :id])

Wasabi.begin_transaction(conn)
try
    Wasabi.insert!(conn, user)
    Wasabi.commit!(conn)
catch e
    Wasabi.rollback(conn)
    rethrow(e)
end

res = Wasabi.execute_query(conn, rq"SELECT * FROM user where name = ?", Any["John Doe"])
users = Wasabi.df2model(User, res)

u.name = "Jane Doe"
Wasabi.update!(conn, user)

Wasabi.delete!(conn, user)

qb = QueryBuilder.select(User) |> QueryBuilder.where(:(and, (User, name, like, "%John%"))) |> QueryBuilder.limit(1)
users = Wasabi.execute_query(conn, qb)

Wasabi.disconnect(conn)
```

Documentation for [Wasabi](https://github.com/iskyd/Wasabi.jl).
