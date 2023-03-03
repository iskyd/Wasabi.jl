using SQLite
using DataFrames
import Wasabi

export SQLiteConnectionConfiguration

MAPPING_TYPES = Dict{Type,String}(
    Int64 => "INTEGER",
    String => "TEXT"
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
    SQLite.execute(db, query)
end

function Wasabi.create_schema(db::SQLite.DB, m::Type{T}, constraints::Vector{S}=Wasabi.ModelConstraint[]) where {T<:Wasabi.Model,S<:Wasabi.ModelConstraint}
    columns = [(col, get_column_type(col, m)) for col in Wasabi.colnames(m)]
    query = "CREATE TABLE IF NOT EXISTS $(Wasabi.tablename(m)) ($(join([String(col[1]) * " " * col[2] * (Wasabi.isnullable(m, col[1], constraints) ? "" : " NOT NULL") for col in columns], ", "))"

    for constraint in constraints
        query = query * ", " * constraint_to_sql(constraint)
    end

    query = query * ")"

    SQLite.execute(db, query)

    return query
end

function get_column_type(col::Symbol, m::Type{T})::String where {T<:Wasabi.Model}
    t = Wasabi.coltype(m, col)
    if t isa Union
        t = union_types(t)[findfirst(x -> x != Nothing, union_types(t))]
    end
    return MAPPING_TYPES[t]
end

function constraint_to_sql(constraint::Wasabi.PrimaryKeyConstraint)::String
    return "PRIMARY KEY ($(join(constraint.fields, ", ")))"
end

function constraint_to_sql(constraint::Wasabi.ForeignKeyConstraint)::String
    return "FOREIGN KEY ($(join(constraint.fields, ", "))) REFERENCES $(constraint.foreign_table) ($(join(constraint.foreign_fields, ", ")))"
end

function constraint_to_sql(constraint::Wasabi.UniqueConstraint)::String
    return "UNIQUE ($(join(constraint.fields, ", ")))"
end

function Wasabi.execute_raw_query(db::SQLite.DB, query::String, params::Vector{Any}=Any[])
    return SQLite.DBInterface.execute(db, query, params) |> DataFrame
end

function Wasabi.begin_transaction(db::SQLite.DB)
    SQLite.execute(db, "BEGIN TRANSACTION")
end

function Wasabi.commit(db::SQLite.DB)
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

function Wasabi.insert(db::SQLite.DB, model::T) where {T<:Wasabi.Model}
    columns = filter(column -> column[2] !== nothing, Wasabi.model2tuple(model))
    fields = map(column -> column[1], columns)
    values = map(column -> column[2], columns)

    query = "INSERT INTO $(Wasabi.tablename(typeof(model))) ($(join(fields, ", "))) VALUES ($(join(fill("?", length(fields)), ", ")))"
    SQLite.DBInterface.execute(db, query, values)
end

function Wasabi.delete(db::SQLite.DB, model::T) where {T<:Wasabi.Model}
    query = "DELETE FROM $(Wasabi.tablename(typeof(model))) WHERE id = ?"
    SQLite.DBInterface.execute(db, query, Any[model.id])
end

function Wasabi.update(db::SQLite.DB, model::T) where {T<:Wasabi.Model}
    columns = filter(column -> column[2] !== nothing, Wasabi.model2tuple(model))
    fields = map(column -> column[1], columns)
    values = (map(column -> column[2], columns)..., model.id)

    query = "UPDATE $(Wasabi.tablename(typeof(model))) SET $(join([String(field) * " = ?" for field in fields], ", ")) WHERE id = ?"
    SQLite.DBInterface.execute(db, query, values)
end

function Wasabi.delete_all(db::SQLite.DB, m::Type{T}) where {T<:Wasabi.Model}
    query = "DELETE FROM $(Wasabi.tablename(m))"
    SQLite.DBInterface.execute(db, query)
end

function Wasabi.all(db::SQLite.DB, m::Type{T}) where {T<:Wasabi.Model}
    query = "SELECT * FROM $(Wasabi.tablename(m))"
    df = Wasabi.execute_raw_query(db, query)
    return Wasabi.df2model(m, df)
end