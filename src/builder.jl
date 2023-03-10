module QueryBuilder

using Wasabi

Base.@kwdef mutable struct Query{T<:Wasabi.Model}
    source::Type{T}
    select::Vector{Symbol}
    groupby::Vector{Symbol} = Symbol[]
    orderby::Vector{Symbol} = Symbol[]
    limit::Union{Nothing,Int} = nothing
    offset::Union{Nothing,Int} = nothing
end

function select(source::Type{T}, select::Union{Vector{Symbol}, Nothing} = nothing) where {T<:Wasabi.Model}
    if select === nothing
        select = Wasabi.colnames(source)
    end
    Query(source=source, select=select)
end

function limit(q::Query, limit::Int)::Query
    q.limit = limit
    q
end

function offset(q::Query, offset::Int)::Query
    q.offset = offset
    q
end

end