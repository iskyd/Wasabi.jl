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

"""
    delete_schema(db::Any, m::Type{T}) where {T <: Model}
    Deletes the schema for the given model.
"""
function Wasabi.delete_schema(db::SQLite.DB, m::Type{T}) where {T<:Wasabi.Model}
    query = "DROP TABLE IF EXISTS $(Wasabi.tablename(m))"
    SQLite.execute(db, query)
end

"""
    create_schema(db::Any, m::Type{T}, constraints::Vector{ModelConstraint}) where {T <: Model}
    Creates the schema for the given model.
    Returns the query used to create the schema.
"""
function Wasabi.create_schema(db::SQLite.DB, m::Type{T}, constraints::Vector{S}=Wasabi.ModelConstraint[]) where {T<:Wasabi.Model,S<:Wasabi.ModelConstraint}
    columns = [(col, MAPPING_TYPES[Wasabi.coltype(m, col)], any(constraint -> constraint isa Wasabi.NotNullConstraint && col in constraint.fields, constraints)) for col in Wasabi.colnames(m)]
    query = "CREATE TABLE IF NOT EXISTS $(Wasabi.tablename(m)) ($(join([String(col[1]) * " " * col[2] * (col[3] == 1 ? " NOT NULL" : "") for col in columns], ", "))"

    for constraint in constraints
        if !(constraint isa Wasabi.NotNullConstraint)
            query = query * ", " * constraint_to_sql(constraint)
        end
    end

    query = query * ")"

    SQLite.execute(db, query)

    return query
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

function constraint_to_sql(constraint::Wasabi.NotNullConstraint)::String
    return "NOT NULL ($(join(constraint.fields, ", ")))"
end

"""
    execute_query(db::SQLite.DB, query::String, params::Vector{Any})
    Executes the given query with the given parameters.
"""
function Wasabi.execute_query(db::SQLite.DB, query::String, params::Vector{Any}=Any[])
    return SQLite.DBInterface.execute(db, query, params) |> DataFrame
end