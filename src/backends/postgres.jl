using DataFrames
using LibPQ
using Mocking
using Dates
using Wasabi: QueryBuilder

Wasabi.mapping(db::Type{LibPQ.Connection}, t::Type{Int64}) = "INTEGER"
Wasabi.mapping(db::Type{LibPQ.Connection}, t::Type{String}) = "TEXT"
Wasabi.mapping(db::Type{LibPQ.Connection}, t::Type{Bool}) = "BOOLEAN"
Wasabi.mapping(db::Type{LibPQ.Connection}, t::Type{Float64}) = "REAL"
Wasabi.mapping(db::Type{LibPQ.Connection}, t::Type{Any}) = "BLOB"
Wasabi.mapping(db::Type{LibPQ.Connection}, t::Type{Date}) = "DATE"
Wasabi.mapping(db::Type{LibPQ.Connection}, t::Type{DateTime}) = "TIMESTAMP"
Wasabi.mapping(db::Type{LibPQ.Connection}, t::Type{AutoIncrement}) = "SERIAL"

Base.@kwdef struct PostgreSQLConnectionConfiguration <: Wasabi.ConnectionConfiguration
    endpoint::String
    username::String
    password::String
    port::Int
    dbname::String
end

function Wasabi.connect(config::PostgreSQLConnectionConfiguration)::LibPQ.Connection
    LibPQ.Connection(
        "host=" * config.endpoint * " user=" * config.username * " password=" * config.password * " port=" * string(config.port) * " dbname=" * config.dbname
    )
end

Wasabi.disconnect(conn::LibPQ.Connection)::Nothing = LibPQ.close(conn)

function Wasabi.delete_schema(conn::LibPQ.Connection, m::Type{T}) where {T<:Wasabi.Model}
    query = "DROP TABLE IF EXISTS \"$(Wasabi.tablename(m))\""
    @mock LibPQ.execute(conn, query)
end

function Wasabi.create_schema(conn::LibPQ.Connection, m::Type{T}) where {T<:Wasabi.Model}
    columns = [(col, Wasabi.mapping(LibPQ.Connection, coltype(m, col))) for col in Wasabi.colnames(m)]
    query = "CREATE TABLE IF NOT EXISTS \"$(Wasabi.tablename(m))\" ($(join([String(col[1]) * " " * col[2] * (Wasabi.isnullable(m, col[1]) ? "" : " NOT NULL") for col in columns], ", "))"

    constraints = Wasabi.constraints(m)
    for constraint in constraints
        query = query * ", " * postgres_constraint_to_sql(constraint)
    end

    query = query * ")"

    @mock LibPQ.execute(conn, query)
end

function postgres_constraint_to_sql(constraint::Wasabi.PrimaryKeyConstraint)::String
    return "PRIMARY KEY ($(join(constraint.fields, ", ")))"
end

function postgres_constraint_to_sql(constraint::Wasabi.ForeignKeyConstraint)::String
    return "FOREIGN KEY ($(join(constraint.fields, ", "))) REFERENCES \"$(constraint.foreign_table)\" ($(join(constraint.foreign_fields, ", ")))"
end

function postgres_constraint_to_sql(constraint::Wasabi.UniqueConstraint)::String
    return "UNIQUE ($(join(constraint.fields, ", ")))"
end

function Wasabi.execute_query(conn::LibPQ.Connection, query::RawQuery, params::Vector{Any}=Any[])
    return LibPQ.execute(conn, query.value, params) |> DataFrame
end

function Wasabi.execute_query(db::LibPQ.Connection, q::QueryBuilder.Query)
    @mock Wasabi.execute_query(db, QueryBuilder.build(q)...)
end

function Wasabi.begin_transaction(conn::LibPQ.Connection)
    LibPQ.execute(conn, "BEGIN TRANSACTION")
end

function Wasabi.commit!(conn::LibPQ.Connection)
    LibPQ.execute(conn, "COMMIT TRANSACTION")
end

function Wasabi.rollback(conn::LibPQ.Connection)
    LibPQ.execute(conn, "ROLLBACK TRANSACTION")
end

function Wasabi.first(conn::LibPQ.Connection, m::Type{T}, id) where {T<:Wasabi.Model}
    query = RawQuery("SELECT * FROM \"$(Wasabi.tablename(m))\" WHERE id = \$1 LIMIT 1")
    df = Wasabi.execute_query(conn, query, Any[id])
    if size(df, 1) == 0
        return nothing
    end

    return Wasabi.df2model(m, df)[1]
end

function Wasabi.insert!(conn::LibPQ.Connection, model::T) where {T<:Wasabi.Model}
    columns = filter(column -> column[2] !== nothing, Wasabi.model2tuple(model))
    fields = map(column -> column[1], columns)
    values = map(column -> Wasabi.to_sql_value(column[2]), columns)

    primary_keys = Wasabi.primary_key(typeof(model))
    primary_key_fields = primary_keys !== nothing ? primary_keys.fields : []

    query = "INSERT INTO \"$(Wasabi.tablename(typeof(model)))\" ($(join(fields, ", "))) VALUES ($(join(["\$$i" for i in 1:length(fields)], ", ")))" * (length(primary_key_fields) > 0 ? (" RETURNING " * join(primary_key_fields, ", ")) : "")
    keys = LibPQ.execute(conn, query, values) |> DataFrame

    if ismutabletype(typeof(model))
        for primary_key in primary_key_fields
            setproperty!(model, primary_key, Wasabi.from_sql_value(Wasabi.coltype(typeof(model), primary_key), keys[1, primary_key]))
        end
    end

    return keys
end

function Wasabi.delete!(conn::LibPQ.Connection, model::T) where {T<:Wasabi.Model}
    query = "DELETE FROM \"$(Wasabi.tablename(typeof(model)))\" WHERE id = \$1"
    LibPQ.execute(conn, query, Any[Wasabi.to_sql_value(model.id)])
end

function Wasabi.update!(conn::LibPQ.Connection, model::T) where {T<:Wasabi.Model}
    columns = filter(column -> column[2] !== nothing, Wasabi.model2tuple(model))
    fields = map(column -> column[1], columns)
    values = (map(column -> Wasabi.to_sql_value(column[2]), columns)..., Wasabi.to_sql_value(model.id))

    query = "UPDATE \"$(Wasabi.tablename(typeof(model)))\" SET $(join([String(fields[i]) * " = \$$i" for i in 1:length(fields)], ", ")) WHERE id = \$$(length(fields) + 1)"
    LibPQ.execute(conn, query, values)
end

function Wasabi.delete_all!(conn::LibPQ.Connection, m::Type{T}) where {T<:Wasabi.Model}
    query = "DELETE FROM \"$(Wasabi.tablename(m))\""
    LibPQ.execute(conn, query)
end

function Wasabi.all(conn::LibPQ.Connection, m::Type{T}) where {T<:Wasabi.Model}
    query = RawQuery("SELECT * FROM \"$(Wasabi.tablename(m))\"")
    df = Wasabi.execute_query(conn, query)
    return Wasabi.df2model(m, df)
end