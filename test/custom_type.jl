@testset "create custom type" begin
    using SQLite
    using JSON

    struct CustomType
        value::Dict
    end

    Wasabi.init_backend(Wasabi.SQLiteBackend())

    Wasabi.mapping(db::Type{SQLite.DB}, t::Type{CustomType}) = "TEXT"
    Wasabi.to_sql_value(value::CustomType) = JSON.json(value.value)
    Wasabi.from_sql_value(t::Type{CustomType}, value::Any) = CustomType(JSON.parse(value))

    struct TestModel <: Wasabi.Model
        id::Int
        custom::CustomType
    end

    Wasabi.primary_key(m::Type{TestModel}) = Wasabi.PrimaryKeyConstraint(Symbol[:id])

    configuration = WasabiSQLite.ConnectionConfiguration("test.db")
    conn = Wasabi.connect(configuration)

    Wasabi.create_schema(conn, TestModel)

    model = TestModel(1, CustomType(Dict("key" => "value")))
    Wasabi.insert!(conn, model)

    model = Wasabi.first(conn, TestModel, 1)
    @test model.custom.value["key"] == "value"

    sql = rq"SELECT * FROM test_model"
    df = Wasabi.execute_query(conn, sql)
    @test df.custom[1] == "{\"key\":\"value\"}"
    model = Wasabi.df2model(TestModel, df)[1]
    @test model.custom.value["key"] == "value"

    Wasabi.delete_schema(conn, TestModel)
    Wasabi.disconnect(conn)

    rm("test.db", recursive=true)
end