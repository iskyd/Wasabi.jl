module Wasabi

using DataFrames
using Dates

export QueryBuilder
export AutoIncrement
export @rq_str
export SQLiteConnectionConfiguration
export PostgreSQLConnectionConfiguration
export Migrations

abstract type Model end
abstract type Table end
abstract type ModelConstraint end
abstract type ConnectionConfiguration end

struct RawQuery
    value::String
end

macro rq_str(v::String)
    RawQuery(v)
end

"""
    tablename(m::Type{T}) where {T <: Model}
    Returns the name of the table for the given model.
"""
tablename(m::Type{T}) where {T<:Model} = join("_$word" for word in lowercase.(split(String(Base.typename(m).name), r"(?=[A-Z])")))[2:end]

"""
    tablename(m::String)
    Returns the name of the table for the given model.
"""
tablename(m::String) = join("_$word" for word in lowercase.(split(m, r"(?=[A-Z])")))[2:end]

"""
    alias(m::Type{T}) where {T <: Model}
    Returns the alias of the table for the given model.
"""
alias(m::Type{T}) where {T<:Model} = Wasabi.tablename(m) * "_alias"

"""
    alias(m::String)
    Returns the alias of the table for the given model.
"""
alias(m::String) = Wasabi.tablename(m) * "_alias"

"""
    colnames(m::Type{T}) where {T <: Model}
    Returns the names of the columns for the given model.
"""
colnames(m::Type{T}) where {T<:Model} = collect(fieldnames(m))

"""
    isnullable(m::Type{T}, field::Symbol, constraints::Vector{S}) where {T <: Model,S<:Wasabi.ModelConstraint}
    Returns true if the given column is nullable.
"""
function isnullable(m::Type{T}, field::Symbol) where {T<:Model}
    t = fieldtype(m, field)

    primary_key_constraint = Wasabi.primary_key(m)
    if primary_key_constraint !== nothing && field in primary_key_constraint.fields
        return false
    end

    if t isa Union
        t = filter(x -> x == Nothing, union_types(t))
        return length(t) > 0
    end

    return false
end

union_types(x::Union) = (x.a, union_types(x.b)...)
union_types(x::Type) = (x,)


"""
    exclude_fields(m::Type{T}) where {T <: Model}
    Returns the fields to exclude from the model when running queries.
"""
exclude_fields(m::Type{T}) where {T<:Wasabi.Model} = []
    
"""
    autoincrement_fields(m::Type{T}) where {T <: Model}
    Returns the fields that are autoincremented.
"""
autoincrement_fields(m::Type{T}) where {T<:Wasabi.Model} = [:id]

"""
    df2model(m::Type{T}, df::DataFrame) where {T <: Model}
    Converts the given DataFrame to the given model.
"""
function df2model(m::Type{T}, df::DataFrame) where {T<:Wasabi.Model}
    return [m(map(col -> row[col] !== missing ? Wasabi.from_sql_value(coltype(m, col), row[col]) : nothing, filter(x -> String(x) in names(df), Wasabi.colnames(m)))...) for row in eachrow(df)]
end

"""
    model2tuple(m::T) where {T <: Model}
    Converts the given model to a tuple.
"""
function model2tuple(m::T) where {T<:Model}
    return tuple(map(col -> (col, getfield(m, col)), Wasabi.colnames(T))...)
end

"""
    coltype(m::Type{T}, col::Symbol) where {T <: Model}
    Returns the column type for the given column and model.
"""
function coltype(m::Type{T}, col::Symbol) where {T<:Wasabi.Model}
    t = fieldtype(m, col)
    if t isa Union
        t = union_types(t)[findfirst(x -> x != Nothing, union_types(t))]
    end
    return t
end

"""
    constraints(m::Type{T}) where {T <: Model}
    Returns the constraints for the given model.
"""
constraints(m::Type{T}) where {T<:Model} = filter(c -> c !== nothing, [Wasabi.primary_key(m), Wasabi.foreign_keys(m)..., Wasabi.unique_constraints(m)...])

"""
    mapping(db::Type{S}, t::Type{T})::String where {S,T}
    Returns the mapping for the given database and type.
"""
function mapping end

"""
    connect(config::ConnectionConfiguration)
    Connects to the database using the given configuration.
"""
function connect end

"""
    disconnect(db::Any)
    Disconnects from the database.
"""
function disconnect end

"""
    create_schema(db::Any, m::Type{T}) where {T <: Model}
    Creates the schema for the given model and constraints.
"""
function create_schema end

"""
    delete_schema(db::Any, m::Type{T}) where {T <: Model}
    Deletes the schema for the given model.
"""
function delete_schema end

"""
    execute_query(db::Any, query::QueryBuilder.Query)
    Executes the given query.
"""
function execute_query end

"""
    execute_query(db::Any, query::RawQuery, params::Vector{Any})
    Executes the given query with the given parameters.
"""
function execute_query end

"""
    first(db::Any, m::Type{T}, id::Any) where {T <: Model}
    Returns the first row of the given model with the given id.
"""
function first end

"""
    all(db::Any, m::Type{T}) where {T <: Model}
    Returns all rows of the given model.
"""
function all end

"""
    insert(db::Any, model::T) where {T <: Model}
    Inserts the given model into the database.
"""
function insert! end

"""
    update(db::Any, model::T) where {T <: Model}
    Updates the given model in the database.
"""
function update! end

"""
    delete(db::Any, model::T) where {T <: Model}
    Deletes the given model from the database.
"""
function delete! end

"""
    delete_all(db::Any, m::Type{T}) where {T <: Model}
    Deletes all rows from the given model.
"""
function delete_all! end

"""
    begin_transaction(db::Any)
    Begins a transaction.
"""
function begin_transaction end

"""
    commit!(db::Any)
    Commits the current transaction.
"""
function commit! end

"""
    rollback(db::Any)
    Rolls back the current transaction.
"""
function rollback end

"""
    to_sql_value(db::Type{Any}, v::Any)
    Converts the given value to a value that can be used in a SQL query.
"""
function to_sql_value end

"""
    from_sql_value(db::Type{Any}, v::Any)
    Converts the SQL value to the struct type value.
"""
function from_sql_value end

include("constraints.jl")
include("QueryBuilder.jl")
include("types.jl")
include("Configurations.jl")
include("Migrations.jl")

end