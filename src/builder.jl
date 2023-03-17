module QueryBuilder

using Wasabi

"""
    Join{T<:Wasabi.Model}
    Represents a join for the given model.
"""
Base.@kwdef struct Join{T<:Wasabi.Model, S<:Wasabi.Model}
    source::Type{T}
    target::Type{S}
    type::Symbol
    on::Tuple{Symbol,Symbol}
    select::Vector{Symbol}
end

"""
    Query{T<:Wasabi.Model}
    Represents a query for the given model.
"""
Base.@kwdef mutable struct Query{T<:Wasabi.Model}
    source::Type{T}
    select::Vector{Symbol}
    groupby::Vector{Symbol} = Symbol[]
    orderby::Vector{Symbol} = Symbol[]
    limit::Union{Nothing,Int} = nothing
    offset::Union{Nothing,Int} = nothing
    joins::Vector{Join} = Join[]
end

"""
    select(source::Type{T}, select::Union{Vector{Symbol}, Nothing} = nothing)::Query where {T <: Model}
    Creates a new query for the given model and selected columns. If no columns are specified, all columns are selected.
"""
function select(source::Type{T}, select::Union{Vector{Symbol},Nothing}=nothing) where {T<:Wasabi.Model}
    if select === nothing
        select = Wasabi.colnames(source)
    end
    Query(source=source, select=select)
end

"""
    limit(limit::Int)
    Sets the limit for the given query.
"""
function limit(limit::Int)
    return function(q::Query)
        q.limit = limit
        q
    end
end

"""
    offset(offset::Int)
    Sets the offset for the given query.
"""
function offset(offset::Int)
    return function(q::Query)
        q.offset = offset
        q
    end
end

"""
    orderby(orderby::Vector{Symbol})
    Sets the order by clause for the given query.
"""
function orderby(orderby::Vector{Symbol})
    return function(q::Query)
        q.orderby = orderby
        q
    end
end

"""
    groupby(groupby::Vector{Symbol})
    Sets the group by clause for the given query.
"""
function groupby(groupby::Vector{Symbol})
    return function(q::Query)
        q.groupby = groupby
        q
    end
end

"""
    join(m::Type{T}, type::Symbol, on::Tuple{Symbol, Symbol}, select::Vector{Symbol} = Symbol[]) where {T <: Model}
    Joins the given model to the query.
"""
function join(source::Type{T}, target::Type{S}, type::Symbol, on::Tuple{Symbol,Symbol}, select::Vector{Symbol}=Symbol[]) where {T<:Wasabi.Model, S<:Wasabi.Model}
    return function(q::Query)
        push!(q.joins, Join(source=source, target=target, type=type, on=on, select=select))
        q
    end
end

end