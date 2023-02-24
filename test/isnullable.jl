@safetestset "tablename" begin
    using Wasabi

    struct User <: Wasabi.Model
        id::Int
        name::Union{String,Nothing}
    end

    constraints = [
        Wasabi.PrimaryKeyConstraint([:id])
    ]

    @test Wasabi.isnullable(User, :id, constraints) == false
    @test Wasabi.isnullable(User, :name, constraints) == true

    struct UserProfile <: Wasabi.Model
        id::Union{Int,Nothing}
        user_id::Int
        bio::Union{String,Nothing}
    end

    constraints = [
        Wasabi.PrimaryKeyConstraint([:id]),
        Wasabi.ForeignKeyConstraint([:user_id], :user, [:id])
    ]

    @test Wasabi.isnullable(UserProfile, :id, constraints) == false
end