@safetestset "sqlite backend" begin
    using Wasabi

    struct User <: Wasabi.Model
        id::Int
        name::String
    end

    struct UserProfile <: Wasabi.Model
        id::Int
        user_id::Int
        bio::String
    end

    constraints = [
        Wasabi.PrimaryKeyConstraint([:id])
    ]

    configuration = Wasabi.SQLiteConnectionConfiguration("test.db")
    conn = Wasabi.connect(configuration)

    Wasabi.delete_schema(conn, User)
    Wasabi.delete_schema(conn, UserProfile)

    q = Wasabi.create_schema(conn, User)
    @test q == "CREATE TABLE IF NOT EXISTS user (id INTEGER, name TEXT)"

    q = Wasabi.create_schema(conn, User, constraints)
    @test q == "CREATE TABLE IF NOT EXISTS user (id INTEGER, name TEXT, PRIMARY KEY (id))"

    constraints = [
        Wasabi.PrimaryKeyConstraint([:id]),
        Wasabi.ForeignKeyConstraint([:id], :user, [:id])
    ]
    q = Wasabi.create_schema(conn, UserProfile, constraints)
    @test q == "CREATE TABLE IF NOT EXISTS user_profile (id INTEGER, user_id INTEGER, bio TEXT, PRIMARY KEY (id), FOREIGN KEY (id) REFERENCES user (id))"

    constraints = [
        Wasabi.PrimaryKeyConstraint([:id]),
        Wasabi.ForeignKeyConstraint([:user_id], :user, [:id]),
        Wasabi.UniqueConstraint([:user_id])
    ]
    q = Wasabi.create_schema(conn, UserProfile, constraints)
    @test q == "CREATE TABLE IF NOT EXISTS user_profile (id INTEGER, user_id INTEGER, bio TEXT, PRIMARY KEY (id), FOREIGN KEY (user_id) REFERENCES user (id), UNIQUE (user_id))"

    constraints = [
        Wasabi.PrimaryKeyConstraint([:id]),
        Wasabi.ForeignKeyConstraint([:user_id], :user, [:id]),
        Wasabi.UniqueConstraint([:user_id]),
        Wasabi.NotNullConstraint([:bio, :user_id])
    ]
    q = Wasabi.create_schema(conn, UserProfile, constraints)
    @test q == "CREATE TABLE IF NOT EXISTS user_profile (id INTEGER, user_id INTEGER NOT NULL, bio TEXT NOT NULL, PRIMARY KEY (id), FOREIGN KEY (user_id) REFERENCES user (id), UNIQUE (user_id))"
end