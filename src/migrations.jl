module Migrations

using Wasabi
using Random
using Dates

struct Migration <: Wasabi.Model
    version::String
end

struct MigrationFileNotFound <: Exception
    path::String
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

            push!(versions, (replace(version, ".jl" => ""), Dates.DateTime(created_at)))
        end
    end

    return versions
end

function get_current_version(db::Any)
    try
        res = Wasabi.all(db, Migration)
        return res[1].version
    catch e
        return nothing
    end
end

function get_last_version(path::String)
    versions = get_versions(path)
    sort!(versions, by=x -> x[2], rev=true)
    return replace(versions[1][1], ".jl" => "")
end

function execute(db::Any, path::String, target_version::String)
    current_version = get_current_version(db)
    if !isfile(joinpath(path, target_version * ".jl"))
        throw(MigrationFileNotFound(joinpath(path, target_version * ".jl")))
    end

    direction = "up"
    versions = get_versions(path)
    sort!(versions, by=x -> x[2], rev=false)

    if current_version !== nothing
        if current_version == target_version
            return
        end

        cur_idx = findfirst(x -> x[1] == current_version, versions)
        next_idx = findfirst(x -> x[1] == target_version, versions)

        if cur_idx > next_idx
            direction = "down"
            versions_to_execute = sort(versions, by=x -> x[2], rev=true)[next_idx:cur_idx-1]
        else
            direction = "up"
            versions_to_execute = versions[cur_idx+1:next_idx]
        end
    else
        next_idx = findfirst(x -> x[1] == target_version, versions)
        versions_to_execute = versions[1:next_idx]
    end

    Wasabi.begin_transaction(db)
    try
        for (version, _) in versions_to_execute
            include(joinpath(path, version * ".jl"))
            if direction == "up"
                Base.invokelatest(up, db)
            else
                Base.invokelatest(down, db)
            end
        end

        Wasabi.delete_all!(db, Migration)
        migration = Migration(target_version)
        Wasabi.insert!(db, migration)

        Wasabi.commit!(db)
    catch e
        Wasabi.rollback(db)
        throw(e)
    end
end

function generate(path::String)::String
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

function init(path::String)::String
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
        Wasabi.create_schema(db, Migrations.Migration, constraints)
    end

    function down(db::Any)
        Wasabi.delete_schema(db, Migrations.Migration)
    end
    """

    open(joinpath(path, version * ".jl"), "w") do f
        write(f, content)
    end

    return version
end

end