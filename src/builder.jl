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
    where::Union{Expr, Nothing} = nothing
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

"""
    where(expr::Expr)
    Sets the where clause for the given query.
"""
function where(expr::Expr)
    return function(q::Query)
        q.where = expr
        q
    end
end

function build_where_expr(e::Expr; top=true)
    args = e.args
    if args[1] == :and || args[1] == :or
        return (top == true ? "WHERE " : "") * "(" * Base.join(map(x -> build_where_expr(x, top=false), args[2:end]), " $(string(args[1])) ") * ")"
    else
        model, field, rel, value = args
        return "$(Wasabi.alias(eval(model))).$(string(field)) $(string(rel)) $(string(value))"
    end
end

function build(q::Query)
    select = Base.join(vcat(
        map(field -> "$(Wasabi.alias(q.source)).$(String(field))", q.select), 
        [Base.join(map(field -> "$(Wasabi.alias(join_query.target)).$(String(field))", join_query.select), ", ") for join_query in q.joins]), ", "
    )
    groupby = isempty(q.groupby) ? "" : " GROUP BY " * Base.join(q.groupby, ", ")
    orderby = isempty(q.orderby) ? "" : " ORDER BY " * Base.join(q.orderby, ", ")
    limit = q.limit === nothing ? "" : " LIMIT " * string(q.limit)
    offset = q.offset === nothing ? "" : " OFFSET " * string(q.offset)
    joins = Base.join(map(join_query -> " $(uppercase(string(join_query.type))) JOIN \"$(Wasabi.tablename(join_query.target))\" $(Wasabi.alias(join_query.target)) ON $(Wasabi.alias(join_query.source)).$(join_query.on[1]) = $(Wasabi.alias(join_query.target)).$(join_query.on[2])", q.joins), " ")
    q_where = q.where === nothing ? "" : build_where_expr(q.where)
    
    sql_query = strip(replace("SELECT $select FROM \"$(Wasabi.tablename(q.source))\" $(Wasabi.alias(q.source)) $joins $q_where $groupby $orderby $limit $offset", r"(\s{2,})" => " "))

    return Wasabi.RawQuery(sql_query)
end

end