@testset "postgres" begin
    using LibPQ

    configuration = Wasabi.PostgreSQLConnectionConfiguration(
        endpoint="localhost",
        username="postgres",
        password="postgres",
        port=5432,
        dbname="test"
    )
    conn = Wasabi.connect(configuration)

    constraints = [
        Wasabi.PrimaryKeyConstraint([:id]),
        Wasabi.UniqueConstraint([:id])
    ]

    Mocking.activate()

    patch = @patch LibPQ.execute(conn::LibPQ.Connection, query::String) = query

    apply(patch) do
        @test Wasabi.delete_schema(conn, UserProfile) == "DROP TABLE IF EXISTS \"user_profile\""
        @test Wasabi.delete_schema(conn, User) == "DROP TABLE IF EXISTS \"user\""
        @test Wasabi.create_schema(conn, User) == "CREATE TABLE IF NOT EXISTS \"user\" (id INTEGER NOT NULL, name TEXT NOT NULL)"
        @test Wasabi.create_schema(conn, User, constraints) == "CREATE TABLE IF NOT EXISTS \"user\" (id INTEGER NOT NULL, name TEXT NOT NULL, PRIMARY KEY (id), UNIQUE (id))"
    end

    constraints = [
        Wasabi.PrimaryKeyConstraint([:id]),
        Wasabi.ForeignKeyConstraint([:id], :user, [:id])
    ]

    apply(patch) do
        @test Wasabi.create_schema(conn, UserProfile, constraints) == "CREATE TABLE IF NOT EXISTS \"user_profile\" (id INTEGER NOT NULL, user_id INTEGER NOT NULL, bio TEXT, PRIMARY KEY (id), FOREIGN KEY (id) REFERENCES \"user\" (id))"
    end

    constraints = [
        Wasabi.PrimaryKeyConstraint([:id]),
        Wasabi.ForeignKeyConstraint([:user_id], :user, [:id]),
        Wasabi.UniqueConstraint([:user_id])
    ]

    apply(patch) do
        @test Wasabi.create_schema(conn, UserProfile, constraints) == "CREATE TABLE IF NOT EXISTS \"user_profile\" (id INTEGER NOT NULL, user_id INTEGER NOT NULL, bio TEXT, PRIMARY KEY (id), FOREIGN KEY (user_id) REFERENCES \"user\" (id), UNIQUE (user_id))"
    end

    patch_execute_raw_query = @patch Wasabi.execute_raw_query(conn::LibPQ.Connection, query::T, params::Vector{Any}=Any[]) where {T<:AbstractString} = query
    apply(patch_execute_raw_query) do
        query = @pipe QueryBuilder.select(User, [:id, :name]) |> QueryBuilder.limit(_, 1) |> QueryBuilder.offset(_, 1) |> Wasabi.execute_query(conn, _)
        @test query == "SELECT user.id, user.name FROM \"user\" user LIMIT 1 OFFSET 1"

        query = @pipe QueryBuilder.select(User, [:id, :name]) |> QueryBuilder.join(_, User, UserProfile, :inner, (:id, :user_id), [:bio]) |> QueryBuilder.join(_, UserProfile, UserPhone, :inner, (:id, :user_profile_id), [:phone]) |> Wasabi.execute_query(conn, _)
        @test query == "SELECT user.id, user.name, user_profile.bio, user_phone.phone FROM \"user\" user INNER JOIN \"user_profile\" user_profile ON user.id = user_profile.user_id INNER JOIN \"user_phone\" user_phone ON user_profile.id = user_phone.user_profile_id"
    end

    Mocking.deactivate()

    Wasabi.delete_schema(conn, UserProfile)
    Wasabi.delete_schema(conn, User)

    Wasabi.create_schema(conn, User)
    Wasabi.create_schema(conn, UserProfile)

    query = "INSERT INTO \"user\" (id, name) VALUES (\$1, \$2)"
    Wasabi.execute_raw_query(conn, query, Any[1, "John Doe"])

    query = "SELECT * FROM \"user\""
    result = Wasabi.execute_raw_query(conn, query)

    @test length(result[!, :id]) == 1
    @test result[!, :id][1] == 1
    @test result[!, :name][1] == "John Doe"

    user = Wasabi.df2model(User, result)[1]
    @test user.id == 1
    @test user.name == "John Doe"

    query = "INSERT INTO \"user\" (id, name) VALUES (\$1, \$2)"
    Wasabi.execute_raw_query(conn, query, Any[2, "Jane Doe"])

    query = "SELECT * FROM \"user\""
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
    query = "INSERT INTO \"user\" (id, name) VALUES (\$1, \$2)"
    Wasabi.execute_raw_query(conn, query, Any[3, "John Doe"])
    Wasabi.rollback(conn)

    query = "SELECT * FROM \"user\""
    result = Wasabi.execute_raw_query(conn, query)
    @test length(result[!, :id]) == 2

    Wasabi.begin_transaction(conn)
    query = "INSERT INTO \"user\" (id, name) VALUES (\$1, \$2)"
    Wasabi.execute_raw_query(conn, query, Any[3, "John Doe"])
    Wasabi.commit!(conn)

    query = "SELECT * FROM \"user\""
    result = Wasabi.execute_raw_query(conn, query)
    @test length(result[!, :id]) == 3

    query == "SELECT user.id, user.name, user_profile.bio, user_phone.phone FROM \"user\" user INNER JOIN \"user_profile\" user_profile ON user.id = user_profile.user_id INNER JOIN \"user_phone\" user_phone ON user_profile.id = user_phone.user_profile_id"
    Wasabi.execute_raw_query(conn, query)

    user = Wasabi.first(conn, User, 1)
    @test user.id == 1
    @test user.name == "John Doe"

    user = Wasabi.first(conn, User, 10)
    @test user === nothing

    new_user = User(10, "John Doe")
    Wasabi.insert!(conn, new_user)

    user = Wasabi.first(conn, User, 10)
    @test user.id == 10
    @test user.name == "John Doe"

    user.name = "Jane Doe"
    Wasabi.update!(conn, user)

    user = Wasabi.first(conn, User, 10)
    @test user.id == 10
    @test user.name == "Jane Doe"

    Wasabi.delete!(conn, user)

    user = Wasabi.first(conn, User, 10)
    @test user === nothing

    users = Wasabi.all(conn, User)
    @test length(users) == 3

    Wasabi.delete_all!(conn, User)
    @test length(Wasabi.all(conn, User)) == 0

    Wasabi.delete_schema(conn, UserProfile)
    Wasabi.delete_schema(conn, User)

    Wasabi.disconnect(conn)
end