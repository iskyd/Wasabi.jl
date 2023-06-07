@testset "postgresql" begin
    using LibPQ

    configuration = PostgreSQLConnectionConfiguration(
        endpoint="localhost",
        username="postgres",
        password="postgres",
        port=5432,
        dbname="test"
    )
    conn = Wasabi.connect(configuration)

    @test Wasabi.mapping(LibPQ.Connection, Int64) == "INTEGER"
    @test Wasabi.mapping(LibPQ.Connection, String) == "TEXT"
    @test Wasabi.mapping(LibPQ.Connection, Bool) == "BOOLEAN"
    @test Wasabi.mapping(LibPQ.Connection, Float64) == "REAL"
    @test Wasabi.mapping(LibPQ.Connection, Any) == "BLOB"
    @test Wasabi.mapping(LibPQ.Connection, Date) == "DATE"
    @test Wasabi.mapping(LibPQ.Connection, DateTime) == "TIMESTAMP"
    @test Wasabi.mapping(LibPQ.Connection, Wasabi.AutoIncrement) == "SERIAL"

    Mocking.activate()
    patch = @patch LibPQ.execute(conn::LibPQ.Connection, query::String) = query

    apply(patch) do
        @test Wasabi.delete_schema(conn, User) == "DROP TABLE IF EXISTS \"user\""
        @test Wasabi.delete_schema(conn, Role) == "DROP TABLE IF EXISTS \"role\""
        @test Wasabi.create_schema(conn, User) == "CREATE TABLE IF NOT EXISTS \"user\" (id SERIAL NOT NULL, name TEXT NOT NULL, created_at TIMESTAMP NOT NULL, PRIMARY KEY (id))"
        @test Wasabi.create_schema(conn, Role) == "CREATE TABLE IF NOT EXISTS \"role\" (id SERIAL NOT NULL, name TEXT NOT NULL, user_id INTEGER NOT NULL, PRIMARY KEY (id), FOREIGN KEY (user_id) REFERENCES \"user\" (id))"
    end

    patch_execute_raw_query = @patch Wasabi.execute_query(conn::LibPQ.Connection, query::Wasabi.RawQuery, params::Vector{Any}=Any[]) = query
    apply(patch_execute_raw_query) do
        query = QueryBuilder.from(User) |> QueryBuilder.select([:id, :name]) |> QueryBuilder.limit(1) |> QueryBuilder.offset(1)
        @test Wasabi.execute_query(conn, query) == rq"SELECT user_alias.id, user_alias.name FROM \"user\" user_alias LIMIT 1 OFFSET 1"

        query = QueryBuilder.from(User) |> QueryBuilder.select([:id, :name]) |> QueryBuilder.join(User, Role, :inner, (:id, :user_id), [:name])
        @test Wasabi.execute_query(conn, query) == rq"SELECT user_alias.id, user_alias.name, role_alias.name FROM \"user\" user_alias INNER JOIN \"role\" role_alias ON user_alias.id = role_alias.user_id"
    end

    Mocking.deactivate()

    Wasabi.delete_schema(conn, Role)
    Wasabi.delete_schema(conn, User)

    Wasabi.create_schema(conn, User)
    Wasabi.create_schema(conn, Role)

    dtnow = Dates.now()
    query = rq"INSERT INTO \"user\" (name, created_at) VALUES ($1, $2)"
    Wasabi.execute_query(conn, query, Any["John Doe", dtnow])

    query = rq"SELECT * FROM \"user\""
    result = Wasabi.execute_query(conn, query)
    @test length(result[!, :id]) == 1
    @test result[!, :id][1] == 1
    @test result[!, :name][1] == "John Doe"
    @test result[!, :created_at][1] == dtnow

    user = Wasabi.df2model(User, result)[1]
    @test user.id == 1
    @test user.name == "John Doe"
    @test user.created_at == dtnow

    query = rq"INSERT INTO \"user\" (name, created_at) VALUES ($1, $2)"
    Wasabi.execute_query(conn, query, Any["Jane Doe", dtnow])

    query = rq"SELECT * FROM \"user\""
    result = Wasabi.execute_query(conn, query)
    @test length(result[!, :id]) == 2
    @test result[!, :id][1] == 1
    @test result[!, :name][1] == "John Doe"
    @test result[!, :created_at][1] == dtnow
    @test result[!, :id][2] == 2
    @test result[!, :name][2] == "Jane Doe"
    @test result[!, :created_at][2] == dtnow

    users = Wasabi.df2model(User, result)
    @test length(users) == 2
    @test users[1].id == 1
    @test users[1].name == "John Doe"
    @test users[1].created_at == dtnow
    @test users[2].id == 2
    @test users[2].name == "Jane Doe"
    @test users[2].created_at == dtnow

    Wasabi.begin_transaction(conn)
    query = rq"INSERT INTO \"user\" (name, created_at) VALUES ($1, $2)"
    Wasabi.execute_query(conn, query, Any["John Doe", dtnow])
    Wasabi.rollback(conn)

    query = rq"SELECT * FROM \"user\""
    result = Wasabi.execute_query(conn, query)
    @test length(result[!, :id]) == 2

    Wasabi.begin_transaction(conn)
    query = rq"INSERT INTO \"user\" (name, created_at) VALUES ($1, $2)"
    Wasabi.execute_query(conn, query, Any["John Doe", dtnow])
    Wasabi.commit!(conn)

    query = rq"SELECT * FROM \"user\""
    result = Wasabi.execute_query(conn, query)
    @test length(result[!, :id]) == 3

    user = Wasabi.first(conn, User, 1)
    @test user.id == 1
    @test user.name == "John Doe"

    user = Wasabi.first(conn, User, 10)
    @test user === nothing

    new_user = User("John Doe", dtnow)
    keys = Wasabi.insert!(conn, new_user)
    @test keys[1, 1] == 5 # This is because even if we have only 3 users postgresql assign the id to the rollbacked user

    user = Wasabi.first(conn, User, 5)
    @test user.id == 5
    @test user.name == "John Doe"
    @test user.created_at == dtnow

    user.name = "Jane Doe"
    Wasabi.update!(conn, user)

    user = Wasabi.first(conn, User, 5)
    @test user.id == 5
    @test user.name == "Jane Doe"
    @test user.created_at == dtnow

    Wasabi.delete!(conn, user)

    user = Wasabi.first(conn, User, 5)
    @test user === nothing

    users = Wasabi.all(conn, User)
    @test length(users) == 3

    qb = QueryBuilder.from(User) |> QueryBuilder.select() |> QueryBuilder.limit(1) |> QueryBuilder.offset(1)
    users = Wasabi.execute_query(conn, qb)
    @test length(users[!, :id]) == 1
    user = Wasabi.df2model(User, users)[1]
    @test user.id == 2
    @test user.name == "Jane Doe"
    @test user.created_at == dtnow

    qb = QueryBuilder.from(User) |> QueryBuilder.select() |> QueryBuilder.where(:(and, (User, name, like, "%John%")))
    users = Wasabi.execute_query(conn, qb)
    @test length(users[!, :id]) == 2

    qb = QueryBuilder.from(User) |> QueryBuilder.select(User, :id, :total, :count)
    totals = Wasabi.execute_query(conn, qb)
    @test length(totals[!, :total]) == 1
    @test totals[!, :total][1] == 3

    qb = QueryBuilder.from(User) |> QueryBuilder.select() |> QueryBuilder.where(:(and, (User, id, in, [1, 2])))
    users = Wasabi.execute_query(conn, qb)
    @test length(users[!, :id]) == 2

    Wasabi.delete_all!(conn, User)
    @test length(Wasabi.all(conn, User)) == 0

    Wasabi.disconnect(conn)
end