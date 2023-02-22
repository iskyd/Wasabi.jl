module Wasabi

abstract type Model end
abstract type ModelConstraint end
abstract type ConnectionConfiguration end

"""
    tablename(m::Type{T}) where {T <: Model}
    Returns the name of the table for the given model.
"""
tablename(m::Type{T}) where {T<:Model} = join("_$word" for word in lowercase.(split(String(Base.typename(m).name), r"(?=[A-Z])")))[2:end]


"""
    colnames(m::Type{T}) where {T <: Model}
    Returns the names of the columns for the given model.
"""
colnames(m::Type{T}) where {T<:Model} = collect(fieldnames(m))


"""
    coltype(m::Type{T}, field::Symbol) where {T <: Model}
    Returns the julia type of the given column.
"""
coltype(m::Type{T}, field::Symbol) where {T<:Model} = fieldtype(m, field)

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
    create_schema(db::Any, m::Type{T}, constraints::Vector{ModelConstraint}) where {T <: Model}
    Creates the schema for the given model and constraints.
"""
function create_schema end

"""
    delete_schema(db::Any, m::Type{T}) where {T <: Model}
    Deletes the schema for the given model.
"""
function delete_schema end

"""
    first(db::Any, m::Type{T})
    Returns the first row of the given model with the given id.
"""
function first end

include("constraints.jl")
include("backends/sqlite/sqlite.jl")

end