# Wasabi

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://iskyd.github.io/Wasabi.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://iskyd.github.io/Wasabi.jl/dev/)
[![Build Status](https://github.com/iskyd/Wasabi.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/iskyd/Wasabi.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/iskyd/Wasabi.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/iskyd/Wasabi.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)


Wasabi is a simple yet powerful ORM for the Julia Language. It currently supports postgresql and sqlite (more to come soon). Wasabi gives you access to a powerful query builder so that you don't need to write SQL and it automatically takes care of query params. It also gives you a simple way to manage tables and their updates using simple migrations.

> **WARNING**: At the moment the latest version of Wasabi (0.3.0) works only with Julia 1.9 due to the use of Pkg Extension. You can use version 0.2.2 for previous versions of Julia, but note that this version depends both from LibPQ and SQLite. Version 0.3.0 can't be released yet to the General registry because Julia 1.9.0 is not yet released.

### Getting Started

```
using Wasabi
using SQLite

configuration = SQLiteConnectionConfiguration("test.db")
conn = Wasabi.connect(configuration)

# declare models
mutable struct User <: Wasabi.Model
    id::Union{Nothing, AutoIncrement}
    name::String

    User(name::string) = new(nothing, name)
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
keys = Wasabi.insert!(conn, user)

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

qb = QueryBuilder.from(User) |> QueryBuilder.select() |> QueryBuilder.where(:(and, (User, name, like, "%John%"))) |> QueryBuilder.limit(1)
users = Wasabi.execute_query(conn, qb)

Wasabi.disconnect(conn)
```