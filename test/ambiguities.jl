@testset "ambiguities" begin
    @test length(detect_ambiguities(Wasabi)) == 0
end