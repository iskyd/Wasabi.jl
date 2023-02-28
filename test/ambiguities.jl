@safetestset "ambiguities" begin
    using Wasabi
    using Test

    @test length(detect_ambiguities(Wasabi)) == 0
end