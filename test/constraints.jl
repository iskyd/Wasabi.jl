@testset "constraints" begin
    @test Wasabi.primary_key(User).fields == Wasabi.PrimaryKeyConstraint(Symbol[:id]).fields
    @test Wasabi.primary_key(UserProfile).fields == Wasabi.PrimaryKeyConstraint(Symbol[:id]).fields
    @test Wasabi.primary_key(UserPhone).fields == Wasabi.PrimaryKeyConstraint(Symbol[:id]).fields

    @test length(Wasabi.foreign_keys(User)) == 0

    user_profile_foreign_constraints = Wasabi.foreign_keys(UserProfile)
    @test length(user_profile_foreign_constraints) == 1
    @test user_profile_foreign_constraints[1].fields == [:user_id]
    @test user_profile_foreign_constraints[1].foreign_table == :user
    @test user_profile_foreign_constraints[1].foreign_fields == [:id]

    user_phone_foreign_constraints = Wasabi.foreign_keys(UserProfile)
    @test length(user_phone_foreign_constraints) == 1
    @test user_phone_foreign_constraints[1].fields == [:user_id]
    @test user_phone_foreign_constraints[1].foreign_table == :user
    @test user_phone_foreign_constraints[1].foreign_fields == [:id]

    @test length(Wasabi.unique_constraints(User)) == 0
    @test length(Wasabi.unique_constraints(UserPhone)) == 0
    
    user_profile_unique_constraints = Wasabi.unique_constraints(UserProfile)
    @test length(user_profile_unique_constraints) == 1
    @test user_profile_unique_constraints[1].fields == [:user_id]
end