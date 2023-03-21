# Wasabi

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://iskyd.github.io/Wasabi.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://iskyd.github.io/Wasabi.jl/dev/)
[![Build Status](https://github.com/iskyd/Wasabi.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/iskyd/Wasabi.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/iskyd/Wasabi.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/iskyd/Wasabi.jl)


Wasabi is a simple yet powerful ORM for the Julia language. It currently supports postgresql and sqlite (more to come soon). Wasabi gives you access to a powerful query builder so that you don't need to write SQL and it automatically takes care of query params. It also gives you a simple way to manage tables and their updates using simple migrations.

### Getting Started

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