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
    limit(q::Query, limit::Int)::Query
    Sets the limit for the given query.
"""
function limit(q::Query, limit::Int)::Query
    q.limit = limit
    q
end

"""
    offset(q::Query, offset::Int)::Query
    Sets the offset for the given query.
"""
function offset(q::Query, offset::Int)::Query
    q.offset = offset
    q
end

"""
    orderby(q::Query, orderby::Vector{Symbol})::Query
    Sets the order by clause for the given query.
"""
function orderby(q::Query, orderby::Vector{Symbol})::Query
    q.orderby = orderby
    q
end

"""
    groupby(q::Query, groupby::Vector{Symbol})::Query
    Sets the group by clause for the given query.
"""
function groupby(q::Query, groupby::Vector{Symbol})::Query
    q.groupby = groupby
    q
end

"""
    join(q::Query, m::Type{T}, type::Symbol, on::Tuple{Symbol, Symbol}, select::Vector{Symbol} = Symbol[]) where {T <: Model}
    Joins the given model to the query.
"""
function join(q::Query, source::Type{T}, target::Type{S}, type::Symbol, on::Tuple{Symbol,Symbol}, select::Vector{Symbol}=Symbol[]) where {T<:Wasabi.Model, S<:Wasabi.Model}
    push!(q.joins, Join(source=source, target=target, type=type, on=on, select=select))
    q
end

end