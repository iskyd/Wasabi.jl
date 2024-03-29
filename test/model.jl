@testset "model" begin
    using DataFrames

    u = User("John", now())
    @test Wasabi.model2tuple(u) == ((:id, nothing), (:name, "John"), (:created_at, u.created_at), (:roles, Role[]), (:profile, nothing))

    Base.:(==)(a::Role, b::Role) = a.name == b.name && a.user_id == b.user_id && a.id == b.id
    Base.:(==)(a::UserProfile, b::UserProfile) = a.bio == b.bio && a.user_id == b.user_id && a.id == b.id

    u = User("John", now(), [Role("admin", 1), Role("user", 1)], UserProfile(1, "bio"))
    @test Wasabi.model2tuple(u) == ((:id, nothing), (:name, "John"), (:created_at, u.created_at), (:roles, Role[Role("admin", 1), Role("user", 1)]), (:profile, UserProfile(1, "bio")))

    df = DataFrame(id = [1, 2, 3], name = ["John", "Jane", "Joe"], created_at = [now(), now(), now()])
    models = Wasabi.df2model(User, df)

    @test models[1].id == 1
    @test models[2].id == 2
    @test models[3].id == 3
    @test models[1].name == "John"
    @test models[2].name == "Jane"
    @test models[3].name == "Joe"
    @test models[1].created_at == df.created_at[1]
    @test models[2].created_at == df.created_at[2]
    @test models[3].created_at == df.created_at[3]
end