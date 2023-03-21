var documenterSearchIndex = {"docs":
[{"location":"querybuilder/","page":"Query Builder","title":"Query Builder","text":"CurrentModule = Wasabi.QueryBuilder","category":"page"},{"location":"querybuilder/#QueryBuilder","page":"Query Builder","title":"QueryBuilder","text":"","category":"section"},{"location":"querybuilder/","page":"Query Builder","title":"Query Builder","text":"You can use QueryBuilder to create and execute a query in a simple and fast way.","category":"page"},{"location":"querybuilder/","page":"Query Builder","title":"Query Builder","text":"using Wasabi\n\nmutable struct User <: Wasabi.Model\n    id::Int\n    name::String\nend\n\nconfiguration = Wasabi.SQLiteConnectionConfiguration(\"test.db\")\nconn = Wasabi.connect(configuration)\n\nquery = QueryBuilder.select(User) |> QueryBuilder.limit(1)\nusers = Wasabi.df2model(User, Wasabi.execute_query(conn, user))","category":"page"},{"location":"querybuilder/","page":"Query Builder","title":"Query Builder","text":"Modules = [Wasabi.QueryBuilder]","category":"page"},{"location":"querybuilder/","page":"Query Builder","title":"Query Builder","text":"Modules = [Wasabi.QueryBuilder]","category":"page"},{"location":"querybuilder/#Wasabi.QueryBuilder.Join","page":"Query Builder","title":"Wasabi.QueryBuilder.Join","text":"Join{T<:Wasabi.Model}\nRepresents a join for the given model.\n\n\n\n\n\n","category":"type"},{"location":"querybuilder/#Wasabi.QueryBuilder.Query","page":"Query Builder","title":"Wasabi.QueryBuilder.Query","text":"Query{T<:Wasabi.Model}\nRepresents a query for the given model.\n\n\n\n\n\n","category":"type"},{"location":"querybuilder/#Wasabi.QueryBuilder.build-Tuple{Wasabi.QueryBuilder.Query}","page":"Query Builder","title":"Wasabi.QueryBuilder.build","text":"build(q::Query)::Tuple{RawQuery, Vector{Any}}\nBuilds the query and returns a tuple of the query string and the parameters.\n\n\n\n\n\n","category":"method"},{"location":"querybuilder/#Wasabi.QueryBuilder.groupby-Tuple{Vector{Symbol}}","page":"Query Builder","title":"Wasabi.QueryBuilder.groupby","text":"groupby(groupby::Vector{Symbol})\nSets the group by clause for the given query.\n\n\n\n\n\n","category":"method"},{"location":"querybuilder/#Wasabi.QueryBuilder.join-Union{Tuple{S}, Tuple{T}, Tuple{Type{T}, Type{S}, Symbol, Tuple{Symbol, Symbol}}, Tuple{Type{T}, Type{S}, Symbol, Tuple{Symbol, Symbol}, Vector{Symbol}}} where {T<:Wasabi.Model, S<:Wasabi.Model}","page":"Query Builder","title":"Wasabi.QueryBuilder.join","text":"join(m::Type{T}, type::Symbol, on::Tuple{Symbol, Symbol}, select::Vector{Symbol} = Symbol[]) where {T <: Model}\nJoins the given model to the query.\n\n\n\n\n\n","category":"method"},{"location":"querybuilder/#Wasabi.QueryBuilder.limit-Tuple{Int64}","page":"Query Builder","title":"Wasabi.QueryBuilder.limit","text":"limit(limit::Int)\nSets the limit for the given query.\n\n\n\n\n\n","category":"method"},{"location":"querybuilder/#Wasabi.QueryBuilder.offset-Tuple{Int64}","page":"Query Builder","title":"Wasabi.QueryBuilder.offset","text":"offset(offset::Int)\nSets the offset for the given query.\n\n\n\n\n\n","category":"method"},{"location":"querybuilder/#Wasabi.QueryBuilder.orderby-Tuple{Vector{Symbol}}","page":"Query Builder","title":"Wasabi.QueryBuilder.orderby","text":"orderby(orderby::Vector{Symbol})\nSets the order by clause for the given query.\n\n\n\n\n\n","category":"method"},{"location":"querybuilder/#Wasabi.QueryBuilder.select-Union{Tuple{Type{T}}, Tuple{T}, Tuple{Type{T}, Union{Nothing, Vector{Symbol}}}} where T<:Wasabi.Model","page":"Query Builder","title":"Wasabi.QueryBuilder.select","text":"select(source::Type{T}, select::Union{Vector{Symbol}, Nothing} = nothing)::Query where {T <: Model}\nCreates a new query for the given model and selected columns. If no columns are specified, all columns are selected.\n\n\n\n\n\n","category":"method"},{"location":"querybuilder/#Wasabi.QueryBuilder.where-Tuple{Expr}","page":"Query Builder","title":"Wasabi.QueryBuilder.where","text":"where(expr::Expr)\nSets the where clause for the given query.\n\n\n\n\n\n","category":"method"},{"location":"api/","page":"API","title":"API","text":"CurrentModule = Wasabi","category":"page"},{"location":"api/#API","page":"API","title":"API","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"","category":"page"},{"location":"api/","page":"API","title":"API","text":"Modules = [Wasabi]","category":"page"},{"location":"api/#Wasabi.alias-Tuple{String}","page":"API","title":"Wasabi.alias","text":"alias(m::String)\nReturns the alias of the table for the given model.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.alias-Union{Tuple{Type{T}}, Tuple{T}} where T<:Wasabi.Model","page":"API","title":"Wasabi.alias","text":"alias(m::Type{T}) where {T <: Model}\nReturns the alias of the table for the given model.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.all","page":"API","title":"Wasabi.all","text":"all(db::Any, m::Type{T}) where {T <: Model}\nReturns all rows of the given model.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.begin_transaction","page":"API","title":"Wasabi.begin_transaction","text":"begin_transaction(db::Any)\nBegins a transaction.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.colnames-Union{Tuple{Type{T}}, Tuple{T}} where T<:Wasabi.Model","page":"API","title":"Wasabi.colnames","text":"colnames(m::Type{T}) where {T <: Model}\nReturns the names of the columns for the given model.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.coltype-Union{Tuple{T}, Tuple{Dict{Type, String}, Type{T}, Symbol}} where T<:Wasabi.Model","page":"API","title":"Wasabi.coltype","text":"coltype(mapping::Dict{Type,String}, col::Symbol, m::Type{T})::String where {T <: Model}\nReturns the column type for the given column and model.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.commit!","page":"API","title":"Wasabi.commit!","text":"commit!(db::Any)\nCommits the current transaction.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.connect","page":"API","title":"Wasabi.connect","text":"connect(config::ConnectionConfiguration)\nConnects to the database using the given configuration.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.constraints-Union{Tuple{Type{T}}, Tuple{T}} where T<:Wasabi.Model","page":"API","title":"Wasabi.constraints","text":"constraints(m::Type{T}) where {T <: Model}\nReturns the constraints for the given model.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.create_schema","page":"API","title":"Wasabi.create_schema","text":"create_schema(db::Any, m::Type{T}) where {T <: Model}\nCreates the schema for the given model and constraints.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.delete!","page":"API","title":"Wasabi.delete!","text":"delete(db::Any, model::T) where {T <: Model}\nDeletes the given model from the database.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.delete_all!","page":"API","title":"Wasabi.delete_all!","text":"delete_all(db::Any, m::Type{T}) where {T <: Model}\nDeletes all rows from the given model.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.delete_schema","page":"API","title":"Wasabi.delete_schema","text":"delete_schema(db::Any, m::Type{T}) where {T <: Model}\nDeletes the schema for the given model.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.df2model-Union{Tuple{T}, Tuple{Type{T}, DataFrames.DataFrame}} where T<:Wasabi.Model","page":"API","title":"Wasabi.df2model","text":"df2model(m::Type{T}, df::DataFrame) where {T <: Model}\nConverts the given DataFrame to the given model.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.disconnect","page":"API","title":"Wasabi.disconnect","text":"disconnect(db::Any)\nDisconnects from the database.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.execute_query","page":"API","title":"Wasabi.execute_query","text":"execute_query(db::Any, query::RawQuery, params::Vector{Any})\nExecutes the given query with the given parameters.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.first","page":"API","title":"Wasabi.first","text":"first(db::Any, m::Type{T})\nReturns the first row of the given model with the given id.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.foreign_keys-Union{Tuple{Type{T}}, Tuple{T}} where T<:Wasabi.Model","page":"API","title":"Wasabi.foreign_keys","text":"foreign_keys(m::Type{T})::Vector{ForeignKeyConstraint} where {T<:Model}\nReturns the foreign key constraints for the given model.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.insert!","page":"API","title":"Wasabi.insert!","text":"insert(db::Any, model::T) where {T <: Model}\nInserts the given model into the database.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.isnullable-Union{Tuple{T}, Tuple{Type{T}, Symbol}} where T<:Wasabi.Model","page":"API","title":"Wasabi.isnullable","text":"isnullable(m::Type{T}, field::Symbol, constraints::Vector{S}) where {T <: Model,S<:Wasabi.ModelConstraint}\nReturns true if the given column is nullable.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.model2tuple-Tuple{T} where T<:Wasabi.Model","page":"API","title":"Wasabi.model2tuple","text":"model2tuple(m::T) where {T <: Model}\nConverts the given model to a tuple.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.primary_key-Union{Tuple{Type{T}}, Tuple{T}} where T<:Wasabi.Model","page":"API","title":"Wasabi.primary_key","text":"primary_key(m::Type{T})::Union{PrimaryKeyConstraint, Nothing} where {T<:Model}\nReturns the primary key constraint for the given model.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.rollback","page":"API","title":"Wasabi.rollback","text":"rollback(db::Any)\nRolls back the current transaction.\n\n\n\n\n\n","category":"function"},{"location":"api/#Wasabi.tablename-Tuple{String}","page":"API","title":"Wasabi.tablename","text":"tablename(m::String)\nReturns the name of the table for the given model.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.tablename-Union{Tuple{Type{T}}, Tuple{T}} where T<:Wasabi.Model","page":"API","title":"Wasabi.tablename","text":"tablename(m::Type{T}) where {T <: Model}\nReturns the name of the table for the given model.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.unique_constraints-Union{Tuple{Type{T}}, Tuple{T}} where T<:Wasabi.Model","page":"API","title":"Wasabi.unique_constraints","text":"unique_constraints(m::Type{T})::Vector{UniqueConstraint} where {T<:Model}\nReturns the unique constraints for the given model.\n\n\n\n\n\n","category":"method"},{"location":"api/#Wasabi.update!","page":"API","title":"Wasabi.update!","text":"update(db::Any, model::T) where {T <: Model}\nUpdates the given model in the database.\n\n\n\n\n\n","category":"function"},{"location":"migrations/","page":"Migrations","title":"Migrations","text":"CurrentModule = Wasabi.Migrations","category":"page"},{"location":"migrations/#Migrations","page":"Migrations","title":"Migrations","text":"","category":"section"},{"location":"migrations/","page":"Migrations","title":"Migrations","text":"Modules = [Wasabi.Migrations]","category":"page"},{"location":"migrations/","page":"Migrations","title":"Migrations","text":"Modules = [Wasabi.Migrations]","category":"page"},{"location":"migrations/#Wasabi.Migrations.execute-Tuple{Any, String, String}","page":"Migrations","title":"Wasabi.Migrations.execute","text":"execute(db::Any, path::String, target_version::String)\nExecutes the migrations to the target version.\n\n\n\n\n\n","category":"method"},{"location":"migrations/#Wasabi.Migrations.generate-Tuple{String}","page":"Migrations","title":"Wasabi.Migrations.generate","text":"generate(path::String)::String\nGenerates a new migration file.\n\n\n\n\n\n","category":"method"},{"location":"migrations/#Wasabi.Migrations.get_current_version-Tuple{Any}","page":"Migrations","title":"Wasabi.Migrations.get_current_version","text":"get_current_version(db::Any)::Union{String,Nothing}\nReturns the current version of the database.\n\n\n\n\n\n","category":"method"},{"location":"migrations/#Wasabi.Migrations.get_last_version-Tuple{String}","page":"Migrations","title":"Wasabi.Migrations.get_last_version","text":"get_last_version(path::String)::String\nReturns the last version of the database.\n\n\n\n\n\n","category":"method"},{"location":"migrations/#Wasabi.Migrations.get_versions-Tuple{String}","page":"Migrations","title":"Wasabi.Migrations.get_versions","text":"get_versions(path::String)::Vector{Tuple{String,Dates.DateTime}}\nReturns a vector of tuples containing the version and the creation date of each migration file.\n\n\n\n\n\n","category":"method"},{"location":"migrations/#Wasabi.Migrations.init-Tuple{String}","page":"Migrations","title":"Wasabi.Migrations.init","text":"init(path::String)::String\nInitializes the migrations directory.\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = Wasabi","category":"page"},{"location":"#Wasabi","page":"Home","title":"Wasabi","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Wasabi is a simple ORM for Julia. It currently supports PostgreSQL and SQLite. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Wasabi\n\nmutable struct User <: Wasabi.Model\n    id::Int\n    name::String\nend\n\nstruct UserProfile <: Wasabi.Model\n    id::Int\n    user_id::Int\n    bio::Union{String,Nothing}\nend\n\nuser_constraints = [\n    Wasabi.PrimaryKeyConstraint([:id])\n]\n\nuser_profile_constraints = [\n    Wasabi.PrimaryKeyConstraint([:id]),\n    Wasabi.ForeignKeyConstraint([:user_id], :user, [:id]),\n    Wasabi.UniqueConstraint([:user_id])\n]\n\nconfiguration = Wasabi.SQLiteConnectionConfiguration(\"test.db\")\nconn = Wasabi.connect(configuration)\n\nWasabi.create_schema(conn, User, user_constraints)\nWasabi.create_schema(conn, UserProfile, user_profile_constraints)\n\nuser = User(1, \"John Doe\")\nWasabi.insert!(conn, user)\n\nu = Wasabi.first(conn, User, 1)\n\nWasabi.begin_transaction(conn)\ntry\n    Wasabi.insert!(conn, user)\n    Wasabi.commit!(conn)\ncatch e\n    Wasabi.rollback(conn)\n    rethrow(e)\nend\n\nres = Wasabi.execute_query(conn, rq\"SELECT * FROM user where name = ?\", Any[\"John Doe\"])\nusers = Wasabi.df2model(User, res)\n\nu.name = \"Jane Doe\"\nWasabi.update!(conn, user)\n\nWasabi.delete!(conn, user)\n\nWasabi.disconnect(conn)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Documentation for Wasabi.","category":"page"}]
}
