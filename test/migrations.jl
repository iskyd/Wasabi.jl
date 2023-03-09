@safetestset "migrations" begin
    using Wasabi

    configuration = Wasabi.SQLiteConnectionConfiguration("test.db")
    conn = Wasabi.connect(configuration)

    path = mkdir("migrations/")
    @test Migrations.get_versions(path) == []

    init_version = Migrations.init(path)
    versions = Migrations.get_versions(path)
    @test length(versions) == 1
    @test versions[1][1] == init_version

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

    rm(path, recursive=true)
    rm("test.db")
end