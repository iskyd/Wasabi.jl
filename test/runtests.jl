cd(@__DIR__)

using Test
using Wasabi
using Random
using Dates
using Mocking

Random.seed!(42)

mutable struct Role <: Wasabi.Model
    id::Union{Nothing, Int}
    name::String
    user_id::Int

    Role(name::String, user_id::Int) = new(nothing, name, user_id)
end

mutable struct User <: Wasabi.Model
    id::Union{Nothing, Int}
    name::String
    created_at::DateTime
    roles::Vector{Role}

    User(name::String, created_at::DateTime, roles::Vector{Role} = Role[]) = new(nothing, name, created_at, roles)
    User(id::Number, name::String, created_at::DateTime, roles::Vector{Role} = Role[]) = new(id, name, created_at, roles)
end

# struct UserProfile <: Wasabi.Model
#     id::Int
#     user_id::Int
#     bio::Union{String,Nothing}
# end

# struct UserPhone <: Wasabi.Model
#     id::Int
#     user_profile_id::Int
#     phone::String
# end

Wasabi.primary_key(m::Type{User}) = Wasabi.PrimaryKeyConstraint(Symbol[:id])
Wasabi.primary_key(m::Type{Role}) = Wasabi.PrimaryKeyConstraint(Symbol[:id])
Wasabi.foreign_keys(m::Type{Role}) = [Wasabi.ForeignKeyConstraint(Symbol[:user_id], :user, Symbol[:id])]
Wasabi.exclude_fields(m::Type{User}) = [:roles]

# Wasabi.primary_key(m::Type{UserProfile}) = Wasabi.PrimaryKeyConstraint(Symbol[:id])

# Wasabi.foreign_keys(m::Type{UserPhone}) = [Wasabi.ForeignKeyConstraint(Symbol[:user_profile_id], :user_profile, Symbol[:id])]

# Wasabi.unique_constraints(m::Type{UserProfile}) = [Wasabi.UniqueConstraint(Symbol[:user_id])]

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
addtests("tablename.jl")
addtests("types.jl")
addtests("model.jl")
addtests("configurations.jl")
addtests("sqlite.jl")
addtests("postgresql.jl")
addtests("custom_type.jl")
addtests("migrations.jl")