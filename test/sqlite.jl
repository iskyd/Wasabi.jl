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

    query = "INSERT INTO user (id, name) VALUES (?, ?)"
    Wasabi.execute_raw_query(conn, query, Any[1, "John Doe"])

    query = "SELECT * FROM user"
    result = Wasabi.execute_raw_query(conn, query)
    @test length(result[!, :id]) == 1
    @test result[!, :id][1] == 1
    @test result[!, :name][1] == "John Doe"

    user = Wasabi.df2model(User, result)[1]
    @test user.id == 1
    @test user.name == "John Doe"

    query = "INSERT INTO user (id, name) VALUES (?, ?)"
    Wasabi.execute_raw_query(conn, query, Any[2, "Jane Doe"])

    query = "SELECT * FROM user"
    result = Wasabi.execute_raw_query(conn, query)
    @test length(result[!, :id]) == 2
    @test result[!, :id][1] == 1
    @test result[!, :name][1] == "John Doe"
    @test result[!, :id][2] == 2
    @test result[!, :name][2] == "Jane Doe"

    users = Wasabi.df2model(User, result)
    @test length(users) == 2
    @test users[1].id == 1
    @test users[1].name == "John Doe"
    @test users[2].id == 2
    @test users[2].name == "Jane Doe"

    Wasabi.begin_transaction(conn)
    query = "INSERT INTO user (id, name) VALUES (?, ?)"
    Wasabi.execute_raw_query(conn, query, Any[3, "John Doe"])
    Wasabi.rollback(conn)

    query = "SELECT * FROM user"
    result = Wasabi.execute_raw_query(conn, query)
    @test length(result[!, :id]) == 2

    Wasabi.begin_transaction(conn)
    query = "INSERT INTO user (id, name) VALUES (?, ?)"
    Wasabi.execute_raw_query(conn, query, Any[3, "John Doe"])
    Wasabi.commit(conn)

    query = "SELECT * FROM user"
    result = Wasabi.execute_raw_query(conn, query)
    @test length(result[!, :id]) == 3

    user = Wasabi.first(conn, User, 1)
    @test user.id == 1
    @test user.name == "John Doe"

    user = Wasabi.first(conn, User, 10)
    @test user === nothing

    new_user = User(10, "John Doe")
    Wasabi.insert(conn, new_user)

    user = Wasabi.first(conn, User, 10)
    @test user.id == 10
    @test user.name == "John Doe"
end