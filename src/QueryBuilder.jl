module QueryBuilder

using Wasabi

REL_MAPPING = Dict(
    :eq => "=",
    :neq => "<>",
    :lt => "<",
    :lte => "<=",
    :gt => ">",
    :gte => ">=",
    :in => "IN",
    :notin => "NOT IN",
    :like => "LIKE",
    :notlike => "NOT LIKE",
    :ilike => "ILIKE",
    :notilike => "NOT ILIKE",
    :is => "IS",
    :isnot => "IS NOT",
    :between => "BETWEEN",
    :notbetween => "NOT BETWEEN",
    :overlap => "&&",
    :contains => "@>",
    :containedby => "<@",
    :any => "ANY",
    :all => "ALL",
    :some => "SOME"
)

FN_MAPPING = Dict(
    :count => "COUNT",
    :sum => "SUM",
    :avg => "AVG",
    :min => "MIN",
    :max => "MAX"
)

"""
    Join{T<:Wasabi.Model}
    Represents a join for the given model.
"""
Base.@kwdef struct Join{T<:Wasabi.Model,S<:Wasabi.Model}
    source::Type{T}
    target::Type{S}
    type::Symbol
    on::Tuple{Symbol,Symbol}
end

"""
    SelectExpr{T<:Wasabi.Model}
    Represents a select expression for the given model.
"""
Base.@kwdef struct SelectExpr{T<:Wasabi.Model}
    source::Type{T}
    field::Symbol
    alias::Union{Symbol,Nothing} = nothing
    fn::Union{Symbol,Nothing} = nothing
end

"""
    Query{T<:Wasabi.Model}
    Represents a query for the given model.
"""
Base.@kwdef mutable struct Query{T<:Wasabi.Model}
    source::Type{T}
    select::Vector{SelectExpr} = SelectExpr[]
    groupby::Vector{Symbol} = Symbol[]
    orderby::Vector{Symbol} = Symbol[]
    limit::Union{Nothing,Int} = nothing
    offset::Union{Nothing,Int} = nothing
    joins::Vector{Join} = Join[]
    where::Union{Expr,Nothing} = nothing
end

"""
    from(source::Type{T})::Query where {T <: Model}
    Creates a new query for the given model.
"""
function from(source::Type{T}) where {T<:Wasabi.Model}
    return Query(source=source)
end

"""
    select(select::Union{Vector{Symbol}, Nothing} = nothing)
    Sets the selected columns for the given query. If no columns are specified, all columns are selected.
"""
function select(select::Union{Vector{Symbol},Nothing}=nothing)
    return function (q::Query)
        if select === nothing
            select = filter(col -> !(col in Wasabi.exclude_fields(q.source)), Wasabi.colnames(q.source))
        end
        q.select = vcat(q.select, [SelectExpr(source=q.source, field=col) for col in select])
        q
    end
end

"""
    selectselect(source::Type{T}, field::Symbol, alias::Union{Symbol, Nothing} = nothing, fn::Union{Symbol, Nothing} = nothing) where {T<:Wasabi.Model}
    Sets the selected columns for the given query.
"""
function select(source::Type{T}, field::Symbol, alias::Union{Symbol,Nothing}=nothing, fn::Union{Symbol,Nothing}=nothing) where {T<:Wasabi.Model}
    return function (q::Query)
        push!(q.select, SelectExpr(source=source, field=field, alias=alias, fn=fn))
        q
    end
end

"""
    select(source::Type{T}, select::Vector{Symbol})
    Sets the selected columns for the given query.
"""
function select(source::Type{T}, select::Vector{Symbol}) where {T<:Wasabi.Model}
    return function (q::Query)
        q.select = vcat(q.select, [SelectExpr(source=source, field=col) for col in select])
        q
    end
end

"""
    limit(limit::Int)
    Sets the limit for the given query.
"""
function limit(limit::Int)
    return function (q::Query)
        q.limit = limit
        q
    end
end

"""
    offset(offset::Int)
    Sets the offset for the given query.
"""
function offset(offset::Int)
    return function (q::Query)
        q.offset = offset
        q
    end
