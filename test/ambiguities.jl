@testset "ambiguities" begin
    @test length(detect_ambiguities(Wasabi; recursive=true)) == 0
end