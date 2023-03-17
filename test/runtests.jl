cd(@__DIR__)

using Pkg

using Test, TestSetExtensions
using Wasabi
using Wasabi: QueryBuilder
using Mocking
# using Pipe

@testset ExtendedTestSet "Wasabi tests" begin
    mutable struct User <: Wasabi.Model
        id::Int
        name::String
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
    
    @includetests ARGS
end