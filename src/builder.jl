abstract type Query end

mutable struct SelectQuery{T<:Model} <: Query
    model::Type{T}
    columns::Vector{Symbol}
    limit::Union{Int,Nothing}
    offset::Union{Int,Nothing}

    function SelectQuery(model::Type{T}, columns::Vector{Symbol}, limit::Union{Int,Nothing}, offset::Union{Int,Nothing}) where {T<:Model}
        new{T}(model, columns, limit, offset)
    end
end

function first(model::Type{T}, id::Int)::SelectQuery where {T<:Model}
    SelectQuery(model, Wasabi.colnames(model), 1, nothing)
end