@safetestset "migrations" begin
    using Wasabi

    configuration = Wasabi.SQLiteConnectionConfiguration("test.db")
    conn = Wasabi.connect(configuration)

    path = mkdir("migrations/")
    @test Wasabi.get_migrations_version(path) == []

    init_version = Wasabi.init_migration(path)
    versions = Wasabi.get_migrations_version(path)
    @test length(versions) == 1
    @test versions[1][1] == init_version

    last_version = Wasabi.generate_migration(path)
    versions = Wasabi.get_migrations_version(path)
    @test length(versions) == 2

    @test last_version == Wasabi.get_last_migration_version(path)

    @test Wasabi.get_current_migration_version(conn) === nothing

    try
        Wasabi.execute_migrations(conn, path, "elDwLsbc")
    catch e
        @test e isa Wasabi.MigrationFileNotFound
    end

    Wasabi.execute_migrations(conn, path, last_version)
    @test Wasabi.get_current_migration_version(conn) == last_version

    Wasabi.execute_migrations(conn, path, init_version)
    @test Wasabi.get_current_migration_version(conn) == init_version

    rm(path, recursive=true)
    rm("test.db")
end