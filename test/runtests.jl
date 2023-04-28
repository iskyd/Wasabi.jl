cd(@__DIR__)

using Test
using Wasabi
using Mocking
using Random
using Dates

Random.seed!(42)

mutable struct User <: Wasabi.Model
    id::Union{Nothing, AutoIncrement}
    name::String
    created_at::DateTime

    User(name::String, created_at::DateTime) = new(nothing, name, created_at)
    User(id::AutoIncrement, name::String, created_at::DateTime) = new(id, name, created_at)
end

struct UserProfile <: Wasabi.Model
    id::Int
    user_id::Int
    bio::Union{String,Nothing}
end

struct UserPhone <: Wasabi.Model
    id::Int
    user_profile_id::Int
    phone::String
end

Wasabi.primary_key(m::Type{User}) = Wasabi.PrimaryKeyConstraint(Symbol[:id])
Wasabi.primary_key(m::Type{UserProfile}) = Wasabi.PrimaryKeyConstraint(Symbol[:id])

Wasabi.foreign_keys(m::Type{UserProfile}) = [Wasabi.ForeignKeyConstraint(Symbol[:user_id], :user, Symbol[:id])]
Wasabi.foreign_keys(m::Type{UserPhone}) = [Wasabi.ForeignKeyConstraint(Symbol[:user_profile_id], :user_profile, Symbol[:id])]

Wasabi.unique_constraints(m::Type{UserProfile}) = [Wasabi.UniqueConstraint(Symbol[:user_id])]

enabled_tests = lowercase.(ARGS)
function addtests(fname)
    key = lowercase(splitext(fname)[1])
    if isempty(enabled_tests) || key in enabled_tests
        Random.seed!(42)
        include(fname)
    end
end

addtests("aqua.jl")
addtests("ambiguities.jl")
addtests("builder.jl")
addtests("colnames.jl")
addtests("coltype.jl")
addtests("constraints.jl")
addtests("isnullable.jl")
addtests("mapping.jl")
addtests("migrations.jl")
addtests("postgresql.jl")
addtests("sqlite.jl")
addtests("tablename.jl")
addtests("types.jl")
addtests("custom_type.jl")