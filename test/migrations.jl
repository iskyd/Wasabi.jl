@testset "migrations" begin
    using SQLite
    configuration = SQLiteConnectionConfiguration("test.db")
    conn = Wasabi.connect(configuration)

    path = mkdir("migrations/")
    @test Migrations.get_versions(path) == []

    init_version = Migrations.init(path)
    versions = Migrations.get_versions(path)
    @test length(versions) == 1
    @test versions[1][1] == init_version

    try
        Migrations.init(path)
    catch e
        @test e.msg == "Directory is not empty"
    end

    last_version = Migrations.generate(path)
    versions = Migrations.get_versions(path)
    @test length(versions) == 2

    @test last_version == Migrations.get_last_version(path)

    @test Migrations.get_current_version(conn) === nothing

    try
        Migrations.execute(conn, path, "elDwLsbc")
    catch e
        @test e isa Migrations.MigrationFileNotFound
    end

    Migrations.execute(conn, path, last_version)
    @test Migrations.get_current_version(conn) == last_version

    Migrations.execute(conn, path, init_version)
    @test Migrations.get_current_version(conn) == init_version

    # Execute the same migration as the current version. Nothing should happen.
    Migrations.execute(conn, path, init_version)
    @test Migrations.get_current_version(conn) == init_version

    # Execute a migrations that throws an error. Rollback should happen.
    created_at = Dates.format(now(), "yyyy-mm-ddTHH:MM:SS.sss")
    error_migrations = """
        using Wasabi

        # Created at: $created_at

        down_version = "$last_version"

        function up(db::Any)
            Wasabi.execute_query(db, rq"INVALID QUERY;")
        end

        function down(db::Any)
        end
    """
    error_migration_version = Migrations.generate(path)
    open(joinpath(path, error_migration_version * ".jl"), "w") do f
        write(f, error_migrations)
    end

    try
        Migrations.execute(conn, path, error_migration_version)
    catch e
        @test e isa SQLite.SQLiteException
    end
    @test Migrations.get_current_version(conn) == init_version

    Wasabi.disconnect(conn)

    rm(path, recursive=true)
    rm("test.db")
end