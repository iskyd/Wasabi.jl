@testset "constraints" begin
    @test Wasabi.primary_key(User).fields == Wasabi.PrimaryKeyConstraint(Symbol[:id]).fields
    @test Wasabi.primary_key(Role).fields == Wasabi.PrimaryKeyConstraint(Symbol[:id]).fields

    @test length(Wasabi.foreign_keys(User)) == 0

    role_foreign_constraints = Wasabi.foreign_keys(Role)
    @test length(role_foreign_constraints) == 1
    @test role_foreign_constraints[1].fields == [:user_id]
    @test role_foreign_constraints[1].foreign_table == :user
    @test role_foreign_constraints[1].foreign_fields == [:id]

    @test length(Wasabi.unique_constraints(User)) == 0

    constraints = Wasabi.constraints(Role)
    @test length(constraints) == 2
    @test constraints[1] isa Wasabi.PrimaryKeyConstraint
    @test constraints[1].fields == Wasabi.primary_key(Role).fields

    @test constraints[2] isa Wasabi.ForeignKeyConstraint
    @test constraints[2].fields == Wasabi.foreign_keys(Role)[1].fields
    @test constraints[2].foreign_table == Wasabi.foreign_keys(Role)[1].foreign_table
    @test constraints[2].foreign_fields == Wasabi.foreign_keys(Role)[1].foreign_fields

    constraints = Wasabi.constraints(UserProfile)
    @test length(constraints) == 3
    @test constraints[1] isa Wasabi.PrimaryKeyConstraint
    @test constraints[1].fields == Wasabi.primary_key(UserProfile).fields
    @test constraints[2] isa Wasabi.ForeignKeyConstraint
    @test constraints[2].fields == Wasabi.foreign_keys(UserProfile)[1].fields
    @test constraints[2].foreign_table == Wasabi.foreign_keys(UserProfile)[1].foreign_table
    @test constraints[2].foreign_fields == Wasabi.foreign_keys(UserProfile)[1].foreign_fields
    @test constraints[3] isa Wasabi.UniqueConstraint
    @test constraints[3].fields == Wasabi.unique_constraints(UserProfile)[1].fields
end