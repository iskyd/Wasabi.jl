```@meta
CurrentModule = Wasabi
```

# Wasabi

Wasabi is a simple ORM for Julia. It currently supports PostgreSQL and SQLite. 

```
using Wasabi

mutable struct User <: Wasabi.Model
    id::Int
    name::String
end

struct UserProfile <: Wasabi.Model
    id::Int
    user_id::Int
    bio::Union{String,Nothing}
end

user_constraints = [
    Wasabi.PrimaryKeyConstraint([:id])
]

user_profile_constraints = [
    Wasabi.PrimaryKeyConstraint([:id]),
    Wasabi.ForeignKeyConstraint([:user_id], :user, [:id]),
    Wasabi.UniqueConstraint([:user_id])
]

configuration = Wasabi.SQLiteConnectionConfiguration("test.db")
conn = Wasabi.connect(configuration)

Wasabi.create_schema(conn, User, user_constraints)
Wasabi.create_schema(conn, UserProfile, user_profile_constraints)

user = User(1, "John Doe")
Wasabi.insert!(conn, user)

u = Wasabi.first(conn, User, 1)

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

Wasabi.disconnect(conn)
```

Documentation for [Wasabi](https://github.com/iskyd/Wasabi.jl).
