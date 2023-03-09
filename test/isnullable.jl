@testset "isnullable" begin
    struct NullableNameUser <: Wasabi.Model
        id::Int
        name::Union{String,Nothing}
    end

    constraints = [
        Wasabi.PrimaryKeyConstraint([:id])
    ]

    @test Wasabi.isnullable(NullableNameUser, :id, constraints) == false
    @test Wasabi.isnullable(NullableNameUser, :name, constraints) == true

    struct NullableUserProfile <: Wasabi.Model
        id::Union{Int,Nothing}
        user_id::Int
        bio::Union{String,Nothing}
    end

    constraints = [
        Wasabi.PrimaryKeyConstraint([:id]),
        Wasabi.ForeignKeyConstraint([:user_id], :user, [:id])
    ]

    @test Wasabi.isnullable(NullableUserProfile, :id, constraints) == false
end