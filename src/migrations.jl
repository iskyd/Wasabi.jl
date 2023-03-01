using Random
using Dates

struct Migration <: Wasabi.Model
    version::String
end

constraints = [
    Wasabi.UniqueConstraint([:version])
]

function get_versions(path::String)::Vector{Tuple{String,Dates.DateTime}}
    versions = Tuple{String,Dates.DateTime}[]
    created_at_reg = r"Created at: ([A-Za-z0-9\-:.]+)"
    for version in readdir(path)
        open(joinpath(path, version)) do f
            content = read(f, String)
            created_at = match(created_at_reg, content)[1]

            push!(versions, (version, Dates.DateTime(created_at)))
        end
    end

    return versions
end

function migrate(db::Any, path::String)
    current_version = nothing
    try
        res = Wasabi.all(db, Migration)
        current_version = res[1].version
    catch e
        current_version = nothing
    end

    versions = get_versions(path)
    sort!(versions, by=x -> x[2], rev=false)

    if current_version !== nothing
        cur_idx = findfirst(x -> replace(x[1], ".jl" => "") == current_version, versions)
        versions = versions[cur_idx+1:end]
    end

    try
        Wasabi.begin_transaction(db)
        for (version, _) in versions
            include(joinpath(path, version))
            Base.invokelatest(up, db)
        end

        new_version = replace(versions[end][1], ".jl" => "")

        Wasabi.delete_all(db, Migration)

        migration = Migration(new_version)
        Wasabi.insert(db, migration)

        Wasabi.commit(db)
    catch e
        Wasabi.rollback(db)
        rethrow(e)
    end
end

function get_last_version(path::String)
    versions = get_versions(path)
    sort!(versions, by=x->x[2], rev=true)
    return replace(versions[1][1], ".jl" => "")
end

function generate_migration(path::String)::String
    version = randstring()
    last_version = get_last_version(path)
    created_at = Dates.format(now(), "yyyy-mm-ddTHH:MM:SS.sss")

    content = """
    using Wasabi

    # Created at: $created_at

    down_version = "$last_version"

    function up(db::Any)
    end

    function down(db::Any)
    end
    """

    open(joinpath(path, version * ".jl"), "w") do f
        write(f, content)
    end

    return version
end

function init_migration(path::String)::String
    if length(readdir(path)) > 0
        error("Directory is not empty")
    end

    version = randstring()
    created_at = Dates.format(now(), "yyyy-mm-ddTHH:MM:SS.sss")

    content = """
    using Wasabi

    # Created at: $created_at

    down_version = nothing

    function up(db::Any)
        constraints = [
            Wasabi.UniqueConstraint([:version])
        ]
        Wasabi.create_schema(db, Migration, constraints)
    end

    function down(db::Any)
        Wasabi.delete_schema(db, Migration)
    end
    """

    open(joinpath(path, version * ".jl"), "w") do f
        write(f, content)
    end

    return version
end