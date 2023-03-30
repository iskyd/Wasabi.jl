using SQLite
using DataFrames
using Mocking
using Dates
using Wasabi: QueryBuilder

Wasabi.mapping(db::Type{SQLite.DB}, t::Type{Int64}) = "INTEGER"
Wasabi.mapping(db::Type{SQLite.DB}, t::Type{String}) = "TEXT"
Wasabi.mapping(db::Type{SQLite.DB}, t::Type{Bool}) = "INTEGER"
Wasabi.mapping(db::Type{SQLite.DB}, t::Type{Float64}) = "REAL"
Wasabi.mapping(db::Type{SQLite.DB}, t::Type{Any}) = "BLOB"
Wasabi.mapping(db::Type{SQLite.DB}, t::Type{Date}) = "TEXT"
Wasabi.mapping(db::Type{SQLite.DB}, t::Type{DateTime}) = "TEXT"

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

function Wasabi.create_schema(db::SQLite.DB, m::Type{T}) where {T<:Wasabi.Model}
    columns = [(col, Wasabi.mapping(SQLite.DB, coltype(m, col))) for col in Wasabi.colnames(m)]
    query = "CREATE TABLE IF NOT EXISTS $(Wasabi.tablename(m)) ($(join([String(col[1]) * " " * col[2] * (Wasabi.isnullable(m, col[1]) ? "" : " NOT NULL") for col in columns], ", "))"

    constraints = Wasabi.constraints(m)
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

function Wasabi.execute_query(db::SQLite.DB, query::RawQuery, params::Vector{Any}=Any[])
    SQLite.DBInterface.execute(db, query.value, params) |> DataFrame
end

function Wasabi.execute_query(db::SQLite.DB, q::QueryBuilder.Query)
    @mock Wasabi.execute_query(db, QueryBuilder.build(q)...)
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
    query = RawQuery("SELECT * FROM $(Wasabi.tablename(m)) WHERE id = \$1 LIMIT 1")
    df = Wasabi.execute_query(db, query, Any[id])
    if size(df, 1) == 0
        return nothing
    end

    return Wasabi.df2model(m, df)[1]
end

function Wasabi.insert!(db::SQLite.DB, model::T) where {T<:Wasabi.Model}
    columns = filter(column -> column[2] !== nothing, Wasabi.model2tuple(model))
    fields = map(column -> column[1], columns)
    values = map(column -> Wasabi.to_sql_value(column[2]), columns)

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
    values = (map(column -> Wasabi.to_sql_value(column[2]), columns)..., model.id)

    query = "UPDATE $(Wasabi.tablename(typeof(model))) SET $(join([String(field) * " = ?" for field in fields], ", ")) WHERE id = ?"
    SQLite.DBInterface.execute(db, query, values)
end

function Wasabi.delete_all!(db::SQLite.DB, m::Type{T}) where {T<:Wasabi.Model}
    query = "DELETE FROM $(Wasabi.tablename(m))"
    SQLite.DBInterface.execute(db, query)
end

function Wasabi.all(db::SQLite.DB, m::Type{T}) where {T<:Wasabi.Model}
    query = RawQuery("SELECT * FROM $(Wasabi.tablename(m))")
    df = Wasabi.execute_query(db, query)
    return Wasabi.df2model(m, df)
end