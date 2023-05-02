Base.@kwdef struct SQLiteConnectionConfiguration <: ConnectionConfiguration
    dbname::String
end

Base.@kwdef struct PostgreSQLConnectionConfiguration <: ConnectionConfiguration
    endpoint::String
    username::String
    password::String
    port::Int
    dbname::String
end