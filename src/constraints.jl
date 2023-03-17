struct PrimaryKeyConstraint <: ModelConstraint
    fields::Vector{Symbol}
end

struct ForeignKeyConstraint <: ModelConstraint
    fields::Vector{Symbol}
    foreign_table::Symbol
    foreign_fields::Vector{Symbol}
end

struct UniqueConstraint <: ModelConstraint
    fields::Vector{Symbol}
end

"""
    primary_key(m::Type{T})::Union{PrimaryKeyConstraint, Nothing} where {T<:Model}
    Returns the primary key constraint for the given model.
"""
function primary_key(m::Type{T})::Union{PrimaryKeyConstraint, Nothing} where {T<:Model}
    fields = Wasabi.fieldnames(m)
    return :id in fields ? PrimaryKeyConstraint(Symbol[:id]) : nothing
end

"""
    foreign_keys(m::Type{T})::Vector{ForeignKeyConstraint} where {T<:Model}
    Returns the foreign key constraints for the given model.
"""
function foreign_keys(m::Type{T})::Vector{ForeignKeyConstraint} where {T<:Model}
    return ForeignKeyConstraint[]
end

"""
    unique_constraints(m::Type{T})::Vector{UniqueConstraint} where {T<:Model}
    Returns the unique constraints for the given model.
"""
function unique_constraints(m::Type{T})::Vector{UniqueConstraint} where {T<:Model}
    return UniqueConstraint[]
end