end

"""
    orderby(orderby::Vector{Symbol})
    Sets the order by clause for the given query.
"""
function orderby(orderby::Vector{Symbol})
    return function (q::Query)
        q.orderby = orderby
        q
    end
end

"""
    groupby(groupby::Vector{Symbol})
    Sets the group by clause for the given query.
"""
function groupby(groupby::Vector{Symbol})
    return function (q::Query)
        q.groupby = groupby
        q
    end
end

"""
    join(m::Type{T}, type::Symbol, on::Tuple{Symbol, Symbol}, select_fields::Vector{Symbol} = Symbol[]) where {T <: Model}
    Joins the given model to the query.
"""
function join(source::Type{T}, target::Type{S}, type::Symbol, on::Tuple{Symbol,Symbol}, select_fields::Vector{Symbol}=Symbol[]) where {T<:Wasabi.Model,S<:Wasabi.Model}
    return function (q::Query)
        push!(q.joins, Join(source=source, target=target, type=type, on=on))
        q = q |> select(target, select_fields)
        q
    end
end

"""
    where(expr::Expr)
    Sets the where clause for the given query.
"""
function where(expr::Expr)
    return function (q::Query)
        q.where = expr
        q
    end
end

function build_where_expr(e::Expr, params::Vector{Any}; top=true)
    args = e.args
    if args[1] == :and || args[1] == :or
        return (top == true ? "WHERE " : "") * "(" * Base.join(map(x -> build_where_expr(x, params, top=false), args[2:end]), " $(uppercase(string(args[1]))) ") * ")"
    else
        model, field, rel, value = args
        p = eval(value)
        if typeof(p) <: AbstractArray || typeof(p) <: Tuple
            push!(params, p...)
            return "$(Wasabi.alias(string(model))).$(string(field)) $(REL_MAPPING[rel]) ($(Base.join(map(v -> "\$$(length(params) - length(p) + v[1])", enumerate(p)), ", ")))"
        else
            push!(params, p)
            return "$(Wasabi.alias(string(model))).$(string(field)) $(REL_MAPPING[rel]) \$$(length(params))"
        end
    end
end

function build_select_expr(s::SelectExpr)
    if s.fn === nothing
        return "$(Wasabi.alias(s.source)).$(String(s.field))" * (s.alias === nothing ? "" : " AS $(String(s.alias))")
    else
        return "$(FN_MAPPING[s.fn])($(Wasabi.alias(s.source)).$(String(s.field)))" * (s.alias === nothing ? "" : " AS $(String(s.alias))")
    end
end

"""
    build(q::Query)::Tuple{RawQuery, Vector{Any}}
    Builds the query and returns a tuple of the query string and the parameters.
"""
function build(q::Query)
    params = Any[]
    select = Base.join(map(s -> build_select_expr(s), q.select), ", ")
    groupby = isempty(q.groupby) ? "" : " GROUP BY " * Base.join(q.groupby, ", ")
    orderby = isempty(q.orderby) ? "" : " ORDER BY " * Base.join(q.orderby, ", ")
    limit = q.limit === nothing ? "" : " LIMIT " * string(q.limit)
    offset = q.offset === nothing ? "" : " OFFSET " * string(q.offset)
    joins = Base.join(map(join_query -> " $(uppercase(string(join_query.type))) JOIN \"$(Wasabi.tablename(join_query.target))\" $(Wasabi.alias(join_query.target)) ON $(Wasabi.alias(join_query.source)).$(join_query.on[1]) = $(Wasabi.alias(join_query.target)).$(join_query.on[2])", q.joins), " ")
    q_where = q.where === nothing ? "" : build_where_expr(q.where, params)

    sql_query = strip(replace("SELECT $select FROM \"$(Wasabi.tablename(q.source))\" $(Wasabi.alias(q.source)) $joins $q_where $groupby $orderby $limit $offset", r"(\s{2,})" => " "))

    return Wasabi.RawQuery(sql_query), params
end

end