using SQLite
using DataFrames
using Mocking
using Wasabi: QueryBuilder

SQLITE_MAPPING_TYPES = Dict{Type,String}(
    Int64 => "INTEGER",
    String => "TEXT",
    Bool => "INTEGER",
    Float64 => "REAL",
    Any => "BLOB"
)

SQLITE_JOIN_MAPPING = Dict{Symbol,String}(
    :inner => "INNER JOIN",
    :left => "LEFT JOIN",
    :right => "RIGHT JOIN",
    :outer => "FULL OUTER JOIN"
)

struct SQLiteConnectionConfiguration <: Wasabi.ConnectionConfiguration
    dbname::String
end

function Wasabi.connect(config::SQLiteConnectionConfiguration)::SQLite.DB
    db = SQLite.DB(config.dbname)
    return db
end

function Wasabi.disconnect(db::SQLite.DB)::Nothing
    SQLite.close(db)
    return nothing
end

function Wasabi.delete_schema(db::SQLite.DB, m::Type{T}) where {T<:Wasabi.Model}
    query = "DROP TABLE IF EXISTS $(Wasabi.tablename(m))"
    @mock SQLite.execute(db, query)
end

function Wasabi.create_schema(db::SQLite.DB, m::Type{T}, constraints::Vector{S}=Wasabi.ModelConstraint[]) where {T<:Wasabi.Model,S<:Wasabi.ModelConstraint}
    columns = [(col, coltype(POSTGRES_MAPPING_TYPES, m, col)) for col in Wasabi.colnames(m)]
    query = "CREATE TABLE IF NOT EXISTS $(Wasabi.tablename(m)) ($(join([String(col[1]) * " " * col[2] * (Wasabi.isnullable(m, col[1]) ? "" : " NOT NULL") for col in columns], ", "))"

    for constraint in constraints
        query = query * ", " * sqlite_constraint_to_sql(constraint)
    end

    query = query * ")"

    @mock SQLite.execute(db, query)
end

function sqlite_constraint_to_sql(constraint::Wasabi.PrimaryKeyConstraint)::String
    return "PRIMARY KEY ($(join(constraint.fields, ", ")))"
end

function sqlite_constraint_to_sql(constraint::Wasabi.ForeignKeyConstraint)::String
    return "FOREIGN KEY ($(join(constraint.fields, ", "))) REFERENCES $(constraint.foreign_table) ($(join(constraint.foreign_fields, ", ")))"
end

function sqlite_constraint_to_sql(constraint::Wasabi.UniqueConstraint)::String
    return "UNIQUE ($(join(constraint.fields, ", ")))"
end

function Wasabi.execute_raw_query(db::SQLite.DB, query::T, params::Vector{Any}=Any[]) where {T<:AbstractString}
    SQLite.DBInterface.execute(db, query, params) |> DataFrame
end

function Wasabi.execute_query(db::SQLite.DB, q::QueryBuilder.Query)
    select = join(vcat(
        map(field -> "$(Wasabi.alias(q.source)).$(String(field))", q.select), 
        [join(map(field -> "$(Wasabi.alias(join_query.target)).$(String(field))", join_query.select), ", ") for join_query in q.joins]), ", "
    )
    groupby = isempty(q.groupby) ? "" : " GROUP BY " * join(q.groupby, ", ")
    orderby = isempty(q.orderby) ? "" : " ORDER BY " * join(q.orderby, ", ")
    limit = q.limit === nothing ? "" : " LIMIT " * string(q.limit)
    offset = q.offset === nothing ? "" : " OFFSET " * string(q.offset)
    joins_sql_query = join(map(join_query -> " $(SQLITE_JOIN_MAPPING[join_query.type]) $(Wasabi.tablename(join_query.target)) $(Wasabi.alias(join_query.target)) ON $(Wasabi.alias(join_query.source)).$(join_query.on[1]) = $(Wasabi.alias(join_query.target)).$(join_query.on[2])", q.joins), " ")

    sql_query = strip(replace("SELECT $select FROM $(Wasabi.tablename(q.source)) $(Wasabi.alias(q.source)) $joins_sql_query $groupby $orderby $limit $offset", r"(\s{2,})" => " "))
    
    @mock Wasabi.execute_raw_query(db, sql_query)
end

function Wasabi.begin_transaction(db::SQLite.DB)
    SQLite.execute(db, "BEGIN TRANSACTION")
end

function Wasabi.commit!(db::SQLite.DB)
    SQLite.execute(db, "COMMIT TRANSACTION")
end

function Wasabi.rollback(db::SQLite.DB)
    SQLite.execute(db, "ROLLBACK TRANSACTION")
end

function Wasabi.first(db::SQLite.DB, m::Type{T}, id) where {T<:Wasabi.Model}
    query = "SELECT * FROM $(Wasabi.tablename(m)) WHERE id = ? LIMIT 1"
    df = Wasabi.execute_raw_query(db, query, Any[id])
    if size(df, 1) == 0
        return nothing
    end

    return Wasabi.df2model(m, df)[1]
end

function Wasabi.insert!(db::SQLite.DB, model::T) where {T<:Wasabi.Model}
    columns = filter(column -> column[2] !== nothing, Wasabi.model2tuple(model))
    fields = map(column -> column[1], columns)
    values = map(column -> column[2], columns)

    query = "INSERT INTO $(Wasabi.tablename(typeof(model))) ($(join(fields, ", "))) VALUES ($(join(fill("?", length(fields)), ", ")))"
    SQLite.DBInterface.execute(db, query, values)
end

function Wasabi.delete!(db::SQLite.DB, model::T) where {T<:Wasabi.Model}
    query = "DELETE FROM $(Wasabi.tablename(typeof(model))) WHERE id = ?"
    SQLite.DBInterface.execute(db, query, Any[model.id])
end

function Wasabi.update!(db::SQLite.DB, model::T) where {T<:Wasabi.Model}
    columns = filter(column -> column[2] !== nothing, Wasabi.model2tuple(model))
    fields = map(column -> column[1], columns)
    values = (map(column -> column[2], columns)..., model.id)

    query = "UPDATE $(Wasabi.tablename(typeof(model))) SET $(join([String(field) * " = ?" for field in fields], ", ")) WHERE id = ?"
    SQLite.DBInterface.execute(db, query, values)
end

function Wasabi.delete_all!(db::SQLite.DB, m::Type{T}) where {T<:Wasabi.Model}
    query = "DELETE FROM $(Wasabi.tablename(m))"
    SQLite.DBInterface.execute(db, query)
end

function Wasabi.all(db::SQLite.DB, m::Type{T}) where {T<:Wasabi.Model}
    query = "SELECT * FROM $(Wasabi.tablename(m))"
    df = Wasabi.execute_raw_query(db, query)
    return Wasabi.df2model(m, df)
end