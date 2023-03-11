cd(@__DIR__)

using Pkg

using Test, TestSetExtensions
using Wasabi
using Wasabi: QueryBuilder
using Mocking
using Pipe

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

    @includetests ARGS
end