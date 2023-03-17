@testset "isnullable" begin
    struct NullableNameUser <: Wasabi.Model
        id::Int
        name::Union{String,Nothing}
    end

    Wasabi.primary_key(m::Type{NullableNameUser}) = Wasabi.PrimaryKeyConstraint(Symbol[:id])

    @test Wasabi.isnullable(NullableNameUser, :id) == false
    @test Wasabi.isnullable(NullableNameUser, :name) == true

    struct NullableUserProfile <: Wasabi.Model
        id::Union{Int,Nothing}
        user_id::Int
        bio::Union{String,Nothing}
    end

    Wasabi.primary_key(m::Type{NullableUserProfile}) = Wasabi.PrimaryKeyConstraint(Symbol[:id])
    Wasabi.foreign_keys(m::Type{NullableUserProfile}) = [Wasabi.ForeignKeyConstraint(Symbol[:user_id], :user, Symbol[:id])]

    @test Wasabi.isnullable(NullableUserProfile, :id) == false
end